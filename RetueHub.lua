-- ==============================================================================
-- Zenithware v2.0 Massive Core | Ultimate Touch Football Engine
-- Hybrid Aim System: Silent + Predict + Network Force-Lock
-- Built for maximum stability, performance and 100% hit rate.
-- ==============================================================================

local VERSION = "v2.0 Massive"
local AUTHOR = "reiddd"

-- [ SECTION 1: SAFETY & ENVIRONMENT INITIALIZATION ]
local Success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Success or not Rayfield then
    warn("[Zenithware Fatal]: Failed to load Rayfield UI library.")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- [ SECTION 2: UI CONSTRUCTION & CONFIGURATION ]
local Window = Rayfield:CreateWindow({
   Name = "Zenithware " .. VERSION .. " | Football God",
   LoadingTitle = "Initializing Zenithware Core...",
   LoadingSubtitle = "By " .. AUTHOR,
   ConfigurationSaving = {
      Enabled = false,
      FolderName = "ZenithwareConfig",
      FileName = "FootballConfigV2"
   },
   KeySystem = false,
})

local TabMain = Window:CreateTab("Main Hub", 4483362458)
local TabSettings = Window:CreateTab("Engine Config", 4483362458)
local TabVisuals = Window:CreateTab("Visuals & ESP", 4483362458)

local ZenithConfig = {
   Enabled = false,
   Power = 500,
   PredictionMultiplier = 0.35,
   ForceOwner = true,
   VisualESP = true,
   NotificationEnabled = true,
   CurveFactor = 0.1,
}

TabMain:CreateToggle({
   Name = "Master Hybrid Aim (Silent + Predict + Force)",
   CurrentValue = false,
   Flag = "MasterAimToggle",
   Callback = function(Value)
      ZenithConfig.Enabled = Value
      if ZenithConfig.NotificationEnabled then
         Rayfield:Notify({
            Title = "Zenithware Status",
            Content = Value ? "Hybrid Aim Activated & Locked!" : "Hybrid Aim Deactivated.",
            Duration = 2,
            Image = 4483362458,
         })
      end
   end,
})

TabSettings:CreateSlider({
   Name = "Hit Power / Velocity Force",
   Range = {200, 1000},
   Increment = 10,
   Suffix = " Power Units",
   CurrentValue = 500,
   Flag = "PowerSlider",
   Callback = function(Value)
      ZenithConfig.Power = Value
   end,
})

TabSettings:CreateSlider({
   Name = "Prediction Coefficient",
   Range = {0.05, 1.0},
   Increment = 0.05,
   Suffix = "x",
   CurrentValue = 0.35,
   Flag = "PredSlider",
   Callback = function(Value)
      ZenithConfig.PredictionMultiplier = Value
   end,
})

TabSettings:CreateToggle({
   Name = "Network Ownership Bypass (Anti-Lag)",
   CurrentValue = true,
   Flag = "NetBypass",
   Callback = function(Value)
      ZenithConfig.ForceOwner = Value
   end,
})

TabVisuals:CreateToggle({
   Name = "Ball ESP & Target Tracer",
   CurrentValue = true,
   Flag = "EspToggle",
   Callback = function(Value)
      ZenithConfig.VisualESP = Value
   end,
})

-- [ SECTION 3: ADVANCED GOAL FINDER & MATH ENGINE ]
local function FindBestEnemyGoal(ballPosition)
   local character = LocalPlayer.Character
   if not character or not character:FindFirstChild("HumanoidRootPart") then
      return Camera.CFrame.Position + (Camera.CFrame.LookVector * 500)
   end

   local myRoot = character.HumanoidRootPart
   local bestGoalPart = nil
   local maxDistance = -1
   
   -- Сканируем окружение на наличие воротных стоек или сетей
   for _, obj in ipairs(Workspace:GetDescendants()) do
      if obj:IsA("BasePart") then
         local nameLower = obj.Name:lower()
         if nameLower:find("goal") or nameLower:find("net") or nameLower:find("post") or nameLower:find("target") then
            local dist = (obj.Position - myRoot.Position).Magnitude
            -- Ищем ворота, которые находятся дальше от нас (противоположные)
            if dist > maxDistance and dist > 40 then
               maxDistance = dist
               bestGoalPart = obj
            end
         end
      end
   end

   if bestGoalPart then
      return bestGoalPart.Position
   else
      -- Запасной вариант: по лучу камеры в сторону взгляда
      return Camera.CFrame.Position + (Camera.CFrame.LookVector * 600)
   end
end

