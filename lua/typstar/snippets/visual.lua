local ls = require('luasnip')
local i = ls.insert_node
local d = ls.dynamic_node
local f = ls.function_node

local helper = require('typstar.autosnippets')
local math = helper.in_math
local snip = helper.snip
local cap = helper.cap
local get_visual = helper.get_visual

local snippets = {}
local operations = { -- boolean denotes whether an additional layer of () brackets should be removed
    { 'vi',  '1/(',         ')', true },
    { 'bb',  '(',           ')', false },
    { 'sq',  '[',           ']', true },
    { 'abs', 'abs(',        ')', false },
    { 'ul',  'underline(',  ')', false },
    { 'ol',  'overline(',   ')', false },
    { 'ub',  'underbrace(', ')', false },
    { 'ob',  'overbrace(',  ')', false },
    { 'ht',  'hat(',        ')', false },
    { 'br',  'macron(',     ')', false },
    { 'dt',  'dot(',        ')', false },
    { 'ci',  'circle(',     ')', false },
    { 'td',  'tilde(',      ')', false },
    { 'nr',  'norm(',       ')', false },
    { 'vv',  'vec(',        ')', false },
    { 'rt',  'sqrt(',       ')', false },
}

local wrap_brackets = function(args, snippet, val)
    local captured = snippet.captures[1]
    local bracket_types = { [')'] = '(', [']'] = '[', ['}'] = '{' }
    local closing_bracket = captured:sub(-1, -1)
    local opening_bracket = bracket_types[closing_bracket]

    if opening_bracket == nil then
        return captured
    end

    local n_brackets = 0
    local char

    for i = #captured, 1, -1 do
        char = captured:sub(i, i)
        if char == closing_bracket then
            n_brackets = n_brackets + 1
        elseif char == opening_bracket then
            n_brackets = n_brackets - 1
        end

        if n_brackets == 0 then
            local remove_additional = val[4] and opening_bracket == '('
            return captured:sub(1, i - 1) .. val[2]
                .. captured:sub(i + (remove_additional and 1 or 0), -(remove_additional and 2 or 1)) .. val[3]
        end
    end
    return captured
end

for _, val in pairs(operations) do
    table.insert(snippets, snip(val[1], val[2] .. '<>' .. val[3], { d(1, get_visual) }, math))
    table.insert(snippets, snip('[\\s$]' .. val[1], val[2] .. '<>' .. val[3], { i(1, '1') }, math))
    table.insert(snippets,
        snip('([\\w]+)'
            .. val[1], val[2] .. '<>' .. val[3], { cap(1) }, math, 900))
    table.insert(snippets,
        snip('(.*[\\)|\\]|\\}])' .. val[1], '<>', { f(wrap_brackets, {}, { user_args = { val } }), nil }, math, 1100))
end

return {
    unpack(snippets)
}
