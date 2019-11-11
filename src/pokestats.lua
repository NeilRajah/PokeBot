--Joseph Keller's Pokemon Gen4/5 PokeStats Display LUA script
--Based of a lua script by MKDasher
--Requires display 4.0.1 or higher.

require "Pokestats Gen 4 and 5 - Include"

local game = 1 -- 1 = Pearl, 2 = HeartGold, 3 = Platinum, 4 = Black, 5 = White, 6 = Black 2, 7 = White 2
local debugscreenbool = true --Weather the debug screen should be show at startup or not

------------------------------------------------------------------------------------------------------------------------

--The key to toggle if the debug display is shown
displayKey = "U" 
--The key to change weather the debug screen is shown on the top or bottom screen (Gen4/5 Only)
displayScreenKey = "Y" 
--Moves the debug screen to the next pokemon
nextPokemonKey = "T" 
-- Moves the debug screen to the previous pokemon
previousPokemonKey="R" 

------------------------------------------------------------------------------------------------------------------------

--TCP stuff
local host, port = "127.0.0.1", 54545
local socket = require("socket")
local tcp = assert(socket.tcp())
tcp:connect(host, port)
tcp:settimeout(0)
print(tcp:getpeername())

local timer_threshold = 180

local gen
local pointer
local pidAddr
local pid = 0
local trainerID, secretID, lotteryID
local shiftvalue
local checksum = 0
local mode = 1
local submode = 1
local debugsubmode = 1
local submodemax = 6
local tabl = {}
local prev = {}
local prng
--BlockA
local pokemonID = 0
local heldItem = 0
local friendship_or_steps_to_hatch
local experience = 0
--BlockB
local ivspart = {}, ivs
local isegg
local gender = 0
--BlockC
local nickname = {}
--BlockD
local pkrs
--Functions
local bnd,br,bxr=bit.band,bit.bor,bit.bxor
local rshift, lshift=bit.rshift, bit.lshift
local mdword=memory.readdwordunsigned
local mword=memory.readwordunsigned
local mbyte=memory.readbyteunsigned
--currentStats
local level, hpstat, maxhpstat
local isShiny = 0
--offsets
local BlockAoff, BlockBoff, BlockCoff, BlockDoff

--local file=io.open(textoutputpath, "w")
--local filecheck=io.read("*all")

timer = 0

local function isempty(s)
  return s == nil or s == ''
end

BlockA = {1,1,1,1,1,1, 2,2,3,4,3,4, 2,2,3,4,3,4, 2,2,3,4,3,4}
BlockB = {2,2,3,4,3,4, 1,1,1,1,1,1, 3,4,2,2,4,3, 3,4,2,2,4,3}
BlockC = {3,4,2,2,4,3, 3,4,2,2,4,3, 1,1,1,1,1,1, 4,3,4,3,2,2}
BlockD = {4,3,4,3,2,2, 4,3,4,3,2,2, 4,3,4,3,2,2, 1,1,1,1,1,1}


local xfix = 10
local yfix = 10
function displaybox(a,b,c,d,e,f)
	gui.box(a+xfix,b+yfix,c+xfix,d+yfix,e,f)
end

function display(a,b,c,d)
	gui.text(xfix+a,yfix+b,c, d)
end

function mult32(a,b)
	local c=rshift(a,16)
	local d=a%0x10000
	local e=rshift(b,16)
	local f=b%0x10000
	local g=(c*f+d*e)%0x10000
	local h=d*f
	local i=g*0x10000+h
	return i
end

function getbits(a,b,d)
	return rshift(a,b)%lshift(1,d)
end

function gettop(a)
	return(rshift(a,16))
end

function getGen()
	if game < 4 then
		return 4
	else
		return 5
	end
end

function getGameName()
	if game == 1 then
		return "Pearl"
	elseif game == 2 then
		return "HeartGold"
	elseif game == 3 then
		return "Platinum"
	elseif game == 4 then
		return "Black"
	elseif game == 5 then
		return "White"
	elseif game == 6 then
		return "Black 2"
	else--if game == 7 then
		return "White 2"
	end
end

function getPointer()
	if game == 1 then
		return memory.readdword(0x02106FAC)
	elseif game == 2 then
		return memory.readdword(0x0211186C)
	else -- game == 3
		return memory.readdword(0x02101D2C)
	end
	-- haven't found pointers for BW/B2W2, probably not needed anyway.
end

