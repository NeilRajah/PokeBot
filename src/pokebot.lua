--test
--Author: Neil Balaskandarajah
--Created on: 11/04/2019
--Basic test for scripting in Desmume

local player = require "player"
local controls = require "controls"

local counter = 0
local battling = false
local bot = true

local x,y = 33,68

--GUI functions
function main()
    --red text box
    gui.text(2,10, "POKEBOT")
    
    --print if in battle
    gui.text(0, 40, memory.readwordunsigned(0x022417F4))

    if battling then
        gui.text(2,20, "battling")
        battling = true
    else 
        gui.text(2,20, "searching")
        battling = false
    end

    --0x021C5CCE - xpos
    --0x021C5CEE - ypos
    gui.text(20,140, string.format(memory.readwordunsigned(0x021C5CCE) .. " " .. string.format(memory.readwordunsigned(0x021C5CEE))))

    r,g,b = gui.getpixel(x, y)
    gui.text(180, 15, r .." ".. g .." ".. b)
    -- gui.pixel(x-1,y, 'red')

    gui.drawbox(200,0, 210,10, {r,g,b, 0xFF})
    -- print((select(1,gui.getpixel(x,y))))

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
        end
    end    
end

gui.register(main) --register for graphics, input uses frameadvance51

--PLAYER MOVEMENT--

steps = 3
controls.delay(40)

local frames = 0

while bot do 
    controls.setAllFalse()

    if memory.readwordunsigned(0x022417F4) == 46584 then --if battling
        battling = true
        -- print("battling switched to:", battling)
    else
        battling = false
        frames = frames + 1
    end

    if battling then
        frames = 0
        player.battleSequence() 

    else --looking for battle
        -- controls.delay(100)
        if player.checkHealth() == 0 then
            player.scramble(steps) --run around
        elseif player.checkHealth() == 1 then 
            -- player.healFromBag()
            if frames > 150 then
                player.flyToCenter()
                player.returnToTrainingSpot()
                frames = 0
            end
        elseif player.checkHealth() == -1 then
            if frames > 150 then
                player.flyToCenter()
                player.returnToTrainingSpot()
                frames = 0
            end
        end
    end
    
    emu.frameadvance()
end

controls.delay(40)

--if facing in same direction, 5 frames
--if facing perpendicular, 8 frames
--if facing opposite, 7 frames
