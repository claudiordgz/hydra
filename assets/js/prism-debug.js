/* http://prismjs.com/download.html?themes=prism-okaidia&languages=markup+css+clike+javascript+bash+c+csharp+cpp+go+handlebars+haskell+java+latex+makefile+markdown+python+r+jsx+scss+scala+scheme */
var _self = (typeof window !== 'undefined')
    ? window   // if in browser
    : (
    (typeof WorkerGlobalScope !== 'undefined' && self instanceof WorkerGlobalScope)
        ? self // if in worker
        : {}   // if in node js
);

/**
 * Prism: Lightweight, robust, elegant syntax highlighting
 * MIT license http://www.opensource.org/licenses/mit-license.php/
 * @author Lea Verou http://lea.verou.me
 */

var Prism = (function(){

// Private helper vars
    var lang = /\blang(?:uage)?-(?!\*)(\w+)\b/i;

    var _ = _self.Prism = {
        util: {
            encode: function (tokens) {
                if (tokens instanceof Token) {
                    return new Token(tokens.type, _.util.encode(tokens.content), tokens.alias);
                } else if (_.util.type(tokens) === 'Array') {
                    return tokens.map(_.util.encode);
                } else {
                    return tokens.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/\u00a0/g, ' ');
                }
            },

            type: function (o) {
                return Object.prototype.toString.call(o).match(/\[object (\w+)\]/)[1];
            },

            // Deep clone a language definition (e.g. to extend it)
            clone: function (o) {
                var type = _.util.type(o);

                switch (type) {
                    case 'Object':
                        var clone = {};

                        for (var key in o) {
                            if (o.hasOwnProperty(key)) {
                                clone[key] = _.util.clone(o[key]);
                            }
                        }

                        return clone;

                    case 'Array':
                        // Check for existence for IE8
                        return o.map && o.map(function(v) { return _.util.clone(v); });
                }

                return o;
            }
        },

        languages: {
            extend: function (id, redef) {
                var lang = _.util.clone(_.languages[id]);

                for (var key in redef) {
                    lang[key] = redef[key];
                }

                return lang;
            },

            /**
             * Insert a token before another token in a language literal
             * As this needs to recreate the object (we cannot actually insert before keys in object literals),
             * we cannot just provide an object, we need anobject and a key.
             * @param inside The key (or language id) of the parent
             * @param before The key to insert before. If not provided, the function appends instead.
             * @param insert Object with the key/value pairs to insert
             * @param root The object that contains `inside`. If equal to Prism.languages, it can be omitted.
             */
            insertBefore: function (inside, before, insert, root) {
                root = root || _.languages;
                var grammar = root[inside];

                if (arguments.length == 2) {
                    insert = arguments[1];

                    for (var newToken in insert) {
                        if (insert.hasOwnProperty(newToken)) {
                            grammar[newToken] = insert[newToken];
                        }
                    }

                    return grammar;
                }

                var ret = {};

                for (var token in grammar) {

                    if (grammar.hasOwnProperty(token)) {

                        if (token == before) {

                            for (var newToken in insert) {

                                if (insert.hasOwnProperty(newToken)) {
                                    ret[newToken] = insert[newToken];
                                }
                            }
                        }

                        ret[token] = grammar[token];
                    }
                }

                // Update references in other language definitions
                _.languages.DFS(_.languages, function(key, value) {
                    if (value === root[inside] && key != inside) {
                        this[key] = ret;
                    }
                });

                return root[inside] = ret;
            },

            // Traverse a language definition with Depth First Search
            DFS: function(o, callback, type) {
                for (var i in o) {
                    if (o.hasOwnProperty(i)) {
                        callback.call(o, i, o[i], type || i);

                        if (_.util.type(o[i]) === 'Object') {
                            _.languages.DFS(o[i], callback);
                        }
                        else if (_.util.type(o[i]) === 'Array') {
                            _.languages.DFS(o[i], callback, i);
                        }
                    }
                }
            }
        },

        highlightAll: function(async, callback) {
            var elements = document.querySelectorAll('code[class*="language-"], [class*="language-"] code, code[class*="lang-"], [class*="lang-"] code');

            for (var i=0, element; element = elements[i++];) {
                _.highlightElement(element, async === true, callback);
            }
        },

        highlightElement: function(element, async, callback) {
            // Find language
            var language, grammar, parent = element;

            while (parent && !lang.test(parent.className)) {
                parent = parent.parentNode;
            }

            if (parent) {
                language = (parent.className.match(lang) || [,''])[1];
                grammar = _.languages[language];
            }

            // Set language on the element, if not present
            element.className = element.className.replace(lang, '').replace(/\s+/g, ' ') + ' language-' + language;

            // Set language on the parent, for styling
            parent = element.parentNode;

            if (/pre/i.test(parent.nodeName)) {
                parent.className = parent.className.replace(lang, '').replace(/\s+/g, ' ') + ' language-' + language;
            }

            if (!grammar) {
                return;
            }

            var code = element.textContent;

            if(!code) {
                return;
            }

            code = code.replace(/^(?:\r?\n|\r)/,'');

            var env = {
                element: element,
                language: language,
                grammar: grammar,
                code: code
            };

            _.hooks.run('before-highlight', env);

            if (async && _self.Worker) {
                var worker = new Worker(_.filename);

                worker.onmessage = function(evt) {
                    env.highlightedCode = Token.stringify(JSON.parse(evt.data), language);

                    _.hooks.run('before-insert', env);

                    env.element.innerHTML = env.highlightedCode;

                    callback && callback.call(env.element);
                    _.hooks.run('after-highlight', env);
                };

                worker.postMessage(JSON.stringify({
                    language: env.language,
                    code: env.code
                }));
            }
            else {
                env.highlightedCode = _.highlight(env.code, env.grammar, env.language);

                _.hooks.run('before-insert', env);

                env.element.innerHTML = env.highlightedCode;

                callback && callback.call(element);

                _.hooks.run('after-highlight', env);
            }
        },

        highlight: function (text, grammar, language) {
            var tokens = _.tokenize(text, grammar);
            return Token.stringify(_.util.encode(tokens), language);
        },

        tokenize: function(text, grammar, language) {
            var Token = _.Token;

            var strarr = [text];

            var rest = grammar.rest;

            if (rest) {
                for (var token in rest) {
                    grammar[token] = rest[token];
                }

                delete grammar.rest;
            }

            tokenloop: for (var token in grammar) {
                if(!grammar.hasOwnProperty(token) || !grammar[token]) {
                    continue;
                }

                var patterns = grammar[token];
                patterns = (_.util.type(patterns) === "Array") ? patterns : [patterns];

                for (var j = 0; j < patterns.length; ++j) {
                    var pattern = patterns[j],
                        inside = pattern.inside,
                        lookbehind = !!pattern.lookbehind,
                        lookbehindLength = 0,
                        alias = pattern.alias;

                    pattern = pattern.pattern || pattern;

                    for (var i=0; i<strarr.length; i++) { // Don’t cache length as it changes during the loop

                        var str = strarr[i];

                        if (strarr.length > text.length) {
                            // Something went terribly wrong, ABORT, ABORT!
                            break tokenloop;
                        }

                        if (str instanceof Token) {
                            continue;
                        }

                        pattern.lastIndex = 0;

                        var match = pattern.exec(str);

                        if (match) {
                            if(lookbehind) {
                                lookbehindLength = match[1].length;
                            }

                            var from = match.index - 1 + lookbehindLength,
                                match = match[0].slice(lookbehindLength),
                                len = match.length,
                                to = from + len,
                                before = str.slice(0, from + 1),
                                after = str.slice(to + 1);

                            var args = [i, 1];

                            if (before) {
                                args.push(before);
                            }

                            var wrapped = new Token(token, inside? _.tokenize(match, inside) : match, alias);

                            args.push(wrapped);

                            if (after) {
                                args.push(after);
                            }

                            Array.prototype.splice.apply(strarr, args);
                        }
                    }
                }
            }

            return strarr;
        },

        hooks: {
            all: {},

            add: function (name, callback) {
                var hooks = _.hooks.all;

                hooks[name] = hooks[name] || [];

                hooks[name].push(callback);
            },

            run: function (name, env) {
                var callbacks = _.hooks.all[name];

                if (!callbacks || !callbacks.length) {
                    return;
                }

                for (var i=0, callback; callback = callbacks[i++];) {
                    callback(env);
                }
            }
        }
    };

    var Token = _.Token = function(type, content, alias) {
        this.type = type;
        this.content = content;
        this.alias = alias;
    };

    Token.stringify = function(o, language, parent) {
        if (typeof o == 'string') {
            return o;
        }

        if (_.util.type(o) === 'Array') {
            return o.map(function(element) {
                return Token.stringify(element, language, o);
            }).join('');
        }

        var env = {
            type: o.type,
            content: Token.stringify(o.content, language, parent),
            tag: 'span',
            classes: ['token', o.type],
            attributes: {},
            language: language,
            parent: parent
        };

        if (env.type == 'comment') {
            env.attributes['spellcheck'] = 'true';
        }

        if (o.alias) {
            var aliases = _.util.type(o.alias) === 'Array' ? o.alias : [o.alias];
            Array.prototype.push.apply(env.classes, aliases);
        }

        _.hooks.run('wrap', env);

        var attributes = '';

        for (var name in env.attributes) {
            attributes += name + '="' + (env.attributes[name] || '') + '"';
        }

        return '<' + env.tag + ' class="' + env.classes.join(' ') + '" ' + attributes + '>' + env.content + '</' + env.tag + '>';

    };

    if (!_self.document) {
        if (!_self.addEventListener) {
            // in Node.js
            return _self.Prism;
        }
        // In worker
        _self.addEventListener('message', function(evt) {
            var message = JSON.parse(evt.data),
                lang = message.language,
                code = message.code;

            _self.postMessage(JSON.stringify(_.util.encode(_.tokenize(code, _.languages[lang]))));
            _self.close();
        }, false);

        return _self.Prism;
    }

// Get current script and highlight
    var script = document.getElementsByTagName('script');

    script = script[script.length - 1];

    if (script) {
        _.filename = script.src;

        if (document.addEventListener && !script.hasAttribute('data-manual')) {
            document.addEventListener('DOMContentLoaded', _.highlightAll);
        }
    }

    return _self.Prism;

})();

