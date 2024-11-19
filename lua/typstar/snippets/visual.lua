local ls = require('luasnip')
local i = ls.insert_node
local d = ls.dynamic_node

local helper = require('typstar.autosnippets')
local math = helper.in_math
local snip = helper.snip
local cap = helper.cap
local get_visual = helper.get_visual

local snippets = {}
local operations = {
    { 'vi',  '1/(',        ')' },
    { 'rb',  '(',          ')' },
    { 'sq',  '[',          ']' },
    { 'abs', '|',          '|' },
    { 'ul',  'underline(', ')' },
    { 'ol',  'overline(',  ')' },
    { 'ht',  'hat(',       ')' },
    { 'br',  'macron(',    ')' },
    { 'dt',  'dot(',       ')' },
    { 'ci',  'circle(',    ')' },
    { 'td',  'tilde(',     ')' },
    { 'nr',  'norm(',      ')' },
    { 'vv',  'vec(',       ')' },
    { 'rt',  'sqrt(',      ')' },
}

for _, val in pairs(operations) do
    table.insert(snippets, snip(val[1], val[2] .. '<>' .. val[3], { d(1, get_visual) }, math, 1200))
    table.insert(snippets,
        snip('(%s)([^%s]*)' .. val[1], '<>' .. val[2] .. '<>' .. val[3], { cap(1), cap(2) }, math, 1100))
    table.insert(snippets, snip('%s' .. val[1], val[2] .. '<>' .. val[3], { i(1, '1') }, math))
end

return {
    unpack(snippets)
}
