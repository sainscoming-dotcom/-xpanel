script_name("XPanel Arizona RP")
script_author("Diazz_Kaneki | Server 20")
script_version("1.0.0")

require "lib.moonloader"
local sampev = require "lib.samp.events"
local inicfg = require "inicfg"
local imgui = require "mimgui"
local ffi = require "ffi"
local encoding = require "encoding"

encoding.default = "CP1251"
local u8 = encoding.UTF8

local CONFIG_NAME = "xpanel_arizona"
local MASK_INTERVAL = 10 * 60 * 1000 -- 10 minutes

local cfg = inicfg.load({
    main = {
        autoMask = true,
        vipUnlocked = false,
        devUnlocked = false,
        localMasterEnabled = true
    }
}, CONFIG_NAME)

inicfg.save(cfg, CONFIG_NAME)

local window = imgui.new.bool(false)
local vipPopup = imgui.new.bool(false)
local devPopup = imgui.new.bool(false)
local keyBuffer = imgui.new.char[128]()
local activeTab = 1

local nextMaskAt = 0
local lastMaskAt = 0

local VIP_KEYS = {
    ["VIP-Y047B8HHY9KRHEEJ"] = true,
    ["VIP-5VWGMXFHV9E6XO0C"] = true,
    ["VIP-0D1J9CREJ1PN5EJS"] = true,
    ["VIP-X15TCP4KXF7BI1KW"] = true,
    ["VIP-51LJ4ZO1M45VS4SY"] = true,
    ["VIP-LPAHJ0GFZQKOEVX8"] = true,
    ["VIP-K1Q7EL4WXM7JJ5XJ"] = true,
    ["VIP-JIUA7EVAIQGVGCTN"] = true,
    ["VIP-UVKBNHTIOBOECOKC"] = true,
    ["VIP-FGU9TVMWUS1WXP68"] = true,
    ["VIP-FDHIP5IWL9K4QQQ5"] = true,
    ["VIP-405D61JBHUJK9YLD"] = true,
    ["VIP-TLFIKXFCO6XGA41Q"] = true,
    ["VIP-Z5G7KZ3T323M0K6L"] = true,
    ["VIP-73LYD30S1PDBKZXC"] = true,
    ["VIP-RO2TN8K85PTEHHWX"] = true,
    ["VIP-QSAVUD8C70GK0KI5"] = true,
    ["VIP-DK0K76D4ITD8PC8A"] = true,
    ["VIP-KMX4GTQU8O1B6PI7"] = true,
    ["VIP-INZUR85FULJ6GP18"] = true,
    ["VIP-VP5O12IJ6TA0EGXJ"] = true,
    ["VIP-PQTVD6O8LJBW8PPW"] = true,
    ["VIP-16ARLMTVMARGSA28"] = true,
    ["VIP-2XEPYKU93AF1IUTL"] = true,
    ["VIP-ZKDQ9W2HMM9JBVU1"] = true,
    ["VIP-H9MEMFG0DSV0XRC6"] = true,
    ["VIP-2Z2M4QPGQP15D004"] = true,
    ["VIP-KBZUAHXC6MT68QPY"] = true,
    ["VIP-I2BEJ1ZSIIIFPHMK"] = true,
    ["VIP-YDLXIHKYBVPUG91V"] = true,
    ["VIP-QYLA2BY4JBIY59KJ"] = true,
    ["VIP-9066IWNTQ0DBY64Q"] = true,
    ["VIP-JSKZ7X2FVN0SDHWN"] = true,
    ["VIP-WB4ZKIDXX4KUPSXO"] = true,
    ["VIP-HG6631KCVMS8CBAI"] = true,
    ["VIP-TDOFU45CZI91FKLZ"] = true,
    ["VIP-X3OYD1V57VHE6EKI"] = true,
    ["VIP-L0DSENVAIQPDQPYJ"] = true,
    ["VIP-ITITVT8DTCE3KF8T"] = true,
    ["VIP-S2GR7QKQ1PLGEMZD"] = true,
    ["VIP-YPHTOGVYWASI3IJ3"] = true,
    ["VIP-2A21VN3AMLT0I6XB"] = true,
    ["VIP-4VTHNMCXSIXRMLDR"] = true,
    ["VIP-ADD37TXKRL0E1SYI"] = true,
    ["VIP-S41S9QQ8F6I3CJ0P"] = true,
    ["VIP-0CIWDUGB3FTY69B9"] = true,
    ["VIP-UP6237123HUW1PC0"] = true,
    ["VIP-RU400OOBRQV7QT5S"] = true,
    ["VIP-V5SNEVGUI23LJDQ5"] = true,
    ["VIP-GVB7EX594GD13TBY"] = true,
    ["VIP-ZGF3ZCE0D88JTKEE"] = true,
    ["VIP-2A4YP8HDYA6QB6WQ"] = true,
    ["VIP-LPWHQR0M27NAMOWL"] = true,
    ["VIP-OB4O5VFZ581O4C9V"] = true,
    ["VIP-QYQOAYY4OPLXPZKX"] = true,
    ["VIP-F2DRBOWK3ZGFYOSA"] = true,
    ["VIP-Y4FRLUUKT93MU6XU"] = true,
    ["VIP-RYXSIFKI1JIJI0ZA"] = true,
    ["VIP-54D98PTJ96HO23ST"] = true,
    ["VIP-ER1F6L4HL8ACO6K4"] = true,
    ["VIP-DLU1YPOYC4DF8ED2"] = true,
    ["VIP-WKCWH187RY9Q8FJB"] = true,
    ["VIP-2ZBLK5MX772EXZJO"] = true,
    ["VIP-5I5FXYONCPX5ITVC"] = true,
    ["VIP-SFIGWA5EUIJDRDRO"] = true,
    ["VIP-C6Q8C57RNIE1LBDA"] = true,
    ["VIP-EYXOQTVBQSTX535J"] = true,
    ["VIP-VBHKDB7YPO2F41UD"] = true,
    ["VIP-EZ06DMA201LWGOV9"] = true,
    ["VIP-WMPUY50DUUIZGCXB"] = true,
    ["VIP-DBK8X3K5UNJ71N5F"] = true,
    ["VIP-LCUF9WUT849KVE0M"] = true,
    ["VIP-33EAFZVOO9IRKJZK"] = true,
    ["VIP-PNWDP2H0CRNODADH"] = true,
    ["VIP-TUDR7HJL1XHW8G8C"] = true,
    ["VIP-DGLHW76HFUT94642"] = true,
    ["VIP-R2OYLK55JABG074L"] = true,
    ["VIP-2FCB0YVJAJAA78F3"] = true,
    ["VIP-28B7WH77Z4I9Z0RG"] = true,
    ["VIP-9AMB3JI1QWYFRFSJ"] = true,
    ["VIP-9XU7RLECS5ZPHXFK"] = true,
    ["VIP-34OOU4UW3OMK5J7X"] = true,
    ["VIP-MKC6ZIWKZTGTCEE0"] = true,
    ["VIP-ZQLR19Q21DHXM34A"] = true,
    ["VIP-90PDXQ2RP54UO66Z"] = true,
    ["VIP-AWV93POT0MK7ENXL"] = true,
    ["VIP-7DLB1ZQDK7Z44HZ3"] = true,
    ["VIP-RH0TMEM3HFHD2DHW"] = true,
    ["VIP-X2LWJPZ6CGJH9OXP"] = true,
    ["VIP-JQ97T020TTGK3K87"] = true,
    ["VIP-SRCT9XZLXBEWVY9B"] = true,
    ["VIP-JAB3R9PHP1N4GLYU"] = true,
    ["VIP-IHFJ6TRCP4L8QPRH"] = true,
    ["VIP-EURHBCN8W7I95DSH"] = true,
    ["VIP-KM934D2L4I87HMJQ"] = true,
    ["VIP-OUMINBZRZ3OE9B08"] = true,
    ["VIP-9Q1ZNYT8YGZL7H61"] = true,
    ["VIP-TCGTBNA0913ELKYP"] = true,
    ["VIP-B4U58U0NSE8CBPRY"] = true,
    ["VIP-Z4BEK6LD6YY0LLPL"] = true,
    ["VIP-O6KPRP0DY97CU51V"] = true,
    ["VIP-9DG7TXTE33NRZ4J3"] = true,
    ["VIP-9T87MXEVZ4ZRBQB8"] = true,
    ["VIP-ZYA5I0LZO0MKU8OQ"] = true,
    ["VIP-6B6S0ZTA6G3CKDFV"] = true,
    ["VIP-9FKHA6H4C69P8ZCX"] = true,
    ["VIP-5KQ5ND7RZ36XFHCO"] = true,
    ["VIP-6KIEU0EPYT7J8AME"] = true,
    ["VIP-4HJIVAL245ILX4HU"] = true,
    ["VIP-0CVKSEABL7LYJY4W"] = true,
    ["VIP-9TUVKW1T4KDP4SKN"] = true,
    ["VIP-ZTFME965UHR6BZOV"] = true,
    ["VIP-P8UY7LOL8LKALZ68"] = true,
    ["VIP-FK4KHGS4M3TQMMT8"] = true,
    ["VIP-HWOQYUMJXLJ4QNF8"] = true,
    ["VIP-U9C2Z7PG0XMM49ZH"] = true,
    ["VIP-J75WYSE394JVN9E3"] = true,
    ["VIP-JXZ9RWKMFJW6JLS5"] = true,
    ["VIP-8FQI57R97OEO7IXW"] = true,
    ["VIP-YKRCKV85MPOUTM4D"] = true,
    ["VIP-6LAZ70XAJNXOZFBA"] = true,
    ["VIP-MZML14TRR9WBXD4D"] = true,
    ["VIP-PCUBG8Y5NR8JZY40"] = true,
    ["VIP-90BSADRI6JJRVZVM"] = true,
    ["VIP-Z5I9QM3ZMBES1DIJ"] = true,
    ["VIP-H987IN16Y3JFEKAB"] = true,
    ["VIP-JR609JEXHOMYAJUP"] = true,
    ["VIP-OTWLDDXJUXA56458"] = true,
    ["VIP-FI7E2390WPPAGMAI"] = true,
    ["VIP-5L322H8UBNHZDVQQ"] = true,
    ["VIP-PZZVHC3SW09R75JV"] = true,
    ["VIP-68LLC9KI3XRB4O61"] = true,
    ["VIP-MT5ICOX4Y2LB78VE"] = true,
    ["VIP-Y81MFH6E30M4X69N"] = true,
    ["VIP-BPXW3CPFNYQ1FF6H"] = true,
    ["VIP-P8VMLU2HYNF5BP82"] = true,
    ["VIP-8M3MMOSRTLZ13DWP"] = true,
    ["VIP-J9WCOEK9GZZG68XK"] = true,
    ["VIP-MQQFOZUM6MO6ZYOI"] = true,
    ["VIP-ZVLHQQ45I30OCXZL"] = true,
    ["VIP-7IZNZOEUW32QPQM8"] = true,
    ["VIP-61EYOHK5SE1X1EIR"] = true,
    ["VIP-7HRMUWMJG394Z2WY"] = true,
    ["VIP-NIZUS0ON3E8CALZ2"] = true,
    ["VIP-0F3WTGKTL671MT1L"] = true,
    ["VIP-NUSUAI6PNMV5TST0"] = true,
    ["VIP-SAHIA24YO1WJ6TWT"] = true,
    ["VIP-CE7DB0I2OLXUN6NQ"] = true,
    ["VIP-FVLALLKBYQI8MIAG"] = true,
    ["VIP-LIL7Q1468I4M6ZFN"] = true,
}
local DEV_KEYS = {
    ["DEV-G3I5MP9HYEN90NB8MCW5"] = true,
    ["DEV-6GGPSTY523MWREXW1ASS"] = true,
    ["DEV-43ZVGRF2CQHOS1XR521R"] = true,
    ["DEV-QVT58935F7QRTQBUZSFK"] = true,
    ["DEV-CFUCV6IQ88OYLGW5Z2O8"] = true,
}

