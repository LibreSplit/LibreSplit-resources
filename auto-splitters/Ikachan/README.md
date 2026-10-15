# Ikachan Autosplitter for Libresplit by Tepiloxtl
Autosplitter for PC version of Ikachan. Supports latest Japanese release. Using brand sparkling new Settings API...

## Configuration
With latest version of Libresplit, autosplitter settings (and path to autosplitter itself) are stored within your splits .json file in new `auto_splitter_settings` key. For now, they can only be added/edited via manually editing your .json file.

Available options are:
### Starting/ending splits
* `start_split` (bool) - Split on "Push Z button" prompt
* `nooob_split` (bool) - Split for end of Any% No OOB

### Event splits
* `event_flag_2_1` (bool) - Talk to Fooze, agree to help
* `event_flag_3_1` (bool) - Zuu fight start
* `event_flag_4_1` (bool) - Zuu fight end
* `event_flag_5_1` (bool) - Talk to Jisin, first quake
* `event_flag_7_1` (bool) - Get Sand Dollar
* `event_flag_8_1` (bool) - First talk with Carry
* `event_flag_9_1` (bool) - Deliver shrimp platter
* `event_flag_10_1` (bool) - Deliver crab platter
* `event_flag_11_1` (bool) - Ask Fooze for globefish platter
* `event_flag_12_1` (bool) - Talk to blue urchin, second quake
* `event_flag_14_1` (bool) - Get Capacitor
* `event_flag_15_1` (bool) - Rescue Pinky
* `event_flag_16_1` (bool) - Get globefish platter from Pinky
* `event_flag_17_1` (bool) - Deliver globefish platter
* `event_flag_18_1` (bool) - Defeat Ironhead
* `event_flag_19_1` (bool) - Rescue Zuu

### Misc splits
* `equip_flag_0_1` (bool) - Get Pointed Hat
* `inv_flag_2_1` (bool) - Get Sand Dollar
* `equip_flag_2_1` (bool) - Get Pearl
* `equip_flag_2_0` (bool) - Get Lose Pearl
* `equip_flag_1_1` (bool) - Get Capacitor
* `inv_flag_10_1` (bool) - Get Ben
* `equip_flag_4_1` (bool) - Get Spaceship