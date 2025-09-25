# Spectres Plugins for the ZX Spectrum Next (Aseprite)

I have created a series of plugin scripts you can download and copy directly to the default Aseprite script folder.

For this, you will need the Aseprite software, which you can find here: https://www.aseprite.org

Once this is installed, the folder location to copy the plugins to, can be found by opening Aseprite and in the menu selecting:
_File / Scripts / Open scripts folder_

Once copied to the folder, open Aseprite and go to file/scripts and you will see the options to run. If you already have Aseprite open when copying the scripts to the folder, close and open Aseprite again for them to take effect.

# PLUGIN SCRIPTS:
## **_1 - SpectrumNext_SpriteSheet_CreateBlank.lua_**

This will create a blank image with a Spectrum Next default palette ready to draw your creations.
Options on running the script:

- Sprite Size - 8 or 16
- Grid Size in X and Y - Enter a positive number
- Colours - 16, 256, 512 or 4096
<br><br>
<img width="486" height="440" alt="image" src="https://github.com/user-attachments/assets/bbe71767-fb52-496a-a96b-5573562fa02c" /><br><br>

Once you press create, it will then make a blank image ready to draw, with a palette of:

- 16 - Standard Spectrum<br>
- 256 - Spectrum Next RRRGGGBB<br>
- 512 - Spectrum Next RRRGGGBBB<br>
- 4096 - Spectrum Next RRRRGGGGBBBB (The proposed 12bit colour palette from KS3)

To change the checkerboard background size when the image is created, you can select: Edit, Preferences and Background, then select the background grid size for the active doc as 8x8 or 16x16.

<img width="938" height="717" alt="image" src="https://github.com/user-attachments/assets/733f94fb-15f0-4eb7-9b52-90e1b8372f58" />
<br><br>
Don't forget that once you have palettes loaded in, you can add them as a preset in Aseprite to use them again, just by selecting them from the preset list.
<br><br>
<img width="748" height="947" alt="image" src="https://github.com/user-attachments/assets/6eb4c12c-09fe-4950-8a0f-601dcc81f26d" />
<br><br>
You can save multiple presets to make your life easier.
<br><br>
<img width="599" height="269" alt="image" src="https://github.com/user-attachments/assets/b2c3c3af-2433-4bb1-aadc-b8830b31a6a2" />
<br><br>
And they can be recalled as seen here.
<br><br>
<img width="1106" height="964" alt="image" src="https://github.com/user-attachments/assets/7112a381-b10a-4389-aa7b-bd2a4d34059a" /><br><br>

## **_2 - SpectrumNext_SpriteSheet_Export.lua_**

Use this script to export your sprites or tiles directly from within Aseprite, to load into a memory bank, for example in Boriel Studio or NextBuild. No conversion or other tools are required!<br>
All you have to do is select pixel size of the sprites/tiles, 8 or 16, and number of colours, 16 or 256.<br>
The script will then chop up the image from top left to bottom right.<br><br>
<img width="326" height="220" alt="image" src="https://github.com/user-attachments/assets/03adffc1-6c40-4934-85ff-5b5f049d03a9" /><br>
<img width="342" height="181" alt="image" src="https://github.com/user-attachments/assets/79049e7c-8dbf-4fb2-af3e-94a74cae2510" /><br>
<img width="332" height="186" alt="image" src="https://github.com/user-attachments/assets/7e143dc6-5e27-4dbd-8d65-f91147bbe21f" />
<br><br>
The size of your spritesheet determines the maximum number of sprites/tiles which are possible to be chopped up, there is no limit and it is not capped. For example, a maximum of 64, 16x16 sprites, could use an image of 64x256 pixels in size or even start with creating a blank image with script 1 above and select 16 for sprite size and grid of 4x16.<br>
You can however select the number from this maximum that you want to export. So if your image supports a maximum of 64, but you only want to export 10, then enter the number here.<br>
The colour palette you use for your image is also down to you, so make sure it is compatible with the Next, however this enables you to use any selection of colours from the 512 available. You would just need to use the same palette in your game.<br>
It has some simple error checking. So if there is no file loaded to export it will exit. If the image is not divisable by either 8 or 16 it will not proceed and if you have more or less colours in your palette than you are trying to export, again it will not proceed.<br><br>

## **_3 - SpectrumNext_Palette_Convert.lua_**

Here you need a colour indexed image to work with or you are working on (as an example, it could be a title screen image of size 320x256 or 256x192.), then run this script and select the type of colour distancing technique before applying.<br>
<br>
Options are - Euclidean, Manhattan, Chebyshev, CIE76, CIEDE2000<br>
<br>
<img width="818" height="612" alt="image" src="https://github.com/user-attachments/assets/9a9fa85e-0b25-491b-9192-b6dcca307971" />
<br><br>
When run, it will use the method selected to check the palette colours of the image and map them to the closest it can find from the 512 available 9bit colours of the Spectrum Next, hopefully without changing the palette too much.<br>
I will be looking further into this for other possible options which may be useful, so stay tuned!<br><br>

## **_4 - SpectrumNext_Palette_Export.lua_**

