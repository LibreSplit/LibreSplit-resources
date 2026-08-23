cmdline("Celeste.bin.x86_64")

local autoSplitterObj = nil
local _read = readAddress
local base = 0
function readAddress(typ, address, ...)
    if type(address) == "number" and address >= base then
        return _read(typ, address - base, ...)
    else
        return _read(typ, address, ...)
    end
end

local current = {
    chapterCompleted = false,
    chapterStarted = false,
    levelName = "",
    areaID = -1,
    areaDifficulty = -1,
    gameTime = 0,
    levelTime = 0,
}

local old = {
    chapterCompleted = false,
    chapterStarted = false,
    levelName = "",
    AreaID = -1,
    areaDifficulty = -1,
    gameTime = 0,
    levelTime = 0,
}

local SplitIndex = 1
local Chapter = ""
local Chapters = {
    forsakenCity = { "6", "9b" },
    forsakenCityB = { "04", "08" },
    forsakenCityC = { "01", "02" },
    oldSite = { "3", "end_0" },
    oldSiteB = { "03", "08b" },
    oldSiteC = { "01", "02" },
    celestialResort = { "08-a", "09-d", "00-d" },
    celestialResortB = { "06", "11", "16" },
    celestialResortC = { "01", "02" },
    goldenRidge = { "b-00", "c-00", "d-00" },
    goldenRidgeB = { "b-00", "c-00", "d-00" },
    goldenRidgeC = { "01", "02" },
    mirrorTemple = { "b-00", "c-00", "d-00", "e-00" },
    mirrorTempleB = { 'b-00', "c-00", "d-00" },
    mirrorTempleC = { "01", "02" },
    reflection = { "00", "04", "b-00", "boss-00", "after-00" },
    reflectionB = { "b-00", "c-00", "d-00" },
    reflectionC = { "01", "02" },
    summit = { "b-00", "c-00", "d-00", "e-00b", "f-00", "g-00" },
    summitB = { "b-00", "c-01", "d-00", "e-00", "f-00", "g-00" },
    summitC = { "02", "03" },
    core = { "a-00", "c-00", "d-00" },
    coreB = { "a-00", "b-00", "c-01" },
    coreC = { "00", "01", "02" },
    farewell = { "a-00", "c-00", "e-00z", "f-door", "h-00b", "i-00", "j-00", "j-16" },
}

local resetRooms = {
    forsakenCity = "1",
    forsakenCityB = "00",
    forsakenCityC = "00",
    oldSite = "start",
    oldSiteB = "start",
    oldSiteC = "00",
    celestialResort = "s0",
    celestialResortB = "00",
    celestialResortC = "00",
    goldenRidge = "a-00",
    goldenRidgeB = "a-00",
    goldenRidgeC = "00",
    mirrorTemple = "a-00b",
    mirrorTempleB = "start",
    mirrorTempleC = "00",
    reflection = "start",
    reflectionB = "a-00",
    reflectionC = "00",
    summit = "a-00-intro",
    summitB = "a-00-intro",
    summitC = "01",
    core = "00",
    coreB = "00",
    coreC = "intro",
    farewell = "intro-00-past"
}


function lookupClass(classCache, name)
    local celesteClassCacheTable = readAddress("uint", classCache + 0x20)
    local hashTableSize = readAddress("uint", classCache + 0x18)
    for bucket = 0, hashTableSize do
        local offset = celesteClassCacheTable + (bucket * 0x8)
        local klass = readAddress("ulong", offset)
        while klass ~= 0 do
            local currentNamePtr = readAddress("ulong", klass + 0x40)
            local nameArr = readAddress("string7", currentNamePtr)

            if nameArr == name then
                return klass
            end
            klass = readAddress("ulong", klass + 0xf8)
        end
    end
    return nil
end

function classFieldOffset(klass, name)
    local classKind = bit.band((readAddress("byte", klass + 0x24)), 7)
    while classKind == 3 do
        local ptr1 = readAddress("ulong", klass + 0xe0)
        local newKlass = readAddress("ulong", klass + 0xe0)
        klass = readAddress("ulong", newKlass)
        classKind = bit.band((readAddress("byte", klass + 0x24)), 0x7)
    end
    local numFields = readAddress("int", klass + 0xf0)
    local fieldsPtr = readAddress("ulong", klass + 0x90)
    local bufSize = numFields * 4
    local slice = 0
    while slice <= bufSize do
        local ptrOffset = (slice + 1) * 0x8
        local fieldPtr = fieldsPtr + ptrOffset
        local fieldNamePtr = readAddress("ulong", fieldPtr)
        local fieldName = readAddress("string20", fieldNamePtr)
        if fieldName == name then
            local offset = (slice + 3) * 0x8
            offset = fieldsPtr + offset
            local fieldOffset = bit.band(readAddress("ulong", offset), 0xffffffff)
            return fieldOffset
        end

        slice = slice + 4
    end
