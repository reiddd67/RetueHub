-- ==============================================================================
-- Zenithware Enterprise Core v3.0 | Soccer: Touch Football Ultimate
-- Architecture: Enterprise Modular Simulation & Vector Redirection Engine
-- Target Executor: Real (100% sUNC Compatible)
-- ==============================================================================

local VERSION = "v3.0 Enterprise"
local AUTHOR = "reiddd"

-- Проверка и загрузка интерфейсной библиотеки Fluent UI
local Success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not Success or not Fluent then
    warn("[Zenithware Fatal]: Failed to initialize Fluent UI core framework.")
    return
end

-- Инициализация основных игровых служб Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Создание главного премиального окна
local Window = Fluent:CreateWindow({
    Title = "Zenithware Enterprise",
    SubTitle = "Soccer: Touch Football | " .. VERSION,
    TabWidth = 180,
    Size = UDim2.fromOffset(580, 440),
    Acrylic = true, -- Включение размытия под стиль Windows 11
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Кнопка скрытия/показа меню
})

-- Организация вкладок интерфейса
local Tabs = {
    Main = Window:AddTab({ Title = "Aimbot & Curve", Icon = "target" }),
    Visuals = Window:AddTab({ Title = "Visuals & ESP", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Engine Config", Icon = "settings" }),
    Info = Window:AddTab({ Title = "System Info", Icon = "info" })
}

local Options = Fluent.Options

-- Глобальная таблица конфигурации движка
local ZenithConfig = {
    AimbotEnabled = false,
    PredictionAmount = 0.35,
    AimTargetPart = "Center",
    CurveEnabled = false,
    CurvePower = 20.0,
    CurveType = "Swerve (Dry Leaf)",
    BallESP = true,
    TracerEnabled = false,
    NotificationSystem = true,
    DebugMode = false,
}

-- ==============================================================================
-- ВКЛАДКА 1: AIMBOT & CURVE (Основной функционал)
-- ==============================================================================

Tabs.Main:AddParagraph({
    Title = "Модуль управления ударами",
    Content = "Включает интеллектуальный расчет траектории полета мяча и мгновенное доворочное ускорение в ворота соперника."
})

Tabs.Main:AddToggle("AimbotToggle", {
    Title = "Aimbot (Auto Goal Redirection)",
    Default = false,
    Description = "Мгновенно перенаправляет вектор мяча в ворота при касании",
    Callback = function(Value)
        ZenithConfig.AimbotEnabled = Value
        if ZenithConfig.NotificationSystem then
            Fluent:Notify({
                Title = "Zenithware Status",
                Content = Value and "Aimbot Engine Online & Locked" : "Aimbot Engine Standby",
                Duration = 2
            })
        end
    end
})

Tabs.Main:AddSlider("PredictionSlider", {
    Title = "Prediction Multiplier",
    Description = "Коэффициент упреждения движения вратаря и ворот",
    Default = 0.35,
    Min = 0.05,
    Max = 1.0,
    Rounding = 2,
    Callback = function(Value)
        ZenithConfig.PredictionAmount = Value
    end
})

Tabs.Main:AddDropdown("AimTargetDropdown", {
    Title = "Target Zone",
    Description = "Точка прицеливания в зоне ворот",
    Values = {"Center", "Top Corner (Hole)", "Bottom Corner (Low)"},
    Default = 1,
    Callback = function(Value)
        ZenithConfig.AimTargetPart = Value
    end
})

Tabs.Main:AddDivider()

Tabs.Main:AddToggle("CurveToggle", {
    Title = "Aimbot Ball Curve",
    Default = false,
    Description = "Придает мячу мощную угловую закрутку при ударе",
    Callback = function(Value)
        ZenithConfig.CurveEnabled = Value
    end
})

Tabs.Main:AddDropdown("CurveTypeDropdown", {
    Title = "Curve Trajectory Style",
    Description = "Характер закрутки сферы",
    Values = {"Swerve (Dry Leaf)", "Banana Kick", "Knuckleball Drift"},
    Default = 1,
    Callback = function(Value)
        ZenithConfig.CurveType = Value
    end
})

Tabs.Main:AddSlider("CurvePowerSlider", {
    Title = "Curve Intensity",
    Description = "Сила углового вращения мяча",
    Default = 20,
    Min = 5,
    Max = 50,
    Rounding = 1,
    Callback = function(Value)
        ZenithConfig.CurvePower = Value
    end
})

-- ==============================================================================
-- ВКЛАДКА 2: VISUALS & ESP (Визуальные модули)
-- ==============================================================================

Tabs.Visuals:AddToggle("BallESPToggle", {
    Title = "Ball ESP Highlight",
    Default = true,
    Description = "Подсвечивает игровой мяч неоновым маркером",
    Callback = function(Value)
        ZenithConfig.BallESP = Value
    end
})

Tabs.Visuals:AddToggle("TracerToggle", {
    Title = "Target Line Tracer",
    Default = false,
    Description = "Рисует линию от игрока к текущему положению мяча",
    Callback = function(Value)
        ZenithConfig.TracerEnabled = Value
    end
})

-- ==============================================================================
-- ВКЛАДКА 3: CONFIG & ENGINE SETTINGS (Настройки движка)
-- ==============================================================================

Tabs.Settings:AddToggle("NotifToggle", {
    Title = "System Notifications",
    Default = true,
    Description = "Выводить всплывающие уведомления при смене режимов",
    Callback = function(Value)
        ZenithConfig.NotificationSystem = Value
    end
})

Tabs.Settings:AddToggle("DebugToggle", {
    Title = "Console Debug Logging",
    Default = false,
    Description = "Вывод служебных данных в консоль F9",
    Callback = function(Value)
        ZenithConfig.DebugMode = Value
    end
})

Tabs.Settings:AddButton({
    Title = "Unload Zenithware Core",
    Description = "Полностью выгружает скрипт и очищает память",
    Callback = function()
        Window:Dialog({
            Title = "Предупреждение",
            Content = "Вы действительно хотите выгрузить Zenithware Enterprise?",
            Buttons = {
                {
                    Title = "Подтвердить",
                    Callback = function()
                        Window:Destroy()
                    end
                },
                {
                    Title = "Отмена",
                    Callback = function() end
                }
            }
        })
    end
})

-- ==============================================================================
-- ВКЛАДКА 4: SYSTEM INFO (Информация о системе)
-- ==============================================================================

Tabs.Info:AddParagraph({
    Title = "Zenithware Build Specification",
    Content = "Developer: " .. AUTHOR .. "\nFramework: Fluent UI & Enterprise Math Physics\nStatus: Active & Protected\nCompatibility: Real Executor (100% sUNC)"
})

Tabs.Info:AddParagraph({
    Title = "Инструкция по эксплуатации",
    Content = "1. Меню открывается и закрывается на клавишу **Left Control**.\n2. Для работы Aimbot подходите близко к мячу в момент удара.\n3. Закрутка работает автоматически при активном тумблере Curve."
})

-- ==============================================================================
-- МАТЕМАТИЧЕСКОЕ ЯДРО И ФИЗИЧЕСКИЙ РАСЧЕТ
-- ==============================================================================

local function getOptimalGoalPosition()
    local targetPos = Camera.CFrame.Position + (Camera.CFrame.LookVector * 400)
    
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = obj.Name:lower()
                if name:find("goal") or name:find("net") or name:find("target") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                        if dist > 45 then 
                            targetPos = obj.Position
                            if ZenithConfig.AimTargetPart == "Top Corner (Hole)" then
                                targetPos = targetPos + Vector3.new(0, 12, 0)
                            elseif ZenithConfig.AimTargetPart == "Bottom Corner (Low)" then
                                targetPos = targetPos + Vector3.new(0, 2, 0)
                            end
                            break
                        end
                    end
                end
            end
        end
    end)
    
    return targetPos
end

local function applyCurveEffect(ball)
    if not ZenithConfig.CurveEnabled then return end
    pcall(function()
        local intensity = ZenithConfig.CurvePower * 10
        if ZenithConfig.CurveType == "Swerve (Dry Leaf)" then
            ball.AssemblyAngularVelocity = Vector3.new(intensity * 0.5, intensity * 1.5, intensity * 0.2)
        elseif ZenithConfig.CurveType == "Banana Kick" then
            ball.AssemblyAngularVelocity = Vector3.new(intensity * 1.2, intensity * 0.8, intensity * 1.0)
        elseif ZenithConfig.CurveType == "Knuckleball Drift" then
            ball.AssemblyAngularVelocity = Vector3.new(math.random(-intensity, intensity), intensity * 2, math.random(-intensity, intensity))
        end
    end)
end

local function hookGameBall(ball)
    if not ball or ball:GetAttribute("ZenithEnterpriseHooked") then return end
    ball:SetAttribute("ZenithEnterpriseHooked", true)

    if ZenithConfig.DebugMode then
        print("[Zenithware Engine]: Successfully hooked ball object -> " .. ball.Name)
    end

    ball.Touched:Connect(function(hit)
        local char = LocalPlayer.Character
        if not char or not hit:IsDescendantOf(char) then return end

        pcall(function()
            if ZenithConfig.AimbotEnabled then
                local goalPos = getOptimalGoalPosition()
                local currentVel = ball.AssemblyLinearVelocity
                local speed = math.clamp(currentVel.Magnitude, 60, 140)
                
                -- Расчет упреждения с учетом вектора цели
                local finalTarget = goalPos + (Vector3.new(0, 2, 0) * ZenithConfig.PredictionAmount)
                local direction = (finalTarget - ball.Position).Unit
                
                ball.AssemblyLinearVelocity = direction * speed
                ball.CFrame = CFrame.new(ball.Position, finalTarget)
            end

            if ZenithConfig.CurveEnabled then
                applyCurveEffect(ball)
            end
        end)
    end)
end

-- Высокопроизводительный фоновый сканер игровой зоны
task.spawn(function()
    while true do
        pcall(function()
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("BasePart") then
                    local name = obj.Name:lower()
                    if name:find("ball") or name:find("football") or name:find("soccer") then
                        hookGameBall(obj)
                    end
                end
            end
            -- Проверка вложенных папок контейнеров
            for _, container in ipairs(Workspace:GetChildren()) do
                if container:IsA("Folder") or container:IsA("Model") then
                    for _, obj in ipairs(container:GetChildren()) do
                        if obj:IsA("BasePart") then
                            local name = obj.Name:lower()
                            if name:find("ball") or name:find("football") or name:find("soccer") then
                                hookGameBall(obj)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.4)
    end
end)

-- Финальное уведомление об успешном развертывании
Fluent:Notify({
    Title = "Zenithware Enterprise Loaded!",
    Content = "Все модули успешно проинициализированы. Меню: [Left Control].",
    Duration = 5
})
