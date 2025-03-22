-- TODO -------------------------------------------
-- Spin Attack
-- [Done] Working Magimajigs
-- Charge spin attack for Scrapper
-- [Done] Fix the dive for Pure
-- [Done]Dive jump for Pure
-- Optional battle music
---------------------------------------------------

local Giggles = Giggles

local transformation_sounds = {}

transformation_sounds[1] = sfx_ptrans
transformation_sounds[2] = sfx_ntrans
transformation_sounds[3] = sfx_strans

local dshstrong_flags = STR_GUARD|STR_WALL|STR_SPIKE
local gpstrong_flags = STR_FLOOR|STR_SPRING|STR_GUARD|STR_HEAVY

local gp_sounds = {}
gp_sounds[1] = sfx_emgp1
gp_sounds[2] = sfx_emgp2
gp_sounds[3] = sfx_emgp3

-- Took this from Chaotix
Giggles.Knockback = function(p)
    if p.mo
    and p.mo.valid
    and IsGiggles(p.mo) then

        local g = p.mo
        local gigs = p.giggletable

        if g.skin == "giggles" then return end

        local multiplier

        if g.skin == "gigglespure" then multiplier = FU*5
        elseif g.skin == "gigglesscrapper" then multiplier = FU end

        g.momx = FixedMul(multiplier, $)
        g.momy = FixedMul(multiplier, $)

        -- CONS_Printf(p, "Knockback")
    end
end

-- Giggles.SpinAttack = function(g, p, gigs)

-- end
Giggles.Dash = function(g, p, gigs)
    -- CONS_Printf(p, "Dash Time: " + tostring(gigs.dash.timer) + "Is Aerial: " + gigs.dash.aerial)

    -- Main dash
    if not gigs.dash.aerial then
        -- Dash Cancel
        if gigs.jump == 1 and not gigs.justjumped or (g.eflags & MFE_SPRUNG) then
        
            p.pflags = $ & ~PF_STASIS
            g.flags = $ & ~MF_NOGRAVITY
            if g.skin == "gigglesscrapper" then p.powers[pw_strong] = $ & ~dshstrong_flags end

            if gigs.jump == 1 and not gigs.justjumped then
            
                P_DoJump(p, true)
                g.momx = $%2
                g.momy = $%2
                gigs.justjumped = true
                S_StartSound(g, sfx_emjmp)
            end
            gigs.dash.enabled = false
            gigs.dash.timer = gigs.dash.timerref
            return
        end
        
        if gigs.dash.timer then
            p.pflags = $|PF_STASIS
            g.flags = $|MF_NOGRAVITY

            P_InstaThrust(g, gigs.dash.angle, skins[g.skin].normalspeed)
            local ghost = P_SpawnGhostMobj(g)
            ghost.fuse = 5
            ghost.scalespeed = FU/15
            ghost.destscale = 0
        
            if g.skin == "gigglesscrapper" then p.powers[pw_strong] = $|dshstrong_flags end
            
            gigs.dash.timer = max(0, $-1)
            g.state = S_GIGGLES_DASH
            p.drawangle = R_PointToAngle2(g.x, g.y, (g.x+g.momx), (g.y+g.momy))
    
        else
            p.pflags = $ & ~PF_STASIS
            g.flags = $ & ~MF_NOGRAVITY

            gigs.dash.enabled = false
            gigs.dash.timer = gigs.dash.timerref

            -- CONS_Printf(p, gigs.majigpointer.forwardmove..","..gigs.majigpointer.sidemove)

            if gigs.majigpointer.forwardmove == 0 and gigs.majigpointer.sidemove == 0 then
                g.momx = 0
                g.momy = 0

                -- CONS_Printf(p, "Stop")
            end

            -- Remove Scrapper's strong flags
            if g.skin == "gigglesscrapper" then p.powers[pw_strong] = $ & ~dshstrong_flags end

            -- Leave dash state
            if P_IsObjectOnGround(g) then g.state = S_PLAY_STND
            else g.state = S_PLAY_FALL end
        end
    else -- Air dash for Pure Giggles
        g.state = S_GIGGLES_DASH

        if gigs.dash.timer then
            p.pflags = $|PF_STASIS

            P_InstaThrust(g, gigs.dash.angle, p.normalspeed*2)
            local ghost = P_SpawnGhostMobj(g)
            ghost.fuse = 5
            ghost.scalespeed = FU/15
            ghost.destscale = 0

            gigs.dash.timer = max(0, $-1)
            p.drawangle = R_PointToAngle2(g.x, g.y, (g.x+g.momx), (g.y+g.momy))
        else
            p.pflags = $ & ~PF_STASIS
        end

        if P_IsObjectOnGround(g) then
            gigs.dash.enabled = false -- Let the hook deal with it, it's fine.
            gigs.dash.timer = gigs.dash.timerref
            g.state = S_PLAY_STND or S_PLAY_WALK
        elseif p.pflags & PF_THOKKED then 
            gigs.dash.enabled = false 
            g.state = S_GIGGLES_DOUBLEJUMP
        end
    end
