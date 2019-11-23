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

    if memory.readwordunsigned(0x022417F4) == 46584 then
        gui.text(2,20, "battling")
        battling = true
    else 
        gui.text(2,20, "searching")
        battling = true
    end

    --0x021C5CCE - xpos
    --0x021C5CEE - ypos
    gui.text(20,140, string.format(memory.readwordunsigned(0x021C5CCE) .. " " .. string.format(memory.readwordunsigned(0x021C5CEE))))

    r,g,b = gui.getpixel(x, y)
    gui.text(180, 15, r .." ".. g .." ".. b)
    -- gui.pixel(x-1,y, 'red')

    gui.drawbox(200,0, 210,10, {r,g,b, 0xFF})
    -- print((select(1,gui.getpixel(x,y))))

    if (player.checkHealth()) then
        gui.text(5,180, "Need to Heal")
    else 
        gui.text(5,180, "Fine to Battle")
    end
end

gui.register(main) --register for graphics, input uses frameadvance51

--PLAYER MOVEMENT--

steps = 3
controls.delay(40)

while bot do 
    controls.setAllFalse()
    if memory.readwordunsigned(0x022417F4) == 46584 then --if battling
        player.battleSequence()

    else --looking for battle
        player.scramble(steps) --run around
    end
    
    emu.frameadvance()
end

controls.delay(40)

--if facing in same direction, 5 frames
--if facing perpendicular, 8 frames
--if facing opposite, 7 frames
