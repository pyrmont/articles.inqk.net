# Grammars

TextMate grammars for highlighting code blocks. `_ecstatic.wattle` loads
every `.json` file here and maps a code block's language to a scope name.

| File               | Scope              | Source |
| ------------------ | ------------------ | ------ |
| `clojure.json`     | `source.clojure`   | VS Code `extensions/clojure` (from atom/language-clojure, MIT) |
| `commonlisp.json`  | `source.commonlisp`| qingpeng9802/vscode-common-lisp `syntaxes/commonlisp.tmLanguage.json` at ad508f15ae8d (MIT) |
| `conf.json`        | `source.conf`      | Written for this site |
| `css.json`         | `source.css`       | VS Code `extensions/css` (from microsoft/vscode-css, MIT); included by HTML |
| `html.json`        | `text.html.basic`  | VS Code `extensions/html` (from textmate/html.tmbundle, TextMate Bundle License) |
| `janet.json`       | `source.janet`     | janet-lang/vscode-janet `syntaxes/janet.tmLanguage` at 0225a87fb8c7 (MIT), converted from a property list to JSON |
| `javascript.json`  | `source.js`        | VS Code `extensions/javascript` (from microsoft/TypeScript-TmLanguage, MIT) |
| `ruby.json`        | `source.ruby`      | VS Code `extensions/ruby` (from Shopify/ruby-lsp, MIT) |
| `shell.json`       | `source.shell`     | VS Code `extensions/shellscript` (from jeff-hykin/better-shell-syntax, MIT) |
| `yaml.json`        | `source.yaml`      | VS Code `extensions/yaml` (from RedCMD/YAML-Syntax-Highlighter, MIT) |
| `yaml-1.2.json`    | `source.yaml.1.2`  | As `yaml.json`; `yaml.json` includes it |

The VS Code files are from microsoft/vscode at 4347d45a5a71 (14 November
2026). Each file's `version` field names the upstream commit it was
converted from. The licences of the repositories the files were taken from
are in `licences/`.

`console` blocks are not highlighted by a grammar: the theme highlights each
line that begins with a prompt (`$`, `#`, `%` or `>`) with the shell grammar
and treats any other line as output.
