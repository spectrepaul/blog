/* NextMap256AttributeULA.js
 *
 * A Tiled plugin to export a tile map as a binary file with hex values.
 * Blank tiles with a value of -1 are replaced with 00.
 * Supports tile ID's up to 256 and using the attribute byte.
 * Includes Rotate, Flip both ways and Palette Offset using the same tile.
 * Also includes support of bit 8 of the high byte for tile on top or below the ULA.
 * 
 * By Paul Spectre Harthen
 *
 */

var customZXNextBinaryExport256AttributeULA = {
    name: "ZXNext Map 256 tile mode with Attribute ULA",
    extension: "map",
    write: function(p_map, p_fileName) {
       
        // Process map tiles
        var bytes = [];
     
            mapLayer = p_map.layerAt(0);
            offsetLayer = p_map.layerAt(1);

            if (mapLayer.isTileLayer && offsetLayer.isTileLayer) {
                for (let y = 0; y < mapLayer.height; ++y) {
                    for (let x = 0; x < mapLayer.width; ++x) {
                        let mapTile = mapLayer.cellAt(x, y);
                        let mapTileID = mapTile.tileId;
                        
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

                        let lowByte = mapTileID === -1 ? 0x00 : mapTileID & 0xFF;

                        // Lookup PaletteOffset
                        let offsetTile = offsetLayer.cellAt(x, y);
                        let offsetTileID = (offsetTile.tileId === -1) ? 0 : offsetTile.tileId;
                        let ULABit = (offsetTileID > 15) ? 1 : 0;
                        //let paletteBits = offsetTileID & 0x0F;
                        let paletteBits = (offsetTileID > 15) ? (offsetTileID-16) & 0x0F : offsetTileID & 0x0F;


                        let highByte = (paletteBits << 4)
                                        | (xMirrorBit << 3)
                                        | (yMirrorBit << 2)
                                        | (rotateBit << 1)
                                        | (ULABit << 0);

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

tiled.registerMapFormat("zxnextBinaryExport256AttributeULA", customZXNextBinaryExport256AttributeULA);
