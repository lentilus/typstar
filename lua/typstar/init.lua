local M = {}

local config = require('typstar.config')

M.setup = function(args)
    config.merge_config(args)
    local excalidraw = require('typstar.excalidraw')
    vim.api.nvim_create_user_command('TypstarInsertExcalidraw', excalidraw.insert_drawing, {})
    vim.api.nvim_create_user_command('TypstarOpenExcalidraw', excalidraw.open_drawing, {})
end

return M
