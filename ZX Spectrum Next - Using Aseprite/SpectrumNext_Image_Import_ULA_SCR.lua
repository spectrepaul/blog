-- ZX Spectrum Next ULA .scr Importer
-- Paul "Spectre" Harthen & John "Wez" Weatherley

local dlg = Dialog("Import .scr File")
dlg:file{ id="filepath", label="Open", title="Choose SCR file", open=true, filetypes={"scr"} }
dlg:button{ id="ok", text="OK" }
dlg:button{ id="cancel", text="Cancel" }
dlg:show()
local data = dlg.data
if not data.filepath then return end

-- Read file
local file = io.open(data.filepath, "rb")
if not file then app.alert("Failed to open file.") return end
local content = file:read("*all")
file:close()

if #content ~= 6912 then
  app.alert("SCR file must be exactly 6912 bytes.")
  return
end

-- Split into bitmap + attributes
local bitmap = {}
for i=1,6144 do bitmap[i] = string.byte(content, i) end
local attrs = {}
for i=1,768 do attrs[i] = string.byte(content, 6144+i) end

-- ZX Spectrum ULA bitmap addressing
local function ulaBitmapByteIndex(xByte, y)
  local part1 = (y & 0xC0) << 5
  local part2 = (y & 0x07) << 8
  local part3 = (y & 0x38) << 2
  return part1 + part2 + part3 + xByte
end

-- Create new sprite
local spr = Sprite(256, 192, ColorMode.INDEXED)
local palette = spr.palettes[1]
palette:resize(256)

-- ZX Spectrum Next standard 256-colour palette
local steps = {0, 36, 73, 109, 146, 182, 219, 255}
local blueSteps = {0, 85, 170, 255}
local index = 0
for r = 0, 7 do
  for g = 0, 7 do
    for b = 0, 3 do
      if index < 256 then
        palette:setColor(index, Color{
          r = steps[r+1],
          g = steps[g+1],
          b = blueSteps[b+1],
          a = 255
        })
        index = index + 1
      end
    end
  end
end


local img = Image(256, 192, ColorMode.INDEXED)

-- Decode bitmap + attributes
for y=0,191 do
  for xByte=0,31 do
    local addr = ulaBitmapByteIndex(xByte, y)+1
    local byte = bitmap[addr]
    local cellRow = math.floor(y/8)
    local cellCol = xByte
    local attr = attrs[cellRow*32+cellCol+1]

    local ink = attr & 0x07
    local paper = (attr >> 3) & 0x07
    local bright = (attr >> 6) & 0x01

    -- Map back to palette indices
    local inkIndex   = ink   + (bright==1 and 8  or 0)
    local paperIndex = paper + (bright==1 and 24 or 16)

    for bit=0,7 do
      local x = xByte*8+bit
      local mask = 0x80 >> bit
      local val = (byte & mask) ~= 0
      img:putPixel(x, y, val and inkIndex or paperIndex)
    end
  end
end


-- Commit image to sprite
spr.cels[1].image = img
app.activeSprite = spr
app.alert("Import complete.")