function getPidAddr()
	if game == 1 then --Pearl
		enemyAddr = pointer + 0x364C8
		if mode == 5 then
			return pointer + 0x36C6C
		elseif mode == 4 then
			return memory.readdword(enemyAddr) + 0x774 + 0x5B0 + 0xEC*(submode-1)
		elseif mode == 3 then
			return memory.readdword(enemyAddr) + 0x774 + 0xB60 + 0xEC*(submode-1)
		elseif mode == 2 then
			return memory.readdword(enemyAddr) + 0x774 + 0xEC*(submode-1)
		else
			return pointer + 0xD2AC + 0xEC*(submode-1)
		end
	elseif game == 2 then --HeartGold
		enemyAddr = pointer + 0x37970
		if mode == 5 then
			return pointer + 0x38540
		elseif mode == 4 then
			return memory.readdword(enemyAddr) + 0x1C70 + 0xA1C + 0xEC*(submode-1)	
		elseif mode == 3 then
			return memory.readdword(enemyAddr) + 0x1C70 + 0x1438 + 0xEC*(submode-1)
		elseif mode == 2 then
			return memory.readdword(enemyAddr) + 0x1C70 + 0xEC*(submode-1)
		else
			return pointer + 0xD088 + 0xEC*(submode-1)
		end
	elseif game == 3 then --Platinum
		enemyAddr = pointer + 0x352F4
		if mode == 5 then
			return pointer + 0x35AC4
		elseif mode == 4 then
			return memory.readdword(enemyAddr) + 0x7A0 + 0x5B0 + 0xEC*(submode-1)
		elseif mode == 3 then
			return memory.readdword(enemyAddr) + 0x7A0 + 0xB60 + 0xEC*(submode-1) 
		elseif mode == 2 then
			return memory.readdword(enemyAddr) + 0x7A0 + 0xEC*(submode-1) 
		else
			return pointer + 0xD094 + 0xEC*(submode-1)
		end
	elseif game == 4 then --Black
		if mode == 5 then
			return 0x02259DD8
		elseif mode == 4 then
			return 0x0226B7B4 + 0xDC*(submode-1)
		elseif mode == 3 then
			return 0x0226C274 + 0xDC*(submode-1)
		elseif mode == 2 then
			return 0x0226ACF4 + 0xDC*(submode-1)
		else -- mode 1
			return 0x022349B4 + 0xDC*(submode-1) 
		end
	elseif game == 5 then --White
		if mode == 5 then
			return 0x02259DF8
		elseif mode == 4 then
			return 0x0226B7D4 + 0xDC*(submode-1)
		elseif mode == 3 then
			return 0x0226C294 + 0xDC*(submode-1)	
		elseif mode == 2 then
			return 0x0226AD14 + 0xDC*(submode-1)
		else -- mode 1
			return 0x022349D4 + 0xDC*(submode-1) 
		end
	elseif game == 6 then --Black 2
		if mode == 5 then
			return 0x0224795C
		elseif mode == 4 then
			return 0x022592F4 + 0xDC*(submode-1)
		elseif mode == 3 then
			return 0x02259DB4 + 0xDC*(submode-1)			
		elseif mode == 2 then
			return 0x02258834 + 0xDC*(submode-1)
		else -- mode 1
			return 0x0221E3EC + 0xDC*(submode-1)
		end
	else --White 2
		if mode == 5 then
			return 0x0224799C
		elseif mode == 4 then
			return 0x02259334 + 0xDC*(submode-1)
		elseif mode == 3 then
			return 0x02259DF4 + 0xDC*(submode-1)
		elseif mode == 2 then
			return 0x02258874 + 0xDC*(submode-1)
		else -- mode 1
			return 0x0221E42C + 0xDC*(submode-1)
		end
	end
end

