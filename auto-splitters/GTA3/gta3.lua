-- GTA3 Autosplitter for Libresplit
-- Original code by: zoton2, iguaan, hoxi
-- Libresplit lua port: Tepiloxtl
process("gta3.exe")
local enable = {}

-- ==== Autosplitter configuration====
-- Version: currently only supporting Steam
-- local version = "Steam"
-- Split after every mission, comment out entry in missionList to disable splitting on that particular mission
enable.missions = true

-- Split once you lose control on The Exchange
enable.anyfinalsplit = false

-- Split once you reach 100% game completion
enable.hundofinalsplit = false

-- USJ autosplitter, values: false, "each", "all"
enable.usjs = false

-- Packages autosplitter, values: false, "each", "all"
enable.packages = false

-- Rampages autosplitter, values: false, "each", "all"
enable.rampages = false
-- ==== Autosplitter configuration ends ====

local current = {}
local old = {}
if enable.missions == true then
    missionList = {
        {addr = 0x35B75C, label = "Luigi's Girls"},
        {addr = 0x35B76C, label = "Don't Spank Ma Bitch Up"},
        {addr = 0x35B770, label = "Drive Misty For Me"},
        {addr = 0x35B80C, label = "The Crook"},
        {addr = 0x35B810, label = "The Thieves"},
        {addr = 0x35B814, label = "The Wife"},
        {addr = 0x35B818, label = "Her Lover"},
        {addr = 0x35B780, label = "Mike Lips Last Lunch"},
        {addr = 0x35B784, label = "Farewell 'Chunky' Lee Chong"},
        {addr = 0x35B788, label = "Van Heist"},
        {addr = 0x35B78C, label = "Cipriani's Chauffeur"},
        {addr = 0x35B79C, label = "Taking Out the Laundry"},
        {addr = 0x35B790, label = "Dead Skunk in the Trunk"},
        {addr = 0x35B838, label = "Turismo"},
        {addr = 0x35B794, label = "The Getaway"},
        {addr = 0x35B7A0, label = "The Pick-Up"},
        {addr = 0x35B970, label = "Patriot Playground"},
        {addr = 0x35B7A4, label = "Salvatore's Called a Meeting"},
        {addr = 0x35B7B4, label = "Chaperone"},
        {addr = 0x35B7B8, label = "Cutting the Grass"},
        {addr = 0x35B7A8, label = "Triads and Tribulations"},
        {addr = 0x35B774, label = "Pump-Action Pimp"},
        {addr = 0x35B9EC, label = "Diablo Destruction"},
        {addr = 0x35B778, label = "The Fuzz Ball"},
        {addr = 0x35B7E4, label = "I Scream, You Scream"},
        {addr = 0x35B7E8, label = "Trial By Fire"},
        {addr = 0x35B7EC, label = "Big'N'Veiny"},
        {addr = 0x35B9F0, label = "Mafia Massacre"},
        {addr = 0x35B7AC, label = "Blow Fish"},
        {addr = 0x35B7BC, label = "Bomb Da Base: Act I"},
        {addr = 0x35B7C0, label = "Bomb Da Base: Act II"},
        {addr = 0x35B7C4, label = "Last Requests"},
        {addr = 0x35B878, label = "Sayonara Salvatore"},
        {addr = 0x35B8D4, label = "Bling-Bling Scramble"},
        {addr = 0x35B87C, label = "Under Surveillance"},
        {addr = 0x35B8AC, label = "Kanbu Bust-Out"},
        {addr = 0x35B9F8, label = "Casino Calamity"},
        {addr = 0x35B8B0, label = "Grand Theft Auto"},
        {addr = 0x35B8D8, label = "Uzi Rider"},
        {addr = 0x35B97C, label = "Multistorey Mayhem"},
        {addr = 0x35B880, label = "Paparazzi Purge"},
        {addr = 0x35B884, label = "Payday For Ray"},
        {addr = 0x35B890, label = "Silence The Sneak"},
        {addr = 0x35B888, label = "Two-Faced Tanner"},
        {addr = 0x35B8B4, label = "Deal Steal"},
        {addr = 0x35B8B8, label = "Shima"},
        {addr = 0x35B8BC, label = "Smack Down"},
        {addr = 0x35B974, label = "A Ride In The Park"},
        {addr = 0x35B894, label = "Arms Shortage"},
        {addr = 0x35B898, label = "Evidence Dash"},
        {addr = 0x35B89C, label = "Gone Fishing"},
        {addr = 0x35B8DC, label = "Gangcar Round-Up"},
        {addr = 0x35B8A0, label = "Plaster Blaster"},
        {addr = 0x35B8E0, label = "Kingdom Come"},
        {addr = 0x35B8C4, label = "Liberator"},
        {addr = 0x35B8C8, label = "Waka-Gashira Wipeout!"},
        {addr = 0x35B8CC, label = "A Drop In The Ocean"},
        {addr = 0x35B8FC, label = "Grand Theft Aero"},
        {addr = 0x35B8A4, label = "Marked Man"},
        {addr = 0x35B900, label = "Escort Service"},
        {addr = 0x35B9F4, label = "Rumpo Rampage"},
        {addr = 0x35B924, label = "Uzi Money"},
        {addr = 0x35B928, label = "Toyminator"},
        {addr = 0x35B92C, label = "Rigged to Blow"},
        {addr = 0x35B930, label = "Bullion Run"},
        {addr = 0x35B910, label = "Bait"},
        {addr = 0x35B904, label = "Decoy"},
        {addr = 0x35B908, label = "Love's Disappearance"},
        {addr = 0x35B914, label = "Espresso-2-Go!"},
        {addr = 0x35B918, label = "S.A.M."},
        {addr = 0x35B948, label = "The Exchange"},
        {addr = 0x35B934, label = "Rumble"},
        {addr = 0x35B978, label = "Gripped!"}
    }
    missionCount = #missionList
    current.missionStates = {}
    old.missionStates = {}
    completedMissions = {}
