local ls = require('luasnip')
local i = ls.insert_node
local d = ls.dynamic_node

local helper = require('typstar.autosnippets')
local snip = helper.snip
local start = helper.start_snip
local markup = helper.in_markup


local ctheorems = {
    { 'tem', 'theorem',    markup },
    { 'pro', 'proof',      markup },
    { 'axi', 'axiom',      markup },
    { 'cor', 'corollary',  markup },
    { 'lem', 'lemma',      markup },
    { 'def', 'definition', markup },
    { 'exa', 'example',    markup },
    { 'rem', 'remark',     markup },
}

local ctheoremsstr = '#%s[\n\t<>\n]'
local document_snippets = {}

for _, val in pairs(ctheorems) do
    local snippet = start(val[1], string.format(ctheoremsstr, val[2]), { i(1) }, val[3])
    table.insert(document_snippets, snippet)
end

return {
    start('dm', '$\n\t<>\n$', { i(1) }, markup),
    snip('ll', ' $<>$', { i(1, '1+1') }, markup),
    start('fla', '#flashcard(0)[<>][\n\t<>\n]', { i(1, "flashcard"), i(2) }, markup),
    start('flA', '#flashcard(0, "<>")[\n\t<>\n]', { i(1, "flashcard"), i(2) }, markup),
    unpack(document_snippets),
}
