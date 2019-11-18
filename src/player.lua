--player
--Author: Neil Balaskandarajah
--Created on: 11/18/2019
--All actions the player can perform 

local controls = require "controls"
local player = {}

local topLeft = {65,55}
local topRight = {194,55}
local botLeft = {65,118}
local botRight = {194,118}
local mid = {127,81}

--[[
    Repeatedly move left and right 
    steps - number of tiles to move
]]--
function player.scramble(steps) 
    controls.move('l', steps, true)
    controls.move('r', steps, true)
end

function player.battleSequence()
    --on first loop
    controls.delay(650)
    controls.stylusTouch(mid[1], mid[2], 10)
    controls.delay(10)
    controls.stylusTouch(botRight[1], botRight[2], 10)
    -- controls.delay(500)
end

return player