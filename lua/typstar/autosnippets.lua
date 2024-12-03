local M = {}
local cfg = require('typstar.config').config.snippets
local luasnip = require('luasnip')
local fmta = require('luasnip.extras.fmt').fmta

M.in_math = function() return vim.api.nvim_eval('typst#in_math()') == 1 end
M.in_markup = function() return vim.api.nvim_eval('typst#in_markup()') == 1 end
M.in_code = function() return vim.api.nvim_eval('typst#in_code()') == 1 end
M.in_comment = function() return vim.api.nvim_eval('typst#in_comment()') == 1 end
M.not_in_math = function() return not M.in_math() end
M.not_in_markup = function() return not M.in_markup() end
M.not_in_code = function() return not M.in_code() end
M.not_in_comment = function() return not M.in_comment() end
M.snippets_toggle = true

function M.cap(i)
    return luasnip.function_node(function(_, snip) return snip.captures[i] end)
end

function M.get_visual(args, parent)
    if (#parent.snippet.env.LS_SELECT_RAW > 0) then
        return luasnip.snippet_node(nil, luasnip.insert_node(1, parent.snippet.env.LS_SELECT_RAW))
    else -- If LS_SELECT_RAW is empty, return a blank insert node
        return luasnip.snippet_node(nil, luasnip.insert_node(1))
    end
end

function M.ri(insert_node_id)
    return luasnip.function_node(function(args) return args[1][1] end, insert_node_id)
end

function M.snip(trigger, expand, insert, condition, priority)
    priority = priority or 1000
    return luasnip.snippet(
        {
            trig = trigger,
            trigEngine = 'ecma',
            regTrig = true,
            wordtrig = false,
            priority = priority,
            snippetType = 'autosnippet'
        },
        fmta(expand, { unpack(insert) }),
        {
            condition = function()
                if not M.snippets_toggle then
                    return false
                end
                return condition()
            end
        }
    )
end

function M.start_snip(trigger, expand, insert, condition, priority)
    return M.snip('^\\s*' .. trigger, expand, insert, condition, priority)
end

function M.toggle_autosnippets()
    M.snippets_toggle = not M.snippets_toggle
end

function M.setup()
    if cfg.enable then
        local autosnippets = {}
        for _, file in ipairs(cfg.modules) do
            vim.list_extend(
                autosnippets,
                require(('typstar.snippets.%s'):format(file))
            )
        end
        luasnip.add_snippets('typst', autosnippets)
    end
end

return M