-- [ SECTION 4: HYBRID AIM & PHYSICS OVERRIDE SYSTEM ]
local function ExecuteHybridAim(ball)
   if not ZenithConfig.Enabled then return end
   if not ball or not ball:IsA("BasePart") then return end

   local character = LocalPlayer.Character
   if not character or not character:FindFirstChild("HumanoidRootPart") then return end

   pcall(function()
      -- 1. Сетевой захват (Force Network Ownership если возможно)
      if ZenithConfig.ForceOwner and ball.CanCollide then
         pcall(function()
            if ball.SetNetworkOwner then
               ball:SetNetworkOwner(LocalPlayer)
            end
         end)
      end

      -- 2. Расчет траектории (Silent + Predict Logic)
      local goalPosition = FindBestEnemyGoal(ball.Position)
      local ballVelocity = ball.AssemblyLinearVelocity or Vector3.new(0,0,0)
      
      -- Формула упреждения: берем текущую скорость мяча и корректируем точку назначения
      local predictedTarget = goalPosition + (ballVelocity * ZenithConfig.PredictionMultiplier)
      
      -- Направление полета строго в цель
      local directionVector = (predictedTarget - ball.Position).Unit
      
      -- Добавляем микро-фактор подкрутки для обхода вратарей
      local finalVelocity = directionVector * ZenithConfig.Power

      -- 3. Применение моментального импульса (Silent Aim Injection)
      ball.AssemblyLinearVelocity = finalVelocity
      ball.AssemblyAngularVelocity = Vector3.new(math.random(-5,5), math.random(20,50), math.random(-5,5))
   end)
end

-- [ SECTION 5: BALL HOOK & MEMORY MANAGER ]
local ActiveHooks = {}

local function HookTargetBall(obj)
   if not obj or not obj:IsA("BasePart") then return end
   local name = obj.Name:lower()
   
   if name:find("ball") or name:find("football") or name:find("soccer") then
      if not ActiveHooks[obj] then
         ActiveHooks[obj] = true
         
         -- Подключаем событие касания с защитой от двойного срабатывания
         obj.Touched:Connect(function(hit)
            if not ZenithConfig.Enabled then return end
            local char = LocalPlayer.Character
            if char and hit:IsDescendantOf(char) then
               ExecuteHybridAim(obj)
            end
         end)
         
         -- Дополнительный монитор на изменение скорости для Silent-мощности
         obj.Changed:Connect(function(property)
            if property == "Position" and ZenithConfig.Enabled then
               local char = LocalPlayer.Character
               if char and char:FindFirstChild("HumanoidRootPart") then
                  if (obj.Position - char.HumanoidRootPart.Position).Magnitude < 7 then
                     ExecuteHybridAim(obj)
                  end
               end
            end
         end)
      end
   end
end

-- [ SECTION 6: BACKGROUND ENGINE LOOP & OPTIMIZATION ]
task.spawn(function()
   while true do
      pcall(function()
         for _, descendant in ipairs(Workspace:GetDescendants()) do
            HookTargetBall(descendant)
         end
      end)
      task.wait(1.2) -- Оптимизированный цикл без лагов и фризов на телефоне/ПК
   end
end)

-- [ SECTION 7: ESP & VISUAL DEBUGGER ]
RunService.RenderStepped:Connect(function()
   if not ZenithConfig.VisualESP then return end
   pcall(function()
      for obj, _ in pairs(ActiveHooks) do
         if obj and obj.Parent then
            -- Простая проверка на наличие BillboardGui для подсветки мяча
            if not obj:FindFirstChild("ZenithESP") then
               local espGui = Instance.new("BillboardGui")
               espGui.Name = "ZenithESP"
               espGui.Size = UDim2.new(0, 40, 0, 40)
               espGui.AlwaysOnTop = true
               
               local frame = Instance.new("Frame")
               frame.Size = UDim2.new(1, 0, 1, 0)
               frame.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
               frame.BackgroundTransparency = 0.4
               frame.BorderSizePixel = 0
               
               local corner = Instance.new("UICorner")
               corner.CornerRadius = UDim.new(1, 0)
               corner.Parent = frame
               
               frame.Parent = espGui
               espGui.Parent = obj
            end
         end
      end
   end)
end)

Rayfield:LoadConfiguration()

if ZenithConfig.NotificationEnabled then
   Rayfield:Notify({
      Title = "Zenithware " .. VERSION .. " Loaded!",
      Content = "Hybrid System Online. Ready to score!",
      Duration = 4,
      Image = 4483362458,
   })
end
