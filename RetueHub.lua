-- ========================================================
-- Zenithware v1.0 (Mega Update) | Touch Football
-- Features: Aim-Lock, Aim Predict, Aim Silent & Rayfield UI
-- ========================================================

local Success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Success or not Rayfield then
    warn("Zenithware: Не удалось загрузить UI!")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "Zenithware v1.0 | Ultimate Football",
   LoadingTitle = "Загрузка Zenithware v1.0...",
   LoadingSubtitle = "by reiddd",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local MainTab = Window:CreateTab("Главная", 4483362458)
local SettingsTab = Window:CreateTab("Настройки Aim", 4483362458)

local Config = {
   Active = false,
   Mode = "Aim-Lock",
   Power = 350,
   PredictionFactor = 0.15,
}

MainTab:CreateToggle({
   Name = "Включить Zenithware Core",
   CurrentValue = false,
   Flag = "CoreToggle",
   Callback = function(Value)
      Config.Active = Value
      local notifyText = "Софт выключен."
      if Value then
         notifyText = "Софт активирован!"
      end
      Rayfield:Notify({
         Title = "Zenithware",
         Content = notifyText,
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

SettingsTab:CreateDropdown({
   Name = "Выбор режима Аима",
   Options = {"Aim-Lock", "Aim Predict", "Aim Silent"},
   CurrentOption = "Aim-Lock",
   Flag = "AimModeDropdown",
   Callback = function(Option)
      if type(Option) == "table" then
         Config.Mode = Option[1]
      else
         Config.Mode = Option
      end
      Rayfield:Notify({
         Title = "Режим изменен",
         Content = "Установлен: " .. tostring(Config.Mode),
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

SettingsTab:CreateSlider({
   Name = "Сила удара / Мощность",
   Range = {150, 700},
   Increment = 10,
   Suffix = " Power",
   CurrentValue = 350,
   Flag = "PowerSlider",
   Callback = function(Value)
      Config.Power = Value
   end,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local function getTargetGoal()
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then 
      return Workspace.CurrentCamera.CFrame.Position + (Workspace.CurrentCamera.CFrame.LookVector * 300) 
   end
   
   local myPos = char.HumanoidRootPart.Position
   local bestGoalPos = nil
   local maxDist = 0
   
   for _, obj in ipairs(Workspace:GetDescendants()) do
      if obj:IsA("BasePart") then
         local nameLower = obj.Name:lower()
         if nameLower:find("goal") or nameLower:find("net") or nameLower:find("post") then
            local dist = (obj.Position - myPos).Magnitude
            if dist > maxDist and dist > 30 then
                maxDist = dist
                bestGoalPos = obj.Position
            end
         end
      end
   end
   
   if not bestGoalPos then
      bestGoalPos = myPos + (char.HumanoidRootPart.CFrame.LookVector * 400)
   end
   
   return bestGoalPos
end

local function applyAimLogic(ball)
   if not Config.Active then return end
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("HumanoidRootPart") then return end
   
   local camera = Workspace.CurrentCamera
   local targetGoal = getTargetGoal()
   local direction = (targetGoal - ball.Position).Unit
   
   if Config.Mode == "Aim-Lock" then
      if camera then
         direction = camera.CFrame.LookVector
      end
      ball.AssemblyLinearVelocity = direction * Config.Power
      
   elseif Config.Mode == "Aim Predict" then
      local vel = ball.AssemblyLinearVelocity
      if not vel then vel = Vector3.new(0,0,0) end
      local velocityPredict = vel * Config.PredictionFactor
      local predictedTarget = targetGoal + velocityPredict
      direction = (predictedTarget - ball.Position).Unit
      ball.AssemblyLinearVelocity = direction * Config.Power
      
   elseif Config.Mode == "Aim Silent" then
      ball.AssemblyLinearVelocity = direction * Config.Power
      ball.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
   end
end

local function hookBall(ball)
   if not ball or not ball:IsA("BasePart") then return end
   local name = ball.Name:lower()
   
   if name:find("ball") or name:find("football") then
      if not ball:GetAttribute("ZenithHooked") then
         ball:SetAttribute("ZenithHooked", true)
         
         ball.Touched:Connect(function(hit)
             pcall(function()
                 local char = LocalPlayer.Character
                 if char and hit:IsDescendantOf(char) then
                     applyAimLogic(ball)
                 end
             end)
         end)
      end
   end
end

task.spawn(function()
   while true do
      pcall(function()
         for _, obj in ipairs(Workspace:GetDescendants()) do
            hookBall(obj)
         end
      end)
      task.wait(1)
   end
end)

Rayfield:LoadConfiguration()

Rayfield:Notify({
   Title = "Zenithware v1.0 Запущен!",
   Content = "Масштабное обновление успешно загружено.",
   Duration = 3,
   Image = 4483362458,
})
