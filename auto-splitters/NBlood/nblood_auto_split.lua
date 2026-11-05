process('nblood')

-- TODO: Add another offsets list for dauswectus srBlood fork
local memoryOffsets = {
	level = 0x381E20,
	episode = 0x381E24,
	menu = 0x6530B0,
	credits = 0xD49D09
}

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

local expectedLevels = { 1, 2, 3, 4, 5 , 6, 7, 8, 9 }
local levelSplitIndex = 1;

-- This will allow us to run episodes in any order we want
local episodeCompleted = { false, false, false, false }

function startup( )
	refreshRate = 60
end

-- Memory addresses are up-to-date with the official NBlood repo. (Build 2026-11-04 )
function state( )
	oldState.level = currentState.level;
	currentState.level = readAddress( "byte", memoryOffsets.level );

	oldState.episode = currentState.episode;
	currentState.episode = readAddress( "byte", memoryOffsets.episode );

	oldState.menu = currentState.menu;
	currentState.menu = readAddress( "byte", memoryOffsets.menu );

	oldState.credits = currentState.credits;
	currentState.credits = readAddress( "byte", memoryOffsets.credits );
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
	if ( currentState.level == expectedLevels[levelSplitIndex] ) and currentState.menu == 0 then
		levelSplitIndex = levelSplitIndex + 1;
		return true
	end
	-- For last episode splits
	if ( not episodeCompleted[currentState.episode+1] and currentState.credits == 1 ) then
		levelSplitIndex = 1;
		episodeCompleted[currentState.episode + 1] = true;
		return true
	end
end

-- Autoresets whenever we enter episode choose menu mid episode run
-- If we want to reset after finishing the episode
-- just start any other and go to the menu
function reset( )
	if ( currentState.menu == 2 or currentState.menu == 3 )
		and not ( episodeCompleted[currentState.episode+1]  ) then
		levelSplitIndex = 1;
		episodeCompleted = { false, false, false, false };
		return true
	end
end
