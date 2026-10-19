--[[
  Star Wars Episode I Racer Auto Splitter (for LibreSplit) by Wuzzmi
  https://github.com/Wuzzmi/swe1r_auto-splitter-libresplit
   - Based on Galeforce's LiveSplit Autosplitter v0.5.1
     https://github.com/everalert/swe1r-autosplitter

  FEATURES
   - Auto start when file is opened, or **optionally when "Start Race" is selected**
   - Auto split at race finish, with toggle for 1st place requirement
   - Auto reset, with choice of reset location
   - Optional run category presets
   - Choice of LRT, or IGT timing methods
   - Option to remove unfocused/tabbed-out time
  
   USING THIS SCRIPT
   - Adjust the script settings in your split file under "auto_splitter_settings"
   - Load and enable this script in LibreSplit
   - Run Star Wars Racer

    See the github README for more in depth details on each setting.
    https://github.com/Wuzzmi/swe1r_auto-splitter-libresplit
--]]

process("SWEP1RCR.EXE")

local sets = {}
local current = {
    raceTime = 0.0,
    racePos = 0,
    podFlags2 = 0,
    podFlags8 = 0,
    podHeat = 0.0,
    selTrk = 0,
    inRace = 0,
    frmCnt = 0,
    frmLen = 0.0,
    sceneId = 0,
    gameTabbedOut = 0,
    menTxt1 = ""
}
local old = shallow_copy_tbl(current)
local vars = {
    -- Auto splitter related variables
    raceDone = false,
    winCond = false,
    gt = 0,
    gtAdd = 0,
    inRace = 0,
    loadBuffer = 0,
    loadBufferSize = 0,
    loading = false
}

-- If address is nil, sets it to 0 and prints alert
local function nilGuard(value, idString)
    if value == nil then
        print( 
        idString .. " has been set to 0. Cannot use nil value.\n")
        return 0
    end
    return value
end

function define_settings()
    settings.define("autoReset", {
        name = "Auto Reset",
        type = SETTING_INTEGER,
        default = 2,
        desc = "Choose to use auto reset and where it triggers. 0 = None, 1 = File Select(risky), 2 = Main Menu, 3 = Settings(safe)"
    })

    settings.define("removeTabbedTime", {
        name = "Remove Tabbed Time",
        type = SETTING_BOOLEAN,
        default = false,
        desc = "Stops the timer while game is tabbed out/loses focus."
    })

    settings.define("require1st", {
        name = "Require 1st",
        type = SETTING_BOOLEAN,
        default = false,
        desc = "Races require a first place finish to trigger a split."
    })

    settings.define("startRaceTrig", {
        name = "Auto start at Start Race",
        type = SETTING_BOOLEAN,
        default = false,
        desc = "Timer will start when selecting Start Race instead of file select. "
    })

    settings.define("useInRaceGT", {
        name = "Use In Race Game Time",
        type = SETTING_BOOLEAN,
        default = false,
        desc = "Counts only in race game time. Load Removed Time(LRT) is used if false."
    })
end

function startup()
    sets.autoReset = settings.get("autoReset")
    sets.removeTabbedTime = settings.get("removeTabbedTime")
    sets.require1st = settings.get("require1st")
    sets.startRaceTrig = settings.get("startRaceTrig")

    refreshRate = 24 -- Starting point, will be calculated dynamically
    useGameTime = settings.get("useInRaceGT")
end

function state()
    old = shallow_copy_tbl(current)
-- Addresses that always hold a value
    current.inRace = readAddress("byte", 0xA9BB81)
    current.frmCnt = readAddress("int", 0xA22A30)
    current.frmLen = readAddress("double", 0xA22A40)
    current.sceneId = readAddress("short", 0xA9BA62)
    current.gameTabbedOut = readAddress("byte", 0x10CB64)
    -- Limit string to 17 chars, sometimes odd chars are added at the end 
    current.menTxt1 = string.sub (readAddress("string17", 0xA2C380), 1, 17)
