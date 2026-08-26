-- ==============================================================================
-- Zenithware v2.0 Massive Core | Ultimate Touch Football Engine (Fixed)
-- ==============================================================================

local VERSION = "v2.0 Massive"
local AUTHOR = "reiddd"

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
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Window = Rayfield:CreateWindow({
   Name = "Zenithware " .. VERSION .. " | Football God",
   LoadingTitle = "Initializing Zenithware Core...",
   LoadingSubtitle = "By " .. AUTHOR,
   ConfigurationSaving = { Enabled = false },
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
            Content = Value and "Hybrid Aim Activated & Locked!" or "Hybrid Aim Deactivated.",
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

TabVisuals:CreateToggle({
   Name = "Ball ESP & Target Tracer",
   CurrentValue = true,
   Flag = "EspToggle",
   Callback = function(Value)
      ZenithConfig.VisualESP = Value
   end,
})

local function FindBestEnemyGoal()
   local character = LocalPlayer.Character
   if not character or not character:FindFirstChild("HumanoidRootPart") then
      return Camera.CFrame.Position + (Camera.CFrame.LookVector * 500)
   end
   return Camera.CFrame.Position + (Camera.CFrame.LookVector * 600)
end

local function ExecuteHybridAim(ball)
   if not ZenithConfig.Enabled then return end
   if not ball or not ball:IsA("BasePart") then return end

   pcall(function()
      local goalPosition = FindBestEnemyGoal()
      local ballVelocity = ball.AssemblyLinearVelocity or Vector3.new(0,0,0)
      local predictedTarget = goalPosition + (ballVelocity * ZenithConfig.PredictionMultiplier)
      local directionVector = (predictedTarget - ball.Position).Unit
      
      ball.AssemblyLinearVelocity = directionVector * ZenithConfig.Power
   end)
end

local ActiveHooks = {}

local function HookTargetBall(obj)
   if not obj or not obj:IsA("BasePart") then return end
   local name = obj.Name:lower()
   
   if (name:find("ball") or name:find("football") or name:find("soccer")) and not ActiveHooks[obj] then
      ActiveHooks[obj] = true
      obj.Touched:Connect(function(hit)
         local char = LocalPlayer.Character
         if char and hit:IsDescendantOf(char) then
            ExecuteHybridAim(obj)
         end
      end)
   end
end

task.spawn(function()
   while true do
      pcall(function()
         for _, descendant in ipairs(Workspace:GetDescendants()) do
            HookTargetBall(descendant)
         end
      end)
      task.wait(1.5)
   end
end)

Rayfield:LoadConfiguration()

Rayfield:Notify({
   Title = "Zenithware " .. VERSION .. " Loaded!",
   Content = "Fixed & Ready to score!",
   Duration = 4,
   Image = 4483362458,
})