The palette exporter does exactly what you would expect, exports palettes to load into the Next, but there are a few options.<br>
It can export both 16 and 256, 9-bit indexed colour palettes in full, from those you have in your image. To export normally then the default position of the offset is "Off".<br>
If you have a 256 palette using multiple groups of 16, you can then select the offset to export these groups.<br>
The priority bit (bit 7 of the 2nd byte) is not exported with the palette. This is provided in the next plugin below for the Palette Viewer.<br>
<br>
<img width="307" height="174" alt="image" src="https://github.com/user-attachments/assets/7227c983-5145-4fef-96ae-29865b52cd4c" /><br>
<img width="328" height="443" alt="image" src="https://github.com/user-attachments/assets/e28cf84d-fa8f-4782-926f-cab45c47045d" /><br><br>

## **_5 - SpectrumNext_Palette_Viewer.lua_**

Once you have exported some palettes using the plugin above, you can then import them to view using this. The options speak for themselves, however, there is an extra feature to this plugin, and that is to tag colours in the palette, allowing the indexed colour to have the priority bit set for further exporting.<br>
Using this priority bit for Layer 2, forces all pixels set with this to be drawn above all other layers.<br> 
<br>
<img width="481" height="623" alt="image" src="https://github.com/user-attachments/assets/f6ba5742-30b2-416e-97da-6dfc1d103f04" /><br><br>
<img width="481" height="627" alt="image" src="https://github.com/user-attachments/assets/a44e3ca0-359e-4366-81e6-9421e6c68070" />
<br>
When tagging is complete, export the palette to save your changes. The next time you import this palette, it will show indexes you have already tagged.<br><br>

## **_6 - SpectrumNext_Image_Export.lua_**

The image exporter couldn't be easier to use and includes some error checking to inform you if your image is in the correct format.<br>
Simply select a BMP or BIN export option for the type of image to export.<br>
If you select BMP, it will give you an option to auto rotate | flip the image, so it's ready to import into your code. This saves using external tools to do this for you.<br>
The BIN file does not require this, as it is saved as a raw binary file (similar to NXI), with no headers or palette included.<br>
For screen sizes with multiples of 320x256 it will export the data from top to bottom and left to right, all other screen resolutions will export from left to right and top to bottom.<br>
<br>
<img width="312" height="125" alt="image" src="https://github.com/user-attachments/assets/9b4b14ea-aba3-4523-bd4f-86745ea54944" /><br>
<img width="297" height="165" alt="image" src="https://github.com/user-attachments/assets/27d44d96-9335-413a-91bc-96d3d7ead22b" /><br>
<img width="285" height="125" alt="image" src="https://github.com/user-attachments/assets/064d0c3c-b5ca-4f68-bc3d-4af5728c14c6" /><br>
<br>
Don't forget you can modify your image colours or export a palette with one of the other plugins.<br>
<br>
Image sizes are not capped to standard layer 2 formats (although it includes these) so be aware when coding what you have exported. However compatible sizes for export are multiples of and including:<br>
128 x 96<br>
256 x 192<br>
320 x 256<br>
<br>
This includes ones like 640x256, 640x512, etc.<br><br>

## **_7 - SpectrumNext_SpriteSheet_Import.lua_**

Spritesheet importer is now available. This alows you to import a set or sprites, tiles or font's in the Next format like, .spr .til, etc. First select the pixel size and colour depth of the sprites you are importing.<br><br>
<img width="338" height="228" alt="image" src="https://github.com/user-attachments/assets/071891c0-55bf-4496-8412-b913992d06e1" />
<br><br>
Then it will ask how many columns wide in sprites you want the image to be. It will show you how many sprites are being imported and put a set value for you here, for as square of an image it can make from this number of sprites. (You can change this value.)
<br><br>
<img width="344" height="146" alt="image" src="https://github.com/user-attachments/assets/6ee8e663-2418-42f4-ba13-ef0fa02fb3e6" />
<br><br>
The spritesheet will then be created for you, with a grey scale palette with the correct number of colours. 
<br><br>
<img width="736" height="525" alt="image" src="https://github.com/user-attachments/assets/c370ac20-596e-4de1-8c5f-63a0b871aed2" />
<br><br>
You can then either import the colour palette using the next plugin below or select a default palette from your created presets.<br><br>
<img width="1106" height="964" alt="image" src="https://github.com/user-attachments/assets/7112a381-b10a-4389-aa7b-bd2a4d34059a" /><br><br>

## **_8 - SpectrumNext_Palette_Import.lua_**

Palette import is really quite straightforward, simply select the .pal file and the plugin will do the rest, loading the colours.<br><br>
<img width="338" height="142" alt="image" src="https://github.com/user-attachments/assets/326bcb9a-8aa2-41bd-9a5d-5592a7828d13" />
<br><br>
For example in the imported spritesheet above.<br><br> 
<img width="697" height="473" alt="image" src="https://github.com/user-attachments/assets/21051ca4-96d3-4c01-b953-871a10b57205" />
<br><br><br>
There will be more updates and useful scripts to follow, so make sure you call back.<br>
Have fun and I hope you enjoy the posts and find these materials useful!<br>

Find out all the latest here: https://www.pandapus.com/

