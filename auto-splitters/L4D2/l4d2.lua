-- Left 4 Dead 2 autosplitter for V200 version
-- Ported from the L4D2 LiveSplit ASL (WIP)
process("left4dead2.exe")

local current = {
    isLoading = false,
    hasControl = false,
    scoreboardLoading = false,
    svCheats = false
}

local old = {
    isLoading = false,
    hasControl = false,
    scoreboardLoading = false,
    svCheats = false
}

local loadCount = 0

-- VERSION 2000 OFFSETS
local offsets = {
    wl = 0x3C9988,
    gl = 0x5CC89C,
    hc = 0x68FBD4,
    sl = 0x6DB58D,
    ft = 0x6ED414,
    sv = 0x6DB040
}

local cutsceneStart = nil
local lastSplit = ""

local tickCount = 0
local ticksPerSec = 30

local function ticksToMs(t) return t * (1000 / ticksPerSec) end
local function msToTicks(ms) return math.ceil(ms * ticksPerSec / 1000) end
local cutsceneMinTicks = msToTicks(250)

function cutsceneElapsed()
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
    current.isLoading = readAddress("bool", "engine.dll", offsets.gl)
    current.hasControl = readAddress("bool", "Client.dll", offsets.hc)
    current.scoreboardLoading = readAddress("bool", "Client.dll", offsets.sl)
    current.finaleTrigger = readAddress("bool", "Client.dll", offsets.ft)
    current.svCheats = readAddress("bool", "Client.dll", offsets.sv, 0x30)

    print("map: " .. readAddress("string30", "engine.dll", offsets.wl))
    print("hc: " .. tostring(current.hasControl))
    print("game loading: " .. tostring(current.isLoading))
    print("sl: " .. tostring(current.scoreboardLoading))
    print("sv_cheats: " .. tostring(current.svCheats))
    print("finaleTrigger: " .. tostring(current.finaleTrigger))
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
    if current.finaleTrigger and not old.finaleTrigger then
        delayedReset()
        -- prevent double split
        if current.whatsLoading == lastSplit then
            return false
        end
        print("finale split")
        lastSplit = current.whatsLoading
        return true
    end

    if delayedElapsedMs() >= 200 then
        delayedReset()
        lastSplit = current.whatsLoading
        return true
    end

    if not current.finaleTrigger and not old.scoreboardLoading and current.scoreboardLoading then
        lastSplit = current.whatsLoading
        return true
    end
end

function isLoading()
    return current.isLoading
end


