-- Win7 Mobile Camlock - Animasyonlu & Stabil Edition (CoreGui - Respawn Safe)
-- Buton tıkla = Lock | Buton sürükle = Hareket ettir

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CoreGui (ölünce kaybolmaz)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Win7CamlockAnim"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Animasyon Tween Info'ları (bozulmasın diye reusable)
local tweenFast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenSlow = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Ana Win7 Pencere (Açılış animasyonu ile)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 460)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(236, 233, 216)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(128, 128, 128)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BackgroundTransparency = 1 -- Açılışta transparan başlıyor
MainFrame.Parent = ScreenGui

-- Açılış animasyonu (fade + scale)
TweenService:Create(MainFrame, tweenSlow, {BackgroundTransparency = 0}):Play()
TweenService:Create(MainFrame, tweenSlow, {Size = UDim2.new(0, 360, 0, 460)}):Play()

-- Win7 Mavi Başlık
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Win7 Camlock"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 45, 0, 28)
Close.Position = UDim2.new(1, -50, 0, 2)
Close.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 16
Close.Parent = TitleBar
Close.MouseButton1Click:Connect(function() 
    TweenService:Create(MainFrame, tweenSlow, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.delay(0.3, function() ScreenGui:Destroy() end)
end)

-- Hover efekti (tüm butonlar için)
local function addHover(btn, defaultColor)
    btn:SetAttribute("DefaultColor", defaultColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, tweenFast, {BackgroundColor3 = Color3.fromRGB(100, 180, 255)}):Play()
        TweenService:Create(btn, tweenFast, {Size = btn.Size + UDim2.new(0, 4, 0, 4)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, tweenFast, {BackgroundColor3 = defaultColor}):Play()
        TweenService:Create(btn, tweenFast, {Size = btn.Size}):Play()
    end)
end

addHover(Close, Color3.fromRGB(231, 76, 60))

-- İçerik ScrollFrame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 215)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 12)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

-- Kare Lock Butonu (Win7 Style - Ana GUI içinde)
local LockBtn = Instance.new("ImageButton")
LockBtn.Size = UDim2.new(0, 120, 0, 120)
LockBtn.Position = UDim2.new(0.5, -60, 0, 10)
LockBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
LockBtn.BorderSizePixel = 2
LockBtn.BorderColor3 = Color3.fromRGB(128, 128, 128)
LockBtn.Image = "rbxassetid://0" -- ← BURAYA WIN7 İKON ID'Nİ YAZ (sen koyacaksın)
LockBtn.Parent = Scroll
LockBtn.LayoutOrder = 1

local LockCorner = Instance.new("UICorner")
LockCorner.CornerRadius = UDim.new(0, 20)
LockCorner.Parent = LockBtn

local LockLabel = Instance.new("TextLabel")
LockLabel.Size = UDim2.new(1, 0, 0.3, 0)
LockLabel.Position = UDim2.new(0, 0, 0.7, 0)
LockLabel.BackgroundTransparency = 1
LockLabel.Text = "LOCK"
LockLabel.TextColor3 = Color3.new(1,1,1)
LockLabel.Font = Enum.Font.SourceSansBold
LockLabel.TextSize = 24
LockLabel.Parent = LockBtn

-- Hover + Tıkla Animasyonu (Win7 bounce + scale)
addHover(LockBtn, Color3.fromRGB(0, 120, 215))
LockBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    TweenService:Create(LockBtn, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {
        Size = UDim2.new(0, Settings.Enabled and 130 or 120, 0, Settings.Enabled and 130 or 120),
        BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(0, 120, 215)
    }):Play()
    LockLabel.Text = Settings.Enabled and "LOCKED" or "LOCK"
end)

-- Ayarlar (FOV, Smoothness)
local FOVTitle = Instance.new("TextLabel")
FOVTitle.Size = UDim2.new(1, -20, 0, 30)
FOVTitle.BackgroundTransparency = 1
FOVTitle.Text = "FOV: 120"
FOVTitle.TextColor3 = Color3.new(0,0,0)
FOVTitle.Font = Enum.Font.SourceSansBold
FOVTitle.TextSize = 16
FOVTitle.Parent = Scroll
FOVTitle.LayoutOrder = 2

local FOVInput = Instance.new("TextBox")
FOVInput.Size = UDim2.new(1, -20, 0, 40)
FOVInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVInput.Text = "120"
FOVInput.Font = Enum.Font.SourceSans
FOVInput.TextSize = 18
FOVInput.Parent = Scroll
FOVInput.LayoutOrder = 3

FOVInput.FocusLost:Connect(function()
    local val = tonumber(FOVInput.Text)
    if val and val >= 50 and val <= 500 then
        Settings.FOV = val
        FOVTitle.Text = "FOV: " .. val
    else
        FOVInput.Text = tostring(Settings.FOV)
    end
end)

-- Smoothness
local SmoothTitle = Instance.new("TextLabel")
SmoothTitle.Size = UDim2.new(1, -20, 0, 30)
SmoothTitle.BackgroundTransparency = 1
SmoothTitle.Text = "Smoothness: 0.12"
SmoothTitle.TextColor3 = Color3.new(0,0,0)
SmoothTitle.Font = Enum.Font.SourceSansBold
SmoothTitle.TextSize = 16
SmoothTitle.Parent = Scroll
SmoothTitle.LayoutOrder = 4

