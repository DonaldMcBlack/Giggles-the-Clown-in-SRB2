local Clown = Clown

local transformation_sounds = {}

transformation_sounds[1] = sfx_ptrans
transformation_sounds[2] = sfx_ntrans
transformation_sounds[3] = sfx_strans

-- Main hook
addHook("PlayerThink", function(p)
    if not (p.giggletable) then Clown.Setup(p) return end -- No table? We'll fix that.
    if not (p.mo and p.mo.valid) then return end
    local g = p.mo
    local gigs = p.giggletable local laughs = gigs

    if not (IsGiggles(g)) then
        
    return end

    -- We are Giggles

    -- We were good, now we're bad. Or are we good?
	if gigs.alignmentphase ~= gigs.lastalignmentphase then
	    S_StartSound(g, transformation_sounds[gigs.alignmentphase])
		gigs.lastalignmentphase = gigs.alignmentphase
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