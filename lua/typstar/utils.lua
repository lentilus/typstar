local M = {}

function M.insert_snippet(snip)
    local line_num = vim.fn.getcurpos()[2]
    local lines = {}
    for line in snip:gmatch '[^\r\n]+' do
        table.insert(lines, line)
    end
    vim.api.nvim_buf_set_lines(0, line_num, line_num, false, lines)
end

function M.run_shell_command(cmd)
    vim.fn.jobstart(cmd)
end

return M
