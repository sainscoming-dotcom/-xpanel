script_name("XPanel Arizona RP")
script_author("Diazz_Kaneki | Server 20")
script_version("2.0.0")
script_description("XPanel Arizona RP - panel and automatic mask timer")

require "lib.moonloader"

local ok_imgui, imgui = pcall(require, "mimgui")
local ok_encoding, encoding = pcall(require, "encoding")

if not ok_imgui then
    function main()
        while not isSampAvailable() do wait(100) end
        sampAddChatMessage("{FF4444}[XPanel] {FFFFFF}Не найдена библиотека mimgui в moonloader/lib.", -1)
        while true do wait(1000) end
    end
    return
end

local u8 = function(s) return s end
if ok_encoding then
    encoding.default = "CP1251"
    u8 = encoding.UTF8
end

local showWindow = imgui.new.bool(false)
local autoMask = imgui.new.bool(true)
local interval = imgui.new.int(10)

local secondsLeft = 600
local status = "Таймер запущен"

local function chat(text)
    sampAddChatMessage("{9B6CFF}[XPanel] {FFFFFF}" .. text, -1)
end

local function clampInterval()
    if interval[0] < 1 then interval[0] = 1 end
    if interval[0] > 50 then interval[0] = 50 end
end

local function resetTimer()
    clampInterval()
    secondsLeft = interval[0] * 60
    status = "Таймер запущен"
end

local function mask()
    sampSendChat("/mask")
    resetTimer()
    status = "Маска обновлена"
end

local function unmask()
    sampSendChat("/unmask")
    status = "Маска снята"
end

local function timeText(sec)
    sec = math.max(0, sec)
    local m = math.floor(sec / 60)
    local s = sec % 60
    return string.format("%02d:%02d", m, s)
end

local function setupStyle()
    local style = imgui.GetStyle()

    style.WindowRounding = 14
    style.ChildRounding = 12
    style.FrameRounding = 9
    style.PopupRounding = 10
    style.ScrollbarRounding = 9
    style.GrabRounding = 9

    style.WindowBorderSize = 1
    style.ChildBorderSize = 1
    style.FrameBorderSize = 1

    style.WindowPadding = imgui.ImVec2(18, 18)
    style.FramePadding = imgui.ImVec2(12, 9)
    style.ItemSpacing = imgui.ImVec2(10, 10)
    style.ItemInnerSpacing = imgui.ImVec2(8, 6)
    style.ScrollbarSize = 11
end

local function pushTheme()
    imgui.PushStyleColor(imgui.Col.WindowBg,        imgui.ImVec4(0.035, 0.018, 0.085, 0.99))
    imgui.PushStyleColor(imgui.Col.ChildBg,         imgui.ImVec4(0.055, 0.025, 0.120, 0.96))
    imgui.PushStyleColor(imgui.Col.PopupBg,         imgui.ImVec4(0.055, 0.025, 0.120, 0.99))
    imgui.PushStyleColor(imgui.Col.Border,          imgui.ImVec4(0.42, 0.18, 0.78, 0.75))
    imgui.PushStyleColor(imgui.Col.FrameBg,         imgui.ImVec4(0.10, 0.045, 0.22, 1.0))
    imgui.PushStyleColor(imgui.Col.FrameBgHovered,  imgui.ImVec4(0.19, 0.07, 0.38, 1.0))
    imgui.PushStyleColor(imgui.Col.FrameBgActive,   imgui.ImVec4(0.27, 0.10, 0.52, 1.0))
    imgui.PushStyleColor(imgui.Col.Button,          imgui.ImVec4(0.22, 0.08, 0.48, 1.0))
    imgui.PushStyleColor(imgui.Col.ButtonHovered,   imgui.ImVec4(0.38, 0.13, 0.72, 1.0))
    imgui.PushStyleColor(imgui.Col.ButtonActive,    imgui.ImVec4(0.52, 0.20, 0.88, 1.0))
    imgui.PushStyleColor(imgui.Col.CheckMark,       imgui.ImVec4(0.70, 0.38, 1.0, 1.0))
    imgui.PushStyleColor(imgui.Col.SliderGrab,      imgui.ImVec4(0.62, 0.30, 0.95, 1.0))
    imgui.PushStyleColor(imgui.Col.SliderGrabActive,imgui.ImVec4(0.80, 0.48, 1.0, 1.0))
    imgui.PushStyleColor(imgui.Col.Text,            imgui.ImVec4(0.95, 0.91, 1.0, 1.0))
    imgui.PushStyleColor(imgui.Col.TextDisabled,    imgui.ImVec4(0.63, 0.54, 0.75, 1.0))
end

local function popTheme()
    imgui.PopStyleColor(15)
end

local purple = imgui.ImVec4(0.72, 0.42, 1.0, 1.0)
local muted = imgui.ImVec4(0.63, 0.55, 0.75, 1.0)
local white = imgui.ImVec4(0.95, 0.91, 1.0, 1.0)

sampRegisterChatCommand("xpanel", function()
    showWindow[0] = not showWindow[0]
end)

imgui.OnInitialize(function()
    setupStyle()
end)

