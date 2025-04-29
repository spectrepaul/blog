/* NextMap256.js
 *
 * A Tiled plugin to export a tile map as a binary file with hex values.
 * Blank tiles with a value of -1 are replaced with 00.
 * Supports tile ID up to 256 (64 tiles for 16x16 pixels and 256 for 8x8 pixels)
 * 
 * By Paul Spectre Harthen
 *
 */

var customZXNextBinaryExport256 = {
    name: "ZXNext Map 256 tile mode",
    extension: "map",

    write: function(p_map, p_fileName) {
        var outputFile = new BinaryFile(p_fileName, BinaryFile.WriteOnly);
        var bytes = [];

        for (let i = 0; i < p_map.layerCount; ++i) {
            let currentLayer = p_map.layerAt(i);

            if (currentLayer.isTileLayer) {
                for (let y = 0; y < currentLayer.height; ++y) {
                    for (let x = 0; x < currentLayer.width; ++x) {
                        let currentTile = currentLayer.cellAt(x, y);
                        let currentTileID = currentTile.tileId;

                        let byteValue = currentTileID === -1 ? 0x00 : currentTileID & 0xFF;
                        bytes.push(byteValue);
                    }
                }
            }
        }

        let byteArray = new Uint8Array(bytes);
        outputFile.write(byteArray.buffer);
        outputFile.commit();
    }
};

tiled.registerMapFormat("zxnextBinaryExport256", customZXNextBinaryExport256);

