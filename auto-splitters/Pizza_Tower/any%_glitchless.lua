-- Pizza Tower Auto Splitter
-- By Penaz
-- Based on the original work of ccarl
process("PizzaTower.exe")

-- The variable that will contain the address for the beginning speedrun section of the memory
local sig = nil

-- This variable is used to lock the auto splitter from splitting when it should not
local can_split = false

-- This is an array containing the name of the rooms where the level exits are located
local full_game_split_rooms = {
    tower_tutorial1 = true,
    tower_tutorial1N = true,
    entrance_1 = true,
    medieval_1 = true,
    ruin_1 = true,
    dungeon_1 = true,
    badland_1 = true,
    graveyard_1 = true,
    farm_2 = true,
    saloon_1 = true,
    plage_entrance = true,
    forest_1 = true,
    minigolf_1 = true,
    space_1 = true,
    street_intro = true,
    sewer_1 = true,
    industrial_1 = true,
    freezer_1 = true,
    chateau_1 = true,
    kidsparty_1 = true,
    war_13 = true,
    boss_pepperman = true,
    boss_vigilante = true,
    boss_noise = true,
    boss_fakepepkey = true,
    boss_pizzaface = true,
    boss_pizzafacefinale = true,
    tower_entrancehall = true,
    rank_room = true,
}

-- This array contains the names of the rooms where we can unlock the splitting
-- usually these are the rooms containing Pillar John (which starts Pizza Time)
local split_unlock_rooms = {
    tower_tutorial10 = true,
    tower_tutorial3N = true,
    entrance_10 = true,
    medieval_10 = true,
    ruin_11 = true,
    dungeon_10 = true,
    badland_9 = true,
    graveyard_6 = true,
    farm_11 = true,
    saloon_6 = true,
    plage_cavern2 = true,
    forest_john = true,
    space_9 = true,
    minigolf_8 = true,
    street_john = true,
    sewer_8 = true,
    industrial_5 = true,
    freezer_escape1 = true,
    chateau_9 = true,
    kidsparty_john = true,
    war_1 = true,
    boss_pepperman = true,
    boss_vigilante = true,
    boss_noise = true,
    boss_fakepepkey = true,
    boss_pizzaface = true,
    tower_finalhallway = true,
}


-- The current state of the game
local current = {
    file_minutes = nil,
    file_seconds = nil,
    level_minutes = nil,
    level_seconds = nil,
    room = nil,
    parsed_room= "Unknown",
    eol_fade_exists = false,
    boss_hp = nil,
}

-- The state of the game in the previous read
local old = {
    file_minutes = nil,
    file_seconds = nil,
    level_minutes = nil,
    level_seconds = nil,
    room = nil,
    parsed_room= "Unknown",
    eol_fade_exists = false,
    boss_hp = nil,
}

