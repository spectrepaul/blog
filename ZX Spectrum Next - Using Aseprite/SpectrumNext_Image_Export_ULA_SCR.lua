-- ZX Spectrum Next ULA .scr Exporter
-- Paul "Spectre" Harthen & John "Wez" Weatherley

local sprite = app.activeSprite
if not sprite then app.alert("No image loaded.") return end
if sprite.width ~= 256 or sprite.height ~= 192 then
  app.alert("Image must be 256x192.") return
end
if sprite.colorMode ~= ColorMode.INDEXED then
  app.alert("Image must be indexed colour.") return
end
if #sprite.palettes[1] > 32 then
  app.alert("Only the 1st 32 indexes will be exported.")
end

-- Ask for save location
local dlg = Dialog("Export .scr File")
dlg:file{ id="filepath", label="Save As", title="Choose SCR file", save=true, filetypes={"scr"} }
dlg:button{ id="ok", text="OK" }
dlg:button{ id="cancel", text="Cancel" }
dlg:show()
local data = dlg.data
if not data.filepath then return end

-- Prepare image
local cel = sprite.cels[1]
local image = Image(sprite.width, sprite.height, ColorMode.INDEXED)
image:drawSprite(sprite, cel.frameNumber)

-- ZX Spectrum ULA bitmap addressing
local function ulaBitmapByteIndex(xByte, y)
  local part1 = (y & 0xC0) << 5   -- top two bits of y
  local part2 = (y & 0x07) << 8   -- bottom three bits
  local part3 = (y & 0x38) << 2   -- middle three bits
  return part1 + part2 + part3 + xByte
end

-- Buffers
local bitmap = {}
for i=1,6144 do bitmap[i]=0 end
local attrs = {}
for i=1,768 do attrs[i]=0 end
local used = {}

-- Build bitmap
for y=0,191 do
  for xByte=0,31 do
    local byte = 0
    local xStart = xByte*8
    for bit=0,7 do
      local x = xStart+bit
      local idx = image:getPixel(x,y)
      used[idx] = true
      if idx >=0 and idx <16 then
        byte = byte | (0x80 >> bit)
      end
    end
    local addr = ulaBitmapByteIndex(xByte,y)+1
    bitmap[addr] = byte
  end
end

-- Build attributes
for cellRow=0,23 do
  for cellCol=0,31 do
    local inkIndex, paperIndex = 0,16
    local inkFound, paperFound = false,false

    for dy=0,7 do
      local y = cellRow*8+dy
      for dx=0,7 do
        local x = cellCol*8+dx
        local idx = image:getPixel(x,y)
        used[idx] = true
        if not inkFound and idx>=0 and idx<16 then
          inkIndex=idx; inkFound=true
        end
        if not paperFound and idx>=16 and idx<32 then
          paperIndex=idx; paperFound=true
        end
      end
    end

    local inkNibble   = inkIndex % 8
    local paperNibble = paperIndex % 8
    local bright      = (inkIndex>=8 or paperIndex>=24) and 1 or 0
    local attrByte    = (bright<<6) | (paperNibble<<3) | inkNibble
    attrs[cellRow*32+cellCol+1] = attrByte
  end
end

-- Write file
local file = io.open(data.filepath,"wb")
if not file then app.alert("Failed to open file.") return end
for i=1,#bitmap do file:write(string.char(bitmap[i] & 0xFF)) end
for i=1,#attrs do file:write(string.char(attrs[i] & 0xFF)) end
file:close()

-- Report summary
local usedIndices = {}
for idx,_ in pairs(used) do table.insert(usedIndices,idx) end
table.sort(usedIndices)
app.alert("Export complete.")
