local M = {}

local function clamp(value)
    return math.max(0, math.min(255, math.floor(value + 0.5)))
end

function M.normalize(hex)
    if type(hex) ~= "string" then
        return nil
    end
    local value = hex:match("^#?(%x%x%x%x%x%x)$")
    if not value then
        return nil
    end
    return "#" .. value:upper()
end

local function rgb(hex)
    local value = M.normalize(hex)
    return tonumber(value:sub(2, 3), 16), tonumber(value:sub(4, 5), 16), tonumber(value:sub(6, 7), 16)
end

function M.mix(a, b, t)
    local ar, ag, ab = rgb(a)
    local br, bg, bb = rgb(b)
    return string.format(
        "#%02X%02X%02X",
        clamp(ar + (br - ar) * t),
        clamp(ag + (bg - ag) * t),
        clamp(ab + (bb - ab) * t)
    )
end

function M.shade(hex, t)
    return M.mix(hex, "#000000", t)
end

function M.tint(hex, t)
    return M.mix(hex, "#FFFFFF", t)
end

local function linear(channel)
    local c = channel / 255
    if c <= 0.04045 then
        return c / 12.92
    end
    return ((c + 0.055) / 1.055) ^ 2.4
end

function M.luminance(hex)
    local r, g, b = rgb(hex)
    return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
end

function M.is_dark(hex)
    return M.luminance(hex) < 0.5
end

return M
