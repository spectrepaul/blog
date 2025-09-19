-- ZX Spectrum Next Sprite Importer
-- By Paul "Spectre" Harthen

local importDialog = Dialog("Import Settings")
importDialog:combobox{
  id = "tileSize",
  label = "Pixel Size",
  options = { "8", "16" },
  option = "16"
}
importDialog:combobox{
  id = "colorDepth",
  label = "Colour Depth",
  options = { "4-bit", "8-bit" },
  option = "8-bit"
}
importDialog:file{
  id = "importFile",
  label = "Import File",
  title = "Open ZXNext Tile Data",
  open = true,
  filetypes = { "spr", "til", "fnt", "nxt", "bin" }
}
importDialog:button{ id = "ok", text = "OK" }
importDialog:button{ id = "cancel", text = "Cancel" }
importDialog:show()

local data = importDialog.data
if not data.ok or data.importFile == "" then return end


local tileSize = tonumber(data.tileSize)
local depth = (data.colorDepth == "8-bit") and 256 or 16
local bytesPerTile = (depth == 256) and (tileSize * tileSize) or ((tileSize * tileSize) // 2)

local f = io.open(data.importFile, "rb")
local raw = f:read("*all")
f:close()

local fileSize = #raw
if (fileSize % bytesPerTile) ~= 0 then
  app.alert("File size is not a multiple of tile size (" .. bytesPerTile .. " bytes per tile).")
  return
end

local tileCount = fileSize // bytesPerTile
local defaultGridW = math.ceil(math.sqrt(tileCount))
local defaultGridH = math.ceil(tileCount / defaultGridW)


local gridDialog = Dialog("Tile Layout")
gridDialog:label{ label = "Tiles detected: " .. tileCount }
gridDialog:number{
  id = "tileColumns",
  label = "Number of Tile Columns",
  text = tostring(defaultGridW)
}
gridDialog:button{ id = "ok", text = "OK" }
gridDialog:show()

local grid = gridDialog.data
local gridW = tonumber(grid.tileColumns)
local gridH = math.ceil(tileCount / gridW)

if gridW <= 0 or gridH <= 0 then
  app.alert("Invalid grid dimensions.")
  return
end

if gridW * gridH < tileCount then
  app.alert("Grid too small to fit all tiles (" .. tileCount .. ").")
  return
end



local imgW = gridW * tileSize
local imgH = gridH * tileSize
local newSprite = Sprite(imgW, imgH, ColorMode.INDEXED)


local pal = newSprite.palettes[1]
pal:resize(depth)
for i = 0, depth - 1 do
  if depth == 256 then
    pal:setColor(i, Color(i, i, i)) -- grayscale ramp
  else
    local v = (i * 255) // 15
    pal:setColor(i, Color(v, v, v)) -- 16 grayscale steps
  end
end


local img = newSprite.cels[1].image
local offset = 0

for tileIndex = 0, tileCount - 1 do
  local tx = (tileIndex % gridW) * tileSize
  local ty = (tileIndex // gridW) * tileSize

  for y = 0, tileSize - 1 do
    if depth == 256 then
      for x = 0, tileSize - 1 do
        local px = string.byte(raw, offset + 1)
        img:putPixel(tx + x, ty + y, px)
        offset = offset + 1
      end
    else
      for x = 0, tileSize - 1, 2 do
        local byte = string.byte(raw, offset + 1)
        local px1 = (byte >> 4) & 0x0F
        local px2 = byte & 0x0F
        img:putPixel(tx + x, ty + y, px1)
        if x + 1 < tileSize then
          img:putPixel(tx + x + 1, ty + y, px2)
        end
        offset = offset + 1
      end
    end
  end
end

app.alert("Import complete.")