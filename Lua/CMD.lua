COM_AddCommand("giggles_alignment", function(p, phase)
    if gamestate ~= GS_LEVEL or not p.giggletable then CONS_Printf(p, "You can't do this right now.") return end

    phase = $:lower()

    if phase == "pure" then
        p.giggletable.alignmentphase = 1
        CONS_Printf(p, "You are now purest as can be!")
    end

    if phase == "neutral" then 
        p.giggletable.alignmentphase = 2
        CONS_Printf(p, "You are now just Giggles.")
    end

    if phase == "scrapper" then
        p.giggletable.alignmentphase = 3
        CONS_Printf(p, "You are now the Scrapper!")
    end
	
	if not phase == ("pure" or "neutral" or "scrapper") then return end

    
end)