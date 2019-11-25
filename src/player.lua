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
        controls.delay(30)
        controls.stylusTouch(mid[1], mid[2], 10)
        controls.delay(30)

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
    local needToHeal = 0
    local health = 0

    for x = 33, 95, 1 do
        local r,g,b = gui.getpixel(x, 68)
        if r == 82 and g == 132 and b == 82 then
            health = health + 1
        end
    end

    if health < 10 and health > 0 then
        needToHeal = 1
    elseif health == 0 then
        needToHeal = -1
    end
    return needToHeal
end --checkHealth

--[[
    Sequence of actions to fly to the Pokemon center
]]
function player.flyToCenter() 
    print("flying to center")
    controls.tapButton('x') --open menu
    controls.tapButton('d') --move down one menu
    controls.tapButton('a') --select Pokemon tab   
    controls.delay(85)

    controls.tapButton('a') --select Pokemon with Fly
    controls.delay(30)
    controls.tapButton('d') --down one
    controls.tapButton('a') --press Fly button
    controls.delay(90)

    controls.pressButton('l', 300) --index to left wall
    controls.pressButton('d', 300) --index to bottom wall
    controls.delay(30) 

    controls.pressButton('u', 30) --move to Canalave City
    controls.tapButton('a') --fly to city

    controls.delay(570) --long pause for fly

    controls.tapButton('x')
    controls.tapButton('u')
    controls.tapButton('x')

    print("entering center")
    player.healAtCenter()
    print("outside center")

    controls.delay(300) 

end --flyToCenter

function player.healAtCenter()
    controls.pressButton('u', 300)
    for i = 1, 55, 1 do
        controls.mash('a', 5, 10)
    end
    controls.pressButton('d', 280)
end

function player.returnToTrainingSpot()
    controls.tapButton('y')
    controls.pressButton('r', 30)
    
    -- controls.tapButton('b')
    controls.pressButton('d', 130)
    controls.pressButton('r', 360)
    controls.pressButton('d', 60)
    controls.tapButton('y')
end

--[[
    Sequence of actions to heal from bag
]]
function player.healFromBag()
    controls.tapButton('x') --open menu
    controls.tapButton('d') 
    controls.tapButton('d') --move down to bag
    controls.tapButton('a') --select Bag Tab

    controls.delay(60) --pause
    controls.pressButton('u', 60) --move to top position of menu
    controls.pressButton('u', 60) --move to top position of menu
end
return player