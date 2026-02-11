process("TombRaider.exe")
-- loadRemover for current version of steam
local current = {FMV = false, cutscene = 0, isloading = false, level = "", newGameSelect = 0, saveSlot = 0, bowAmmo = 0, Camp = 0, Ammo = 0, GLA = 0, percentage = 0.0}
local old = {FMV = false, cutscene = 0, isloading = false, level = "", newGameSelect = 0, saveSlot = 0, bowAmmo = 0, Camp = 0, Ammo = 0, GLA = 0, percentage = 0.0}
-- Settings: id -> { tooltip = "...", cond = "level_transition_string" (optional), cond = "lua expr" (optional), enabled = bool }
-- Edit this table to enable/disable splits. Put the level-transition string in `cond` for simple transitions,
-- or a Lua boolean expression in `cond` for more complex checks. Expressions may reference `current`, `old`, and `leveltransition`.
local settings = {
    --#region scavenger den splits
    ["Give me the JUMP!"] = { tooltip = "Splits after first qte with guy trying to grab you", cond = "survival_den97_survival_den_rambotunnel", enabled = false },
    ["Neck high water"] = { tooltip = "Splits after leaving the neck high water", cond = "survival_den_rambotunnel_survival_den_puzzleroom", enabled = false },
    ["Puzzle Room"] = { tooltip = "Splits right before falling down the slide with cave collapsing", cond = "survival_den_puzzleroom_survival_den03", enabled = false },
    ["Let go of me you Bastard"] = { tooltip = "Splits right before the jump of qte's", cond = "survival_den03_survival_den04", enabled = false },
    ["Scavenger's Den"] = { tooltip = "Complete the climbing QTE at the end of the intro.", cond = "survival_den04_oceanvista", enabled = true },
    --#endregion
    --#region costal forest splits
    ["Coastal Bluffs"] = { tooltip = "Lara reaches the area where the bow is.", cond = "oceanvista_ac_forest", enabled = false },
    ["Bow"] = { tooltip = "Lara gets the bow.", cond = "skip", enabled = true },
    ["First Skill"] = { tooltip = "Splits during the cutscene after you acquire your first skill", cond = "skip", enabled = false },
    ["Costal Forest(south)"] = { tooltip = "Splits when Lara climbs the ladder of the bunker.", cond = "ac_bunker_ac_main", enabled = false },
    ["Costal Forest(north) earlier"] = { tooltip = "Splits after gate cutscene", cond = "ac_main_connector_acmain_to_mountainclimb_a", enabled = false },
    ["Costal Forest(north)"] = { tooltip = "Splits after the cutscene of Lara getting captured after Whitman Skip.", cond = "connector_acmain_to_mountainclimb_a_mountain_climb", enabled = false },
    --#endregion
    --#region Mountain Temple splits
    ["VLADIMIR!"] = { tooltip = "Splits during the cutscene when Vladimir is dying", cond = "skip", enabled = false },
    ["Chimney"] = { tooltip = "Splits right before the climb at the common crash point", cond = "mountain_climb_mountain_climb_to_village_hub_connector", enabled = false },
    ["Mountain Temple"] = { tooltip = "Splits after ascending the narrow mountain shaft, before reuniting with Roth for the first time.", cond = "mountain_climb_to_village_hub_connector_vh_main", enabled = false },
    --#endregion
    --#region Mountain Village splits
    ["Chimney Alt"] = { tooltip = "Splits during the cutscene of Roth fighting the wolves", cond = "skip", enabled = false },
    ["Wolves"] = { tooltip = "Splits after you skip the 2nd cutscene with Roth after retrieving the pack from the wolves", cond = "skip", enabled = false },
    ["Bridge"] = { tooltip = "Splits after you get past the collapsing bridge", cond = "vh_main_vh_vhmain_to_ww2_sos_01_connector", enabled = false },
    ["Mountain Village"] = { tooltip = "Splits after you current location updates to Base approach", cond = "vh_vhmain_to_ww2_sos_01_connector_ww2_sos_01", enabled = false },
    --#endregion
    --#region WW2 Base splits
    ["CampFire"] = { tooltip = "Splits during the forced camp fire before crew footage plays", cond = "skip", enabled = false },
    ["CampFireAlt"] = { tooltip = "Splits during the forced camp fire during crew footage", cond = "skip", enabled = false },
    ["Spot light time"] = { tooltip = "Splits when you get to the spot light area", cond = "ww2_sos_01_ww2_sos_02", enabled = false },
    ["Base Approach"] = { tooltip = "Splits after lara lands in the water", cond = "ww2_sos_02_ww2sos_03", enabled = false },
    ["Time for puzzle room"] = { tooltip = "splits when you enter the gas puzzle room", cond = "ww2sos_03_ww2sos_gas_puzzle", enabled = false },
    ["puzzle room"] = { tooltip = "splits when entering ambush room", cond = "ww2sos_gas_puzzle_ww2sos_map_room", enabled = false },
    ["Ambush Room"] = { tooltip = "Splits during the cutscene after opening the door from map room", cond = "skip", enabled = false },
    ["Map room"] = { tooltip = "Splits going into the small gap", cond = "ww2sos_map_room_ww2sos_03_to_04_connector", enabled = false },
    ["Mountain Base"] = { tooltip = "Splits after exiting the Mountain Base into the snowy outside.", cond = "ww2sos_03_to_04_connector_ww2sos_04", enabled = false },
    ["Sos Signal"] = { tooltip = "Splits after a little bit after you leave the SOS tower", cond = "ww2sos_04_ww2sos_05", enabled = false },
    ["Base Exterior"] = { tooltip = "Splits after descending the communications tower and blowing up the fuel tanks.", cond = "ww2sos_05_slide_of_insanity", enabled = false },
    --#endregion
    --#region Cliff-Side Village splits
    ["Slide"] = { tooltip = "Splits after the slide and when location updates", cond = "slide_of_insanity_cliffs_of_insanity", enabled = false },
    ["LARA! What the hell happened"] = { tooltip = "Splits in tunnel while talking to Roth", cond = "cliffs_of_insanity_vh_cliffs_to_hub_connector_a", enabled = false },
    ["Rope Arrow"] = { tooltip = "Splits after the forced radio convo with Roth", cond = "vh_cliffs_to_hub_connector_a_vh_cliffs_to_hub_connector_b", enabled = false },
    ["Cliff-side Village"] = { tooltip = "Splits in the tunnel before reuniting with Roth for the second time.", cond = "vh_cliffs_to_hub_connector_b_vh_main", enabled = false },
    ["Loss"] = { tooltip = "Splits during the cutscene when you reunite with Roth after cliff-side village", cond = "skip", enabled = false },
    ["Mountain Village 2"] = { tooltip = "Splits after sliding down the hill before radio call with Alex.", cond = "vh_main_vh_hub_to_chasm_connector", enabled = false },
    --#endregion
    --#region Chasm Monastery splits
    ["Cave thing"] = { tooltip = "Splits when entering the cave with the campfire", cond = "vh_hub_to_chasm_connector_ch_hubtochasm", enabled = false },
    ["Pilgrimage"] = { tooltip = "Splits when Lara says 'A pilgrimage...'", cond = "ch_hubtochasm_chasm_entrance", enabled = false },
    ["Mountain pass"] = { tooltip = "splits after the cutscene with captain Jesop dying", cond = "chasm_entrance_ma_monastery_interior", enabled = false },
    ["Big Scary boi"] = { tooltip = "Splits as you are falling down on the pile of bones", cond = "ma_monastery_interior_ma_chasm_vista", enabled = false },
    ["Ugh, I Hate Tombs"] = { tooltip = "Splits when entering the 'Ugh, I hate Tomb's' room", cond = "ma_chasm_vista_ma_puzzle", enabled = false },
    ["Bell Cutscene"] = { tooltip = "Splits when Bell Cutscene plays.", cond = "skip", enabled = false },
    ["Bell"] = { tooltip = "Splits after bell cutscene", cond = "ma_puzzle_ma_run_out", enabled = false },
    ["Chasm Monastery"] = { tooltip = "Splits after falling from the collapsing monastery tunnel.", cond = "ma_run_out_ma_chasm_to_hub_connector", enabled = false },
    ["Chasm Monastery(later)"] = { tooltip = "Splits when you get near the obstruction that needs to be destroyed by your shotgun", cond = "ma_chasm_to_hub_connector_vh_chasm_to_hub_connector", enabled = false },
    --#endregion
    --#region Mountain Decent splits
    ["Talk to Roth"] = { tooltip = "Splits after leaving the area where you have the convo with Roth through the crack", cond = "vh_chasm_to_hub_connector_vh_main", enabled = false },
    ["Mountain Village 3"] = { tooltip = "Splits when going down the zip-line to get to waterfall before parachute", cond = "vh_main_vh_vhmain_to_descent_connector", enabled = false },
    ["Time for water slide"] = { tooltip = "Splits right before entering the water", cond = "vh_vhmain_to_descent_connector_de_descent", enabled = false },
    ["Time for Parachute"] = { tooltip = "Splits when getting the parachute", cond = "de_descent_de_descent_to_scav_hub_connector", enabled = false },
    ["Mountain Descent"] = { tooltip = "Splits after completing the parachute QTE when entering the Shantytown.", cond = "de_descent_to_scav_hub_connector_sh_scavenger_hub", enabled = false },
    --#endregion
    --#region Shantytown splits
    ["Shantytown (North"] = { tooltip = "Splits when Lara goes through the gate to the southern part of Shantytown.", cond = "sh_scavenger_hub_sh_scavenger_hub_2", enabled = false },
    ["Shantytown (South) (to Geothermal Caverns)"] = { tooltip = "Splits after leaving Shantytown to go into the Geothermal Caverns.", cond = "sh_scavenger_hub_2_sh_scavenger_hub_to_geothermal_connector", enabled = false },
    ["Shantytown (South) (to Geothermal Caverns) later"] = { tooltip = "Splits after leaving Shantytown to go into the Geothermal Caverns. After the water.", cond = "sh_scavenger_hub_to_geothermal_connector_bi_entrance", enabled = false },
    --#endregion
    --#region Geothermal Cavern splits
    ["Sam Trial of Fire"] = { tooltip = "Splits when right before when sam has her trial of fire cutscene", cond = "bi_entrance_bi_ceremony", enabled = false },
    ["Blood Bath"] = { tooltip = "Splits when lara leaves the blood pool", cond = "bi_ceremony_bi_pit", enabled = false },
    ["Cannibals"] = { tooltip = "Splits when leaving the mini puzzle area with the cannibals", cond = "bi_pit_bi_catacombs", enabled = false },
    ["A Ceremony"] = { tooltip = "Splits when getting to Ceremony room", cond = "bi_catacombs_bi_altar_room", enabled = false },
    ["Reyes, Jonah, Alex Your ALIVE!"] = { tooltip = "Splits when getting to the puzzle room", cond = "bi_altar_room_bi_puzzle", enabled = false },
    ["Geothermal Caverns(sooner)"] = { tooltip = "Splits when doing friendship skip.", cond = "bi_puzzle_bi_exit", enabled = false },
    ["Geothermal Caverns"] = { tooltip = "Splits when entering the Solarii Fortress.", cond = "bi_exit_ge_01", enabled = false },
    --#endregion
    --#region Solarii fortress splits
    ["Explosions EveryWhere"] = { tooltip = "Splits when lara has to climb the rock wall while everything is exploding", cond = "ge_01_ge_02", enabled = false },
    ["Doctor Whitman?"] = { tooltip = "Splits when getting to cutscene with Doctor Whitman", cond = "ge_02_ge_02_a", enabled = false },
    ["Weapons"] = { tooltip = "Splits when getting your weapons back fight", cond = "ge_02_a_ge_03", enabled = false },
    ["Burning room"] = { tooltip = "Splits when you leave burning room of first fight", cond = "ge_03_ge_04", enabled = false },
    ["Grenade launcher"] = { tooltip = "Splits during when lara attaches the grenade launcher to her rifle", cond = "skip", enabled = false },
    ["Grenade Launcher alt"] = { tooltip = "Splits after blowing up the wall after getting the Grenade Launcher", cond = "ge_04_ge_06", enabled = false },
    ["Sam"] = { tooltip = "Splits when in the cutscene when sam picks up a pistol", cond = "ge_06_ge_07", enabled = false },
    ["Solarii Fortress"] = { tooltip = "Splits at gate with sam in Solarii Fortress", cond = "ge_07_ge_08", enabled = false },
    ["Burning Building"] = { tooltip = "Splits when leaving the burning building with the zip-line", cond = "ge_08_tt_two_towers", enabled = false },
    ["Helicopter"] = { tooltip = "Splits during helicopter crash cutscene", cond = "tt_two_towers_tt_connector_to_rc_01_marsh", enabled = false },
    ["Fortress Tower"] = { tooltip = "Splits after the helicopter crash cutscene.", cond = "tt_connector_to_rc_01_marsh_rc_01_marsh", enabled = false },
    --#endregion
    --#region Summit Forest splits
    ["Time for stealth again"] = { tooltip = "Splits when getting to the stealth area", cond = "rc_01_marsh_rc_15_camp", enabled = false },
    ["Doggies"] = { tooltip = "Warning will split even if u die at said split point. Splits when touching the bridge before the caged wolf area", cond = "rc_15_camp_rc_20_wolfden", enabled = false },
    ["Summit Forest"] = { tooltip = "Splits when exiting the Summit Forest cave towards Shantytown.", cond = "rc_20_wolfden_sh_scavenger_hub_2", enabled = false },
    --#endregion
    --#region Air Ship Splits
    ["Shantytown (South) (to Gondola)"] = { tooltip = "Splits when exiting from the Shantytown via the gondola.", cond = "sh_scavenger_hub_2_tb_skub_to_kick_the_bucket", enabled = false },
    ["Gondola Transport Hard Stop"] = { tooltip = "Splits when the transport hard stops", cond = "tb_skub_to_kick_the_bucket_tb_to_beach", enabled = false },
    ["Gondola Transport"] = { tooltip = "Splits after completing the gondola QTE and falling into the river at the bottom.", cond = "tb_to_beach_tb_to_beach_to_beach_hub_connector", enabled = false },
    --#endregion
    --#region Beach Splits
    ["Where's Alex"] = { tooltip = "Splits during the cutscene where you reunite with the crew on the beach", cond = "skip", enabled = false },
    ["Compound bow"] = { tooltip = "Splits during the cutscene when Jonah gives you the Compound bow", cond = "skip", enabled = false },
    ["Shipwreck Beach (to Cliff-side Bunker)"] = { tooltip = "Splits when leaving the beach towards the bunker.", cond = "bh_beach_hub_sb_01", enabled = false },
    ["WW2 Base to Endurance"] = { tooltip = "Splits when dropping down to the Endurance", cond = "sb_05_sb_15", enabled = false },
    --#endregion
    --#region WW2 Bunker splits
    ["Goaliath"] = { tooltip = "Splits when getting the rope ascender cutscene", cond = "skip", enabled = false },
    ["Goaliath Done"] = { tooltip = "Splits when dropping down the hole in the endurance", cond = "sb_15_sb_16", enabled = false },
    ["Mirror"] = { tooltip = "Splits during the cutscene with lara looking herself in the mirror on the endurance", cond = "skip", enabled = false },
    ["2nd half of endurance time"] = { tooltip = "Splits when dropping the hole in the 2nd half of the endurance", cond = "sb_16_sb_20", enabled = false },
    ["Alex who?"] = { tooltip = "Splits during alex death cutscene", cond = "skip", enabled = false },
    ["Alex is Dead"] = { tooltip = "Splits after alex death cutscene", cond = "sb_20_sb_21", enabled = false },
    ["Endurance(early)"] = { tooltip = "Splits while lara is leaving the 2nd half of the endurance", cond = "sb_21_sb_15", enabled = false },
    ["Endurance(later)"] = { tooltip = "Splits when leaving the Endurance area", cond = "sb_15_sb_05", enabled = false },
    ["Book"] = { tooltip = "Splits during the book cutscene", cond = "skip", enabled = false },
    ["Cliff-side Bunker"] = { tooltip = "Splits when leaving the bunker towards the beach.", cond = "sb_01_bh_beach_hub", enabled = false },
    --#endregion
    --#region Research Base Splits
    ["Tools"] = { tooltip = "Splits during the cutscene when lara gives Ryes the tools", cond = "skip", enabled = false },
    ["Shipwreck Beach (to Research Base)"] = { tooltip = "Splits when jumping down into the Research Base.", cond = "bh_beach_hub_si_05_bunker_to_research_connector", enabled = false },
    ["2 Enemies time"] = { tooltip = "Splits when getting near the campfire with the 2 enemies", cond = "si_05_bunker_to_research_connector_si_10_research", enabled = false },
    ["Elevator puzzle time"] = { tooltip = "Splits when getting to elevator puzzle", cond = "si_10_research_si_15_elevator", enabled = false },
    ["Elevator puzzle done"] = { tooltip = "Splits when you leave the elevator puzzle area", cond = "si_15_elevator_si_20_machinery", enabled = false },
    ["Time for annoying ass fight"] = { tooltip = "Splits when you enter the annoying ass fight area", cond = "si_20_machinery_si_25_tomb", enabled = false },
    ["Samurai"] = { tooltip = "Splits on Samurai cutscene in Research base", cond = "skip", enabled = false },
    ["Research Base Early"] = { tooltip = "Splits when leaving Research Base (Early version)", cond = "si_25_tomb_si_30_tomb_to_bh_connector", enabled = false },
    ["Research Base"] = { tooltip = "Splits when leaving Research Base", cond = "si_30_tomb_to_bh_connector_bh_beach_hub", enabled = false },
    ["Shipwreck Beach (Boat to Mountain Pass)"] = { tooltip = "Splits after departing down the river from the beach with Reyes and Jonah.", cond = "bh_beach_hub_ptboat_cine", enabled = false },
    --#endregion
    --#region Chasm Monastery 2
    ["Bye Reyes bye Jonah"] = { tooltip = "Splits after the un-skippable cutscene", cond = "ptboat_cine_chasm_entrance", enabled = false },
    ["Dr James Whitman"] = { tooltip = "Splits during Whitman death cutscene", cond = "skip", enabled = false },
    ["shit ton of guards time"] = { tooltip = "Splits when entering the chasm Monastery via the window", cond = "chasm_entrance_mb_eatery", enabled = false },
    ["Goaliath Armor"] = { tooltip = "Splits when entering the Goaliath Armor room", cond = "mb_eatery_mb_readyroom", enabled = false },
    ["Lara Discovered"] = { tooltip = "Splits when Lara gets discovered in the Goaliath armor room", cond = "mb_readyroom_chasm_streamhall_01", enabled = false },
    ["Mini Slide"] = { tooltip = "Splits after awkward camera angle run and going down the slide", cond = "chasm_streamhall_01_mb_candlehall_combat", enabled = false },
    ["3 Oni and 1 Girl"] = { tooltip = "Splits when you get to the day camp after the 3 Oni", cond = "mb_candlehall_combat_chasm_streamhall_02", enabled = false },
    ["Big Fight"] = { tooltip = "Splits when opening the door to windy area", cond = "chasm_streamhall_02_chasm_bridge", enabled = false },
    ["Chasm Stronghold"] = { tooltip = "Splits when entering the door after the windy bridge with the big fat oni", cond = "chasm_bridge_qt_pre_stalker_arena", enabled = false },
    ["Chasm Shrine puzzle room time"] = { tooltip = "Splits when entering the puzzle room", cond = "qt_pre_stalker_arena_qt_stalkerfight", enabled = false },
    ["Lara Realizes"] = { tooltip = "Splits when entering the room where Lara realizes Mathias purpose for all this", cond = "qt_stalkerfight_qt_hall_of_queens", enabled = false },
    --#endregion
    --#region Chasm Shrine
    ["Point of no Return"] = { tooltip = "Splits when getting to the point of no return cutscene", cond = "qt_hall_of_queens_qt_trial_by_fire", enabled = false },
    ["Chasm Shrine"] = { tooltip = "Splits when crossing the bridge before the ziggurat.", cond = "qt_trial_by_fire_qt_scale_the_ziggurat", enabled = false },
    ["Almost there"] = { tooltip = "Splits when you get to the camp right before the final climb", cond = "qt_scale_the_ziggurat_qt_zig_to_ritual_connector", enabled = false },
    ["Climb"] = { tooltip = "Splits when you get to the top of the spire and the cutscene activates", cond = "qt_zig_to_ritual_connector_qt_the_ritual", enabled = false },
    --#endregion
    -- [""] = { tooltip = "", cond = "", enabled = false },
}
local EnabledSettings = {}
function TableInsert(table, val)
    local i = #table + 1
    table[i] = val
