COM_AddCommand("giggles_alignment", function(p, phase)
    if gamestate ~= GS_LEVEL or not p.giggletable then CONS_Printf(p, "You can't do this right now.") return end
    if not IsGiggles(p.mo) then CONS_Printf(p, "Where's your Giggles license?") return end

    local gigs = p.giggletable

    phase = string.lower($)

    if phase == "pure" and gigs.alignmentphase ~= 1 then
        gigs.alignmentphase = 1
        CONS_Printf(p, "You are now purest as can be!")
        return
    end

    if phase == "neutral" and gigs.alignmentphase ~= 2 then 
        gigs.alignmentphase = 2
        CONS_Printf(p, "You are now just Giggles.")
        return
    end

    if phase == "scrapper" and gigs.alignmentphase ~= 3 then
        gigs.alignmentphase = 3
        CONS_Printf(p, "You are now the Scrapper!")
        return
    end

    CONS_Printf(p, "You're already in this form.")
end)

COM_AddCommand("giggles_heal", function(p, num)
    if gamestate ~= GS_LEVEL or not p.giggletable then CONS_Printf(p, "You can't do this right now.") return end
    if not IsGiggles(p.mo) then CONS_Printf(p, "You use rings, silly.") return end

    local gigs = p.giggletable
    num = tonumber(num)

    if gigs.healthpips == gigs.maxhealthpips then
        num = 0 -- Do this just in case
        CONS_Printf(p, "You're already at full health.")
        return
    end

    if gigs.maxhealthpips < num then
        gigs.healthpips = gigs.maxhealthpips
    else
        gigs.healthpips = $+num
    end

    CONS_Printf(p, "Here's your health back!")
end)