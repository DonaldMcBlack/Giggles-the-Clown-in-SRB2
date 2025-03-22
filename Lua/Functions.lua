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

-- Resets almost every property related to Giggles
Giggles.ResetAll = function(p, gigs)
    gigs.sprinting = false
    gigs.justjumped = false
    
    gigs.majigpointer.mobj = nil

    gigs.dash.enabled = false
    gigs.groundpound.enabled = false

    gigs.prevrings = 0
    gigs.ringenergy.points = 0
    gigs.ringenergy.maxcount = 3

    gigs.abilitystates.handstand = false
    gigs.abilitystates.summoning = false

end

Giggles.ManageHealth = function(gigs, oper, num)
    if oper == "add" or oper == "+" then
        gigs.healthpips = $+num
        if gigs.healthpips > gigs.maxhealthpips then gigs.healthpips = gigs.maxhealthpips end
    elseif oper == "minus" or oper == "-" then
        gigs.healthpips = $-num
        if gigs.healthpips < 0 then gigs.healthpips = 0 end
    end
end

Giggles.SpawnDustCircle = function(mo, dusttype, rot, vertical, amount, scale, destscale, scalespd, pitch) -- mo is the mobj, dusttype is the particle you'll use, rot is the range, vertical is what is says on the tin, amount is how many mobjs will spawn, scale is what the particles start with, destscale is what they end with, scalespd is scale speed, pitch does nothing for the time being
    for i = 0, amount do
        local left = amount-(i-1)
        local another_angle = 360*(FU/amount)
        local angle = FixedAngle(another_angle*left)

        local z = (mo.height/2)-((mo.height/2)*P_MobjFlip(mo))

        local particle = P_SpawnMobjFromMobj(mo, 0, 0, z, dusttype)
        if particle and particle.valid then

            particle.scale = scale

            particle.destscale = destscale
            particle.scalespeed = scalespd

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

Giggles.LoadMusicLayers = function(map)
    -- Music layer stuff, it's optional and not necessary.
    if mapheaderinfo[map].layered_music ~= nil and mapheaderinfo[map].layered_music == "true" then
        local mapmus = mapheaderinfo[map].musname
            
        -- Do this first to help with not requiring manual SOC inclusion.
        if string.sub(mapmus, 1, 1) == "N" then

            local normalmus = string.sub(mapmus, 2, string.len(mapmus))

            Giggles_NET.musiclayers.layers[1] = "L" + normalmus
            Giggles_NET.musiclayers.layers[2] = mapmus
            Giggles_NET.musiclayers.layers[3] = "D" + normalmus

            if S_MusicExists(Giggles_NET.musiclayers.layers[1]) and S_MusicExists(Giggles_NET.musiclayers.layers[3]) then
                Giggles_NET.musiclayers.canplay = true
            elseif mapheaderinfo[map].lightmusname ~= nil or mapheaderinfo[map].darkmusname ~= nil then -- Fall back on SOC if previous method didn't work
                Giggles_NET.musiclayers.canplay = true
                Giggles_NET.musiclayers.layers[1] = mapheaderinfo[map].lightmusname
                Giggles_NET.musiclayers.layers[2] = mapheaderinfo[map].musname
                Giggles_NET.musiclayers.layers[3] = mapheaderinfo[map].darkmusname
                
            else -- If there is no music found
                Giggles_NET.musiclayers.canplay = false

                Giggles_NET.musiclayers.layers[1] = nil
                Giggles_NET.musiclayers.layers[2] = nil
                Giggles_NET.musiclayers.layers[3] = nil
            end
        else
            Giggles_NET.musiclayers.canplay = false
            Giggles_NET.musiclayers.layers[1] = nil
            Giggles_NET.musiclayers.layers[2] = nil
            Giggles_NET.musiclayers.layers[3] = nil
        end

    else
        Giggles_NET.musiclayers.canplay = false

        Giggles_NET.musiclayers.layers[1] = nil
        Giggles_NET.musiclayers.layers[2] = nil
        Giggles_NET.musiclayers.layers[3] = nil
    end
end

Giggles.MusicLayerChange = function(p, gigs)
    if not Giggles_NET.musiclayers.enabled or not Giggles_NET.musiclayers.canplay or Giggles_NET.inbossmap then return end -- You shouldn't be playing
    if p.powers[pw_invulnerability] or p.powers[pw_sneakers] or p.powers[pw_extralife] then return end -- We want to hear the jingles!

    local CurrentLayer = Giggles_NET.musiclayers.layers[gigs.alignment.phase]

    -- CONS_Printf(p, CurrentLayer)

    if S_MusicExists(CurrentLayer) then S_ChangeMusic(CurrentLayer, true, p, nil, S_GetMusicPosition())
    else LoadMusicLayers(Giggles_NET.currentmap) end
end