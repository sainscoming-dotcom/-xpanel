script_name("XPanel Arizona RP")
script_author("Diazz_Kaneki | Server 20")
script_version("2.1.0")
script_description("XPanel Arizona RP - purple UI and automatic mask timer")

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
local lastAppliedInterval = 10

local function chat(text)
    sampAddChatMessage("{9B6CFF}[XPanel] {FFFFFF}" .. text, -1)
end

local function resetTimer()
    lastAppliedInterval = math.max(1, math.min(60, interval[0]))
    secondsLeft = lastAppliedInterval * 60
    status = "Таймер запущен"
end

local function updateMask()
    -- Если на вашем сервере команда маски другая, замените /mask здесь.
    sampSendChat("/mask")
    resetTimer()
    status = "Маска обновлена"
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
    style.TabRounding = 9

    style.WindowBorderSize = 1.0
    style.ChildBorderSize = 1.0
    style.FrameBorderSize = 1.0
    style.PopupBorderSize = 1.0

    style.WindowPadding = imgui.ImVec2(18, 18)
    style.FramePadding = imgui.ImVec2(12, 9)
    style.ItemSpacing = imgui.ImVec2(10, 10)
    style.ItemInnerSpacing = imgui.ImVec2(8, 6)
    style.ScrollbarSize = 12
end

local function beginPurpleTheme()
    imgui.PushStyleColor(imgui.Col.WindowBg,       imgui.ImVec4(0.035, 0.018, 0.085, 0.985))
    imgui.PushStyleColor(imgui.Col.ChildBg,        imgui.ImVec4(0.055, 0.025, 0.120, 0.96))
    imgui.PushStyleColor(imgui.Col.PopupBg,        imgui.ImVec4(0.055, 0.025, 0.120, 0.98))
    imgui.PushStyleColor(imgui.Col.Border,         imgui.ImVec4(0.42, 0.18, 0.78, 0.70))
    imgui.PushStyleColor(imgui.Col.FrameBg,        imgui.ImVec4(0.10, 0.045, 0.22, 1.0))
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(0.19, 0.07, 0.38, 1.0))
    imgui.PushStyleColor(imgui.Col.FrameBgActive,  imgui.ImVec4(0.27, 0.10, 0.52, 1.0))
    imgui.PushStyleColor(imgui.Col.Button,         imgui.ImVec4(0.22, 0.08, 0.48, 1.0))
    imgui.PushStyleColor(imgui.Col.ButtonHovered,  imgui.ImVec4(0.38, 0.13, 0.72, 1.0))
    imgui.PushStyleColor(imgui.Col.ButtonActive,   imgui.ImVec4(0.52, 0.20, 0.88, 1.0))
    imgui.PushStyleColor(imgui.Col.Header,         imgui.ImVec4(0.25, 0.09, 0.52, 1.0))
    imgui.PushStyleColor(imgui.Col.HeaderHovered,  imgui.ImVec4(0.38, 0.13, 0.72, 1.0))
    imgui.PushStyleColor(imgui.Col.HeaderActive,   imgui.ImVec4(0.48, 0.18, 0.82, 1.0))
    imgui.PushStyleColor(imgui.Col.CheckMark,      imgui.ImVec4(0.70, 0.38, 1.0, 1.0))
    imgui.PushStyleColor(imgui.Col.SliderGrab,     imgui.ImVec4(0.62, 0.30, 0.95, 1.0))
    imgui.PushStyleColor(imgui.Col.SliderGrabActive,imgui.ImVec4(0.80, 0.48, 1.0, 1.0))
    imgui.PushStyleColor(imgui.Col.Text,           imgui.ImVec4(0.95, 0.91, 1.0, 1.0))
    imgui.PushStyleColor(imgui.Col.TextDisabled,   imgui.ImVec4(0.63, 0.54, 0.75, 1.0))
end

local function endPurpleTheme()
    imgui.PopStyleColor(17)
end

sampRegisterChatCommand("xpanel", function()
    showWindow[0] = not showWindow[0]
end)

imgui.OnInitialize(function()
    setupStyle()
end)

