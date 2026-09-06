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

local function resetTimer()
    secondsLeft = math.max(1, interval[0]) * 60
    status = "Таймер запущен"
end

local function updateMask()
    -- Если на вашем сервере команда маски другая, замените /mask ниже.
    sampSendChat("/mask")
    resetTimer()
    status = "Маска обновлена"
end

local function timeText(sec)
    local m = math.floor(sec / 60)
    local s = sec % 60
    return string.format("%02d:%02d", m, s)
end

sampRegisterChatCommand("xpanel", function()
    showWindow[0] = not showWindow[0]
end)

imgui.OnFrame(function()
    return showWindow[0]
end, function()
    imgui.SetNextWindowSize(imgui.ImVec2(540, 410), imgui.Cond.FirstUseEver)
    imgui.Begin(u8("XPanel Arizona RP 2.0"), showWindow)

    imgui.Text(u8("XPanel Arizona RP"))
    imgui.Text(u8("Diazz_Kaneki | Server 20"))
    imgui.Text(u8("Версия 2.0.0"))
    imgui.Separator()

    imgui.Text(u8("АВТОМАТИЧЕСКАЯ МАСКА"))
    imgui.Checkbox(u8("Автоматически обновлять маску"), autoMask)

    imgui.PushItemWidth(180)
    imgui.InputInt(u8("Интервал (минуты)"), interval)
    imgui.PopItemWidth()

    if interval[0] < 1 then interval[0] = 1 end
    if interval[0] > 60 then interval[0] = 60 end

    imgui.Text(u8("Осталось: ") .. timeText(secondsLeft))
    imgui.Text(u8("Статус: ") .. u8(status))

    if imgui.Button(u8("Надеть / обновить маску"), imgui.ImVec2(245, 40)) then
        updateMask()
    end

    imgui.SameLine()
    if imgui.Button(u8("Сбросить таймер"), imgui.ImVec2(200, 40)) then
        resetTimer()
    end

    imgui.Separator()
    imgui.Text(u8("БЫСТРЫЕ ДЕЙСТВИЯ"))

    if imgui.Button(u8("/mask"), imgui.ImVec2(130, 35)) then
        updateMask()
    end

    imgui.SameLine()
    if imgui.Button(u8("Закрыть"), imgui.ImVec2(130, 35)) then
        showWindow[0] = false
    end

    imgui.Separator()
    imgui.TextWrapped(u8("Панель открывается командой /xpanel."))
    imgui.TextWrapped(u8("По умолчанию таймер установлен на 10 минут."))
    imgui.TextWrapped(u8("Команда маски: /mask. При необходимости измени её в функции updateMask()."))

    imgui.End()
end)

function main()
    while not isSampAvailable() do
        wait(100)
    end

    wait(1000)
    resetTimer()
    chat("XPanel 2.0 загружен! Открытие панели: {C8B6FF}/xpanel")

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
