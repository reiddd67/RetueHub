-- ==============================================================================
-- Zenithware v2.5 Massive Core | Touch Football Ultimate Engine (WindUI Edition)
-- ==============================================================================

local VERSION = "v2.5 Pro"
local AUTHOR = "reiddd"

-- Подгружаем ультрасовременную библиотеку WindUI
local Success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not Success or not WindUI then
    warn("[Zenithware Fatal]: Failed to load WindUI library.")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Создаем главное футуристичное окно через WindUI
local Window = WindUI:CreateWindow({
    Title = "Zenithware " .. VERSION .. " | Football God",
    Icon = "zap", -- Иконка из библиотеки Lucide
    Author = "By " .. AUTHOR,
    Folder = "ZenithwareConfig",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark", -- Премиальная темная тема
    Resizable = false,
})

-- Создаем вкладки
local TabMain = Window:Tab({ Title = "Auto-Goal Hub", Icon = "target" })
local TabVisuals = Window:Tab({ Title = "Visuals & ESP", Icon = "eye" })
local TabSettings = Window:Tab({ Title = "Engine Config", Icon = "settings" })

-- Конфигурация движка
local ZenithConfig = {
    Enabled = false,
    VisualESP = true,
    NotificationEnabled = true,
    SpeedMultiplier = 1.0,
}

-- Элементы управления на главной вкладке
TabMain:Toggle({
    Title = "Auto-Goal Redirection",
    Desc = "Мгновенно перенаправляет мяч в ворота соперника при касании",
    Value = false,
    Callback = function(Value)
        ZenithConfig.Enabled = Value
        if ZenithConfig.NotificationEnabled then
            WindUI:Notify({
                Title = "Zenithware Status",
                Content = Value and "Auto-Goal Activated & Locked!" or "Auto-Goal Deactivated.",
                Duration = 2,
                Icon = Value and "check-circle" or "x-circle",
            })
        end
    end,
})

TabMain:Paragraph({
    Title = "Информация о режиме",
    Desc = "Скрипт сохраняет родную скорость удара мяча, но меняет вектор полета точно в ворота под любым углом.",
})

-- Элементы вкладки Визуалов
TabVisuals:Toggle({
    Title = "Ball ESP & Highlight",
    Desc = "Подсветка игрового мяча на поле",
    Value = true,
    Callback = function(Value)
        ZenithConfig.VisualESP = Value
    end,
})

-- Элементы вкладки Настроек
TabSettings:Slider({
    Title = "Velocity Correction Boost",
    Desc = "Множитель корректировки скорости полета",
    Step = 0.1,
    Value = {
        Min = 0.5,
        Max = 2.0,
        Default = 1.0,
    },
    Callback = function(Value)
        ZenithConfig.SpeedMultiplier = Value
    end,
})

TabSettings:Toggle({
    Title = "System Notifications",
    Desc = "Показывать уведомления при включении функций",
    Value = true,
    Callback = function(Value)
        ZenithConfig.NotificationEnabled = Value
    end,
})

-- Функция поиска ворот соперника
local function getOpponentGoalPosition()
    local targetPos = Camera.CFrame.Position + (Camera.CFrame.LookVector * 300)
    
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = obj.Name:lower()
                if name:find("goal") or name:find("net") or name:find("target") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                        if dist > 40 then 
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

-- Логика перехвата и мгновенного забивания мяча
local function setupBall(ball)
    if not ball or ball:GetAttribute("ZenithHooked") then return end
    ball:SetAttribute("ZenithHooked", true)

    local connection
    connection = ball.Touched:Connect(function(hit)
        if not ZenithConfig.Enabled then return end
        
        local char = LocalPlayer.Character
        if char and hit:IsDescendantOf(char) then
            pcall(function()
                local currentVelocity = ball.AssemblyLinearVelocity
                local speed = currentVelocity.Magnitude * ZenithConfig.SpeedMultiplier
                if speed < 15 then speed = 75 end -- Страховка от нулевой скорости

                local goalPos = getOpponentGoalPosition()
                local direction = (goalPos - ball.Position).Unit
                
                -- Перенаправляем физику и вектор движения
                ball.AssemblyLinearVelocity = direction * speed
                ball.CFrame = CFrame.new(ball.Position, goalPos)
            end)
        end
    end)

    ball.AncestryChanged:Connect(function()
        if not ball.Parent then
            if connection then connection:Disconnect() end
        end
    end)
end

-- Фоновый сканер мячей на карте (оптимизированный)
task.spawn(function()
    while true do
        pcall(function()
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("BasePart") then
                    local name = obj.Name:lower()
                    if name:find("ball") or name:find("football") then
                        setupBall(obj)
                    end
                end
            end
            for _, child in ipairs(Workspace:GetChildren()) do
                if child:IsA("Folder") or child:IsA("Model") then
                    for _, obj in ipairs(child:GetChildren()) do
                        if obj:IsA("BasePart") then
                            local name = obj.Name:lower()
                            if name:find("ball") or name:find("football") then
                                setupBall(obj)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.8)
    end
end)

-- Уведомление об успешной загрузке
WindUI:Notify({
    Title = "Zenithware " .. VERSION .. " Loaded!",
    Content = "WindUI Engine is ready to play.",
    Duration = 4,
    Icon = "zap",
})
