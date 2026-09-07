local json = require("carbJsonConfig")
local fa = require('fAwesome6_solid')
local ffi = require("ffi")
local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local log = {}

json.load(getWorkingDirectory()..'\\config\\profitchecker.json', log)

local selected_streak = 0
for k, v in ipairs(log) do
    selected_streak = k
end
local select_streak = false

local renderWindow = imgui.new.bool(false)
local inputs = {
    name = imgui.new.char[128](),
    price = imgui.new.char[128](),
}
local font
local font1
local font0

imgui.OnInitialize(function()
    fa.Init()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    font = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\arialbd.ttf', 16.0, _, glyph_ranges)
    font1 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\arialbd.ttf', 24.0, _, glyph_ranges)
    font0 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\arialbd.ttf', 14.0, _, glyph_ranges)
    imgui.GetIO().IniFilename = nil
    Theme()
end)

local newFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(self)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 1100, 600
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        -- imgui.WindowFlags.NoDecoration
        -- imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse
        if imgui.Begin('Profit checker', renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse) then
            imgui.PushFont(font)
            imgui.BeginChild("1", imgui.ImVec2(630, 500), true)
            if select_streak then
                imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.18, 0.19, 0.21, 1))
                imgui.BeginChild("fdsfsdf", imgui.ImVec2(-1, -1), true)
                imgui.CenterText(u8("Выберите серию"))
                for k, v in ipairs(log) do
                    if imgui.CustomSelectable(u8("Серия "..k), selected_streak == k) then
                        selected_streak = k
                        select_streak = false
                    end
                end
                if imgui.Button(u8("Новая серия"), imgui.ImVec2(-1, 30)) then
                    select_streak = false
                    selected_streak = #log+1
                    log[#log+1] = {}
                    save()
                end
                imgui.EndChild()
                imgui.PopStyleColor(1)
            else
                imgui.SetCursorPosY(150)
                imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.18, 0.19, 0.21, 1))
                imgui.BeginChild("add profit", imgui.ImVec2(600, 227), true)
                imgui.PushItemWidth(-1)
                imgui.InputTextWithHint("##iptprice", u8("Введите сумму"), inputs.price, ffi.sizeof(inputs.price))
                imgui.InputTextWithHint("##iptname", u8("Введите комментарий"), inputs.name, ffi.sizeof(inputs.name))
                imgui.PopFont()
                imgui.PushFont(font1)
                if imgui.Button(u8("СОХРАНИТЬ"), imgui.ImVec2(-1, 40)) then
                    if selected_streak == 0 then
                        select_streak = false
                        selected_streak = #log+1
                        log[#log+1] = {}
                        save()
                    end
                    if log[selected_streak] then
                        local p1 = ffi.string(inputs.price)
                        local p2 = u8:decode(p1)
                        local p3 = p2:gsub("%D", "")
                        local price = tonumber(p3)
                        table.insert(log[selected_streak], {time = os.time(), price = price, name = u8:decode(ffi.string(inputs.name))})
                        inputs = {
                            name = imgui.new.char[128](),
                            price = imgui.new.char[128](),
                        }
                    end
                    save()
                end
                imgui.PopFont()
                imgui.PushFont(font)
                imgui.BeginChild("gfdgsadgsd", imgui.ImVec2(imgui.CalcTextSize(u8("Заработано за серию:")).x+15, 50))
                imgui.CenterText(u8("Заработано за серию:"))
                imgui.CenterText(comma_value(calcEarned(selected_streak)))
                imgui.EndChild()

                imgui.SameLine()

                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.45, 0.54, 0.83, 1))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.45, 0.54, 0.83, 1))
                imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.45, 0.54, 0.83, 1))
                imgui.PushStyleVarVec2(imgui.StyleVar.FramePadding, imgui.ImVec2(4.00, 8.00))
                imgui.PopFont()
                imgui.PushFont(font0)
                if imgui.Button(u8("Новая серия"), imgui.ImVec2(90, 50)) then
                    select_streak = false
                    selected_streak = #log+1
                    log[#log+1] = {}
                    save()
                end

                imgui.SameLine()

                if imgui.Button(u8("Сбросить"), imgui.ImVec2(90, 50)) then
                    log[selected_streak] = {}
                    save()
                end
                imgui.PopStyleVar(1)
                imgui.PopStyleColor(3)
                imgui.PopFont()
                imgui.PushFont(font)

                imgui.SameLine()

                imgui.BeginChild("hnfgdji", imgui.ImVec2(imgui.CalcTextSize(u8("Заработано всего:")).x+15, 50))
                imgui.CenterText(u8("Заработано всего:"))
                imgui.CenterText(comma_value(calcEarned()))
                imgui.EndChild()

                imgui.EndChild()
                imgui.PopStyleColor(1)
            end
            imgui.EndChild()
            imgui.SameLine()
            imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.18, 0.19, 0.21, 1))
            imgui.BeginChild("2", imgui.ImVec2(-1, -1), true)
            if selected_streak ~= 0 then
                if log[selected_streak] then
                    for k, v in pairs(log[selected_streak]) do
                        imgui.DrawProfit(u8(v.name), v.price, v.time, imgui.ImVec2(-1, 60))
                    end
                end
            end
            imgui.EndChild()
            imgui.PopStyleColor(1)
            imgui.PopFont()
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.18, 0.19, 0.21, 0))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.18, 0.19, 0.21, 0))
            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.18, 0.19, 0.21, 0))
            imgui.SetCursorPosY(imgui.GetWindowSize().y-50)
            if imgui.Button("##dsafsdgsdgsdgds", imgui.ImVec2(200, 50)) then
                select_streak = true
            end
            imgui.PopStyleColor(3)
            imgui.End()
        end
    end
)

