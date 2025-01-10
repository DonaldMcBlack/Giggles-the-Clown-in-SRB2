rawset(_G, "Giggles", {}) -- Global table for holding functions.

rawset(_G, "Giggles_NET", {
    inbossmap = false,
    playedbossintro = false
})

-- These are set in the S_SKIN files but they're here anyway.
rawset(_G, "MORAL_STATS", {

    -- Pure
    [1] = {
        skinname = "gigglespure",
		jumpfactor = FRACUNIT*6/4, //1.5
		normalspeed = 40*FRACUNIT,
		runspeed = 28*FRACUNIT,
		thrustfactor = 11*FU,
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
		thrustfactor = 11*FU,
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
		thrustfactor = 11*FU,
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
        return MORAL_STATS[p.giggletable.alignment.phase][stat]
    else
        return MORAL_STATS[p.giggletable.alignment.phase]
    end
end)

-- g for the mo, p for the player if mo is empty, insert a string for the clip and chance is for how common.
rawset(_G, "Giggles_PlayVoice", function(g, p, clip, chance)
    if not p.giggletable.voice then return end -- Can't say anything if you're muted dummy
    if p.spectator then return end --         Or if you're dead

    if not g then g = p.mo end

    local val = P_RandomRange(0, 100)

    if val < chance or chance >= 100 then S_StartSound(g, clip) end
end)

Giggles.Setup = function(p)
    if p.giggletable == nil or (type(p.giggletable) ~= "table") then
        p.giggletable = {
            -- Health
		    healthpips = 5,
			maxhealthpips = 5,

            -- Alignment
            alignment = { points = 0, phase = 2, lastphase = 2 },

            hudtoggle = true,

            -- Logic
            grounded = true,
			sprinting = false,
            justjumped = false,

            dash = { enabled = false, timer = 10, timerref = 10, angle = 0, aerial = false },

            groundpound = { enabled = false, canperform = false, stuntime = 5, stuntimeref = 5 },

            knockedback = false,
            fallmomz = 0,

            -- Buttons
            jump = (p.cmd.buttons & BT_JUMP) and 1 or 0,
            spin = (p.cmd.buttons & BT_SPIN) and 1 or 0,
            c1 = (p.cmd.buttons & BT_CUSTOM1) and 1 or 0,
            c2 = (p.cmd.buttons & BT_CUSTOM2) and 1 or 0,
            c3 = (p.cmd.buttons & BT_CUSTOM3) and 1 or 0,

            weaponprev = (p.cmd.buttons & BT_WEAPONPREV) and 1 or 0,
            weaponnext = (p.cmd.buttons & BT_WEAPONNEXT) and 1 or 0,

            firenormal = (p.cmd.buttons & BT_FIRENORMAL) and 1 or 0,
            fire = (p.cmd.buttons & BT_ATTACK) and 1 or 0,
			
			tossflag = (p.cmd.buttons & BT_TOSSFLAG) and 1 or 0,

            -- Magicmobjs
            magicmobjspawn = { enabled = false, canperform = true },
            magicmobjs = { tv = 5, watch = 5, anvil = 5, balloon = 5, fireworks = 5},

            -- Options
            voice = true,
            magicmobjlimit = 5,

            -- Misc
            camerascale = FU*6/5,
            knockbackforce = FU*3/2,
            musiclayers = { enabled = true, canplay = true, layers = {[1] = "light", [2] = "neutral", [3] = "dark"}}
        }
    end
    return true
end