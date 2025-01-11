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

            gigs.weaponprev = (p.cmd.buttons & BT_WEAPONPREV) and $+1 or 0
            gigs.weaponnext = (p.cmd.buttons & BT_WEAPONNEXT) and $+1 or 0

            gigs.firenormal = (p.cmd.buttons & BT_FIRENORMAL) and $+1 or 0
            gigs.fire = (p.cmd.buttons & BT_ATTACK) and $+1 or 0
        end

        if g then
            if gigs.tossflag == 1 then
                gigs.sprinting = not gigs.sprinting
            elseif (g.state == S_PLAY_STND or g.state == S_PLAY_SKID) then
                gigs.sprinting = false
            end

            if gigs.c1 == 1 then
                P_SetObjectMomZ(g, abs(g.momz), true)
            end

            -- Extend this so it doesn't exceed 0 or length
            local currentmagicmobj = gigs.magicmobjspawn.selectednum

            if gigs.weaponnext == 1 and currentmagicmobj < #gigs.magicmobjs then gigs.magicmobjspawn.selectednum = $+1
            elseif gigs.weaponnext == 1 and currentmagicmobj > #gigs.magicmobjs then gigs.magicmobjspawn.selectednum = 0 end

            if gigs.weaponprev == 1 and currentmagicmobj > 0 then gigs.magicmobjspawn.selectednum = $-1
            elseif gigs.weaponprev == 1 and currentmagicmobj < 0 then gigs.magicmobjspawn.selectednum = #gigs.magicmobjs end

            if gigs.firenormal == 1 then P_SpawnMobjFromMobj(g, g.x+10, 0, 0, MT_HEARTRING) end

            if gigs.firenormal >= 5 or gigs.fire >= 5 then
                p.drawangle = R_PointToAngle(g.x+FixedMul(cos(g.angle), 64<<FRACBITS), g.y+FixedMul(sin(g.angle), 64<<FRACBITS))

                local spray = P_SpawnPlayerMissile(g, MT_REDRING)

                if gigs.firenormal and not gigs.fire then
                    spray.color = SKINCOLOR_SKY
                elseif not gigs.firenormal and gigs.fire then
                    spray.color = SKINCOLOR_GREEN
                end
                
                P_InstaThrust(spray, camera.angle, FU*10)
            end

            -- For ground only actions
            if P_IsObjectOnGround(g) then
                -- Dash
                if gigs.spin == 1 
                and not gigs.dash.enabled then
                    p.powers[pw_nocontrol] = 1
                    S_StartSound(g, sfx_emdsh)
                    Giggles_PlayVoice(g, p, sfx_giqg1, 50)
                    gigs.dash.enabled = true
                    gigs.dash.angle = g.angle
                    gigs.dash.aerial = false
                    Giggles.SpawnDustCircle(g, MT_DUST, 8 << FRACBITS/2, true, 16, FU*4, p.drawangle)
                end
            end

            -- For air only actions
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
                and not gigs.groundpound.enabled
                and gigs.dash.timer then
                    S_StartSound(g, sfx_emdsh)
                    Giggles_PlayVoice(g, p, sfx_giqg1, 50)
                    P_SetObjectMomZ(g, FU, false)
                    p.pflags = $ & ~PF_THOKKED
                    gigs.dash.enabled = true
                    gigs.dash.angle = g.angle
                    gigs.dash.aerial = true
                    Giggles.SpawnDustCircle(g, MT_DUST, 8 << FRACBITS/2, true, 16, FU*4, p.drawangle)
                end
            end
        end

        if Giggles_NET.inbossmap then
            if S_IdPlaying(sfx_stboss) then S_PauseMusic(consoleplayer)
            else S_ResumeMusic(consoleplayer) end
        else
            Giggles.MusicLayerChange(p, gigs)
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
            
            if not gigs.dash.timer and not gigs.dash.enabled then gigs.dash.timer = gigs.dash.timerref end
        elseif not p.powers[pw_carry] 
        and not (p.pflags & PF_JUMPED) 
        and not gigs.dash.enabled
        and g.state ~= S_PLAY_SPRING
            and not (p.pflags & PF_SPINNING)
            and not (p.pflags & PF_THOKKED) then
            gigs.grounded = false
            p.pflags = $ | PF_JUMPED
            gigs.falling = true
            gigs.justjumped = true

            if g.state ~= S_PLAY_PAIN then g.state = S_PLAY_FALL end
        end

        if g.state == S_GIGGLES_DOUBLEJUMP and not gigs.jump and g.momz > 0 then
            g.momz = $/2
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