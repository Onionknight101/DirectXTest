_addon.name = 'DirectXTest'
_addon.author = 'vinke'
_addon.version = '1.1.0'
_addon.commands = {'dxtest', 'directxtest'}

local runtime_path = windower.addon_path .. 'direct_ffxi\\direct_ffxi.lua'
local loader, load_message = loadfile(runtime_path)
if not loader then
    error('DirectXTest could not load its DirectX runtime: ' .. tostring(load_message), 2)
end

local ok, direct = pcall(loader)
if not ok then
    error('DirectXTest could not start its DirectX runtime: ' .. tostring(direct), 2)
end

local handle = direct.new('DirectXTest')
local painter = direct.menu.new(handle)
local visible = true
local drawn = false
local drawn_profile = nil

local font = {
    folder = windower.addon_path .. 'media\\font\\consolas',
    basePixelSize = 48,
    between = 0,
    letter = {},
}
for byte = 32, 126 do
    font.letter[byte] = {size = 24.5, left = 0, kerning = {}}
end

local shader_texture = windower.addon_path .. 'media\\shader_test.png'

local function chat(color, message)
    windower.add_to_chat(color, '[DirectXTest] ' .. tostring(message))
end

local function draw_test_panel()
    if not visible then return false end

    local screen_width, screen_height = painter:size()
    screen_width = tonumber(screen_width) or 0
    screen_height = tonumber(screen_height) or 0
    if screen_width <= 0 or screen_height <= 0 then return false end

    local base_width, base_height = 720, 430
    local scale = math.min(1, (screen_width - 20) / base_width,
        (screen_height - 20) / base_height)
    if scale <= 0 then return false end

    local function scaled(value)
        return math.max(1, math.floor(value * scale + 0.5))
    end

    local width, height = scaled(base_width), scaled(base_height)
    local x = math.floor((screen_width - width) / 2)
    local y = math.floor((screen_height - height) / 2)

    local function rect(left, top, rect_width, rect_height, color)
        painter:rect(x + scaled(left), y + scaled(top), scaled(rect_width),
            scaled(rect_height), color)
    end

    local function border(left, top, rect_width, rect_height, thickness, color)
        painter:border(x + scaled(left), y + scaled(top), scaled(rect_width),
            scaled(rect_height), scaled(thickness), color)
    end

    local function text(left, top, value, size, color, effect)
        painter:text(font, x + scaled(left), y + scaled(top), value,
            scaled(size), color, effect)
    end

    local function image(left, top, image_width, image_height, effect)
        painter:image(x + scaled(left), y + scaled(top), scaled(image_width),
            scaled(image_height), shader_texture, {255, 255, 255, 255}, effect)
    end

    local profile = tostring(direct.ui_shader_profile())

    painter:begin()
    painter:rect(x, y, width, height, {8, 22, 72, 225})
    painter:border(x, y, width, height, 3, {235, 241, 255, 255})

    text(22, 14, 'DIRECTX RENDER DIAGNOSTICS', 24, {255, 255, 255, 255})
    text(440, 18, 'PIXEL PROFILE: ' .. profile:upper(), 16,
        {145, 205, 255, 255})
    rect(20, 50, 680, 2, {115, 145, 220, 255})

    text(22, 62, 'BITMAP TEXT', 16, {255, 220, 120, 255})
    text(22, 84, 'Aa Bb 0123456789  !?  []  /\\', 22,
        {245, 248, 255, 255})
    text(422, 88, 'SMALL TEXT: sharp and aligned', 13,
        {185, 205, 245, 255})

    text(22, 126, 'PIXEL SHADER SAMPLES', 16, {255, 220, 120, 255})
    text(42, 151, 'NORMAL', 14, {235, 240, 255, 255})
    text(185, 151, 'GRAYSCALE', 14, {235, 240, 255, 255})
    text(362, 151, 'SHIMMER', 14, {235, 240, 255, 255})
    text(530, 151, 'PULSE', 14, {235, 240, 255, 255})
    image(50, 174, 64, 64, nil)
    image(205, 174, 64, 64, 'grayscale')
    image(370, 174, 64, 64, 'shimmer')
    image(530, 174, 64, 64, 'pulse')
    border(42, 166, 80, 80, 1, {120, 155, 230, 255})
    border(197, 166, 80, 80, 1, {120, 155, 230, 255})
    border(362, 166, 80, 80, 1, {120, 155, 230, 255})
    border(522, 166, 80, 80, 1, {120, 155, 230, 255})

    text(22, 263, 'VERTEX SHADER VS.1.1 + PIXEL SHIMMER', 16,
        {255, 220, 120, 255})
    text(390, 265, 'IMAGE SHOULD BREATHE AND SWEEP', 13,
        {185, 205, 245, 255})
    image(28, 288, 120, 72, 'combined')
    border(22, 282, 132, 84, 1, {120, 155, 230, 255})
    text(177, 305, 'Animated size = vertex shader', 15,
        {235, 240, 255, 255})
    text(177, 330, 'Moving highlight = pixel shader', 15,
        {235, 240, 255, 255})

    -- Solid geometry is the non-textured baseline for alignment and fill size.
    text(470, 294, 'SOLID BASELINE', 14, {235, 240, 255, 255})
    rect(470, 320, 210, 18, {65, 78, 135, 255})
    rect(470, 320, 210, 18, {255, 155, 170, 255})
    border(470, 320, 210, 18, 1, {255, 220, 120, 255})
    rect(470, 346, 210, 14, {65, 78, 135, 255})
    rect(470, 346, 158, 14, {95, 220, 135, 255})
    border(470, 346, 210, 14, 1, {225, 235, 255, 255})
    rect(470, 368, 210, 10, {65, 78, 135, 255})
    rect(470, 368, 105, 10, {245, 195, 70, 255})
    border(470, 368, 210, 10, 1, {225, 235, 255, 255})

    text(22, 394, 'Use //dxtest status for runtime and shader diagnostics.', 14,
        {145, 205, 255, 255})

    -- Corner marks expose viewport alignment or clipping errors.
    rect(10, 10, 7, 7, {255, 255, 255, 255})
    rect(703, 10, 7, 7, {255, 255, 255, 255})
    rect(10, 413, 7, 7, {255, 255, 255, 255})
    rect(703, 413, 7, 7, {255, 255, 255, 255})

    painter:commit()
    drawn = true
    drawn_profile = profile
    return true
