-- Nyxal - Modern Mobile Camlock (Ping Prediction + Premium GUI)
-- Toggle Button → Ana GUI aç/kapat | Lock Button → Lock ON/OFF

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
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
    Prediction = 0.1768521,
    HorizontalPrediction = 0.111076110,
    VerticalPrediction = 0.11034856,
    XPrediction = 20,
    YPrediction = 20,
    TargetInfo = true
}

-- Ana Modern Siyah GUI
local MainGui = Instance.new("Frame")
MainGui.Size = UDim2.new(0, 320, 0, 420)
MainGui.Position = UDim2.new(0.5, -160, 0.5, -210)
MainGui.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainGui.BackgroundTransparency = 0.25
MainGui.BorderSizePixel = 0
MainGui.Active = true
MainGui.Draggable = true
MainGui.Visible = false
MainGui.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = MainGui

local UIGrad = Instance.new("UIGradient")
UIGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 8))
}
UIGrad.Rotation = 90
UIGrad.Parent = MainGui

-- Başlık
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "Nyxal"
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 26
Title.Parent = MainGui

-- Close Button
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 45, 0, 45)
Close.Position = UDim2.new(1, -55, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
Close.Text = "×"
Close.TextColor3 = Color3.new(1,1,1)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 28
Close.Parent = MainGui

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 12)
CloseCorner.Parent = Close

Close.MouseButton1Click:Connect(function()
    TweenService:Create(MainGui, TweenInfo.new(0.35, Enum.EasingStyle.Back), {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.delay(0.4, function() MainGui.Visible = false end)
end)

-- Lock Button (Ayrı sürüklenir buton)
local LockBtn = Instance.new("ImageButton")
LockBtn.Size = UDim2.new(0, 110, 0, 110)
LockBtn.Position = UDim2.new(0.5, -55, 0.6, -55)
LockBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
LockBtn.BackgroundTransparency = 0.3
LockBtn.BorderSizePixel = 0
LockBtn.Image = "rbxassetid://0" -- ← BURAYA İKON ID'Nİ YAZ (sen koyacaksın)
LockBtn.Parent = ScreenGui

local LockCorner = Instance.new("UICorner")
LockCorner.CornerRadius = UDim.new(0, 24)
LockCorner.Parent = LockBtn

local LockStroke = Instance.new("UIStroke")
LockStroke.Color = Color3.fromRGB(0, 255, 180)
LockStroke.Thickness = 3
LockStroke.Transparency = 0.4
LockStroke.Parent = LockBtn

-- Hover + Click Animasyonu (en iyi Win7 benzeri)
LockBtn.MouseEnter:Connect(function()
    TweenService:Create(LockBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.1, Size = UDim2.new(0, 120, 0, 120)}):Play()
end)
LockBtn.MouseLeave:Connect(function()
    TweenService:Create(LockBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.3, Size = UDim2.new(0, 110, 0, 110)}):Play()
end)

LockBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    TweenService:Create(LockBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
        BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(18, 18, 18),
        Size = UDim2.new(0, Settings.Enabled and 130 or 110, 0, Settings.Enabled and 130 or 110)
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
ToggleGuiBtn.Size = UDim2.new(0, 80, 0, 80)
ToggleGuiBtn.Position = UDim2.new(0.05, 0, 0.9, -100)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
ToggleGuiBtn.BackgroundTransparency = 0.45
ToggleGuiBtn.BorderSizePixel = 0
ToggleGuiBtn.Text = "GUI"
ToggleGuiBtn.TextColor3 = Color3.fromRGB(0, 255, 180)
ToggleGuiBtn.Font = Enum.Font.GothamBold
ToggleGuiBtn.TextSize = 20
ToggleGuiBtn.Parent = ScreenGui

local ToggleGuiCorner = Instance.new("UICorner")
ToggleGuiCorner.CornerRadius = UDim.new(0, 20)
ToggleGuiCorner.Parent = ToggleGuiBtn

ToggleGuiBtn.MouseButton1Click:Connect(function()
    if MainGui.Visible then
        TweenService:Create(MainGui, TweenInfo.new(0.35, Enum.EasingStyle.Back), {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.delay(0.4, function() MainGui.Visible = false end)
    else
        MainGui.Visible = true
        TweenService:Create(MainGui, TweenInfo.new(0.35, Enum.EasingStyle.Back), {BackgroundTransparency = 0.25, Size = UDim2.new(0, 320, 0, 420)}):Play()
    end
end)

-- Senin Lock Mantığı (FindNearestEnemy + Velocity Prediction)
local CamlockState = false
local enemy = nil

local function FindNearestEnemy()
    local ClosestDistance, ClosestPlayer = math.huge, nil
    local CenterPosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local Character = Player.Character
            if Character and Character:FindFirstChild("UpperTorso") and Character.Humanoid.Health > 0 then
                local Position, IsVisibleOnViewport = Camera:WorldToViewportPoint(Character.UpperTorso.Position)

                if IsVisibleOnViewport then
                    local Distance = (CenterPosition - Vector2.new(Position.X, Position.Y)).Magnitude
                    if Distance < ClosestDistance then
                        ClosestPlayer = Character.UpperTorso
                        ClosestDistance = Distance
                    end
                end
            end
        end
    end

    return ClosestPlayer
end

-- Lock Loop
RunService.Heartbeat:Connect(function()
    if Settings.Enabled then
        if enemy then
            local camera = workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.p, enemy.Position + enemy.Velocity * Settings.Prediction)
        end
    end
end)

-- Lock Butonu Tıklandığında
LockBtn.MouseButton1Click:Connect(function()
    CamlockState = not CamlockState
    Settings.Enabled = CamlockState

    if CamlockState then
        enemy = FindNearestEnemy()
        if enemy then
            local targetPlayer = Players:GetPlayerFromCharacter(enemy.Parent)
            if targetPlayer then
                -- İsteğe bağlı notification (kapatabilirsin)
                -- game.StarterGui:SetCore("SendNotification", {Title = "Nyxal", Text = "Locked: " .. targetPlayer.DisplayName})
            end
        end
    else
        enemy = nil
        -- game.StarterGui:SetCore("SendNotification", {Title = "Nyxal", Text = "Unlocked!"})
    end
end)

print("Nyxal LOADED! ✓")
print("Lock butonuna tıkla = Lock ON/OFF | Butonu sürükle = Yer değiştir")