local SmoothInput = Instance.new("TextBox")
SmoothInput.Size = UDim2.new(1, -20, 0, 40)
SmoothInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SmoothInput.Text = "0.12"
SmoothInput.Font = Enum.Font.SourceSans
SmoothInput.TextSize = 18
SmoothInput.Parent = Scroll
SmoothInput.LayoutOrder = 5

SmoothInput.FocusLost:Connect(function()
    local val = tonumber(SmoothInput.Text)
    if val and val >= 0.01 and val <= 1 then
        Settings.Smoothness = val
        SmoothTitle.Text = "Smoothness: " .. val
    else
        SmoothInput.Text = tostring(Settings.Smoothness)
    end
end)

-- Team Check Toggle
local TeamToggle = Instance.new("TextButton")
TeamToggle.Size = UDim2.new(1, -20, 0, 50)
TeamToggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
TeamToggle.Text = "Team Check: ON"
TeamToggle.TextColor3 = Color3.new(1,1,1)
TeamToggle.Font = Enum.Font.SourceSansBold
TeamToggle.TextSize = 16
TeamToggle.Parent = Scroll
TeamToggle.LayoutOrder = 6

TeamToggle.MouseButton1Click:Connect(function()
    Settings.TeamCheck = not Settings.TeamCheck
    TeamToggle.Text = "Team Check: " .. (Settings.TeamCheck and "ON" or "OFF")
    TeamToggle.BackgroundColor3 = Settings.TeamCheck and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
end)
addWin7Hover(TeamToggle, Color3.fromRGB(46, 204, 113))

-- Target Info Panel (sağ üstte, animasyonlu)
local TargetPanel = Instance.new("Frame")
TargetPanel.Size = UDim2.new(0, 260, 0, 100)
TargetPanel.Position = UDim2.new(1, -280, 0, 20)
TargetPanel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TargetPanel.BorderSizePixel = 2
TargetPanel.BorderColor3 = Color3.fromRGB(0, 120, 215)
TargetPanel.Visible = false
TargetPanel.BackgroundTransparency = 1 -- Açılışta transparan
TargetPanel.Parent = ScreenGui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 12)
PanelCorner.Parent = TargetPanel

local TargetName = Instance.new("TextLabel")
TargetName.Size = UDim2.new(1, -10, 0.5, 0)
TargetName.Position = UDim2.new(0, 5, 0, 5)
TargetName.BackgroundTransparency = 1
TargetName.Text = "No Target"
TargetName.TextColor3 = Color3.new(1,1,1)
TargetName.Font = Enum.Font.SourceSansBold
TargetName.TextSize = 20
TargetName.Parent = TargetPanel

local TargetDist = Instance.new("TextLabel")
TargetDist.Size = UDim2.new(1, -10, 0.5, 0)
TargetDist.Position = UDim2.new(0, 5, 0.5, 0)
TargetDist.BackgroundTransparency = 1
TargetDist.Text = "Distance: --"
TargetDist.TextColor3 = Color3.fromRGB(200, 200, 200)
TargetDist.Font = Enum.Font.SourceSans
TargetDist.TextSize = 16
TargetDist.Parent = TargetPanel

-- FOV Circle (animasyonlu)
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = FOVCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(0, 120, 215)
CircleStroke.Thickness = 4
CircleStroke.Transparency = 0.3
CircleStroke.Parent = FOVCircle

-- En Yakın Oyuncu Bulma
local function GetClosestTarget()
    local closest, minDist = nil, Settings.FOV

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
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

-- Ana Loop (Stabil & Animasyonlu)
local CurrentTarget = nil
RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then 
        CurrentTarget = nil
        TargetPanel.Visible = false
        return 
    end

    local target = GetClosestTarget()
    CurrentTarget = target

    if target and target.Character and target.Character:FindFirstChild("Head") then
        -- Smooth Camlock
        local headPos = target.Character.Head.Position
        local current = Camera.CFrame
        local targetCF = CFrame.lookAt(current.Position, headPos)
        Camera.CFrame = current:Lerp(targetCF, Settings.Smoothness)

        -- Target Info Animasyonlu açılış
        if not TargetPanel.Visible then
            TargetPanel.BackgroundTransparency = 1
            TargetPanel.Visible = true
            TweenService:Create(TargetPanel, tweenSlow, {BackgroundTransparency = 0}):Play()
        end

        TargetName.Text = target.DisplayName or target.Name
        local dist = (target.Character.HumanoidRootPart.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new())).Magnitude
        TargetDist.Text = "Distance: " .. math.floor(dist) .. " studs"
    else
        if TargetPanel.Visible then
            TweenService:Create(TargetPanel, tweenFast, {BackgroundTransparency = 1}):Play()
            task.delay(0.3, function() TargetPanel.Visible = false end)
        end
        CurrentTarget = nil
    end
end)

print("Win7 Mobile Camlock - Animasyonlu Ana GUI LOADED! ✓")
print("Butonu sürükle | Tıkla = Lock ON/OFF")
