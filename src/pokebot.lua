--test
--Author: Neil Balaskandarajah
--Created on: 11/04/2019
--Basic test for scripting in Desmume

local player = require "player"
local controls = require "controls"

local battling = false --whether the bot is in a battle or not
local bot = true --whether the bot should run
local checking = true --whether the bot needs to check the health of the leading Pokemon

--GUI functions
function main()
    gui.text(2,10, "POKEBOT")

    --print the mode the bot is in
    if battling then
        gui.text(2,20, "battling")
        battling = true
    else 
        gui.text(2,20, "searching")
        battling = false
    end --if

    --health indicator
    if battling == false then
        local health = player.checkHealth()
        -- print(health)
        if (health == 1) then
            gui.text(5,180, "Need to Heal")
        elseif (health == -1) then
            gui.text(5, 180, "Need to Revive")
        else
            gui.text(5,180, "Fine to Battle")
        end --if
    end --if
end --main

gui.register(main) --register for graphics, input uses frameadvance51

--PLAYER MOVEMENT--

local steps = 3 --take 3 steps when scrambling
local frames = 0 --summed to delay actions

--bot is false when auxiliary features of the script should run
while bot do 
    controls.setAllFalse()

    --check the memory address for battling
    if memory.readwordunsigned(0x022417F4) == 46584 then
        battling = true
    else
        battling = false
        frames = frames + 1 --keep track of number of frames passed since battle has ended
    end --if

    if battling then
        frames = 0
        player.battleSequence() --battle sequence

    else --looking for battle

        if player.checkHealth() == 0 then
            player.scramble(steps) --run around
            checking = false
        elseif player.checkHealth() == 1 and checking then -- low health
            if frames > 200 then --slight delay for healing when coming out of battle
                checking = false
                print("1: need to heal, playing sequence")
                controls.playSequence() --play file with healing and return sequence
            end --frames
        elseif player.checkHealth() == -1 and checking then --fainted
            if frames > 200 then
                checking = false
                print("-1: need to heal, playing sequence")
                controls.playSequence() --play file with healing and return sequence
            end --frames
        end --if
        -- player.scramble(steps)
    end --battling
    
    emu.frameadvance()
end --loop
