local Giggles = Giggles

addHook("PreThinkFrame", do

    for p in players.iterate do
        local gigs = p.giggletable local laughs = gigs

        if not gigs then continue end
        local g = p.mo

        if not (p.powers[pw_nocontrol]==1 and g and not gigs.dashing) then
            gigs.jump = (p.cmd.buttons & BT_JUMP) and $+1 or 0
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
            p.powers[pw_nocontrol] = 1
            gigs.dashing = true
            gigs.dashz = g.momz
        end

        if gigs.jump == 1 and gigs.dashing then
            Giggles.CancelZipTackle(gigs)
            P_DoJump(p)
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