--player
--Author: Neil Balaskandarajah
--Created on: 11/18/2019
--All actions the player can perform 

local controls = require "controls"
local player = {}

--coordinates for move slots 
local topLeft = {59,59}
local topRight = {187,59}
local botLeft = {59,122}
local botRight = {187,122}
local mid = {44,82}

--b value for color of full, low and empty PPs
local full = 57
local low = 140
local empty = 148

--[[
    Repeatedly move left and right 
    steps - number of tiles to move
]]--
function player.scramble(steps) 
    controls.move('l', steps, true)
    controls.move('r', steps, true)
end --scramble

--[[
    The main flow for when the trainer is in a battle
]]
function player.battleSequence()
    if ((select(3, gui.getpixel(mid[1], mid[2]))) == 57) then --is the fight button
        --wait, press the fight button, wait
        controls.delay(60)
        controls.stylusTouch(mid[1], mid[2], 10)
        controls.delay(60)

        --decide which move based on pp
        if ((select(1, gui.getpixel(topLeft[1], topLeft[2]))) ~= empty) then --top left slot
            controls.stylusTouch(topLeft[1], topLeft[2], 10)
            print("TL")

        elseif ((select(1, gui.getpixel(topRight[1], topRight[2]))) ~= empty) then --top right slot
            controls.stylusTouch(topRight[1], topRight[2], 10)
            print("TR")

        elseif ((select(1, gui.getpixel(botRight[1], botRight[2]))) ~= empty) then --bottom right slot
            controls.stylusTouch(botRight[1], botRight[2], 10)
            print("BR")

        elseif ((select(1, gui.getpixel(botLeft[1], botLeft[2]))) ~= empty) then --bottom left slot
            controls.stylusTouch(botLeft[1], botLeft[2], 10)
            print("BL")

        else --run away, switch, etc.
            print("bruh")
            -- gui.text(160, 10, "wtf")
        end
    
    elseif ((select(3, gui.getpixel(mid[1], mid[2]))) == 214) then --not fight button
        --mash A to scroll through text faster
        controls.mash('a', 5, 5)
    end
end --battleSequence

--fight button color: 239 57 57
--Poketch gray: 49 49 49
--no PP: 148 0 33
--low PP: 140 107 16 
--regular PP: 57 66 57

--Poketch health color: 82,132,82
--Poketch no health color: 115,181,115
function player.checkHealth()
    local needToHeal = false
    local health = 0

    for x = 33, 95, 1 do
        local r,g,b = gui.getpixel(x, 68)
        if r == 82 and g == 132 and b == 82 then
        health = health + 1
        end
    end

    if health < 16 then
        needToHeal = true
    end
    return needToHeal
end

return player