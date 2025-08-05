-- ZX Spectrum Next Palette Remapper
-- Paul "Spectre" Harthen

local sprite = app.activeSprite
if not sprite then
  return app.alert("No active sprite found.")
end

if sprite.colorMode ~= ColorMode.INDEXED then
  return app.alert("Sprite must be in Indexed colour mode.")
end

-- Build 9-bit ZX Spectrum Next palette
local steps = {0, 36, 73, 109, 146, 182, 219, 255}
local next_palette = {}
for r = 1, 8 do
  for g = 1, 8 do
    for b = 1, 8 do
      table.insert(next_palette, Color{r=steps[r], g=steps[g], b=steps[b]})
    end
  end
end

-- Custom atan2 function (replacement for math.atan2)
local function atan2(y, x)
  if x > 0 then
    return math.atan(y / x)
  elseif x < 0 and y >= 0 then
    return math.atan(y / x) + math.pi
  elseif x < 0 and y < 0 then
    return math.atan(y / x) - math.pi
  elseif x == 0 and y > 0 then
    return math.pi / 2
  elseif x == 0 and y < 0 then
    return -math.pi / 2
  else
    return 0
  end
end

-- Helper functions for RGB → LAB conversion

local function rgb_to_xyz(r, g, b)
  r, g, b = r/255, g/255, b/255
  local function pivot(c)
    if c > 0.04045 then
      return ((c + 0.055) / 1.055)^2.4
    else
      return c / 12.92
    end
  end
  r, g, b = pivot(r), pivot(g), pivot(b)
  local x = r * 0.4124 + g * 0.3576 + b * 0.1805
  local y = r * 0.2126 + g * 0.7152 + b * 0.0722
  local z = r * 0.0193 + g * 0.1192 + b * 0.9505
  return x, y, z
end

local function xyz_to_lab(x, y, z)
  local ref_x, ref_y, ref_z = 0.95047, 1.00000, 1.08883
  local function pivot(t)
    if t > 0.008856 then
      return t^(1/3)
    else
      return 7.787 * t + 16/116
    end
  end
  local xr = x / ref_x
  local yr = y / ref_y
  local zr = z / ref_z
  local fx = pivot(xr)
  local fy = pivot(yr)
  local fz = pivot(zr)
  local l = 116 * fy - 16
  local a = 500 * (fx - fy)
  local b = 200 * (fy - fz)
  return l, a, b
end

local function rgb_to_lab(r, g, b)
  local x, y, z = rgb_to_xyz(r, g, b)
  return xyz_to_lab(x, y, z)
end

-- CIE76 colour difference
local function delta_e_cie76(lab1, lab2)
  local dl = lab1[1] - lab2[1]
  local da = lab1[2] - lab2[2]
  local db = lab1[3] - lab2[3]
  return math.sqrt(dl*dl + da*da + db*db)
end

