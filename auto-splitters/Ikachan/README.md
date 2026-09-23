# Ikachan Autosplitter for Libresplit by Tepiloxtl
Autosplitter for PC version of Ikachan. Supports latest Japanese release. Using brand sparkling new Settings API...

## Configuration
With latest version of Libresplit, autosplitter settings (and path to autosplitter itself) are stored within your splits .json file in new `auto_splitter_settings` key. For now, they can only be added/edited via manually editing your .json file.

Available options are:
* `start_split` (bool) - Split on "Push Z button" prompt
* `nooob_split` (bool) - Split for end of Any% No OOB
* `event_split` (bool) - Has to be true for event flags below to take effect
* `event_flag_2` (bool) - Talk to Fooze, agree to help
* `event_flag_3` (bool) - Zuu fight start
* `event_flag_4` (bool) - Zuu fight end
* `event_flag_5` (bool) - Talk to Jisin, first quake
* `event_flag_7` (bool) - Get Sand Dollar
* `event_flag_8` (bool) - First talk with Carry
* `event_flag_9` (bool) - Deliver shrimp platter
* `event_flag_10` (bool) - Deliver crab platter
* `event_flag_11` (bool) - Ask Fooze for globefish platter
* `event_flag_12` (bool) - Talk to blue urchin, second quake
* `event_flag_14` (bool) - Get Capacitor
* `event_flag_15` (bool) - Rescue Pinky
* `event_flag_16` (bool) - Get globefish platter from Pinky
* `event_flag_17` (bool) - Deliver globefish platter
* `event_flag_18` (bool) - Defeat Ironhead
* `event_flag_19` (bool) - Rescue Zuu

There is a big lack of splits after defeating Ironhead, that's because most of everything after that is tracked in other variables, bringing those in is on TODO