function main()
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand('profit', function()
        renderWindow[0] = not renderWindow[0]
    end)
    wait(-1)
end



function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end

function Theme()
    local style = imgui.GetStyle()
    local colors = style.Colors

    style.Alpha = 1.0
    style.WindowPadding = imgui.ImVec2(10.00, 10.00)
    style.WindowRounding = 10.0
    style.WindowBorderSize = 0.0
    style.WindowMinSize = imgui.ImVec2(50.00, 50.00)
    style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50)
    style.ChildRounding = 10.0
    style.ChildBorderSize = 1.0
    style.PopupRounding = 8.0
    style.PopupBorderSize = 1.0
    style.FramePadding = imgui.ImVec2(12.00, 8.00)
    style.FrameRounding = 10.0
    style.FrameBorderSize = 0.0
    style.ItemSpacing = imgui.ImVec2(10.00, 8.00)
    style.ItemInnerSpacing = imgui.ImVec2(8.00, 6.00)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 16.0
    style.ScrollbarRounding = 12.0
    style.GrabMinSize = 14.0
    style.GrabRounding = 8.0
    style.TabRounding = 10.0

    style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50)
    style.SelectableTextAlign = imgui.ImVec2(0.50, 0.50)
    colors[imgui.Col.Text] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.60, 0.60, 0.60, 1.00)
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.21, 0.22, 0.25, 1)
    colors[imgui.Col.ChildBg] = imgui.ImVec4(0.18, 0.19, 0.21, 0)
    colors[imgui.Col.PopupBg] = imgui.ImVec4(0.10, 0.10, 0.10, 1.00)
    colors[imgui.Col.Border] = imgui.ImVec4(0.33, 0.58, 0.34, 0)
    colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.21, 0.22, 0.25, 1)
    colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.23, 0.25, 0.27, 1)
    colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.25, 0.27, 0.29, 1)
    colors[imgui.Col.TitleBg] = imgui.ImVec4(0.18, 0.19, 0.22, 1)
    colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.18, 0.19, 0.22, 1)
    colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.18, 0.19, 0.22, 1)
    colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.18, 0.19, 0.21, 1)
    colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.29, 0.75, 0.29, 1)
    colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.30, 0.70, 0.30, 1.00)
    colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.40, 0.80, 0.40, 1.00)
    colors[imgui.Col.Button] = imgui.ImVec4(0.29, 0.75, 0.29, 1)
    colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.30, 0.70, 0.30, 1.00)
    colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.40, 0.80, 0.40, 1.00)
    colors[imgui.Col.Header] = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.70, 0.70, 0.70, 1.00)
    colors[imgui.Col.Tab] = imgui.ImVec4(0.35, 0.35, 0.35, 1.00)
    colors[imgui.Col.TabHovered] = imgui.ImVec4(0.55, 0.55, 0.55, 1.00)
    colors[imgui.Col.TabActive] = imgui.ImVec4(0.75, 0.75, 0.75, 1.00)
    colors[imgui.Col.PlotLines] = imgui.ImVec4(0.85, 0.85, 0.85, 1.00)
    colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.85, 0.85, 0.85, 1.00)
    colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.60, 0.60, 0.60, 0.35)
    colors[imgui.Col.DragDropTarget] = imgui.ImVec4(0.85, 0.85, 0.50, 0.90)
    colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.85, 0.85, 0.85, 1.00)
    colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.20, 0.20, 0.20, 0.20)
    colors[imgui.Col.CheckMark] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.20, 0.20, 0.20, 0.35)
