local btns = 'RLDUTSBAYXWEG'
str = ""
frames = 0

function main()
    input = joypad.get(1)

    str = ""
    for i = 1, #btns do
        local c = btns:sub(i,i)
        if c == "U" then 
            c = "up"
        end

        print(c, input[c])
        if input[c] == c then
            str = str .. c
        else
            str = str .. "."
        end
    end

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
-- io.output(file)

file:write([[-- version 1
emuVersion 91100
rerecordCount 0
romFilename 3541 - Pokemon Platinum Version (US)(XenoPhobia).nds
romChecksum 00000000
romSerial NTR-CPUE-USA
guid 84BE2329-6CE1-AED6-9052-49F1F1BBE9EB
useExtBios 0
advancedTiming 1
useExtFirmware 0
firmNickname yopyop
firmMessage DeSmuME makes you happy!
firmFavColour 10
firmBirthMonth 7
firmBirthDay 15
firmLanguage 1
rtcStartNew 2009-JAN-01 00:00:00:000]])

while true do
    file:write("|0|" .. str .. "000 000 0|\n")
    emu.frameadvance()
    if frames > 300 then
        file:flush()
        file:close()
        print("recording ended")
        break
    end
end
