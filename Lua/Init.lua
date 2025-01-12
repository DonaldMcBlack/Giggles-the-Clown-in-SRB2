rawset(_G, "Giggles", {}) -- Global table for holding functions.

rawset(_G, "Giggles_NET", {
    -- Gameplay Stuff
    inbossmap = false,
    playedbossintro = false,
    currentmap = nil,
    musiclayers = { enabled = true, canplay = true, layers = {[1] = "L", [2] = "N", [3] = "D"}},
    magicmobjlimit = 5,

    -- Options
    voice = true,
    hudtoggle = true
})

-- g for the mo, p for the player if mo is empty, insert a string for the clip and chance is for how common.
rawset(_G, "Giggles_PlayVoice", function(g, p, clip, chance)
    if not Giggles_NET.voice then return end -- Can't say anything if you're muted dummy
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

            -- Logic
            grounded = true,
			sprinting = false,
            justjumped = false,

            -- Abilities
            dash = { enabled = false, timer = 10, timerref = 10, angle = 0, aerial = false },
            groundpound = { enabled = false, canperform = false, stuntime = 5, stuntimeref = 5 },

            abilitystates = {
                -- Pure only -------------------
                handstand = { enabled = false },
                --------------------------------
                summoning = { enabled = false }
            },

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
            magicmobjspawn = { enabled = false, canperform = true, selectednum = 0 },
            magicmobjs = {
                [0] = {
                    name = "TV",
                    -- type = MT_TV,
                    amount = 5,
                    duration = 15
                },

                [1] = {
                    name = "Watch",
                    -- type = MT_WATCH,
                    amount = 5,
                    duration = 15
                },
                
                [2] = {
                    name = "Anvil",
                    -- type = MT_ANVIL,
                    amount = 5,
                    duration = 10
                },

                [3] = {
                    name = "Balloon",
                    -- type = MT_CLOWN_BALLOON,
                    amount = 5,
                    duration = -1
                },

                [4] = {
                    name = "Fireworks",
                    -- type = MT_FIREWORKS,
                    amount = 5,
                    duration = -1
                }
            }
        }
    end
    return true
end