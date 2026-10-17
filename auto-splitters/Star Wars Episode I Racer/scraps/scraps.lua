-- DEBUG VALUE PRINTING
print("\n===========================\nuseGameTime = " .. tostring(useGameTime))
print("isLoading() = " .. tostring(isLoading()))
if useGameTime then
    print("gameTime() = " .. tostring(gameTime()))
end
for i, tbl in ipairs({sets, current, vars}) do
    if i == 1 then
        print('\n---------------------------\n      sets\n---------------------------')
    elseif i == 2 then
        print('\n---------------------------\n      ADDRESS VALUES\n---------------------------')
    elseif i == 3 then
        print('\n---------------------------\n      VARIABLE VALUES\n---------------------------')
    end
    for k, v in pairs(tbl) do
        if type(v) ~= "string" then 
            v = tostring(v)
        end
        print (k .. " = " .. v)
    end
end

local function getLargest(strTable)
    local largest = 0
    for i, v in pairs(strTable) do
        if string.len(v) > largest then
            largest = string.len(v)
        end
    end
    return largest
end

