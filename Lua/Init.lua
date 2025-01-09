rawset(_G, "Giggles", {}) -- Global table for holding functions

Giggles.NeutralMusic = nil
Giggles.LightMusic = nil
Giggles.DarkMusic = nil

rawset(_G, "MORAL_STATS", {

    -- Pure
    [1] = {
        skinname = "gigglespure",
		jumpfactor = FRACUNIT*6/4, //1.5
		normalspeed = 40*FRACUNIT,
		runspeed = 28*FRACUNIT,
		thrustfactor = 11,
		accelstart = 255,
		acceleration = 4,
        knockbackforce = FU*5
    },
    -- Neutral
    [2] = {
        skinname = "giggles",
		jumpfactor = FRACUNIT*6/5, //1.2
		normalspeed = 36*FRACUNIT,
		runspeed = 28*FRACUNIT,
		thrustfactor = 11,
		accelstart = 255,
		acceleration = 4,
        knockbackforce = FU*3
    },
    -- Scrapper
    [3] = {
        skinname = "gigglesscrapper",
		jumpfactor = FRACUNIT*6/5, //1.2
		normalspeed = 36*FRACUNIT,
		runspeed = 28*FRACUNIT,
		thrustfactor = 11,
		accelstart = 255,
		acceleration = 4,
        knockbackforce = FU
    }
})

rawset(_G, "SET_MORAL_STATS", function(form, oldstat, newstat)
    MORAL_STATS[form][oldstat] = newstat
end)

rawset(_G, "GET_MORAL_STATS", function(p, stat)
    if stat ~= nil then
        return MORAL_STATS[p.giggletable.alignmentphase][stat]
    else
        return MORAL_STATS[p.giggletable.alignmentphase]
    end
end)

Giggles.Setup = function(p)
    if p.giggletable == nil or (type(p.giggletable) ~= "table") then
        p.giggletable = {
            -- Health
		    healthpips = 5,
			maxhealthpips = 5,

            -- Alignment
            alignment = 0,
            lastalignmentphase = 2,
            alignmentphase = 2,

            hudtoggle = true,

            -- Logic
			sprinting = false,
            dashing = false,
            dashtimer = TICRATE/2,
            dashz = 0,

            jumped = false,
            doublejumped = false,
            flipping = false,
            frontflipduration = 0,
            frontflipdurationref = 9,

            knockedback = false,

            -- Buttons
            jump = (p.cmd.buttons & BT_JUMP) and 1 or 0,
            spin = (p.cmd.buttons & BT_SPIN) and 1 or 0,
            c1 = (p.cmd.buttons & BT_CUSTOM1) and 1 or 0,
			
			tossflag = (p.cmd.buttons & BT_TOSSFLAG) and 1 or 0,

            -- Misc
            camerascale = FU*6/5,
            knockbackforce = FU*3/2,
            layeredmusic = false,
        }
    end

    CONS_Printf(p, "Giggles the clown has come to town.")
    return true
end