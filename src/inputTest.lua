file = io.open("return.sqnc", "w")
io.input(file)

for key, value in pairs(joypad.get(1)) do
    print(key, value)
end

-- file = io.open(filename, "w")
print("Recording will start when input starts")
recording = false

while recording == false do 
    emu.frameadvance()
    for key, value in pairs(joypad.get(1)) do
        if value == true then
            recording = true
            break
        end --if
    end --loop
end --loop
        
-- stop = ""

while recording do
    --get and print input
    local allFalse = true
    str = ""
    for key, value in pairs(joypad.get(1)) do
        if value == true then 
            str = str .. key .. " "
            allFalse = false
        end
    end

    --print for no input
    if (allFalse) then
        str = "---"
    end
    -- print(str)
    
    if joypad.get(1).select == true then
        print("select is true")
        recording = false
    end --if

    --write to file
    file:write(str .. "\n")

    emu.frameadvance()

    --exit if done recording
    if recording == false then
        file:flush()
        file:close()
        print("Recording ended")
        break
    end --if 
end --loop