end

function imgui.DrawProfit(name, price, time, size)
    local data = {}
    if type(name) == "table" then
        data = name
    else
        data.name = name
        data.price = price
        data.time = time
        data.size = size
    end
    data.size = data.size or imgui.ImVec2(-1, 30)

    local style = imgui.GetStyle()
    local colors = style.Colors

    local bg_colors = {
        default = imgui.ColorConvertFloat4ToU32(colors[imgui.Col.FrameBg]),
        hovered = imgui.ColorConvertFloat4ToU32(colors[imgui.Col.FrameBgHovered]),
        active = imgui.ColorConvertFloat4ToU32(colors[imgui.Col.FrameBgActive]),
        border = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.29, 0.75, 0.28, 1)),
    }

    local text_size = imgui.CalcTextSize(data.name)
    local price_size = imgui.CalcTextSize(comma_value(data.price))
    local p = imgui.GetCursorScreenPos()
    local dl = imgui.GetWindowDrawList()
    local result = imgui.InvisibleButton(data.name, data.size)
    data.size = imgui.GetItemRectSize()

    local frame_color = data.selected and bg_colors.active or (imgui.IsItemHovered() and bg_colors.hovered or bg_colors.default)

    dl:AddRectFilled(p, imgui.ImVec2(p.x+data.size.x, p.y+data.size.y), frame_color, 5)
    dl:AddRect(p, imgui.ImVec2(p.x+data.size.x, p.y+data.size.y), bg_colors.border, 5, nil, 2)
    dl:AddText(
        imgui.ImVec2(p.x+12, p.y+8),
        0xAAFFFFFF,
        os.date("%H:%M:%S", data.time)
    )
    dl:AddText(
        imgui.ImVec2(p.x+data.size.x/2-price_size.x/2, p.y+8),
        -1,
        comma_value(data.price)
    )
    dl:AddText(
        imgui.ImVec2(p.x+data.size.x/2-text_size.x/2, p.y+data.size.y-text_size.y-8),
        -1,
        data.name
    )
    return result
end

function imgui.CustomSelectable(label, selected, size, center)
    local data = {}
    if type(label) == "table" then
        data = label
    else
        data.label = label
        data.size = size
        data.center = center
        data.selected = selected
    end
    data.size = data.size or imgui.ImVec2(-1, 30)

    local style = imgui.GetStyle()
    local colors = style.Colors

    local bg_colors = {
        default = imgui.ColorConvertFloat4ToU32(colors[imgui.Col.FrameBg]),
        hovered = imgui.ColorConvertFloat4ToU32(colors[imgui.Col.FrameBgHovered]),
        active = imgui.ColorConvertFloat4ToU32(colors[imgui.Col.FrameBgActive]),
        border = imgui.ColorConvertFloat4ToU32(colors[imgui.Col.Border]),
    }

    local text_size = imgui.CalcTextSize(data.label)
    local p = imgui.GetCursorScreenPos()
    local dl = imgui.GetWindowDrawList()
    local result = imgui.InvisibleButton(data.label, data.size)
    data.size = imgui.GetItemRectSize()

    local frame_color = data.selected and bg_colors.active or (imgui.IsItemHovered() and bg_colors.hovered or bg_colors.default)

    dl:AddRectFilled(p, imgui.ImVec2(p.x+data.size.x, p.y+data.size.y), frame_color, 5)
    dl:AddRect(p, imgui.ImVec2(p.x+data.size.x, p.y+data.size.y), bg_colors.border, 5)
    dl:AddText(data.center and
        imgui.ImVec2(p.x+data.size.x/2-text_size.x/2, p.y+data.size.y/2-text_size.y/2)
        or
        imgui.ImVec2(p.x+12, p.y+data.size.y/2-text_size.y/2),
        -1,
        data.label
    )
    return result
end

function comma_value(n)
    if not n then return "" end
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right.."$"
end

function calcEarned(streak)
    local result = 0
    if streak then
        if log[streak] then
            for k, v in pairs(log[streak]) do
                result=result+(v.price or 0)
            end
        end
    else
        for num, strk in pairs(log) do
            for k, v in pairs(strk) do
                result=result+(v.price or 0)
            end
        end
    end
    return result
end

function save()
    json.save(getWorkingDirectory()..'\\config\\profitchecker.json', log)
end