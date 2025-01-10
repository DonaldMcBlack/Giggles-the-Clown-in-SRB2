local alignment_value = {}

alignment_value[1] = "P_"
alignment_value[2] = "N_"
alignment_value[3] = "S_"



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
	
	v.drawScaled(-10*FU/5, -12*FU, 2*FU/4, patch, healthflags|frontflag, color)
	
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

        v.drawScaled(maxspace-(incre)+xoff, 35*FU+add, FU/4, patch, healthflags|frontflag)
    end

    v.drawString(55, 55, ("x ") + p.lives, V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER)
end

local function DrawRings(v, p)
    if ultimatemode then
        return
    end

    local patch = v.cachePatch("RINGA0")
    local eflag

    if p.spectator then eflag = V_HUDTRANSHALF
    else eflag = V_HUDTRANS end


    v.drawScaled(260*FU, 45*FU, FU*4/5, patch, V_SNAPTORIGHT|V_SNAPTOTOP|eflag|V_PERPLAYER)

    local rings = tostring(p.rings)

    v.drawString(260, 30, rings, V_SNAPTORIGHT|V_SNAPTOTOP|eflag|V_PERPLAYER, "center")
end

hud.add(function(v, p)
    if isdedicatedserver and p == server then return end
    if not (p.mo and p.mo.valid and p.giggletable) or (gamestate ~= GS_LEVEL) then return end
    local g = p.mo

    if IsGiggles(g, p) then
        hud.disable("lives")
        hud.disable("rings")
        hud.disable("score")
        hud.disable("time")
    else
        hud.enable("lives")
        hud.enable("rings")
        hud.enable("score")
        hud.enable("time")
        return
    end
	
	local color = v.getColormap(g.skin, g.color)
    local gigs = p.giggletable

    DrawHealth(v, p, g, gigs, color)
    DrawRings(v, p)

end)