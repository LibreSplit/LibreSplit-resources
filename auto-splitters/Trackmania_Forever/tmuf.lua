process('TmForever.exe')

--Autosplitter for TMUF on Linux
--Needs standalone install, but will run through Proton
--https://github.com/LibreSplit/LibreSplit

local currentRunTime = 0
local totalRunTime = 0
local current = { isLoading = false, playground, playerInfosBufferSize, currentPlayerInfo, raceTime, raceState }
local old = { isLoading = false, playground, playerInfosBufferSize, currentPlayerInfo, raceTime, raceState }

local counter = 0;

function startup()
    useGameTime = true
    refreshRate = 120
end

function state()
    old.isLoading = current.isLoading

    old.playground = current.playground
    old.playerInfosBufferSize = current.playerInfosBufferSize
    old.currentPlayerInfo = current.currentPlayerInfo
    old.raceTime = current.raceTime
    old.raceState = current.raceState

    current.playground = readAddress('int', 0x1580, -808, 0x454)
    current.playerInfosBufferSize = readAddress('int', 0x1580, -808, 0x12C, 0x2FC)
    current.currentPlayerInfo = readAddress('int', 0x1580, -808, 0x12C, 0x300, 0x0)
    current.raceState = readAddress('int', 0x1580, -808, 0x12C, 0x300, 0x0, 292)
    current.raceTime = readAddress('int', 0x1580, -808, 0x12C, 0x300, 0x0, 0x2B0)
end

function update()
    if current.playground == 0 and current.playerInfosBufferSize == 0 and current.currentPlayerInfo == 0 then
        current.isLoading = true
    end

    if b_and(old.raceState, 0x400) == 0 and b_and(current.raceState, 0x400) ~= 0 then
        current.isLoading = true
    end

--     if (old.raceTime < 0 and current.raceTime >= 0) then
--         local oldRaceTime = math.max(old.raceTime, 0)
--         local newRaceTime = math.max(current.raceTime, 0)
--         currentRunTime = currentRunTime + (newRaceTime - oldRaceTime)
--         current.isLoading = false
--     end


    --print("counter: ", counter)
    counter = counter + 1;
end

function isLoading()
    return current.isLoading
end

function start()

    if current.playground == 0 or current.playerInfosBufferSize == 0 or current.currentPlayerInfo == 0 or b_and(current.raceState, 0x200) == 0 then
        return false
    elseif (old.raceTime < 0 and current.raceTime >= 0) then
        currentRunTime = current.raceTime
        print("started: ", currentRunTime)
        return true
    end

    return false
end

function split()
    if current.playground == 0 and current.playerInfosBufferSize == 0 and current.currentPlayerInfo == 0 then
        return false
    end

    --Race state isn't 0
    if b_and(old.raceState, 0x400) == 0 and b_and(current.raceState, 0x400) ~= 0 then
        totalRunTime = totalRunTime + currentRunTime
        print("Split: ", totalRunTime)
        return true
    end
    
    return false
end

function gameTime()

    if current.playground == 0 or current.playerInfosBufferSize == 0 or current.currentPlayerInfo == 0 or b_and(current.raceState, 0x200) == 0 then
        return currentRunTime
    end
    
    if current.raceTime >= 0 then
        local oldRaceTime = math.max(old.raceTime, 0)
        local newRaceTime = math.max(current.raceTime, 0)
        currentRunTime = currentRunTime + (newRaceTime - oldRaceTime)
    end
    
    return currentRunTime
end
