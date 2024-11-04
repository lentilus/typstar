local M = {}
local config = require('typstar.config')
local utils = require('typstar.utils')


local cfg = config.config.excalidraw
local affix = [[
#figure(
    image("%s"),
)
]]

local function launch_obsidian_open(path)
    print(string.format('Opening %s in Excalidraw', path))
    utils.run_shell_command('python3 ' ..
        config.config.typstarRoot .. '/python/obsidian_open.py ' ..
        path .. ' --config ' .. cfg.obsidianOpenConfig)
end


function M.insert_drawing()
    local assets_dir = vim.fn.expand('%:p:h') .. '/' .. cfg.assetsDir
    if vim.fn.isdirectory(assets_dir) == 0 then
        vim.fn.mkdir(assets_dir, 'p')
    end
    local filename = os.date(cfg.filename)
    local path = assets_dir .. '/' .. filename .. '.excalidraw.md'
    local path_inserted = cfg.assetsDir .. '/' .. filename .. cfg.fileExtensionInserted
    utils.insert_snippet(string.format(affix, path_inserted))
    launch_obsidian_open(path)
end

function M.open_drawing()
    local line = vim.api.nvim_get_current_line()
    local path = vim.fn.expand('%:p:h') ..
        '/' .. string.match(line, '"(.*)' .. string.gsub(cfg.fileExtensionInserted, '%.', '%%%.')) ..
        '.excalidraw.md'
    launch_obsidian_open(path)
end

return M