-- Nil guarded addresses, since they don't always hold a value, fixes bitwise errors
    current.selTrk = nilGuard(readAddress("byte", 0xBFDB8, 0x5D),
    "(0) [current.selTrk]")
    current.raceTime = nilGuard(readAddress("float", 0xD78A4, 0x74),
    "(1) [current.raceTime]")
    current.racePos = nilGuard(readAddress("byte", 0xD78A4, 0x5C),
    "(2) [current.racePos]")
    current.podFlags2 = nilGuard(readAddress("byte", 0xd78a4, 0x84, 0x61),
    "(3) [current.podFlags2]")
    current.podFlags8 = nilGuard(readAddress("byte", 0xD78A4, 0x84, 0x67),
    "(4) [current.podFlags8]")
    current.podHeat = nilGuard(readAddress("float", 0xD78A4, 0x84, 0x218),
    "(5) [current.podHeat]")
end

function update()
    -- Dynamically update refresh rate based on frame time
    refreshRate = current.frmLen > 0 and math.floor(1 / current.frmLen) or 24
end

function start()
    vars.gt = 0
    vars.gtAdd = 0
    vars.inRace = 0
    vars.loadBuffer = 0
    vars.loadBufferSize = 0
    -- Auto start trigger based on sets
    if sets.startRaceTrig then
        return current.sceneId == 0 and old.sceneId == 260
    end
    return current.menTxt1 == "~F6~sBack" and old.menTxt1 == "~F6Current Player"
end

function split()
    -- Handle race finish
    vars.raceDone = ((current.podFlags8 & (1 << 1)) ~= 0) and 
    ((old.podFlags8 & (1 << 1)) == 0)
    -- Split based on win condition setting
    if sets.require1st then
        vars.winCond = current.racePos == 1
    else
        if current.selTrk == 17 or 
        current.selTrk == 8 or 
        current.selTrk == 1 then
            vars.winCond = current.racePos <= 3
        else
            vars.winCond = current.racePos <= 4
        end
    end
    return vars.raceDone and vars.winCond
end

function isLoading()
    -- Actual ingame isLoading bool unknown. Detects loading based on frame 
    -- counter with small dynamic buffer to account for framerate discrepancies
    if not useGameTime then
        vars.loadBufferSize = math.floor(old.frmLen / current.frmLen) + 2
        if current.frmCnt == old.frmCnt then
            vars.loadBuffer = vars.loadBuffer + 1
        else
            vars.loadBuffer = vars.loadBuffer - 1
        end
        if vars.loadBuffer <= 0 then
            vars.loading = false
            vars.loadBuffer = 0
        end
        if vars.loadBuffer >= vars.loadBufferSize then
            vars.loading = true
            vars.loadBuffer = vars.loadBufferSize
        end
        -- Real Time - Loads and Unfocused Time Removed
        if sets.removeTabbedTime then
            return vars.loading
        end
        -- Real Time - Loads Removed 
        return vars.loading and current.gameTabbedOut == 0
    end
    -- In Game Race Time
    return true
end

function reset()
    -- Determine auto reset trigger
    if sets.autoReset == 1 then
        return current.menTxt1 == "~F6Current Player"
    elseif sets.autoReset == 2 then
        return current.menTxt1 == "~F6~sSingle Playe"
    elseif sets.autoReset == 3 then
        return current.menTxt1 == "~F6~sVIDEO SETTIN"
    end
end

function gameTime()
    -- Entering race
    if current.inRace == 1 and old.inRace == 0 then
        vars.inRace = 1
    end
    -- Current race in-game time 
    if vars.inRace == 1 and ((current.podFlags8 & (1 << 1)) == 0) then
        vars.gtAdd = current.raceTime
    else
        vars.gtAdd = 0    
    end
    -- Race completion
    if ((current.podFlags8 & (1 << 1)) ~= 0 and 
    (old.podFlags8 & (1 << 1)) == 0) or
    (current.inRace == 0 and old.inRace == 1 and vars.inRace ~= 0) then
        vars.gt = vars.gt + current.raceTime
        vars.gtAdd = 0
        vars.inRace = 0
    end
    -- IGT in milliseconds
    return math.floor((vars.gt + vars.gtAdd) * 1000)
end

