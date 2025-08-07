# Aseprite scripts for the ZX Spectrum Next

I have created a series of scripts you can download and copy directly to the default Aseprite script folder.<br>
<br>
You can find the folder location to copy to, by opening Aseprite and in the menu selecting:<br>
_File / Scripts / Open scripts folder_<br>
<br>
Once copied to the folder, open Aseprite and go to file/scripts and you will see the options to run. If you already have Aseprite open when copying the scripts to the folder, close and open Aseprite again for them to take effect.<br>
<br><br>
SCRIPTS:<br>
_1 - SpectrumNext_SpriteSheet_CreateBlank.lua_<br>
<br>
This will create a blank image with a Spectrum Next default palette ready to draw your creations.<br>
Options on running the script:<br>
<br>
Sprite Size - 8 or 16<br>
Grid Size in X and Y - Enter a positive number<br>
Colours - 16, 256 or 512<br>
<br>
<img width="486" height="440" alt="image" src="https://github.com/user-attachments/assets/bbe71767-fb52-496a-a96b-5573562fa02c" />
<br><br>
Once you press create, it will then make a blank image ready to draw, with a palette of:<br>
<br>
16  - Standard Spectrum<br>
256 - Spectrum Next RRRGGGBB<br>
512 - Spectrum Next RRRGGGBBB<br>
<br>
To change the checkerboard background size when the image is created, you can select: Edit, Preferences and Background, then select the background grid size for the active doc as 8x8 or 16x16.
<br><br>
<img width="938" height="717" alt="image" src="https://github.com/user-attachments/assets/733f94fb-15f0-4eb7-9b52-90e1b8372f58" />
<br>
<br><br><br><br>
_2 - SpectrumNext_SpriteSheet_Export.lua_<br>
<br>
Use this script to export your sprites or tiles directly from within Aseprite, to load into a memory bank, for example in Boriel Studio or NextBuild. No conversion or other tools are required!<br>
All you have to do is select pixel size of the sprites/tiles, 8 or 16, and number of colours, 16 or 256.<br>
The script will then chop up the image from top left to bottom right.<br><br>
<img width="326" height="220" alt="image" src="https://github.com/user-attachments/assets/03adffc1-6c40-4934-85ff-5b5f049d03a9" />
<br>
<img width="332" height="186" alt="image" src="https://github.com/user-attachments/assets/7e143dc6-5e27-4dbd-8d65-f91147bbe21f" />
<br><br>
The size of your spritesheet determines how many sprites/tiles are chopped up, as there is no limit and not capped. For example if you want 64, 16x16 sprites, you could use an image of 64x256 pixels in size or even start with creating a blank image with script 1 above and select 16 for sprite size and grid of 4x16.<br>
The colour palette you use for your image is also down to you, so make sure it is compatible with the Next, however this enables you to use any selection of colours from the 512 available. You would just need to use the same palette in your game.<br>
It has some simple error checking. So if there is no file loaded to export it will exit. If the image is not divisable by either 8 or 16 it will not proceed and if you have more or less colours in your palette than you are trying to export, again it will not proceed.<br>
<br>
I will be adding to this very soon to include other features, like palette export and an option to select the number of sprites to cut up, but this is good to get you started.<br>
<br><br><br><br>
_3 - SpectrumNext_Palette_Convert.lua_<br>
<br>
Here you need a colour indexed image to work with or you are working on (as an example, it could be a title screen image of size 320x256 or 256x192.), then run this script and select the type of colour distancing technique before applying.<br>
<br>
Options are - Euclidean, Manhattan, Chebyshev, CIE76, CIEDE2000<br>
<br>
<img width="818" height="612" alt="image" src="https://github.com/user-attachments/assets/9a9fa85e-0b25-491b-9192-b6dcca307971" />
<br><br>
When run, it will use the method selected to check the palette colours of the image and map them to the closest it can find from the 512 available 9bit colours of the Spectrum Next, hopefully without changing the palette too much.<br>
I will be looking further into this for other possible options which may be useful, so stay tuned!<br>
<br><br><br><br><br>
There will be more useful scripts to follow like palette exporting, so make sure you call back.<br>
Have fun and I hope you enjoy the posts and find these materials useful!<br>

Find out all the latest here: https://www.pandapus.com/

