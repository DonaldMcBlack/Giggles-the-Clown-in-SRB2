local Clown = Clown

-- Main hook
addHook("PlayerThink", function(p)
    if not (p.giggletable) then Clown.Setup(p) return end -- No table? We'll fix that.
    if not (p.mo and p.mo.valid) then return end
    local g = p.mo
    local gigs = p.giggletable local laughs = gigs

    if not (IsGiggles(g)) then
        
    return end

    -- We are Giggles

    if p.pflags & PF_JUMPED
    and not gigs.jumped
    and g.state ~= S_PLAY_FALL then
        gigs.jumped = true
        gigs.dofrontflip = true

        S_StartSound(g, sfx_emjmp)
    end

    if p.pflags & PF_THOKKED
    and (gigs.jumped or gigs.falling)
    and gigs.dofrontflip then
	    gigs.dofrontflip = false
		gigs.didfrontflip = false
        g.state = S_PLAY_ROLL
        S_StartSound(g, sfx_emjmp2)
    end

    if g.state == S_PLAY_ROLL 
    and not gigs.didfrontflip
	and not P_IsObjectOnGround(g)
    and gigs.frontflipduration >= gigs.frontflipdurationref then
        g.state = S_PLAY_FALL
		gigs.frontflipduration = gigs.frontflipdurationref
		gigs.didfrontflip = false
    end

    if g.state == S_PLAY_ROLL
    and not gigs.didfrontflip
    and gigs.frontflipduration < gigs.frontflipdurationref then
        gigs.frontflipduration = $ + 1
    end
end)