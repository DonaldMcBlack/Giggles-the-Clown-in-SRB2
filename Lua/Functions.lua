local Giggles = Giggles

local CLINS = { "gigglespure", "giggles", "gigglesscrapper"}
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

Giggles.SpawnDustCircle = function(mo, dusttype, rot, vertical, amount, range, pitch)
    for i = 0, amount do
        local left = amount-(i-1)
        local another_angle = 360*(FU/amount)
        local angle = FixedAngle(another_angle*left)

        local z = (mo.height/2)-((mo.height/2)*P_MobjFlip(mo))

        local particle = P_SpawnMobjFromMobj(mo, 0, 0, z, dusttype)
        if particle and particle.valid then
            if vertical then
                particle.momz = FixedMul(sin(angle), rot)
                P_InstaThrust(particle, pitch+ANGLE_90,
                FixedMul(cos(angle),rot))
            else
                particle.momx = FixedMul(sin(angle),rot)
                particle.momy = FixedMul(cos(angle),rot)
            end    
        end
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
        R_SetPlayerSkin(p, CLINS[gigs.alignment.phase])
    end
end

Giggles.MusicLayerChange = function(p, gigs)
    if not gigs.musiclayers.enabled or not gigs.musiclayers.canplay then return end -- You shouldn't be playing

    if p.powers[pw_invulnerability] or p.powers[pw_sneakers] or p.powers[pw_extralife] then return end -- We want to hear the jingles!

    local CurrentLayer = gigs.musiclayers.layers[gigs.alignment.phase]
    S_ChangeMusic(CurrentLayer, true, p, nil, S_GetMusicPosition())
end

// Taken from Cash Banooca
Giggles.JumpManager = function(g, z, relative)
    // Nerf any additional jumps made in water
    if g.eflags & MFE_UNDERWATER or g.eflags & MFE_GOOWATER then z = $ - ($/3) end

    P_SetObjectMomZ(g, z, relative)
end