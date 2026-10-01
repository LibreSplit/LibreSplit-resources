-- Ikachan Autosplitter for Libresplit by Tepiloxtl
process('Ikachan.exe')

local loc = {
    sys = 0x2174C,    -- Counts screen transitions, useful only for timing run start
    event = 0x20956,  -- Event flags, main dish
    equip = 0x20DDB,  -- Tracks whats equipped: pointy hat, pearl, transistor, spaceship
    exp = 0x20DF6,    -- Mirrors ingame Exp counter
    act = 0x20DB8,    -- Thought to be "can be controlled" var, but isn't. Set to 1 on *some* cutscenes
    key = 0x2097C,    -- Keys pressed. Used to time start
    gather = 0x20E01, -- Keeps count of collected passengers in spaceship part. Useful for No OOB last split
    endf = 0x20DDA    -- Something to do with locking movement direction/speed. Bit1 for capacitor, bit2 for No OOB last split
}

local event_list = {
    {"event", 2, 1, "Talk to Fooze, agree to help"},
    {"event", 3, 1, "Zuu fight start"},
    {"event", 4, 1, "Zuu fight end"},
    {"event", 5, 1, "Talk to Jisin, first quake"},
    {"event", 7, 1, "Get Sand Dollar"},
    {"event", 8, 1, "First talk with Carry"},
    {"event", 9, 1, "Deliver shrimp platter"},
    {"event", 10, 1, "Deliver crab platter"},
    {"event", 11, 1, "Ask Fooze for globefish platter"},
    {"event", 12, 1, "Talk to blue urchin, second quake"},
    {"event", 14, 1, "Get Capacitor"},
    {"event", 15, 1, "Rescue Pinky"},
    {"event", 16, 1, "Get globefish platter from Pinky"},
    {"event", 17, 1, "Deliver globefish platter"},
    {"event", 18, 1, "Defeat Ironhead"},
    {"event", 19, 1, "Rescue Zuu"}
}

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

    settings.define("event_split", {
        name = "Splits for events, see event flags below",
        type = SETTING_BOOLEAN,
        default = false
    })

    for index, item in ipairs(event_list) do
        settings.define("event_flag_" .. item[2], {
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
    enable.any_split = settings.get("any_split")
    enable.nooob_split = settings.get("nooob_split")
    enable.event_split = settings.get("event_split")

    if enable.event_split == true then
        enable.event_list = {}
        for index, item in ipairs(event_list) do
            if settings.get("event_flag_" .. item[2]) == true then
                enable.event_list[#enable.event_list+1]=item
            end
        end
        enable.event_count = #enable.event_list
        current.event_states = {}
        old.event_states = {}
        enable.events_done = {}
        for i = 1, enable.event_count do
            enable.events_done[i] = false
        end
    end
end

function state()
    old = shallow_copy_tbl(current)
    if enable.start_split == true then
        current.memsys = readAddress("int", loc.sys)
        current.memkey = readAddress("byte", loc.key)
    end
    if enable.nooob_split == true then
        current.memgather = readAddress("int", loc.gather)
        current.memendf = readAddress("byte", loc.endf)
    end
    if enable.event_split == true then
        current.memevent = readAddress("byte3", loc.event)
    end
end

function update()
    if enable.event_split == true then
        old.event_states = shallow_copy_tbl(current.event_states)
        for i = 1, enable.event_count do
            if enable.events_done[i] == false then
                local address = enable.event_list[i][2]
                local val = b_and(b_rshift(current.memevent[math.floor(address/8) + 1], address % 8), 1)
                current.event_states[i] = val
            end
        end
    end
end

-- Start of run is when sys is 0x08 and key bit6 is 1
function start()
    if current.memsys == 8 and b_and(b_rshift(current.memkey, 6), 1) == 1 then
        return true
    end
end

function split()
    if enable.event_split == true then
        for i = 1, enable.event_count do
            if enable.events_done[i] == false then
                -- TODO val 3 in event_list means wether we look for value going from 0 to 1 or 1 to 0
                -- not important with events, but will be if I implement inventory/equip tracking
                if old.event_states and old.event_states[i] and current.event_states[i] > old.event_states[i] then
                    enable.events_done[i] = true
                    print("Done " .. enable.event_list[i][4])
                    return true
                end
            end
        end
    end
    -- End of Any% No OOB is when gather is 0x0C and endf bit1 is 1
    if enable.nooob_split == true then
        if current.memgather == 0x0C and b_and(b_rshift(current.memendf, 1), 1) == 1 then
            -- print("Done Any% No OOB final split")
            return true
        end
    end
end


-- End of Any% TBD
-- Current Any% No OOB WR has split for obtaining Ben, that will be somewhere either in equip or inventory