-- Function to copy over data from one table to another
function shallow_copy_tbl(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

-- Function used to print tables, useful for debugging purposes
function print_tbl(t)
    for k,v in pairs(t) do
        print(k, " -> ", v)
    end
end

-- Standard startup function, 60FPS, uses internal game time
function startup()
    refreshRate = 60
    useGameTime = true
end

function state()
    -- If the address is nil, either we just started up the auto splitter or we couldn't
    -- find the address reporting the signature.
    if sig == nil then
        print("Scanning...")
        -- C2 5A 17 ... Marks the beginning of the "speedrun section" of memory, provided it exists.
        sig = sig_scan("C2 5A 17 65 BE 4D DF D6 F2 1C D1 3B A7 A6 1F C3", 0)
        if sig == nil then
            -- If we didn't find it, it was either not allocated yet (better luck next loop) or PT was not started
            -- with the "-livesplit" option.
            print("Signature not found, make sure Pizza Tower is run with the -livesplit option")
        end
    else
        -- First of all, before updating the current state, copy it over to the previous one
        -- so we can tell the difference
        old = shallow_copy_tbl(current)
        -- At 0x80 (128) bytes after the beginning of the signature, we find the minutes spent on the savefile
        -- It is a double-precision float
        current.file_minutes = readAddress("double", sig + 0x80)
        -- At 0x88 we find the seconds
        current.file_seconds = readAddress("double", sig + 0x88)
        -- 0x90 -> Minutes spent on the level
        current.level_minutes = readAddress("double", sig + 0x90)
        -- 0x98 -> Minutes spent on the level
        current.level_seconds = readAddress("double", sig + 0x98)
        -- 0xA0 -> A 64-character string telling us the name of the room we're in (including cutscenes)
        current.room = readAddress("string64", sig + 0xA0)
        -- 0xE0 -> A boolean telling us if we're fading to the end-of-level
        current.eol_fade_exists = readAddress("bool", sig + 0xE0)
        -- 0xE1 -> A small integer telling us the remaining boss health
        current.boss_hp = readAddress("byte", sig + 0xE1)
    end
end

function start()
    -- Start from new file. If we transition from the Intro to the Entrance, start the timer.
    if old.room == "Finalintro" and current.room == "tower_entrancehall" then
        return true
    end
    -- Start from loaded file. If we transition from the loading screen to the Entrance, start the timer.
    if old.room == "hub_loadingscreen" and current.room == "tower_entrancehall" then
        return true
    end
    -- If none of the above applies. Do nothing.
    return false
end

function split()
    -- If we cannot split yet, check if the current room can "unlock" the split lock.
    -- If it is already unlocked, don't do anything (or it may "re-lock")
    if not can_split then
        can_split = split_unlock_rooms[current.room] ~= nil
    end
    -- If we changed room
    if old.room ~= current.room then
        -- And we can split
        if can_split then
            -- Then parse the current room name into something that makes more sense (there are many hubs in the tower, for instance)
            current.parsed_room = getCurrentLevel(current.room, old.parsed_room)
            -- If the room we just passed contains an exit...
            if full_game_split_rooms[old.room] ~= nil then
                -- And we ended in the Results Screen (normal levels) or a room in the Tower (for the boss outro skip)
                if current.parsed_room == "ResultsScreen" or current.parsed_room == "Hub" then
                    -- And the boss HP is depleted (which is always true on normal levels)
                    if old.boss_hp == 0 then
                        -- Re-lock the split lock for the next time
                        can_split = false
                        -- Allow Libresplit to split
                        return true
                    end
                end
            end
        end
    end
    -- Frame perfect End of Run split. This is very specific for the the of "The Crumbling Tower of Pizza"
    -- Where it would not split "frame-perfectly" otherwise.
    if (current.eol_fade_exists and not old.eol_fade_exists) and current.room == "tower_entrancehall" then
        return true
    end
    return false
end

function reset()
    -- Reset on new save
    if current.room == "Finalintro" and old.room ~= "Finalintro" then
        return true
    end
    -- Reset on loading save
    if current.room ~= old.room then
        if current.room == "hub_loadingscreen" then
            return true
        end
    end
    return false
end

function gameTime()
    -- Since we have the file minutes and seconds, we just chuck them into the game time
    -- if not null
    if (current.file_minutes ~= nil and current.file_seconds ~= nil) then
        return current.file_minutes * 60000 + current.file_seconds * 1000
    end
    return 0
end

-- A translation function for the level names into something that makes more sense
-- For instance every room starting with "tower_" is a Hub room, unless we started a CTOP run.
-- Or if we started a "Secrets of the world" run, all secret levels will be part of SOTW, instead of "normal secrets"
function getCurrentLevel(room_name, prev_level)
    if prev_level == "F5CrumblingTower" and string.match(room_name, "tower_") and not string.match(room_name, "tower_pizzafacehall") then
        return "F5CrumblingTower"
    end
    if prev_level == "SecretsOfTheWorld" and string.match(room_name, "secret") then
        return "SecretsOfTheWorld"
    end
    if string.match(room_name, "tower_finalhallway") then
        return "F5CrumblingTower"
    end
    if room_name=="tower_tutorial1N" then
        return "F1TutorialNoise"
    end
    if room_name=="tower_tutorial2N" then
        return "F1TutorialNoise"
    end
    if room_name=="tower_tutorial3N" then
        return "F1TutorialNoise"
    end
    if string.match(room_name, "tower_tutorial") then
        return "F1Tutorial"
    end
    if string.match(room_name, "tower_") then
        return "Hub"
    end
    if string.match(room_name, "boss_pizzafacehub") then
        return "Hub"
    end
    if string.match(room_name, "entrance_") then
        return "F1JohnGutter"
    end
    if string.match(room_name, "medieval_") then
        return "F1Pizzascape"
    end
    if string.match(room_name, "ruin_") then
        return "F1AncientCheese"
    end
    if string.match(room_name, "dungeon_") then
        return "F1BloodsauceDungeon"
    end
    if room_name == "boss_pepperman" then
        return "Pepperman"
    end
    if string.match(room_name, "badland_") then
        return "F2OreganoDesert"
    end
    if string.match(room_name, "graveyard_") then
        return "F2Wasteyard"
    end
    if string.match(room_name, "farm_") then
        return "F2FunFarm"
    end
    if string.match(room_name, "saloon_") then
        return "F2FastfoodSaloon"
    end
    if room_name == "boss_vigilante" then
        return "Vigilante"
    end
    if string.match(room_name, "plage_") then
        return "F3CrustCove"
    end
    if string.match(room_name, "forest_") then
        return "F3GnomeForest"
    end
    if string.match(room_name, "space_") then
        return "F3DeepDish9"
    end
    if string.match(room_name, "minigolf_") then
        return "F3Golf"
    end
    if room_name == "boss_noise" then
        return "Noise"
    end
    if string.match(room_name, "street_") then
        return "F4ThePigCity"
    end
    if string.match(room_name, "industrial_") then
        return "F4PeppibotFactory"
    end
    if string.match(room_name, "sewer_") then
        return "F4OhShit"
    end
    if string.match(room_name, "freezer_") then
        return "F4Refrigerator"
    end
    if string.match(room_name, "boss_fakepep") then
        return "Fake"
    end
    if string.match(room_name, "secret_entrance") then
        return "SecretsOfTheWorld"
    end
    if string.match(room_name, "trickytreat") then
        return "TrickyTreat"
    end
    if string.match(room_name, "cheateau_") then
        return "F5Pizzascare"
    end
    if string.match(room_name, "kidsparty_") then
        return "F5DMAS"
    end
    if string.match(room_name, "war_") then
        return "F5War"
    end
    if room_name == "boss_pizzaface" then
        return "Pizzaface"
    end
    if room_name == "rank_room" then
        return "ResultsScreen"
    end
    return "Unknown"
end
