-- ZX Spectrum Sprite & Tile Exporter
-- By Paul "Spectre" Harthen

local sprite = app.activeSprite

-- Validation: Sprite presence and colour mode
if sprite == nil then
  app.alert("No sprite loaded.")
  return
end

if sprite.colorMode ~= ColorMode.INDEXED then
  app.alert("Sprite must be in indexed colour mode.")
  return
end

-- Export Info Dialog (initial tile size and colour depth)
local exportDialog = Dialog("Export Info")
exportDialog:combobox{
  id = "tileSize",
  label = "Pixel Size",
  options = { "8", "16" },
  option = "16"
}
exportDialog:combobox{
  id = "colorDepth",
  label = "Number of Colours",
  options = { "16", "256" },
  option = "256"
}
exportDialog:button{ id = "ok", text = "OK" }
exportDialog:show()

local tileSize = tonumber(exportDialog.data.tileSize)
local colorDepth = tonumber(exportDialog.data.colorDepth)

-- Validate dimensions
if (sprite.width % tileSize) ~= 0 or (sprite.height % tileSize) ~= 0 then
  app.alert("Sprite dimensions must be multiples of " .. tileSize .. ".")
  return
end

-- Validate palette size based on what selected
local paletteSize = #sprite.palettes[1]
if colorDepth == 16 and paletteSize ~= 16 then
  app.alert("Warning, use 1st set of index colours for 4-bit export. Current palette has " .. paletteSize .. " colours.")
  --return
elseif colorDepth == 256 and paletteSize ~= 256 then
  app.alert("Palette must contain exactly 256 colours for 8-bit export. Current palette has " .. paletteSize .. " colours.")
  return
end

-- Calculate maximum number of tiles
local maxTiles = (sprite.width // tileSize) * (sprite.height // tileSize)

-- Dialog for number of tiles to export
local countDialog = Dialog("Tile Count")
countDialog:number{
  id = "tileCount",
  label = "Number to Export",
  text = tostring(maxTiles)
}
countDialog:button{ id = "ok", text = "OK" }
countDialog:show()

local tileCount = tonumber(countDialog.data.tileCount)

-- Validate tile count
if tileCount == nil or tileCount <= 0 then
  app.alert("Number to Export must be greater than 0.")
  return
elseif tileCount > maxTiles then
  app.alert("Number to Export exceeds maximum possible tiles (" .. maxTiles .. ").")
  return
end

-- Export tiles
local function writeTile(img, x, y, size, file, depth)
  for cy = 0, size - 1 do
    if depth == 256 then
      -- 8-bit: write each pixel as one byte
      for cx = 0, size - 1 do
        local px = img:getPixel(cx + x, cy + y)
        file:write(string.char(px))
      end
    else
      -- 4-bit: pack two pixels into one byte
      local cx = 0
      while cx < size do
        local px1 = img:getPixel(cx + x, cy + y) & 0x0F
        local px2 = 0
        if cx + 1 < size then
          px2 = img:getPixel(cx + x + 1, cy + y) & 0x0F
        end
        local packed = (px1 << 4) | px2
        file:write(string.char(packed))
        cx = cx + 2
      end
    end
  end
end

-- Export all tiles from current frame, up to tileLimit
local function exportCurrentFrame(file, size, depth, tileLimit)
  local img = Image(sprite.spec)
  img:drawSprite(sprite, app.activeFrame)

  local tilesWritten = 0
  for y = 0, sprite.height - 1, size do
    for x = 0, sprite.width - 1, size do
      if tilesWritten >= tileLimit then return end
      writeTile(img, x, y, size, file, depth)
      tilesWritten = tilesWritten + 1
    end
  end
end

-- Dialog for output file
local dlg = Dialog("Save Export")
dlg:file{
  id = "exportFile",
  label = "Export File",
  title = "Save Binary Tile Data",
  save = true,
  filetypes = { "spr", "til", "fnt", "nxt", "bin" }
}
dlg:button{ id = "ok", text = "OK" }
dlg:button{ id = "cancel", text = "Cancel" }
dlg:show()

local data = dlg.data
if data.ok and data.exportFile ~= "" then
  local f = io.open(data.exportFile, "wb")
  exportCurrentFrame(f, tileSize, colorDepth, tileCount)
  f:close()

  app.alert("Export complete.")
end
