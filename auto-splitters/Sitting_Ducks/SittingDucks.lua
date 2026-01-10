process("OVERLAY.exe")

-- User settings
local dolrt = true
local version = "PL"
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
end

function isLoading()
    return true
end

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
    -- print(current.duckTimems)
    -- print(current.duckTimeSeconds)
    -- print("return false")
end

function start()
    if current.duckTimeSeconds < old.duckTimeSeconds then
        -- print("The thing")
        return true
    end
end

function gameTime()
    if dolrt == true then
        if current.loading ~= 0 then
            loadtime = loadtime + (current.duckTimems - old.duckTimems)
        end
        print(current.duckTimems - loadtime)
        return current.duckTimems - loadtime
    else
        return current.duckTimems
    end
end

function split()
    if current.missionComplete > old.missionComplete then
        return true
    end
    return false
end