end

local function DoDustTrail(g)
    local z = (g.height/2)-((g.height/2)*P_MobjFlip(g))

    local dust = P_SpawnMobjFromMobj(g, 0, 0, z, MT_DUST)
    P_Thrust(dust, FixedAngle(P_RandomRange(360, 0)*FRACUNIT), 3*g.scale)
	P_Thrust(dust, R_PointToAngle2(0,0, g.momx, g.momy), -3*g.scale)
	dust.scale = g.scale
end

Giggles.GroundPound = function(p, g, gigs)

	if not gigs.groundpound.enabled then
		p.powers[pw_strong] = $ & ~gpstrong_flags
        gigs.groundpound.stuntime = gigs.groundpound.stuntimeref
		return
    end

	if g.eflags & MFE_SPRUNG then
		gigs.groundpound.enabled = false
        gigs.groundpound.stuntime = gigs.groundpound.stuntimeref
		g.spritexscale = FU
		g.spriteyscale = FU
		p.powers[pw_strong] = $ & ~gpstrong_flags
		return
	end

	local slope = (g.standingslope and g.standingslope.valid) and g.standingslope

	if P_IsObjectOnGround(g) then
		if not slope then
            if gigs.groundpound.stuntime == gigs.groundpound.stuntimeref then

                if g.skin == "gigglesscrapper" then
                    -- SpawnPoundDust(g, FU*10)
                    Giggles.SpawnDustCircle(g, MT_DUST, 10 << FRACBITS, false, 16, FU*6/5, FU/4, FU, 0)
                    P_StartQuake(FU*10, 8)
                    S_StartSound(g, sfx_s3k5d)
                    
                else
                    -- SpawnPoundDust(g, FU*8)
                    Giggles.SpawnDustCircle(g, MT_DUST, 8 << FRACBITS, false, 16, FU, FU, FU, 0)
                end
                S_StartSound(g, gp_sounds[P_RandomRange(1, 3)])
                p.pflags = $|PF_JUMPSTASIS
            end

            gigs.groundpound.stuntime = max(0, $-1)

			g.momx = 0
			g.momy = 0
			g.momz = 0

            local tweenTime = FixedDiv(gigs.groundpound.stuntime, gigs.groundpound.stuntimeref)

			g.spritexscale = FU+ease.incubic(tweenTime, 0, FU)
			g.spriteyscale = FU-ease.incubic(tweenTime, 0, FU)
		else
			S_StartSound(p.mo, sfx_spndsh)
			g.spritexscale = FU
			g.spriteyscale = FU
            gigs.groundpound.stuntime = 0
			p.pflags = $|PF_SPINNING
			g.state = S_PLAY_ROLL
			P_InstaThrust(g, p.drawangle, abs(FixedMul(p.normalspeed, cos(slope.zangle))))
		end
	else
		if g.state ~= S_PLAY_RIDE then
			g.state = S_PLAY_RIDE
		end

        if g.skin ~= "gigglespure" then
            g.momx = 0
			g.momy = 0
        end

        gigs.groundpound.stuntime = gigs.groundpound.stuntimeref

		local scale = min(FixedDiv(g.momz*P_MobjFlip(g), -60*FU), FU/3)
		g.spriteyscale = FU+scale
		g.spritexscale = FU-scale
	end

    -- CONS_Printf(p, tostring(gigs.groundpound.stuntime))

    if not (gigs.groundpound.stuntime) then
        gigs.groundpound.enabled = false
        p.powers[pw_strong] = $ & ~gpstrong_flags
        p.pflags = $ & ~PF_JUMPSTASIS
    end
end

local function LevelByRings(p, gigs)
    -- After Giggles collects a ring
    if gigs.prevrings > p.rings then
        gigs.prevrings = p.rings
    elseif gigs.prevrings < p.rings then
        gigs.ringenergy.points = $ + (p.rings - gigs.prevrings)
        gigs.hud.rings.scale = 2*FU/2

        if gigs.ringenergy.points > 9 then
            gigs.ringenergy.count = tonumber(string.sub(tostring(gigs.ringenergy.points), 1, 1))

            -- Keep it under the max amount
            if gigs.ringenergy.count > gigs.ringenergy.maxcount then
                gigs.ringenergy.count = gigs.ringenergy.maxcount
            end
        else
            gigs.ringenergy.count = 0
        end
        gigs.prevrings = p.rings
    end

    -- Updates the maximum amount of bars
    for i = #Giggles_NET.ringenergylevels, 1, -1 do
        local v = Giggles_NET.ringenergylevels[i]
        if p.rings >= v then
            gigs.ringenergy.maxcount = 3 + (v/30)

            if gigs.ringenergy.prevmaxcount < gigs.ringenergy.maxcount then
                gigs.ringenergy.prevmaxcount = gigs.ringenergy.maxcount
                gigs.hud.leveluptimer = 120
            elseif gigs.ringenergy.prevmaxcount > gigs.ringenergy.maxcount then
                gigs.ringenergy.prevmaxcount = gigs.ringenergy.maxcount
            end
            break
        end
    end