function read_adressess()
    gen = getGen()
	pointer = getPointer()
	pidAddr = getPidAddr()
	pid = memory.readdword(pidAddr)
    checksum = memory.readword(pidAddr + 6)
	shiftvalue = (rshift((bnd(pid,0x3E000)),0xD)) % 24
    
    BlockAoff = (BlockA[shiftvalue + 1] - 1) * 32
	BlockBoff = (BlockB[shiftvalue + 1] - 1) * 32
	BlockCoff = (BlockC[shiftvalue + 1] - 1) * 32
	BlockDoff = (BlockD[shiftvalue + 1] - 1) * 32
    
    -- Block A
	prng = checksum
	for i = 1, BlockA[shiftvalue + 1] - 1 do
		prng = mult32(prng,0x5F748241) + 0xCBA72510 -- 16 cycles
	end
	
	prng = mult32(prng,0x41C64E6D) + 0x6073
	pokemonID = bxr(memory.readword(pidAddr + BlockAoff + 8), gettop(prng))
	if gen == 4 and pokemonID > 494 then --just to make sure pokemonID is right (gen 4)
		pokemonID = -1 -- (pokemonID = -1 indicates invalid data)
	elseif gen == 5 and pokemonID > 651 then -- gen5
		pokemonID = -1 -- (pokemonID = -1 indicates invalid data)
	end
	
	prng = mult32(prng,0x41C64E6D) + 0x6073
	heldItem = bxr(memory.readword(pidAddr + BlockAoff + 2 + 8), gettop(prng))
	if gen == 4 and heldItem > 537 then -- Gen 4
		pokemonID = -1 -- (pokemonID = -1 indicates invalid data)
	elseif gen == 5 and heldItem > 639 then -- Gen 5
		pokemonID = -1 -- (pokemonID = -1 indicates invalid data)
	end
	
    prng = mult32(prng,0x41C64E6D) + 0x6073
    prng = mult32(prng,0x41C64E6D) + 0x6073
	prng = mult32(prng,0x41C64E6D) + 0x6073
    experience = bxr(memory.readword(pidAddr + BlockAoff + 8 + 8), gettop(prng))
	prng = mult32(prng,0x41C64E6D) + 0x6073
	prng = mult32(prng,0x41C64E6D) + 0x6073
	ability = bxr(memory.readword(pidAddr + BlockAoff + 12 + 8), gettop(prng))
	friendship_or_steps_to_hatch = getbits(ability, 0, 8)
	ability = getbits(ability, 8, 8)
	if gen == 4 and ability > 123 then
		pokemonID = -1 -- (pokemonID = -1 indicates invalid data)
	elseif gen == 5 and ability > 164 then
		pokemonID = -1
	end
    
    -- Block B
	prng = checksum
	for i = 1, BlockB[shiftvalue + 1] - 1 do
		prng = mult32(prng,0x5F748241) + 0xCBA72510 -- 16 cycles
	end
    
    prng = mult32(prng,0x41C64E6D) + 0x6073
    prng = mult32(prng,0x41C64E6D) + 0x6073
    prng = mult32(prng,0x41C64E6D) + 0x6073
    prng = mult32(prng,0x41C64E6D) + 0x6073
    prng = mult32(prng,0x41C64E6D) + 0x6073
    prng = mult32(prng,0x41C64E6D) + 0x6073
    prng = mult32(prng,0x41C64E6D) + 0x6073
	prng = mult32(prng,0x41C64E6D) + 0x6073
	
	prng = mult32(prng,0x41C64E6D) + 0x6073
	ivspart[1] = bxr(memory.readword(pidAddr + BlockBoff + 16 + 8), gettop(prng))
	prng = mult32(prng,0x41C64E6D) + 0x6073
	ivspart[2] = bxr(memory.readword(pidAddr + BlockBoff + 18 + 8), gettop(prng))
	ivs = ivspart[1]  + lshift(ivspart[2],16)
	isegg = getbits(ivs,30,1)
    
    prng = mult32(prng,0x41C64E6D) + 0x6073
    prng = mult32(prng,0x41C64E6D) + 0x6073
    prng = mult32(prng,0x41C64E6D) + 0x6073
    
    local genderByte = bxr(memory.readword(pidAddr + BlockBoff + 24 + 8), gettop(prng))
    local isGenderless = getbits(genderByte,2,3)
    local genderStatus = getbits(genderByte,1,2)
    
    gender = genderStatus + 1
    
    
    -- Block C
	prng = checksum
	for i = 1, BlockC[shiftvalue + 1] - 1 do
		prng = mult32(prng,0x5F748241) + 0xCBA72510 -- 16 cycles
	end
    prng = mult32(prng,0x41C64E6D) + 0x6073
    for i = 0, 11 do
        nickname[i+1] = bxr(memory.readword(pidAddr + BlockCoff + (i*2) + 8), gettop(prng))
        prng = mult32(prng,0x41C64E6D) + 0x6073
    end
    
    -- Block D
	prng = checksum
	for i = 1, BlockD[shiftvalue + 1] - 1 do
		prng = mult32(prng,0x5F748241) + 0xCBA72510 -- 16 cycles
	end
	
	prng = mult32(prng,0xCFDDDF21) + 0x67DBB608 -- 8 cycles
	prng = mult32(prng,0xEE067F11) + 0x31B0DDE4 -- 4 cycles
	prng = mult32(prng,0x41C64E6D) + 0x6073
	prng = mult32(prng,0x41C64E6D) + 0x6073
	pkrs = bxr(memory.readword(pidAddr + BlockDoff + 0x1A + 8), gettop(prng))
	pkrs = getbits(pkrs,0,8)
	
	-- Current stats
	prng = pid
    prng = mult32(prng,0x41C64E6D) + 0x6073
    statusConditions = getbits(bxr(memory.readbyte(pidAddr + 0x88), gettop(prng)),0,8)
	prng = mult32(prng,0x41C64E6D) + 0x6073
	prng = mult32(prng,0x41C64E6D) + 0x6073
	level = getbits(bxr(memory.readword(pidAddr + 0x8C), gettop(prng)),0,8)
	prng = mult32(prng,0x41C64E6D) + 0x6073
	hpstat = bxr(memory.readword(pidAddr + 0x8E), gettop(prng))
	prng = mult32(prng,0x41C64E6D) + 0x6073
	maxhpstat = bxr(memory.readword(pidAddr + 0x90), gettop(prng))
