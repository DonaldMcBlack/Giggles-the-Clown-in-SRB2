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
    and IsGiggles(p.mo)
    and p.giggletable.knockedback then

        local g = p.mo
        local gigs = p.giggletable

        local multiplier = gigs.knockbackforce

        g.momx = FixedMul(multiplier, $)
        g.momy = FixedMul(multiplier, $)

        CONS_Printf(p, "Knockback")
        gigs.knockedback = false
    end
end

-- Giggles.SpinAttack = function(g, p, gigs)

-- end

Giggles.Dash = function(g, p, gigs)

    if gigs.jump == 1 and gigs.justjumped or (g.eflags & MFE_SPRUNG) then
        p.pflags = $ & ~PF_STASIS
        g.flags = $ & ~MF_NOGRAVITY

        if g.skin == "gigglesscrapper" then p.powers[pw_strong] = $ & ~dshstrong_flags end

        if gigs.jump == 1 and gigs.justjumped then 
            P_DoJump(p, true) 
            g.momx = $%2 
            g.momy = $%2
        end
        gigs.dash.enabled = false
    end

    if gigs.dash.timer then 
        P_InstaThrust(g, gigs.dash.angle, p.normalspeed*2)
        if g.skin == "gigglesscrapper" then p.powers[pw_strong] = $|dshstrong_flags end

        local ghost = P_SpawnGhostMobj(g)
        ghost.fuse = 5
        ghost.scalespeed = FU/15
        ghost.destscale = 0

        gigs.dash.timer = max(0, $-1)
        g.state = S_GIGGLES_DASH
        p.drawangle = R_PointToAngle2(g.x, g.y, (g.x+g.momx), (g.y+g.momy))
    else
        p.pflags = $ & ~PF_STASIS
        g.flags = $ & ~MF_NOGRAVITY

        if g.skin == "gigglespure" and P_IsObjectOnGround(g)
        or g.skin == "gigglespure" and p.pflags & PF_THOKKED then
            gigs.dash.enabled = false
            g.state = S_PLAY_FALL
        end

        if g.skin == "gigglesscrapper" then p.powers[pw_strong] = $ & ~dshstrong_flags end

        if g.skin ~= "gigglespure" or g.skin ~= "gigglespure" and P_IsObjectOnGround(g) then
            g.momx = 0
            g.momy = 0
            gigs.dash.enabled = false

            if P_IsObjectOnGround(g) then g.state = S_PLAY_STND
            else g.state = S_PLAY_FALL end
        end
    end

    -- Easy timer reset
    if not gigs.dash.enabled then gigs.dash.timer = gigs.dash.timerref end
end

local function DoDustTrail(g)
    local z = (g.height/2)-((g.height/2)*P_MobjFlip(g))

    local dust = P_SpawnMobjFromMobj(g, 0, 0, z, MT_DUST)
    P_Thrust(dust, FixedAngle(P_RandomRange(360, 0)*FRACUNIT), 3*g.scale)
	P_Thrust(dust, R_PointToAngle2(0,0, g.momx, g.momy), -3*g.scale)
	dust.scale = g.scale
end

-- local function SpawnPoundDust(mo, range)
-- 	local amount = 16
-- 	local another_angle = 360*(FU/amount)

-- 	for i = 1,amount do
-- 		local left = amount-(i-1)
-- 		local angle = fixangle(another_angle*left)

-- 		local z = (mo.height/2)-((mo.height/2)*P_MobjFlip(mo))

