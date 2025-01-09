local Clown = Clown

local transformation_sounds = {}

transformation_sounds[1] = sfx_ptrans
transformation_sounds[2] = sfx_ntrans
transformation_sounds[3] = sfx_strans

local function MoralitySwap(p)
    p.jumpfactor = GET_MORAL_STATS(p, "jumpfactor")
	p.normalspeed = GET_MORAL_STATS(p, "normalspeed")
	p.runspeed = GET_MORAL_STATS(p, "runspeed")
	p.thrustfactor = GET_MORAL_STATS(p, "thrustfactor")
	p.accelstart = GET_MORAL_STATS(p, "accelstart")
	p.acceleration = GET_MORAL_STATS(p, "acceleration")
end

-- Main hook
addHook("PlayerThink", function(p)
    if not (p.giggletable) then Clown.Setup(p) return end -- No table? We'll fix that.
    if not (p.mo and p.mo.valid) then return end
    local g = p.mo
    local gigs = p.giggletable local laughs = gigs

    if not (IsGiggles(g)) then
        
    return end

    -- We are Giggles

    if g.state == S_PLAY_WAIT and p.camerascale >= 1 then
        p.camerascale = 1
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
        MoralitySwap(p)
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