end

local function redraw()
    painter:clear()
    drawn = false
    drawn_profile = nil
    local succeeded, message = pcall(draw_test_panel)
    if not succeeded then
        chat(123, 'redraw failed: ' .. tostring(message))
        return false
    end
    return drawn
end

local function report_status()
    local screen_width, screen_height = painter:size()
    chat(207, ('runtime %s; shader %s; viewport %sx%s; visible %s'):format(
        tostring(direct.version()), tostring(direct.ui_shader_profile()),
        tostring(screen_width or '?'), tostring(screen_height or '?'), tostring(visible)))
    chat(207, 'tests: bitmap glyph textures; normal/grayscale/shimmer/pulse pixel paths; combined vs.1.1 + shimmer path.')

    local last_error = handle:last_error()
    local engineering_error = handle:engineering_error()
    if last_error and last_error ~= '' then chat(123, 'last error: ' .. tostring(last_error)) end
    if engineering_error and engineering_error ~= '' then
        chat(123, 'engineering error: ' .. tostring(engineering_error))
    end
end

-- The viewport can be unavailable during the first few frames after loading.
windower.register_event('prerender', function()
    if not visible then return end
    if not drawn or tostring(direct.ui_shader_profile()) ~= drawn_profile then redraw() end
end)

windower.register_event('addon command', function(command)
    command = tostring(command or 'toggle'):lower()
    if command == 'show' then
        visible = true
        redraw()
    elseif command == 'hide' then
        visible = false
        painter:clear()
        drawn = false
        drawn_profile = nil
    elseif command == 'toggle' then
        visible = not visible
        if visible then
            redraw()
        else
            painter:clear()
            drawn = false
            drawn_profile = nil
        end
    elseif command == 'redraw' then
        redraw()
    elseif command == 'status' then
        report_status()
    else
        chat(207, '//dxtest show | hide | toggle | redraw | status')
    end
end)

windower.register_event('unload', function()
    painter:clear()
end)

chat(207, 'loaded; the DirectX alignment panel will appear when the viewport is ready.')
