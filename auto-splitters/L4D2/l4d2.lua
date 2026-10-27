-- Left 4 Dead 2 autosplitter
-- Ported from the L4D2 LiveSplit ASL
process("left4dead2.exe")

local engineAndClientHashesAndOffsets = {
    -- V2000 offsets
    ["6CBADAA9132AD6138F3D50920BB9ECFE_B23B95981DE30C91C8C9C3E3FD7F3E84"] = {
        whatsLoading = 0x3C9988,
        gameLoading = 0x5CC89C,
        hasControl = 0x68FBD4,
        scoreboardLoad = 0x6DB58D,
        finaleTrigger = 0x6ED414,
        svCheats = 0x6DB040,
        cutscenePlaying = 0x66CEEC,
    },
    -- V2012 offsets
    ["F79518A744FE34538726AAC4A9E43593_474DB57CBCDC9819AA36FBFA55CCFBF5"] = {
        whatsLoading = 0x3CD988,
        gameLoading = 0x5D091C,
        hasControl = 0x699164,
        scoreboardLoad = 0x6E4C85,
        finaleTrigger = 0x6F6B14,
        svCheats = 0x6E4738,
        cutscenePlaying = 0x67647C,
    },
    -- V2027 offsets
    ["6BD61059254B425464507486F096D209_263E9AE9ABA9C751A14663DF432EE9EA"] = {
        whatsLoading = 0x3CF988,
        gameLoading = 0x5D291C,
        hasControl = 0x699264,
        scoreboardLoad = 0x6E4D6D,
        finaleTrigger = 0x6F6BF4,
        svCheats = 0x6E4820,
        cutscenePlaying = 0x676584,
    },
    -- V2045 offsets
    ["9B767FB9EC1AA2C35401F1A7310B0943_281AE29C235AACDEC83EE7471175D390"] = {
        gameLoading = 0x5DE494,
        whatsLoading = 0x3D2A00,
        hasControl = 0x6A9C64,
        scoreboardLoad = 0x6F57BD,
        finaleTrigger = 0x707824,
        svCheats = 0x6F5270,
        cutscenePlaying = 0x686F7C,
    },
    -- V2075 offsets
    ["C7BA3CF5AC8722BCA7CBCA0BFB4BCB5B_352E7987A4D778EEA082D2CCB8967EEB"] = {
        gameLoading = 0x5DA8CC,
        whatsLoading = 0x3CF630,
        hasControl = 0x6ABAC4,
        scoreboardLoad = 0x6F761D,
        finaleTrigger = 0x709634,
        svCheats = 0x6F70D0,
        cutscenePlaying = 0x688E14,
    },
    -- V2091 offsets
    ["074A3EF53F97661C724C5FD5FE7F33D8_9A88102D7D7D7D55A2DCBF67406378F7"] = {
        whatsLoading = 0x3CF630,
        gameLoading = 0x5E19D4,
        hasControl = 0x6ABB24,
        scoreboardLoad = 0x6F7685,
        finaleTrigger = 0x7096AC,
        svCheats = 0x6F7138,
        cutscenePlaying = 0x688E64,
    },
    -- V2147 offsets
    ["7899154C8A5263F8919A8E272E1C65AD_D75DD50CBB1A8B9F6106B7B38A5293F7"] = {
        whatsLoading = 0x42F240,
        gameLoading = 0x46C54C,
        hasControl = 0x72767C,
        scoreboardLoad = 0x775AB5,
        finaleTrigger = 0x787E14,
        svCheats = 0x775568,
        cutscenePlaying = 0x702C64,
    },
    -- V2203 offsets
    ["D6DCB5F35F8CA379E1649AE5E5BD0B52_1339CD4EF916923DA04B04904C1B544C"] = {
        whatsLoading = 0x435240,
        gameLoading = 0x47264C,
        hasControl = 0x73421C,
        scoreboardLoad = 0x782E55,
        finaleTrigger = 0x7951D4,
        svCheats = 0x782908,
        cutscenePlaying = 0x70F804,
    },
}

local current = {
    whatsLoading = "",
    isLoading = false,
    hasControl = false,
    scoreboardLoading = false,
    svCheats = false,
    cutscenePlaying = false,
}

local old = shallow_copy_tbl(current)

local function basename(path)
    return (path or ""):match("([^/]+)$") or ""
end

local function getEngineClientMaps()
    local maps = getMaps()
    local output = {}
    for _, map in ipairs(maps) do
        local name = basename(map.name)

        if name == "engine.dll" then
            output["engineBase"] = map
        elseif name == "Client.dll" then
            output["clientBase"] = map
        end
    end

    return output
end

local function getOffsets()
    local gameMaps = getEngineClientMaps()

    if gameMaps.engineBase ~= nil or gameMaps.clientBase ~= nil then
        local engineHash = md5sum(gameMaps.engineBase.name):upper()
        local clientHash = md5sum(gameMaps.clientBase.name):upper()

        local key = string.format("%s_%s", engineHash, clientHash)

        -- UNCOMMENT WHEN DEBUGGING
        -- print("Engine Hash : " .. tostring(engineHash))
        -- print("Client Hash : " .. tostring(clientHash))
        -- print("OFFSETS KEY : " .. key)

        return engineAndClientHashesAndOffsets[key]
    else
        return nil
    end
