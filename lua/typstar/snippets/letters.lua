local ls = require('luasnip')
local d = ls.dynamic_node
local s = ls.snippet_node
local t = ls.text_node
local helper = require('typstar.autosnippets')
local snip = helper.snip
local cap = helper.cap
local math = helper.in_math
local markup = helper.in_markup


local letter_snippets = {}
local greek_letters_map = {
    ['a'] = 'alpha',
    ['b'] = 'beta',
    ['c'] = 'chi',
    ['d'] = 'delta',
    ['e'] = 'epsilon',
    ['g'] = 'gamma',
    ['h'] = 'phi',
    ['i'] = 'iotta',
    ['j'] = 'theta',
    ['k'] = 'kappa',
    ['l'] = 'lambda',
    ['m'] = 'mu',
    ['n'] = 'nu',
    ['o'] = 'omega',
    ['p'] = 'pi',
    ['q'] = 'eta',
    ['r'] = 'rho',
    ['s'] = 'sigma',
    ['t'] = 'tau',
    ['x'] = 'xi',
    ['z'] = 'zeta',
}
local greek_letters = {}
local greek_keys = {}
local common_indices = { '\\d+', '[i-n]' }
local index_conflicts = { 'in', 'ln', 'pi', 'xi' }
local index_conflicts_set = {}
local trigger_greek = ''
local trigger_index_pre = ''
local trigger_index_post = ''

local upper_first = function(str)
    return str:sub(1, 1):upper() .. str:sub(2, -1)
end

local greek_full = {}
for latin, greek in pairs(greek_letters_map) do
    greek_full[latin] = greek
    greek_full[latin:upper()] = upper_first(greek)
    table.insert(greek_letters, greek)
    table.insert(greek_letters, upper_first(greek))
    table.insert(greek_keys, latin)
    table.insert(greek_keys, latin:upper())
end

for _, conflict in ipairs(index_conflicts) do
    index_conflicts_set[conflict] = true
end

greek_letters_map = greek_full
trigger_greek = table.concat(greek_keys, '|')
trigger_index_pre = '[A-Za-z]' .. '|' .. table.concat(greek_letters, '|')
trigger_index_post = table.concat(common_indices, '|')

local get_greek = function(_, snippet)
    return s(nil, t(greek_letters_map[snippet.captures[1]]))
end

local get_index = function(_, snippet)
    local letter, index = snippet.captures[1], snippet.captures[2]
    local trigger = letter .. index
    if index_conflicts_set[trigger] then
        return s(nil, t(trigger))
    end
    return s(nil, t(letter .. '_' .. index))
end

table.insert(letter_snippets, snip(':([A-Za-z0-9])', '$<>$ ', { cap(1) }, markup))
table.insert(letter_snippets, snip(';(' .. trigger_greek .. ')', '$<>$ ', { d(1, get_greek) }, markup))
table.insert(letter_snippets, snip(';(' .. trigger_greek .. ')', '<>', { d(1, get_greek) }, math))
table.insert(letter_snippets,
    snip('\\$(' .. trigger_index_pre .. ')\\$' .. '(' .. trigger_index_post .. ') ',
        '$<>$ ', { d(1, get_index) }, markup, 500))
table.insert(letter_snippets,
    snip('(' .. trigger_index_pre .. ')' .. '(' .. trigger_index_post .. ') ', '<> ', { d(1, get_index) }, math, 200))

return {
    unpack(letter_snippets)
}
