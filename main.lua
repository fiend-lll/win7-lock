-- Nyxal - Modern Mobile Camlock (Ping Prediction + Stabil Lock)
-- Toggle Button → Ana GUI aç/kapat | Lock Button → Lock ON/OFF

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CoreGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nyxal"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Settings
local Settings = {
    Enabled = false,
    TeamCheck = true,
    VisibleCheck = true,
    Smoothness = 0.11,
    PredictionMultiplier = 1.25, -- Ping'e göre çarpan
    TargetInfo = true
}

-- Modern Siyah Transparent Ana GUI
local MainGui = Instance.new("Frame")
MainGui.Size = UDim2.new(0, 300, 0, 350)
MainGui.Position = UDim2.new(0.5, -150, 0.5, -175)
MainGui.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainGui.BackgroundTransparency = 0.4
MainGui.BorderSizePixel = 0
MainGui.Active = true
MainGui.Draggable = true
MainGui.Visible = false
MainGui.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 18)
UICorner.Parent = MainGui

local UIGrad = Instance.new("UIGradient")
UIGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 5))
}
UIGrad.Rotation = 90
UIGrad.Parent = MainGui

-- Başlık
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "Nyxal"
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.Parent = MainGui

-- Close Button
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -50, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
Close.Text = "×"
Close.TextColor3 = Color3.new(1,1,1)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 26
Close.Parent = MainGui

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = Close

Close.MouseButton1Click:Connect(function()
    TweenService:Create(MainGui, TweenInfo.new(0.3, Enum.EasingStyle.Back), {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.delay(0.35, function() MainGui.Visible = false end)
end)

-- Lock Button (Ana GUI içinde değil, ayrı sürüklenir buton)
local LockBtn = Instance.new("ImageButton")
LockBtn.Size = UDim2.new(0, 100, 0, 100)
LockBtn.Position = UDim2.new(0.5, -50, 0.6, -50)
LockBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LockBtn.BackgroundTransparency = 0.35
LockBtn.BorderSizePixel = 0
LockBtn.Image = "rbxassetid://0" -- ← BURAYA İKON ID'Nİ YAZ (sen koyacaksın)
LockBtn.Parent = ScreenGui

local LockCorner = Instance.new("UICorner")
LockCorner.CornerRadius = UDim.new(0, 22)
LockCorner.Parent = LockBtn

local LockStroke = Instance.new("UIStroke")
LockStroke.Color = Color3.fromRGB(0, 255, 180)
LockStroke.Thickness = 2.5
LockStroke.Transparency = 0.5
LockStroke.Parent = LockBtn

-- Lock Hover + Click Animasyon
LockBtn.MouseEnter:Connect(function()
    TweenService:Create(LockBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.15, Size = UDim2.new(0, 110, 0, 110)}):Play()
end)
LockBtn.MouseLeave:Connect(function()
    TweenService:Create(LockBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.35, Size = UDim2.new(0, 100, 0, 100)}):Play()
end)

LockBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    TweenService:Create(LockBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
        BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(20, 20, 20),
        Size = UDim2.new(0, Settings.Enabled and 120 or 100, 0, Settings.Enabled and 120 or 100)
    }):Play()
end)

-- Lock Button Drag
local dragging, dragInput, dragStart, startPos
LockBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = LockBtn.Position
    end
end)

LockBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        LockBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Toggle Button (Ana GUI'yi gizle/göster)
local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Size = UDim2.new(0, 70, 0, 70)
ToggleGuiBtn.Position = UDim2.new(0.05, 0, 0.9, -80)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleGuiBtn.BackgroundTransparency = 0.5
ToggleGuiBtn.BorderSizePixel = 0
ToggleGuiBtn.Text = "GUI"
ToggleGuiBtn.TextColor3 = Color3.fromRGB(0, 255, 180)
ToggleGuiBtn.Font = Enum.Font.GothamBold
ToggleGuiBtn.TextSize = 18
ToggleGuiBtn.Parent = ScreenGui

local ToggleGuiCorner = Instance.new("UICorner")
ToggleGuiCorner.CornerRadius = UDim.new(0, 18)
ToggleGuiCorner.Parent = ToggleGuiBtn

ToggleGuiBtn.MouseButton1Click:Connect(function()
    if MainGui.Visible then
        TweenService:Create(MainGui, TweenInfo.new(0.3), {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.delay(0.35, function() MainGui.Visible = false end)
    else
        MainGui.Visible = true
        TweenService:Create(MainGui, TweenInfo.new(0.3, Enum.EasingStyle.Back), {BackgroundTransparency = 0.35, Size = UDim2.new(0, 300, 0, 350)}):Play()
    end
end)

-- En Yakın Oyuncu + Ping Prediction
local function GetClosestTarget()
    local closest, minDist = nil, 180 -- max lock mesafesi

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local root = plr.Character.HumanoidRootPart
            
            -- Ping bazlı prediction (en iyi değer 1.25-1.4 arası)
            local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
            local predOffset = root.Velocity * ping * Settings.PredictionMultiplier
            local predPos = head.Position + predOffset

            local screenPos, onScreen = Camera:WorldToScreenPoint(predPos)
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude

            if onScreen and dist < minDist then
                if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
                closest = plr
                minDist = dist
            end
        end
    end

    return closest
end

-- Ana Lock Loop
local CurrentTarget = nil
RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then 
        CurrentTarget = nil
        return 
    end

    local target = GetClosestTarget()
    CurrentTarget = target

    if target and target.Character and target.Character:FindFirstChild("Head") then
        local headPos = target.Character.Head.Position
        local rootVel = target.Character.HumanoidRootPart.Velocity
        local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
        local predPos = headPos + rootVel * ping * Settings.PredictionMultiplier

        local current = Camera.CFrame
        local targetCF = CFrame.lookAt(current.Position, predPos)
        Camera.CFrame = current:Lerp(targetCF, Settings.Smoothness)
    end
end)

print("Nyxal LOADED! ✓")
print("Lock Butonuna tıkla = Lock ON/OFF | Butonu sürükle = Yer değiştir")
