-- ZX Spectrum Next Palette Viewer with Tagged Priority Colour
-- Paul "Spectre" Harthen

-- Load palette file
local dlg = Dialog("Load 9-bit Palette")
dlg:file{
  id = "importFile",
  label = "Import File",
  title = "Open Palette",
  open = true,
  filetypes = { "pal", "nxp" }
}
dlg:button{ id = "ok", text = "Load" }
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

local function expand3Bit(v)
  return math.floor((v / 7) * 255 + 0.5)
end

local pal = {}
local tags = {}

for i = 1, 256 do
  local b1 = f:read(1)
  local b2 = f:read(1)
  if not b1 or not b2 then break end

  local byte1 = string.byte(b1)
  local byte2 = string.byte(b2)

  local r = (byte1 >> 5) & 0x07
  local g = (byte1 >> 2) & 0x07
  local b = ((byte1 & 0x03) << 1) | (byte2 & 0x01)

  table.insert(pal, Color{
    r = expand3Bit(r),
    g = expand3Bit(g),
    b = expand3Bit(b),
    a = 255
  })

  if (byte2 & 0x80) ~= 0 then
    tags[i - 1] = true
  end
end
f:close()

local numColors = #pal
if numColors ~= 16 and numColors ~= 256 then
  app.alert{
    title = "Invalid Palette",
    text = "This palette contains " .. numColors .. " colours.\nOnly 16 or 256 colours are supported.",
    buttons = { "OK" }
  }
  return
end

-- Viewer UI
local viewer = nil
local currIdx = 0
local bordS = 3
local swW = 12
local swH = 12
local gap = 2
local canvasW = (swW + gap) * 16 + bordS * 2
local canvasH = (swH + gap) * 16 + bordS * 2
local blackCol = Color(0, 0, 0)
local tagCol = Color(255, 255, 100)
local mouseDwn = false

local function updateColorInfo()
  local c = pal[currIdx + 1]
  viewer:modify{
    id = "ColorInfo",
    text = "Colour Index " .. currIdx .. ": RGB (" .. c.red .. ", " .. c.green .. ", " .. c.blue .. ")"
  }
  viewer:modify{
    id = "TagButton",
    text = tags[currIdx] and "UNTAG" or "TAG"
  }
end

local function onPaletteCanvasPaint(ev)
  local gc = ev.context
  gc.antialias = false
  gc.strokeWidth = 0

  gc.color = Color(99, 86, 96)
  gc:fillRect(Rectangle(0, 0, gc.width, gc.height))
  gc.color = blackCol
  gc:strokeRect(Rectangle(0, 0, gc.width, gc.height))

  local x = bordS
  local y = bordS
  local actRect

  for i = 0, numColors - 1 do
    if i > 0 and i % 16 == 0 then
      x = bordS
      y = y + swH + gap
    end

    local rect = Rectangle(x, y, swW, swH)
    gc.color = pal[i + 1]
    gc:fillRect(rect)
    gc.color = blackCol
    gc:strokeRect(rect)

    if tags[i] then
      gc.color = tagCol
      gc.strokeWidth = 1
      gc:strokeRect(Rectangle(x - 1, y - 1, swW + 2, swH + 2))
    end

    if i == currIdx then actRect = rect end
    x = x + swW + gap
  end

  if actRect then
    gc.color = pal[currIdx + 1]
    gc.strokeWidth = 2
    actRect.width = actRect.width + 1
    actRect.height = actRect.height + 1
    gc:fillRect(actRect)
    gc.color = blackCol
    gc:strokeRect(actRect)
  end
end

local function onPaletteCanvasMouseDown(ev)
  mouseDwn = true
  local x = ev.x
  local y = ev.y
  local newIdx = (math.floor((x - bordS) / (swW + gap))) + (math.floor((y - bordS) / (swH + gap)) * 16)
  if newIdx >= 0 and newIdx < numColors then
    currIdx = newIdx
    updateColorInfo()
    viewer:repaint()
  end
end

local function onPaletteCanvasMouseMove(ev)
  if mouseDwn then onPaletteCanvasMouseDown(ev) end
end

local function onPaletteCanvasMouseUp(ev)
  mouseDwn = false
end

local function onTagButtonClick()
  tags[currIdx] = not tags[currIdx]
  updateColorInfo()
  viewer:repaint()
end

local function onTagAllClick()
  for i = 0, numColors - 1 do tags[i] = true end
  updateColorInfo()
  viewer:repaint()
end

local function onUntagAllClick()
  for i = 0, numColors - 1 do tags[i] = false end
  updateColorInfo()
  viewer:repaint()
end

-- Export logic
local function convertTo3Bit(value)
  return math.floor(value / 36.43 + 0.5)
end

local function packColorWithTag(color, isTagged)
  local r = convertTo3Bit(color.red)
  local g = convertTo3Bit(color.green)
  local b = convertTo3Bit(color.blue)

  local byte1 = (r << 5) | (g << 2) | (b >> 1)
  local byte2 = (b & 0x01) | (isTagged and 0x80 or 0x00)
  return byte1, byte2
end

local function onExportClick()
  local dlg = Dialog("Save Tagged Palette")
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
  if not data.ok or data.exportFile == "" then return end

  local path = data.exportFile
  if not path:match("%.pal$") and not path:match("%.nxp$") then
    path = path .. ".pal"
  end

  local f = io.open(path, "wb")
  if not f then
    app.alert("Failed to open file for writing:\n" .. path)
    return
  end

  for i = 0, numColors - 1 do
    local color = pal[i + 1]
    local isTagged = tags[i] and true or false
    local b1, b2 = packColorWithTag(color, isTagged)
    f:write(string.char(b1))
    f:write(string.char(b2))
  end

  f:close()
  app.alert("Exported tagged palette to:\n" .. path)
end

-- Show dialog
viewer = Dialog{ title = "ZX Spectrum Next Palette Viewer" }
viewer:canvas{
  id = "PaletteCanvas",
  width = canvasW,
  height = canvasH,
  autoscaling = true,
  vexpand = false,
  onpaint = onPaletteCanvasPaint,
  onmousedown = onPaletteCanvasMouseDown,
  onmousemove = onPaletteCanvasMouseMove,
  onmouseup = onPaletteCanvasMouseUp
}
viewer:label{ id = "ColorInfo", text = "Colour 0:  RGB(0, 0, 0)" }

viewer:button{ id = "TagButton", text = "TAG", onclick = onTagButtonClick }
viewer:button{ id = "TagAllButton", text = "Tag All", onclick = onTagAllClick }
viewer:button{ id = "UntagAllButton", text = "Untag All", onclick = onUntagAllClick }

viewer:separator{}
viewer:button{ id = "ExportButton", text = "Export", onclick = onExportClick }
viewer:button{ id = "ok", text = "Close", focus = true }

viewer:show{ wait = false }
updateColorInfo()
