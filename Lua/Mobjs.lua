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

        if gigs.majigpointer.forwardmove ~= 0 or gigs.majigpointer.sidemove ~= 0 then
            P_InstaThrust(mo, p.cmd.angleturn<<16 + R_PointToAngle2(0, 0, gigs.majigpointer.forwardmove*FU, -gigs.majigpointer.sidemove*FU), FU*(abs(gigs.majigpointer.forwardmove) + abs(gigs.majigpointer.sidemove)))
        end
    end
end, MT_MAJIGARROW)

addHook("MobjSpawn", function(ring)
    ring.shadowscale = FU
end, MT_HEARTRING)

addHook("TouchSpecial", function(ring, mo)
    if not (mo.player and mo.player.valid) then return end

    local p = mo.player
    local gigs = p.giggletable


    if IsGiggles(mo, mo.player) then
        if gigs.healthpips < gigs.maxhealthpips then 
            gigs.healthpips = $+1
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