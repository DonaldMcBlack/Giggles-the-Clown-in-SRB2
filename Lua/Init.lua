rawset(_G, "Clown", {}) -- Global table for holding functions

Clown.Setup = function(p)
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
            jumped = false,
            doublejumped = false,
            flipping = false,
            frontflipduration = 0,
            frontflipdurationref = 9,
            isrunning = false,

            -- Buttons
            jump = (p.cmd.buttons & BT_JUMP) and 1 or 0,
            spin = (p.cmd.buttons & BT_SPIN) and 1 or 0,
            c1 = (p.cmd.buttons & BT_CUSTOM1) and 1 or 0
        }
    end

    CONS_Printf(p, "Giggles has logged in.")
    return true
end
