local Giggles = Giggles

local CLINS = { "giggles", "gigglesscrapper", "gigglespure"}
rawset(_G, "IsGiggles", function(g, p)
    if p then -- For if the mo is not valid
        local SKIN = skins[p.skin]
        for i = 1, 3 do
            if SKIN == skins[CLINS[i]] then return true end
        end
    end

	if g then -- If the mo is actually valid
        for i = 1, 3 do
            if g.skin == CLINS[i] then return true end
        end
	end
end)

Giggles.CancelZipTackle = function (gigs)
    gigs.dashing = false
    gigs.dashtimer = TICRATE/4
end

Giggles.MusicLayerChange = function(p, gigs)
    local CurrentLayer
    if gigs.alignmentphase == 1 then CurrentLayer = Giggles.LightMusic end
    if gigs.alignmentphase == 2 then CurrentLayer = Giggles.NeutralMusic end
    if gigs.alignmentphase == 3 then CurrentLayer = Giggles.DarkMusic end

    S_ChangeMusic(CurrentLayer, true, p, nil, S_GetMusicPosition())
end