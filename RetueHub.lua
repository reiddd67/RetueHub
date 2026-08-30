-- ==============================================================================
-- Zenithware Ultimate Enterprise v12.4 | Soccer: Touch Football Special Edition
-- Architecture: Direct Remote/Touch Interception & Force Vector Redirection
-- Target Executor: Real (Fully Optimized & Verified)
-- ==============================================================================

local VERSION = "v12.4 Secure Pro"
local AUTHOR = "reiddd"

-- Защита от мультизапуска
if getgenv().ZenithUltimateRunning then
    pcall(function() getgenv().ZenithUltimateRunning:Destroy() end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Создание стабильного графического ядра нативных элементов
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZenithUltimateTouchFootball"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    end
end)

getgenv().ZenithUltimateRunning = ScreenGui

-- Главное окно (Элитный стиль Dark Cyberpunk с плавной анимацией)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(540, 380)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 40, 80)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Шапка
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "ZENITHWARE // Touch Football Pro Engine"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Список настроек
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -24, 1, -60)
ContentScroll.Position = UDim2.new(0, 12, 0, 50)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 350)
ContentScroll.ScrollBarThickness = 3
ContentScroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)
UIList.Parent = ContentScroll

-- Конфиг состояния функций
local Config = {
    AimbotActive = true,
    CurveActive = true,
    CurvePower = 25,
    ESPActive = true
}

-- Функция создания красивого переключателя
local function addToggle(title, desc, defaultVal, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 52)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Frame.BorderSizePixel = 0
    Frame.Parent = ContentScroll

    local FC = Instance.new("UICorner")
    FC.CornerRadius = UDim.new(0, 8)
    FC.Parent = Frame

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -70, 0, 20)
    L.Position = UDim2.new(0, 14, 0, 8)
    L.BackgroundTransparency = 1
    L.Font = Enum.Font.GothamBold
    L.Text = title
    L.TextColor3 = Color3.fromRGB(235, 235, 245)
    L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = Frame

    local D = Instance.new("TextLabel")
    D.Size = UDim2.new(1, -70, 0, 16)
    D.Position = UDim2.new(0, 14, 0, 28)
    D.BackgroundTransparency = 1
    D.Font = Enum.Font.Gotham
    D.Text = desc
    D.TextColor3 = Color3.fromRGB(130, 130, 145)
    D.TextSize = 10
    D.TextXAlignment = Enum.TextXAlignment.Left
    D.Parent = Frame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.fromOffset(42, 22)
    Btn.Position = UDim2.new(1, -54, 0.5, -11)
    Btn.BackgroundColor3 = defaultVal and Color3.fromRGB(255, 40, 80) or Color3.fromRGB(45, 45, 55)
    Btn.AutoButtonColor = false
    Btn.Text = ""
    Btn.Parent = Frame

    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(1, 0)
    BC.Parent = Btn

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(16, 16)
    Knob.Position = defaultVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Btn

    local KC = Instance.new("UICorner")
    KC.CornerRadius = UDim.new(1, 0)
    KC.Parent = Knob

    local state = defaultVal
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(255, 40, 80) or Color3.fromRGB(45, 45, 55)
        TweenService:Create(Knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        callback(state)
    end)
end

addToggle("Goal Aimbot (Auto Redirect)", "Мгновенное точное направление мяча в ворота при касании", Config.AimbotActive, function(v)
    Config.AimbotActive = v
end)

addToggle("Aimbot Ball Curve", "Добавление мощного углового вращения (эффект сухих листьев)", Config.CurveActive, function(v)
    Config.CurveActive = v
end)

addToggle("Ball Neon ESP", "Подсветка мяча сквозь любые текстуры карты", Config.ESPActive, function(v)
    Config.ESPActive = v
end)

-- Управление видимостью на Left Control
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ==============================================================================
-- РАБОЧЕЕ ФИЗИЧЕСКОЕ ЯДРО (TOUCH FOOTBALL EXPLOIT LOGIC)
-- ==============================================================================

local function getTargetGoal()
    local bestTarget = Camera.CFrame.Position + (Camera.CFrame.LookVector * 400)
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n:find("goal") or n:find("net") or n:find("post") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        if (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude > 30 then
                            bestTarget = obj.Position
                            break
                        end
                    end
                end
            end
        end
    end)
    return bestTarget
end

local trackedBalls = {}

local function hookBall(ball)
    if not ball or trackedBalls[ball] then return end
    trackedBalls[ball] = true

    -- Добавляем ESP подсветку
    pcall(function()
        local hl = Instance.new("Highlight")
        hl.Adornee = ball
        hl.FillColor = Color3.fromRGB(255, 40, 80)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.3
        hl.Parent = ball
    end)

    -- Перехват касания для изменения траектории полета
    ball.Touched:Connect(function(hit)
        local char = LocalPlayer.Character
        if not char or not hit:IsDescendantOf(char) then return end

        pcall(function()
            task.defer(function()
                if Config.AimbotActive then
                    local goalPos = getTargetGoal()
                    local currentVel = ball.AssemblyLinearVelocity
                    local speed = math.clamp(currentVel.Magnitude, 60, 160)
                    
                    -- Принудительное изменение вектора скорости прямо в ворота
                    local directVector = (goalPos - ball.Position).Unit
                    ball.AssemblyLinearVelocity = directVector * speed
                    ball.CFrame = CFrame.new(ball.Position, goalPos)
                end

                if Config.CurveActive then
                    -- Применяем угловую скорость для закрутки
                    local curveFactor = Config.CurvePower * 20
                    ball.AssemblyAngularVelocity = Vector3.new(curveFactor * 0.3, curveFactor * 1.5, curveFactor * 0.1)
                end
            end)
        end)
    end)
end

-- Непрерывный поиск мяча в матче
task.spawn(function()
    while true do
        pcall(function()
            for _, v in ipairs(Workspace:GetChildren()) do
                if v:IsA("BasePart") then
                    local name = v.Name:lower()
                    if name:find("ball") or name:find("football") or name:find("soccer") then
                        hookBall(v)
                    end
                end
            end
            -- Проверка в контейнерах
            for _, parentObj in ipairs(Workspace:GetChildren()) do
                if parentObj:IsA("Folder") or parentObj:IsA("Model") then
                    for _, sub in ipairs(parentObj:GetChildren()) do
                        if sub:IsA("BasePart") then
                            local name = sub.Name:lower()
                            if name:find("ball") or name:find("football") or name:find("soccer") then
                                hookBall(sub)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.25)
    end
end)

print("[Zenithware]: Loaded successfully! Press [Left Control] to toggle menu.")
