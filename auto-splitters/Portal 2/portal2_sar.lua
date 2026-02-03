--- Portal 2 SAR Autosplitter
--- By Zach (Phi0)
--- Based on work done by Nekz, Mlugg, and others in P2SR I'm probably forgetting
process("portal2_linux")

-- Def for action
local action_dict = {
    none = 0,
    start = 1,
    restart = 2,
    split = 3,
    end_t = 4,
    reset = 5
};

-- Layout of SAR info we need
local SAR = {
    total = nil,
    ipt = nil,
    action = nil
}

function startup()
    refreshRate = 60;
    useGameTime = true;
end

function clear_table(table)
    for n in pairs(table) do
        table[n] = nil
    end
end

-- Find where SAR is loaded in memory, then load SAR values into local sar variable
function find_interface()
    local target = sig_scan(
        "53 41 52 5F 54 49 4D 45 52 5F 53 54 41 52 54 00", -- char start[16]
        "?? ?? ?? ??",                                     -- int total
        "?? ?? ?? ??",                                     -- float ipt
        "?? ?? ?? ??",                                     -- int action
        "53 41 52 5F 54 49 4D 45 52 5F 45 4E 44 00",       -- char end[14]
        16
    );

    if target ~= nil then
        print("[LIBRESPLIT] Public Inferface found at 0x", string.format("%x", target));
        local total = readAddress('int', target);
        local ipt = readAddress('float', target + 4);  -- sizeof(int)
        local action = readAddress('int', target + 8); -- sizeof(int) + sizeof(float)

        clear_table(SAR);
        SAR.total = total;
        SAR.ipt = ipt;
        SAR.action = action;

        return true
    end

    print("[LIBRESPLIT] Memory scan failed")
    return false
end

function state()
    find_interface();
    print(string.format("[SAR]: total: %d, ipt: %.2f, action: %d", SAR.total, SAR.ipt, SAR.action))
end
