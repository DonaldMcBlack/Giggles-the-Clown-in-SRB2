local alignment_value = {}

alignment_value[1] = "P_"
alignment_value[2] = "N_"
alignment_value[3] = "S_"

if not (rawget(_G, "customhud")) then return end
local modname = "giggles"

-- Changes the face depending on health.
local function GetFaceStatus(gigs)
    if gigs.healthpips > 0 then
        local healthamount = gigs.healthpips*FU
        local maxhealth = gigs.maxhealthpips*FU

        local halfhealth = FixedRound(FixedDiv(maxhealth, 2*FU))

        -- CONS_Printf(consoleplayer, "Current health is: " + healthamount + " Actual half health is: " + halfhealth)

        if healthamount == maxhealth then 
            return 5
        else
            if healthamount > halfhealth then return 4
            elseif healthamount == (halfhealth) then return 3
            elseif healthamount >= FixedDiv(maxhealth, 4*FU) then return 2
            elseif healthamount < FixedDiv(maxhealth, 4*FU) then return 1
            end
        end
    else
        return 1
    end
end

-- Draw Giggles' health.
local function DrawHealth(v, p, g, gigs, color)

    if (customhud.CheckType("giggles-health") ~= modname) then return end

    local xoff = 50*FU
    local maxspace = 50*FU

	-- draw from last to first
    local frontflag = V_HUDTRANS
    local backflag = V_HUDTRANSHALF
	
	local healthflags = V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER
	
	-- Draw HP bar first
	local patch = v.cachePatch((alignment_value[gigs.alignment.phase] + "HPBAR"))
	
	v.drawScaled(0, 0, 2*FU/4, patch, healthflags|backflag)
	
	-- Then face
	patch = v.cachePatch((alignment_value[gigs.alignment.phase] + "FACE" + tostring(GetFaceStatus(gigs))))
	
	v.drawScaled(35*FU, 40*FU, 2*FU/4, patch, healthflags|frontflag, color)
	
    for i = 1, gigs.maxhealthpips do

        local j = i

        -- Patch time! 
        if gigs.maxhealthpips - i > gigs.healthpips - 1 then 
            patch = v.cachePatch((alignment_value[gigs.alignment.phase] + "HPDED"))
        else
            patch = v.cachePatch((alignment_value[gigs.alignment.phase] + "HPLIV"))
        end

        -- Always make the first pip displayed go down
        local add = 3*FU

        local is_even = gigs.maxhealthpips % 2  == 0
        if (i%2 and is_even) or (not (i%2) and not is_even) then 
            add = -3*FU
        end

        local incre = (FixedMul(FixedDiv(maxspace, gigs.maxhealthpips*FU)*j, FU*4/5))

        v.drawScaled(maxspace-(incre)+xoff, 40*FU+add, FU/4, patch, healthflags|frontflag)
    end

    v.drawString(55, 55, ("x ") + p.lives, V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER)
end

local function DrawRings(v, p)

    if (customhud.CheckType("rings") ~= modname) then return end

    if ultimatemode then
        return
    end

    p.giggletable.hud.rings.scale = ease.outcubic(FU/4, p.giggletable.hud.rings.scale, p.giggletable.hud.rings.fixedscale)
    local scale = p.giggletable.hud.rings.scale

    local patch = v.cachePatch("G_RING")
    local eflag

    if p.spectator then eflag = V_HUDTRANSHALF
    else eflag = V_HUDTRANS end

    v.drawScaled(260*FU, 35*FU, scale, patch, V_SNAPTORIGHT|V_SNAPTOTOP|eflag|V_PERPLAYER)

    local rings = tostring(p.rings)

    v.drawString(260, 30, rings, V_SNAPTORIGHT|V_SNAPTOTOP|eflag|V_PERPLAYER, "center")
end

local function DrawMagicMobjs(v, p)

    if (customhud.CheckType("giggles-magicmobjs") ~= modname) then return end

    local gigs = p.giggletable

    local objectname = gigs.magicmobjs[gigs.magicmobjspawn.selectednum].name

    v.drawString(250, 30, objectname, V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_HUDTRANS|V_PERPLAYER, "left")
end

local function DrawDebugInfo(v, p)
    if not Giggles_NET.debugmode then return end

    local gigs = p.giggletable
    local debugflags = V_SNAPTOLEFT|V_SNAPTOBOTTOM

    local phasename
    if gigs.alignment.phase == 1 then phasename = "Pure"
    elseif gigs.alignment.phase == 2 then phasename = "Neutral"
    elseif gigs.alignment.phase == 3 then phasename = "Scrapper"
    else phasename = "NULL" end

    v.drawString(50, 140, "Alignment: " + gigs.alignment.points + " (" + phasename + ")", debugflags, "center")
end

-- hud.add(function(v, p)
--     if isdedicatedserver and p == server then return end
--     if not (p.mo and p.mo.valid and p.giggletable) or (gamestate ~= GS_LEVEL) then return end
--     local g = p.mo

--     if IsGiggles(g, p) then
--         hud.disable("lives")
--         hud.disable("rings")
--         hud.disable("score")
--         hud.disable("time")
--     else
--         hud.enable("lives")
--         hud.enable("rings")
--         hud.enable("score")
--         hud.enable("time")
--         return
--     end
	
-- 	local color = v.getColormap(g.skin, g.color)
--     local gigs = p.giggletable

--     DrawHealth(v, p, g, gigs, color)
--     DrawRings(v, p)

-- end)

local unmodname = "vanilla"
local dontdrawgiggleshud = false
addHook("HUD", function(v, p, cam)
    if isdedicatedserver and p == server then return end
    if not (p.mo and p.mo.valid and p.giggletable) or (gamestate ~= GS_LEVEL) then return end

    local g = p.mo
    local color = v.getColormap(g.skin, g.color)
    local gigs = p.giggletable

    if gametype == GT_SAXAMM then dontdrawgiggleshud = true end

    if gigs then
        if IsGiggles(g, p) then
            customhud.SetupItem("rings", modname)
            customhud.SetupItem("lives", modname)
            customhud.SetupItem("giggles-health", modname)
            customhud.SetupItem("giggles-magicmobjs", modname)

            customhud.disable("score")
            customhud.disable("time")
            customhud.disable("lives")
            customhud.disable("rings")

            if not dontdrawgiggleshud then
                DrawHealth(v, p, g, gigs, color)
                DrawRings(v, p)
                DrawMagicMobjs(v, p)
                DrawDebugInfo(v, p)
            end

            if gigs.hud.rings.count ~= p.rings then
                gigs.hud.rings.scale = 2*FU/2
                gigs.hud.rings.count = p.rings
            end
        else -- Not Giggles
            customhud.SetupItem("rings", unmodname)
            customhud.SetupItem("lives", unmodname)
        end
    end
end)