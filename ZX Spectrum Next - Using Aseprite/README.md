# Aseprite scripts for the ZX Spectrum Next

I have created a series of scripts to be placed in the default Aseprite script folder.<br>
<br>
You can find this by opening Aseprite and in the menu selecting:<br>
_File / Scripts / Open scripts folder_<br>
<br>
SCRIPTS:<br>
_SpectrumNext_SpriteSheet_CreateBlank.lua_<br>
<br>
With this you can select a sprite size of 8 or 16, image grid size in X and Y and how many colours, 16, 256 or 512.<br>
Once you press create it will then make the correct image with a palette of:<br>
<br>
16  - Standard Spectrum<br>
256 - Spectrum Next RRRGGGBB<br>
512 - Spectrum Next RRRGGGBBB<br>
<br><br><br>
_SpectrumNext_Palette_Convert.lua_<br>
<br>
Here you need a colour indexed image to work with or you are working on, then run this script and select the type of colour distancing technique before applying.<br>
It will then use this method to check the palette colours of the image and map them to the closest it can find from the 512 available 9bit colours of the Spectrum Next, hopefully without changing the palette too much.<br>
<br><br><br>
_SpectrumNext_SpriteSheet_Export.lua_<br>
<br>
Use this script to export your sprites or tiles directly from within Aseprite, to load into a memory bank, for example in Boriel Studio or NextBuild. No conversion or other tools are required!<br>
All you have to do is select pixel size of the sprites/tiles, 8 or 16, and number of colours, 16 or 256.<br>
The script will then chop up the image from top left to bottom right.<br>
I will be adding to this very soon to include other features, but this is good to get your started.<br>
<br><br><br>
There will be more useful scripts to follow so make sure you call back.<br>
Have fun and I hope you enjoy the posts and find these materials useful!<br>

Find out all the latest here: https://www.pandapus.com/

