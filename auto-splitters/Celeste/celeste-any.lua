cmdline("Celeste.bin.x86_64")

-- Set the b sides you do to true
local bSides = {
    templeB = false,
    reflectionB = false,
}

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

local lastCompleted = false
local splitIndex = 1
local checkpointIndex = 1
local splitDelay = false

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

local Chapters =
{ "prologue", "forsakenCity", "oldSite", "celestialResort", "goldenRidge", "temple", "reflection", "summit" }

local route = {
    prologue = { "Clear" },
    forsakenCity = { "Clear" },
    oldSite = { "Clear" },
    celestialResort = { "Clear" },
    goldenRidge = { "Clear" },
    temple = {},
    reflection = {},
    summit = { "Clear" },
}
local templeA = { "Clear" }
local templeB = { "Enter", "Clear" }
local reflectionA = { "Clear" }
local reflectionB = { "Enter", "Clear" }

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

function start()
    if current.areaID >= 0 then
        if bSides.templeB == true then
            route.temple = templeB
        else
            route.temple = templeA
        end
        if bSides.reflectionB == true then
            route.reflection = reflectionB
        else
            route.reflection = reflectionA
        end
        splitIndex = 1
        checkpointIndex = 1
        return true
    end
    return false
end

function split()
    local shouldSplit = false
    local Chapter = Chapters[splitIndex]
    if splitDelay == true then
        shouldSplit = true
        splitDelay = false
    else
        if current.chapterCompleted == true then
            lastCompleted = true
        end
        if route[Chapter][checkpointIndex] == "Clear" then
            if Chapter == "summit" then
                if current.areaID == 8 then
                    shouldSplit = true
                    splitIndex = splitIndex + 1
                    checkpointIndex = 1
                end
            elseif lastCompleted and current.areaID == -1 then
                splitDelay = true
                lastCompleted = false
                splitIndex = splitIndex + 1
                checkpointIndex = 1
            end
        elseif route[Chapter][checkpointIndex] == "Enter" then
            if current.areaID == splitIndex - 1 and current.areaDifficulty == 1 then
                shouldSplit = true
                checkpointIndex = checkpointIndex + 1
            end
        end
    end
    return shouldSplit
end

function isLoading()
    return true
end

function reset()
    if old.gameTime == 0 then
        return true
    end
    return false
end

function gameTime()
    return current.gameTime
end