end

function debugScreen()
    submode = debugsubmode
    -- Display data
	displaybox(-5,-5,240,175,"#000000A0", "white")
    display(5,0,"dude22072's PokeStats Script (DEBUG)","white")
	display(180,10, getGameName(), "#FF88FFFF")
    display(0,15,"Slot:","White")
    display(80,15,submode,"White")
	if pokemonID == -1 then
		display(55,30, "Invalid Pokemon Data", "red")
	else
		if isegg == 1 then
			display(0,25, "Pokemon: " .. pokemon[pokemonID + 1] .. " egg", "yellow")
		else
			display(0,25, "Pokemon: " .. pokemon[pokemonID + 1], "yellow")
		end
        display(0,35,"Nickname: ", "yellow")
        local stringTerminated = false
        for i = 1,12 do
            if stringTerminated == false then
                if nickname[i] ~= 0xffff then
                     if gen == 4 then
                                display(50 + (i*5),35,poketext4[nickname[i]], "yellow")
                            else 
                                display(55,35,pokemon[pokemonID + 1], "yellow") --Just the pokemon's species, because I dont have a gen 5 unicode table yet.
                            end 
                else
                    stringTerminated = true
                end
            end
        end
        
		display(0,45, "PID : " .. bit.tohex(pid), "magenta")
		display(0,55, "Item: ", "white")
        display(80,55,heldItem,"white")
		display(0,65, "Level: ", "green")
        display(80,65, level, "green")
        display(0,75, "HP: ", "green")
        
        if hpstat > 0 then
            if maxhpstat >= 100 then
                if hpstat >= 100 then
                    display(44,75, hpstat.."/"..maxhpstat, "green")
                else 
                    if hpstat >= 10 then
                        display(50,75, hpstat.."/"..maxhpstat, "green")
                    else
                        display(56,75, hpstat.."/"..maxhpstat, "green")
                    end
                end
            else 
                if maxhpstat >= 10 then
                    if hpstat >= 10 then
                        display(56,75, hpstat.."/"..maxhpstat, "green")
                    else
                        display(62,75, hpstat.."/"..maxhpstat, "green")
                    end
                else
                    display(68,75, hpstat.."/"..maxhpstat, "green")
                end
            end
        else
            if maxhpstat >= 100 then
                display(56,65, hpstat.."/"..maxhpstat, "red")
            else
                if maxhpstat >= 10 then
                    display(62,75, hpstat.."/"..maxhpstat, "red")
                else
                    display(68,75, hpstat.."/"..maxhpstat, "red")
                end
            end
        end
        
        display(0,85, "EXP:", "blue")
        display(25,85,experience,"blue")
        
		if pkrs == 0 then
			display(0,95, "PKRS:       no", "red")
		else
			display(0,95, "PKRS: yes (" .. pkrs .. ")", "red")
		end
		if isegg == 0 then
			display(0,105, "Friendship: " .. friendship_or_steps_to_hatch, "orange")
		else
			display(0,105, "Steps to hatch: ", "orange")
			display(0,115, friendship_or_steps_to_hatch * 256 .. "-" .. (friendship_or_steps_to_hatch + 1) * 256 .. " steps", "orange")
		end
        display(110,25, "Gender:", "green")
        if gender == 0 then
            display(155,25, "Genderless", "green")
        elseif gender == 1 then
            display(155,25, "Male", "blue")
        elseif gender == 2 then
            display(155,25, "Female", "red")
        end
        display(110,45,"STATUS:", "white")
        display(155,45,statusConditions,"white")
        
	end
    
    --Controls
    display(0,130,previousPokemonKey.."/"..nextPokemonKey..": Change Pokemon","orange")
    display(0,140,displayScreenKey..": Change Displays", "orange")
    display(0,150,displayKey..": Show/Hide Display","orange")
    --[[display(0,160,textOutputKey..": Enable/Disable Text Output","orange")
    
    if textoutputbool ~= 0 then
        display(185,160,"(Enabled)","green")
    else 
        display(180,160,"(Disabled)","red")
    end]]
