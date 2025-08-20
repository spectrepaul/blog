-- ZX Spectrum Next Export (.bmp or .nxi)
-- Paul "Spectre" Harthen

-- Manual 90° CCW rotation for indexed bmp image
local function rotateCCW90(src)
  local w, h = src.width, src.height
  local rotated = Image(h, w, ColorMode.INDEXED)
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      local color = src:getPixel(x, y)
      rotated:putPixel(y, w - 1 - x, color)
    end
  end
  return rotated
end

-- Export raw index data (.nxi) with conditional scan order
local function exportNXI(image, path, paletteSize, is320x256Multiple)
  local file = io.open(path, "wb")
  if not file then
    app.alert("Failed to open file for writing:\n" .. path)
    return
  end

  local writeIndex
  if paletteSize == 16 then
    writeIndex = function(x, y)
      local i1 = image:getPixel(x, y) & 0x0F
      local i2 = image:getPixel(x + 1, y) & 0x0F
      local packed = (i1 << 4) | i2
      file:write(string.char(packed))
    end
  elseif paletteSize == 256 then
    writeIndex = function(x, y)
      local index = image:getPixel(x, y) & 0xFF
      file:write(string.char(index))
    end
  end

  if is320x256Multiple then
    -- Top-to-bottom, left-to-right
    for x = 0, image.width - 1, (paletteSize == 16 and 2 or 1) do
      for y = 0, image.height - 1 do
        writeIndex(x, y)
      end
    end
  else
    -- Default: Left-to-right, top-to-bottom
    for y = 0, image.height - 1 do
      for x = 0, image.width - 1, (paletteSize == 16 and 2 or 1) do
        writeIndex(x, y)
      end
    end
  end

  file:close()
  app.alert("Exported NXI file to:\n" .. path)
end

-- Validate sprite
local sprite = app.activeSprite
if not sprite then
  app.alert("No image loaded.")
  return
end

if sprite.colorMode ~= ColorMode.INDEXED then
  app.alert("Image must be in indexed colour mode.")
  return
end

local w, h = sprite.width, sprite.height
local is320x256Multiple = (w % 320 == 0) and (h % 256 == 0)
local is256x192Multiple = (w % 256 == 0) and (h % 192 == 0)
local is128x96Multiple  = (w % 128 == 0) and (h % 96 == 0)

if not (is320x256Multiple or is256x192Multiple or is128x96Multiple) then
  app.alert("Image must be a multiple of 320x256, 256x192, or 128x96.")
  return
end

local paletteSize = #sprite.palettes[1]
if paletteSize ~= 16 and paletteSize ~= 256 then
  app.alert("Palette must contain exactly 16 or 256 colours.")
  return
end

-- Copy current cel image
local cel = sprite.cels[1]
local srcImage = Image(w, h, ColorMode.INDEXED)
srcImage:drawSprite(sprite, cel.frameNumber)

-- Format selection dialog
local formatDlg = Dialog("Select Export Format")
formatDlg:combobox{
  id = "format",
  label = "Export Format",
  options = { "BMP", "NXI" },
  option = "BMP"
}
formatDlg:button{ id = "ok", text = "OK" }
formatDlg:button{ id = "cancel", text = "Cancel" }
formatDlg:show()

local formatData = formatDlg.data
if not formatData.ok then return end
local selectedFormat = formatData.format

-- Export dialog (conditional UI)
local dlg = Dialog("Export Indexed Image")
dlg:file{
  id = "exportFile",
  label = "Export File",
  title = "Save Image",
  save = true,
  filetypes = { selectedFormat:lower() }
}

if selectedFormat == "BMP" then
  dlg:combobox{
    id = "transform",
    label = "Flip / Rotate",
    options = { "Auto", "Off" },
    option = "Auto"
  }
end

dlg:button{ id = "ok", text = "Export" }
dlg:button{ id = "cancel", text = "Cancel" }
dlg:show()

local data = dlg.data
if data.ok and data.exportFile ~= "" then
  local path = data.exportFile
  local transformOption = data.transform or "Off"

  -- Apply transformation based on user selection
  local transformed
  if selectedFormat == "BMP" and transformOption == "Auto" then
    if is320x256Multiple then
      transformed = rotateCCW90(srcImage)
    elseif is256x192Multiple or is128x96Multiple then
      transformed = srcImage:clone()
      transformed:flip(1)
    else
      transformed = srcImage
    end
  else
    transformed = srcImage
  end

  if selectedFormat == "BMP" then
    if not path:match("%.bmp$") then path = path .. ".bmp" end

    local exportSprite = Sprite(transformed.width, transformed.height, ColorMode.INDEXED)
    exportSprite.transparentColor = -1  -- Ensure index 0 is visible
    exportSprite:setPalette(sprite.palettes[1])
    exportSprite.cels[1].image:drawImage(transformed, Point(0, 0))
    exportSprite:saveCopyAs(path)
    app.alert("Exported BMP image to:\n" .. path)

  elseif selectedFormat == "NXI" then
    if not path:match("%.nxi$") then path = path .. ".nxi" end
    exportNXI(srcImage, path, paletteSize, is320x256Multiple)
  end
end
