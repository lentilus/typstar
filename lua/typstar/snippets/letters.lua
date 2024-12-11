local helper = require('typstar.autosnippets')
local snip = helper.snip
local cap = helper.cap
local math = helper.in_math
local markup = helper.in_markup

local letter_snippets = {}
local greek_letters = {
    { 'a', 'alpha' }, { 'A', 'Alpha' },
    { 'b', 'beta' }, { 'B', 'Beta' },
    { 'c', 'chi' }, { 'C', 'Chi' },
    { 'd', 'delta' }, { 'D', 'Delta' },
    { 'e', 'epsilon' }, { 'E', 'Epsilon' },
    { 'g', 'gamma' }, { 'G', 'Gamma' },
    { 'h', 'phi' }, { 'H', 'Phi' },
    { 'i', 'iotta' }, { 'I', 'Iotta' },
    { 'j', 'theta' }, { 'J', 'Theta' },
    { 'k', 'kappa' }, { 'K', 'Kappa' },
    { 'l', 'lambda' }, { 'L', 'Lambda' },
    { 'm', 'mu' }, { 'M', 'Mu' },
    { 'n', 'nu' }, { 'N', 'Nu' },
    { 'o', 'omega' }, { 'O', 'Omega' },
    { 'p', 'pi' }, { 'P', 'Pi' },
    { 'q', 'eta' }, { 'Q', 'Eta' },
    { 'r', 'rho' }, { 'R', 'Rho' },
    { 's', 'sigma' }, { 'S', 'Sigma' },
    { 't', 'tau' }, { 'T', 'Tau' },
    { 'x', 'xi' }, { 'X', 'xi' },
    { 'z', 'zeta' }, { 'Z', 'Zeta' },
}
local latin_letters = { 'f', 'u', 'v', 'w', 'y' } -- remaining ones are added dynamically
local common_indices = { '\\d+', 'i', 'j', 'k', 'n' }

for _, letter in ipairs({ unpack(latin_letters) }) do
    table.insert(latin_letters, letter:upper())
end

local generate_index_snippets = function(letter)
    for _, index in pairs(common_indices) do
        table.insert(letter_snippets,
            snip(letter .. '(' .. index .. ') ', letter .. '_<> ', { cap(1) }, math, 200))
        table.insert(letter_snippets,
            snip('\\$' .. letter .. '\\$(' .. index .. ') ', '$' .. letter .. '_<>$ ', { cap(1) }, markup, 200))
    end
end

for _, val in pairs(greek_letters) do
    table.insert(letter_snippets, snip(';' .. val[1], val[2], {}, math))
    table.insert(letter_snippets, snip(';' .. val[1], '$' .. val[2] .. '$ ', {}, markup))
    generate_index_snippets(val[2])
    table.insert(latin_letters, val[1])
end

for _, letter in pairs(latin_letters) do
    generate_index_snippets(letter)
    table.insert(letter_snippets, snip(':' .. letter, '$' .. letter .. '$ ', {}, markup))
end

return {
    unpack(letter_snippets)
}
