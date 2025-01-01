local M = {}

local default_config = {
    typstarRoot = '~/typstar',
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
            'document',
            'letters',
            'math',
            'matrix',
            'visual',
        }
    },
}

function M.merge_config(args)
    M.config = vim.tbl_deep_extend('force', default_config, args or {})
    M.config.excalidraw.templatePath = M.config.excalidraw.templatePath or
        {
            ['%.excalidraw%.md$'] = M.config.typstarRoot .. '/res/excalidraw_template.excalidraw.md',
        }
end

M.merge_config(nil)

return M