imgui.OnFrame(function()
    return showWindow[0]
end, function()
    -- Окно можно свободно растягивать мышью.
    imgui.SetNextWindowSize(imgui.ImVec2(760, 600), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSizeConstraints(
        imgui.ImVec2(620, 500),
        imgui.ImVec2(1600, 1200)
    )

    pushTheme()

    imgui.Begin(u8("XPanel Arizona RP"), showWindow)

    -- ШАПКА
    imgui.TextColored(purple, u8("◆  XPANEL ARIZONA RP"))
    imgui.SameLine()
    imgui.TextColored(muted, u8("Управляйте игровыми функциями с удобством"))

    imgui.SameLine()
    local rightX = imgui.GetWindowWidth() - 245
    if rightX > 400 then
        imgui.SetCursorPosX(rightX)
    end
    imgui.TextColored(white, u8("Diazz_Kaneki  |  Server 20"))

    imgui.Separator()

    -- НАСТРОЙКИ
    imgui.BeginChild("Settings", imgui.ImVec2(0, 145), true)

        imgui.TextColored(purple, u8("⚙  НАСТРОЙКИ"))
        imgui.TextColored(muted, u8("Выберите значение и нажмите для применения"))

        imgui.Spacing()

        imgui.BeginChild("SettingRow", imgui.ImVec2(0, 62), true)

            imgui.TextColored(white, u8("Значение параметра"))

            imgui.SameLine()
            if imgui.Button(u8("−##minus"), imgui.ImVec2(48, 38)) then
                interval[0] = interval[0] - 1
                clampInterval()
            end

            imgui.SameLine()
            imgui.PushItemWidth(100)
            imgui.InputInt(u8("##interval"), interval)
            imgui.PopItemWidth()

            imgui.SameLine()
            if imgui.Button(u8("+##plus"), imgui.ImVec2(48, 38)) then
                interval[0] = interval[0] + 1
                clampInterval()
            end

            imgui.SameLine()
            imgui.TextColored(muted, u8("Настройте параметр от 1 до 50"))

            imgui.SameLine()
            local applyX = imgui.GetWindowWidth() - 145
            if applyX > imgui.GetCursorPosX() then
                imgui.SetCursorPosX(applyX)
            end

            if imgui.Button(u8("✓  ПРИМЕНИТЬ"), imgui.ImVec2(125, 38)) then
                resetTimer()
            end

        imgui.EndChild()
    imgui.EndChild()

    imgui.Spacing()

    -- МАСКА
    imgui.BeginChild("Mask", imgui.ImVec2(0, 145), true)

        imgui.TextColored(purple, u8("♢  МАСКА ПЕРСОНАЖА"))
        imgui.TextColored(muted, u8("Управление маской персонажа"))

        imgui.Spacing()

        local buttonWidth = (imgui.GetWindowWidth() - 30) / 2

        if imgui.Button(u8("♢   /mask"), imgui.ImVec2(buttonWidth, 60)) then
            mask()
        end

        imgui.SameLine()

        if imgui.Button(u8("♢   Снять маску"), imgui.ImVec2(buttonWidth, 60)) then
            unmask()
        end

    imgui.EndChild()

    imgui.Spacing()

    -- ИНФОРМАЦИЯ И КОМАНДЫ
    imgui.BeginChild("Info", imgui.ImVec2(0, 0), true)

        imgui.TextColored(purple, u8("●  ИНФОРМАЦИЯ И КОМАНДЫ"))
        imgui.TextColored(muted, u8("Доступные команды панели"))

        imgui.Spacing()

        imgui.BeginChild("CommandList", imgui.ImVec2(0, 178), true)

            imgui.TextColored(white, u8("/xpanel"))
            imgui.SameLine()
            imgui.TextColored(muted, u8("Открыть панель управления"))
            imgui.TextColored(muted, u8("Основная команда для открытия панели XPanel"))

            imgui.Separator()

            imgui.TextColored(white, u8("/mask"))
            imgui.SameLine()
            imgui.TextColored(muted, u8("Надеть маску"))
            imgui.TextColored(muted, u8("Надевает маску на персонажа"))

            imgui.Separator()

            imgui.TextColored(white, u8("/unmask"))
            imgui.SameLine()
            imgui.TextColored(muted, u8("Снять маску"))
            imgui.TextColored(muted, u8("Снимает текущую маску с персонажа"))

        imgui.EndChild()

    imgui.EndChild()

    imgui.Separator()

    -- НИЖНЯЯ ПАНЕЛЬ
    imgui.TextColored(purple, u8("●"))
    imgui.SameLine()
    imgui.TextColored(white, u8("XPanel Arizona RP v2.0.0"))

    imgui.SameLine()
    imgui.TextColored(muted, u8("Удобное управление игровыми функциями"))

    imgui.SameLine()
    local footerX = imgui.GetWindowWidth() - 270
    if footerX > imgui.GetCursorPosX() then
        imgui.SetCursorPosX(footerX)
    end
    imgui.TextColored(muted, u8("Diazz_Kaneki   |   Server 20"))

    imgui.End()

    popTheme()
end)

function main()
    while not isSampAvailable() do
        wait(100)
    end

    wait(1000)
    resetTimer()
    chat("XPanel 2.0 загружен! Открытие панели: /xpanel")

    while true do
        wait(1000)

        if autoMask[0] then
            secondsLeft = secondsLeft - 1

            if secondsLeft <= 0 then
                mask()
            end
        end
    end
end
