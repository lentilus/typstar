local M = {}

local default_config = {
    typstarRoot = nil,
    anki = {
        typstarAnkiCmd = 'typstar-anki',
        typstCmd = 'typst',
        ankiUrl = 'http://127.0.0.1:8765',
        ankiKey = nil,
    },
    excalidraw = {
        assetsDir = 'assets',
        filename = 'drawing-%Y-%m-%d-%H-%M-%S',
        fileExtension = '.excalidraw.md',
        fileExtensionInserted = '.excalidraw.svg',
        uriOpenCommand = 'xdg-open', -- set depending on OS
        templatePath = nil,
    },
    snippets = {
        enable = true,
        modules = { -- enable modules from ./snippets
            'letters',
            'math',
            'matrix',
            'markup',
            'visual',
        },
        exclude = {}, -- list of triggers to exclude
    },
}

function M.merge_config(args)
    M.config = vim.tbl_deep_extend('force', default_config, args or {})
    M.config.typstarRoot = M.config.typstarRoot
        or debug.getinfo(1).source:match('^@(.*)/lua/typstar/config%.lua$')
        or '~/typstar'
    M.config.excalidraw.templatePath = M.config.excalidraw.templatePath
        or {
            ['%.excalidraw%.md$'] = M.config.typstarRoot .. '/res/excalidraw_template.excalidraw.md',
        }
end

M.merge_config(nil)

return M
