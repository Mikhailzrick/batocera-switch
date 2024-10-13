
-----NO MORE HEROES 3 GRAPHICS MOD-----
-----BY NikkMann-----------------------
-----Last Updated Sept. 29, 2021 (V2.2)---


--HOW TO INSTALL--

The mod comes in 2 versions, Normal and High Open World Distance. The only difference between them is how far out the open world renders,
as that heavily affects performance. Everything else is exactly the same. If you are getting 
constant crashes in the open world, try the Normal version.

Installing is the same for both Yuzu and Ryujinx. In each Quality folder you’ll see presets for the resolution and effect combo you 
want. MB=Motion Blur.  You can get to the game's mod location  by right-clicking it in your emulator 
and there should be an option to open the mod directory. Pick the folder for the preset you want and copy it to the game’s mod directory. 
For example, copy the "1440+MB_HighOpenWorldDistance" folder to the mod directory.

On both Ryujinx and Yuzu, enable the "6GB DRAM" setting for the emulator to avoid crashes.
Keep the resolution scale at Native, as my mod will completely handle the resolution.


--FEATURES--

-Greatly increase draw distance quality in the open world and in general for all objects (for the High Open World Distance version)
---NOTE: It will be a bit laggy when first loading into the open world because it is loading ALOT more all at once

-Increase quality of all graphical effects to the normal max setting unreal engine uses for PC games (Bloom, depth of field, lens flares, ambient occlusion, etc)
----NOTE: Depth of field has a small issue when going above 720p (the game's default resolution). DoF is only used in cutscenes, and in certain sections of certain cutscenes
		  it may be slightly off for a second or 2 because it was originally configured with the 720p resolution in mind. You probably won't even notice it, but if you think that things
		  are a little more blurry than they should be for certain parts of cutscenes that use DoF, thats why. Nothing I can do to fix it.

-Enable higher quality Temporal Anti-Aliasing with some custom tuning by me to fix jagged edges and image stability issues while maintaining sharpness

-Increase texture quality to the highest the game has available

-Increase texture quality transition distance (no more obvious line of blurry texture transition ahead of you when on the bike)

-Enable x16 Anisotropic Filtering to increase texture quality at farther distances

-Greatly increase the quality and render distance of shadows, including self-shadows on characters

-Increase hair rendering quality and enable hair to cast shadows in normal gameplay

-Increase lighting and shading quality and light render distance

-(Optional) Enable my own tuned per-object motion blur



---V2.2 CHANGES---

-Fixed an issue PRESENT IN THE BASE GAME where shadows would clip through characters and enemies

-Improved the quality of shadows in the small number of arenas where full dynamic shadows are used

-Fixed an issue where shadows did not match up with the original game's presentation in a small number of areas. 
This was essentially because I made the shadow setting "too high" causing them to be rendered differently. 
There is visually no change to shadow quality from previous mod versions, its just more accurate to the original game now.



--V2 CHANGES--

-Offer Normal and High Open World Distance presets

-Optimized streaming pool size. Should no longer instant crash when trying to load into the open world on Yuzu.

-Fixed depth of field not rendering in cutscenes at all

-Tuned roughness of screen space reflecions (SSR). Now only objects that should have SSR will have it, and everything 
that has it won't look like a polished mirror. SSR is now enabled by default on all presets. Thanks to cucholix on the GBATemp forums for finding the fix!

-Further improved the distance at which detailed contact shadows fade

-Further increased the quality of character rendering. Characters should now render at their max possible quality at all times.

-Slightly tuned Temporal Anti Aliasing to be a bit sharper with less ghosting and eliminate shimmering

-Slightly tuned Motion Blur to now not have any artifacting around Travis when moving the camera while running

-Cleaned up alot of unnecessary commands
