process("joequake-gl")

--Based on https://github.com/Loomeh/LibreSplitAutosplitters/blob/main/Quake_Enhanced_Steam.lua
--and https://github.com/kugelrund/LiveSplit.Quake
--Only works with JoeQuake (v17.8 and up, but use 18 to be sure)
--Get it here: https://github.com/matthewearl/JoeQuake-1

--Currently RTA only

local magic_signature = nil

local settings =
{
    --False for full game, true for single episodes
    episodeRun = true,
    --Do not use currently
    ignoreHub = false, --Ignore start.bsp for IGT runs
    ignoreIntermission = false -- RTA or IGT
    -- Replace both of these for a "use IGT" option?
}

--Stores addresses, do not use as values
local addresses = {
    total_time = nil,
    map_time = nil,
    game_state = nil,
    map = nil,
    counter = nil
}

local current = {
    total_time = nil,
    map_time = nil,
    --game_state 0 = playing
    --game_state 1 = intermission
    game_state = nil,
    map = nil,
    counter = nil
}

local vars =
{
--These don't get changed by the code
--Add custom level pack start and end names here
    fullGameStarts = {"start"},
    fullGameEnds = { "end", "hipend", "r2m8", "e5end", "mgend", "nend" },
    episodeStarts = { "e1m1", "e2m1", "e3m1", "e4m1", "hip1m1", "hip2m1", "hip2m3", "r1m1", "r2m1" },
    episodeEnds = { "e1m7", "e2m6", "e3m6", "e4m7", "hip1m5", "hip2m5", "hipend", "r1m7", "r2m8" },
    
    --These do get changed
    lastMap = "",
    lastVisitedMaps = {},
    startPassed = false,
    stop = false
}

function startup()
    refreshRate = 60
    mapsCacheCycles = 1
end

function state()

    print("Current")
    print_tbl(current)
    print("Vars")
    print(vars.lastMap)
    print("lastmaps")
    print_tbl(vars.lastVisitedMaps)
    
    old = shallow_copy_tbl(current)

    if magic_signature == nil then
        -- We search for the signature and point our pointer 40 units over, to the first number
        magic_signature = sig_scan("6D 61 67 69 63 20 69 64 20 66 6F 72 20 73 70 65 65 64 72 75 6E 20 64 61 74 61 20 66 6F 72 20 6C 69 76 65 73 70 6C 69 74", 40)
    else
        -- Each address in the Linux version is 8 bytes, so we'll find
        -- +0 Total time address
        -- +8 Map time address
        -- +16 Game State address
        -- +24 Map Address
        -- +32 Counter Address
        if addresses["total_time"] == nil then
            -- Read the address as an 8-byte pointer (64 bit, different from the windows ASL)
            addresses["total_time"] = readAddress("ulong", magic_signature) - getBaseAddress()
        else
            current["total_time"] = readAddress("double", addresses["total_time"])
        end
        if addresses["map_time"] == nil then
            -- Read the address as an 8-byte pointer (64 bit, different from the windows ASL)
            addresses["map_time"] = readAddress("ulong", magic_signature + 8) - getBaseAddress()
        else
            current["map_time"] = readAddress("double", addresses["map_time"])
        end
        if addresses["game_state"] == nil then
            -- Read the address as an 8-byte pointer (64 bit, different from the windows ASL)
            addresses["game_state"] = readAddress("ulong", magic_signature + 16) - getBaseAddress()
        else
            current["game_state"] = readAddress("int", addresses["game_state"])
        end
        if addresses["map"] == nil then
            -- Read the address as an 8-byte pointer (64 bit, different from the windows ASL)
            addresses["map"] = readAddress("ulong", magic_signature + 24) - getBaseAddress()
        else
            current["map"] = readAddress("string32", addresses["map"])
        end
        if addresses["counter"] == nil then
            -- Read the address as an 8-byte pointer (64 bit, different from the windows ASL)
            addresses["counter"] = readAddress("ulong", magic_signature + 32) - getBaseAddress()
        else
            -- This might be dynamically allocated, since I see some readAddress errors
            current["counter"] = readAddress("int", addresses["counter"])
        end
    end

end

function start()
    if settings.episodeRun then
        if indexOf(vars.episodeStarts, current.map) > -1 then
            vars.lastMap = current.map
            vars.lastVisitedMaps = {}
            vars.startPassed = true
            return true
        end
    end

    if indexOf(vars.fullGameStarts, current.map) > -1 then
        vars.lastMap = current.map
        vars.lastVisitedMaps = {}
        vars.startPassed = false
        return true
    end

    return false
end

function split()

    --Split on start.bsp
    if not settings.ignoreHub and not vars.startPassed and not settings.episodeRun then
        if vars.lastMap == "start" and (indexOf(vars.episodeStarts, current.map) > -1) and current.total_time == 0 then
            vars.startPassed = true
            vars.lastVisitedMaps[#vars.lastVisitedMaps + 1] = vars.lastMap .. current.map
            vars.lastMap = current.map
            return true
        end
    end

    --Check whether old.map and current.map are the same, and whether current.map exists
    if old.map ~= current.map and (current.map ~= nil and #current.map > 0) then
        if vars.lastMap ~= current.map and not contains(vars.lastVisitedMaps, vars.lastMap .. current.map) and vars.lastMap ~= "start" then
            vars.lastVisitedMaps[#vars.lastVisitedMaps + 1] = vars.lastMap .. current.map
            vars.lastMap = current.map
            return true
        end
        vars.lastMap = current.map
    end

    --End game on end.bsp intermission screen
    if (indexOf(vars.fullGameEnds, current.map) > -1) and current.game_state > 0 then
        vars.lastVisitedMaps[#vars.lastVisitedMaps + 1] = vars.lastMap .. current.map
        vars.lastMap = current.map
        vars.startPassed = false
        return true
    end
    
    --End of episode run on final map in episode intermission screen
    if settings.episodeRun then
        if (indexOf(vars.episodeEnds, current.map) > -1) and current.game_state > 0 then
            vars.lastVisitedMaps[#vars.lastVisitedMaps + 1] = vars.lastMap .. current.map
            vars.lastMap = current.map
            vars.startPassed = false
            return true
        end
    end

    return false
end

function reset()
    if settings.episodeRun then
        if current.total_time == 0 and current.map_time == 0 and (indexOf(vars.episodeStarts, current.map) > -1) then
            vars.lastVisitedMaps = {}
            vars.startPassed = true
            vars.lastMap = ""
            return true
        end
    end

    if current.total_time == 0 and current.map_time == 0 and (indexOf(vars.fullGameStarts, current.map) > -1) then
        vars.lastVisitedMaps = {}
        vars.startPassed = false
        vars.lastMap = ""
        return true
    end
end

function isLoading()
    if settings.ignoreHub and (indexOf(vars.fullGameStarts, current.map) > -1) then
        return true
    end

    if settings.ignoreIntermission and current.game_state > 0 then
        return true
    end
    
    if vars.stop then
        return true
    end
    
    return false
end

-- Helper functions
function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return -1
end

function contains(tbl, element)
    if tbl == nil then
        return false
    end
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end