end
function PopulateEnabledSettings()
    for key, value in pairs(settings) do
        if value.enabled == true and value.cond ~= "skip" then
            TableInsert(EnabledSettings, value.cond)
        end
    end
end 
local CompletedSpecialSplits = {}
function TableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end
function startup()
    refreshrate = 60
end
function state()
    old.FMV = current.FMV
    old.cutscene = current.cutscene
    old.isloading = current.isloading
    old.level = current.level
    old.newGameSelect = current.newGameSelect
    old.saveSlot = current.saveSlot
    old.bowAmmo = current.bowAmmo
    old.Camp = current.Camp
    old.Ammo = current.Ammo
    old.GLA = current.GLA
    old.percentage = current.percentage

    current.FMV = readAddress("bool", "binkw32.dll", 0x2830C)
    current.cutscene = readAddress("int", 0x20C97C0)
    current.isloading = readAddress("bool", 0x1DDBC51)
    current.Camp = readAddress("int", 0x107DD60)
    current.level = readAddress("string50", 0x1DC18D8)
    current.percentage = readAddress("float", 0x01CDD540, 0x24)
    current.newGameSelect = readAddress("int", 0x020CF83C, 0x100, 0x24)
    current.saveSlot = readAddress("int", 0x020CF83C, 0xFC, 0x24)
    current.GLA = readAddress("int", 0x20D0014)
    current.Ammo = readAddress("int", 0x20D0000)
    current.bowAmmo = readAddress("int", 0x20CFD80)
    --[[ print("current fmv: " .. tostring(current.FMV))
    print("current loading: " .. tostring(current.isloading))
    print("current cutscene: " .. current.cutscene)
    print("current bowAmmo: " .. current.bowAmmo)--]]   
    