end

function menu()
	tabl = input.get()
    if tabl[displayKey] and not prev[displayKey] then
        if debugscreenbool == 0 then
            debugscreenbool = 1
        else
            debugscreenbool = 0
        end
    end
	if tabl[previousPokemonKey] and not prev[previousPokemonKey] and mode < 5 then
		debugsubmode = debugsubmode - 1
		if debugsubmode == 0 then
			debugsubmode = submodemax
		end
	end
	if tabl[nextPokemonKey] and not prev[nextPokemonKey] and mode < 5 then
		debugsubmode = debugsubmode + 1
		if debugsubmode == submodemax + 1 then
			debugsubmode = 1
		end
	end
	if tabl[displayScreenKey] and not prev[displayScreenKey] then
		if yfix == 10 then
			yfix = -185
		else
			yfix = 10
		end
	end
    
    if tabl[textOutputKey] and not prev[textOutputKey] then
		if textoutputbool == 0 then
            textoutputbool = 1
        else
            textoutputbool = 0
        end
	end
	prev = tabl
end

function do_pokestats()
    menu()
    --if textoutputbool ~= 0 then
    
    timer = timer + 1
    if timer >= timer_threshold then
    
    
    local stringToSend = "POKESTATS:"
    --File Output
        --if filecheck~=file then
            for i=1,6 do
                submode = i
                read_adressess()
                if level > 100 then
                    return
                end
                if hpstat > maxhpstat then
                    return
                end
            end
            --file:close()
            --file=io.open(textoutputpath, "w+")
            --file:close()
            --file=io.open(textoutputpath, "w")
            
            for i=1, 6 do
                submode = i
                read_adressess()
                if gen == 4 then maxpokemon = 496 else maxpokemon = 649 end
                if pokemonID ~= nil and (pokemonID >= 1 and pokemonID <= maxpokemon) then
                 stringToSend = stringToSend..(pokemon[pokemonID + 1]..":")
                local stringTerminated = false
                for i = 1,12 do
                    if stringTerminated == false then
                        if nickname[i] ~= 0xffff and nickname[i] ~= nil and (poketext4[nickname[i]] ~= nil) then
                            if gen == 4 then
                                 stringToSend = stringToSend..(poketext4[nickname[i]])
                            else 
                                 stringToSend = stringToSend..(pokemon[pokemonID + 1]) --Just the pokemon's species, because I dont have a gen 5 unicode table yet.
                            end 
                        else
                            stringTerminated = true
                        end
                    end
                    
                end
                 stringToSend = stringToSend..(":"..
                    hpstat..":"..
                    maxhpstat..":"..
                    level..":"..
                    statusConditions..":"..--team[i].status..":"..
                    pkrs..":"..
                    heldItem..":"..
                        experience..":")
                
                else
                 stringToSend = stringToSend..("None:None")
                     stringToSend = stringToSend..(":"..
                        "0" ..":"..
                        "0" ..":"..
                        "0" ..":"..
                        "0" ..":"..
                        "0"..":"..
                        "0"..":"..
                            "0"..":")
                end
            end
                 --("POKESTATS 3.0.0 STUFF\n")
                 stringToSend = stringToSend..("NOBATTLE")
                for i=1,6 do
                    submode = i
                    read_adressess()
                     stringToSend = stringToSend..(":"..gender)
                end
                for i=1,6 do
                     stringToSend = stringToSend..(":"..isShiny)
                end
            --file:flush()
        --end
        
        stringToSend = stringToSend.."\n"
            tcp:send(stringToSend)
    timer = 0
    end
    --end
    if debugscreenbool ~= 0 then
        submode = debugsubmode
        read_adressess()
        debugScreen()
    end
end

gui.register(do_pokestats)