-- CIEDE2000 implementation (Sharma et al. 2005)
local function delta_e_ciede2000(lab1, lab2)
  local L1, a1, b1 = lab1[1], lab1[2], lab1[3]
  local L2, a2, b2 = lab2[1], lab2[2], lab2[3]

  local avg_L = (L1 + L2) / 2

  local C1 = math.sqrt(a1*a1 + b1*b1)
  local C2 = math.sqrt(a2*a2 + b2*b2)
  local avg_C = (C1 + C2) / 2

  local G = 0.5 * (1 - math.sqrt((avg_C^7) / (avg_C^7 + 25^7)))

  local a1_prime = (1 + G) * a1
  local a2_prime = (1 + G) * a2

  local C1_prime = math.sqrt(a1_prime*a1_prime + b1*b1)
  local C2_prime = math.sqrt(a2_prime*a2_prime + b2*b2)

  local h1_prime = math.deg(atan2(b1, a1_prime))
  if h1_prime < 0 then h1_prime = h1_prime + 360 end
  local h2_prime = math.deg(atan2(b2, a2_prime))
  if h2_prime < 0 then h2_prime = h2_prime + 360 end

  local delta_L_prime = L2 - L1
  local delta_C_prime = C2_prime - C1_prime

  local h_diff = h2_prime - h1_prime
  local delta_h_prime = 0
  if C1_prime * C2_prime == 0 then
    delta_h_prime = 0
  elseif math.abs(h_diff) <= 180 then
    delta_h_prime = h_diff
  elseif h_diff > 180 then
    delta_h_prime = h_diff - 360
  else -- h_diff < -180
    delta_h_prime = h_diff + 360
  end

  local delta_H_prime = 2 * math.sqrt(C1_prime * C2_prime) * math.sin(math.rad(delta_h_prime / 2))

  local avg_L_prime = (L1 + L2) / 2
  local avg_C_prime = (C1_prime + C2_prime) / 2

  local avg_h_prime = 0
  if C1_prime * C2_prime == 0 then
    avg_h_prime = h1_prime + h2_prime
  elseif math.abs(h1_prime - h2_prime) <= 180 then
    avg_h_prime = (h1_prime + h2_prime) / 2
  elseif (h1_prime + h2_prime) < 360 then
    avg_h_prime = (h1_prime + h2_prime + 360) / 2
  else
    avg_h_prime = (h1_prime + h2_prime - 360) / 2
  end

  local T = 1
    - 0.17 * math.cos(math.rad(avg_h_prime - 30))
    + 0.24 * math.cos(math.rad(2 * avg_h_prime))
    + 0.32 * math.cos(math.rad(3 * avg_h_prime + 6))
    - 0.20 * math.cos(math.rad(4 * avg_h_prime - 63))

  local delta_theta = 30 * math.exp(- ((avg_h_prime - 275) / 25)^2)
  local R_C = 2 * math.sqrt((avg_C_prime^7) / (avg_C_prime^7 + 25^7))
  local S_L = 1 + ((0.015 * ((avg_L_prime - 50)^2)) / math.sqrt(20 + ((avg_L_prime - 50)^2)))
  local S_C = 1 + 0.045 * avg_C_prime
  local S_H = 1 + 0.015 * avg_C_prime * T
  local R_T = -math.sin(math.rad(2 * delta_theta)) * R_C

  local delta_E = math.sqrt(
    (delta_L_prime / S_L)^2 +
    (delta_C_prime / S_C)^2 +
    (delta_H_prime / S_H)^2 +
    R_T * (delta_C_prime / S_C) * (delta_H_prime / S_H)
  )

  return delta_E
end

-- Distance methods table with fixed CIE calls
local distanceMethods = {
  ["Euclidean"] = function(c1, c2)
    local dr = c1.red - c2.red
    local dg = c1.green - c2.green
    local db = c1.blue - c2.blue
    return dr*dr + dg*dg + db*db
  end,
  ["Manhattan"] = function(c1, c2)
    return math.abs(c1.red - c2.red) + math.abs(c1.green - c2.green) + math.abs(c1.blue - c2.blue)
  end,
  ["Chebyshev"] = function(c1, c2)
    return math.max(math.abs(c1.red - c2.red), math.abs(c1.green - c2.green), math.abs(c1.blue - c2.blue))
  end,
  ["CIE76"] = function(c1, c2)
    local L1,a1,b1 = rgb_to_lab(c1.red, c1.green, c1.blue)
    local L2,a2,b2 = rgb_to_lab(c2.red, c2.green, c2.blue)
    return delta_e_cie76({L1,a1,b1}, {L2,a2,b2})
  end,
  ["CIEDE2000"] = function(c1, c2)
    local L1,a1,b1 = rgb_to_lab(c1.red, c1.green, c1.blue)
    local L2,a2,b2 = rgb_to_lab(c2.red, c2.green, c2.blue)
    return delta_e_ciede2000({L1,a1,b1}, {L2,a2,b2})
  end,
}

-- Dialog UI
local dlg = Dialog("ZX Spectrum Next Palette Remapper")

local selectedMethod = "Euclidean" -- default

dlg:combobox{
  id = "distMethod",
  label = "Colour Distance",
  option = selectedMethod,
  options = {"Euclidean", "Manhattan", "Chebyshev", "CIE76", "CIEDE2000"}
}

dlg:button{
  text = "Convert",
  focus = true,
  onclick = function()
    local choice = dlg.data.distMethod or "Euclidean"
    local colorDistance = distanceMethods[choice]

    local currentPalette = sprite.palettes[1] or app.getPalette()
    local newPalette = Palette(#currentPalette)

    for i = 0, #currentPalette - 1 do
      local orig = currentPalette:getColor(i)
      local bestColor = nil
      local bestDist = math.huge

      for _, zxnCol in ipairs(next_palette) do
        local dist = colorDistance(orig, zxnCol)
        if dist < bestDist then
          bestDist = dist
          bestColor = zxnCol
        end
      end

      newPalette:setColor(i, bestColor)
    end

    sprite:setPalette(newPalette)
    app.refresh()
    
    app.alert("Palette converted using " .. choice .. " distance.")
    
    dlg:close()  -- <-- Close dialog after conversion and alert
  end
}

dlg:button{ text = "Cancel" }

dlg:show()
