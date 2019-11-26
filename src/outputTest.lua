require "controls"

file = io.open("newMovie.dsm", "r")
io.input(file)

j = joypad.get(1)

while true do
    inputs = io.read()
    if (inputs ~= nil) then
        -- print(inputs)
    
        for key, value in pairs(j) do
            j[key] = false
        end --loop

        for i in string.gmatch(inputs, "%S+") do
            print(i)
            j[i] = true
        end
    end

    joypad.set(1,j)
    emu.frameadvance()
end