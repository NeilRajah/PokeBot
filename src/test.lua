--test
--Author: Neil Balaskandarajah
--Created on: 11/04/2019
--Basic test for scripting in Desmume

local controls = require "controls"

-- emu.loadrom("D:\\Desktop\\Games\\Emulators\\DS\\Platinum\\3541 - Pokemon Platinum Version (US)(XenoPhobia)")
counter = 0
battling = false

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
end

--[[
    Repeatedly move left and right 
    steps - number of tiles to move
]]--
function scramble(steps) 
    controls.move('l', steps, true)
    controls.move('r', steps, true)
end

gui.register(main) --register for graphics, input uses frameadvance51

--PLAYER MOVEMENT--



steps = 3
controls.delay(40)


while true do 
    controls.setAllFalse()
    if memory.readwordunsigned(0x022417F4) == 46584 then --if battling
        controls.mash('a', 5, 2, j) --mash A

    else --looking for battle
        scramble(steps) --run around
    end
    
    emu.frameadvance()
end
controls.delay(40)

--if facing in same direction, 5 frames
--if facing perpendicular, 8 frames
--if facing opposite, 7 frames
