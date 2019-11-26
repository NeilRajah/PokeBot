local btns = 'RLDUTSBAYXWEG'
str = ""
frames = 0

function main()
    input = joypad.get(1)

    -- str = ""

    gui.text(0,20, str)

    frames = frames + 1
end

gui.register(main)

for key, value in pairs(joypad.get(1)) do
    print(key, value)
end

-- file2 = io.open("test.txt", "a")
-- io.input(file2)

file = io.open("newMovie.dsm", "w")
print("recording started")

while true do
    local allFalse = true
    str = ""
    for key, value in pairs(joypad.get(1)) do
        if value == true then 
            str = str .. key .. " "
            allFalse = false
        end
    end
    if (allFalse) then
        str = "---"
    end
    print(str)
    file:write(str .. "\n")

    emu.frameadvance()
    if frames > 300 then
        file:flush()
        file:close()
        print("recording ended")
        break
    end
end