end

-- Main hook
addHook("PlayerThink", function(p)
    if not (p.giggletable) then Giggles.Setup(p) return end -- No table? We'll fix that.
    if not (p.mo and p.mo.valid) then return end
    local g = p.mo
    local gigs = p.giggletable

    -- We're not Giggles
    if not (IsGiggles(g, p)) then Giggles.ResetAll(p, gigs) return end

    -- We are Giggles

    LevelByRings(p, gigs)

    -- Do some idle stuff
    if g.state == S_PLAY_WAIT and p.camerascale >= FU then
        p.camerascale = ease.linear(FU*1/10, $, FU)
    else
        p.camerascale = skins[g.skin].camerascale
    end

    -- We were good, now we're bad. Or are we good?
	if gigs.alignment.phase ~= gigs.alignment.lastphase then
	    S_StartSound(g, transformation_sounds[gigs.alignment.phase])
		gigs.alignment.lastphase = gigs.alignment.phase
	end

    if not P_IsObjectOnGround(g) and g.momz < 0 then
        gigs.fallmomz = g.momz
		-- CONS_Printf(p, tostring(g.momz))
    elseif not P_IsObjectOnGround(g) and g.momz > 0 then
        -- camera.momz = 0
    elseif abs(gigs.fallmomz) >= p.height/4 and (g.eflags & MFE_JUSTHITFLOOR) and not gigs.groundpound.enabled then
        S_StartSound(g, P_RandomRange(sfx_land1, sfx_land3))
        Giggles.SpawnDustCircle(g, MT_DUST, 8 << FRACBITS/2, false, 8, FU, FU, FU, 0)
        gigs.fallmomz = 0
    else
	    gigs.fallmomz = 0
	end

    if g.eflags & MFE_SPRUNG then
        p.pflags = $|PF_JUMPED
        gigs.justjumped = true
    end
	
    -- Sprinting, since she's too slow
	if gigs.sprinting and P_IsObjectOnGround(g) or p.powers[pw_sneakers] == 1 then
        DoDustTrail(g)
        p.normalspeed = skins[g.skin].normalspeed
    elseif not gigs.sprinting and P_IsObjectOnGround(g) then
        p.normalspeed = skins[g.skin].normalspeed/2
    end

    if gigs.abilitystates.summoning then p.pflags = $|PF_FULLSTASIS
    else p.pflags = $ & ~PF_FULLSTASIS end

    if gigs.groundpound.enabled then
        Giggles.GroundPound(p, g, gigs)
        g.momz = $ + FixedMul(P_GetMobjGravity(g), FU*5)
    end

    if gigs.dash.enabled then
        Giggles.Dash(g, p, gigs)
    end
end)

addHook("MusicChange", function(oldmus, newmus)
    if not Giggles_NET.musiclayers.layers then return end

    for i, v in ipairs(Giggles_NET.musiclayers.layers) do
        if v ~= type("number") or not S_MusicExists(v) then break end
        if newmus == Giggles_NET.musiclayers.layers[i] then Giggles_NET.musiclayers.canplay = true
        else Giggles_NET.musiclayers.canplay = false end

        CONS_Printf(consoleplayer, newmus)
    end
end)

addHook("MapChange", function(map) Giggles_NET.nextmap = map end)

addHook("MapLoad", function(map)
    if not Giggles_NET.currentmap then Giggles_NET.currentmap = map end

    for p in players.iterate() do
        if not p.giggletable then
            Giggles.Setup(p)
        else
            Giggles.ResetAll(p, p.giggletable)
        end
    end
end)

addHook("PlayerSpawn", function(p)
    if not (p.mo and p.mo.valid) then return end
    if not (p.giggletable) then Giggles.Setup(p) end -- No table? We'll fix that.

    if IsGiggles(p.mo, p) and p.giggletable and not p.spectator then
        -- Do this for now
        p.giggletable.healthpips = p.giggletable.maxhealthpips
        Giggles.AlignmentCheck(p, p.giggletable)
    end
end)