end

function start()
    -- starts after the fmv
    if current.FMV and current.isloading and current.cutscene ~= 8 and current.level == "cine_chaos_beach" and old.level ~= "cine_chaos_beach" and current.saveSlot >= 1 then
        CompletedSpecialSplits = {}
        EnabledSettings = {}
        PopulateEnabledSettings()
        print("started on new save")
        return true
    end
    -- starts after the load or when reloading checkpoint
    if old.isloading and not current.isloading and current.level == "survival_den97" then
        CompletedSpecialSplits = {}
        EnabledSettings = {}
        PopulateEnabledSettings()
        print("started on premade save")
        return true
    end
end

function split()
    --#region special splits
    if settings["Bow"].enabled == true and TableContains(CompletedSpecialSplits, "Bow") == false and current.level == "ac_forest" and current.bowAmmo > old.bowAmmo and old.bowAmmo > -1 then
        TableInsert(CompletedSpecialSplits, "Bow")
        return true
    end
    if settings["First Skill"].enabled == true and TableContains(CompletedSpecialSplits, "First Skill") == false and current.level == "ac_forest" and current.cutscene == 520 and current.Camp == 0 and old.Camp == 1 then
        TableInsert(CompletedSpecialSplits, "First Skill")
        return true
    elseif settings["First Skill"].enabled == true and TableContains(CompletedSpecialSplits, "First Skill") == false and current.level == "ac_forest" and  current.cutscene == 8 and old.cutscene == 520 and current.bowAmmo > 0 then
        TableInsert(CompletedSpecialSplits, "First Skill")
        return true
    end
    if settings["VLADIMIR!"].enabled == true and TableContains(CompletedSpecialSplits, "VLADIMIR!") == false and current.level == "mountain_climb" and current.cutscene == 520 and (current.Ammo == 0 or (current.bowAmmo >= 0 and current.Ammo >= 0)) then
        TableInsert(CompletedSpecialSplits, "VLADIMIR!")
        return true
    end
    if settings["Chimney Alt"].enabled == true and TableContains(CompletedSpecialSplits, "Chimney Alt") == false and current.level == "vh_main" and current.cutscene == 520 and current.percentage >= 8.0 then
        TableInsert(CompletedSpecialSplits, "Chimney Alt")
        return true
    end
    if settings["Wolves"].enabled == true and TableContains(CompletedSpecialSplits, "Wolves") == false and current.level == "vh_main" and current.cutscene == 521 and old.cutscene ~= 521 then
        TableInsert(CompletedSpecialSplits, "Wolves")
        return true
    end
    if settings["CampFire"].enabled == true and TableContains(CompletedSpecialSplits, "CampFire") == false and current.level == "ww2_sos_01" and current.cutscene == 520 and old.cutscene == 8 then
        TableInsert(CompletedSpecialSplits, "CampFire")
        return true
    end
    if settings["CampFireAlt"].enabled == true and TableContains(CompletedSpecialSplits, "CampFireAlt") == false and current.level == "ww2_sos_01" and current.FMV == true then
        TableInsert(CompletedSpecialSplits, "CampFireAlt")
        return true
    end
    if settings["Ambush Room"].enabled == true and TableContains(CompletedSpecialSplits, "Ambush Room") == false and current.level == "ww2sos_map_room" and current.cutscene == 520 then
        TableInsert(CompletedSpecialSplits, "Ambush Room")
        return true
    end
    if settings["Loss"].enabled == true and TableContains(CompletedSpecialSplits, "Loss") == false and current.level == "vh_main" and current.cutscene == 520 and current.percentage >= 19.72 then
        TableInsert(CompletedSpecialSplits, "Loss")
        return true
    end
    if settings["Bell Cutscene"].enabled == true and TableContains(CompletedSpecialSplits, "Bell Cutscene") == false and current.level == "ma_puzzle" and current.cutscene == 520 then
        TableInsert(CompletedSpecialSplits, "Bell Cutscene")
        return true
    end
    if settings["Grenade launcher"].enabled == true and TableContains(CompletedSpecialSplits, "Grenade launcher") == false and current.level == "ge_04" and current.GLA == 0 and old.GLA ~= current.GLA and current.cutscene >= 520 then
        TableInsert(CompletedSpecialSplits, "Grenade launcher")
        return true
    end
    if settings["Where's Alex"].enabled == true and TableContains(CompletedSpecialSplits, "Where's Alex") == false and current.level == "bh_beach_hub" and current.cutscene == 520 and current.percentage >= 40.14 then
        TableInsert(CompletedSpecialSplits, "Where's Alex")
        return true
    end
    if settings["Compound bow"].enabled == true and TableContains(CompletedSpecialSplits, "Compound bow") == false and current.level == "bh_beach_hub" and current.cutscene == 520 and current.percentage >= 42.14 then
        TableInsert(CompletedSpecialSplits, "Compound bow")
        return true
    end
    if settings["Goaliath"].enabled == true and TableContains(CompletedSpecialSplits, "Goaliath") == false and current.level == 'sb_15' and current.cutscene == 520 then
        TableInsert(CompletedSpecialSplits, "Goaliath")
        return true
    end
    if settings["Mirror"].enabled == true and TableContains(CompletedSpecialSplits, "Mirror") == false and current.level == 'sb_16' and current.cutscene == 520 then
        TableInsert(CompletedSpecialSplits, "Mirror")
        return true
    end
    if settings["Alex who?"].enabled == true and TableContains(CompletedSpecialSplits, "Alex who?") == false and current.level == 'sb_20' and current.cutscene == 520 then
        TableInsert(CompletedSpecialSplits, "Alex who?")
        return true
    end
    if settings["Book"].enabled == true and TableContains(CompletedSpecialSplits, "Book") == false and current.level == 'sb_05' and current.cutscene == 520 then
        TableInsert(CompletedSpecialSplits, "Book")
        return true
    end
    if settings["Tools"].enabled == true and TableContains(CompletedSpecialSplits, "Tools") == false and current.level == "bh_beach_hub" and current.cutscene == 520 and current.percentage >= 46.83 then
        TableInsert(CompletedSpecialSplits, "Tools")
        return true
    end
    if settings["Samurai"].enabled == true and TableContains(CompletedSpecialSplits, "Samurai") == false and current.level == "si_25_tomb" and current.cutscene == 520 then
        TableInsert(CompletedSpecialSplits, "Samurai")
        return true
    end
    if settings["Dr James Whitman"].enabled == true and TableContains(CompletedSpecialSplits, "Dr James Whitman") == false and current.level == "chasm_entrance" and current.cutscene == 520 and old.cutscene == 8 and current.GLA > -1 then
        TableInsert(CompletedSpecialSplits, "Dr James Whitman")
        return true
    end
    --#endregion
    --[[ extra if conditions
    if settings[""].enabled == true and table.contains(CompletedSpecialSplits, "") == false and then
        TableInsert(CompletedSpecialSplits, "")
        return true
    end
    --]]
    --#region Main Split logic
    if old.level ~= current.level then
        local LevelTransition = old.level .. "_" .. current.level
        if TableContains(EnabledSettings, LevelTransition) == true and TableContains(CompletedSpecialSplits, LevelTransition) == false then
            TableInsert(CompletedSpecialSplits, LevelTransition)
            return true
        end
    end
    -- ending split everyone wants this split so hard code it.
    if current.level == "qt_the_ritual" and current.cutscene == 712 and old.cutscene ~= 712 then
        return true
    end
end

function isLoading()
   --[[ if current.cutscene ~= 8 and (current.bowAmmo == -1 or current.isloading == true or current.FMV == true) then
        return true
    elseif current.bowAmmo == -1 or current.isloading == true or current.FMV == true then
        return true
    elseif current.cutscene >= 520 and (current.bowAmmo == -1 or current.isloading == false or current.FMV == false) and current.level ~= "main_menu" then
        return true
    end
    --]]
--[[    if current.level == "qt_the_ritual" and current.cutscene == 712 and old.cutscene ~= 712 then
        return false
    else-
    if current.FMV or current.isloading or current.bowAmmo == -1 or current.cutscene ~=8 then
        print("2nd if statement")
        return true
    end-]]
    --return current.FMV or current.isloading or current.bowAmmo == -1 or current.cutscene ~=8
    return (current.isloading or current.FMV or current.cutscene > 8 or current.cutscene < 8 or current.bowAmmo == -1) and current.level ~= "main_menu"

end
