local alignment_value = {}

alignment_value[1] = "P_"
alignment_value[2] = "N_"
alignment_value[3] = "S_"


local function DrawHealth(v, g, gigs, color)
    local xoff = 40*FU
    local maxspace = 50*FU

	-- draw from last to first
	local eflag = V_HUDTRANS
	
	local flags = V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER|eflag
	
	-- Draw HP bar first
	local patch = v.cachePatch((alignment_value[gigs.alignmentphase] + "HPBAR"))
	
	v.drawScaled(0, 0, 2*FU/5, patch, flags|V_80TRANS)
	
	-- Then face
	patch = v.cachePatch((alignment_value[gigs.alignmentphase] + "FACE"))
	
	v.drawScaled(50*FU/5, 0, 2*FU/5, patch, flags, color)
	
    for i = 1, gigs.maxhealthpips do

        local j = i

        -- Patch time! 
        local patch = v.cachePatch((alignment_value[gigs.alignmentphase] + "HPLIV"))
        local hp = gigs.healthpips

        

        -- Always make the first pip displayed go down
        local add = 3*FU

        local is_even = gigs.maxhealthpips % 2  == 0
        if (i%2 and is_even) or (not (i%2) and not is_even) then 
            add = -3*FU
        end

        local incre = (FixedMul(FixedDiv(maxspace, gigs.maxhealthpips*FU)*j, FU*4/5))

        -- draw from last to first
        flags = V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER|eflag

        v.drawScaled(maxspace-(incre)+xoff, 20*FU+add, FU/5, patch, flags)


    end
end

hud.add(function(v, p)
    if isdedicatedserver and p == server then return end
    if not (p.mo and p.mo.valid and p.giggletable) or (gamestate ~= GS_LEVEL) then return end
    local g = p.mo
	
	local color = v.getColormap(g.skin, g.color)

    if (g.skin ~= "giggles") then 
        hud.enable("lives")
        hud.enable("rings")
        hud.enable("score")
        hud.enable("time")
        return 
    else
        hud.disable("lives")
        hud.disable("rings")
        hud.disable("score")
        hud.disable("time")
        
    end

    local gigs = p.giggletable

    DrawHealth(v, g, gigs, color)

end)