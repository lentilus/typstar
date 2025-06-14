local ls = require('luasnip')
local i = ls.insert_node

local helper = require('typstar.autosnippets')
local snip = helper.snip
local math = helper.in_math
local cap = helper.cap

return {
    snip('fa', 'AA ', {}, math),
    snip('ex', 'EE ', {}, math),
    snip('ni', 'in.not ', {}, math),

    -- boolean logic
    snip('not', 'not ', {}, math),
    snip('ip', '==>> ', {}, math),
    snip('ib', '<<== ', {}, math),
    snip('iff', '<<==>> ', {}, math),

    -- relations
    snip('el', '= ', {}, math),
    snip('df', ':= ', {}, math),
    snip('lt', '<< ', {}, math),
    snip('gt', '>> ', {}, math),
    snip('le', '<<= ', {}, math),
    snip('ne', '!= ', {}, math),
    snip('ge', '>>= ', {}, math),

    snip('ff', '(<>) / (<>) <>', { i(1, 'a'), i(2, 'b'), i(3) }, math),

    -- exponents
    snip('iv', '^(-1) ', {}, math, 500, { wordTrig = false, blacklist = { 'equiv' } }),
    snip('sr', '^2 ', {}, math, 500, { wordTrig = false }),
    snip('cb', '^3 ', {}, math, 500, { wordTrig = false }),
    snip('jj', '_(<>) ', { i(1, 'n') }, math, 500, { wordTrig = false }),
    snip('kk', '^(<>) ', { i(1, 'n') }, math, 500, { wordTrig = false }),
    snip('ep', 'exp(<>) ', { i(1, '1') }, math),

    -- sets
    -- 'st' to '{<>} in ./visual.lua
    snip('set', '{<> | <>}', { i(1), i(2) }, math),
    snip('es', 'emptyset ', {}, math, 900),
    snip('sp', 'supset ', {}, math),
    snip('sb', 'subset ', {}, math),
    snip('sep', 'supset.eq ', {}, math),
    snip('seb', 'subset.eq ', {}, math),

    -- misc
    snip('to', '->> ', {}, math),
    snip('mt', '|->> ', {}, math),
    snip('cc', 'cases(\n\t<>\n)\\', { i(1, '1') }, math),
    snip('([A-Za-z])o([A-Za-z0-9])', '<>(<>) ', { cap(1), cap(2) }, math, 100, {
        maxTrigLength = 3,
        blacklist = { 'bot', 'cos', 'col', 'com', 'con', 'dol', 'dot', 'log', 'loz', 'mod', 'top', 'won', 'xor' },
    }),
    snip('(K|M|N|Q|R|S|Z)([\\dn]) ', '<><>^<> ', { cap(1), cap(1), cap(2) }, math),

    snip('dx', 'dif / (dif <>) ', { i(1, 'x') }, math, 900),
    snip('ddx', '(dif <>) / (dif <>) ', { i(1, 'f'), i(2, 'x') }, math),
    snip('DX', 'partial / (partial <>) ', { i(1, 'x') }, math, 900),
    snip('DDX', '(partial <>) / (partial <>) ', { i(1, 'f'), i(2, 'x') }, math),
    snip('part', 'partial ', {}, math, 1600),
    snip('it', 'integral ', {}, math, 900),
    snip('int', 'integral_(<>)^(<>) ', { i(1, 'a'), i(2, 'b') }, math),
    snip('oit', 'integral_Omega ', {}, math),
    snip('dit', 'integral_(<>) ', { i(1, 'Omega') }, math),

    snip('sm', 'sum ', {}, math, 900),
    snip('sum', 'sum_(<>)^(<>) ', { i(1, 'i=0'), i(2, 'oo') }, math),
    snip('osm', 'sum_Omega ', {}, math),
    snip('dsm', 'sum_(<>) ', { i(1, 'I') }, math),

    snip('lm', 'lim ', {}, math),
    snip('lim', 'lim_(<> ->> <>) ', { i(1, 'n'), i(2, 'oo') }, math),
    snip('lim (sup|inf)', 'lim<> ', { cap(1) }, math),
    snip(
        'lim(_\\(\\s?\\w+\\s?->\\s?\\w+\\s?\\)) (sup|inf)',
        'lim<><> ',
        { cap(2), cap(1) },
        math,
        1000,
        { maxTrigLength = 25 }
    ),

    -- semicolon as auto-brackets
    snip(';(.*?);', '(<>)', {cap(1)}, math, 500, { wordTrig = false }),
}
