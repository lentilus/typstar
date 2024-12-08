local M = {}
local ts = vim.treesitter

function M.get_cursor_pos()
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
    cursor_row = cursor_row - 1
    return { cursor_row, cursor_col }
end

function M.insert_snippet(snip)
    local line_num = M.get_cursor_pos()[1] + 1
    local lines = {}
    for line in snip:gmatch '[^\r\n]+' do
        table.insert(lines, line)
    end
    vim.api.nvim_buf_set_lines(0, line_num, line_num, false, lines)
end

function M.run_shell_command(cmd)
    vim.fn.jobstart(cmd)
end

function M.cursor_within_treesitter_query(query, match_tolerance, cursor)
    cursor = cursor or M.get_cursor_pos()
    local bufnr = vim.api.nvim_get_current_buf()
    local root = ts.get_parser(bufnr):parse()[1]:root()
    for _, match, _ in query:iter_matches(root, bufnr, cursor[1], cursor[1] + 1) do
        if match then
            local start_row, start_col, _, _ = match[1]:range()
            local _, _, end_row, end_col     = match[#match]:range()
            local matched                    = M.cursor_within_coords(cursor, start_row, end_row, start_col, end_col,
                match_tolerance)
            if matched then
                return true
            end
        end
    end
    return false
end

function M.cursor_within_coords(cursor, start_row, end_row, start_col, end_col, match_tolerance)
    if start_row <= cursor[1] and end_row >= cursor[1] then
        if start_row == cursor[1] and start_col - match_tolerance >= cursor[2] then
            return false
        elseif end_row == cursor[1] and end_col + match_tolerance <= cursor[2] then
            return false
        end
        return true
    end
    return false
end

return M
