-- Left 4 Dead 2 autosplitter for V2000 version
-- Ported from the L4D2 LiveSplit ASL (WIP)
process("left4dead2.exe")

local settings = {
    -- DEFAULT : TRUE
    chapterSplit = true,
    scoreboardVSgameLoading = true
}

local current = {
    whatsLoading = "",
    isLoading = false,
    hasControl = false,
    scoreboardLoading = false,
    svCheats = false,
    cutscenePlaying = false
}

local old = {
    whatsLoading = "",
    isLoading = false,
    hasControl = false,
    scoreboardLoading = false,
    svCheats = false,
    cutscenePlaying = false
}

local loadCount = 0

-- VERSION 2000 OFFSETS
local offsets = {
    whatsLoading = 0x3C9988,
    gameLoading = 0x5CC89C,
    hasControl = 0x68FBD4,
    scoreboardLoad = 0x6DB58D,
    finaleTrigger = 0x6ED414,
    svCheats = 0x6DB040,
    cutscenePlaying = 0x66CEEC
}

-- More maps should be added here when more versions are supported
-- in the near future
local campaignsLastMaps = {
    c5m5_bridge = true
}
local campaignsFirstMaps = {
    c1m1_hotel        = true,
    c2m1_highway      = true,
    c3m1_plankcountry = true,
    c4m1_milltown_a   = true,
    c5m1_waterfront   = true
}

local cutsceneStart = nil
local lastSplit = ""

local tickCount = 0
local ticksPerSec = 30

local function ticksToMs(t) return t * (1000 / ticksPerSec) end
local function msToTicks(ms) return math.ceil(ms * ticksPerSec / 1000) end
local cutsceneMinTicks = msToTicks(250)

local function cutsceneElapsed()
    if cutsceneElapsed == nil then return 0 end
    return tickCount - cutsceneStart
end

local delayedSplitStart = nil
function delayedStart()
    if delayedSplitStart == nil then
        delayedSplitStart = tickCount
    end
end

local function delayedReset() delayedSplitStart = nil end
local function delayedElapsedMs()
    if delayedSplitStart == nil then return 0 end
    return ticksToMs(tickCount - delayedSplitStart)
end

function startup()
    refreshRate = 30
end

function state()
    tickCount = tickCount + 1
    old = shallow_copy_tbl(current)
    current.whatsLoading = readAddress("string30", "engine.dll", offsets.whatsLoading)
    current.isLoading = readAddress("bool", "engine.dll", offsets.gameLoading)
    current.hasControl = readAddress("bool", "Client.dll", offsets.hasControl)
    current.scoreboardLoading = readAddress("bool", "Client.dll", offsets.scoreboardLoad)
    current.finaleTrigger = readAddress("bool", "Client.dll", offsets.finaleTrigger)
    current.svCheats = readAddress("bool", "Client.dll", offsets.svCheats, 0x30)
    current.cutscenePlaying = readAddress("bool", "Client.dll", offsets.cutscenePlaying)

    print("map: " .. current.whatsLoading)
    print("hasControl: " .. tostring(current.hasControl))
    print("game loading: " .. tostring(current.isLoading))
    print("scoreboardLoad: " .. tostring(current.scoreboardLoading))
    print("sv_cheats: " .. tostring(current.svCheats))
    print("finaleTrigger: " .. tostring(current.finaleTrigger))
    print("cutscenePlaying: " .. tostring(current.cutscenePlaying))
    print("lastSplit: " .. lastSplit)
    print()
end

function update()
    if not current.isLoading and old.isLoading then
        loadCount = loadCount + 1
    end
end

function start()
    if current.hasControl and not current.isLoading then
        if cutsceneStart ~= nil and cutsceneElapsed() >= cutsceneMinTicks then
            cutsceneStart = nil
            lastSplit = ""
            return true
        elseif cutsceneStart ~= nil then
            cutsceneStart = nil
        end
    end

    if not old.hasControl and not current.hasControl
        and not current.isLoading
        and current.whatsLoading ~= ""
        and cutsceneStart == nil then
        cutsceneStart = tickCount
    end

    return false
end

function split()
    -- This relies on having Game Instructor enabled
    if current.finaleTrigger and not old.finaleTrigger then
        delayedReset()
        -- prevent double split
        if current.whatsLoading == lastSplit then
            return false
        end
        print("finale split")
        lastSplit = current.whatsLoading
        return true
    elseif current.cutscenePlaying and not old.cutscenePlaying and campaignsLastMaps[current.whatsLoading] then
        delayedStart()
        if current.whatsLoading == lastSplit then
            return false
        end
    end

    if delayedElapsedMs() >= 200 then
        delayedReset()
        lastSplit = current.whatsLoading
        return true
    end

    if settings.chapterSplit then
        if settings.scoreboardVSgameLoading then
            if not current.finaleTrigger
                and not old.scoreboardLoading and current.scoreboardLoading then
                lastSplit = current.whatsLoading
                return true
            end
        else
            if not current.finaleTrigger
                and not old.isLoading and current.isLoading
                and current.scoreboardLoading then
                lastSplit = current.whatsLoading
                return true
            end
        end
    end
end

function isLoading()
    return current.isLoading
end


