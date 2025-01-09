local alignment_value = {}

alignment_value[1] = "P_"
alignment_value[2] = "N_"
alignment_value[3] = "S_"


local function DrawHealth(v, g, gigs, color)
    local xoff = 50*FU
    local maxspace = 50*FU

	-- draw from last to first
    local frontflag = V_HUDTRANS
    local backflag = V_HUDTRANSHALF
	
	local healthflags = V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER
	
	-- Draw HP bar first
	local patch = v.cachePatch((alignment_value[gigs.alignmentphase] + "HPBAR"))
	
	v.drawScaled(0, 0, 2*FU/4, patch, healthflags|backflag)
	
	-- Then face
	patch = v.cachePatch((alignment_value[gigs.alignmentphase] + "FACE"))
	
	v.drawScaled(55*FU/5, -12*FU, 2*FU/4, patch, healthflags|frontflag, color)
	
    for i = 1, gigs.maxhealthpips do

        local j = i

        -- Patch time! 
        if gigs.maxhealthpips - i > gigs.healthpips - 1 then 
            patch = v.cachePatch((alignment_value[gigs.alignmentphase] + "HPDED"))
        else
            patch = v.cachePatch((alignment_value[gigs.alignmentphase] + "HPLIV"))
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

    DrawHealth(v, g, gigs, color)

end)