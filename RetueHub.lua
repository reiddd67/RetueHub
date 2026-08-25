-- ========================================================
-- Zenithware v0.5 Ultimate | Touch Football
-- Developed for Delta & Mobile Executors
-- ========================================================

-- Проверка на загрузку UI библиотек
local Success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Success or not Rayfield then
    warn("Zenithware: Не удалось загрузить Rayfield UI!")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "Zenithware | Touch Football v0.5",
   LoadingTitle = "Загрузка Zenithware...",
   LoadingSubtitle = "by reiddd",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = "ZenithwareConfig",
      FileName = "TouchFootball"
   },
   KeySystem = false,
})

local MainTab = Window:CreateTab("Главная", 4483362458)
local SettingsTab = Window:CreateTab("Настройки", 4483362458)

-- Переменные конфигурации
local Config = {
   AutoGoal = false,
   GoalPower = 300, -- Мощность удара по умолчанию
   HitboxExpand = false
}

-- Главный переключатель
MainTab:CreateToggle({
   Name = "Ультимативный авто-гол (Aim-Lock)",
   CurrentValue = false,
   Flag = "AutoGoalToggle",
   Callback = function(Value)
      Config.AutoGoal = Value
      Rayfield:Notify({
         Title = "Zenithware",
         Content = Value ? "Авто-гол включен!" : "Авто-гол выключен.",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- Слайдер настройки силы удара
SettingsTab:CreateSlider({
   Name = "Сила удара / Мощность",
   Range = {100, 600},
   Increment = 10,
   Suffix = " Power",
   CurrentValue = 300,
   Flag = "GoalPowerSlider",
   Callback = function(Value)
      Config.GoalPower = Value
   end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Функция точного перехвата и удара мяча
local function processBall(ball)
   if not ball or not ball:IsA("BasePart") then return end
   
   local name = ball.Name:lower()
   if name:find("ball") or name:find("football") then
      -- Проверяем, не хукали ли мы этот мяч ранее
      if not ball:GetAttribute("ZenithHooked") then
         ball:SetAttribute("ZenithHooked", true)
         
         -- Событие касания мяча игроком
         ball.Touched:Connect(function(hit)
            if Config.AutoGoal then
               local character = LocalPlayer.Character
               if character and hit:IsDescendantOf(character) then
                  local camera = workspace.CurrentCamera
                  if camera then
                     -- Придаем моментальный вектор скорости строго по взгляду камеры
                     ball.AssemblyLinearVelocity = camera.CFrame.LookVector * Config.GoalPower
                     ball.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                  end
               end
            end
         end)
      end
   end
end

-- Фоновый поток для непрерывного сканирования мячей на карте (с защитой от крашей)
task.spawn(function()
   while true do
      local success, err = pcall(function()
         for _, obj in ipairs(workspace:GetDescendants()) do
            processBall(obj)
         end
      end)
      task.wait(1.5) -- Оптимизация: сканируем каждые 1.5 секунды, не нагружая мобильный процессор
   end
end)

Rayfield:LoadConfiguration()

Rayfield:Notify({
   Title = "Zenithware загружен!",
   Content = "Скрипт успешно запущен. Приятной игры!",
   Duration = 3,
   Image = 4483362458,
})
