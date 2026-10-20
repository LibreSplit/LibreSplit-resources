# Star Wars Racer - Auto Splitter (for LibreSplit)
**A script that automates LibreSplit's timer, for Star Wars Episode I Racer speedruns.**  
Based on [Galeforce's LiveSplit Autosplitter](https://github.com/everalert/swe1r-autosplitter) v0.5.1  
The same auto splitter logic converted to Lua, with some compatibility changes, and additions.

> [!note]
> This script has the requirements for all run categories, but some issues still remain, so is still somewhat a work in progress.
>   
> *\*\*Starred Features\*\** indicate that, that feature currently has some kind issue. The details of any issue are provided under the relevant section in this readme.
  
### Features
* Auto start when file is opened, or *\*\*optionally when "Start Race" is selected\*\**
* Auto split at race finish, with toggle for 1st place requirement
* Auto reset, with choice of reset location
* Choice of LRT, or IGT timing methods 
* Option to remove tabbed-out/unfocused time

### Required
* [Download](https://github.com/Wuzzmi/swe1r_auto-splitter-libresplit/archive/refs/heads/main.zip) auto splitter
* [LibreSplit](https://github.com/LibreSplit/LibreSplit/tree/main)
* [JSON splits](https://github.com/Wuzzmi/swe1r_splits-libresplit/tree/master), or [converted](https://libresplit.org/converter) LSS splits
* Installation of the re-released PC version of Star Wars Episode I Racer (Steam, GOG, etc.)  
    - does not work with the original CD version

### Auto Splitter Settings
Auto splitter settings can be adjusted within each split file, under the "auto_splitter_settings" section. 

```json
"auto_splitter_settings": {
  "autoReset": 2,
  "removeTabbedTime": false,
  "require1st": false,
  "startRaceTrig": false,
  "useInRaceGT": false
},
```

All settings are described in greater detail below.   

> [!note]
> * Do not remove any commas when editing settings!
> * Eventually there should be a GUI option, but this in not implemented is LibreSplit yet.
  
### Enable Script
* Open LibreSplit
* Right click, to open the auto splitter and select "Enable Auto Splitter" 
  
![Rightclick in LibreSplit](https://github.com/Wuzzmi/repo-media/blob/main/Wuzzmi-LibreSplit-resources/img/rightclick-autosplitter-libresplit.png)
  
> [!important]
> * If you edit your settings after the script has already been loaded, you will need to Reload the auto splitter for the changes to take effect.
> * When using a new split file, the auto splitter must be loaded after the split file.
  
**Now everything is all set. The auto splitter will function when you run Star Wars Racer!**

___
### Settings Breakdown
**Auto Reset Trigger**
```json
"autoReset": 2,
```
**```autoReset```** allows you to disable auto reset or choose the location it will be triggered. For any runs that require a file/mode change mid run, it is important to set **```autoReset```** to trigger at a location that will not be reached during the run, or to disable it. This ensures file/mode changes do not reset and ruining the run. Otherwise **```autoReset```** is just personal preference.
|  | Disabled | File Select (Risky) | Main Menu | Settings (Safe) |
|:---:|:---:|:---:|:---:|:---:|
|**autoReset**| 0 | 1 | 2 | 3 |
 
___
**Remove Tabbed-Out/Unfocused Time**
```json
"removeTabbedTime": false,
```
**```removeTabbedTime```** discounts tabbed-out/unfocused time from the timer. It will have no effect if using in race game time.
|  | Tabbed Time Removed | Tabbed Time Counted |
|:---:|:---:|:---:|
|**removeTabbedTime**| true | false |

___
**Require 1st Place**
```json
"require1st": false,
```
**```require1st```** toggles requiring a 1st place finish, to trigger a split. The default win condition is used otherwise, which requires 4th place, or 3rd on the last track of a circuit ( SMR/BB/BEC ). 

*Recommened for: 100%*


|  | Require 1st | Require 4th, 3rd (on SMR/BB/BEC) |
|:---:|:---:|:---:|
|**require1st**| true | false |

___
**Auto Start at Start Race**
```json
"startRaceTrig": false,
```
**```startRaceTrig```** sets the timer to start when "Start Race" is selected, otherwise the timer will start at file open.

*Recommened for: All Tracks NG+*

|  | "Start Race" Selected | File Opened |
|:---:|:---:|:---:|
|**startRaceTrig**| true | false |

> [!important]
> ***\*\*SEMIFUNCTIONAL\*\****
>   
> Currently for the "START RACE" trigger to work, you must enter the track selection scene, then move directly to select "Start Race". If you deviate, just return to the track selection scene before heading to "Start Race".

___
**Use In Race Game Time**
```json
"useInRaceGT": false
```
Enable to use IGT (in race game time), otherwise LRT(load removed time) will be used. IGT is not useful for recording official runs, but can be useful for testing the "total in race game time" under differing run conditions (ex. various upgrade routes, pods, etc.), or other uses if you have one.

|  | In Race Game Time(IGT) | Load Removed Time(LRT) |
|:---:|:---:|:---:|
|**useInRaceGT**| True | false |

___
### License
This repo is unlicensed.
