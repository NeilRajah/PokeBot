--test
--Author: Neil Balaskandarajah
--Created on: 11/04/2019
--Basic test for scripting in Desmume

j = {} --input table
-- emu.loadrom("D:\\Desktop\\Games\\Emulators\\DS\\Platinum\\3541 - Pokemon Platinum Version (US)(XenoPhobia)")
counter = 0

function main()
    --red text box
    gui.box(0,6, 45,20, "red")
    gui.text(2,10, "PokeBot")

    --detect button press
    j = joypad.get(1)
    if j.B then
        gui.text(2,20, "B Button Pressed")
    end

    --press button sequence from select button
    if j.select then 
        pressButton('d', 3)
        pressButton('r', 5)
    end

    --touch screen every 30 frames
    -- counter = counter + 1
    -- if counter == 30 then
    --     print("been 30 frames")
    --     counter = 0
    -- end
    gui.text(20,140, string.format(memory.readwordunsigned(0x2886)))
end

gui.register(main) --register for graphics, input uses frameadvance51

-- move for a number of tiles
function move(val, n, run) 
    setAllFalse()
    print("move ", val, n, run)
    if val == 'd' then --set everything else to false, only one can be true
        j.down = true
    elseif val == 'r' then
        j.right = true
    elseif val == 'l' then
        j.left = true
    elseif val == 'u' then 
        j.up = true
    end

    if run then
        j.B = true
    end

    for i = 1, 7 * n, 1 do --hold input for n frames
        joypad.set(1, j)
        emu.frameadvance()
    end
end

function setAllFalse()
    for key, value in pairs(j) do
        j[key] = false
    end
end    

function delay(num)
    print("delaying ", num)
    for i = 0, num, 1 do
        emu.frameadvance()
    end
end

steps = 2
delay(40)
-- for i = 1, 10, 1 do
--     move('r', steps, true)
--     delay(50)
--     move('l', steps, true)
--     delay(50)
-- end
move('r', 1, false)
delay(40)

--if facing in same direction, 5 frames
--if facing perpendicular, 8 frames
--if facing opposite, 7 frames