local function saveCfg()
    inicfg.save(cfg, CONFIG_NAME)
end

local function nowMs()
    return os.clock() * 1000
end

local function resetMaskTimer()
    lastMaskAt = nowMs()
    nextMaskAt = lastMaskAt + MASK_INTERVAL
end

local function notify(text)
    if isSampAvailable() then
        sampAddChatMessage(u8:decode("[XPanel] " .. text), 0x66CCFF)
    end
end

local function useMask()
    if not isSampAvailable() then return end
    sampSendChat("/mask")
    resetMaskTimer()
    notify("Команда /mask отправлена. Следующее автонадевание через 10 минут.")
end

local function secondsLeft()
    if nextMaskAt <= 0 then return 0 end
    local left = math.floor((nextMaskAt - nowMs()) / 1000)
    if left < 0 then left = 0 end
    return left
end

local function formatTime(sec)
    local m = math.floor(sec / 60)
    local s = sec % 60
    return string.format("%02d:%02d", m, s)
end

local function toggleButton(label, value)
    local changed = false
    local draw = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    local h = 24
    local w = 48
    local radius = h / 2

    local bg
    if value then
        bg = imgui.GetColorU32Vec4(imgui.ImVec4(0.20, 0.75, 0.95, 1.00))
    else
        bg = imgui.GetColorU32Vec4(imgui.ImVec4(0.25, 0.27, 0.32, 1.00))
    end

    imgui.InvisibleButton("##" .. label, imgui.ImVec2(w, h))
    if imgui.IsItemClicked() then
        value = not value
        changed = true
    end

    draw:AddRectFilled(p, imgui.ImVec2(p.x + w, p.y + h), bg, radius)

    local knobX = value and (p.x + w - radius) or (p.x + radius)
    draw:AddCircleFilled(imgui.ImVec2(knobX, p.y + radius), radius - 3,
        imgui.GetColorU32Vec4(imgui.ImVec4(1, 1, 1, 1)))

    return changed, value
