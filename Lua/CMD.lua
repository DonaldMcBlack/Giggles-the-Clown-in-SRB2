COM_AddCommand("giggles_alignment", function(p, phase)
    if gamestate ~= GS_LEVEL or not p.giggletable then CONS_Printf(p, "You can't do this right now.") return end
    if not IsGiggles(p.mo) then CONS_Printf(p, "Where's your Giggles license?") return end

    local gigs = p.giggletable

    phase = string.lower($)

    if phase == "pure" and gigs.alignment.phase ~= 1 then
        gigs.alignment.points = -100
        CONS_Printf(p, "You are now purest as can be!")
        S_StartSound(p.mo, sfx_stliht, p)
        return
    end

    if phase == "neutral" and gigs.alignment.phase ~= 2 then 
        gigs.alignment.points = 0
        CONS_Printf(p, "You are now just Giggles.")
        return
    end

    if phase == "scrapper" and gigs.alignment.phase ~= 3 then
        gigs.alignment.points = 100
        CONS_Printf(p, "You are now the Scrapper!")
        S_StartSound(p.mo, sfx_stdark, p)
        return
    end

    CONS_Printf(p, "You're already in this form.")
    
end)

COM_AddCommand("giggles_setmaxhealth", function(p, num)
    if gamestate ~= GS_LEVEL or not p.giggletable then CONS_Printf(p, "You can't do this right now.") return end
    if not IsGiggles(p.mo) then CONS_Printf(p, "You use rings, silly.") return end

    local gigs = p.giggletable
    num = tonumber(num)

    if num <= 0 then
        CONS_Printf(p, "Can't do that.")

    else
        gigs.maxhealthpips = num
        CONS_Printf(p, "Max health changed!")
    end
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

    Giggles.ManageHealth(gigs, "+", num)

    CONS_Printf(p, "Here's your health back!")
end)

COM_AddCommand("giggles_voice", function(p, toggle)
    if not p.giggletable then CONS_Printf(p, "You can't do this right now.") return end

    local gigs = p.giggletable

    if toggle == "true" then 
        gigs.voice = true
        CONS_Printf(p, "Giggles can now speak!")
    elseif toggle == "false" then 
        gigs.voice = false
        CONS_Printf(p, "Giggles is now mute!")
    end
end)