addHook("PlayerCanDamage", function(p, mobj)
    if not IsGiggles(p.mo, p) then return end
    local g = p.mo
    local gigs = p.giggletable

    if gigs.dash.enabled then
        if mobj.flags & MF_MONITOR then return true end

        if g.skin == "gigglesscrapper" then
            if mobj.flags & MF_ENEMY then
                return true
            end
        end
    end
end)

addHook("MobjDamage", function(g, inf, src, dmg, dmgtype)
    local p = g and g.valid and IsGiggles(g) and g.player
    if not p then return end

    local gigs = p.giggletable

    if p and p.valid and not (dmgtype & DMG_DEATHMASK)
    and p.powers[pw_carry] ~= CR_NIGHTSMODE
    and not p.powers[pw_invulnerability]
    and not p.powers[pw_flashing]
    and not p.powers[pw_super]
    and not G_IsSpecialStage()
    and (not p.guard or p.guard <=0) then
        if 1 < gigs.healthpips then

            if p.rings == 0 and not p.powers[pw_shield] then
                p.powers[pw_shield] = SH_PITY
            end

            gigs.ringenergy.points = $/2
            if gigs.ringenergy.maxcount > 3 then gigs.ringenergy.maxcount = $-1 end

            Giggles.Knockback(p)
            Giggles.ManageHealth(gigs, "-", 1)
            Giggles_PlayVoice(g, p, P_RandomRange(sfx_gipai1, sfx_gipai4), 75)
        else
            gigs.healthpips = 0
            P_KillMobj(g, inf, src, dmgtype)
        end
    end

end, MT_PLAYER)

addHook("JumpSpecial", function(p)
    if not IsGiggles(p.mo, p) then return end

    local g = p.mo

    if not p.giggletable.justjumped
    and (p.pflags & PF_JUMPED) then
        S_StartSound(g, sfx_emjmp)
        Giggles_PlayVoice(g, p, P_RandomRange(sfx_givoc1, sfx_givoc4), 40)
        p.giggletable.justjumped = true
    end

    return false
end)

addHook("AbilitySpecial", function(p)
    if not IsGiggles(p.mo, p) then return end
    if p.giggletable.groundpound.enabled then return end

    local g = p.mo
    local gigs = p.giggletable

    if not (p.pflags & PF_THOKKED)
    and g.state ~= S_PLAY_SPINDASH then
        S_StartSound(g, sfx_emjmp2)
        Giggles_PlayVoice(g, p, P_RandomRange(sfx_givoc5, sfx_givoc8), 40)

        local djfactor = 10*FU
        local jfactor = min(FixedDiv(p.jumpfactor, skins[g.skin].jumpfactor), FU)
        
        if gigs.dash.enabled and g.skin == "gigglespure" then djfactor = $/4 end

        if g.eflags & MFE_UNDERWATER or g.eflags & MFE_GOOWATER then djfactor = $ - ($/3) end

        P_DoJump(p, false)
        P_SetObjectMomZ(g, FixedMul(djfactor, jfactor))
        
        g.state = S_GIGGLES_DOUBLEJUMP
        p.pflags = $ | PF_THOKKED
    end
end)

-- Use for linedef 443
addHook("LinedefExecute", function(line, mo)
    if not mo.player.valid then return end
    if not IsGiggles(mo, mo.player) then return end

    local gigs = mo.player.giggletable

    if gigs.alignment.phase ~= 3 and mo.skin ~= "gigglesscrapper" then gigs.alignment.points = 100 end
end, "INSTASCRAPPER")

addHook("LinedefExecute", function(line, mo)
    if not mo.player.valid then return end
    if not IsGiggles(mo, mo.player) or not mo.valid then return end

    local gigs = mo.player.giggletable

    if gigs.alignment.phase ~= 1 and mo.skin ~= "gigglespure" then gigs.alignment.points = -100 end
end, "INSTAPURE")

addHook("LinedefExecute", function(line, mo)
    if not mo.player.valid then return end
    if not IsGiggles(mo, mo.player) or not mo.valid then return end

    local gigs = mo.player.giggletable

    if gigs.alignment.phase ~= 2 and mo.skin ~= "giggles" then gigs.alignment.points = 0 end
end, "INSTANEUTRAL")

-- Reset values for Time Watch effects
addHook("MobjThinker", function(mobj)
	if mobj and mobj.valid
	and not ((mobj.flags & MF_AMBIENT) or (mobj.flags & MF_NOTHINK) or (mobj.flags & MF_SCENERY)) then --exclude some mobjs in order to preserve processing power
		if mobj.preslowxmom == nil then
			mobj.preslowxmom = 0
		end
		if mobj.preslowymom == nil then
			mobj.preslowymom = 0
		end
		if mobj.preslowzmom == nil then
			mobj.preslowzmom = 0
		end
	end
end, MT_NULL) --run this for everything