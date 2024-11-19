local helper = require('typstar.autosnippets')
local snip = helper.snip

local letters = {
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

local letter_snippets = {}

for _, val in pairs(letters) do
    table.insert(letter_snippets, snip(';' .. val[1], val[2], {}, helper.in_math))
    table.insert(letter_snippets, snip(';' .. val[1], '$' .. val[2] .. '$ ', {}, helper.in_markup))
    table.insert(letter_snippets, snip(':' .. val[1], '$' .. val[1] .. '$ ', {}, helper.in_markup))
end

return {
    unpack(letter_snippets)
}
