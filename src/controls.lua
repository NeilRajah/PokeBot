--controls
--Author: Neil Balaskandarajah
--Created on: 11/11/2019
--A module holding all functions regarding setting controller input

local controls = {} --module
local j = {} --button input table
local s = stylus.get(0) --stylus

--[[
    Press down a button
    val - button to press down 
]]--
function setButton(val) 
    j = joypad.get(1)
    controls.setAllFalse() -- have to set all buttons to false first to prevent overlap
    --set a button based on the letter passed
    if val == 'd' then 
        j.down = true
    elseif val == 'r' then
        j.right = true
    elseif val == 'l' then
        j.left = true
    elseif val == 'u' then 
        j.up = true
    elseif val == 'a' then
        j.A = true
    elseif val == 'b' then
        j.B = true
    elseif val == 'x' then
        j.X = true
    elseif val == 'y' then
        j.Y = true
    elseif val == 'start' then
        j.start = true
    elseif val == 'select' then
        j.select = true
    elseif val == 'lbump' then
        j.L = true
    elseif val == 'rbump' then
        j.R = true
    end    
end --setButton

--[[
    Touch the bottom touch screen at a point
    x - x position of touch
    y - y position of touch
    frames - number of frames to hold the touch down
]]--
function controls.stylusTouch(x,y, frames)
    --set values to the stylus
    s.x = x
    s.y = y 
    s.touch = true

    print("stylusTouch", x,y,frames)
    --loop holding down the stylus
    for i = 0, frames, 1 do
        stylus.set(s)
        emu.frameadvance()
    end --loop
end --stylusTouch

--[[
    Tap the bottom touch screen at a point
    loc - (x,y) coordinates of point to touch
]]
function controls.tapScreen(loc)
    s.x = loc[1]
    s.y = loc[2]
    s.touch = true

    print("tapScreen", loc[1], loc[2])
    --loop holding down the stylus
    for i = 0, 10, 1 do
        stylus.set(s)
        emu.frameadvance()
    end --loop

    controls.delay(10)
end --tapScreen

--[[
    Move the player a number of tiles
    val - button to hold down
    n - number of tiles to move
    run - whether the player runs or not
]]--
function controls.move(val, n, run) 
    setButton(val)
    if run then j.B = true end

    --hold input for n frames
    for i = 1, 7 * n, 1 do 
        joypad.set(1, j)
        emu.frameadvance()
    end --loop
end --move

--[[
    Press the button for a number of frames
    val - button to hold down
    n - number of frames to press the button for
]]
function controls.pressButton(val, n)
    setButton(val)

    --hold input for n frames
    for i = 1, n, 1 do
        joypad.set(1, j)
        emu.frameadvance()
    end --loop
end --pressButton

--[[
    Tap the button
    val - button to press
]]
function controls.tapButton(val)
    setButton(val)

    --hold button for 10 frames
    for i = 1, 10, 1 do
        joypad.set(1,j)
        emu.frameadvance()
    end --loop
end --tapButton

--[[
    Mash a button 
    button - button to mash
    on - frames to hold the button for
    off - frames to release for
]]
function controls.mash(button, on, off)
        for i = 0, on+off, 1 do 
            if i < on then --hold button for the on frames
                setButton(button)    
            end --if
            
            joypad.set(1, j)
            emu.frameadvance() --move one frame ahead
        end --loop

        emu.frameadvance()
end --mash

--[[
    Set all values in the joystick table to false to prevent button overlap
]]--
function controls.setAllFalse()
    for key, value in pairs(j) do
        j[key] = false
    end --loop
end --setAllFalse

--[[
    Run the emulator without input
    num - number of frames to move forward
]]
function controls.delay(num)
    print("delaying ", num)
    for i = 0, num, 1 do
        emu.frameadvance()
    end --loop
end --delay

--[[
    Play input from a file
]]
function controls.playSequence()
    local file = io.open("return.sqnc", "r") --open the file to read from
    io.input(file) --set the file to the input
    
    local reading = true --start reading
    
    while reading do
        inputs = io.read() --read from the file
        if (inputs ~= nil) then --if there is a string
        
            --set buttons false
            for key, value in pairs(j) do 
                j[key] = false
            end --loop
    
            --set the buttons from the file to be true
            for i in string.gmatch(inputs, "%S+") do
                j[i] = true
            end --loop
    
            joypad.set(1,j)
            emu.frameadvance()
        else
            reading = false --stop the loop
        end --if   
    end --loop
end --playSequence

--[[
    Check to see if a pixel on the bottom screen is a certain color
    location - (x,y) coordinate of the pixel to check
    clr - (r,g,b) color to compare to
]]
function comparePixel(location, clr) 
    --get RGB value of pixel 
    local r,g,b = gui.getpixel(location[1], location[2])

    if r == clr[1] and g == clr[2] and b == clr[3] then
        return true
    end --if

    return false
end --comparePixel

return controls 