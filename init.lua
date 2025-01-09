freeslot("sfx_load")

dofile("Freeslots.lua")
dofile("Init.lua")
dofile("PrePost.lua")
dofile("Main.lua")
dofile("Functions.lua")
dofile("HUD.lua")
dofile("CMD.lua")

sfxinfo[sfx_load] = { false, 255, SF_NOMULTIPLESOUND }
S_StartSound(consoleplayer, sfx_load)