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
local bottom = {128,178}
local switch = {110,78}
local back = {244,177}

--b value for color of full, low and empty PPs
local battleRed = {239,57,57}
local fleeBlue = {41,148,206}
local fullClr = {57,66,57}
local lowClr = {140,107,16}
local emptyClr = {148,0,33}
local switchClr = {57,156,82}

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
    if comparePixel(mid, battleRed) and not comparePixel(botRight,fleeBlue) then --is the fight button
        --wait, press the fight button, wait
        controls.delay(30)
        controls.stylusTouch(mid[1], mid[2], 10)
        controls.delay(30)

        --decide which move based on PP
        if not comparePixel(topLeft, emptyClr) then --top left slot
            controls.tapScreen(topLeft)
            print("TL")

        elseif not comparePixel(topRight, emptyClr) then --top right slot
            controls.tapScreen(topRight)
            print("TR")

        elseif not comparePixel(botLeft, emptyClr) then --bottom left slot
            controls.tapScreen(botLeft)
            print("BR")

        elseif not comparePixel(botRight, emptyClr) then --bottom right slot
            controls.tapScreen(botRight)
            print("BL")
        end --if
    
    else --not fight button
        --need to either flee or not learn new move
        if comparePixel(mid, battleRed) and comparePixel(botRight, fleeBlue) then 
            controls.tapScreen(botRight)
            controls.delay(30)
            controls.tapScreen(botRight)
            controls.delay(100)
            controls.tapScreen(mid)

        else --regular battle
            controls.mash('a', 5,5) --mash A to scroll through text faster
        end --comparePixel

    end --fightButton
end --battleSequence

--[[
    When leading Pokemon has fainted, switch to the next Pokemon and run
]]
function player.switchAndRun()
    controls.tapScreen(back) --exit to Choose a Pokemon screen
    controls.tapScreen(botRight) --last Pokemon slot
    controls.tapScreen(mid) --middle of screen
    controls.delay(250) --wait for Pokemon to come out

    controls.tapScreen(bottom) --flee
    controls.delay(360) --return to overworld
end --switchAndRun

--Poketch health color: 82,132,82
--Poketch no health color: 115,181,115
function player.checkHealth()
    local needToHeal = 0
    local health = 0

    for x = 33, 95, 1 do --check all pixels in the Poketch line
        local r,g,b = gui.getpixel(x, 68)
        if r == 82 and g == 132 and b == 82 then
            health = health + 1 --increase health points if they match
        end
    end

    if health < 16 and health > 0 then
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