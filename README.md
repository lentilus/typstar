# Typstar
Neovim plugin for efficient note taking in Typst

## Features
- Powerful autosnippets using [LuaSnip](https://github.com/L3MON4D3/LuaSnip/) and [Tree-sitter](https://tree-sitter.github.io/) (inspired by [fastex.nvim](https://github.com/lentilus/fastex.nvim))
- Easy insertion of drawings using [Obsidian Excalidraw](https://github.com/zsviczian/obsidian-excalidraw-plugin)
- Export of [Anki](https://apps.ankiweb.net/) flashcards \[No Neovim required\]

## Usage

### Snippets
Use `:TypstarToggleSnippets` to toggle all snippets at any time.
Available snippets can mostly be intuitively derived from [here](././lua/typstar/snippets), they include:

- Alphanumeric characters: `:<char>` &#8594; `$<char>$ ` in markup (e.g. `:X` &#8594; `$X$ `, `:5` &#8594; `$5$ `)
- Greek letters: `;<latin>` &#8594; `<greek>` in math and `$<greek>$ ` in markup (e.g. `;a` &#8594; `alpha`/`$alpha$ `)
- Common indices (numbers and letters `i-n`): `<letter><index>` &#8594; `<letter>_<index>` in math and `$<letter>$<index> ` &#8594; `$<letter>_<index>$ ` in markup (e.g `A314` &#8594; `A_314`, `$alpha$n ` &#8594; `$alpha_n$ `)
- Wrapping of any mathematical expression (see [operations](./lua/typstar/snippets/visual.lua), works nested, multiline and in visual mode via the [selection key](#installation)): `<expression><operation>` &#8594; `<operation>(<expression>)` (e.g. `(a^2+b^2)rt` &#8594; `sqrt(a^2+b^2)`, `lambdatd` &#8594; `tilde(lambda)`, `(1+1)sQ` &#8594; `[1+1]`, `(1+1)sq` &#8594; `[(1+1)]`)
- Matrices: `<size>ma` and `<size>lma` (e.g. `23ma` &#8594; 2x3 matrix)
- [ctheorems shorthands](./lua/typstar/snippets/document.lua) (e.g. `tem` &#8594; empty theorem, `exa` &#8594; empty example)
- [Many shorthands](./lua/typstar/snippets/math.lua) for mathematical expressions

Note that you can enable and disable collections of snippets in the [config](#configuration).

### Excalidraw
- Use `:TypstarInsertExcalidraw` to create a new drawing using the configured template, insert a figure displaying it and open it in Obsidian.
- To open an inserted drawing in Obsidian, simply run `:TypstarOpenExcalidraw` while your cursor is on a line referencing the drawing.

### Anki
Use the `flA` snippet to create a new flashcard
```typst
#flashcard(0, "My first flashcard")[
  Typst is awesome $a^2+b^2=c^2$
]
```
or the `fla` snippet to add a more complex front
```typst
#flashcard(0)[I love Typst $pi$][
  This is the back of my second flashcard
]
```

To render the flashcard in your document as well add some code like this
```typst
#let flashcard(id, front, back) = {
  strong(front)
  [\ ]
  back
}
```

- Add a comment like `// ANKI: MY::DECK` to your document to set a deck used for all flashcards after this comment (You can use multiple decks per file)
- Add a file named `.anki.typ` to define a preamble on a directory base. You can find the default preamble [here](./src/anki/typst_compiler.py).
- Tip: Despite the use of SVGs you can still search your flashcards in Anki as the typst source is added into an invisible html paragraph

#### Neovim
- Use `:TypstarAnkiScan` to scan the current nvim working directory and compile all flashcards in its context, unchanged files will be ignored
- Use `:TypstarAnkiForce` to force compilation of all flashcards in the current working directory even if the files haven't changed since the last scan (e.g. on preamble change)
- Use `:TypstarAnkiForceCurrent` to force compilation of all flashcards in the file currently edited

#### Standalone
- Run `typstar-anki --help` to show the available options


## Installation
Install the plugin in Neovim and set the `typstarRoot` config or alternatively clone typstar into `~/typstar`.
```lua
require('typstar').setup({
  typstarRoot = '/path/to/typstar/repo' -- depending on your nvim plugin system
})
```

### Snippets
1. Install [LuaSnip](https://github.com/L3MON4D3/LuaSnip/), set `enable_autosnippets = true` and set a visual mode selection key (e.g. `store_selection_keys = '<Tab>'`) in the configuration
2. Install [jsregexp](https://github.com/kmarius/jsregexp) as described [here](https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#transformations) (running `:lua require('jsregexp')` in nvim should not result in an error)
3. Install [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) and run `:TSInstall typst`
4. Optional: Setup [ctheorems](https://typst.app/universe/package/ctheorems/) with names like [here](./lua/typstar/snippets/document.lua)

### Excalidraw
1. Install [Obsidian](https://obsidian.md/) and create a vault in your typst note taking directory
2. Install the [obsidian-excalidraw-plugin](https://github.com/zsviczian/obsidian-excalidraw-plugin) and enable `Auto-export SVG` (in plugin settings at `Embedding Excalidraw into your Notes and Exporting > Export Settings > Auto-export Settings`)
3. Have the `xdg-open` command working or set a different command at `uriOpenCommand` in the [config](#configuration)

### Anki
1. Install [Anki](https://apps.ankiweb.net/#download)
2. Install [Anki-Connect](https://ankiweb.net/shared/info/2055492159) and make sure `http://localhost` is added to `webCorsOriginList` in the Add-on config (should be added by default)
3. Install the typstar python package (I recommend using [pipx](https://github.com/pypa/pipx) via `pipx install git+https://github.com/arne314/typstar`) [Note: this may take a while]
4. Make sure the `typstar-anki` command is available in your `PATH` or modify the `typstarAnkiCmd` option in the [config](#configuration)

## Configuration
Configuration options can be intuitively derived from the table [here](./lua/typstar/config.lua).

