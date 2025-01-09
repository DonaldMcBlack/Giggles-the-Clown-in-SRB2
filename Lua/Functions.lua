rawset(_G, "IsGiggles", function(g, p)
    if p then -- When the mo is not valid
        if p.skin == "giggles" then return true end
    end
	if g then
	     if g.skin == "giggles" then return true end
	end
end)