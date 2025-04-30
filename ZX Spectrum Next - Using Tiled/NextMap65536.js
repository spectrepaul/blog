/* NextMap65536.js
 *
 * A Tiled plugin to export a tile map as a binary file with hex values.
 * Blank tiles with a value of -1 are replaced with 00 00.
 * Supports tile ID's up to 65536 (For users thinking outside the box.)
 * 
 * By Paul Spectre Harthen
 *
 */

var customZXNextBinaryExport65536 = {
    name: "ZXNext Map 65536 tile mode",
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

                        if (currentTileID === -1) {
                            bytes.push(0x00, 0x00);
                        } else {
                            let highByte = (currentTileID >> 8) & 0xFF;
                            let lowByte = currentTileID & 0xFF;
                            bytes.push(lowByte, highByte);
                        }
                    }
                }
            }
        }

        let byteArray = new Uint8Array(bytes);
        outputFile.write(byteArray.buffer);
        outputFile.commit();
    }
};

tiled.registerMapFormat("zxnextBinaryExport65536", customZXNextBinaryExport65536);
