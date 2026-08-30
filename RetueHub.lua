-- ==============================================================================
-- Zenithware Ultimate Enterprise v15.0 | Soccer: Touch Football (Network Hook)
-- Architecture: RemoteEvent Interception & Server-Side Vector Override
-- Target Executor: Real (100% Guaranteed Native Execution)
-- ==============================================================================

local VERSION = "v15.0 Network Hook"
local AUTHOR = "reiddd"

-- Защита от мультизапуска
if getgenv().ZenithNetworkRunning then
    pcall(function() getgenv().ZenithNetworkRunning:Destroy() end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Создание графического ядра
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZenithNetworkTouchFootball"
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

getgenv().ZenithNetworkRunning = ScreenGui

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(500, 360)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -180)
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
TitleLabel.Text = "ZENITHWARE // Touch Football Network Core"
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
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 300)
ContentScroll.ScrollBarThickness = 3
ContentScroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)
UIList.Parent = ContentScroll

-- Конфиг
local Config = {
    AimbotActive = true,
    CurveActive = true,
    CurvePower = 30,
    ESPActive = true
}

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

addToggle("Network Goal Aimbot", "Перехват сетевого удара и направление мяча в ворота", Config.AimbotActive, function(v)
    Config.AimbotActive = v
end)

addToggle("Aimbot Ball Curve", "Добавление углового вращения (эффект сухих листьев)", Config.CurveActive, function(v)
    Config.CurveActive = v
end)

addToggle("Ball Neon ESP", "Подсветка мяча сквозь любые объекты", Config.ESPActive, function(v)
    Config.ESPActive = v
end)

-- Управление на Left Control
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ==============================================================================
-- СЕТЕВОЕ ЯДРО ПЕРЕХВАТА УДАРОВ (TOUCH FOOTBALL EXPLOIT)
-- ==============================================================================

local function getTargetGoal()
    local bestTarget = Camera.CFrame.Position + (Camera.CFrame.LookVector * 500)
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n:find("goal") or n:find("net") or n:find("post") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        if (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude > 25 then
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

-- Перехват сетевых вызовов (FireServer), через которые игра отправляет удар на сервер
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and self:IsA("RemoteEvent") then
        -- Проверяем, если аргументы содержат вектор или объект мяча (удар)
        if Config.AimbotActive then
            pcall(function()
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" then
                        local goalPos = getTargetGoal()
                        -- Подменяем направление удара на ворота
                        args[i] = (goalPos - Camera.CFrame.Position).Unit * v.Magnitude
                    end
                end
            end)
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

-- Дополнительная физическая коррекция мяча в реальном времени
local trackedBalls = {}
task.spawn(function()
    while true do
        pcall(function()
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("BasePart") then
                    local name = obj.Name:lower()
                    if name:find("ball") or name:find("football") or name:find("soccer") then
                        if not trackedBalls[obj] and Config.ESPActive then
                            trackedBalls[obj] = true
                            local hl = Instance.new("Highlight")
                            hl.Adornee = obj
                            hl.FillColor = Color3.fromRGB(255, 40, 80)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.3
                            hl.Parent = obj
                        end

                        -- Если мяч рядом с игроком и включен аим/закрутка
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                            if dist < 8 then
                                if Config.AimbotActive then
                                    local goalPos = getTargetGoal()
                                    local speed = math.clamp(obj.AssemblyLinearVelocity.Magnitude, 70, 180)
                                    obj.AssemblyLinearVelocity = (goalPos - obj.Position).Unit * speed
                                end
                                if Config.CurveActive then
                                    local p = Config.CurvePower * 25
                                    obj.AssemblyAngularVelocity = Vector3.new(p * 0.4, p * 1.8, p * 0.2)
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)

print("[Zenithware]: Network Hook Loaded! Press [Left Control] to toggle menu.")
