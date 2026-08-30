-- ==============================================================================
-- Zenithware v2.1 | Touch Football Ultimate Auto-Goal Engine
-- ==============================================================================

local VERSION = "v2.1 Pro"
local AUTHOR = "reiddd"

local Success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Success or not Rayfield then
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Window = Rayfield:CreateWindow({
   Name = "Zenithware " .. VERSION + " | Touch Football",
   LoadingTitle = "Initializing Zenithware Core...",
   LoadingSubtitle = "By " .. AUTHOR,
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local TabMain = Window:CreateTab("Auto-Goal Hub", 4483362458)
local TabVisuals = Window:CreateTab("Visuals & ESP", 4483362458)

local ZenithConfig = {
   Enabled = false,
   VisualESP = true,
   NotificationEnabled = true,
}

TabMain:CreateToggle({
   Name = "Auto-Goal Redirection (Instant & Natural Speed)",
   CurrentValue = false,
   Flag = "AutoGoalToggle",
   Callback = function(Value)
      ZenithConfig.Enabled = Value
      if ZenithConfig.NotificationEnabled then
         Rayfield:Notify({
            Title = "Zenithware Status",
            Content = Value and "Auto-Goal Activated!" or "Auto-Goal Deactivated.",
            Duration = 2,
            Image = 4483362458,
         })
      end
   end,
})

TabVisuals:CreateToggle({
   Name = "Ball ESP & Highlight",
   CurrentValue = true,
   Flag = "EspToggle",
   Callback = function(Value)
      ZenithConfig.VisualESP = Value
   end,
})

-- Функция поиска ворот соперника (определяем по позициям или направлению камеры)
local function getOpponentGoalPosition()
   -- Ищем ворота или стойки на карте, если нет — берем точку впереди по направлению атаки
   local targetPos = Camera.CFrame.Position + (Camera.CFrame.LookVector * 300)
   
   for _, obj in ipairs(Workspace:GetDescendants()) do
      if obj:IsA("BasePart") then
         local name = obj.Name:lower()
         -- Поиск триггеров ворот или самих ворот на карте
         if name:find("goal") or name:find("net") or name:find("target") then
            -- Проверяем, что это не наши ворота (находятся дальше от нас или по другую сторону)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
               local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude
               if dist > 40 then 
                  return obj.Position
               end
            end
         end
      end
   end
   return targetPos
end

-- Основная логика мгновенного перенаправления мяча при касании
local function setupBall(ball)
   if not ball or ball:GetAttribute("ZenithHooked") then return end
   ball:SetAttribute("ZenithHooked", true)

   local connection
   connection = ball.Touched:Connect(function(hit)
      if not ZenithConfig.Enabled then return end
      
      local char = LocalPlayer.Character
      if char and hit:IsDescendantOf(char) then
         pcall(function()
            -- Сохраняем текущую скорость и направление (чтобы летело естественно)
            local currentVelocity = ball.AssemblyLinearVelocity
            local speed = currentVelocity.Magnitude
            if speed < 10 then speed = 60 end -- Страховка на случай слабого касания

            -- Находим цель (ворота)
            local goalPos = getOpponentGoalPosition()
            
            -- Вычисляем вектор направления строго в ворота
            local direction = (goalPos - ball.Position).Unit
            
            -- Мгновенно меняем траекторию полета, сохраняя родную скорость удара
            ball.AssemblyLinearVelocity = direction * speed
            
            -- Дополнительно сдвигаем CFrame на микрошаг вперед, чтобы избежать багов коллизии
            ball.CFrame = CFrame.new(ball.Position, goalPos)
         end)
      end
   end)

   -- Очистка при удалении мяча
   ball.AncestryChanged:Connect(function()
      if not ball.Parent then
         if connection then connection:Disconnect() end
      end
   end)
end

-- Быстрый и легкий сканер мячей на поле (без нагрузки на процессор)
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
         -- Также проверяем папки с инвентарем/мячами если они есть
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
      task.wait(1)
   end
end)

Rayfield:LoadConfiguration()

Rayfield:Notify({
   Title = "Zenithware " .. VERSION .. " Loaded!",
   Content = "Auto-Goal Engine is ready.",
   Duration = 4,
   Image = 4483362458,
})
