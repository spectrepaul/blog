-- ZX Spectrum Next Export (.bmp or .bin)
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

-- Export raw index data (.bin) with fixed scan order
local function exportNXI(image, path, paletteSize, screenWidth, screenHeight)
  local file = io.open(path, "wb")
  if not file then
    app.alert("Failed to open file for writing:\n" .. path)
    return
  end

  local screensWide = image.width // screenWidth
  local screensHigh = image.height // screenHeight

  local function writeSection(x0, y0)
    if paletteSize == 16 then
      if screenWidth == 320 and screenHeight == 256 then
        -- Top-to-bottom, left-to-right
        for x = x0, x0 + screenWidth - 1 do
          local y = y0
          while y < y0 + screenHeight do
            local px1 = image:getPixel(x, y) & 0x0F
            local px2 = 0
            if y + 1 < y0 + screenHeight then
              px2 = image:getPixel(x, y + 1) & 0x0F
            end
            local packed = (px1 << 4) | px2
            file:write(string.char(packed))
            y = y + 2
          end
        end
      else
        -- Left-to-right, top-to-bottom
        for y = y0, y0 + screenHeight - 1 do
          local x = x0
          while x < x0 + screenWidth do
            local px1 = image:getPixel(x, y) & 0x0F
            local px2 = 0
            if x + 1 < x0 + screenWidth then
              px2 = image:getPixel(x + 1, y) & 0x0F
            end
            local packed = (px1 << 4) | px2
            file:write(string.char(packed))
            x = x + 2
          end
        end
      end

    elseif paletteSize == 256 then
      if screenWidth == 320 and screenHeight == 256 then
        -- Top-to-bottom, left-to-right
        for x = x0, x0 + screenWidth - 1 do
          for y = y0, y0 + screenHeight - 1 do
            local index = image:getPixel(x, y) & 0xFF
            file:write(string.char(index))
          end
        end
      else
        -- Left-to-right, top-to-bottom
        for y = y0, y0 + screenHeight - 1 do
          for x = x0, x0 + screenWidth - 1 do
            local index = image:getPixel(x, y) & 0xFF
            file:write(string.char(index))
          end
        end
      end
    end
  end

  for screenY = 0, screensHigh - 1 do
    for screenX = 0, screensWide - 1 do
      local originX = screenX * screenWidth
      local originY = screenY * screenHeight
      writeSection(originX, originY)
    end
  end

  file:close()
  app.alert("Exported BIN file to:\n" .. path)
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
  options = { "BMP", "BIN" },
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
if selectedFormat == "BIN" then
  dlg:file{
    id = "exportFile",
    label = "Export File",
    title = "Save NXI/BIN File",
    save = true,
    filetypes = { "nxi", "bin" },
  }
  dlg:combobox{
    id = "screenMulti",
    label = "Screen Size",
    options = { "320x256", "256x192", "128x96" },
    option = "320x256"
  }
else
  dlg:file{
    id = "exportFile",
    label = "Export File",
    title = "Save Image",
    save = true,
    filetypes = { "bmp" },
  }
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
  local screenMultiOption = data.screenMulti or "320x256"

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
    exportSprite.transparentColor = -1
    exportSprite:setPalette(sprite.palettes[1])
    exportSprite.cels[1].image:drawImage(transformed, Point(0, 0))
    exportSprite:saveCopyAs(path)
    app.alert("Exported BMP image to:\n" .. path)

  elseif selectedFormat == "BIN" then
    if not path:match("%.nxi$") and not path:match("%.bin$") then
      path = path .. ".nxi"
    end

    local screenWidth, screenHeight
    if is320x256Multiple and screenMultiOption == "320x256" then
      screenWidth, screenHeight = 320, 256
    elseif is256x192Multiple and screenMultiOption == "256x192" then
      screenWidth, screenHeight = 256, 192
    elseif is128x96Multiple and screenMultiOption == "128x96" then
      screenWidth, screenHeight = 128, 96
    else
      app.alert("Selected screen size does not match image multiple.")
      return
    end

    exportNXI(srcImage, path, paletteSize, screenWidth, screenHeight)
  end
end
