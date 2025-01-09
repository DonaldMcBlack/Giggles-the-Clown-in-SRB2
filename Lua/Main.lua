local Giggles = Giggles

local transformation_sounds = {}

transformation_sounds[1] = sfx_ptrans
transformation_sounds[2] = sfx_ntrans
transformation_sounds[3] = sfx_strans

local function MoralitySwap(p, gigs)
    R_SetPlayerSkin(p, GET_MORAL_STATS(p, "skinname"))
    gigs.knockbackforce = GET_MORAL_STATS(p, "knockbackforce")

    Giggles.MusicLayerChange(p, gigs)
end

Giggles.Knockback = function(p)
    if p.mo
    and p.mo.valid
    and IsGiggles(p.mo)
    and p.giggletable.knockedback then

        local g = p.mo
        local gigs = p.giggletable

        local multiplier = gigs.knockbackforce

        g.momx = FixedMul(multiplier, $)
        g.momy = FixedMul(multiplier, $)

        CONS_Printf(p, "Knockback")
        gigs.knockedback = false
    end
end

-- Main hook
addHook("PlayerThink", function(p)
    if not (p.giggletable) then Giggles.Setup(p) return end -- No table? We'll fix that.
    if not (p.mo and p.mo.valid) then return end
    local g = p.mo
    local gigs = p.giggletable local laughs = gigs

    if not (IsGiggles(g, p)) then
        
    return end

    -- We are Giggles

    if (p.playerstate == PST_DEAD) then
        gigs.healthpips = 0
    return end

    Giggles.Knockback(p)

    if g.state == S_PLAY_WAIT and p.camerascale >= FU then
        p.camerascale = FU
    else
        p.camerascale = gigs.camerascale
    end

    if gigs.dashing then
        P_InstaThrust(g, g.angle, FU*28)
        gigs.dashtimer = $-1
        P_SetObjectMomZ(g, gigs.dashz, false)

        if gigs.dashtimer == 0 then gigs.dashing = false end
    else
        gigs.dashtimer = TICRATE/4
    end

    -- We were good, now we're bad. Or are we good?
	if gigs.alignmentphase ~= gigs.lastalignmentphase then
	    S_StartSound(g, transformation_sounds[gigs.alignmentphase])
        MoralitySwap(p, gigs)

        -- if gigs.alignmentphase > gigs.lastalignmentphase then S_StartSound(g, sfx_stdark, p) 
        -- else
        --     S_StartSound(g, sfx_stliht, p)
        -- end

		gigs.lastalignmentphase = gigs.alignmentphase
	end
	
	if (g.eflags & MFE_JUSTHITFLOOR) then S_StartSound(g, sfx_land1) end
	
    -- Sprinting, since she's too slow
	if gigs.sprinting and P_IsObjectOnGround(g) then
        p.normalspeed = GET_MORAL_STATS(p, "normalspeed")
        local dust = P_SpawnMobjFromMobj(g, 0, 0, 0, MT_DUST)
        P_Thrust(dust, FixedAngle(P_RandomRange(360, 0)*FRACUNIT), 3*g.scale)
		P_Thrust(dust, R_PointToAngle2(0,0, g.momx, g.momy), -3*g.scale)
		dust.scale = g.scale
    elseif not gigs.sprinting and P_IsObjectOnGround(g) then
        p.normalspeed = GET_MORAL_STATS(p, "normalspeed")/2
    end
	
    -- Jumping (Sounds crazy, right?)
	if P_IsObjectOnGround(g) then 
        gigs.jumped = false
		gigs.doublejumped = false
        gigs.falling = false
        gigs.frontflipduration = 0
    else
        if not p.powers[pw_carry] 
        and not (p.pflags & PF_JUMPED)
        and not (p.pflags & PF_SPINNING)
        and not (p.pflags & PF_THOKKED) then
            p.pflags = $ | PF_JUMPED
            gigs.falling = true
        end

        if not p.powers[pw_carry]
        and not (p.pflags & PF_JUMPED)
        and not (p.pflags & PF_SPINNING)
        and not (p.pflags & PF_THOKKED)
        and gigs.frontflipduration > 0
        and g.state ~= S_PLAY_SPRING then
            g.state = S_PLAY_FALL
        end
    end

    if not gigs.jumped 
	and not gigs.flipping
	and not gigs.falling
	and not (p.pflags & PF_THOKKED)
	and (p.pflags & PF_JUMPED) then

        gigs.jumped = true
        S_StartSound(g, sfx_emjmp)
    end

    if (gigs.jumped or gigs.falling)
	and not gigs.doublejumped
    and (p.pflags & PF_JUMPED)
	and (p.pflags & PF_THOKKED) then

		gigs.flipping = true
		gigs.doublejumped = true
        g.state = S_PLAY_ROLL
        S_StartSound(g, sfx_emjmp2)
	end
	
	if g.state == S_PLAY_ROLL
        and gigs.flipping
        and not P_IsObjectOnGround(g)
        and gigs.frontflipduration >= gigs.frontflipdurationref then
        g.state = S_PLAY_FALL
        gigs.frontflipduration = gigs.frontflipdurationref
        gigs.flipping = false
    end
    
    if g.state == S_PLAY_ROLL
    and gigs.flipping
    and gigs.frontflipduration < gigs.frontflipdurationref then
        gigs.frontflipduration = $ + 1
    end
end)

addHook("MapChange", function(map)
    if mapheaderinfo[map].layered_music ~= nil and mapheaderinfo[map].layered_music == "true" then

        if mapheaderinfo[map].giggles_light == nil or mapheaderinfo[map].giggles_dark == nil then
            return
        end

        Giggles.LightMusic = mapheaderinfo[map].giggles_light
        Giggles.NeutralMusic = mapheaderinfo[map].musname
        Giggles.DarkMusic = mapheaderinfo[map].giggles_dark
    else
        Giggles.LightMusic = nil
        Giggles.NeutralMusic = nil
        Giggles.DarkMusic = nil
    end
end)

addHook("PlayerSpawn", function(p)
    if not (p.mo and p.mo.valid) then return end
    
    if not (p.giggletable) then Giggles.Setup(p) end -- No table? We'll fix that.

    if IsGiggles(p.mo, p) and p.giggletable and not p.spectator then
        -- Do this for now
        p.giggletable.healthpips = p.giggletable.maxhealthpips
        MoralitySwap(p, p.giggletable)
    end
end)

addHook("MobjDamage", function(g, inf, src, dmg, dmgtype)
    local p = g and g.valid and IsGiggles(g) and g.player
    if not p then return end

    local gigs = p.giggletable

    if p and not (dmgtype & DMG_DEATHMASK)
    and p.powers[pw_carry] ~= CR_NIGHTSMODE
    and not p.powers[pw_invulnerability]
    and not p.powers[pw_flashing]
    and not p.powers[pw_super]
    and not G_IsSpecialStage()
    and (not p.guard or p.guard <=0) then
        if 1 < gigs.healthpips then

            if not p.powers[pw_shield] then p.powers[pw_shield] = SH_PITY
            elseif p.rings <= 0 then 
                p.powers[pw_shield] = SH_PITY
            end

            gigs.knockedback = true
            
            gigs.healthpips = $-1
        elseif gigs.healthpips <= 1 then
            P_KillMobj(g, inf, src, dmgtype)
        end
    end

end, MT_PLAYER)