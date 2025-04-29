/* NextMap512Attribute.js
 *
 * A Tiled plugin to export a tile map as a binary file with hex values.
 * Blank tiles with a value of -1 are replaced with 00.
 * Supports tile ID's up to 512 and using the attribute byte.
 * Includes Rotate, Flip both ways and Palette Offset using the same tile
 * 
 * By Paul Spectre Harthen
 *
 */

var customZXNextBinaryExport512Attribute = {
    name: "ZXNext Map 512 tile mode with Attribute",
    extension: "map",
    write: function(p_map, p_fileName) {
       
        // Process map tiles
        var bytes = [];
        var D = 0;
        var V = 0;
        var H = 0;

     
            mapLayer = p_map.layerAt(0);
            offsetLayer = p_map.layerAt(1);

            if (mapLayer.isTileLayer && offsetLayer.isTileLayer) {
                for (let y = 0; y < mapLayer.height; ++y) {
                    for (let x = 0; x < mapLayer.width; ++x) {
                        let mapTile = mapLayer.cellAt(x, y);
                        let mapTileID = mapTile.tileId;
                        

                        if (mapTileID === -1) {
                            bytes.push(0x00); // Represent blank tile as 0x00
                            bytes.push(0x00); // Add a second 0x00 for the high byte
                            continue;
                        }

                        let D = mapTile.flippedAntiDiagonally ? 1 : 0;
                        let V = mapTile.flippedVertically ? 1 : 0;
                        let H = mapTile.flippedHorizontally ? 1 : 0;
                       
                        if (D == 1 && V == 0 && H == 1) {
                            xMirrorBit = 0;
                            yMirrorBit = 0;
                            rotateBit = 1;
                        } else if (D == 1 && V == 1 && H == 0) {
                            xMirrorBit = 1;
                            yMirrorBit = 1;
                            rotateBit = 1;
                        } else if (D == 0 && V == 1 && H == 1) {
                            xMirrorBit = 1;
                            yMirrorBit = 1;
                            rotateBit = 0;
                        } else{
                            xMirrorBit = H;
                            yMirrorBit = V;
                            rotateBit = D;
                        }

                        let baseTileID = mapTileID & 0x1FF;
                        let lowByte = baseTileID & 0xFF;
                        let tileRangeBit = (baseTileID > 255) ? 1 : 0;

                        // Lookup PaletteOffset
                        let offsetTile = offsetLayer.cellAt(x, y);
                        let offsetTileID = offsetTile.tileId;

                        if (offsetTileID === -1) {
                            offsetTileID = 0
                        }
                       
                        let paletteBits = offsetTileID & 0x0F;

                        let highByte = (paletteBits << 4)
                                        | (xMirrorBit << 3)
                                        | (yMirrorBit << 2)
                                        | (rotateBit << 1)
                                        | (tileRangeBit << 0);

                        bytes.push(lowByte);
                        bytes.push(highByte);
                    }
                }
            }
   

        // Write to output file
        let byteArray = new Uint8Array(bytes);
        let outputFile = new BinaryFile(p_fileName, BinaryFile.WriteOnly);
        outputFile.write(byteArray.buffer);
        outputFile.commit();
    }
};

tiled.registerMapFormat("zxnextBinaryExport512Attribute", customZXNextBinaryExport512Attribute);
