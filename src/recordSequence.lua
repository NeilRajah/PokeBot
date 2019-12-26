--recordSequence
--Author: Neil Balaskandarajah
--Created on: 25/11/2019
--Record a sequence of actions to a file to be played later

file = io.open("return.sqnc", "w") --open a file in write mode
io.input(file) --set the file to be the input

print("Recording will start when input starts")
print("Press the select button to end recording")
recording = false

--Start recording input when the user presses a button to beigin
while recording == false do 
    emu.frameadvance()
    --loop through all buttons to see if one is true
    for key, value in pairs(joypad.get(1)) do
        if value == true then 
            recording = true --start recording
            break --break out
        end --if
    end --loop
end --loop

--Main recording loop
while recording do
    local allFalse = true --check if nothing has been input
    str = ""
    
    --loop through all the keys
    for key, value in pairs(joypad.get(1)) do
        if value == true then 
            --appendd the key of the button pressed to the string
            str = str .. key .. " " 
            allFalse = false
        end --if
    end --loop

    if (allFalse) then --if no buttons were pressed
        str = "---"
    end
    
    --stop recording if select button is pressed
    if joypad.get(1).select == true then
        recording = false
    end --if

    --write the buttons pressed to the file
    file:write(str .. "\n")

    emu.frameadvance() --step forward one frame

    --exit if done recording
    if recording == false then
        --close the file and end the program
        file:flush()
        file:close()
        print("Recording ended")
        break
    end --if
end --loop