end
if enable.anyfinalsplit == true then
    current.teHelipad = 0
    current.teTimer = 0
end
if enable.hundofinalsplit == true then
    current.progressMade = 0
end
if enable.usjs ~= false then
    current.usjs = 0
end
if enable.packages ~= false then
    current.packages = 0
end
if enable.rampages ~= false then
    current.rampages = 0
end
current.gameState = 0


function startup()
    refreshRate = 30
    if enable.missions == true then
        for i = 1, missionCount do
            completedMissions[i] = false
        end
    end
end

function start()
    if (old.gameState == 8 and current.gameState == 9) then
        return true
    end 
end

-- function reset()
--     if (old.gameState == 8 and current.gameState == 9) then
--         return true
--     end 
-- end

function state()
    old = shallow_copy_tbl(current)
    if enable.missions == true then
        old.missionStates = shallow_copy_tbl(current.missionStates)
        for i = 1, missionCount do
            if completedMissions[i] == false then
                local address = missionList[i].addr
                local val = readAddress("int", address)
                current.missionStates[i] = val
            end
        end
    end
    if enable.anyfinalsplit == true then
        current.teHelipad = readAddress("byte", 0x35F6B8)
        current.teTimer = readAddress("int", 0x35BA2C)
    end
    if enable.hundofinalsplit == true then
        current.progressMade = readAddress("int", 0x50651C)
    end
    if enable.usjs ~= false then
        current.usjs = readAddress("int", 0x35BFB0)
    end
    if enable.packages ~= false then
        current.packages = readAddress("int", 0x35C3D4)
    end
    if enable.rampages ~= false then
        current.rampages = readAddress("int", 0x35C0AC)
    end
    current.gameState = readAddress("int", "0x505A2C")
end

function split()
    if enable.missions == true then
        --Procedure, via LiveSplit ASL
        --Loop over all missions
        --1. Check if mission is enabled
        --2. Check if the mission was just passed
        --3. Check if we didn't split for this mission already
        --If all checks passes, split
        for i = 1, missionCount do
            if completedMissions[i] == false then
                if old.missionStates and old.missionStates[i] and current.missionStates[i] > old.missionStates[i] then
                    completedMissions[i] = true
                    print("Mission Complete: " .. missionList[i].label)
                    return true
                end
            end
        end
    end
    if enable.anyfinalsplit == true then
        if current.teHelipad == 1 and current.teTimer ~= old.teTimer then
            return true
        end
    end
    if enable.hundofinalsplit == true then
        if current.progressMade == 154 and current.progressMade ~= old.progressMade then
            return true
        end
    end
    if enable.usjs ~= false then
        if enable.usjs == "each" then
            if current.usjs > old.usjs then
                return true
            end
        elseif enable.usjs == "all" then
            if current.usjs == 20 and current.usjs ~= old.usjs then
                return true
            end
        end
    end
    if enable.packages ~= false then
        if enable.packages == "each" then
            if current.packages > old.packages then
                return true
            end
        elseif enable.packages == "all" then
            if current.packages == 100 and current.packages ~= old.packages then
                return true
            end
        end
    end
    if enable.rampages ~= false then
        if enable.rampages == "each" then
            if current.rampages > old.rampages then
                return true
            end
        elseif enable.rampages == "all" then
            if current.rampages == 20 and current.rampages ~= old.rampages then
                return true
            end
        end
    end
end
