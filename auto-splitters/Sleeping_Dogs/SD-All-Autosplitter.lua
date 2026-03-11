-- Autosplitter and Load Remover for Sleeping Dogs (DE + OG)
-- Works for all current categories
-- Credits to riekelt, LeoKeidran, Plasma, SneakyEvil, and everyone who tested this

local version = "DE"
local refresh = 60
local gameTime = false

if version == "OG" then
    process("HKShip.exe")
elseif version == "DE" then
    process("sdhdship.exe")
end

local old = {}
local current = {}

local vars = {
    runType = "Unknown",
    completedMissions = {},
    lastCompletedMission = "",
    completedMs = 0,
    currentRaceMs = 0,
    startedRace = false,
    activeInRace = false,
    canSplit = false,
    missionSets = {
        ["Any%"] = {
            "$SGTITLE_WELCOME_TO_HONG_KONG",
            "$SGTITLE_GOING_UNDER",
            "$SGTITLE_VENDOR_EXTORTION",
            "$SGTITLE_VENDOR_FAVOR",
            "$SGTITLE_NIGHT_MARKET_CHASE",
            "$SGTITLE_STICK_UPANDDELIVERY",
            "$SGTITLE_MINI_BUS",
            "$SGTITLE_POPSTAR_1",
            "$SGTITLE_POPSTAR_2",
            "$SGTITLE_AMANDA",
            "$SGTITLE_BAM_BAM_CLUB",
            "$SGTITLE_POPSTAR_3",
            "$SGTITLE_RACE_CASE_START",
            "$SGTITLE_PENDREWS_BUGS",
            "$SGTITLE_TIFFANYS_GUN",
            "$SGTITLE_SWEATSHOP",
            "$SGTITLE_HOTSHOT_LEAD_2",
            "$SGTITLE_UNCLE_PO",
            "$SGTITLE_BRIDE_TO_BE",
            "$SGTITLE_RACE_HOTSHOT_LEAD_3",
            "$SGTITLE_WEDDING",
            "$SGTITLE_HOTSHOT_LEAD_4",
            "$SGTITLE_THE_NEW_BOSS",
            "$SGTITLE_TOP_GLAMOUR_AMBUSH",
            "$SGTITLE_MRS_CHUS_REVENGE",
            "$SGTITLE_FINAL_KILL",
            "$SGTITLE_INITIATION",
            "$SGTITLE_JACKIE_ARRESTED",
            "$SGTITLE_HOSPITAL_SHOOTOUT",
            "$SGTITLE_IMPORTANT_VISITOR",
            "$SGTITLE_FAST_GIRLS",
            "$SGTITLE_BAD_LUCK",
            "$SGTITLE_THE_BIG_HIT",
            "$SGTITLE_THE_FUNERAL",
            "$SGTITLE_CIVIL_DISCORD",
            "$SGTITLE_BURIED_ALIVE",
            "$SGTITLE_THE_ELECTION"
        },
        ["NiNP"] = {
            "$SGTITLE_BIG_TROUBLE",
            "$SGTITLE_CHINESE_MAGIC",
            "$SGTITLE_HAPPY_CATS_ARMY",
            "$SGTITLE_CLEAN_OUT_THE_RATS",
            "$SGTITLE_REVENGE_X2",
            "$SGTITLE_GHOSTS_OF_THE_PAST"
        },
        ["YoTS"] = {
            "$SGTITLE_ENDOFTHEWORLD",
            "$SGTITLE_ILLUMINATION",
            "$SGTITLE_BOMBSCARE1",
            "$SGTITLE_BOMBSCARE2",
            "$SGTITLE_BOMBSCARE3",
            "$SGTITLE_BOMBBUS",
            "$SGTITLE_HEADOFTHESNAKE",
            "$SGTITLE_SDURIOTS",
            "$SGTITLE_SDUSHOOTER1",
            "$SGTITLE_SDUSHOOTER2",
            "$SGTITLE_SDUVANSHOOTER"
        },
        ["Wedding%"] = {
            "$SGTITLE_GOING_UNDER",
            "$SGTITLE_VENDOR_EXTORTION",
            "$SGTITLE_VENDOR_FAVOR",
            "$SGTITLE_NIGHT_MARKET_CHASE",
            "$SGTITLE_STICK_UPANDDELIVERY",
            "$SGTITLE_MINI_BUS",
            "$SGTITLE_POPSTAR_1",
            "$SGTITLE_POPSTAR_2",
            "$SGTITLE_AMANDA",
            "$SGTITLE_BAM_BAM_CLUB",
            "$SGTITLE_POPSTAR_3",
            "$SGTITLE_RACE_CASE_START",
            "$SGTITLE_PENDREWS_BUGS",
            "$SGTITLE_TIFFANYS_GUN",
            "$SGTITLE_SWEATSHOP",
            "$SGTITLE_HOTSHOT_LEAD_2",
            "$SGTITLE_UNCLE_PO",
            "$SGTITLE_BRIDE_TO_BE",
            "$SGTITLE_RACE_HOTSHOT_LEAD_3"
        }
    },
    firstMissionDetection = {
        ["$SGTITLE_WELCOME_TO_HONG_KONG"] = "Any%",
        ["$SGTITLE_BIG_TROUBLE"] = "NiNP",
        ["$SGTITLE_ENDOFTHEWORLD"] = "YoTS",
        ["$SGTITLE_GOING_UNDER"] = "Wedding%"
    },
    finalObjectives = {
        ["Any%"] = "$MISSION_BIGSMILELEE_ICE_CHIPPER",
        ["NiNP"] = "$MISSION_HC_DEFEAT_HAPPY_CAT",
        ["YoTS"] = "MISSION_CNY_EOW_ARRESTSUSPECT"
    },
    finalMissions = {
        ["Wedding%"] = "$SGTITLE_WEDDING"
    }
}

