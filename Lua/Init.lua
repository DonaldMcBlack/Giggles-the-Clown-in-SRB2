rawset(_G, "Giggles", {}) -- Global table for holding functions.

rawset(_G, "Giggles_NET", {
    startup = false,
    -- Gameplay Stuff
    inbossmap = false,
    playedbossintro = false,
    currentmap = nil,
    nextmap = nil,
    musiclayers = { enabled = true, canplay = true, layers = {}},
    magicmobjlimit = 5,
    magicmobjattribs = {
        anvil = { ticcer = 0, landed = false }
    },
    ringenergylevels = { 30, 60, 90 },

    -- Options
    voice = true,
    hudtoggle = true,
    debugmode = true
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

            majigpointer = {
                mobj = nil,
                forwardmove = 0,
                sidemove = 0,
                upmove = 0,
                originalyoffset = 137
            },

            hud = {
                health = { x = 0, y = 0, scale = 2*FU/4 },
                rings = {x = 186*FU, y = 5*FU, barscale = 2*FU/3, fixedscale = 2*FU/3, scale = 2*FU/3 },
                leveluptimer = 0
            },

            -- Abilities
            dash = { enabled = false, timer = 10, timerref = 10, angle = 0, aerial = false },
            groundpound = { enabled = false, canperform = false, stuntime = 5, stuntimeref = 5 },

            prevrings = 0,
            ringenergy = { points = 0, count = 0, maxcount = 3, prevmaxcount = 3},

            abilitystates = {
                -- Pure only -------------------
                handstand = false,
                --------------------------------
                summoning = false
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
            --

            -- Magicmobjs
            magicmobjspawn = { enabled = false, canperform = true, selectednum = 0 },
            magicmobjs = {
                [0] = {
                    name = "TV",
                    thingtype = MT_RING_BOX,
                    icon = "G_MAJIG_TV",
                    amount = 5,
                    duration = 15
                },

                [1] = {
                    name = "Watch",
                    thingtype = MT_BUMPER,
                    icon = "G_MAJIG_WATCH",
                    amount = 5,
                    duration = 15
                },
                
                [2] = {
                    name = "Anvil",
                    thingtype = MT_ANVIL,
                    icon = "G_MAJIG_ANVIL",
                    amount = 5,
                    duration = 10
                },

                [3] = {
                    name = "Balloon",
                    thingtype = MT_BALLOON,
                    icon = "G_MAJIG_BALLOON",
                    amount = 5,
                    duration = -1
                },

                [4] = {
                    name = "Fireworks",
                    thingtype = MT_EXPLODE,
                    icon = "G_MAJIG_ROCKET",
                    amount = 5,
                    duration = -1
                }
            },

            -- Other techincal stuff
            O_layersloaded = false
        }
    end
    return true
end