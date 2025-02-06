-- SPRITES -------------------------------------
freeslot("SPR_HRNG", "SPR_MJIG")

-- SOUNDS --------------------------------------
freeslot("sfx_emjmp", "sfx_emjmp2", "sfx_ptrans", "sfx_ntrans", "sfx_strans", "sfx_honk1", "sfx_silenc", "sfx_emdsh")
freeslot("sfx_land1", "sfx_land2", "sfx_land3")
freeslot("sfx_emgp1", "sfx_emgp2", "sfx_emgp3")
freeslot("sfx_mmswch")
freeslot("sfx_mjgeq", "sfx_mjguq")

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
sfxinfo[sfx_mmswch].caption = "Swap"
sfxinfo[sfx_mjgeq].caption = "Magicmajig Equipped"
sfxinfo[sfx_mjguq].caption = "Magicmajig Unequipped"

-- VOX ---------------------------------------
freeslot("sfx_givoc1", "sfx_givoc2", "sfx_givoc3", "sfx_givoc4") -- Jumps
freeslot("sfx_givoc5", "sfx_givoc6", "sfx_givoc7", "sfx_givoc8") -- Double Jumps

freeslot("sfx_giatk1", "sfx_giatk2", "sfx_giatk3") -- Attacks

freeslot("sfx_giqg1") -- Grunts or other noises
freeslot("sfx_gipai1", "sfx_gipai2", "sfx_gipai3", "sfx_gipai4") -- Pain

sfxinfo[sfx_givoc1].caption = "'Hup!'"
sfxinfo[sfx_givoc2].caption = "'Hah!'"
sfxinfo[sfx_givoc3].caption = "'Yah!'"
sfxinfo[sfx_givoc4].caption = "'Hah'"
sfxinfo[sfx_givoc5].caption = "'Yah!'"
sfxinfo[sfx_givoc6].caption = "'Aah!'"
sfxinfo[sfx_givoc7].caption = "'Yah!'"
sfxinfo[sfx_givoc8].caption = "'Hoo!'"

sfxinfo[sfx_giatk1].caption = "'Haaa!'"
sfxinfo[sfx_giatk2].caption = "'Huaaa!'"
sfxinfo[sfx_giatk3].caption = "'Yoohh!'"

sfxinfo[sfx_giqg1].caption = "'Hee!'"

sfxinfo[sfx_gipai1].caption = "'Nngh!'"
sfxinfo[sfx_gipai2].caption = "'Nuh!'"
sfxinfo[sfx_gipai3].caption = "'Aagh!'"
sfxinfo[sfx_gipai4].caption = "'Ow!'"

sfxinfo[sfx_hpup] = {
    flags = SF_NOMULTIPLESOUND|SF_X4AWAYSOUND,
    singular = false,
    caption = "Hearty Sparkle"
}

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
states[S_PLAY_STND].action = A_DoNotWait

freeslot("S_GIGGLES_DOUBLEJUMP")
states[S_GIGGLES_DOUBLEJUMP] = { 
    sprite = SPR_PLAY, 
    frame = A|FF_ANIMATE|SPR2_ROLL,
    tics =  9, 
    action = none, 
    var1 = 6, 
    var2 = 1,
    nextstate = S_PLAY_FALL
}

freeslot("S_GIGGLES_DASH")
states[S_GIGGLES_DASH] = { SPR_PLAY, SPR2_DASH, -1, nil, nil, nil, S_PLAY_FALL }

-- Magimajigs & Other Mobjs ---------
freeslot("S_HEARTRING", "S_MAJIGPNT1")

states[S_HEARTRING] = {
    sprite = SPR_HRNG,
    frame = A|FF_ANIMATE,
    tics = -1,
    action = nil,
    var1 = 23,
    var2 = 1,
    nextstate = S_HEARTRING,
}

states[S_MAJIGPNT1] = {
    sprite = SPR_MJIG,
    frame = A|FF_FULLBRIGHT,
    tics = -1,
    action = nil,
    nextstate = S_MAJIGPNT1
}

states[S_WATCH_SPAWN] = {

}

states[S_ANVIL_SPAWN] = {

}
-- MOBJS --------------------------------------
freeslot("MT_HEARTRING", "MT_PUREMAGIC", "MT_SCRAPPERMAGIC", "MT_MAJIGARROW")

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

mobjinfo[MT_MAJIGARROW] = {
    doomednum = -1,
    spawnstate = S_MAJIGPNT1,
    spawnhealth = 1000,
    seestate = S_NULL,
    reactiontime = 8,
    attacksound = 0,
    painstate = 0,
    painsound = 0,
    deathstate = S_NULL,
    speed = FU*10,
    radius = FU*5,
    height = FU*156,
    flags = MF_NOCLIP|MF_NOBLOCKMAP
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

mobjinfo[MT_DOV] = {
    doomednum = -1,
    spawnstate = S_DOV_SPAWN,
    spawnhealth = 1000,
    speed = 20*FU,
    radius = 18*FU,
    height = 16*FU,
    mass = 25,
    damage = 0,
    flags = MF_SOLID|MF_SLIDEME|MF_SPECIAL
}

mobjinfo[MT_WATCH] = {
    doomednum = -1,
    spawnstate = S_WATCH_SPAWN,
    spawnhealth = 1000,
    speed = 10*FU,
    radius = 15*FU,
    height = 15*FU,
    mass = 20,
    damage = 0,
    flags = MF_NOBLOCKMAP|MF_NOGRAVITY
}

mobjinfo[MT_ANVIL] = {
    doomednum = -1,
    spawnstate = S_ANVIL_SPAWN,
    spawnhealth = 1000,
    speed = 24*FU,
    radius = 20*FU,
    height = 15*FU,
    mass = 50,
    damage = 100,
    flags = MF_SOLID|MF_SLIDEME
}

mobjinfo[MT_PACKLOON] = {
    doomednum = -1,
    spawnstate = S_PACKLOON_SPAWN,
    spawnhealth = 1000,
    speed = 0,
    radius = 15*FU,
    height = 20*FU,
    mass = 30,
    damage = 0,
    flags = MF_NOGRAVITY
}

-- mobjinfo[MT_FIREWORKS] = {
--     doomednum = -1,
--     spawnstate = S_FIREWORKS_SPAWN,
--     spawnhealth = 1000,
--     speed = 0
-- }