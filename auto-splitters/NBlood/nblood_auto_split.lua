process('nblood')

local memoryOffsets = {
	-- Vanilla offset ( r14388 )
	["9c1ac283457950f4ab57fa46688040a4"] = {
		level = 0x381E20,
		episode = 0x381E24,
		menu = 0x6530B0,
		credits = 0xD49D09
	},

	-- srBlood offsets
	["82618e9b3f04d2ea2276e2a637c0b537"] = {
		level = 0x349F74,
		episode = 0x349F78,
		menu = 0x694E70,
		credits = 0xC262E9
	}
}

local currentOffsets = nil;

local offsetsFound = false;

local currentState = {
	level = 0,
	episode = 0,
	menu = 0,
	credits = 0
}

local oldState = {
	level = 0,
	episode = 0,
	menu = 0,
	credits = 0
}

-- Making an array to track if the level was started
-- this will prevent from repeated splits 
-- and this will allow us to run 100% with secret levels
local levelStarted = {}
for i = 1,10 do
	levelStarted[i] = false
end

local levelSplitIndex = 1

-- This will allow us to run episodes in any order we want
local episodeCompleted = { false, false, false, false }

local function getProcessPath(  )
	local maps = getMaps( )
	if not maps then
		print( "ERROR: getMaps( ) returned nil" )
		return nil
	end

	-- Looking for nblood executable file path
	for i, map in ipairs( maps ) do
		if map.name and map.name:match( "nblood" ) then
			return map.name
		end
	end

	return nil
end

local function getOffsets(  )
	local processPath = getProcessPath( )
	if not processPath then
		print( "ERROR: Couldn't find nblood executable file path" )
		return nil
	end

	local md5Process = md5sum( processPath )
	print( "nblood md5sum = " .. tostring( md5Process ) )

	return memoryOffsets[md5Process]
end

function startup( )
	refreshRate = 60

	-- Looking for nblood executable file path via maps
	local maps = getMaps( )
	currentOffsets = getOffsets(  )
	if not currentOffsets then
		print( "ERROR: No offsets found for nblood executable\n" )
		print( "Please be sure that you are using builds from Blood resource page on speedrun.com" )
		return
	end

	offsetsFound = true
	print( "Chosen offsets are:\n",
	"level: 0x" .. string.format( "%X", currentOffsets.level) .. '\n',
	"episode: 0x" .. string.format( "%X", currentOffsets.episode) .. '\n',
	"menuState: 0x" .. string.format( "%X", currentOffsets.menu) .. '\n',
	"credits: 0x" .. string.format( "%X", currentOffsets.credits ) .. '\n'
	)

end


-- Memory addresses are up-to-date with the official NBlood repo. (Build 2026-11-04 )
function state( )
	if not offsetsFound then return end
	oldState.level = currentState.level
	currentState.level = readAddress( "byte", currentOffsets.level )

	oldState.episode = currentState.episode
	currentState.episode = readAddress( "byte", currentOffsets.episode )

	oldState.menu = currentState.menu
	currentState.menu = readAddress( "byte", currentOffsets.menu )

	oldState.credits = currentState.credits
	currentState.credits = readAddress( "byte", currentOffsets.credits )
end

function start( )
	if currentState.level == 0 and ( oldState.menu == 3 and currentState.menu == 0 ) then
		return true
	end
end

function update( )
	
	-- UNCOMMENT LINES BELOW FOR DEBUG INFO
	-- if ( currentState.level ~= oldState.level ) then
	-- 	print ( "Level Change:", oldState.level, "->", currentState.level )
	-- end
	-- if ( currentState.episode ~= oldState.episode ) then
	-- 	print ( "Episode Change:", oldState.episode, "->", currentState.episode )
	-- end
	-- if ( currentState.menu ~= oldState.menu ) then
	-- 	print ( "Menu state change:", oldState.menu, "->", currentState.menu )
	-- end

	if oldState.episode ~= currentState.episode then
		levelSplitIndex = 1
	end


end

-- Checking if current map is what we expect to avoid repeated splits
-- in case we load a save from previous map
function split( )
	-- Checking if the current level is what was expected
	if ( currentState.level == levelSplitIndex or not levelStarted[currentState.level+1]) and currentState.menu == 0 then
		levelSplitIndex = levelSplitIndex + 1
		levelStarted[currentState.level+1] = true
		return true
	end
	-- For last episode splits
	if ( not episodeCompleted[currentState.episode+1] and currentState.credits == 1 ) then
		levelSplitIndex = 1
		episodeCompleted[currentState.episode + 1] = true
		return true
	end
end

-- Autoresets whenever we enter episode choose menu mid episode run
-- If we want to reset after finishing the episode
-- just start any other and go to the menu
function reset( )
	if ( currentState.menu == 2 or currentState.menu == 3 )
		and not ( episodeCompleted[currentState.episode+1]  ) then
		levelSplitIndex = 1
		episodeCompleted = { false, false, false, false }
		for i = 1, 10 do
			levelStarted[i] = false
		end
		return true
	end
end
