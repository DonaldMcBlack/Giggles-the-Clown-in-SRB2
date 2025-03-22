local Giggles = Giggles
local strong_flags = STR_FLOOR|STR_SPRING|STR_GUARD|STR_HEAVY

local function SpawnMajimajigPointer(p, g)
    local mobj = P_SpawnMobjFromMobj(g, 0, 0, 0, MT_MAJIGARROW)


    mobj.target = g
    mobj.drawonlyforplayer = p
    mobj.fuse = -1

    mobj.spritebounce = 0
    mobj.maxspritebounce = 2*FU
    mobj.spritemomz = 2*FU

    p.giggletable.majigpointer.mobj = mobj

    S_StartSound(g, sfx_mjgeq)
end

addHook("PreThinkFrame", do

    for p in players.iterate do
        if not IsGiggles(p.mo, p) then continue end

        local gigs = p.giggletable
        if not gigs then continue end

        local g = p.mo

        -- Music Layers
        if Giggles_NET.currentmap ~= Giggles_NET.nextmap then -- For continuously switching maps

            Giggles_NET.currentmap = Giggles_NET.nextmap
            if mapheaderinfo[Giggles_NET.currentmap].bonustype == 1 then
                Giggles_NET.inbossmap = true

                S_PauseMusic(p)
                S_StartSound(nil, sfx_stboss, p)
            else
                Giggles_NET.inbossmap = false
                Giggles.LoadMusicLayers(Giggles_NET.currentmap)
            end

        elseif Giggles_NET.currentmap and not gigs.O_layersloaded then -- First time loading in
            Giggles.LoadMusicLayers(Giggles_NET.currentmap)
            gigs.O_layersloaded = true
        end

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

            gigs.majigpointer.forwardmove = p.cmd.forwardmove
            gigs.majigpointer.sidemove = p.cmd.sidemove
            gigs.majigpointer.upmove = gigs.jump
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

            -- Magimajig swapping
            
            local currentmagicmobj = gigs.magicmobjspawn.selectednum

            if gigs.weaponnext == 1 and currentmagicmobj < #gigs.magicmobjs then gigs.magicmobjspawn.selectednum = $+1
            elseif gigs.weaponnext == 1 and currentmagicmobj == #gigs.magicmobjs then gigs.magicmobjspawn.selectednum = 0 end

            if gigs.weaponprev == 1 and currentmagicmobj > 0 then gigs.magicmobjspawn.selectednum = $-1
            elseif gigs.weaponprev == 1 and currentmagicmobj == 0 then gigs.magicmobjspawn.selectednum = #gigs.magicmobjs end

            if gigs.weaponprev == 1 or gigs.weaponnext == 1 then S_StartSound(nil, sfx_mmswch, consoleplayer) end
            --

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
                and gigs.c3 == 0 
                and not gigs.dash.enabled
                and not gigs.abilitystates.summoning then
                    p.powers[pw_nocontrol] = 1
                    S_StartSound(g, sfx_emdsh)
                    Giggles_PlayVoice(g, p, sfx_giqg1, 50)
                    gigs.dash.enabled = true
                    gigs.dash.angle = g.angle
                    gigs.dash.aerial = false
                    Giggles.SpawnDustCircle(g, MT_DUST, 8 << FRACBITS/2, true, 16, FU, FU, FU, p.drawangle)
                end

                -- Summoning state

                local pointer = gigs.majigpointer.mobj
                if gigs.c3 == 1 and not gigs.abilitystates.summoning then
                    gigs.abilitystates.summoning = true
                    if not (pointer and pointer.valid) then
                        SpawnMajimajigPointer(p, g)
                    end
                elseif gigs.c3 < 1 and gigs.abilitystates.summoning and pointer.valid then
                    local thing = P_SpawnMobjFromMobj(pointer, 0, 0, pointer.height, gigs.magicmobjs[gigs.magicmobjspawn.selectednum].thingtype)
                    thing.target = g
                    P_SpawnMobjFromMobj(pointer, 0, 0, pointer.height, MT_MAJIGSPARK)
                    
                    local i = 0
                    while i < 20 do
                        local particle = P_SpawnMobjFromMobj(pointer, 0, 0, pointer.height, MT_IVSP)
                        particle.momx = P_RandomRange(-10, 10)*FU
                        particle.momy = P_RandomRange(-10, 10)*FU
                        particle.momz = P_RandomRange(-10, 10)*FU
                        particle.scalespeed = FU/TICRATE
                        particle.destscale = 0
                        i = $+1
                    end

                    gigs.abilitystates.summoning = false
                    S_StartSound(g, sfx_mjguq)
                    P_KillMobj(pointer)
                elseif gigs.c3 > 1 and gigs.spin == 1 and gigs.abilitystates.summoning and pointer.valid then
                    gigs.abilitystates.summoning = false
                    S_StartSound(g, sfx_mjguq)
                    P_KillMobj(pointer)
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
                    Giggles.SpawnDustCircle(g, MT_DUST, 8 << FRACBITS/2, true, 16, FU, FU, FU, p.drawangle)
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
    if not Giggles_NET.startup then
        S_StartSound(nil, sfx_load)
        Giggles_NET.startup = true
    end
    
    for p in players.iterate() do
        if not IsGiggles(p.mo, p) then return end

        local gigs = p.giggletable
        if not gigs or p.playerstate == PST_DEAD then continue end

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

        local gigs = p.giggletable

        if not gigs then continue end
        local g = p.mo

        -- Summoning State
        local pointer = gigs.majigpointer.mobj
        if gigs.abilitystates.summoning and pointer.valid then
            p.drawangle = R_PointToAngle2(g.x, g.y, pointer.x, pointer.y)
        end
    end
end)