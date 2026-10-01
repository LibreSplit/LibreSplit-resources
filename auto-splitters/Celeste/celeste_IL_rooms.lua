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

local Chapter = ""
local SplitIndex = 1
local Chapters = {
    forsakenCity = { "2", "3", "4", "3b", "5", "6", "6a", "6b", "6c", "7", "8", "8b", "9", "9b", "10a", "11", "12", "12a", "end", },
    forsakenCityB = { "01", "02", "02b", "03", "04", "05", "05b", "06", "07", "08", "08b", "09", "10", "11", "end", },
    forsakenCityC = { "01", "02" },
    oldSite = { "0", "1", "d0", "d7", "d8", "d3", "d2", "d0", "1", "0", "3x", "3", "4", "5", "6", "7", "8", "9", "10", "2", "11", "12b", "12", "13", "end_0", "end_1", "end_2", "end_3", "end_4", "end_3b", "end_5", "end_6" },
    oldSiteB = { "00", "01", "01b", "02b", "02", "03", "04", "05", "06", "07", "08b", "08", "09", "10", "11", "end", },
    oldSiteC = { "01", "02" },
    celestialResort = { "s1", "s2", "s3", "0x-a", "00-a", "02-a", "02-b", "02-a", "03-a", "05-a", "06-a", "07-a", "07-b", "06-b", "06-c", "08-c", "08-b", "07-b", "07-a", "08-a", "09-b", "10-x", "11-x", "11-y", "11-z", "10-z", "10-y", "10-x", "09-b", "10-c", "11-c", "12-c", "12-d", "11-d", "10-d", "10-c", "09-b", "11-b", "12-b", "13-b", "13-a", "13-x", "12-x", "11-a", "09-b", "09-d", "08-d", "06-d", "04-d", "02-d", "00-d", "roof00", "roof01", "roof02", "roof03", "roof04", "roof05", "roof06", },
    celestialResortB = { "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "13", "14", "15", "12", "16", "17", "18", "19", "21", "20", "end", },
    celestialResortC = { "01", "02" },
    goldenRidge = { "a-01", "a-01x", "a-02", "a-03", "a-04", "a-05", "a-06", "a-07", "a-08", "a-09", "b-00", "b-02", "b-05", "b-08b", "b-08", "c-00", "c-02", "c-04", "c-05", "c-06", "c-09", "c-07", "c-08", "d-00", "d-01", "d-02", "d-03", "d-04", "d-05", "d-06", "d-07", "d-08", "d-09", "d-10", },
    goldenRidgeB = { "a-01", "a-02", "a-03", "a-04", "b-00", "b-01", "b-02", "b-03", "b-04", "c-00", "c-01", "c-02", "c-03", "c-04", "d-00", "d-01", "d-02", "d-03", "end", },
    goldenRidgeC = { "01", "02" },
    mirrorTemple = { "a-00d", "a-00c", "a-00", "a-01", "a-08", "a-12", "a-08", "a-01", "a-13", "b-00", "b-01", "b-01b", "b-02", "b-06", "b-19", "b-14", "b-16", "void", "c-00", "c-01", "c-01b", "c-01c", "c-08b", "c-08", "c-10", "c-12", "c-07", "c-11", "c-09", "c-13", "d-00", "d-01", "d-04", "d-19b", "d-19", "d-19b", "d-10", "d-20", "e-00", "e-01", "e-02", "e-03", "e-04", "e-06", "e-05", "e-07", "e-08", "e-09", "e-10", "e-11", },
    mirrorTempleB = { "a-00", "a-01", "a-02", "b-00", "b-01", "b-07", "b-03", "b-08", "b-09", "c-00", "c-01", "c-02", "c-03", "c-04", "d-00", "d-01", "d-02", "d-03", "d-04", "d-05", },
    mirrorTempleC = { "01", "02" },
    reflection = { "00", "01", "02", "03", "02", "02b", "04", "05", "06", "07", "08b", "09", "10b", "11", "12b", "13", "14a", "15", "16b", "17", "17", "19", "20", "b-00", "b-01", "b-02", "b-02b", "b-03", "boss-00", "boss-01", "boss-02", "boss-03", "boss-04", "boss-05", "boss-06", "boss-07", "boss-08", "boss-09", "boss-10", "boss-11", "boss-12", "boss-13", "boss-14", "boss-15", "boss-16", "boss-17", "boss-18", "boss-19", "boss-20", "after-00", "after-01", "after-02", },
    reflectionB = { "a-01", "a-02", "a-03", "a-04", "a-05", "a-06", "b-00", "b-01", "b-02", "b-03", "b-04", "b-05", "b-06", "b-07", "b-08", "b-10", "c-00", "c-01", "c-02", "c-03", "c-04", "d-00", "d-01", "d-02", "d-03", "d-04", "d-05", },
    reflectionC = { "01", "02" },
    summit = { "a-01", "a-02", "a-03", "a-05", "a-06", "b-00", "b-01", "b-02", "b-03", "b-05", "b-06", "b-07", "b-08", "b-09", "c-00", "c-01", "c-02", "c-03", "c-04", "c-06", "c-07", "c-08", "c-09", "d-00", "d-01", "d-01b", "d-02", "d-03", "d-04", "d-05", "d-06", "d-08", "d-10", "d-11", "e-00b", "e-00", "e-02", "e-03", "e-04", "e-05", "e-06", "e-07", "e-08", "e-10", "e-10b", "e-13", "f-00", "f-02", "f-04", "f-03", "f-05", "f-07", "f-08", "f-09", "f-10", "f-10b", "f-11", "g-00", "g-00b", "g-01", "g-02", "g-03" },
    summitB = { "a-01", "a-02", "a-03", "b-00", "b-01", "b-02", "b-03", "c-01", "c-00", "c-02", "c-03", "d-00", "d-01", "d-02", "d-03", "e-00", "e-01", "e-02", "e-03", "f-00", "f-01", "f-02", "f-03", "g-00", "g-01", "g-02", "g-03", },
    summitC = { "02", "03" },
    core = { "01", "02", "a-00", "a-01", "a-02", "a-03", "b-00", "b-07b", "b-07", "c-00", "c-01", "c-02", "c-03", "c-04", "d-00", "d-01", "d-02", "d-03", "d-04", "d-05", "d-06", "d-07", "d-08", "d-09", "d-10", "d-10b", "d-10c", "d-11", "space", },
    coreB = { "01", "a-00", "a-01", "a-02", "a-03", "a-04", "a-05", "b-00", "b-01", "b-02", "b-03", "b-04", "b-05", "c-01", "c-02", "c-03", "c-04", "c-05", "c-06", "c-08", "c-07", "space", },
    coreC = { "00", "01", "02" },
    farewell = { "intro-03-space", "a-00", "a-01", "a-02", "a-03", "a-04", "a-05", "b-00", "b-01", "b-02", "b-03", "b-04", "b-05", "b-06", "b-07", "c-00", "c-alt-00", "c-alt-01", "c-03", "d-00", "d-05", "e-00y", "e-00yb", "e-00z", "e-00", "e-00b", "e-01", "e-02", "e-03", "e-04", "e-05", "e-05b", "e-05c", "e-06", "e-07", "e-08", "f-door", "f-00", "f-01", "f-02", "f-03", "f-04", "f-05", "f-06", "f-07", "f-08", "f-09", "g-00", "g-01", "g-03", "g-02", "g-04", "g-05", "g-06", "h-00b", "h-00", "h-01", "h-02", "h-03", "h-03b", "h-04", "h-05", "h-06", "h-06b", "h-07", "h-08", "h-09", "h-10", "i-00", "i-00b", "i-01", "i-02", "i-03", "i-04", "i-05", "j-00", "j-00b", "j-01", "j-02", "j-03", "j-04", "j-05", "j-06", "j-07", "j-08", "j-09", "j-10", "j-11", "j-12", "j-13", "j-14", "j-14b", "j-15", "j-16", },
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
