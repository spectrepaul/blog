-- Stray Pixel Tester for ZX Spectrum Next
-- Paul "Spectre" Harthen

-- Expand palette to 256 entries, fill missing with black, set last to highlight colour
local function injectColorToPalette(sprite, highlightColor)
  local palette = sprite.palettes[1]

  -- Expand to full 256 entries with black
  if #palette < 256 then
    local currentSize = #palette
    palette:resize(256)
    for i = currentSize, 255 do
      palette:setColor(i, Color{ r = 0, g = 0, b = 0, a = 255 })
    end
  end

  -- Set last index to highlight colour
  palette:setColor(255, highlightColor)
  sprite:setPalette(palette)

  -- Return index 255 for use
  return 255
end

-- Validate original sprite
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
if w % 8 ~= 0 or h % 8 ~= 0 then
  app.alert("Image dimensions must be multiples of 8x8 pixels.")
  return
end

-- Ask user for highlight colour and border toggle
local dlg = Dialog("Pick Highlight Colour")
local r, g, b = 255, 0, 255

dlg:combobox{ id="r", label="Red", option=r, options=(function()
  local opts = {}
  for i = 0, 255 do table.insert(opts, i) end
  return opts
end)() }

dlg:combobox{ id="g", label="Green", option=g, options=(function()
  local opts = {}
  for i = 0, 255 do table.insert(opts, i) end
  return opts
end)() }

dlg:combobox{ id="b", label="Blue", option=b, options=(function()
  local opts = {}
  for i = 0, 255 do table.insert(opts, i) end
  return opts
end)() }

dlg:combobox{ id="border", label="Border", option="Off", options={ "Off", "On" } }

dlg:button{ id="ok", text="OK" }
dlg:show()

local data = dlg.data
local strayRGB = Color{ r = data.r, g = data.g, b = data.b, a = 255 }
local drawBorder = (data.border == "On")

-- Clone palette and image
local originalPalette = sprite.palettes[1]
if not originalPalette then
  app.alert("No palette found.")
  return
end

local cel = sprite.cels[1]
local srcImage = Image(w, h, ColorMode.INDEXED)
srcImage:drawSprite(sprite, cel.frameNumber)

-- Create new sprite for error visualisation
local errorSprite = Sprite(w, h, ColorMode.INDEXED)
errorSprite.filename = "Pixel_Errors"
errorSprite.transparentColor = -1

-- Clone palette
local newPalette = Palette(#originalPalette)
for i = 0, #originalPalette - 1 do
  newPalette:setColor(i, originalPalette:getColor(i))
end
errorSprite:setPalette(newPalette)

-- Copy image into new sprite
local errorImage = errorSprite.cels[1].image
errorImage:drawImage(srcImage, Point(0, 0))

-- Scan new image for stray pixels
local errorsFound = false

for blockY = 0, h - 1, 8 do
  for blockX = 0, w - 1, 8 do
    local colorSet = {}
    local colorCount = {}

    -- Collect colours
    for y = blockY, blockY + 7 do
      for x = blockX, blockX + 7 do
        local index = errorImage:getPixel(x, y)
        colorSet[index] = true
        colorCount[index] = (colorCount[index] or 0) + 1
      end
    end

    -- If more than 2 colours, fix stray pixels
    local uniqueColors = {}
    for index in pairs(colorSet) do
      table.insert(uniqueColors, index)
    end

    if #uniqueColors > 2 then
      errorsFound = true
      table.sort(uniqueColors, function(a, b)
        return (colorCount[a] or 0) > (colorCount[b] or 0)
      end)
      local allowed1 = uniqueColors[1]
      local allowed2 = uniqueColors[2]

      -- Replace stray pixels with placeholder
      for y = blockY, blockY + 7 do
        for x = blockX, blockX + 7 do
          local index = errorImage:getPixel(x, y)
          if index ~= allowed1 and index ~= allowed2 then
            errorImage:putPixel(x, y, -1)
          end
        end
      end

      -- Draw 1-pixel border from options setting
      if drawBorder then
        for i = 0, 7 do
          errorImage:putPixel(blockX + i, blockY, 255)         -- Top
          errorImage:putPixel(blockX + i, blockY + 7, 255)     -- Bottom
          errorImage:putPixel(blockX, blockY + i, 255)         -- Left
          errorImage:putPixel(blockX + 7, blockY + i, 255)     -- Right
        end
      end
    end
  end
end

-- Handle results
if not errorsFound then
  app.alert("Great! No stray pixels found!")
  errorSprite:close()
  return
end

-- Highlight stray pixels and replace placeholders
local strayIndex = injectColorToPalette(errorSprite, strayRGB)

for y = 0, h - 1 do
  for x = 0, w - 1 do
    if errorImage:getPixel(x, y) == -1 then
      errorImage:putPixel(x, y, strayIndex)
    end
  end
end

app.alert("Stray pixels highlighted in new image: Pixel_Errors")
