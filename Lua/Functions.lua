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

Giggles.ManageHealth = function(gigs, oper, num)
    if oper == "add" or oper == "+" then
        gigs.healthpips = $+num
        if gigs.healthpips > gigs.maxhealthpips then gigs.healthpips = gigs.maxhealthpips end
    elseif oper == "minus" or oper == "-" then
        gigs.healthpips = $-num
        if gigs.healthpips < 0 then gigs.healthpips = 0 end
    end
end

Giggles.AlignmentCheck = function(p, gigs)

    local ChangeCheck = false

    -- Neutral
    if gigs.alignment.points == 0 and gigs.alignment.phase ~= 2 then
        gigs.alignment.phase = 2
        ChangeCheck = true
    end

    -- Scrapper
    if (gigs.alignment.points == 100) and gigs.alignment.phase ~= 3 then
        gigs.alignment.phase = 3
        ChangeCheck = true
    end

    -- Pure
    if (gigs.alignment.points == -100) and gigs.alignment.phase ~= 1 then
        gigs.alignment.phase = 1
        ChangeCheck = true
    end

    if ChangeCheck then
        R_SetPlayerSkin(p, GET_MORAL_STATS(p, "skinname"))
        gigs.knockbackforce = GET_MORAL_STATS(p, "knockbackforce")
        Giggles.MusicLayerChange(p, gigs)
    end
end

Giggles.MusicLayerChange = function(p, gigs)
    local CurrentLayer
    if gigs.alignment.phase == 1 then CurrentLayer = Giggles.LightMusic end
    if gigs.alignment.phase == 2 then CurrentLayer = Giggles.NeutralMusic end
    if gigs.alignment.phase == 3 then CurrentLayer = Giggles.DarkMusic end

    S_ChangeMusic(CurrentLayer, true, p, nil, S_GetMusicPosition())
end