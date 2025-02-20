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

addHook("MobjSpawn", function(mo)
    mo.shadowscale = FU
    S_StartSound(mo, sfx_nvild)

end, MT_ANVIL)

addHook("MobjThinker", function(mo)
    if mo.state == S_ANVIL_SPAWN then 
        mo.flags = $|MF_NOGRAVITY

        mo.momx = 0
        mo.momy = 0
        mo.momz = 0
    else
        mo.flags = $ & ~MF_NOGRAVITY

        if P_IsObjectOnGround(mo) then
            if (mo.eflags & MFE_JUSTHITFLOOR) then
                S_StartSound(mo, sfx_nvilc)
                P_StartQuake(FU*10, 15)

                Giggles.SpawnDustCircle(mo, MT_DUST, 24 << FRACBITS, false, 16, FU*3, FU, FU/2, 0)
                
                mo.eflags = $ & ~MFE_JUSTHITFLOOR
            end
        else
            mo.momz = $ + FixedMul(P_GetMobjGravity(mo), FU*15)
    
            searchBlockmap("objects", function(refmobj, foundmobj)
                if foundmobj and foundmobj.valid then
                    if (foundmobj.flags & MF_ENEMY) or (foundmobj.player) then
                        P_KillMobj(foundmobj, mo, mo.target, DMG_CRUSHED)
                    end
                end
            end, mo, mo.x-mo.radius, mo.x+mo.radius, mo.y, mo.y-mo.height/FU)
        end
    end

end, MT_ANVIL)

addHook("MobjThinker", function(mo)
    for p in players.iterate() do
        if player.mo and player.mo.valid then
	
            if player.mo.skin ~= "sonja_belnades" then
                return
            end
            
            if player.custom1down > 1
            and player.custom2down > 1
            and player.custom1down > player.custom2down
            and player.tossflagdown == 0
            and player.mo.energy >= 6*FRACUNIT then
                if not (player.custom1down%TICRATE) then
                    player.mo.energy = $ - 6*FRACUNIT --reduce energy by 6
                end
                if (player.custom1down%(1*(TICRATE/12))-1) then
                    for mobj in mobjs.iterate() do
                        if not ((mobj.flags & MF_AMBIENT) or (mobj.flags & MF_BOXICON) or (mobj.flags & MF_MONITOR) or (mobj.flags & MF_NOTHINK) or (mobj.flags & MF_SCENERY)) then --exclude some mobjs in order to preserve processing power
                            mobj.preslowxmom = mobj.xmom --store x-axis momentum
                            mobj.preslowymom = mobj.ymom --store y-axis momentum
                            mobj.preslowzmom = mobj.zmom --store z-axis momentum
                        end
                    end
                end
                if (player.custom1down%(1*(TICRATE/12))) then
                    player.slowedtime = $ + 1 --remove a tic from the player's HUD time
                    for mobj in mobjs.iterate() do
                        if mobj == localplayer.mo
                        or not ((mobj.flags & MF_AMBIENT) or (mobj.flags & MF_BOXICON) or (mobj.flags & MF_MONITOR) or (mobj.flags & MF_NOTHINK) or (mobj.flags & MF_SCENERY)) then --exclude some mobjs in order to preserve processing power
                            continue --don't slow down Sonja herself
                        else
                            mobj.xmom = 0 --remove x-axis momentum
                            mobj.ymom = 0 --remove y-axis momentum
                            mobj.zmom = 0 --remove z-axis momentum
                            mobj.tics = $ + 1 --delay next action
                            mobj.reactiontime = $ + 1 --delay next action
                            mobj.movecount = $ + 1 --delay next action
                            mobj.threshold = $ + 1 --delay next action
                        end
                    end
                end
                if (player.custom1down%(1*(TICRATE/12))+1) then
                    for mobj in mobjs.iterate() do
                        if not ((mobj.flags & MF_AMBIENT) or (mobj.flags & MF_BOXICON) or (mobj.flags & MF_MONITOR) or (mobj.flags & MF_NOTHINK) or (mobj.flags & MF_SCENERY)) then --exclude some mobjs in order to preserve processing power
                            mobj.xmom = mobj.preslowxmom --return x-axis momentum
                            mobj.ymom = mobj.preslowymom --return y-axis momentum
                            mobj.zmom = mobj.preslowzmom --return z-axis momentum
                        end
                    end
                end
            end
        end
    end
end, MT_WATCH)

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