end

function classStaticFields(klass)
    local runtimeInfo = readAddress("ulong", klass + 0xc8)
    local celesteVtable = readAddress("ulong", runtimeInfo + 0x8)
    local vtableSize = readAddress("uint", klass + 0x54)
    local offset = celesteVtable + 64 + vtableSize * 8
    return readAddress("ulong", offset)
end

function staticField(klass, name)
    local offset = classFieldOffset(klass, name)
    local staticPtr = classStaticFields(klass)
    return readAddress("ulong", offset + staticPtr)
end

function instanceClass(instance)
    local class = readAddress("ulong", instance)
    local class = bit.band(class, bit.bnot(1))
    return readAddress("ulong", class)
end

function field(instance, name)
    local klass = instanceClass(instance)
    local offset = classFieldOffset(klass, name)
    return readAddress("ulong", offset + instance)
end

function getLevelName(address)
    local levelPtr = readAddress("ulong", address)
    if levelPtr == 0 then
        return ""
    end
    local size = readAddress("uint", address + 0x10)
    if size > 512 then
        return ""
    end
    local levelName = ""
    for i = 0, size, 1 do
        local newChar = readAddress("string2", levelPtr + 0x14 + i * 2)
        if newChar == "" then
            break
        end
        levelName = levelName .. newChar
    end
    return levelName
end

function startup()
    refreshRate = 60
    useGameTime = true
    base = getBaseAddress()
end

function state()
    if autoSplitterObj == nil then
        local celesteDomain = 0
        local domainList = readAddress("ulong", 0xA17698)
        local firstDomain = readAddress("ulong", domainList)
        local firstDomainName = readAddress("ulong", firstDomain + 0xd8)
        local secondDomain = readAddress("ulong", domainList + 0x8)
        if secondDomain ~= 0 then
            celesteDomain = secondDomain
        else
            celesteDomain = firstDomain
        end
        local celesteAssembly = readAddress("ulong", celesteDomain + 0xd0)
        local celesteImage = readAddress("ulong", celesteAssembly + 0x60)
        local classCache = celesteImage + 1216
        local celesteClass = lookupClass(classCache, "Celeste")
        local celesteObj = staticField(celesteClass, "Instance")
        autoSplitterObj = field(celesteObj, "AutoSplitterInfo") + 0x10
    else
        old = shallow_copy_tbl(current)
        current.chapterCompleted = readAddress("bool", autoSplitterObj + 0x12)
        current.chapterStarted = readAddress("bool", autoSplitterObj + 0x11)
        current.areaID = readAddress("int", autoSplitterObj + 0x8)
        current.areaDifficulty = readAddress("int", autoSplitterObj + 0xc)
        current.gameTime = readAddress("long", autoSplitterObj + 0x28) / 10000
        current.levelTime = readAddress("long", autoSplitterObj + 0x18) / 10000
        current.levelName = getLevelName(autoSplitterObj)
    end
end

function split()
    local shouldSplit = false
    if old.chapterCompleted ~= current.chapterCompleted then
        shouldSplit = true
    end
    if old.levelName ~= current.levelName then
        if current.levelName == Chapters[Chapter][SplitIndex] then
            SplitIndex = SplitIndex + 1
            shouldSplit = true
        end
    end
    return shouldSplit
end

function start()
    if current.areaID >= 1 and current.levelTime > 0 then
        if current.areaID == 1 then
            Chapter = "forsakenCity"
        elseif current.areaID == 2 then
            Chapter = "oldSite"
        elseif current.areaID == 3 then
            Chapter = "celestialResort"
        elseif current.areaID == 4 then
            Chapter = "goldenRidge"
        elseif current.areaID == 5 then
            Chapter = "mirrorTemple"
        elseif current.areaID == 6 then
            Chapter = "reflection"
        elseif current.areaID == 7 then
            Chapter = "summit"
        elseif current.areaID == 9 then
            Chapter = "core"
        elseif current.areaID == 10 then
            Chapter = "farewell"
        end
        if current.areaDifficulty == 1 then
            Chapter = Chapter .. "B"
        elseif current.areaDifficulty == 2 then
            Chapter = Chapter .. "C"
        end

        return true
    end
    return false
end

function reset()
    if old.levelTime == 0 then
        if current.levelName == resetRooms[Chapter] then
            SplitIndex = 1
            return true
        end
    end
    return false
end

function isLoading()
    return true
end

function gameTime()
    return current.levelTime
end
