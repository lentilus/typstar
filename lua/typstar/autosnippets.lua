local M = require('typstar.engine') -- inherit all functions
local luasnip = require('luasnip')

function M.cap(i)
    return luasnip.function_node(function(_, snip) return snip.captures[i] end)
end

local compute_leading_white_spaces = function(snip, i)
    local capture = snip.captures[i] or ''
    return capture:match('^%s*') or ''
end

function M.leading_white_spaces(i)
    return luasnip.function_node(function(_, snip) return compute_leading_white_spaces(snip, i) end)
end

function M.visual(idx, default, line_prefix, indent_capture_idx)
    default = default or ''
    line_prefix = line_prefix or ''
    return luasnip.dynamic_node(idx, function(_, snip)
        local select_raw = snip.snippet.env.LS_SELECT_RAW
        if #select_raw > 0 then
            if line_prefix ~= '' then -- e.g. indentation
                for i, s in ipairs(select_raw) do
                    select_raw[i] = line_prefix .. s
                end
            end
            return luasnip.snippet_node(nil, luasnip.text_node(select_raw))
        else -- If LS_SELECT_RAW is empty, return an insert node
            local leading = ''
            if indent_capture_idx ~= nil then leading = compute_leading_white_spaces(snip, indent_capture_idx) end
            return luasnip.snippet_node(nil, {
                luasnip.text_node(leading .. line_prefix),
                luasnip.insert_node(1, default),
            })
        end
    end)
end

function M.ri(insert_node_id)
    return luasnip.function_node(function(args) return args[1][1] end, insert_node_id)
end

function M.start_snip(trigger, expand, insert, condition, priority, options)
    return M.snip('^(\\s*)' .. trigger, '<>' .. expand, { M.cap(1), unpack(insert) }, condition, priority, options)
end

-- Allows to pass expand string and insert table to either indent each line
-- dynamically of the captured group indent, and or prepend to each line after the indent
-- For example prepend = '-- ' in lua.
-- indent: boolean to turn off indenting (option can't be set off right now)
-- prepend: prepend string
function M.blocktransform(expand, insert, prepend, indent)
    -- if idiomatic, skip
    if indent ~= nil and not indent and not prepend then return expand, insert end

    -- defaults / setup
    if indent == nil then indent = true end
    prepend = prepend or ''
    local last_newl_index = 0
    local modified_expand = expand
    function shallowClone(original)
        local copy = {}
        for key, value in pairs(original) do
            copy[key] = value
        end
        return copy
    end

    local modified_insert = shallowClone(insert)
    local newl_count = 0
    local offset = 0

    -- logic
    while true do
        -- break if no \n anymore
        local new_newl_index = string.find(expand, '\n', last_newl_index + 1)
        if not new_newl_index then break end
        newl_count = newl_count + 1

        -- insert the prepend and newl at the correct position
        local insert_pos = new_newl_index + offset + 1
        modified_expand = string.sub(modified_expand, 1, insert_pos - 1)
            .. (indent and '<>' or '')
            .. prepend
            .. string.sub(modified_expand, insert_pos)
        offset = offset + (indent and 2 or 0) + #prepend

        -- indent of course needs to be added as a dynamic function
        if indent then
            local substring = string.sub(modified_expand, 1, insert_pos + 1)
            local count = 0

            local _, occurrences = string.gsub(substring, '<>', '')
            count = occurrences
            table.insert(modified_insert, count, M.leading_white_spaces(1))
        end

        last_newl_index = new_newl_index
    end
    return modified_expand, modified_insert
end

function M.start_snip_in_newl(trigger, expand, insert, condition, priority, options)
    return M.snip(
        '([^\\s]\\s+)' .. trigger,
        '<>\n' .. expand,
        { M.cap(1), unpack(insert) },
        condition,
        priority,
        options
    )
end

function M.bulletpoint_snip(trigger, expand, insert, condition, priority, options)
    return M.snip(
        '(^\\s*\\-\\s+.*\\s*)' .. trigger,
        '<>' .. expand,
        { M.cap(1), unpack(insert) },
        condition,
        priority,
        options
    )
end
return M
