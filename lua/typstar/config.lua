local M = {}

local default_config = {
    typstarRoot = '~/typstar',
    excalidraw = {
        assetsDir = 'assets',
        filename = 'drawing-%Y-%m-%d-%H-%M-%S',
        fileExtension = '.excalidraw.md',
        fileExtensionInserted = '.excalidraw.svg',
        uriOpenCommand = 'xdg-open',
        templatePath = nil,
    },
    snippets = {
        enable = true,
        modules = {
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
