-- ==============================================================================
-- Zenithware Ultimate | Touch Football Clean Edition (Fluent UI)
-- ==============================================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Zenithware Pro",
    SubTitle = "Touch Football Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 360),
    Acrylic = true, -- Премиальное размытие фона
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Кнопка скрытия/показа меню
})

-- Создаем единственную чистую вкладку
local Tabs = {
    Main = Window:AddTab({ Title = "Core Hub", Icon = "target" })
}

local Options = Fluent.Options

-- Конфиг функций
local Settings = {
    AimbotEnabled = false,
    CurveEnabled = false,
    CurvePower = 15.0
}

-- ==============================================================================
-- ФУНКЦИЯ 1: AIMBOT (Наведение вектора мяча в ворота)
-- ==============================================================================
Tabs.Main:AddToggle("AimbotToggle", {
    Title = "Aimbot (Auto Goal Redirect)",
    Default = false,
    Description = "Мгновенно доводит мяч до ворот соперника при касании",
    Callback = function(Value)
        Settings.AimbotEnabled = Value
        Fluent:Notify({
            Title = "Zenithware",
            Content = Value and "Aimbot Activated!" or "Aimbot Deactivated.",
            Duration = 2
        })
    end
})

-- ==============================================================================
-- ФУНКЦИЯ 2: AIMBOT BALL CURVE (Закрутка мяча)
-- ==============================================================================
Tabs.Main:AddToggle("CurveToggle", {
    Title = "Aimbot Ball Curve",
    Default = false,
    Description = "Добавляет мощное вращение (эффект сухих листьев / траектория)",
    Callback = function(Value)
        Settings.CurveEnabled = Value
    end
})

Tabs.Main:AddSlider("CurvePowerSlider", {
    Title = "Curve Intensity",
    Description = "Сила закрутки мяча",
    Default = 15,
    Min = 5,
    Max = 30,
    Rounding = 1,
    Callback = function(Value)
        Settings.CurvePower = Value
    end
})

-- Логика перехвата мяча и физики
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local function getGoalPosition()
    local targetPos = Camera.CFrame.Position + (Camera.CFrame.LookVector * 300)
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = obj.Name:lower()
                if name:find("goal") or name:find("net") or name:find("target") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                        if dist > 35 then 
                            targetPos = obj.Position
                            break
                        end
                    end
                end
            end
        end
    end)
    return targetPos
end

local function hookBall(ball)
    if not ball or ball:GetAttribute("ZenithLocked") then return end
    ball:SetAttribute("ZenithLocked", true)

    ball.Touched:Connect(function(hit)
        local char = LocalPlayer.Character
        if not char or not hit:IsDescendantOf(char) then return end

        pcall(function()
            if Settings.AimbotEnabled then
                local goalPos = getGoalPosition()
                local speed = math.clamp(ball.AssemblyLinearVelocity.Magnitude, 50, 120)
                local dir = (goalPos - ball.Position).Unit
                
                -- Корректируем скорость и вектор полета
                ball.AssemblyLinearVelocity = dir * speed
                ball.CFrame = CFrame.new(ball.Position, goalPos)
            end

            if Settings.CurveEnabled then
                -- Добавляем угловую скорость для закрутки
                ball.AssemblyAngularVelocity = Vector3.new(0, Settings.CurvePower * 5, 0)
            end
        end)
    end)
end

-- Быстрый сканер мяча без лагов
task.spawn(function()
    while true do
        pcall(function()
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("football")) then
                    hookBall(obj)
                end
            end
        end)
        task.wait(0.5)
    end
end)

Fluent:Notify({
    Title = "Zenithware Loaded!",
    Content = "Fluent UI initialized successfully. Press LeftCtrl to toggle menu.",
    Duration = 4
})
