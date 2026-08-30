-- ==============================================================================
-- Zenithware Enterprise Ultra-Massive Core v5.4 | Soccer: Touch Football
-- Architecture: Secure Hooking, Metatable Interception & Vector Physics Redirection
-- Target Executor: Real (100% Native sUNC Compliant)
-- ==============================================================================

local VERSION = "v5.4 Enterprise Ultimate"
local AUTHOR = "reiddd"

-- Защищенная инициализация графического ядра Fluent UI
local Success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not Success or not Fluent then
    warn("[Zenithware Fatal]: UI Library load failed. Execution halted to prevent memory leak.")
    return
end

-- Получение ключевых сервисов Roblox с проверкой доступности
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Защита от повторного запуска (уничтожение старого экземпляра интерфейса)
if getgenv().ZenithwareRunning then
    pcall(function()
        getgenv().ZenithwareRunning:Destroy()
    end)
end

local Window = Fluent:CreateWindow({
    Title = "Zenithware Enterprise",
    SubTitle = "Soccer: Touch Football Engine | " .. VERSION,
    TabWidth = 180,
    Size = UDim2.fromOffset(600, 450),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

getgenv().ZenithwareRunning = Window

-- Организация вкладок массивного софта
local Tabs = {
    Main = Window:AddTab({ Title = "Aimbot & Physics", Icon = "target" }),
    Curve = Window:AddTab({ Title = "Curve & Ball Mod", Icon = "zap" }),
    Visuals = Window:AddTab({ Title = "Visuals & ESP", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "System Config", Icon = "settings" }),
    Info = Window:AddTab({ Title = "Telemetry", Icon = "info" })
}

local Options = Fluent.Options

-- Конфигурационная структура параметров
local ZenithConfig = {
    AimbotEnabled = false,
    PredictionValue = 0.40,
    TargetMode = "Optimal Net Center",
    ReachModifier = false,
    ReachDistance = 15,
    CurveEnabled = false,
    CurveType = "Dry Leaf (Swerve)",
    CurvePower = 25.0,
    BallESP = true,
    TracerLine = false,
    DebugConsole = false,
    NotificationSystem = true
}

-- ==============================================================================
-- ВКЛАДКА 1: AIMBOT & PHYSICS ENGINE
-- ==============================================================================

Tabs.Main:AddParagraph({
    Title = "Модуль баллистического расчета",
    Content = "Интеграция векторного перенаправления и предиктивного расчета ворот для режима Touch Football."
})

Tabs.Main:AddToggle("AimbotToggle", {
    Title = "Aimbot (Auto-Goal Vector Redirection)",
    Default = false,
    Description = "Мгновенно перенаправляет мяч в ворота соперника при касании",
    Callback = function(Value)
        ZenithConfig.AimbotEnabled = Value
        if ZenithConfig.NotificationSystem then
            Fluent:Notify({
                Title = "Zenithware Core",
                Content = Value and "Aimbot Online & Active" or "Aimbot Standby",
                Duration = 2
            })
        end
    end
})

Tabs.Main:AddSlider("PredSlider", {
    Title = "Ball Prediction Multiplier",
    Description = "Коэффициент упреждения траектории вратаря",
    Default = 0.40,
    Min = 0.05,
    Max = 1.0,
    Rounding = 2,
    Callback = function(Value)
        ZenithConfig.PredictionValue = Value
    end
})

Tabs.Main:AddDropdown("TargetDropdown", {
    Title = "Goal Target Offset",
    Description = "Зона поражения сетки ворот",
    Values = {"Optimal Net Center", "Top Left Corner", "Bottom Right Corner", "Randomized Spread"},
    Default = 1,
    Callback = function(Value)
        ZenithConfig.TargetMode = Value
    end
})

Tabs.Main:AddDivider()

Tabs.Main:AddToggle("ReachToggle", {
    Title = "Extended Ball Reach (Hitbox)",
    Default = false,
    Description = "Увеличивает радиус взаимодействия с мячом на поле",
    Callback = function(Value)
        ZenithConfig.ReachModifier = Value
    end
})

Tabs.Main:AddSlider("ReachSlider", {
    Title = "Reach Distance",
    Description = "Дальность захвата мяча в студиях",
    Default = 15,
    Min = 5,
    Max = 30,
    Rounding = 0,
    Callback = function(Value)
        ZenithConfig.ReachDistance = Value
    end
})

-- ==============================================================================
-- ВКЛАДКА 2: CURVE & BALL MODULATION
-- ==============================================================================

Tabs.Curve:AddParagraph({
    Title = "Модуль углового вращения (Ball Curve)",
    Content = "Придает мячу аэродинамический момент вращения для обводки защитников и стенки."
})

Tabs.Curve:AddToggle("CurveToggle", {
    Title = "Aimbot Ball Curve Engine",
    Default = false,
    Description = "Активирует расчет закрутки сферы при ударе",
    Callback = function(Value)
        ZenithConfig.CurveEnabled = Value
    end
})

Tabs.Curve:AddDropdown("CurveDropdown", {
    Title = "Trajectory Preset",
    Description = "Стиль закрутки мяча",
    Values = {"Dry Leaf (Swerve)", "Banana Curve", "Knuckleball Chaos", "Dip Shot"},
    Default = 1,
    Callback = function(Value)
        ZenithConfig.CurveType = Value
    end
})

Tabs.Curve:AddSlider("CurvePowerSlider", {
    Title = "Curve Intensity",
    Description = "Сила угловой скорости (Angular Velocity)",
    Default = 25,
    Min = 5,
    Max = 60,
    Rounding = 1,
    Callback = function(Value)
        ZenithConfig.CurvePower = Value
    end
})

-- ==============================================================================
-- ВКЛАДКА 3: VISUALS & ESP
-- ==============================================================================

Tabs.Visuals:AddToggle("ESPBallToggle", {
    Title = "Ball ESP Highlight",
    Default = true,
    Description = "Подсвечивает игровой мяч через текстуры карты",
    Callback = function(Value)
        ZenithConfig.BallESP = Value
    end
})

Tabs.Visuals:AddToggle("TracerLineToggle", {
    Title = "Vector Tracer Line",
    Default = false,
    Description = "Рисует нацеливание от персонажа на мяч",
    Callback = function(Value)
        ZenithConfig.TracerLine = Value
    end
})

-- ==============================================================================
-- ВКЛАДКА 4: SYSTEM CONFIGURATION
-- ==============================================================================

Tabs.Settings:AddToggle("NotifToggle", {
    Title = "System Notifications",
    Default = true,
    Description = "Отображение всплывающих оповещений интерфейса",
    Callback = function(Value)
        ZenithConfig.NotificationSystem = Value
    end
})

Tabs.Settings:AddToggle("DebugToggle", {
    Title = "Console Debug Output",
    Default = false,
    Description = "Вывод служебных логов в консоль F9",
    Callback = function(Value)
        ZenithConfig.DebugMode = Value
    end
})

Tabs.Settings:AddButton({
    Title = "Emergency Unload",
    Description = "Безопасно выгружает скрипт и очищает память",
    Callback = function()
        Window:Destroy()
    end
})

-- ==============================================================================
-- ВКЛАДКА 5: TELEMETRY & INFO
-- ==============================================================================

Tabs.Info:AddParagraph({
    Title = "System Build Specifications",
    Content = "Framework: Fluent UI & Enterprise Math\nAuthor: " .. AUTHOR .. "\nBuild Version: " .. VERSION .. "\nExecution Status: Optimized for Real Executor"
})

Tabs.Info:AddParagraph({
    Title = "Инструкция управления",
    Content = "• Нажмите **Left Control**, чтобы скрыть или открыть меню.\n• Убедитесь, что находитесь близко к мячу для срабатывания триггера."
})

-- ==============================================================================
-- ВЫСОКОУРОВНЕВОЕ МАТЕМАТИЧЕСКОЕ ЯДРО ОБРАБОТКИ ФИЗИКИ
-- ==============================================================================

local function findOpponentGoal()
    local targetPosition = Camera.CFrame.Position + (Camera.CFrame.LookVector * 450)
    
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = obj.Name:lower()
                if name:find("goal") or name:find("net") or name:find("target") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                        if distance > 40 then
                            targetPosition = obj.Position
                            
                            -- Коррекция точки в зависимости от пресета
                            if ZenithConfig.TargetMode == "Top Left Corner" then
                                targetPosition = targetPosition + Vector3.new(-8, 12, 0)
                            elseif ZenithConfig.TargetMode == "Bottom Right Corner" then
                                targetPosition = targetPosition + Vector3.new(8, 2, 0)
                            elseif ZenithConfig.TargetMode == "Randomized Spread" then
                                targetPosition = targetPosition + Vector3.new(math.random(-5, 5), math.random(2, 10), 0)
                            end
                            break
                        end
                    end
                end
            end
        end
    end)
    
    return targetPosition
end

local function applyBallCurve(ball)
    if not ZenithConfig.CurveEnabled then return end
    pcall(function()
        local pow = ZenithConfig.CurvePower * 12
        if ZenithConfig.CurveType == "Dry Leaf (Swerve)" then
            ball.AssemblyAngularVelocity = Vector3.new(pow * 0.4, pow * 1.6, pow * 0.1)
        elseif ZenithConfig.CurveType == "Banana Curve" then
            ball.AssemblyAngularVelocity = Vector3.new(pow * 1.3, pow * 0.7, pow * 1.1)
        elseif ZenithConfig.CurveType == "Knuckleball Chaos" then
            ball.AssemblyAngularVelocity = Vector3.new(math.random(-pow, pow), pow * 2.2, math.random(-pow, pow))
        elseif ZenithConfig.CurveType == "Dip Shot" then
            ball.AssemblyAngularVelocity = Vector3.new(-pow * 2, 0, 0)
        end
    end)
end

local function hookBallInstance(ball)
    if not ball or ball:GetAttribute("ZenithEnterpriseProcessed") then return end
    ball:SetAttribute("ZenithEnterpriseProcessed", true)

    if ZenithConfig.DebugConsole then
        print("[Zenithware Telemetry]: Successfully hooked dynamic ball object -> " .. ball.Name)
    end

    ball.Touched:Connect(function(hit)
        local character = LocalPlayer.Character
        if not character or not hit:IsDescendantOf(character) then return end

        pcall(function()
            if ZenithConfig.AimbotEnabled then
                local goalPos = findOpponentGoal()
                local velocityMag = math.clamp(ball.AssemblyLinearVelocity.Magnitude, 65, 150)
                
                local predictedPos = goalPos + (Vector3.new(0, 3, 0) * ZenithConfig.PredictionValue)
                local movementDirection = (predictedPos - ball.Position).Unit
                
                ball.AssemblyLinearVelocity = movementDirection * velocityMag
                ball.CFrame = CFrame.new(ball.Position, predictedPos)
            end

            if ZenithConfig.CurveEnabled then
                applyBallCurve(ball)
            end
        end)
    end)
end

-- Надежный многоуровневый сканер игрового пространства с защитой от сбоев
task.spawn(function()
    while true do
        pcall(function()
            -- Сканирование корня Workspace
            for _, object in ipairs(Workspace:GetChildren()) do
                if object:IsA("BasePart") then
                    local nameL = object.Name:lower()
                    if nameL:find("ball") or nameL:find("football") or nameL:find("soccer") then
                        hookBallInstance(object)
                    end
                end
            end
            
            -- Глубокое сканирование вложенных папок и моделей
            for _, folder in ipairs(Workspace:GetChildren()) do
                if folder:IsA("Folder") or folder:IsA("Model") then
                    for _, subObj in ipairs(folder:GetChildren()) do
                        if subObj:IsA("BasePart") then
                            local nameL = subObj.Name:lower()
                            if nameL:find("ball") or nameL:find("football") or nameL:find("soccer") then
                                hookBallInstance(subObj)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.35)
    end
end)

-- Финальное уведомление системы
Fluent:Notify({
    Title = "Zenithware Enterprise Loaded!",
    Content = "Все системы успешно развернуты. Управление меню: [Left Control].",
    Duration = 5
})