function startup()
    refreshRate = refresh
    useGameTime = gameTime
end

function start()
    if current.gamePaused and current.socialTab == 4 and current.popupPrompt and current.chosePopupOption then
        vars.runType = "Race"
        vars.completedMs = 0
        vars.currentRaceMs = 0
        vars.startedRace = false
        vars.activeInRace = false
        vars.canSplit = false
        return true
    end
    if ((current.onMainMenu or current.staticHealth == -1) and current.mainMenuSavesShown and old.mainMenuSavesShown and current.popupPrompt and current.chosePopupOption)
        or (current.gamePaused and current.confirmGame and current.readSaves and not current.pausedSavesShown) then
        vars.runType = "Unknown"
        vars.completedMissions = {}
        vars.lastCompletedMission = ""
        vars.canSplit = false
        return true
    end
end

local function in_list(list, value)
    if not list then return false end
    for i = 1, #list do
        if list[i] == value then return true end
    end
    return false
end

local function TimeToMs(mins, secs, ms)
    return mins * 60000 + secs * 1000 + ms
end

function DetectRunType(mission, cSave, oSave)
    if vars.runType ~= "Unknown" then return end
    if not cSave or (not oSave and cSave) then return end
    if not vars.firstMissionDetection[mission] then return end

    vars.runType = vars.firstMissionDetection[mission]
    vars.completedMissions = {}
    vars.lastCompletedMission = ""
    print("Detected runType: " .. vars.runType)
end

function IsValidMission(mission)
    local set = vars.missionSets[vars.runType]
    if not set then return false end
    if not in_list(set, mission) then return false end
    if in_list(vars.completedMissions, mission) then return false end
    return true
end

local function ShouldFinalSplit(currentObjective)
    local set = vars.missionSets[vars.runType]
    if not set then return false end

    if vars.finalObjectives[vars.runType] then
        return #vars.completedMissions == #set and currentObjective == vars.finalObjectives[vars.runType]
    end
    return #vars.completedMissions == #set
end