end

local newFrame = imgui.OnFrame(
    function() return window[0] end,
    function(player)
        imgui.SetNextWindowSize(imgui.ImVec2(620, 420), imgui.Cond.FirstUseEver)
        imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(18, 18))
        imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, 14)
        imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 9)

        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.055, 0.065, 0.095, 0.98))
        imgui.PushStyleColor(imgui.Col.TitleBg, imgui.ImVec4(0.08, 0.12, 0.20, 1.00))
        imgui.PushStyleColor(imgui.Col.TitleBgActive, imgui.ImVec4(0.10, 0.28, 0.45, 1.00))
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.10, 0.35, 0.55, 0.90))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.12, 0.50, 0.75, 1.00))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.08, 0.28, 0.48, 1.00))
        imgui.PushStyleColor(imgui.Col.Header, imgui.ImVec4(0.10, 0.35, 0.55, 0.80))
        imgui.PushStyleColor(imgui.Col.HeaderHovered, imgui.ImVec4(0.12, 0.50, 0.75, 0.90))

        imgui.Begin(u8"XPanel • Arizona RP", window,
            imgui.WindowFlags.NoCollapse)

        imgui.TextColored(imgui.ImVec4(0.25, 0.80, 1.00, 1.00), u8"XPanel")
        imgui.SameLine()
        imgui.TextDisabled(u8"• MoonLoader utility")
        imgui.Separator()

        if imgui.Button(u8"Главная", imgui.ImVec2(170, 38)) then activeTab = 1 end
        imgui.SameLine()
        if imgui.Button(u8"VIP", imgui.ImVec2(170, 38)) then
            if cfg.main.vipUnlocked then
                activeTab = 2
            else
                vipPopup[0] = true
                ffi.fill(keyBuffer, 128)
            end
        end
        imgui.SameLine()
        if imgui.Button(u8"Разработчик", imgui.ImVec2(170, 38)) then
            if cfg.main.devUnlocked then
                activeTab = 3
            else
                devPopup[0] = true
                ffi.fill(keyBuffer, 128)
            end
        end

        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

        if activeTab == 1 then
            imgui.TextColored(imgui.ImVec4(0.85, 0.92, 1.00, 1.00), u8"Автонадевание маски")
            imgui.Spacing()

            imgui.Text(u8"Автоматически отправлять /mask каждые 10 минут")
            imgui.SameLine(500)
            local changed, value = toggleButton("autoMask", cfg.main.autoMask)
            if changed then
                cfg.main.autoMask = value
                resetMaskTimer()
                saveCfg()
            end

            imgui.Spacing()
            if cfg.main.autoMask and cfg.main.localMasterEnabled then
                imgui.TextColored(imgui.ImVec4(0.30, 1.00, 0.55, 1.00),
                    u8("Статус: ВКЛЮЧЕНО"))
                imgui.Text(u8("До следующего /mask: " .. formatTime(secondsLeft())))
            else
                imgui.TextColored(imgui.ImVec4(1.00, 0.45, 0.45, 1.00),
                    u8("Статус: ВЫКЛЮЧЕНО"))
            end

            imgui.Spacing()
            if imgui.Button(u8"Надеть маску сейчас", imgui.ImVec2(230, 38)) then
                useMask()
            end

            imgui.Spacing()
            imgui.TextDisabled(u8"Команды открытия: /xpanel или .чзфтуд")

        elseif activeTab == 2 then
            imgui.TextColored(imgui.ImVec4(0.90, 0.75, 0.25, 1.00), u8"VIP-раздел")
            imgui.Spacing()
            imgui.TextWrapped(u8"VIP доступ активирован.")
            imgui.TextDisabled(u8"Раздел пока пуст — как и было запрошено.")

        elseif activeTab == 3 then
            imgui.TextColored(imgui.ImVec4(1.00, 0.45, 0.75, 1.00), u8"Режим разработчика")
            imgui.Spacing()

            imgui.TextWrapped(u8"Главный выключатель этой копии скрипта")
            imgui.SameLine(500)
            local changed, value = toggleButton("master", cfg.main.localMasterEnabled)
            if changed then
                cfg.main.localMasterEnabled = value
                resetMaskTimer()
                saveCfg()
                if value then
                    notify("Главный переключатель включён.")
                else
                    notify("Главный переключатель выключен.")
                end
            end

            imgui.Spacing()
            imgui.TextColored(imgui.ImVec4(1.00, 0.75, 0.25, 1.00),
                u8"Важно: локальный Lua не может отключать скрипт у других игроков.")
            imgui.TextWrapped(u8"Для настоящего общего выключателя нужен удалённый сервер/API, к которому подключены все копии XPanel.")
        end

        imgui.SetCursorPosY(imgui.GetWindowHeight() - 42)
        imgui.Separator()
        imgui.TextDisabled(u8"Автор: Diazz_Kaneki • Server 20")

        imgui.End()

        if vipPopup[0] then
            imgui.OpenPopup(u8"VIP доступ")
            vipPopup[0] = false
        end

        if imgui.BeginPopupModal(u8"VIP доступ", nil, imgui.WindowFlags.AlwaysAutoResize) then
            imgui.Text(u8"Введите VIP ключ-код:")
            imgui.PushItemWidth(360)
            imgui.InputText("##vipkey", keyBuffer, 128)
            imgui.PopItemWidth()

            if imgui.Button(u8"Активировать", imgui.ImVec2(170, 35)) then
                local entered = ffi.string(keyBuffer)
                if VIP_KEYS[entered] then
                    cfg.main.vipUnlocked = true
                    saveCfg()
                    activeTab = 2
                    notify("VIP доступ активирован.")
                    imgui.CloseCurrentPopup()
                else
                    notify("Неверный VIP ключ.")
                end
            end
            imgui.SameLine()
            if imgui.Button(u8"Отмена", imgui.ImVec2(170, 35)) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end

        if devPopup[0] then
            imgui.OpenPopup(u8"Доступ разработчика")
            devPopup[0] = false
        end

        if imgui.BeginPopupModal(u8"Доступ разработчика", nil, imgui.WindowFlags.AlwaysAutoResize) then
            imgui.Text(u8"Введите DEV ключ-код:")
            imgui.PushItemWidth(360)
            imgui.InputText("##devkey", keyBuffer, 128)
            imgui.PopItemWidth()

            if imgui.Button(u8"Войти", imgui.ImVec2(170, 35)) then
                local entered = ffi.string(keyBuffer)
                if DEV_KEYS[entered] then
                    cfg.main.devUnlocked = true
                    saveCfg()
                    activeTab = 3
                    notify("Режим разработчика разблокирован.")
                    imgui.CloseCurrentPopup()
                else
                    notify("Неверный DEV ключ.")
                end
            end
            imgui.SameLine()
            if imgui.Button(u8"Отмена", imgui.ImVec2(170, 35)) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end

        imgui.PopStyleColor(8)
        imgui.PopStyleVar(3)
    end
)

function sampev.onSendChat(message)
    local lowered = message:lower()
    if lowered == ".чзфтуд" or lowered == ".xpanel" then
        window[0] = not window[0]
        return false
    end
end

function main()
    repeat wait(100) until isSampAvailable()

    sampRegisterChatCommand("xpanel", function()
        window[0] = not window[0]
    end)

    resetMaskTimer()
    notify("Загружен. Открыть: /xpanel или .чзфтуд")

    while true do
        wait(100)

        if cfg.main.autoMask and cfg.main.localMasterEnabled then
            if nowMs() >= nextMaskAt then
                useMask()
            end
        end
    end
end
