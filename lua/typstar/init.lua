local M = {}

local config = require('typstar.config')

M.setup = function(args)
    config.merge_config(args)
    local autosnippets = require('typstar.autosnippets')
    local excalidraw = require('typstar.excalidraw')
    local anki = require('typstar.anki')

    vim.api.nvim_create_user_command('TypstarToggleSnippets', autosnippets.toggle_autosnippets, {})

    vim.api.nvim_create_user_command('TypstarInsertExcalidraw', excalidraw.insert_drawing, {})
    vim.api.nvim_create_user_command('TypstarOpenExcalidraw', excalidraw.open_drawing, {})

    vim.api.nvim_create_user_command('TypstarAnkiScan', anki.scan, {})
    vim.api.nvim_create_user_command('TypstarAnkiReimport', anki.scan_reimport, {})
    vim.api.nvim_create_user_command('TypstarAnkiForce', anki.scan_force, {})
    vim.api.nvim_create_user_command('TypstarAnkiForceReimport', anki.scan_force_reimport, {})
    vim.api.nvim_create_user_command('TypstarAnkiForceCurrent', anki.scan_force_current, {})
    vim.api.nvim_create_user_command('TypstarAnkiForceCurrentReimport', anki.scan_force_current_reimport, {})

    autosnippets.setup()
end

return M
