-- ZX Spectrum Next Import Palette (.pal or .nxp)
-- By Paul "Spectre" Harthen

local sprite = app.activeSprite


if not sprite then
  app.alert("No sprite loaded.")
  return
end

if sprite.colorMode ~= ColorMode.INDEXED then
  app.alert("Sprite must be in indexed colour mode.")
  return
end


local dlg = Dialog("Import ZXNext Palette")
dlg:file{
  id = "importFile",
  label = "Import File",
  title = "Open Palette",
  open = true,
  filetypes = { "pal", "nxp" }
}
dlg:button{ id = "ok", text = "Import" }
dlg:button{ id = "cancel", text = "Cancel" }
dlg:show()

local data = dlg.data
if not data.ok or data.importFile == "" then return end

local path = data.importFile
local f = io.open(path, "rb")
if not f then
  app.alert("Failed to open file:\n" .. path)
  return
end

local content = f:read("*all")
f:close()

local byteCount = #content
if byteCount ~= 32 and byteCount ~= 512 then
  app.alert("Invalid palette file size.\nExpected 32 or 512 bytes.")
  return
end

local colorCount = byteCount / 2


local function convertFrom3Bit(value)
  return math.floor(value * 36.43 + 0.5)
end


local function unpackColor(b1, b2)
  local r = (b1 >> 5) & 0x07
  local g = (b1 >> 2) & 0x07
  local b = ((b1 & 0x03) << 1) | (b2 & 0x01)
  return Color{
    r = convertFrom3Bit(r),
    g = convertFrom3Bit(g),
    b = convertFrom3Bit(b)
  }
end


local newPalette = Palette(colorCount)
for i = 0, colorCount - 1 do
  local b1 = content:byte(i * 2 + 1)
  local b2 = content:byte(i * 2 + 2)
  local color = unpackColor(b1, b2)
  newPalette:setColor(i, color)
end

sprite:setPalette(newPalette)