function state()
    old = shallow_copy_tbl(current)
    if version == "DE" then
        current.currentObjective = readAddress("string48", 0x02431108, 0x0)
        current.autosaveInternalName = readAddress("string32", 0x2409EE0)
        current.autosaveIconVisible = readAddress("bool", 0x02401208, 0x20)
        current.missionPassedVisible = readAddress("bool", 0x243120C)
        current.killedSmileyCat = readAddress("bool", 0x02378120, 0x30, 0x20, 0x28, 0xA30)
        current.animationChange = readAddress("bool", 0x023CE050, 0x18, 0x8, 0x10, 0x90)
        current.bigSmileLeeChipper = readAddress("bool", 0x02072EE8, 0xF9C)
        current.mainMenuSavesShown = readAddress("bool", 0x23F20B8)
        current.confirmGame = readAddress("bool", 0x023E4CA8, 0x10)
        current.gamePaused = readAddress("bool", 0x203C95C)
        current.onMainMenu = readAddress("bool", 0x242E580)
        current.loading = readAddress("bool", 0x0207B000, 0x260)
        current.chosePopupOption = readAddress("bool", 0x0249F468, 0x1E8, 0x0, 0xC0, 0x80C)
        -- Sometimes misses when loading saves ingame
        current.readSaves = readAddress("bool", 0x240A014)
        current.pausedSavesShown = readAddress("bool", 0x0235F860, 0x8, 0x6D4)
        current.staticHealth = readAddress("float", 0x2088654)
        current.inMission = readAddress("bool", 0x20234C4)
        current.popupPrompt = readAddress("bool", 0x2431090)
        current.genericFail = readAddress("bool", 0x02176418, 0x28, 0x10, 0xA64)
        current.raceStartAnim = readAddress("bool", 0x02421CB8, 0xE8, 0xF8, 0x30, 0x10, 0x30, 0x9C0)
        current.socialTab = readAddress("int", 0x024014E8, 0x2C)
        current.activeRaceMS = readAddress("int", 0x2430BF0, 0xC)
        current.activeRaceSec = readAddress("int", 0x2430BF0, 0x8)
        current.activeRaceMins = readAddress("int", 0x2430BF0, 0x4)
        current.finishedRaceMS = readAddress("int", 0x24312F0)
        current.finishedRaceSec = readAddress("int", 0x24312EC)
        current.finishedRaceMins = readAddress("int", 0x24312E8)
    elseif version == "OG" then
        current.currentObjective = readAddress("string48", 0x10F47E4, 0x0)
        current.autosaveInternalName = readAddress("string32", 0x10A12B0)
        current.autosaveIconVisible = readAddress("bool", 0x0109B908, 0x10)
        current.missionPassedVisible = readAddress("bool", 0x10F492C)
        current.killedSmileyCat = readAddress("bool", 0x010E75C8, 0x24, 0xF0, 0x10, 0x790)
        current.animationChange = readAddress("bool", 0x0109F0B4, 0x14)
        current.bigSmileLeeChipper = readAddress("bool", 0x00FF3EA4, 0xA8)
        --current.mainMenuSavesShown = readAddress("bool", 0x00AB2C3C, 0x1B8, 0xFCC)
        -- Actual address didn't resolve, using onMainMenu but has misfires for closing popups after movies
        current.mainMenuSavesShown = readAddress("bool", 0x1091B30)
        current.confirmGame = readAddress("bool", 0x010F45BC, 0x4C, 0x138, 0xF4, 0x54, 0x3D4, 0x3C, 0xA4)
        current.gamePaused = readAddress("bool", 0x10F457C)
        current.onMainMenu = readAddress("bool", 0x1091B30)
        current.loading = readAddress("bool", 0x0105B3A8)
        current.chosePopupOption = readAddress("bool", 0x011124A8, 0x38, 0x2C, 0x8, 0x28C)
        -- readSaves doesn't seem to work for loading saves in game, works most of the time on Windows so it might be a race condition
        current.readSaves = readAddress("bool", 0x10A1154)
        current.pausedSavesShown = readAddress("bool", 0x01089C5C, 0x40)
        current.staticHealth = readAddress("float", 0x1007314)
        current.inMission = readAddress("bool", 0x10A3B84)
        current.popupPrompt = readAddress("bool", 0x107A28C)
        current.genericFail = readAddress("bool", 0x10F4770)
        current.raceStartAnim = readAddress("bool", 0x0104F0B0, 0x20, 0x1C, 0x13C, 0x0, 0x10, 0x20, 0x2E0)
        current.socialTab = readAddress("int", 0x0109B8CC, 0x2C)
        current.activeRaceMS = readAddress("int", 0x010F4600, 0xC)
        current.activeRaceSec = readAddress("int", 0x010F4600, 0x8)
        current.activeRaceMins = readAddress("int", 0x010F4600, 0x4)
        current.finishedRaceMS = readAddress("int", 0x010F4600, 0xC)
        current.finishedRaceSec = readAddress("int", 0x010F4600, 0x8)
        current.finishedRaceMins = readAddress("int", 0x010F4600, 0x4)
    end
