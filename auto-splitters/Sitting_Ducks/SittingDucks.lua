process("OVERLAY.exe")

-- User settings
local dolrt = false
local version = "auto"
-- Do not edit below this line!

local current = {
    loading = 0,
    missionComplete = 0,
    duckTimeSeconds = 0,
    duckTimeHours = 0,
    featherCount = 0,
    duckTimems = 0
}
local old = {
    loading = 0,
    missionComplete = 0,
    duckTimeSeconds = 0,
    duckTimeHours = 0,
    featherCount = 0,
    duckTimems = 0
}
local loadtime = 0

function startup()
    useGameTime = true
    if version == "auto" then
        -- I can't be checking for md5sum of exe file in the current version of Libresplit, but this works too
        -- EU version does something weird (due to nocd patch maybe?) and returns 4096
        -- if we want checking for speed fix, check if corresponding patch address is int 1015580809
        -- instant load patch is more complicated, will have to re from patcher
        local modsize = getModuleSize()
        if modsize == 1757184 then
            version = "PL"
            -- PL patch: 0xC8A36
            -- RU patch: 0xC8A16
        elseif modsize == 4096 then
            version = "EU"
            -- patch: 0xC8C46
        elseif modsize == 1753088 then
            version = "US"
            -- patch: 0xC9156
        else
            -- stop or something
            version = "unknown"
            print("Could not determine game version. Go find Tepiloxtl on Discord/sr.com and tell them")
        end
    end
    -- To check another version, uncomment these:
    -- print("modsize " .. tostring(getModuleSize()))
    -- print("patch at " .. sig_scan("89 88 88 3C", 0))
    -- print("patch val " .. readAddress("int", 0xC8A16))
end

-- This is broken for now, without this the timer jitters when load remover is in effect
-- function isLoading()
--     return current.loading
-- end

function state()
    old = shallow_copy_tbl(current)
    if version == "US" then
        current.loading = readAddress("short", 0x1D5A5C, 0x70, 0x5FC)
        current.missionComplete = readAddress("short", 0x1D5A48, 0x8, 0x268)
        current.duckTimeSeconds = readAddress("float", 0x1D5A50, 0x26DC)
        current.duckTimeHours = readAddress("float", 0x1D5A50, 0x26D8)
        current.featherCount = readAddress("int", 0x1D5A50, 0x1F54)
    elseif version == "EU" then
        current.loading = readAddress("short", 0x1D5A4C, 0x70, 0x5FC)
        current.missionComplete = readAddress("short", 0x1D5A38, 0x8, 0x268)
        current.duckTimeSeconds = readAddress("float", 0x1D5A40, 0x26DC)
        current.duckTimeHours = readAddress("float", 0x1D5A40, 0x26D8)
        current.featherCount = readAddress("int", 0x1D5A40, 0x1F54)
    elseif version == "PL" then
        current.loading = readAddress("short", 0x1D6A8C, 0x70, 0x5FC)
        current.missionComplete = readAddress("short", 0x1D6A90, 0x18, 0x9C, 0x4BC, 0x560, 0x40, 0x38, 0xE08)
        current.duckTimeSeconds = readAddress("float", 0x1D6A80, 0x26DC)
        current.duckTimeHours = readAddress("float", 0x1D6A80, 0x26D8)
        current.featherCount = readAddress("int", 0x1D6A80, 0x1F54)
    end
end

function update()
    current.duckTimems = current.duckTimeHours * 3600000 + current.duckTimeSeconds * 1000
end

function start()
    if current.duckTimeSeconds < old.duckTimeSeconds then
        return true
    end
end

function gameTime()
    if dolrt == true then
        if current.loading ~= 0 then
            loadtime = loadtime + (current.duckTimems - old.duckTimems)
        end
        timer = current.duckTimems - loadtime
        -- print(timer)
    else
        timer = current.duckTimems
    end
    return timer
end

function split()
    if current.missionComplete > old.missionComplete then
        -- print_tbl(current)
        return true
    end
end