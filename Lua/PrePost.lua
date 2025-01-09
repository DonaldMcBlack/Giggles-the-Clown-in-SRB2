local Clown = Clown

addHook("PreThinkFrame", do

    for p in players.iterate do
        local gigs = p.giggletable local laughs = gigs

        if not gigs then continue end
        local g = p.mo

        if P_IsObjectOnGround(g) then 
            gigs.jumped = false
            gigs.frontflipduration = 0
        end
    
    end
end)
