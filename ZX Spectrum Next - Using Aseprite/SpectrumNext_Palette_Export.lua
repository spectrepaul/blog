-- ZX Spectrum Next Export 9-bit RGB Palette (.pal or .nxp)
-- Paul "Spectre" Harthen

local sprite = app.activeSprite

-- Validation: Sprite presence, indexed mode and palette size
if not sprite then
  app.alert("No sprite loaded.")
  return
end

if sprite.colorMode ~= ColorMode.INDEXED then
  app.alert("Sprite must be in indexed colour mode.")
  return
end

local palette = sprite.palettes[1]
local paletteSize = #palette

if paletteSize ~= 16 and paletteSize ~= 256 then
  app.alert("Palette must contain exactly 16 or 256 colours.")
  return
end

-- Dialog for output file
local dlg = Dialog("Save 9-bit RGB Palette")

-- Palette Offset dropdown: Off + 1–16
dlg:combobox{
  id = "offsetCombo",
  label = "Palette Offset",
  options = (function()
    local opts = { "Off" }
    for i = 1, 16 do
      table.insert(opts, tostring(i))
    end
    return opts
  end)(),
  option = "Off"
}

dlg:file{
  id = "exportFile",
  label = "Export File",
  title = "Save Palette",
  save = true,
  filetypes = { "pal", "nxp" }
}

dlg:button{ id = "ok", text = "Export" }
dlg:button{ id = "cancel", text = "Cancel" }
dlg:show()

local data = dlg.data

if data.ok and data.exportFile ~= "" then
  local path = data.exportFile
  if not path:match("%.pal$") and not path:match("%.nxp$") then
    path = path .. ".pal" -- Default to .pal if no extension
  end

  -- Parse offset
  local offset = 0
  if data.offsetCombo ~= "Off" then
    offset = tonumber(data.offsetCombo)
  end

  -- Warn if offset is selected with 16 colour palette
  if paletteSize == 16 and offset > 0 then
    app.alert("Palette Offset is only available with 256 colours.")
    return
  end

  -- Convert RGB to 3-bit
  local function convertTo3Bit(value)
    return math.floor(value / 36.43 + 0.5)
  end

  -- Pack colour into 9-bit format (rrrgggbbb)
  local function packColor(color)
    local r = convertTo3Bit(color.red)
    local g = convertTo3Bit(color.green)
    local b = convertTo3Bit(color.blue)
    local byte1 = (r << 5) | (g << 2) | (b >> 1)
    local byte2 = b & 1
    return byte1, byte2
  end

  local f = io.open(path, "wb")
  if not f then
    app.alert("Failed to open file for writing:\n" .. path)
    return
  end

  -- Determine export range
  local startIndex = 0
  local exportCount = paletteSize

  if paletteSize == 256 and offset > 0 then
    startIndex = (offset - 1) * 16
    exportCount = 16
  end

  for i = 0, exportCount - 1 do
    local index = startIndex + i
    local color = palette:getColor(index)
    local b1, b2 = packColor(color)
    f:write(string.char(b1))
    f:write(string.char(b2))
  end

  f:close()
  app.alert("Exported 9-bit RGB palette to:\n" .. path)
end
