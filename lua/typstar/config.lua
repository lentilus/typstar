local M = {}

local default_config = {
    typstarRoot = '~/typstar',
    excalidraw = {
        assetsDir = 'assets',
        filename = 'drawing-%Y-%m-%d-%H-%M-%S',
        fileExtensionInserted = '.excalidraw.svg',
        obsidianOpenConfig = nil,
    }
}

function M.merge_config(args)
    M.config = vim.tbl_deep_extend('force', default_config, args or {})
    M.config.excalidraw.obsidianOpenConfig = M.config.excalidraw.obsidianOpenConfig or
        M.config.typstarRoot .. '/res/obsidian_open_config_example.json'
end

M.merge_config(nil)

return M