if (typeof module !== 'undefined' && module.exports) {
    module.exports = Prism;
}
;
Prism.languages.markup = {
    'comment': /<!--[\w\W]*?-->/,
    'prolog': /<\?[\w\W]+?\?>/,
    'doctype': /<!DOCTYPE[\w\W]+?>/,
    'cdata': /<!\[CDATA\[[\w\W]*?]]>/i,
    'tag': {
        pattern: /<\/?[^\s>\/]+(?:\s+[^\s>\/=]+(?:=(?:("|')(?:\\\1|\\?(?!\1)[\w\W])*\1|[^\s'">=]+))?)*\s*\/?>/i,
        inside: {
            'tag': {
                pattern: /^<\/?[^\s>\/]+/i,
                inside: {
                    'punctuation': /^<\/?/,
                    'namespace': /^[^\s>\/:]+:/
                }
            },
            'attr-value': {
                pattern: /=(?:('|")[\w\W]*?(\1)|[^\s>]+)/i,
                inside: {
                    'punctuation': /[=>"']/
                }
            },
            'punctuation': /\/?>/,
            'attr-name': {
                pattern: /[^\s>\/]+/,
                inside: {
                    'namespace': /^[^\s>\/:]+:/
                }
            }

        }
    },
    'entity': /&#?[\da-z]{1,8};/i
};

// Plugin to make entity title show the real entity, idea by Roman Komarov
Prism.hooks.add('wrap', function(env) {

    if (env.type === 'entity') {
        env.attributes['title'] = env.content.replace(/&amp;/, '&');
    }
});
;
Prism.languages.css = {
    'comment': /\/\*[\w\W]*?\*\//,
    'atrule': {
        pattern: /@[\w-]+?.*?(;|(?=\s*\{))/i,
        inside: {
            'rule': /@[\w-]+/
            // See rest below
        }
    },
    'url': /url\((?:(["'])(\\(?:\r\n|[\w\W])|(?!\1)[^\\\r\n])*\1|.*?)\)/i,
    'selector': /[^\{\}\s][^\{\};]*?(?=\s*\{)/,
    'string': /("|')(\\(?:\r\n|[\w\W])|(?!\1)[^\\\r\n])*\1/,
    'property': /(\b|\B)[\w-]+(?=\s*:)/i,
    'important': /\B!important\b/i,
    'function': /[-a-z0-9]+(?=\()/i,
    'punctuation': /[(){};:]/
};

Prism.languages.css['atrule'].inside.rest = Prism.util.clone(Prism.languages.css);

if (Prism.languages.markup) {
    Prism.languages.insertBefore('markup', 'tag', {
        'style': {
            pattern: /<style[\w\W]*?>[\w\W]*?<\/style>/i,
            inside: {
                'tag': {
                    pattern: /<style[\w\W]*?>|<\/style>/i,
                    inside: Prism.languages.markup.tag.inside
                },
                rest: Prism.languages.css
            },
            alias: 'language-css'
        }
    });

    Prism.languages.insertBefore('inside', 'attr-value', {
        'style-attr': {
            pattern: /\s*style=("|').*?\1/i,
            inside: {
                'attr-name': {
                    pattern: /^\s*style/i,
                    inside: Prism.languages.markup.tag.inside
                },
                'punctuation': /^\s*=\s*['"]|['"]\s*$/,
                'attr-value': {
                    pattern: /.+/i,
                    inside: Prism.languages.css
                }
            },
            alias: 'language-css'
        }
    }, Prism.languages.markup.tag);
};
Prism.languages.clike = {
    'comment': [
        {
            pattern: /(^|[^\\])\/\*[\w\W]*?\*\//,
            lookbehind: true
        },
        {
            pattern: /(^|[^\\:])\/\/.*/,
            lookbehind: true
        }
    ],
    'string': /("|')(\\(?:\r\n|[\s\S])|(?!\1)[^\\\r\n])*\1/,
    'class-name': {
        pattern: /((?:(?:class|interface|extends|implements|trait|instanceof|new)\s+)|(?:catch\s+\())[a-z0-9_\.\\]+/i,
        lookbehind: true,
        inside: {
            punctuation: /(\.|\\)/
        }
    },
    'keyword': /\b(if|else|while|do|for|return|in|instanceof|function|new|try|throw|catch|finally|null|break|continue)\b/,
    'boolean': /\b(true|false)\b/,
    'function': /[a-z0-9_]+(?=\()/i,
    'number': /\b-?(0x[\dA-Fa-f]+|\d*\.?\d+([Ee]-?\d+)?)\b/,
    'operator': /[-+]{1,2}|!|<=?|>=?|={1,3}|&{1,2}|\|?\||\?|\*|\/|~|\^|%/,
    'punctuation': /[{}[\];(),.:]/
};
;
Prism.languages.javascript = Prism.languages.extend('clike', {
    'keyword': /\b(as|async|await|break|case|catch|class|const|continue|debugger|default|delete|do|else|enum|export|extends|false|finally|for|from|function|get|if|implements|import|in|instanceof|interface|let|new|null|of|package|private|protected|public|return|set|static|super|switch|this|throw|true|try|typeof|var|void|while|with|yield)\b/,
    'number': /\b-?(0x[\dA-Fa-f]+|0b[01]+|0o[0-7]+|\d*\.?\d+([Ee][+-]?\d+)?|NaN|Infinity)\b/,
    'function': /(?!\d)[a-z0-9_$]+(?=\()/i
});

Prism.languages.insertBefore('javascript', 'keyword', {
    'regex': {
        pattern: /(^|[^/])\/(?!\/)(\[.+?]|\\.|[^/\\\r\n])+\/[gimyu]{0,5}(?=\s*($|[\r\n,.;})]))/,
        lookbehind: true
    }
});

Prism.languages.insertBefore('javascript', 'class-name', {
    'template-string': {
        pattern: /`(?:\\`|\\?[^`])*`/,
        inside: {
            'interpolation': {
                pattern: /\$\{[^}]+\}/,
                inside: {
                    'interpolation-punctuation': {
                        pattern: /^\$\{|\}$/,
                        alias: 'punctuation'
                    },
                    rest: Prism.languages.javascript
                }
            },
            'string': /[\s\S]+/
        }
    }
});

if (Prism.languages.markup) {
    Prism.languages.insertBefore('markup', 'tag', {
        'script': {
            pattern: /<script[\w\W]*?>[\w\W]*?<\/script>/i,
            inside: {
                'tag': {
                    pattern: /<script[\w\W]*?>|<\/script>/i,
                    inside: Prism.languages.markup.tag.inside
                },
                rest: Prism.languages.javascript
            },
            alias: 'language-javascript'
        }
    });
}
;
Prism.languages.bash = Prism.languages.extend('clike', {
    'comment': {
        pattern: /(^|[^"{\\])#.*/,
        lookbehind: true
    },
    'string': {
        //allow multiline string
        pattern: /("|')(\\?[\s\S])*?\1/,
        inside: {
            //'property' class reused for bash variables
            'property': /\$([a-zA-Z0-9_#\?\-\*!@]+|\{[^\}]+\})/
        }
    },
    // Redefined to prevent highlighting of numbers in filenames
    'number': {
        pattern: /([^\w\.])-?(0x[\dA-Fa-f]+|\d*\.?\d+([Ee]-?\d+)?)\b/,
        lookbehind: true
    },
    // Originally based on http://ss64.com/bash/
    'function': /\b(?:alias|apropos|apt-get|aptitude|aspell|awk|basename|bash|bc|bg|builtin|bzip2|cal|cat|cd|cfdisk|chgrp|chmod|chown|chroot|chkconfig|cksum|clear|cmp|comm|command|cp|cron|crontab|csplit|cut|date|dc|dd|ddrescue|df|diff|diff3|dig|dir|dircolors|dirname|dirs|dmesg|du|egrep|eject|enable|env|ethtool|eval|exec|expand|expect|export|expr|fdformat|fdisk|fg|fgrep|file|find|fmt|fold|format|free|fsck|ftp|fuser|gawk|getopts|git|grep|groupadd|groupdel|groupmod|groups|gzip|hash|head|help|hg|history|hostname|htop|iconv|id|ifconfig|ifdown|ifup|import|install|jobs|join|kill|killall|less|link|ln|locate|logname|logout|look|lpc|lpr|lprint|lprintd|lprintq|lprm|ls|lsof|make|man|mkdir|mkfifo|mkisofs|mknod|more|most|mount|mtools|mtr|mv|mmv|nano|netstat|nice|nl|nohup|notify-send|nslookup|open|op|passwd|paste|pathchk|ping|pkill|popd|pr|printcap|printenv|printf|ps|pushd|pv|pwd|quota|quotacheck|quotactl|ram|rar|rcp|read|readarray|readonly|reboot|rename|renice|remsync|rev|rm|rmdir|rsync|screen|scp|sdiff|sed|seq|service|sftp|shift|shopt|shutdown|sleep|slocate|sort|source|split|ssh|stat|strace|su|sudo|sum|suspend|sync|tail|tar|tee|test|time|timeout|times|touch|top|traceroute|trap|tr|tsort|tty|type|ulimit|umask|umount|unalias|uname|unexpand|uniq|units|unrar|unshar|uptime|useradd|userdel|usermod|users|uuencode|uudecode|v|vdir|vi|vmstat|wait|watch|wc|wget|whereis|which|who|whoami|write|xargs|xdg-open|yes|zip)\b/,
    'keyword': /\b(if|then|else|elif|fi|for|break|continue|while|in|case|function|select|do|done|until|echo|exit|return|set|declare)\b/
});

Prism.languages.insertBefore('bash', 'keyword', {
    //'property' class reused for bash variables
    'property': /\$([a-zA-Z0-9_#\?\-\*!@]+|\{[^}]+\})/
});
Prism.languages.insertBefore('bash', 'comment', {
    //shebang must be before comment, 'important' class from css reused
    'important': /^#!\s*\/bin\/bash|^#!\s*\/bin\/sh/
});
;
Prism.languages.c = Prism.languages.extend('clike', {
    'keyword': /\b(asm|typeof|inline|auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while)\b/,
    'operator': /\-[>-]?|\+\+?|!=?|<<?=?|>>?=?|==?|&&?|\|?\||[~^%?*\/]/
});

Prism.languages.insertBefore('c', 'string', {
    'macro': {
        // allow for multiline macro definitions
        // spaces after the # character compile fine with gcc
        pattern: /(^\s*)#\s*[a-z]+([^\r\n\\]|\\.|\\(?:\r\n?|\n))*/im,
        lookbehind: true,
        alias: 'property',
        inside: {
            // highlight the path of the include statement as a string
            'string': {
                pattern: /(#\s*include\s*)(<.+?>|("|')(\\?.)+?\3)/,
                lookbehind: true
            }
        }
    }
});

delete Prism.languages.c['class-name'];
delete Prism.languages.c['boolean'];;
Prism.languages.csharp = Prism.languages.extend('clike', {
    'keyword': /\b(abstract|as|async|await|base|bool|break|byte|case|catch|char|checked|class|const|continue|decimal|default|delegate|do|double|else|enum|event|explicit|extern|false|finally|fixed|float|for|foreach|goto|if|implicit|in|int|interface|internal|is|lock|long|namespace|new|null|object|operator|out|override|params|private|protected|public|readonly|ref|return|sbyte|sealed|short|sizeof|stackalloc|static|string|struct|switch|this|throw|true|try|typeof|uint|ulong|unchecked|unsafe|ushort|using|virtual|void|volatile|while|add|alias|ascending|async|await|descending|dynamic|from|get|global|group|into|join|let|orderby|partial|remove|select|set|value|var|where|yield)\b/,
    'string': [
        /@("|')(\1\1|\\\1|\\?(?!\1)[\s\S])*\1/,
        /("|')(\\?.)*?\1/
    ],
    'number': /\b-?(0x[\da-f]+|\d*\.?\d+)\b/i
});

Prism.languages.insertBefore('csharp', 'keyword', {
    'preprocessor': {
        pattern: /(^\s*)#.*/m,
        lookbehind: true
    }
});
;
Prism.languages.cpp = Prism.languages.extend('c', {
    'keyword': /\b(alignas|alignof|asm|auto|bool|break|case|catch|char|char16_t|char32_t|class|compl|const|constexpr|const_cast|continue|decltype|default|delete|do|double|dynamic_cast|else|enum|explicit|export|extern|float|for|friend|goto|if|inline|int|long|mutable|namespace|new|noexcept|nullptr|operator|private|protected|public|register|reinterpret_cast|return|short|signed|sizeof|static|static_assert|static_cast|struct|switch|template|this|thread_local|throw|try|typedef|typeid|typename|union|unsigned|using|virtual|void|volatile|wchar_t|while)\b/,
    'boolean': /\b(true|false)\b/,
    'operator': /[-+]{1,2}|!=?|<{1,2}=?|>{1,2}=?|\->|:{1,2}|={1,2}|\^|~|%|&{1,2}|\|?\||\?|\*|\/|\b(and|and_eq|bitand|bitor|not|not_eq|or|or_eq|xor|xor_eq)\b/
});

Prism.languages.insertBefore('cpp', 'keyword', {
    'class-name': {
        pattern: /(class\s+)[a-z0-9_]+/i,
        lookbehind: true
    }
});;
Prism.languages.go = Prism.languages.extend('clike', {
    'keyword': /\b(break|case|chan|const|continue|default|defer|else|fallthrough|for|func|go(to)?|if|import|interface|map|package|range|return|select|struct|switch|type|var)\b/,
    'builtin': /\b(bool|byte|complex(64|128)|error|float(32|64)|rune|string|u?int(8|16|32|64|)|uintptr|append|cap|close|complex|copy|delete|imag|len|make|new|panic|print(ln)?|real|recover)\b/,
    'boolean': /\b(_|iota|nil|true|false)\b/,
    'operator': /([(){}\[\]]|[*\/%^!]=?|\+[=+]?|-[>=-]?|\|[=|]?|>[=>]?|<(<|[=-])?|==?|&(&|=|^=?)?|\.(\.\.)?|[,;]|:=?)/,
    'number': /\b(-?(0x[a-f\d]+|(\d+\.?\d*|\.\d+)(e[-+]?\d+)?)i?)\b/i,
    'string': /("|'|`)(\\?.|\r|\n)*?\1/
});
delete Prism.languages.go['class-name'];
;
(function(Prism) {

    var handlebars_pattern = /\{\{\{[\w\W]+?\}\}\}|\{\{[\w\W]+?\}\}/g;

    Prism.languages.handlebars = Prism.languages.extend('markup', {
        'handlebars': {
            pattern: handlebars_pattern,
            inside: {
                'delimiter': {
                    pattern: /^\{\{\{?|\}\}\}?$/i,
                    alias: 'punctuation'
                },
                'string': /(["'])(\\?.)+?\1/,
                'number': /\b-?(0x[\dA-Fa-f]+|\d*\.?\d+([Ee]-?\d+)?)\b/,
                'boolean': /\b(true|false)\b/,
                'block': {
                    pattern: /^(\s*~?\s*)[#\/]\S+/i,
                    lookbehind: true,
                    alias: 'keyword'
                },
                'brackets': {
                    pattern: /\[[^\]]+\]/,
                    inside: {
                        punctuation: /\[|\]/,
                        variable: /[\w\W]+/
                    }
                },
                'punctuation': /[!"#%&'()*+,.\/;<=>@\[\\\]^`{|}~]/,
                'variable': /[^!"#%&'()*+,.\/;<=>@\[\\\]^`{|}~]+/
            }
        }
    });

    // Comments are inserted at top so that they can
    // surround markup
    Prism.languages.insertBefore('handlebars', 'tag', {
        'handlebars-comment': {
            pattern: /\{\{![\w\W]*?\}\}/,
            alias: ['handlebars','comment']
        }
    });

    // Tokenize all inline Handlebars expressions that are wrapped in {{ }} or {{{ }}}
    // This allows for easy Handlebars + markup highlighting
    Prism.hooks.add('before-highlight', function(env) {
        if (env.language !== 'handlebars') {
            return;
        }

        env.tokenStack = [];

        env.backupCode = env.code;
        env.code = env.code.replace(handlebars_pattern, function(match) {
            env.tokenStack.push(match);

            return '___HANDLEBARS' + env.tokenStack.length + '___';
        });
    });

    // Restore env.code for other plugins (e.g. line-numbers)
    Prism.hooks.add('before-insert', function(env) {
        if (env.language === 'handlebars') {
            env.code = env.backupCode;
            delete env.backupCode;
        }
    });

    // Re-insert the tokens after highlighting
    // and highlight them with defined grammar
    Prism.hooks.add('after-highlight', function(env) {
        if (env.language !== 'handlebars') {
            return;
        }

        for (var i = 0, t; t = env.tokenStack[i]; i++) {
            env.highlightedCode = env.highlightedCode.replace('___HANDLEBARS' + (i + 1) + '___', Prism.highlight(t, env.grammar, 'handlebars'));
        }

        env.element.innerHTML = env.highlightedCode;
    });

}(Prism));
;
Prism.languages.haskell= {
    'comment': {
        pattern: /(^|[^-!#$%*+=\?&@|~.:<>^\\])(--[^-!#$%*+=\?&@|~.:<>^\\].*(\r?\n|$)|{-[\w\W]*?-})/m,
        lookbehind: true
    },
    'char': /'([^\\"]|\\([abfnrtv\\"'&]|\^[A-Z@[\]\^_]|NUL|SOH|STX|ETX|EOT|ENQ|ACK|BEL|BS|HT|LF|VT|FF|CR|SO|SI|DLE|DC1|DC2|DC3|DC4|NAK|SYN|ETB|CAN|EM|SUB|ESC|FS|GS|RS|US|SP|DEL|\d+|o[0-7]+|x[0-9a-fA-F]+))'/,
    'string': /"([^\\"]|\\([abfnrtv\\"'&]|\^[A-Z@[\]\^_]|NUL|SOH|STX|ETX|EOT|ENQ|ACK|BEL|BS|HT|LF|VT|FF|CR|SO|SI|DLE|DC1|DC2|DC3|DC4|NAK|SYN|ETB|CAN|EM|SUB|ESC|FS|GS|RS|US|SP|DEL|\d+|o[0-7]+|x[0-9a-fA-F]+)|\\\s+\\)*"/,
    'keyword' : /\b(case|class|data|deriving|do|else|if|in|infixl|infixr|instance|let|module|newtype|of|primitive|then|type|where)\b/,
    'import_statement' : {
        // The imported or hidden names are not included in this import
        // statement. This is because we want to highlight those exactly like
        // we do for the names in the program.
        pattern: /(\n|^)\s*(import)\s+(qualified\s+)?(([A-Z][_a-zA-Z0-9']*)(\.[A-Z][_a-zA-Z0-9']*)*)(\s+(as)\s+(([A-Z][_a-zA-Z0-9']*)(\.[A-Z][_a-zA-Z0-9']*)*))?(\s+hiding\b)?/m,
        inside: {
            'keyword': /\b(import|qualified|as|hiding)\b/
        }
    },
    // These are builtin variables only. Constructors are highlighted later as a constant.
    'builtin': /\b(abs|acos|acosh|all|and|any|appendFile|approxRational|asTypeOf|asin|asinh|atan|atan2|atanh|basicIORun|break|catch|ceiling|chr|compare|concat|concatMap|const|cos|cosh|curry|cycle|decodeFloat|denominator|digitToInt|div|divMod|drop|dropWhile|either|elem|encodeFloat|enumFrom|enumFromThen|enumFromThenTo|enumFromTo|error|even|exp|exponent|fail|filter|flip|floatDigits|floatRadix|floatRange|floor|fmap|foldl|foldl1|foldr|foldr1|fromDouble|fromEnum|fromInt|fromInteger|fromIntegral|fromRational|fst|gcd|getChar|getContents|getLine|group|head|id|inRange|index|init|intToDigit|interact|ioError|isAlpha|isAlphaNum|isAscii|isControl|isDenormalized|isDigit|isHexDigit|isIEEE|isInfinite|isLower|isNaN|isNegativeZero|isOctDigit|isPrint|isSpace|isUpper|iterate|last|lcm|length|lex|lexDigits|lexLitChar|lines|log|logBase|lookup|map|mapM|mapM_|max|maxBound|maximum|maybe|min|minBound|minimum|mod|negate|not|notElem|null|numerator|odd|or|ord|otherwise|pack|pi|pred|primExitWith|print|product|properFraction|putChar|putStr|putStrLn|quot|quotRem|range|rangeSize|read|readDec|readFile|readFloat|readHex|readIO|readInt|readList|readLitChar|readLn|readOct|readParen|readSigned|reads|readsPrec|realToFrac|recip|rem|repeat|replicate|return|reverse|round|scaleFloat|scanl|scanl1|scanr|scanr1|seq|sequence|sequence_|show|showChar|showInt|showList|showLitChar|showParen|showSigned|showString|shows|showsPrec|significand|signum|sin|sinh|snd|sort|span|splitAt|sqrt|subtract|succ|sum|tail|take|takeWhile|tan|tanh|threadToIOResult|toEnum|toInt|toInteger|toLower|toRational|toUpper|truncate|uncurry|undefined|unlines|until|unwords|unzip|unzip3|userError|words|writeFile|zip|zip3|zipWith|zipWith3)\b/,
    // decimal integers and floating point numbers | octal integers | hexadecimal integers
    'number' : /\b(\d+(\.\d+)?([eE][+-]?\d+)?|0[Oo][0-7]+|0[Xx][0-9a-fA-F]+)\b/,
    // Most of this is needed because of the meaning of a single '.'.
    // If it stands alone freely, it is the function composition.
    // It may also be a separator between a module name and an identifier => no
    // operator. If it comes together with other special characters it is an
    // operator too.
    'operator' : /\s\.\s|([-!#$%*+=\?&@|~:<>^\\]*\.[-!#$%*+=\?&@|~:<>^\\]+)|([-!#$%*+=\?&@|~:<>^\\]+\.[-!#$%*+=\?&@|~:<>^\\]*)|[-!#$%*+=\?&@|~:<>^\\]+|(`([A-Z][_a-zA-Z0-9']*\.)*[_a-z][_a-zA-Z0-9']*`)/,
    // In Haskell, nearly everything is a variable, do not highlight these.
    'hvariable': /\b([A-Z][_a-zA-Z0-9']*\.)*[_a-z][_a-zA-Z0-9']*\b/,
    'constant': /\b([A-Z][_a-zA-Z0-9']*\.)*[A-Z][_a-zA-Z0-9']*\b/,
    'punctuation' : /[{}[\];(),.:]/
};
;
Prism.languages.java = Prism.languages.extend('clike', {
    'keyword': /\b(abstract|continue|for|new|switch|assert|default|goto|package|synchronized|boolean|do|if|private|this|break|double|implements|protected|throw|byte|else|import|public|throws|case|enum|instanceof|return|transient|catch|extends|int|short|try|char|final|interface|static|void|class|finally|long|strictfp|volatile|const|float|native|super|while)\b/,
    'number': /\b0b[01]+\b|\b0x[\da-f]*\.?[\da-fp\-]+\b|\b\d*\.?\d+[e]?[\d]*[df]\b|\b\d*\.?\d+\b/i,
    'operator': {
        pattern: /(^|[^\.])(?:\+=|\+\+?|-=|--?|!=?|<{1,2}=?|>{1,3}=?|==?|&=|&&?|\|=|\|\|?|\?|\*=?|\/=?|%=?|\^=?|:|~)/m,
        lookbehind: true
    }
});;
Prism.languages.latex = {
    'comment': /%.*?(\r?\n|$)$/m,
    'string': /(\$)(\\?.)*?\1/,
    'punctuation': /[{}]/,
    'selector': /\\[a-z;,:\.]*/i
};;
Prism.languages.makefile = {
    'comment': {
        pattern: /(^|[^\\])#(?:\\[\s\S]|.)*/,
        lookbehind: true
    },
    'string': /(["'])(?:\\[\s\S]|(?!\1)[^\\\r\n])*\1/,

    // Built-in target names
    'builtin': /\.[A-Z][^:#=\s]+(?=\s*:(?!=))/,

    // Targets
    'symbol': {
        pattern: /^[^:=\r\n]+(?=\s*:(?!=))/m,
        inside: {
            'variable': /\$+(?:[^(){}:#=\s]+|(?=[({]))/
        }
    },
    'variable': /\$+(?:[^(){}:#=\s]+|\([@*%<^+?][DF]\)|(?=[({]))/,

    'keyword': [
        // Directives
        /\b(?:define|else|endef|endif|export|ifn?def|ifn?eq|-?include|override|private|sinclude|undefine|unexport|vpath)\b/,
        // Functions
        {
            pattern: /(\()(?:addsuffix|abspath|and|basename|call|dir|error|eval|file|filter(?:-out)?|findstring|firstword|flavor|foreach|guile|if|info|join|lastword|load|notdir|or|origin|patsubst|realpath|shell|sort|strip|subst|suffix|value|warning|wildcard|word(?:s|list)?)(?=[ \t])/,
            lookbehind: true
        }
    ],
    'operator': /(?:::|[?:+!])?=|[|@]/,
    'punctuation': /[:;(){}]/
};;
Prism.languages.markdown = Prism.languages.extend('markup', {});
Prism.languages.insertBefore('markdown', 'prolog', {
    'blockquote': {
        // > ...
        pattern: /(^|\n)>(?:[\t ]*>)*/,
        lookbehind: true,
        alias: 'punctuation'
    },
    'code': [
        {
            // Prefixed by 4 spaces or 1 tab
            pattern: /(^|\n)(?: {4}|\t).+/,
            lookbehind: true,
            alias: 'keyword'
        },
        {
            // `code`
            // ``code``
            pattern: /``.+?``|`[^`\n]+`/,
            alias: 'keyword'
        }
    ],
    'title': [
        {
            // title 1
            // =======

            // title 2
            // -------
            pattern: /\w+.*\n(?:==+|--+)/,
            alias: 'important',
            inside: {
                punctuation: /==+$|--+$/
            }
        },
        {
            // # title 1
            // ###### title 6
            pattern: /((?:^|\n)\s*)#+.+/,
            lookbehind: true,
            alias: 'important',
            inside: {
                punctuation: /^#+|#+$/
            }
        }
    ],
    'hr': {
        // ***
        // ---
        // * * *
        // -----------
        pattern: /((?:^|\n)\s*)([*-])([\t ]*\2){2,}(?=\s*(?:\n|$))/,
        lookbehind: true,
        alias: 'punctuation'
    },
    'list': {
        // * item
        // + item
        // - item
        // 1. item
        pattern: /((?:^|\n)\s*)(?:[*+-]|\d+\.)(?=[\t ].)/,
        lookbehind: true,
        alias: 'punctuation'
    },
    'url-reference': {
        // [id]: http://example.com "Optional title"
        // [id]: http://example.com 'Optional title'
        // [id]: http://example.com (Optional title)
        // [id]: <http://example.com> "Optional title"
        pattern: /!?\[[^\]]+\]:[\t ]+(?:\S+|<(?:[^>]|\\>)+>)(?:[\t ]+(?:"(?:[^"]|\\")*"|'(?:[^']|\\')*'|\((?:[^)]|\\\))*\)))?/,
        inside: {
            'variable': {
                pattern: /^(!?\[)[^\]]+/,
                lookbehind: true
            },
            'string': /(?:"(?:[^"]|\\")*"|'(?:[^']|\\')*'|\((?:[^)]|\\\))*\))$/,
            'punctuation': /[[\]\(\)<>:]/
        },
        alias: 'url'
    },
    'bold': {
        // **strong**
        // __strong__

        // Allow only one line break
        pattern: /(^|[^\\])(\*\*|__)(?:\n(?!\n)|.)+?\2/,
        lookbehind: true,
        inside: {
            'punctuation': /^\*\*|^__|\*\*\s*$|__\s*$/
        }
    },
    'italic': {
        // *em*
        // _em_

        // Allow only one line break
        pattern: /(^|[^\\])(?:\*(?:\n(?!\n)|.)+?\*|_(?:\n(?!\n)|.)+?_)/,
        lookbehind: true,
        inside: {
            'punctuation': /^[*_]|[*_]$/
        }
    },
    'url': {
        // [example](http://example.com "Optional title")
        // [example] [id]
        pattern: /!?\[[^\]]+\](?:\([^\s)]+(?:[\t ]+"(?:[^"]|\\")*")?\)| ?\[[^\]\n]*\])/,
        inside: {
            'variable': {
                pattern: /(!?\[)[^\]]+(?=\]$)/,
                lookbehind: true
            },
            'string': {
                pattern: /"(?:[^"]|\\")*"(?=\)$)/
            }
        }
    }
});

Prism.languages.markdown['bold'].inside['url'] = Prism.util.clone(Prism.languages.markdown['url']);
Prism.languages.markdown['italic'].inside['url'] = Prism.util.clone(Prism.languages.markdown['url']);
Prism.languages.markdown['bold'].inside['italic'] = Prism.util.clone(Prism.languages.markdown['italic']);
Prism.languages.markdown['italic'].inside['bold'] = Prism.util.clone(Prism.languages.markdown['bold']);;
Prism.languages.python= {
    'comment': {
        pattern: /(^|[^\\])#.*?(\r?\n|$)/,
        lookbehind: true
    },
    'string': /"""[\s\S]+?"""|'''[\s\S]+?'''|("|')(\\?.)*?\1/,
    'function' : {
        pattern: /((^|\s)def[ \t]+)([a-zA-Z_][a-zA-Z0-9_]*(?=\())/g,
        lookbehind: true
    },
    'keyword' : /\b(as|assert|break|class|continue|def|del|elif|else|except|exec|finally|for|from|global|if|import|in|is|lambda|pass|print|raise|return|try|while|with|yield)\b/,
    'boolean' : /\b(True|False)\b/,
    'number' : /\b-?(0[bo])?(?:(\d|0x[a-f])[\da-f]*\.?\d*|\.\d+)(?:e[+-]?\d+)?j?\b/i,
    'operator' : /[-+]|<=?|>=?|!|={1,2}|&{1,2}|\|?\||\?|\*|\/|~|\^|%|\b(or|and|not)\b/,
    'punctuation' : /[{}[\];(),.:]/
};;
Prism.languages.r = {
    'comment': /#.+/,
    'string': /(['"])(?:\\?.)*?\1/,
    'percent-operator': {
        // Includes user-defined operators
        // and %%, %*%, %/%, %in%, %o%, %x%
        pattern: /%[^%]*?%/,
        alias: 'operator'
    },
    'boolean': /\b(?:TRUE|FALSE)\b/,
    'ellipsis': /\.\.(?:\.|\d+)/,
    'number': [
        /\b(?:NaN|Inf)\b/,
        /\b(?:0x[\dA-Fa-f]+(?:\.\d*)?|\d*\.?\d+)(?:[EePp][+-]??\d+)?[iL]?\b/
    ],
    'keyword': /\b(?:if|else|repeat|while|function|for|in|next|break|NULL|NA|NA_integer_|NA_real_|NA_complex_|NA_character_)\b/,
    'operator': /->>?|<?<-|[<>!=]=?|::?|&&?|\|\|?|[+\-*\/^$@~]/,
    'punctuation': /[(){}\[\],;]/
};;
(function(Prism) {

    var javascript = Prism.util.clone(Prism.languages.javascript);

    Prism.languages.jsx = Prism.languages.extend('markup', javascript);
    Prism.languages.jsx.tag.pattern= /<\/?[\w:-]+\s*(?:\s+[\w:-]+(?:=(?:("|')(\\?[\w\W])*?\1|[^\s'">=]+|(\{[\w\W]*?\})))?\s*)*\/?>/i;

    Prism.languages.jsx.tag.inside['attr-value'].pattern = /=[^\{](?:('|")[\w\W]*?(\1)|[^\s>]+)/i;

    Prism.languages.insertBefore('inside', 'attr-value',{
        'script': {
            pattern: /=(\{[\w\W]*?\})/i,
            inside: {
                'function' : Prism.languages.javascript.function,
                'punctuation': /[={}[\];(),.:]/,
                'keyword':  Prism.languages.javascript.keyword
            },
            'alias': 'language-javascript'
        }
    }, Prism.languages.jsx.tag);

}(Prism));
;
Prism.languages.scss = Prism.languages.extend('css', {
    'comment': {
        pattern: /(^|[^\\])(\/\*[\w\W]*?\*\/|\/\/.*?(\r?\n|$))/,
        lookbehind: true
    },
    'atrule': {
        pattern: /@[\w-]+(?:\([^()]+\)|[^(])*?(?=\s+(\{|;))/i,
        inside: {
            'rule': /@[\w-]+/
            // See rest below
        }
    },
    // url, compassified
    'url': /([-a-z]+-)*url(?=\()/i,
    // CSS selector regex is not appropriate for Sass
    // since there can be lot more things (var, @ directive, nesting..)
    // a selector must start at the end of a property or after a brace (end of other rules or nesting)
    // it can contain some caracters that aren't used for defining rules or end of selector, & (parent selector), or interpolated variable
    // the end of a selector is found when there is no rules in it ( {} or {\s}) or if there is a property (because an interpolated var
    // can "pass" as a selector- e.g: proper#{$erty})
    // this one was ard to do, so please be careful if you edit this one :)
    'selector': {
        pattern: /([^@;\{\}\(\)]?([^@;\{\}\(\)]|&|#\{\$[-_\w]+\})+)(?=\s*\{(\}|\s|[^\}]+(:|\{)[^\}]+))/m,
        inside: {
            'placeholder': /%[-_\w]+/i
        }
    }
});

Prism.languages.insertBefore('scss', 'atrule', {
    'keyword': /@(if|else if|else|for|each|while|import|extend|debug|warn|mixin|include|function|return|content)|(?=@for\s+\$[-_\w]+\s)+from/i
});

Prism.languages.insertBefore('scss', 'property', {
    // var and interpolated vars
    'variable': /((\$[-_\w]+)|(#\{\$[-_\w]+\}))/i
});

Prism.languages.insertBefore('scss', 'function', {
    'placeholder': {
        pattern: /%[-_\w]+/i,
        alias: 'selector'
    },
    'statement': /\B!(default|optional)\b/i,
    'boolean': /\b(true|false)\b/,
    'null': /\b(null)\b/,
    'operator': /\s+([-+]{1,2}|={1,2}|!=|\|?\||\?|\*|\/|%)\s+/
});

Prism.languages.scss['atrule'].inside.rest = Prism.util.clone(Prism.languages.scss);;
Prism.languages.scala = Prism.languages.extend('java', {
    'keyword': /(<-|=>)|\b(abstract|case|catch|class|def|do|else|extends|final|finally|for|forSome|if|implicit|import|lazy|match|new|null|object|override|package|private|protected|return|sealed|self|super|this|throw|trait|try|type|val|var|while|with|yield)\b/,
    'builtin': /\b(String|Int|Long|Short|Byte|Boolean|Double|Float|Char|Any|AnyRef|AnyVal|Unit|Nothing)\b/,
    'number': /\b0x[\da-f]*\.?[\da-f\-]+\b|\b\d*\.?\d+[e]?[\d]*[dfl]?\b/i,
    'symbol': /'([^\d\s]\w*)/,
    'string': /(""")[\W\w]*?\1|("|\/)[\W\w]*?\2|('.')/
});
delete Prism.languages.scala['class-name'];
delete Prism.languages.scala['function'];
;
Prism.languages.scheme = {
    'boolean' : /#(t|f){1}/,
    'comment' : /;.*/,
    'keyword' : {
        pattern : /([(])(define(-syntax|-library|-values)?|(case-)?lambda|let(-values|(rec)?(\*)?)?|else|if|cond|begin|delay|delay-force|parameterize|guard|set!|(quasi-)?quote|syntax-rules)/,
        lookbehind : true
    },
    'builtin' : {
        pattern :  /([(])(cons|car|cdr|null\?|pair\?|boolean\?|eof-object\?|char\?|procedure\?|number\?|port\?|string\?|vector\?|symbol\?|bytevector\?|list|call-with-current-continuation|call\/cc|append|abs|apply|eval)\b/,
        lookbehind : true
    },
    'string' :  /(["])(?:(?=(\\?))\2.)*?\1|'[^('|\s)]+/, //thanks http://stackoverflow.com/questions/171480/regex-grabbing-values-between-quotation-marks
    'number' : /(\s|\))[-+]?[0-9]*\.?[0-9]+((\s*)[-+]{1}(\s*)[0-9]*\.?[0-9]+i)?/,
    'operator': /(\*|\+|\-|%|\/|<=|=>|>=|<|=|>)/,
    'function' : {
        pattern : /([(])[^(\s|\))]*\s/,
        lookbehind : true
    },
    'punctuation' : /[()]/
};




;
