local Giggles = Giggles
local strong_flags = STR_FLOOR|STR_SPRING|STR_GUARD|STR_HEAVY

addHook("PreThinkFrame", do

    for p in players.iterate do
        if not IsGiggles(p.mo, p) then continue end

        local gigs = p.giggletable
        if not gigs then continue end

        local g = p.mo

        Giggles.AlignmentCheck(p, gigs)

        if not (p.powers[pw_nocontrol]==1 and g) then
            gigs.jump = (p.cmd.buttons & BT_JUMP) and $+1 or 0
            gigs.tossflag = (p.cmd.buttons & BT_TOSSFLAG) and $+1 or 0
            gigs.spin = (p.cmd.buttons & BT_SPIN) and $+1 or 0
            gigs.c1 = (p.cmd.buttons & BT_CUSTOM1) and $+1 or 0
            gigs.c2 = (p.cmd.buttons & BT_CUSTOM2) and $+1 or 0
            gigs.c3 = (p.cmd.buttons & BT_CUSTOM3) and $+1 or 0
        end

        if g then
            if gigs.tossflag == 1 then
                gigs.sprinting = not gigs.sprinting
            elseif (g.state == S_PLAY_STND or g.state == S_PLAY_SKID) then
                gigs.sprinting = false
            end

            -- For ground actions
            if P_IsObjectOnGround(g) then
                -- Dash
                if gigs.spin == 1 
                and not gigs.dash.enabled then
                    p.powers[pw_nocontrol] = 1
                    S_StartSound(g, sfx_emdsh)
                    Giggles_PlayVoice(g, p, sfx_giqg1, 50)
                    gigs.dash.enabled = true
                    gigs.dash.angle = g.angle
                    Giggles.SpawnDustCircle(g, MT_DUST, 8 << FRACBITS/2, true, 16, FU*4, p.drawangle)
                end
            end

            -- For air actions
            if not P_IsObjectOnGround(g) then
                -- Ground pound
                if gigs.c3 == 1
                and not gigs.groundpound.enabled
                and not gigs.dash.enabled
                and (p.pflags & PF_JUMPED) then
                    p.powers[pw_strong] = $|strong_flags
                    g.state = S_PLAY_SPINDASH
                    S_StartSound(g, sfx_spin)
                    Giggles_PlayVoice(g, p, P_RandomRange(sfx_giatk1, sfx_giatk3), 50)
                    gigs.groundpound.enabled = true
                    P_SetObjectMomZ(g, 19*FU)
                end

                -- Air Dash (Pure Only)
                if g.skin == "gigglespure"
                and gigs.spin == 1
                and not gigs.dash.enabled
                and not gigs.groundpound.enabled then
                    S_StartSound(g, sfx_emdsh)
                    Giggles_PlayVoice(g, p, sfx_giqg1, 50)
                    p.pflags = $ & ~PF_THOKKED
                    gigs.dash.enabled = true
                    gigs.dash.angle = g.angle
                    Giggles.SpawnDustCircle(g, MT_DUST, 8 << FRACBITS/2, true, 16, FU*4, p.drawangle)
                end
            end
        end
    end
end)

addHook("ThinkFrame", do
    for p in players.iterate() do
        if not IsGiggles(p.mo, p) then return end

        local gigs = p.giggletable
        if not gigs then continue end

        local g = p.mo
        
        -- Jumping (Sounds crazy, right?)
        if P_IsObjectOnGround(g) then 
            gigs.grounded = true
            gigs.falling = false  
            gigs.justjumped = false      
        elseif not p.powers[pw_carry] 
        and not (p.pflags & PF_JUMPED) 
        and not gigs.dash.enabled
        and g.state ~= S_PLAY_SPRING
            and not (p.pflags & PF_SPINNING)
            and not (p.pflags & PF_THOKKED) then
            gigs.grounded = false
            p.pflags = $ | PF_JUMPED
            gigs.falling = true
            g.state = S_PLAY_FALL
        end
    end
end)

addHook("PostThinkFrame", do

    for p in players.iterate() do
        if not IsGiggles(p.mo, p) then return end

        local gigs = p.giggletable local laughs = gigs

        if not gigs then continue end
        local g = p.mo
    end
end)