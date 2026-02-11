--- Portal 2 SAR Autosplitter
--- By Zach (Phi0)
--- Based on work done by Nekz, Mlugg, and others in P2SR I'm probably forgetting
process("portal2_linux")

-- Def for action
local action_dict = {
    [0] = "none",
    [1] = "start",
    [2] = "restart",
    [3] = "split",
    [4] = "end",
    [5] = "reset"
};

-- Layout of SAR info we need
local SAR = {
    total = nil,
    ipt = nil,
    action = nil
}

-- Mem address for SAR
local target = nil;

function clear_table(table)
    for n in pairs(table) do
        table[n] = nil
    end
end

local last_action = 0;

-- Returns true when action memory address is updated in SAR
function action_changed()
    if SAR.action ~= last_action then
        last_action = SAR.action;
        return true;
    end
    return false
end

-- Update SAR memory values
function update_sar()
    local total = readAddress('int', target);
    local ipt = readAddress('float', target + sizeOf("int"));                    -- sizeOf(int)
    local action = readAddress('int', target + sizeOf("int") + sizeOf("float")); -- sizeOf(int) + sizeOf(float)
    -- print(string.format("[SAR]: total: %d, ipt: %f, action: %d", SAR.total, SAR.ipt, SAR.action))

    clear_table(SAR);
    SAR.total = total;
    SAR.ipt = ipt;
    SAR.action = action;
end

-- Find where SAR is loaded in memory, then load SAR values into local sar variable
function find_interface()
    target = sig_scan(
        "53 41 52 5F 54 49 4D 45 52 5F 53 54 41 52 54 00 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 53 41 52 5F 54 49 4D 45 52 5F 45 4E 44 00",
        -- char start[16]                                int total   float ipt   int action  char end[14]
        16
    );

    if target ~= nil then
        -- print("[SAR]: Public Inferface found at 0x", string.format("%x", target));
        local total = readAddress('int', target);
        local ipt = readAddress('float', target + sizeOf("int"));                    -- sizeOf(int)
        local action = readAddress('int', target + sizeOf("int") + sizeOf("float")); -- sizeOf(int) + sizeOf(float)

        clear_table(SAR);
        SAR.total = total;
        SAR.ipt = ipt;
        SAR.action = action;

        return true;
    end

    print("[SAR] Memory scan failed");
    return false;
end

local init = false;

function startup()
    refreshRate = 120;
    useGameTime = true;
end

function state()
    if init then
        update_sar()
    else
        find_interface()
    end
end

function gameTime()
    -- print(SAR.total * SAR.ipt * 1000)
    return SAR.total * SAR.ipt * 1000;
end

function start()
    return action_changed() and (SAR.action == 1 or SAR.action == 2);
end

function reset()
    return action_changed() and SAR.action == 5;
end

function split()
    return action_changed() and (SAR.action == 3 or SAR.action == 4);
end
