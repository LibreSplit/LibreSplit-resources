# STAR WARS RACER AUTOSPLITTER (for LibreSplit)
**A script that automates LibreSplit's timer, for Star Wars Episode I Racer speedruns.**  
Based on [Galeforce's LiveSplit Autosplitter](https://github.com/everalert/swe1r-autosplitter) v0.5.1  
The same autosplitter logic converted to Lua, with some compatibility changes, and additions.

> [!note]
> This script includes all of the basic functionalities required for all speedrun categories, but some features still have bugs/caveats, so it's still a work in progress.
>   
> *\*\*Starred Features\*\** indicate that, that feature currently has a bug/caveat associated with it.
  
### FEATURES
* Auto start when file is opened, or *\*\*optionally when "Start Race" is selected\*\**
* Auto split at race finish, with toggle for 1st place requirement
* Auto reset, with choice of reset location
* Optional run category presets
* Choice of LRT, or IGT timing methods 
* Option to remove unfocused/tabbed-out time

### REQUIRES
* [LibreSplit](https://github.com/LibreSplit/LibreSplit/tree/main)
* [JSON splits](https://github.com/Wuzzmi/swe1r-splits-libresplit/tree/master), or [converted](https://libresplit.org/converter) LSS splits
* Installation of the re-released PC version of Star Wars Episode I Racer (Steam, GOG, etc.)  
    - does not work with the original CD version

### AUTOSPLITTER SETTINGS
Autosplitter settings can be adjusted near the bottom of each split file, under the "auto_splitter_settings" section. Eventually there should be a gui option, but this in not implemented in LibreSplit yet. 

```json
  "auto_splitter_settings": {
    "preset": 1,
    "loadlessRT": true,
    "require1st": false,
    "startRaceTrig": false,
    "autoReset": 2,
    "removeTabbedTime": false
  },
```
All settings are described in greater detail below.   
  
## ENABLE SCRIPT
* Open LibreSplit
* Right click, to open the autosplitter and select "Enable Autosplitter" 
  
![Rightclick in LibreSplit](https://github.com/Wuzzmi/repo-media/blob/main/Wuzzmi-LibreSplit-resources/img/rightclick-autosplitter-libresplit.png)
  
> [!important]
> If you edit your script settings after the script has already been loaded, you will need to right click "Reload" the autosplitter for the changes to take effect.
  
**Now everything is all set. The autosplitter will function when you run Star Wars Racer!**
___  
  
## FULL SETTINGS BREAKDOWN
### CATEGORY PRESET
```json
"preset": 1 
```
**```preset```** is a one setting adjustment for switching run categories. It functions as a override for a number of other settings. For this reason **```preset``` ```0```** exists, allowing full settings control for special use cases.
|  | None | Any% / Amateur / Semi-Pro | 100% | New Game + |
|:---:|:---:|:---:|:---:|:---:|
| **preset** | 0 | 1 | 2 | 3 |  
___
### TIMING METHOD
```json
"loadlessRT": true
```
**```loadlessRT```** functions as a timing method toggle, choose either LRT (Loadless Real Time), or IGT (In Game Race Time). As shown in the table below, every category **```preset```** overrides to LRT . IGT is not useful for recording official runs, but is here for other uses if you have one.

|  | Loadless Real Time | In Race Game Time |
|:---:|:---:|:---:|
|**loadlessRT**| True | false |
| **```preset```** | **```1``` ```2``` ```3```** |  |

___
### WIN CONDITION
```json
"require1st": false
```
**```require1st```** toggles requiring a 1st place finish, to trigger a split. The default win condition is used otherwise, which requires 4th place, or 3rd on the last track of a circuit ( SMR/BB/BEC ). **```require1st```** is typically used for the 100% category.
|  | Require 1st | Require 4th, 3rd (on SMR/BB/BEC) |
|:---:|:---:|:---:|
|**require1st**| true | false |
| **```preset```** | **```2```** | **```1``` ```3```** |

___
### AUTO START TRIGGER
```json
"startRaceTrig": false
```
**```startRaceTrig```** sets the timer to start when "Start Race" is selected, otherwise the timer will start at file open. **```startRaceTrig```** is used for the All Tracks NG+ category, which requires timing to start when selecting "Start Race" for the first track.
|  | "Start Race" Selected | File Opened |
|:---:|:---:|:---:|
|**startRaceTrig**| true | false |
| **```preset```** | **```3```** | **```1``` ```2```** |
> [!important]
> ***\*\*SEMIFUNCTIONAL\*\****
>   
> Currently for the "START RACE" trigger to work, you must enter the track selection scene, then move directly to select "Start Race". If you deviate, just return to the track selection scene before heading to "Start Race". 

___
### AUTO RESET TRIGGER
```json
"autoReset": 2
```
**```autoReset```** allows you to disable auto reset or choose the location it will be triggered. For any runs that require a file/mode change mid run, it is important to set **```autoReset```** to trigger at a location that will not be reached during the run, or to disable it. This ensures file/mode changes do not reset and ruining the run. Otherwise **```autoReset```** is just personal preference.
|  | Disabled | File Select (Risky) | Main Menu | Settings (Safe) |
|:---:|:---:|:---:|:---:|:---:|
|**autoReset**| 0 | 1 | 2 | 3 |
 
___
### REMOVE UNFOCUSED TIME (Tabbed-Out)
```json
"removeTabbedTime": false 
```
Use **```removeTabbedTime```** to register unfocused/tabbed-out time as loading time, so it will not be counted on the timer. **```removeTabbedTime```** will only have an effect if **```loadlessRT = true,```** (LRT). Usage of **```removeTabbedTime```** is up to you.
|  | Tabbed Time Removed | Tabbed Time Counted |
|:---:|:---:|:---:|
|**removeTabbedTime**| true | false |

___

## POSSIBLE FUTURE IMPROVMENTS
* Determine a proper memory address for triggering the timer on "START RACE" selection (currently relying on sceneID, not ideal).
  
## LICENSE
This repo is unlicensed.
