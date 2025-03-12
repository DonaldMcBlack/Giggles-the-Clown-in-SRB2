-- TODO -------------------------------------------
-- TV, Anvil, Watch, Balloon, Fairy Dust
-- Make flickies run from Scrapper
-- Make enemies target other enemies if redeemed
---------------------------------------------------

local Giggles = Giggles

local function GiveRandomItemFromMobj(target, inf, src, dmg, dmgtype)
    if not (target and target.valid) then return end

    if not target.health
    and (src and IsGiggles(src, src.player))
    and not ultimatemode then

        local gigs = src.player.giggletable

        if target.flags & MF_ENEMY then
            if P_RandomChance(FU/gigs.healthpips) then 
                CONS_Printf(consoleplayer, "Spawned Heart Ring.")
                P_SpawnMobjFromMobj(target, 0, 0, target.height*P_MobjFlip(target), MT_HEARTRING)
            end
        end
    end
end

addHook("MobjDeath", GiveRandomItemFromMobj)

addHook("MobjThinker", function(mo)
    if mo.target.player and mo.target.valid then
        local p = mo.target.player
        local gigs = p.giggletable

        if P_RandomChance(FU/2) then
            local wind = P_SpawnMobjFromMobj(mo, P_RandomRange(-18, 18) * mo.scale, P_RandomRange(-18, 18) * mo.scale, P_RandomRange(-18, 18) * mo.scale, MT_BOXSPARKLE)
			wind.frame = $|FF_FULLBRIGHT
			wind.drawonlyforplayer = p
			wind.renderflags = $|RF_FULLBRIGHT
			P_SetObjectMomZ(wind,P_RandomRange(1,3)*FU)
		end

        do
            mo.spritemomz = $ - FU/4

            mo.spritebounce = $ + mo.spritemomz
            if mo.spritebounce <= 0 then
                mo.spritebounce = 0
                mo.spritemomz = 2*FU
            end
        end

        mo.spriteyoffset = mo.spritebounce

        if gigs.majigpointer.forwardmove ~= 0 or gigs.majigpointer.sidemove ~= 0 then
            P_InstaThrust(mo, p.cmd.angleturn<<16 + R_PointToAngle2(0, 0, gigs.majigpointer.forwardmove*FU, -gigs.majigpointer.sidemove*FU), FU*(abs(gigs.majigpointer.forwardmove) + abs(gigs.majigpointer.sidemove)))
        end

        if gigs.majigpointer.upmove == 1 then mo.momz = 0
        elseif gigs.majigpointer.upmove > 1 then
            mo.momz = $+(24*FU)
        end
    end
end, MT_MAJIGARROW)

addHook("MobjSpawn", function(mo)
    mo.shadowscale = FU
    S_StartSound(mo, sfx_nvild)
    mo.anvil = Giggles_NET.magicmobjattribs.anvil
end, MT_ANVIL)

addHook("MobjThinker", function(mo)
    if mo.anvil.ticcer == 1 then mo.eflags = $|MFE_JUSTHITFLOOR end

    if mo.state == S_ANVIL_SPAWN then
        mo.flags = $|MF_NOGRAVITY

        mo.momx = 0
        mo.momy = 0
        mo.momz = 0
    else
        mo.flags = $ & ~MF_NOGRAVITY

        if P_IsObjectOnGround(mo) or mo.anvil.ticcer > 0 then
            if (mo.eflags & MFE_JUSTHITFLOOR) and not mo.anvil.landed then
                S_StartSound(mo, sfx_nvilc)
                P_StartQuake(FU*15, 45)

                Giggles.SpawnDustCircle(mo, MT_DUST, 24 << FRACBITS, false, 16, FU*3, FU, FU/2, 0)
                
                mo.eflags = $ & ~MFE_JUSTHITFLOOR
                mo.anvil.landed = true
            end
        else
            mo.momz = $ + FixedMul(P_GetMobjGravity(mo), FU*15)
            mo.anvil.ticcer = 0
            mo.anvil.landed = false
        end
    end

end, MT_ANVIL)

local function AnvilCollide(anvil, mo)
    S_StartSound(anvil, sfx_nvilh)

    -- Make sure this works on solid objects
    if mo.flags & MF_SOLID then
        mo.anvil.ticcer = $+1
        if (mo.flags & MF_SOLID) then anvil.z = mo.height
        else mo.anvil.ticcer = 0 end
    end

    if (mo == anvil.target or mo.player) and mo.health then
        P_DamageMobj(mo, anvil, anvil.target, 1, DMG_CRUSHED)
    elseif mo.flags & MF_ENEMY then P_KillMobj(mo) end
end

addHook("MobjCollide", function(anvil, mo)
    if not mo.valid then return false end

    local midz = anvil.z + (anvil.height/2)
    local topz = anvil.z + anvil.height
    local bottomz = anvil.z
    local otherz = mo.z + mo.height

    if P_MobjFlip(anvil) == 1 then

		if (mo.z <= bottomz-anvil.scale and otherz >= bottomz+anvil.scale) then
			AnvilCollide(anvil, mo)
		end
		
		if (mo.momz > 0) then return true end
	else
		
		if (otherz <= bottomz+anvil.scale and otherz >= bottomz-anvil.scale) then
            AnvilCollide(anvil, mo)
        end
		
		if (mo.momz < 0) then return true end
	end
end, MT_ANVIL)

addHook("MobjSpawn", function(ring)
    ring.shadowscale = FU
end, MT_HEARTRING)

addHook("TouchSpecial", function(ring, mo)
    if not (mo.player and mo.player.valid) then return end

    local p = mo.player
    local gigs = p.giggletable

    if IsGiggles(mo, p) then
        if gigs.healthpips < gigs.maxhealthpips then
            Giggles.ManageHealth(gigs, "+", 1)
        else return true end
    end

    return false
end, MT_HEARTRING)

addHook("ShouldDamage", function(mo, magic, g, dmg, dmgtype)
    return false
end, MT_PUREMAGIC)

addHook("ShouldDamage", function(mo, magic, g, dmg, dmgtype)
    return true
end, MT_SCRAPPERMAGIC)