end

local offsets = getOffsets()

-- stylua: ignore start
-- More maps should be added here when more versions are supported
-- in the near future
local campaignsLastMaps = {
    c5m5_bridge          = true,
    c6m3_port            = true,
    c7m3_port            = true,
    c13m4_cutthroatcreek = true
}
-- local campaignsFirstMaps = {
--     c1m1_hotel        = true,
--     c2m1_highway      = true,
--     c3m1_plankcountry = true,
--     c4m1_milltown_a   = true,
--     c5m1_waterfront   = true
-- }
-- stylua: ignore end

local cutsceneStart = 0
local delayedSplitStart = 0

local lastSplit = ""

function delayedStart()
    if delayedSplitStart == 0 then
        delayedSplitStart = os.time_us()
    end
end

local function elapsed_ms(start)
    if start == 0 then
        return 0
    end

    return os.difftime(os.time_us(), start) / 1000
end

function define_settings()
    settings.define("chapter_split", {
        name = "Chapter Split",
        type = SETTING_BOOLEAN,
        default = true,
        desc = "Split inbetween chapters",
    })

    settings.define("scoreboard_split", {
        name = "Scoreboard Split",
        type = SETTING_BOOLEAN,
        default = true,
        desc = "Split at scoreboard screen, otherwise split when the next chapter is loading",
    })
end

function startup()
    refreshRate = 30
    mapsCacheCycles = 2
end

function state()
    if offsets == nil then
        offsets = getOffsets()
        return
    end

    old = shallow_copy_tbl(current)
    -- stylua: ignore start
    current.whatsLoading      = readAddress("string30", "engine.dll", offsets.whatsLoading, { pointerSize = POINTER_SIZE_32 })
    current.isLoading         = readAddress("bool", "engine.dll", offsets.gameLoading,      { pointerSize = POINTER_SIZE_32 })
    current.hasControl        = readAddress("bool", "Client.dll", offsets.hasControl,       { pointerSize = POINTER_SIZE_32 })
    current.scoreboardLoading = readAddress("bool", "Client.dll", offsets.scoreboardLoad,   { pointerSize = POINTER_SIZE_32 })
    current.finaleTrigger     = readAddress("bool", "Client.dll", offsets.finaleTrigger,    { pointerSize = POINTER_SIZE_32 })
    current.svCheats          = readAddress("bool", "Client.dll", offsets.svCheats, 0x30,   { pointerSize = POINTER_SIZE_32 })
    current.cutscenePlaying   = readAddress("bool", "Client.dll", offsets.cutscenePlaying,  { pointerSize = POINTER_SIZE_32 })
    -- stylua: ignore end

    -- UNCOMMENT WHEN DEBUGGING
    -- print("map: " .. current.whatsLoading)
    -- print("hasControl: " .. tostring(current.hasControl))
    -- print("game loading: " .. tostring(current.isLoading))
    -- print("scoreboardLoad: " .. tostring(current.scoreboardLoading))
    -- print("sv_cheats: " .. tostring(current.svCheats))
    -- print("finaleTrigger: " .. tostring(current.finaleTrigger))
    -- print("cutscenePlaying: " .. tostring(current.cutscenePlaying))
    -- print("lastSplit: " .. lastSplit)
    -- print("cutsceneStart: " .. tostring(cutsceneStart))
    -- print()
end

function start()
    if current.svCheats then
        cutsceneStart = 0
        return false
    end

    if current.hasControl and not current.isLoading then
        if elapsed_ms(cutsceneStart) >= 250 then
            cutsceneStart = 0
            lastSplit = ""
            return true
        elseif cutsceneStart ~= 0 then
            cutsceneStart = 0
        end
    end

    if
        not old.hasControl
        and not current.hasControl
        and not current.isLoading
        and current.whatsLoading ~= ""
        and cutsceneStart == 0
    then
        cutsceneStart = os.time_us()
    end

    return false
end

function split()
    -- This relies on having Game Instructor enabled
    if current.finaleTrigger and not old.finaleTrigger then
        delayedSplitStart = 0
        -- prevent double split
        if current.whatsLoading == lastSplit then
            return false
        end
        lastSplit = current.whatsLoading
        return true
    elseif
        current.cutscenePlaying
        and not old.cutscenePlaying
        and campaignsLastMaps[current.whatsLoading]
    then
        delayedStart()
        if current.whatsLoading == lastSplit then
            return false
        end
    end

    if elapsed_ms(delayedSplitStart) >= 250 then
        delayedSplitStart = 0
        lastSplit = current.whatsLoading
        return true
    end

    if settings.get("chapter_split") then
        if settings.get("scoreboard_split") then
            if
                not current.finaleTrigger
                and not old.scoreboardLoading
                and current.scoreboardLoading
            then
                lastSplit = current.whatsLoading
                return true
            end
        else
            if
                not current.finaleTrigger
                and not old.isLoading
                and current.isLoading
                and current.scoreboardLoading
            then
                lastSplit = current.whatsLoading
                return true
            end
        end
    end
end

function isLoading()
    return current.isLoading
end
