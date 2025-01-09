rawset(_G, "Clown", {}) -- Global table for holding functions

Clown.Setup = function(p)
    if p.giggletable == nil or (type(p.giggletable) ~= "table") then
        p.giggletable = {
            alignment = 0,
            hudtoggle = true,

            jumped = false,
            dofrontflip = false,
            frontflipduration = 0,
            frontflipdurationref = 12,
			didfrontflip = false,
            isrunning = false,



            jump = (p.cmd.buttons & BT_JUMP) and 1 or 0,
            spin = (p.cmd.buttons & BT_SPIN) and 1 or 0,
            c1 = (p.cmd.buttons & BT_CUSTOM1) and 1 or 0
        }
    end

    CONS_Printf(p, "Giggles has logged in.")
    return true
end
