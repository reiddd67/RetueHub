-- Zenithware v0.4 - Touch Football (Fixed Touch & Goal Logic)
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
   GoalPower = 220, -- Увеличили мощность для верности
}

Tab:CreateToggle({
   Name = "Моментальный авто-гол (Только в ворота соперника)",
   CurrentValue = false,
   Flag = "AutoGoalToggle",
   Callback = function(Value)
      Settings.AutoGoal = Value
      if Value then
         Rayfield:Notify({
            Title = "Zenithware",
            Content = "Ультимативный авто-гол активирован!",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Жесткий поиск вражеских ворот по цвету или названию (ищем то, что дальше всего от нашей базы)
local function getRealEnemyGoal()
   local character = LocalPlayer.Character
   if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
   
   local myPos = character.HumanoidRootPart.Position
   local bestGoal = nil
   local maxDist = 0
   
   for _, obj in ipairs(workspace:GetDescendants()) do
      if obj:IsA("BasePart") and (obj.Name:lower():find("goal") or obj.Name:lower():find("net") or obj.Name:lower():find("post")) then
         local dist = (obj.Position - myPos).Magnitude
         -- Ворота противника всегда находятся дальше от нас, чем наши собственные
         if dist > maxDist and dist > 40 then
            maxDist = dist
            bestGoal = obj.Position
         end
      end
   end
   
   -- Если ворота не найдены, лупим далеко вперед по камере
   if not bestGoal then
      bestGoal = workspace.CurrentCamera.CFrame.Position + (workspace.CurrentCamera.CFrame.LookVector * 300)
   end
   
   return bestGoal
end

-- Перехват касания через событие Touch (чтобы мяч не пролетал сквозь игрока)
local function hookBall(ball)
   if not ball:IsA("BasePart") then return end
   
   -- Проверяем, что это реально мяч по имени
   local name = ball.Name:lower()
   if name:find("ball") or name:find("football") then
      if not ball:GetAttribute("ZenithHooked") then
         ball:SetAttribute("ZenithHooked", true)
         
         ball.Touched:Connect(function(hit)
            if Settings.AutoGoal then
               local character = LocalPlayer.Character
               if character and (hit:IsDescendantOf(character)) then
                  local enemyGoal = getRealEnemyGoal()
                  
                  -- Придаем мгновенное ускорение прямо в ворота противника
                  ball.AssemblyLinearVelocity = (enemyGoal - ball.Position).Unit * Settings.GoalPower
                  ball.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
               end
            end
         end)
      end
   end
end

-- Сканируем мячи на карте в реальном времени
task.spawn(function()
   while true do
      task.wait(1)
      for _, obj in ipairs(workspace:GetDescendants()) do
         if obj:IsA("BasePart") then
            hookBall(obj)
         end
      end
   end
end)

Rayfield:LoadConfiguration()
