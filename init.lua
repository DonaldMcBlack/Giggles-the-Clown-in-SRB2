freeslot("sfx_load")

local filetree = {
    "Freeslots.lua",
    "Init.lua",
    "Libs/LIB_CustomHud-v2-1.lua",

    "PrePost.lua",
    "Main.lua",
    "Mobjs.lua",
    "Functions.lua",
    "HUD.lua",
    "CMD.lua"
}

-- Executing files easy
for k, v in ipairs(filetree) do
    dofile(v)
end

sfxinfo[sfx_load] = { false, 255, SF_NOMULTIPLESOUND }
S_StartSound(consoleplayer, sfx_load)