end

function update()
    if vars.runType == "Unknown" then
        if not (current.onMainMenu or current.gamePaused or current.loading) then
            DetectRunType(current.autosaveInternalName, current.autosaveIconVisible, old.autosaveIconVisible)
        end
        return
    end

    if vars.runType == "Race" then
        if not current.raceStartAnim and old.raceStartAnim then
            vars.startedRace = true
        end
        vars.activeInRace = vars.startedRace and
            (current.activeRaceMins ~= old.activeRaceMins or current.activeRaceSec ~= old.activeRaceSec or current.activeRaceMS ~= old.activeRaceMS)
        if vars.activeInRace then
            vars.currentRaceMs = TimeToMs(current.activeRaceMins, current.activeRaceSec, current.activeRaceMS)
        elseif (current.chosePopupOption and current.loading) or (current.genericFail and not old.genericFail) then
            vars.currentRaceMs = 0
        end
        if vars.startedRace and not current.inMission and old.inMission and vars.currentRaceMs > 0 then
            vars.completedMs = vars.completedMs + TimeToMs(current.finishedRaceMins, current.finishedRaceSec, current.finishedRaceMS)
            vars.currentRaceMs = 0
            vars.activeInRace = false
            vars.startedRace = false
            vars.canSplit = true
        end
        return
    end

    if not (current.onMainMenu or current.gamePaused or current.loading) then
        if ShouldFinalSplit(current.currentObjective) then
            local finalCondition = false
            if vars.finalObjectives[vars.runType] then
                if vars.runType == "Any%" then
                    finalCondition = not old.bigSmileLeeChipper and current.bigSmileLeeChipper
                elseif vars.runType == "NiNP" then
                    finalCondition = current.killedSmileyCat
                elseif vars.runType == "YoTS" then
                    finalCondition = not old.animationChange and current.animationChange
                end
            else
                local isCorrectFinalMission = vars.finalMissions[vars.runType] and old.autosaveInternalName == vars.finalMissions[vars.runType]
                finalCondition = isCorrectFinalMission and not old.missionPassedVisible and current.missionPassedVisible
            end
            if finalCondition then
                vars.canSplit = true
                return
            end
        end

        if current.autosaveIconVisible
            and old.autosaveIconVisible
            and current.autosaveInternalName
            and current.autosaveInternalName ~= ""
            and IsValidMission(current.autosaveInternalName) then
                vars.completedMissions[#vars.completedMissions + 1] = current.autosaveInternalName
                vars.lastCompletedMission = current.autosaveInternalName
                vars.canSplit = true
        end
    end
end

function split()
    if vars.canSplit then
        print("Doing split")
        vars.canSplit = false
        return true
    end
    return false
end

function isLoading()
    if vars.runType == "Race" then
        return true
    end
    return current.loading
end

function gameTime()
    if vars.runType == "Race" then
        return vars.completedMs + vars.currentRaceMs
    end
end

function reset()
    if vars.runType == "Race" then
        return vars.startedRace and not current.inMission and vars.currentRaceMs == 0
    end
end
