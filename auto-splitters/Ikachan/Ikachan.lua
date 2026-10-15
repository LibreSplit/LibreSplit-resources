-- Ikachan Autosplitter for Libresplit by Tepiloxtl
process('Ikachan.exe')

local loc = {
    sys = 0x2174C,    -- Counts screen transitions, useful only for timing run start
    event = 0x20956,  -- Event flags, main dish
    equip = 0x20DDB,  -- Tracks whats equipped: pointy hat, pearl, capacitor, spaceship
    exp = 0x20DF6,    -- Mirrors ingame Exp counter
    act = 0x20DB8,    -- Thought to be "can be controlled" var, but isn't. Set to 1 on *some* cutscenes
    key = 0x2097C,    -- Keys pressed. Used to time start
    gather = 0x20E01, -- Keeps count of collected passengers in spaceship part. Useful for No OOB last split
    endf = 0x20DDA,    -- Something to do with locking movement direction/speed. Bit1 for capacitor, bit2 for No OOB last split
    inv = {0x020E14, 0x2d0, 0x200}  -- Suddenly, scary stuff. It's 10 bytes long, 1 byte per item
}

local split_list = {
    {"event",  2, 1, "Talk to Fooze, agree to help"},
    {"event",  3, 1, "Zuu fight start"},
    {"event",  4, 1, "Zuu fight end"},
    {"event",  5, 1, "Talk to Jisin, first quake"},
    {"event",  7, 1, "Get Sand Dollar"},
    {"event",  8, 1, "First talk with Carry"},
    {"event",  9, 1, "Deliver shrimp platter"},
    {"event", 10, 1, "Deliver crab platter"},
    {"event", 11, 1, "Ask Fooze for globefish platter"},
    {"event", 12, 1, "Talk to blue urchin, second quake"},
    {"event", 14, 1, "Get Capacitor"},
    {"event", 15, 1, "Rescue Pinky"},
    {"event", 16, 1, "Get globefish platter from Pinky"},
    {"event", 17, 1, "Deliver globefish platter"},
    {"event", 18, 1, "Defeat Ironhead"},
    {"event", 19, 1, "Rescue Zuu"},
    {"equip",  0, 1, "Get Pointed Hat"},
    {"inv",    2, 1, "Get Sand Dollar"},
    {"equip",  2, 1, "Get Pearl"},
    {"equip",  2, 0, "Lose Pearl"},
    {"equip",  1, 1, "Get Capacitor"},
    {"inv",   10, 1, "Get Ben"},
    {"equip",  4, 1, "Get Spaceship"}
}

local function bit_at(value, index)
    return (value >> index) & 1
end

local decoders = {
    equip = function(snap, bit_index)
        return bit_at(snap.mem_equip, bit_index)
    end,

    event = function(snap, bit_index)
        return bit_at(snap.mem_event[(bit_index >> 3) + 1], bit_index & 7)
    end,

    inv = function(snap, item_id)
        for _, slot_value in ipairs(snap.mem_inv) do
            if slot_value == item_id then
                return 1
            end
        end
        return 0
    end
}

local function setting_key(item)
    return item[1] .. "_flag_" .. item[2] .. "_" .. item[3]
end

function define_settings()
    settings.define("start_split", {
        name = "Starting split",
        type = SETTING_BOOLEAN,
        default = true
    })

    settings.define("any_split", {
        name = "Ending split for Any% - Not yet implemented!",
        type = SETTING_BOOLEAN,
        default = false
    })

    settings.define("nooob_split", {
        name = "Ending split for Any% No OOB",
        type = SETTING_BOOLEAN,
        default = true
    })

    for _, item in ipairs(split_list) do
        settings.define(setting_key(item), {
            name = item[4],
            type = SETTING_BOOLEAN,
            default = false
        })
    end
end

local current, old, enable = {}, {}, {}

function startup()
    refreshRate = 50
    enable.start_split = settings.get("start_split")
end

function state()
    old = shallow_copy_tbl(current)
    if enable.start_split == true then
        current.mem_sys = readAddress("int", loc.sys)
        current.mem_key = readAddress("byte", loc.key)
    end
    if enable.nooob_split == true then
        current.mem_gather = readAddress("int", loc.gather)
        current.mem_endf   = readAddress("byte", loc.endf)
    end
    if enable.subsplits == true then
        current.mem_event = readAddress("byte3", loc.event)
        current.mem_equip = readAddress("byte", loc.equip)
        current.mem_inv   = readAddress("byte10", table.unpack(loc.inv))
    end
end

function update()
    if not enable.subsplits then
        return
    end

    old.states = shallow_copy_tbl(current.states)
    for i, entry in ipairs(enable.split_list) do
        current.states[i] = decoders[entry[1]](current, entry[2])
    end
end

function onStart()
    enable.start_split = settings.get("start_split")
    enable.any_split   = settings.get("any_split")
    enable.nooob_split = settings.get("nooob_split")

    enable.split_list = {}
    for _, item in ipairs(split_list) do
        if settings.get(setting_key(item)) == true then
            enable.split_list[#enable.split_list + 1] = item
        end
    end

    enable.fired     = {}
    enable.subsplits = #enable.split_list > 0
    current.states   = {}
    old.states       = {}
end

-- Start of run is when sys is 0x08 and key bit6 is 1
function start()
    if not enable.start_split then
        return
    end
    if current.mem_sys == 8 and bit_at(current.mem_key, 6) == 1 then
        return true
    end
end

function split()
    if enable.subsplits then
        for i, entry in ipairs(enable.split_list) do
            if not enable.fired[i]
                and old.states[i] ~= nil
                and old.states[i] ~= entry[3]
                and current.states[i] == entry[3]
            then
                enable.fired[i] = true
                return true
            end
        end
    end

    -- End of Any% No OOB is when gather is 0x0C and endf bit1 is 1
    if enable.nooob_split
        and current.mem_gather == 0x0C
        and bit_at(current.mem_endf, 1) == 1
    then
        return true
    end
end

-- End of Any% TBD
-- Current Any% No OOB WR has split for obtaining Ben, that will be somewhere either in equip or inventory

-- Inventory starts at 0x020e14, 0x2d0, 0x200, 1 item is 1 byte

-- equip:
-- 0 Pointy hat
-- 1 Capacitor
-- 2 Pearl
-- 3
-- 4 Spaceship
-- 5
-- 6
-- 7
--
-- inv:
-- 01 Pointed hat
-- 02 Sand dollar
-- 03 Strange Liquid
-- 04 Note on Pearls
-- 05 Pearl
-- 06 Shrimp Platter
-- 07 Crab Platter
-- 08 Capacitor
-- 09 Globefish Platter
-- 10 Ben
-- 11 Spaceship
