-- RetueHub v0.2 - Touch Football (Rayfield UI Edition)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "RetueHub | Touch Football",
   LoadingTitle = "RetueHub Loading...",
   LoadingSubtitle = "by reiddd",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false,
})

local Tab = Window:CreateTab("Main", 4483362458) -- Иконка домика/главная

-- Переменные функций
local Settings = {
   AutoGoal = false,
   GoalPower = 50, -- Сила удара/паса
}

-- Секция функций
local Section = Tab:CreateSection("Функции для матча")

-- Переключатель авто-гола / жесткого аима на ворота
Tab:CreateToggle({
   Name = "Авто-гол при касании мяча",
   CurrentValue = false,
   Flag = "AutoGoalToggle",
   Callback = function(Value)
      Settings.AutoGoal = Value
      if Value then
         Rayfield:Notify({
            Title = "RetueHub",
            Content = "Авто-гол активирован! При касании мяч полетит в ворота.",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

-- Логика перехвата касания мяча и направления в ворота
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

RunService = game:GetService("RunService")

-- Пример поиска ворот на карте (обычно они называются Goal или Part ворот)
local function getGoalPosition()
   -- Ищем ворота на поле (в зависимости от карты название может отличаться, ищем общие ориентиры)
   for _, obj in ipairs(workspace:GetDescendants()) do
      if obj:IsA("BasePart") and (obj.Name:lower():find("goal") or obj.Name:lower():find("net") or obj.Name:lower():find("posts")) then
         return obj.Position
      end
   end
   -- Если точных ворот не нашлось, бьем по дефолтной точке впереди
   return workspace.CurrentCamera.CFrame.Position + (workspace.CurrentCamera.CFrame.LookVector * 100)
end

-- Основной обработчик события касания и изменения траектории мяча
game:GetService("RunService").Stepped:Connect(function()
   if Settings.AutoGoal then
      local character = LocalPlayer.Character
      if character and character:FindFirstChild("HumanoidRootPart") then
         local hrp = character.HumanoidRootPart
         
         -- Ищем мяч поблизости от игрока
         for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("football")) then
               local distance = (obj.Position - hrp.Position).Magnitude
               -- Если мяч рядом (происходит касание/владение)
               if distance < 6 then
                  local goalPos = getGoalPosition()
                  -- Мгновенно меняем вектор скорости мяча прямо в ворота
                  if obj:FindFirstChildOfClass("BodyVelocity") or obj:FindFirstChildOfClass("LinearVelocity") then
                     -- Если у мяча есть физический движок, подстраиваем velocity
                  else
                     -- Принудительно толкаем мяч в сторону ворот
                     obj.Velocity = (goalPos - obj.Position).Unit * 150
                  end
               end
            end
         end
      end
   end
end)

Rayfield:LoadConfiguration()
