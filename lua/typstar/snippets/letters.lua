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
    ['p'] = 'psi',
    ['q'] = 'eta',
    ['r'] = 'rho',
    ['s'] = 'sigma',
    ['t'] = 'tau',
    ['v'] = 'nu',
    ['w'] = 'omega',
    ['x'] = 'xi',
    ['y'] = 'upsilon',
    ['z'] = 'zeta',
}
local greek_keys = {}
local greek_letters_set = {}
local common_indices = { '\\d+', '[i-n]' }
local index_conflicts = { 'in', 'ln', 'pi', 'xi', 'el' }
local index_conflicts_set = {}
local trigger_greek = ''
local trigger_index_pre = ''
local trigger_index_post = ''

local upper_first = function(str) return str:sub(1, 1):upper() .. str:sub(2, -1) end

local greek_full = {}
for latin, greek in pairs(greek_letters_map) do
    greek_full[latin] = greek
    greek_full[latin:upper()] = upper_first(greek)
    if not greek_letters_set[greek] then
        table.insert(greek_letters_set, greek)
        table.insert(greek_letters_set, upper_first(greek))
    end
    table.insert(greek_keys, latin)
    table.insert(greek_keys, latin:upper())
end

for _, conflict in ipairs(index_conflicts) do
    index_conflicts_set[conflict] = true
end

greek_letters_map = greek_full
trigger_greek = table.concat(greek_keys, '|')
trigger_index_pre = '[A-Za-z]' .. '|' .. table.concat(greek_letters_set, '|')
trigger_index_post = table.concat(common_indices, '|')

local get_greek = function(_, snippet) return s(nil, t(greek_letters_map[snippet.captures[1]])) end

local get_index = function(_, snippet)
    local letter, index = snippet.captures[1], snippet.captures[2]
    local trigger = letter .. index
    if index_conflicts_set[trigger] then return s(nil, t(trigger)) end
    return s(nil, t(letter .. '_' .. index))
end

local get_series = function(_, snippet)
    local letter, target = snippet.captures[1], snippet.captures[2]
    local target_num = tonumber(target)
    local result
    if target_num then
        local res = {}
        for n = 1, target_num do
            table.insert(res, string.format('%s_%d', letter, n))
            if n ~= target_num then table.insert(res, ', ') end
        end
        result = table.concat(res, '')
    else
        result = string.format('%s_1, %s_2, ... %s_%s', letter, letter, letter, target)
    end
    return s(nil, t(result))
end

return {
    -- latin/greek
    snip(':([A-Za-z0-9])', '$<>$ ', { cap(1) }, markup),
    snip(';(' .. trigger_greek .. ')', '$<>$ ', { d(1, get_greek) }, markup),
    snip(';(' .. trigger_greek .. ')', '<>', { d(1, get_greek) }, math),

    -- indices
    snip(
        '\\$(' .. trigger_index_pre .. ')\\$' .. '(' .. trigger_index_post .. ') ',
        '$<>$ ',
        { d(1, get_index) },
        markup,
        500
    ),
    snip('(' .. trigger_index_pre .. ')' .. '(' .. trigger_index_post .. ') ', '<> ', { d(1, get_index) }, math, 200),

    -- series of numbered letters
    snip('(' .. trigger_index_pre .. ') ot ', '<>_1, <>_2, ... ', { cap(1), cap(1) }, math), -- a_1, a_2, ...
    snip('(' .. trigger_index_pre .. ') ot(\\w+) ', '<> ', { d(1, get_series) }, math), -- a_1, a_2, ... a_j or a_1, a_2, a_2, a_3, a_4, a_5
    unpack(letter_snippets),
}
