local Clown = Clown

addHook("PreThinkFrame", do

    for p in players.iterate do
        local gigs = p.giggletable local laughs = gigs

        if not gigs then continue end
        local g = p.mo

        if not (p.powers[pw_nocontrol]==1 and g) then
            gigs.tossflag = (p.cmd.buttons & BT_TOSSFLAG) and $+1 or 0
            gigs.spin = (p.cmd.buttons & BT_SPIN) and $+1 or 0
        end

        if gigs.tossflag == 1 then
            gigs.sprinting = not gigs.sprinting
        elseif (g.state == S_PLAY_STND or g.state == S_PLAY_SKID) then
            gigs.sprinting = false
        end

        if gigs.spin == 1 
        and P_IsObjectOnGround(g)
        and not gigs.dashing
        and not (p.pflags & PF_JUMPED)
        then 
            gigs.dashing = true
            gigs.dashz = g.momz
        end

    end
end)

addHook("PostThinkFrame", do

    for p in players.iterate() do
        local gigs = p.giggletable local laughs = gigs

        if not gigs then continue end
        local g = p.mo
        
    end

end)