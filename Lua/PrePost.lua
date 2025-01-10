local Giggles = Giggles
local strong_flags = STR_FLOOR|STR_SPRING|STR_GUARD|STR_HEAVY

addHook("PreThinkFrame", do

    for p in players.iterate do
        if not IsGiggles(p.mo, p) then continue end

        local gigs = p.giggletable
        if not gigs then continue end

        local g = p.mo

        Giggles.AlignmentCheck(p, gigs)

        if not (p.powers[pw_nocontrol]==1 and g and not gigs.dashing) then
            gigs.jump = (p.cmd.buttons & BT_JUMP) and $+1 or 0
            gigs.tossflag = (p.cmd.buttons & BT_TOSSFLAG) and $+1 or 0
            gigs.spin = (p.cmd.buttons & BT_SPIN) and $+1 or 0
        end

        if g then
            if gigs.tossflag == 1 then
                gigs.sprinting = not gigs.sprinting
            elseif (g.state == S_PLAY_STND or g.state == S_PLAY_SKID) then
                gigs.sprinting = false
            end

            if not gigs.justjumped
            and not gigs.falling
            and (p.pflags & PF_JUMPED) then
                S_StartSound(g, sfx_emjmp)
                Giggles_PlayVoice(g, p, P_RandomRange(sfx_givoc1, sfx_givoc4), 40)
                gigs.justjumped = true
            end
            
            if (p.pflags & PF_JUMPED) 
            and (p.pflags & PF_THOKKED)
            and (gigs.justjumped or gigs.falling)
            and not gigs.doublejumped then
                S_StartSound(g, sfx_emjmp2)
                Giggles_PlayVoice(g, p, P_RandomRange(sfx_givoc5, sfx_givoc8), 40)
                
                gigs.frontflip.flipping = true
                gigs.doublejumped = true
                g.state = S_PLAY_ROLL
            end

            -- For ground actions
            if P_IsObjectOnGround(g) then
                if gigs.spin == 1 
                and not gigs.dash.enabled then
                    p.powers[pw_nocontrol] = 1
                    S_StartSound(g, sfx_emdsh)
                    Giggles_PlayVoice(g, p, sfx_giqg1, 50)
                    gigs.dash.enabled = true
                    gigs.dash.angle = g.angle
                end
            end

            -- For air actions
            if not P_IsObjectOnGround(g) then
                if gigs.spin == 1
                and not gigs.groundpound.enabled
                and (p.pflags & PF_JUMPED) then
                    p.powers[pw_strong] = $|strong_flags
                    g.state = S_PLAY_SPINDASH
                    S_StartSound(g, sfx_spin)
                    Giggles_PlayVoice(g, p, P_RandomRange(sfx_giatk1, sfx_giatk3), 50)
                    gigs.groundpound.enabled = true
                    P_SetObjectMomZ(g, 19*FU)
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
        
            gigs.justjumped = false
            gigs.doublejumped = false        
            gigs.falling = false        
            gigs.frontflip.duration = 0
    
        elseif not p.powers[pw_carry] and not (p.pflags & PF_JUMPED) and not gigs.dash.enabled
            and not (p.pflags & PF_SPINNING)
            and not (p.pflags & PF_THOKKED) then
            gigs.grounded = false
            p.pflags = $ | PF_JUMPED
            gigs.falling = true
        end

        if not p.powers[pw_carry]
        and not (p.pflags & PF_JUMPED)
        and not (p.pflags & PF_SPINNING)
        and not (p.pflags & PF_THOKKED)
        and gigs.frontflip.duration > 0
        and g.state ~= S_PLAY_SPRING then
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

        if g.state == S_PLAY_ROLL
        and gigs.frontflip.flipping
        and gigs.frontflip.duration >= gigs.frontflip.durationref then
            g.state = S_PLAY_FALL
            gigs.frontflip.duration = gigs.frontflip.durationref
            gigs.frontflip.flipping = false
        end
        
        if g.state == S_PLAY_ROLL
        and gigs.frontflip.flipping
        and gigs.frontflip.duration < gigs.frontflip.durationref then
            gigs.frontflip.duration = $ + 1
        end

        if (g.eflags & MFE_SPRUNG) then 
            gigs.frontflip.flipping = false
            gigs.frontflip.duration = gigs.frontflip.durationref
            gigs.doublejumped = false 
        end
    end

end)