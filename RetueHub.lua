-- Zenithware v0.3 - Touch Football (Fixed Instant Goal Aim)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Zenithware | Touch Football",
   LoadingTitle = "Zenithware Loading...",
   LoadingSubtitle = "by reiddd",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Main", 4483362458)

local Settings = {
   AutoGoal = false,
   GoalPower = 180, -- Скорость полета мяча в ворота
}

Tab:CreateToggle({
   Name = "Моментальный авто-гол (В ворота соперника)",
   CurrentValue = false,
   Flag = "AutoGoalToggle",
   Callback = function(Value)
      Settings.AutoGoal = Value
      if Value then
         Rayfield:Notify({
            Title = "Zenithware",
            Content = "Авто-гол активирован! При касании мяч полетит в ворота соперника.",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Функция точного поиска вражеских ворот (чтобы не забить в свои)
local function getEnemyGoalPosition()
   local closestGoal = nil
   local shortestDist = math.huge
   
   for _, obj in ipairs(workspace:GetDescendants()) do
      if obj:IsA("BasePart") and (obj.Name:lower():find("goal") or obj.Name:lower():find("net") or obj.Name:lower():find("posts")) then
         -- Исключаем свои ворота, если они привязаны к командной зоне, либо ищем противоположные от нашей базы
         local dist = (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
         -- Ворота противника обычно дальше от нас, чем свои, либо имеют маркер вражеской стороны
         if dist > 30 and dist < shortestDist then
            shortestDist = dist
            closestGoal = obj.Position
         end
      end
   end
   
   -- Если ворота не нашлись поблизости, берем точку далеко впереди по взгляду камеры
   if not closestGoal then
      closestGoal = workspace.CurrentCamera.CFrame.Position + (workspace.CurrentCamera.CFrame.LookVector * 200)
   end
   
   return closestGoal
end

-- Жесткий обработчик касания и моментального пуляния мяча
RunService.Stepped:Connect(function()
   if Settings.AutoGoal then
      local character = LocalPlayer.Character
      if character and character:FindFirstChild("HumanoidRootPart") then
         local hrp = character.HumanoidRootPart
         
         for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("football")) then
               local distance = (obj.Position - hrp.Position).Magnitude
               
               -- Как только происходит касание мяча (дистанция меньше 5 ступней)
               if distance < 5 then
                  local enemyGoalPos = getEnemyGoalPosition()
                  
                  -- Обнуляем старую физику и пуляем мяч на максимальной скорости в ворота врага
                  if obj:IsA("BasePart") then
                     obj.AssemblyLinearVelocity = (enemyGoalPos - obj.Position).Unit * Settings.GoalPower
                  end
               end
            end
         end
      end
   end
end)

Rayfield:LoadConfiguration()