-- 		local particle = P_SpawnMobjFromMobj(mo, 0,0,z, MT_THOK)
-- 		particle.state = S_SPINDUST1
-- 		P_InstaThrust(particle, angle, range)
-- 	end
-- end

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
                    Giggles.SpawnDustCircle(g, MT_DUST, 8 << FRACBITS, false, 16, FU*10, 0)
                    P_StartQuake(FU*10, 8)
                    S_StartSound(g, sfx_s3k5d)
                    
                else
                    -- SpawnPoundDust(g, FU*8)
                    Giggles.SpawnDustCircle(g, MT_DUST, 8 << FRACBITS, false, 16, FU*8, 0)
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

    CONS_Printf(p, tostring(gigs.groundpound.stuntime))

    if not (gigs.groundpound.stuntime) then
        gigs.groundpound.enabled = false
        p.powers[pw_strong] = $ & ~gpstrong_flags
        p.pflags = $ & ~PF_JUMPSTASIS
    end
end

-- Main hook
addHook("PlayerThink", function(p)
    if not (p.giggletable) then Giggles.Setup(p) return end -- No table? We'll fix that.
    if not (p.mo and p.mo.valid) then return end
    local g = p.mo
    local gigs = p.giggletable local laughs = gigs

    if not (IsGiggles(g, p)) then
        
    return end

    -- We are Giggles

    if (p.playerstate == PST_DEAD) then
        gigs.healthpips = 0
    return end

    Giggles.Knockback(p)

    if g.state == S_PLAY_WAIT and p.camerascale >= FU then
        p.camerascale = ease.linear(FU*1/10, $, FU)
    else
        p.camerascale = gigs.camerascale
    end

    -- We were good, now we're bad. Or are we good?
	if gigs.alignment.phase ~= gigs.alignment.lastphase then
	    S_StartSound(g, transformation_sounds[gigs.alignment.phase])
		gigs.alignment.lastphase = gigs.alignment.phase
	end
	
	-- if g.momz < -FU and (g.eflags & MFE_JUSTHITFLOOR) then S_StartSound(g, sfx_land1) end
	
    -- Sprinting, since she's too slow
	if gigs.sprinting and P_IsObjectOnGround(g) then
        DoDustTrail(g)
        p.normalspeed = GET_MORAL_STATS(p, "normalspeed")
    elseif not gigs.sprinting and P_IsObjectOnGround(g) then
        p.normalspeed = GET_MORAL_STATS(p, "normalspeed")/2
    end

    if gigs.groundpound.enabled then
        Giggles.GroundPound(p, g, gigs)
        g.momz = $ + FixedMul(P_GetMobjGravity(g), FU*5)
    end

    if gigs.dash.enabled then
        p.pflags = $|PF_STASIS
        g.flags = $|MF_NOGRAVITY
        Giggles.Dash(g, p, gigs)
    end
end)

addHook("MapChange", function(map)
    -- Music layer stuff, it's optional
    if mapheaderinfo[map].layered_music ~= nil and mapheaderinfo[map].layered_music == "true" then

        if mapheaderinfo[map].giggles_light == nil or mapheaderinfo[map].giggles_dark == nil then
            return
        end

        Giggles.LightMusic = mapheaderinfo[map].giggles_light
        Giggles.NeutralMusic = mapheaderinfo[map].musname
        Giggles.DarkMusic = mapheaderinfo[map].giggles_dark
    else
        Giggles.LightMusic = nil
        Giggles.NeutralMusic = nil
        Giggles.DarkMusic = nil
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

    if p and not (dmgtype & DMG_DEATHMASK)
    and p.powers[pw_carry] ~= CR_NIGHTSMODE
    and not p.powers[pw_invulnerability]
    and not p.powers[pw_flashing]
    and not p.powers[pw_super]
    and not G_IsSpecialStage()
    and (not p.guard or p.guard <=0) then
        if 1 < gigs.healthpips then

            if not p.powers[pw_shield] then p.powers[pw_shield] = SH_PITY
            elseif p.rings <= 0 then 
                p.powers[pw_shield] = SH_PITY
            end

            gigs.knockedback = true
            
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

        local doublejumpfactor = GET_MORAL_STATS(p, "thrustfactor")

        if gigs.dash.enabled and g.skin == "gigglespure" then doublejumpfactor = $/2 end

        Giggles.JumpManager(g, doublejumpfactor)
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