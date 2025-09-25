# Spectres Plugins for the ZX Spectrum Next (Tiled)

I have created a series of plugin scripts to be placed in the default Tiled plugins folder.<br>
For this, you will need the Tiled software, which you can find here: https://www.mapeditor.org/
<br>
Once installed, you can find the folder location to copy to, by opening Tiled and selecting preferences and plugins. Then press Open to get to the directory.<br>
You will also need the PNG images I created for numbers 0-15, to use as reference tiles, however these don't go in the plugins folder, so save elsewhere.<br>
<br>
When the files are saved in the plugins folder, you'll know if it's worked, as you should just be able to select Export from the file option, (You may have to restart Tiled, although I found I didn't need to.) and from the file type dropdown, you will see 4 export options for ".map"<br><br>
<img width="483" height="270" alt="image" src="https://github.com/user-attachments/assets/cc4a371d-1560-4943-8362-3b9fabcfe6fe" /><br><br><br>

## PLUGIN SCRIPTS:
## _1st set of scripts - NextMap256.js & NextMap65536.js_

Creating a map using the 256 & 65536 exports, is quite straight forward. These are for the Layer 2 mode on the Speccy Next.<br>
<br>
Here create your map size with either 8x8 or 16x16 pixel tiles and load your tileset image in to be chopped up by Tiled, then export with either option, creating a ".map" file with all your level data. For 256, this will be saved as 2 digit Hex values, in a binary file format for each tile ID and 65536, using more tile ID's, saved as 2 bytes of 2 digit hex codes.<br>
<br>
These save just the tile ID references of each tile used on your map in its location, from top left to bottom right.<br><br>
<img width="640" height="406" alt="image" src="https://github.com/user-attachments/assets/2d419540-0167-455c-ba8e-4d5c8b2b72e0" /><br>
<br>
From here you can load a set of ".spr" tiles into something like Nextbuild, load the ".map" file and draw out your level, in code.<br><br><br>

## _2nd set of scripts - NextMap256AttributeULA.js & NextMap512Attribute.js_

256 & 512 with attribute export options require a further step to use, but this allows all the extras which I will explain here. These are for hardware layer 3 mode or Tile Layer on the Speccy Next.<br>
<br>
The way these scripts create the output files, allows you to draw your level in a normal fashion with 8x8 pixel tiles, using the standard Tiled features like horizontal & vertical mirror and also rotate. (This is created on Tile Layer 1 in Tiled.)<br>
<br>
You then use Tile Layer 2 in Tiled to create your palette offset, stamping a set of tiles with numbers from 0 to 15 over the level tiles. This denotes what palette offset bank should be used for that tile underneath it on Tile Layer 1.<br>
<br>
In my repository I have created the number sets to be used as the reference tiles. These are nothing special, just PNG files that can be loaded into Tiled, and cut up as separate 8x8 tiles, with the numbers being used as a reference, so you know which palette offset you are using for each tile you have just stamped it on. (Of note, these tiles are loaded in as a separate set to your map tiles, as the ID's for these need to match the numbers 0-15.)<br>
<br>
This is the set for 512 export version, the 256 version has 2 sets of 0-15 numbers which would use tile ID's 0-31 and are Red & Green. I will explain these later.<br><br>
<img width="255" height="400" alt="image" src="https://github.com/user-attachments/assets/7b5686e5-e146-4db7-ba08-8cd8b424a2f6" /><br><br>

### 512 Tiles

As an example of how the 512 export works for using different colour banks for the same tile, you may have a row all containing 16 of the same tile, lets say tile 321 for arguments sake. Each of these tiles could then have a different palette offset number tile stamped on it from 1 to 15. In this mode you don't actually have to stamp the zero tiles down as I've made it so it defaults to zero anyway.<br>
<br>
Then when you reference your tiles in code from the output file, each instance of tile 321 in that position on the map, would use the palette offset from 0 to 15 to display the same tile in a different colour offset.<br>
<br>
Here you can see palette offset's set for the tiles as 9, 5, 5, 7, 5....etc. Again of note, you wouldn't need to put the 2 zero tiles down as they would be set to zero if left blank anyway, I am showing these as reference.<br><br>
<img width="640" height="258" alt="image" src="https://github.com/user-attachments/assets/90ac19f4-0d06-4ec5-9b9c-24a50fc9a995" /><br>
<br>
To make things easier for you when stamping the number tiles over the map on Tile Layer 2, you can reduce the opacity of Tile Layer 1.<br><br>
<img width="640" height="407" alt="image" src="https://github.com/user-attachments/assets/f6b346e8-bdcf-4046-95e1-b849216c6b87" /><br>
<br><br>
To give an idea of how the file saves the map references with the attribute byte for 512 export, I need to explain how the information is split across the high and low bytes.<br>
<br>
Here is an example of the hex values within the exported map file.<br><br>
<img width="332" height="36" alt="image" src="https://github.com/user-attachments/assets/97f5f97e-4e2b-49ec-9fe8-af6a4686b7a8" /><br>
<br>
High byte:
- Bits 15 - 12 contain the palette offset reference value from 0-15<br>
- Bit 11 a value of 0 or 1 for the X mirror value<br>
- Bit 10 a value of 0 or 1 for the Y mirror value<br>
- Bit 9 for 90 degree rotate with value 0 or 1<br>
- Bit 8 in this 512 tile mode, is the index bit, being 0 for tiles 0-255 and 1 for tiles 256-511<br><br>

Low byte:
- Bits 7 - 0 are all used to store a value from 0-255 for the tile ID<br><br>

So if you are following along with this, in the example above where 4c90 has been saved for the first tile reference on the map, 4c is the low byte returning the tile ID reference from Tiled and 90 is the high byte with all bits 15 - 8 combined into one 2 digit hex code.<br>
<br>
In order to sort this high byte, I've written the script to check each tile on the map and see if it is flipped or rotated and also if it has a palette offset reference tile stamped on top of it in layer 2 of Tiled. Once all checked, I have assigned all the values and created the hex codes for the output file.<br><br><br>


### 256 Tiles

Right the 256 attribute export is very similar to this 512 one above so won't need much more explaining, however there is a slight difference. Because we are now counting half the tiles, bit 8 is not required as the tile ID index, and is now used for the tile placement, above or below the ULA display.<br>
<br>
I have set this up so it still uses Tile Layer 1 & 2 in Tiled as before, but this time the set of reference tiles with 2 sets of 0-15 numbers are used instead. These are the ones with red and green numbers and are loaded in as separate 8x8 tiles, using tile ID's 0-31 (Red 0-15 using ID's 0-15 and Green 0-15 using ID's 16-31.)<br>
<br>
Everything is the same as before for mirror, rotate and palette offset, but this time having in mind 0-15 in either red or green represent a palette offset of 0-15 for the tile under it.<br>
<br>
The difference now is that if you use a red number, the tile under it will be below the ULA display and if a green number the tile will be on top of the ULA display.<br>
<br>
The default here is again a red 0, so if you place no numbered reference tiles at all, then all tiles on Tile Layer 1 of Tiled would be set as 0, meaning a palette offset of 0, and below the ULA display. However, if you wanted to use a palette offset of 0 and have the tile on top of the ULA display, then you WOULD have to put a green 0 tile down. Hope this all makes sense.<br>
<br>
This shows the palette offset tile for 256 export, notice tile ID 19 is showing the green number 3. <br><br>
<img width="639" height="524" alt="image" src="https://github.com/user-attachments/assets/e3fa0f7a-7f5a-4fc2-90ba-17e972709385" /><br>
<br>
And how you would use the tiles.<br><br>
<img width="640" height="446" alt="image" src="https://github.com/user-attachments/assets/6a6c71cb-4dc2-4700-a3ff-9607c6618a52" /><br>
<br>
As before the file is exported in a similar way with only bit 8 being different.<br>
<br>
High byte:
- Bits 15 - 12 contain the palette offset reference value from 0-15<br>
- Bit 11 a value of 0 or 1 for the X mirror value<br>
- Bit 10 a value of 0 or 1 for the Y mirror value<br>
- Bit 9 for 90 degree rotate with value 0 or 1<br>
- Bit 8 in this 256 tile mode, is the ULA reference of 0 for below the ULA display and 1 for on top.<br><br>

Low byte:
- Bits 7 - 0 are all used to store a value from 0-255 for the tile ID<br><br><br>

Follow my blog link here for a bit more information on this: https://www.pandapus.com/2025/05/zx-spectrum-next-using-tiled.html<br><br>
Have fun and I hope you enjoy the posts and find these materials useful!<br>


