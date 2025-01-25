local M = {}
local config = require('typstar.config')
local utils = require('typstar.utils')

local cfg = config.config.anki

local function run_typstar_anki(args)
    local cwd = vim.fn.getcwd()
    local anki_key = ''
    if cfg.ankiKey ~= nil then anki_key = ' --anki-key ' .. cfg.ankiKey end
    local cmd = string.format(
        '%s --root-dir %s --typst-cmd %s --anki-url %s %s %s',
        cfg.typstarAnkiCmd,
        cwd,
        cfg.typstCmd,
        cfg.ankiUrl,
        anki_key,
        args
    )
    utils.run_shell_command(cmd, true)
end

function M.scan() run_typstar_anki('') end

function M.scan_reimport() run_typstar_anki('--reimport') end

function M.scan_force() run_typstar_anki('--force-scan ' .. vim.fn.getcwd()) end

function M.scan_force_reimport() run_typstar_anki('--reimport --force-scan ' .. vim.fn.getcwd()) end

function M.scan_force_current() run_typstar_anki('--force-scan ' .. vim.fn.expand('%:p')) end

function M.scan_force_current_reimport() run_typstar_anki('--reimport --force-scan ' .. vim.fn.expand('%:p')) end

return M
