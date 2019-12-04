--player
--Author: Neil Balaskandarajah
--Created on: 11/18/2019
--All actions the player can perform 

local controls = require "controls"
local player = {}

--Coordinates for move slots 
local topLeft = {59,59} --top left move
local topRight = {187,59} --top right move
local botLeft = {59,122} --bottom left move
local botRight = {187,122} --bottom right move
local mid = {44,82} --used for fight button
local bottom = {128,178} --bottom run button
local switch = {110,78} --bottom switch button
local back = {244,177} --back arrow

--RGB color values
local battleRed = {239,57,57} --fight button red
local fleeBlue = {41,148,206} --flee button blue
local fullClr = {57,66,57} --full PP color move
local lowClr = {140,107,16} --low PP color move
local emptyClr = {148,0,33} --no PP color move
local switchClr = {57,156,82} --switch button green
local poketchHealthClr = {82,132,82} --Poketch health color
local poketchNoHealthClr = {115,181,115} --Poketch background color

--[[
    Move left and right
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
    --check if the fight button is in the middle and not the flee/learn a new move button
    if comparePixel(mid, battleRed) and not comparePixel(botRight,fleeBlue) then --just fight button, regular battle
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
        if comparePixel(mid, battleRed) and comparePixel(botRight, fleeBlue) then --flee or learn a new move
            --exit the battle
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

--[[
    Check the health of the player by checking the Poketch team app
]]
function player.checkHealth()
    local needToHeal = 0 --returns different int based on value
    local health = 0 --number of pixels

    for x = 33, 95, 1 do --check all pixels in the Poketch line
        local r,g,b = gui.getpixel(x, 68)
        if comparePixel({x,68}, poketchHealthClr) then
            health = health + 1 --increase health points if they match
        end --if
    end --loop

    if health < 16 and health > 0 then --low health, ~25% of total
        needToHeal = 1 --1 is low health
    elseif health == 0 then
        needToHeal = -1 --(-1) is fainted (revive)
    end
    return needToHeal
end --checkHealth

return player