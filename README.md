# Buildmode-ULX
Hopefully prevent Builders from abusing GodMode

Hopefully prevents PVPers from bothering Builders

## Current Features:
* Easy to use, organized UI
* Builders are 100% unable to deal damage
* Anti-Prop Minge for both Builders and PVPers
* Custom Limits for Builder Weapons and Entities
* Custom Colors for Builder and PVPer Halos
* Noclip for Builders only
* More to come...

## Details

![alt text](https://i.imgur.com/1blRo5X.png "ULX Settings Page")

* Players Spawn With Buildmode
  * When a player first spawns in the server, or later respawns, Buildmode becomes enabled.
* Override the above if the player enables PVP
  * Allows the player to explicitly stay in Buildmode when they respawn when the above setting is enabled
* Buildmode Delay
  * The amount of time (in seconds) that the player has to wait before Buildmode is enabled
  * Useful for preventing players from entering Buildmode just to not be killed
  

  ![alt text](https://i.imgur.com/r2Xg49y.png "ULX Settings Page")
  ![alt text](https://i.imgur.com/ShtCPL7.png "ULX Settings Page")
  
* Restrict weapons with 'Builder Weapons'
  * Limit Builders' loadouts using the list on the "Advanced" tab
  * Builders can only spawn or pickup weapons from this list, while enabled
  * Useful for cleaning a Builder's inventory
  * If disabled Builders can still have weapons, however they can not do any damage
  * Can be a whitelist or a blacklist
  * Default is a whitelist of the physgun toolgun, and camera
* Restrcit SENTs with 'Builder SENTs'
  * Limit the SENTs a Builder can spawn using the list on the "Advanced" tab
  * Useful for preventing Builders from spawning explosive SENTs
  * Can be a whitelist or a blacklist
  * Default is a blacklist of nothing
  * Added per Feature Request https://github.com/kythre/Buildmode-ULX/issues/26
* Allow Prop Spawn in PVP
  * When disabled only Builders and admins can spawn props
  * Useful for preventing PVPers from Building
* Alow Noclip in Buildmode
  * When enabled, Builders can use the default Sandbox noclip ("noclip" in console).
  * Does not affect ULX Noclip
  * sbox_noclip must be 0
  * I recommend installing [UClip](https://github.com/TeamUlysses/uclip) so Builders can't noclip through the world, players, or anyone else's props.
* Prevent Propkill in Buildmode
  * No-collides Builders' Props when are spawned, so they can't be dropped on players
  * No-collides Builders' Props when they are physgunned so they can not be used to proppush or propclimb
  * No-collides Builders' Vechiles when they are are being driven so you can not run other players over or mess up their buildings
  * Disables no-collide when the props and vehicles are not moving and there is nothing inside them.
* Highlight Builders
  * Renders a colored halo around Builders
  * Color can be configured on the "Advanced" tab
  * Default color is Blue
* Highlight PVPers
  * Color can be configured on the "Advanced" tab
  * Default color is Red
* Highlight Only When Looking
  * Only the player you are looking at is highlighted
* Show Text Status
  * Displays a the build status of a player under their health when you hover over them
    ![alt text](https://i.imgur.com/BlVHNPI.png")
  

  ![alt text](https://i.imgur.com/OK0Q00w.png "ULX Settings Page")


* Return Player to spawn on Buildmode exit
  * Teleports the player back to spawn when they exit Buildmode
  * Useful for preventing abuse of Builder Noclip to fly in to players' bases
* PVP Delay
  * The amount of time (in seconds) that the player has to wait before Buildmode is disabled
  * Useful for preventing players from exiting Buildmode just to kill someone
  
![alt text](https://i.imgur.com/2HgSZ3F.png "ULX Settings Page")

  
* Builder Halo Color
  * RGB Selection for custom halo color 
* PVPer Halo Color
  * RGB Selection for custom halo color
* Builder Weapons
  * List of weapons that Builders can or can not have
  * List is a Blacklist determines whether the above list is for allowed weapons or disallowed weapons
  * Type the weapon in to the box, then press the + button to add
  * Select the weapon from the list, then press the - button to remove
  * The + button will turn into a - button automatically
* Builder SENTs
  * List of sents that Builders can or can not have
  * List is a Blacklist determines whether the above list is for allowed weapons or disallowed sents
  * Type the weapon in to the box, then press the + button to add
  * Select the weapon from the list, then press the - button to remove
  * The + button will turn into a - button automatically
  
  
