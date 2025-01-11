-- SOUNDS --------------------------------------
freeslot("sfx_emjmp", "sfx_emjmp2", "sfx_ptrans", "sfx_ntrans", "sfx_strans", "sfx_honk1", "sfx_silenc", "sfx_emdsh")
freeslot("sfx_land1", "sfx_land2", "sfx_land3")
freeslot("sfx_emgp1", "sfx_emgp2", "sfx_emgp3")

freeslot("sfx_hpup")
sfxinfo[sfx_emjmp].caption = "Jump"
sfxinfo[sfx_emjmp2].caption = "Double Jump"
sfxinfo[sfx_silenc].caption = "/"
sfxinfo[sfx_ntrans].caption = "\x86" + "Normal." + "\x80"
sfxinfo[sfx_ptrans].caption = "\x88" + "A lighter path!" + "\x80"
sfxinfo[sfx_strans].caption = "\x8B" + "A darker path..." + "\x80"
sfxinfo[sfx_land1].caption = "Thud"
sfxinfo[sfx_land2].caption = "Thud"
sfxinfo[sfx_land3].caption = "Thud"
sfxinfo[sfx_emdsh].caption = "Whoosh"
sfxinfo[sfx_emgp1].caption = "Splat!"
sfxinfo[sfx_emgp2].caption = "Splat!"
sfxinfo[sfx_emgp3].caption = "Splat!"


-- VOX ---------------------------------------
freeslot("sfx_givoc1", "sfx_givoc2", "sfx_givoc3", "sfx_givoc4") -- Jumps
freeslot("sfx_givoc5", "sfx_givoc6", "sfx_givoc7", "sfx_givoc8") -- Double Jumps

freeslot("sfx_giatk1", "sfx_giatk2", "sfx_giatk3") -- Attacks

freeslot("sfx_giqg1") -- Grunts or other noises
freeslot("sfx_gipai1", "sfx_gipai2", "sfx_gipai3", "sfx_gipai4") -- Pain

-- STINGERS -------------------------------------
freeslot("sfx_stdark", "sfx_stliht")
freeslot("sfx_stboss")

sfxinfo[sfx_stdark].caption = "You did a bad..."
sfxinfo[sfx_stliht].caption = "You did a good!"

-- STATE ACTIONS --------------------------------
function A_DoNotWait(mo) 
    if IsGiggles(mo, mo.player) then
        mo.tics = -1
    end
end

-- STATES ---------------------------------------
freeslot("S_GIGGLES_DOUBLEJUMP")
states[S_GIGGLES_DOUBLEJUMP] = { 
    sprite = SPR_PLAY, 
    frame = A|FF_ANIMATE|SPR2_ROLL,
    tics =  9, 
    action = none, 
    var1 = 6, 
    var2 = 1,
    nextstate = S_PLAY_FALL}

freeslot("S_GIGGLES_DASH")
states[S_GIGGLES_DASH] = { SPR_PLAY, SPR2_DASH, -1, nil, nil, nil, S_PLAY_FALL }

states[S_PLAY_STND].action = A_DoNotWait

-- MOBJS --------------------------------------
freeslot("MT_HEARTRING", "MT_PUREMAGIC", "MT_SCRAPPERMAGIC")
freeslot("S_HEARTRING")
freeslot("SPR_HRNG")

states[S_HEARTRING] = {
    sprite = SPR_HRNG,
    frame = A|FF_ANIMATE,
    tics = -1,
    action = nil,
    var1 = 23,
    var2 = 1,
    nextstate = S_HEARTRING,
}

mobjinfo[MT_HEARTRING] = {
    doomednum = -1,
    spawnstate = S_HEARTRING,
    deathsound = sfx_hpup,
    deathstate = S_SPRK1,
    spawnhealth = 1000,
    reactiontime = MT_FLINGRING,
    speed = 38*FU,
    radius = 16*FU,
    height = 24*FU,
    mass = 100,
    flags = MF_SLIDEME|MF_NOGRAVITY|MF_SPECIAL|MF_NOCLIPHEIGHT
}

sfxinfo[sfx_hpup] = {
    flags = SF_NOMULTIPLESOUND|SF_X4AWAYSOUND,
    singular = false,
    caption = "Hearty Sparkle"
}

mobjinfo[MT_PUREMAGIC] = {
    doomednum = -1,
    spawnstate = S_SPRK1,
    spawnhealth = 1000,
    speed = 38*FU,
    radius = 8*FU,
    height = 8*FU,
    mass = 20,
    damage = 5,
    flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY
}

mobjinfo[MT_SCRAPPERMAGIC] = {
    doomednum = -1,
    spawnstate = S_RRNG1,
    spawnhealth = 1000,
    speed = 100*FU,
    radius = 16*FU,
    height = 24*FU,
    mass = 20,
    damage = 5,
    flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY
}

-- states[S_ANVIL_HANG] = {

-- }

-- mobjinfo[MT_ANVIL] = {
--     doomednum = -1,
--     spawnstate = S_ANVIL_HANG
-- }