-- Touch Football Advanced Aim Script (v2)
-- Подходит для тестирования через Real / Madium на ПК

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки
local Settings = {
    Enabled = false, -- По умолчанию выключено, включаем с кнопки
    TeamCheck = true,
    FOV = 200,
}

-- Создаем простейшую GUI кнопку для включения/выключения прямо в игре
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimToggleGui"
ScreenGui.ResetOnSpawn = false
-- Безопасная привязка к GUI игрока
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 140, 0, 45)
ToggleButton.Position = UDim2.new(0, 50, 0, 50) -- Уголок экрана
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "Aim: OFF"
ToggleButton.Parent = ScreenGui

-- Логика кнопки
ToggleButton.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    if Settings.Enabled then
        ToggleButton.Text = "Aim: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        ToggleButton.Text = "Aim: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)

-- Функция поиска ближайшей цели (соперника)
local function getClosestTarget()
    local target = nil
    local shortestDistance = Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not Settings.TeamCheck or player.Team ~= LocalPlayer.Team then
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    local rootPart = character.HumanoidRootPart
                    -- Целимся чуть выше центра (в грудь/корпус), чтобы пас ловился лучше
                    local targetPos = rootPart.Position + Vector3.new(0, 0.5, 0)
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPos)
                    
                    if onScreen then
                        local mouseLocation = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation).Magnitude
                        
                        if distance < shortestDistance then
                            shortestDistance = distance
                            target = targetPos
                        end
                    end
                end
            end
        end
    end
    return target
end

-- Основной цикл работы аима
RunService.RenderStepped:Connect(function()
    if Settings.Enabled then
        local targetPos = getClosestTarget()
        if targetPos then
            -- Плавное или моментальное переведение взгляда на цель
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end)

print("Touch Football Custom Aim успешно загружен!")
