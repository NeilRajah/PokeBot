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
    if j.A then
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
end

gui.register(main) --register for graphics, input uses frameadvance

-- move for a number of tiles
function move(val, n) 

    if val == 'd' then --set everything else to false, only one can be true
        print("pressButton ", val, n)
        j.down = true
        j.right = false
        j.left = false
        j.up = false
    elseif val == 'r' then
        print("pressButton ", val, n)
        j.down = false
        j.right = true
        j.left = false
        j.up = false
    elseif val == 'l' then
        print("pressButton ", val, n)
        j.down = false
        j.right = false
        j.left = true
        j.up = false
    elseif val == 'u' then 
        print("pressButton ", val, n)
        j.down = false
        j.right = false
        j.left = false
        j.up = true
    end

    for i = 0, 15 * n, 1 do --hold input for 15 frames
        joypad.set(1, j)
        emu.frameadvance()
    end
end

move('r', 3)
move('u', 4)
move('r', 1)
move('d', 1)