imgui.OnFrame(function()
    return showWindow[0]
end, function()
    imgui.SetNextWindowSize(imgui.ImVec2(760, 600), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSizeConstraints(imgui.ImVec2(560, 430), imgui.ImVec2(1400, 1000))

    beginPurpleTheme()

    imgui.Begin(u8("XPanel Arizona RP 2.1"), showWindow,
        imgui.WindowFlags.NoCollapse)

    -- Шапка
    imgui.TextColored(imgui.ImVec4(0.72, 0.42, 1.0, 1.0), u8("◆  XPANEL ARIZONA RP"))
    imgui.SameLine()
    imgui.TextColored(imgui.ImVec4(0.63, 0.55, 0.75, 1.0), u8("   |   Управление игровыми функциями"))
    imgui.SameLine()
    imgui.TextColored(imgui.ImVec4(0.82, 0.65, 1.0, 1.0), u8("Diazz_Kaneki  •  Server 20"))

    imgui.Separator()
    imgui.Spacing()

    -- Настройки
    imgui.BeginChild("settings", imgui.ImVec2(0, 150), true)
        imgui.TextColored(imgui.ImVec4(0.72, 0.42, 1.0, 1.0), u8("⚙  НАСТРОЙКИ"))
        imgui.TextColored(imgui.ImVec4(0.63, 0.55, 0.75, 1.0),
            u8("Автоматическое обновление маски"))

        imgui.Spacing()

        imgui.Checkbox(u8("Автоматически обновлять маску"), autoMask)

        imgui.SameLine()
        imgui.SetCursorPosX(imgui.GetWindowWidth() - 335)
        imgui.Text(u8("Интервал:"))

        imgui.SameLine()
        imgui.PushItemWidth(80)
        imgui.InputInt("##interval", interval)
        imgui.PopItemWidth()

        if interval[0] < 1 then interval[0] = 1 end
        if interval[0] > 60 then interval[0] = 60 end

        imgui.SameLine()
        if imgui.Button(u8("Применить##interval"), imgui.ImVec2(115, 30)) then
            resetTimer()
            chat("Интервал установлен: " .. interval[0] .. " мин.")
        end
    imgui.EndChild()

    imgui.Spacing()

    -- Статус таймера
    imgui.BeginChild("status", imgui.ImVec2(0, 92), true)
        imgui.TextColored(imgui.ImVec4(0.72, 0.42, 1.0, 1.0), u8("◉  СОСТОЯНИЕ"))
        imgui.SameLine()
        if autoMask[0] then
            imgui.TextColored(imgui.ImVec4(0.45, 1.0, 0.65, 1.0), u8("● АКТИВНО"))
        else
            imgui.TextColored(imgui.ImVec4(1.0, 0.55, 0.55, 1.0), u8("● ВЫКЛЮЧЕНО"))
        end

        imgui.Spacing()
        imgui.Text(u8("До обновления:  "))
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.82, 0.65, 1.0, 1.0), timeText(secondsLeft))
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.63, 0.55, 0.75, 1.0), u8("   •   " .. status))
    imgui.EndChild()

    imgui.Spacing()

    -- Маска
    imgui.BeginChild("mask", imgui.ImVec2(0, 128), true)
        imgui.TextColored(imgui.ImVec4(0.72, 0.42, 1.0, 1.0), u8("♢  МАСКА ПЕРСОНАЖА"))
        imgui.TextColored(imgui.ImVec4(0.63, 0.55, 0.75, 1.0),
            u8("Быстрые действия"))

        imgui.Spacing()

        local w = (imgui.GetWindowWidth() - 30) / 2

        if imgui.Button(u8("НАДЕТЬ / ОБНОВИТЬ МАСКУ"), imgui.ImVec2(w, 46)) then
            updateMask()
        end

        imgui.SameLine()

        if imgui.Button(u8("СБРОСИТЬ ТАЙМЕР"), imgui.ImVec2(w, 46)) then
            resetTimer()
            chat("Таймер сброшен.")
        end
    imgui.EndChild()

    imgui.Spacing()

    -- Команды
    imgui.BeginChild("commands", imgui.ImVec2(0, 0), true)
        imgui.TextColored(imgui.ImVec4(0.72, 0.42, 1.0, 1.0), u8("ℹ  ИНФОРМАЦИЯ И КОМАНДЫ"))
        imgui.TextColored(imgui.ImVec4(0.63, 0.55, 0.75, 1.0),
            u8("Доступные команды панели"))

        imgui.Spacing()

        if imgui.Button(u8("/xpanel"), imgui.ImVec2(120, 34)) then
            -- Команда уже открыта; кнопка оставлена как подсказка.
        end
        imgui.SameLine()
        imgui.Text(u8("Открыть панель управления"))
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.55, 0.45, 0.68, 1.0),
            u8("   Команда открытия XPanel"))

        if imgui.Button(u8("/mask"), imgui.ImVec2(120, 34)) then
            updateMask()
        end
        imgui.SameLine()
        imgui.Text(u8("Надеть / обновить маску"))
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.55, 0.45, 0.68, 1.0),
            u8("   Команда сервера"))

        imgui.Spacing()

        imgui.TextColored(imgui.ImVec4(0.55, 0.45, 0.68, 1.0),
            u8("Размер окна можно изменять мышью за нижний правый угол."))

    imgui.EndChild()

    imgui.Spacing()
    imgui.TextColored(imgui.ImVec4(0.55, 0.45, 0.68, 1.0),
        u8("XPanel Arizona RP v2.1.0"))
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 155)
    imgui.TextColored(imgui.ImVec4(0.65, 0.50, 0.85, 1.0), u8("Server 20  •  09:34"))

    imgui.End()
    endPurpleTheme()
end)

function main()
    while not isSampAvailable() do
        wait(100)
    end

    wait(1000)
    resetTimer()
    chat("XPanel 2.1 загружен! Открытие панели: {C8B6FF}/xpanel")

    while true do
        wait(1000)

        if autoMask[0] then
            secondsLeft = secondsLeft - 1

            if secondsLeft <= 0 then
                updateMask()
            end
        end
    end
end
