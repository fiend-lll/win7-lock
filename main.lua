local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Performance Optimization
local RENDER_DISTANCE = 1000
local UPDATE_INTERVAL = 0.016
local lastUpdate = 0

-- Ana Ayarlar
local Settings = {
    -- Lock Settings
    camlockEnabled = false,
    silentAimEnabled = false,
    lockButtonEnabled = false,
    
    -- Smoothness
    camlockSmoothness = 0.25,
    
    -- Prediction
    horizontalPrediction = 0.145,
    verticalPrediction = 0.165,
    autoPrediction = true,
    
    -- Shake
    shakeIntensity = 0.5,
    
    -- Target
    targetPart = "Head",
    maxLockDistance = 500,
    fovRadius = 180,
    
    -- Auto Features
    autoSwitch = true,
    antiAimAbuse = true,
    wallCheck = true,
    
    -- Notifications
    showNotifications = true,
    showTargetInfo = true,
    showFOV = true,
    showTracers = true
}

-- Target Data
local TargetData = {
    current = nil,
    lastPart = nil,
    lastHealth = 0,
    lockTime = 0,
    hitCount = 0,
    missCount = 0
}

-- UI Container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedLockSystem"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = gethui and gethui() or game:GetService("CoreGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 420)
mainFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Shadow Effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.ZIndex = 0
shadow.Parent = mainFrame

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

-- Accent Line
local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 3)
accentLine.Position = UDim2.new(0, 0, 0, 45)
accentLine.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
accentLine.BorderSizePixel = 0
accentLine.Parent = mainFrame

local accentGradient = Instance.new("UIGradient")
accentGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(114, 137, 218)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 101, 242))
}
accentGradient.Parent = accentLine

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(1, -20, 1, 0)
headerTitle.Position = UDim2.new(0, 10, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "ADVANCED LOCK SYSTEM"
headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextSize = 15
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = header

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(0, 60, 0, 20)
versionLabel.Position = UDim2.new(1, -70, 0.5, -10)
versionLabel.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
versionLabel.Text = "v3.5"
versionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
versionLabel.Font = Enum.Font.GothamBold
versionLabel.TextSize = 11
versionLabel.Parent = header

local versionCorner = Instance.new("UICorner")
versionCorner.CornerRadius = UDim.new(0, 5)
versionCorner.Parent = versionLabel

-- Content Container
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, 0, 1, -48)
content.Position = UDim2.new(0, 0, 0, 48)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.Parent = content

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 10)
contentPadding.PaddingBottom = UDim.new(0, 10)
contentPadding.Parent = content

-- Button Creator Function
local function createButton(text, callback, color, parent)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 260, 0, 45)
    button.BackgroundColor3 = color or Color3.fromRGB(25, 25, 30)
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.Parent = parent or content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    local status = Instance.new("Frame")
    status.Size = UDim2.new(0, 35, 0, 24)
    status.Position = UDim2.new(1, -45, 0.5, -12)
    status.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    status.BorderSizePixel = 0
    status.Parent = button
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = status
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "OFF"
    statusText.TextColor3 = Color3.fromRGB(180, 180, 190)
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 11
    statusText.Parent = status
    
    button.MouseButton1Click:Connect(function()
        callback(button, label, status, statusText)
    end)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color or Color3.fromRGB(25, 25, 30)}):Play()
    end)
    
    return button, label, status, statusText
end

-- Section Creator
local function createSection(title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(0, 260, 0, 25)
    section.BackgroundTransparency = 1
    section.Parent = content
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Size = UDim2.new(1, 0, 1, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = title
    sectionLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextSize = 12
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = section
    
    return section
end

-- Info Panel
local infoPanel = Instance.new("Frame")
infoPanel.Size = UDim2.new(0, 260, 0, 90)
infoPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
infoPanel.BorderSizePixel = 0
infoPanel.Parent = content

local infoPanelCorner = Instance.new("UICorner")
infoPanelCorner.CornerRadius = UDim.new(0, 10)
infoPanelCorner.Parent = infoPanel

local infoLayout = Instance.new("UIListLayout")
infoLayout.Padding = UDim.new(0, 5)
infoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
infoLayout.Parent = infoPanel

local infoPadding = Instance.new("UIPadding")
infoPadding.PaddingTop = UDim.new(0, 8)
infoPadding.PaddingBottom = UDim.new(0, 8)
infoPadding.Parent = infoPanel

local targetNameLabel = Instance.new("TextLabel")
targetNameLabel.Size = UDim2.new(0, 240, 0, 20)
targetNameLabel.BackgroundTransparency = 1
targetNameLabel.Text = "Target: None"
targetNameLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
targetNameLabel.Font = Enum.Font.GothamMedium
targetNameLabel.TextSize = 13
targetNameLabel.Parent = infoPanel

local healthLabel = Instance.new("TextLabel")
healthLabel.Size = UDim2.new(0, 240, 0, 20)
healthLabel.BackgroundTransparency = 1
healthLabel.Text = "Health: -"
healthLabel.TextColor3 = Color3.fromRGB(255, 180, 180)
healthLabel.Font = Enum.Font.GothamMedium
healthLabel.TextSize = 12
healthLabel.Parent = infoPanel

local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(0, 240, 0, 20)
distanceLabel.BackgroundTransparency = 1
distanceLabel.Text = "Distance: -"
distanceLabel.TextColor3 = Color3.fromRGB(255, 220, 180)
distanceLabel.Font = Enum.Font.GothamMedium
distanceLabel.TextSize = 12
distanceLabel.Parent = infoPanel

local accuracyLabel = Instance.new("TextLabel")
accuracyLabel.Size = UDim2.new(0, 240, 0, 20)
accuracyLabel.BackgroundTransparency = 1
accuracyLabel.Text = "Accuracy: 100%"
accuracyLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
accuracyLabel.Font = Enum.Font.GothamMedium
accuracyLabel.TextSize = 12
accuracyLabel.Parent = infoPanel

-- Toggle Lock Button (Floating)
local lockButton = Instance.new("TextButton")
lockButton.Size = UDim2.new(0, 70, 0, 70)
lockButton.Position = UDim2.new(0.5, -35, 0.8, -35)
lockButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
lockButton.BorderSizePixel = 0
lockButton.Text = ""
lockButton.Active = true
lockButton.Draggable = true
lockButton.Visible = false
lockButton.Parent = screenGui

local lockButtonCorner = Instance.new("UICorner")
lockButtonCorner.CornerRadius = UDim.new(0, 12)
lockButtonCorner.Parent = lockButton

local lockButtonShadow = Instance.new("ImageLabel")
lockButtonShadow.Size = UDim2.new(1, 30, 1, 30)
lockButtonShadow.Position = UDim2.new(0, -15, 0, -15)
lockButtonShadow.BackgroundTransparency = 1
lockButtonShadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
lockButtonShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
lockButtonShadow.ImageTransparency = 0.4
lockButtonShadow.ScaleType = Enum.ScaleType.Slice
lockButtonShadow.SliceCenter = Rect.new(10, 10, 118, 118)
lockButtonShadow.ZIndex = 0
lockButtonShadow.Parent = lockButton

local lockIcon = Instance.new("TextLabel")
lockIcon.Size = UDim2.new(1, 0, 0.6, 0)
lockIcon.Position = UDim2.new(0, 0, 0, 5)
lockIcon.BackgroundTransparency = 1
lockIcon.Text = "L"
lockIcon.TextColor3 = Color3.fromRGB(180, 180, 190)
lockIcon.Font = Enum.Font.GothamBold
lockIcon.TextSize = 32
lockIcon.Parent = lockButton

local lockStatus = Instance.new("TextLabel")
lockStatus.Size = UDim2.new(1, 0, 0.3, 0)
lockStatus.Position = UDim2.new(0, 0, 0.65, 0)
lockStatus.BackgroundTransparency = 1
lockStatus.Text = "LOCK"
lockStatus.TextColor3 = Color3.fromRGB(150, 150, 160)
lockStatus.Font = Enum.Font.GothamBold
lockStatus.TextSize = 11
lockStatus.Parent = lockButton

-- Lock Button Logic
local isLocked = false
lockButton.MouseButton1Click:Connect(function()
    isLocked = not isLocked
    
    local targetColor = isLocked and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(25, 25, 30)
    local iconColor = isLocked and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(180, 180, 190)
    
    TweenService:Create(lockButton, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        BackgroundColor3 = targetColor,
        Size = UDim2.new(0, 75, 0, 75)
    }):Play()
    
    TweenService:Create(lockIcon, TweenInfo.new(0.2), {
        TextColor3 = iconColor
    }):Play()
    
    task.wait(0.1)
    TweenService:Create(lockButton, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 70, 0, 70)
    }):Play()
    
    lockStatus.Text = isLocked and "LOCKED" or "LOCK"
    lockStatus.TextColor3 = iconColor
    
    if isLocked then
        sendNotification("LOCK ACTIVATED", "Target locked via button", Color3.fromRGB(100, 255, 150))
    else
        sendNotification("LOCK DEACTIVATED", "Lock released", Color3.fromRGB(255, 100, 100))
    end
end)

-- Main Controls Section
createSection("MAIN CONTROLS")

local camlockBtn = createButton("Camlock", function(btn, label, status, statusText)
    Settings.camlockEnabled = not Settings.camlockEnabled
    statusText.Text = Settings.camlockEnabled and "ON" or "OFF"
    statusText.TextColor3 = Settings.camlockEnabled and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(180, 180, 190)
    TweenService:Create(status, TweenInfo.new(0.2), {
        BackgroundColor3 = Settings.camlockEnabled and Color3.fromRGB(40, 80, 50) or Color3.fromRGB(35, 35, 40)
    }):Play()
    
    if Settings.camlockEnabled then
        sendNotification("CAMLOCK ENABLED", "Camera lock system activated", Color3.fromRGB(100, 255, 150))
    else
        TargetData.current = nil
        sendNotification("CAMLOCK DISABLED", "System deactivated", Color3.fromRGB(255, 100, 100))
    end
end)

local silentAimBtn = createButton("Silent Aim", function(btn, label, status, statusText)
    Settings.silentAimEnabled = not Settings.silentAimEnabled
    statusText.Text = Settings.silentAimEnabled and "ON" or "OFF"
    statusText.TextColor3 = Settings.silentAimEnabled and Color3.fromRGB(255, 150, 255) or Color3.fromRGB(180, 180, 190)
    TweenService:Create(status, TweenInfo.new(0.2), {
        BackgroundColor3 = Settings.silentAimEnabled and Color3.fromRGB(80, 40, 80) or Color3.fromRGB(35, 35, 40)
    }):Play()
    
    if Settings.silentAimEnabled then
        sendNotification("SILENT AIM ENABLED", "Bullets redirect to target anywhere", Color3.fromRGB(255, 150, 255))
    else
        sendNotification("SILENT AIM DISABLED", "System deactivated", Color3.fromRGB(255, 100, 100))
    end
end)

local lockButtonToggleBtn = createButton("Toggle Lock Button", function(btn, label, status, statusText)
    Settings.lockButtonEnabled = not Settings.lockButtonEnabled
    statusText.Text = Settings.lockButtonEnabled and "ON" or "OFF"
    statusText.TextColor3 = Settings.lockButtonEnabled and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(180, 180, 190)
    TweenService:Create(status, TweenInfo.new(0.2), {
        BackgroundColor3 = Settings.lockButtonEnabled and Color3.fromRGB(40, 60, 80) or Color3.fromRGB(35, 35, 40)
    }):Play()
    
    lockButton.Visible = Settings.lockButtonEnabled
    
    if Settings.lockButtonEnabled then
        sendNotification("LOCK BUTTON ENABLED", "Drag and tap to lock target", Color3.fromRGB(100, 200, 255))
    else
        isLocked = false
        lockStatus.Text = "LOCK"
        sendNotification("LOCK BUTTON DISABLED", "Button hidden", Color3.fromRGB(255, 100, 100))
    end
end)

-- Target Settings Section
createSection("TARGET SETTINGS")

local targetParts = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso", "Torso"}
local currentPartIndex = 1

local targetPartBtn = createButton("Target: Head", function(btn, label, status, statusText)
    currentPartIndex = currentPartIndex % #targetParts + 1
    Settings.targetPart = targetParts[currentPartIndex]
    label.Text = "Target: " .. Settings.targetPart
    statusText.Text = string.sub(Settings.targetPart, 1, 3):upper()
    sendNotification("TARGET CHANGED", "Now targeting " .. Settings.targetPart, Color3.fromRGB(100, 200, 255))
end)

local autoSwitchBtn = createButton("Auto Switch", function(btn, label, status, statusText)
    Settings.autoSwitch = not Settings.autoSwitch
    statusText.Text = Settings.autoSwitch and "ON" or "OFF"
    statusText.TextColor3 = Settings.autoSwitch and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(180, 180, 190)
    TweenService:Create(status, TweenInfo.new(0.2), {
        BackgroundColor3 = Settings.autoSwitch and Color3.fromRGB(40, 80, 50) or Color3.fromRGB(35, 35, 40)
    }):Play()
end)

local wallCheckBtn = createButton("Wall Check", function(btn, label, status, statusText)
    Settings.wallCheck = not Settings.wallCheck
    statusText.Text = Settings.wallCheck and "ON" or "OFF"
    statusText.TextColor3 = Settings.wallCheck and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(180, 180, 190)
    TweenService:Create(status, TweenInfo.new(0.2), {
        BackgroundColor3 = Settings.wallCheck and Color3.fromRGB(40, 80, 50) or Color3.fromRGB(35, 35, 40)
    }):Play()
end)

-- Visual Settings Section
createSection("VISUAL SETTINGS")

local fovBtn = createButton("FOV Circle", function(btn, label, status, statusText)
    Settings.showFOV = not Settings.showFOV
    statusText.Text = Settings.showFOV and "ON" or "OFF"
    statusText.TextColor3 = Settings.showFOV and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(180, 180, 190)
    TweenService:Create(status, TweenInfo.new(0.2), {
        BackgroundColor3 = Settings.showFOV and Color3.fromRGB(40, 80, 50) or Color3.fromRGB(35, 35, 40)
    }):Play()
end)

local tracerBtn = createButton("Target Tracer", function(btn, label, status, statusText)
    Settings.showTracers = not Settings.showTracers
    statusText.Text = Settings.showTracers and "ON" or "OFF"
    statusText.TextColor3 = Settings.showTracers and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(180, 180, 190)
    TweenService:Create(status, TweenInfo.new(0.2), {
        BackgroundColor3 = Settings.showTracers and Color3.fromRGB(40, 80, 50) or Color3.fromRGB(35, 35, 40)
    }):Play()
end)

local notifBtn = createButton("Notifications", function(btn, label, status, statusText)
    Settings.showNotifications = not Settings.showNotifications
    statusText.Text = Settings.showNotifications and "ON" or "OFF"
    statusText.TextColor3 = Settings.showNotifications and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(180, 180, 190)
    TweenService:Create(status, TweenInfo.new(0.2), {
        BackgroundColor3 = Settings.showNotifications and Color3.fromRGB(40, 80, 50) or Color3.fromRGB(35, 35, 40)
    }):Play()
end)

-- Notification System
local notificationContainer = Instance.new("Frame")
notificationContainer.Size = UDim2.new(0, 320, 1, -20)
notificationContainer.Position = UDim2.new(1, -330, 0, 10)
notificationContainer.BackgroundTransparency = 1
notificationContainer.Parent = screenGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.Padding = UDim.new(0, 8)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.Parent = notificationContainer

function sendNotification(title, message, color)
    if not Settings.showNotifications then return end
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = notificationContainer
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notif
    
    local notifShadow = Instance.new("ImageLabel")
    notifShadow.Size = UDim2.new(1, 30, 1, 30)
    notifShadow.Position = UDim2.new(0, -15, 0, -15)
    notifShadow.BackgroundTransparency = 1
    notifShadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    notifShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    notifShadow.ImageTransparency = 0.6
    notifShadow.ScaleType = Enum.ScaleType.Slice
    notifShadow.SliceCenter = Rect.new(10, 10, 118, 118)
    notifShadow.ZIndex = -1
    notifShadow.Parent = notif
    
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.BackgroundColor3 = color or Color3.fromRGB(88, 101, 242)
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notif
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 22)
    titleLabel.Position = UDim2.new(0, 15, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 18)
    messageLabel.Position = UDim2.new(0, 15, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 11
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = notif
    
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, -10, 0, 2)
    progressBg.Position = UDim2.new(0, 5, 1, -6)
    progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = notif
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = color or Color3.fromRGB(88, 101, 242)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg
    
    local expandTween = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, 60)
    })
    expandTween:Play()
    
    local progressTween = TweenService:Create(progressBar, TweenInfo.new(3.5, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    })
    
    expandTween.Completed:Connect(function()
        progressTween:Play()
    end)
    
    task.delay(3.5, function()
        local fadeTween = TweenService:Create(notif, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        })
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            notif:Destroy()
        end)
    end)
end

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Radius = Settings.fovRadius
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(88, 101, 242)
fovCircle.Transparency = 0.8

-- Target Tracer
local targetLine = Drawing.new("Line")
targetLine.Thickness = 2
targetLine.Visible = false
targetLine.Color = Color3.fromRGB(255, 100, 150)
targetLine.Transparency = 0.7

-- Update FOV Circle
RunService.Heartbeat:Connect(function()
    if Settings.showFOV and (Settings.camlockEnabled or Settings.silentAimEnabled or isLocked) then
        local viewportSize = Camera.ViewportSize
        fovCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
        fovCircle.Radius = Settings.fovRadius
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end)

-- Wall Check Function
local function isWallBetween(origin, target)
    if not Settings.wallCheck then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, target.Parent}
    raycastParams.IgnoreWater = true
    
    local rayResult = Workspace:Raycast(origin, (target.Position - origin), raycastParams)
    return rayResult ~= nil
end

-- Get Valid Target
local lastTargetName = nil
local function getValidTarget()
    if TargetData.current and TargetData.current.Parent and TargetData.current:IsDescendantOf(Workspace) then
        local humanoid = TargetData.current.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local distance = (myChar.HumanoidRootPart.Position - TargetData.current.Position).Magnitude
                if distance <= Settings.maxLockDistance then
                    if not isWallBetween(Camera.CFrame.Position, TargetData.current) then
                        return TargetData.current
                    end
                end
            end
        end
        
        if not Settings.autoSwitch then
            return TargetData.current
        end
    end

    local closestPart = nil
    local closestDistance = math.huge
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local myChar = LocalPlayer.Character
    
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local targetBodyPart = character:FindFirstChild(Settings.targetPart)
            
            if not targetBodyPart then
                targetBodyPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
            end
            
            if humanoid and humanoid.Health > 0 and targetBodyPart then
                local worldDist = (myChar.HumanoidRootPart.Position - targetBodyPart.Position).Magnitude
                
                if worldDist <= Settings.maxLockDistance then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetBodyPart.Position)
                    
                    if onScreen then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        
                        if screenDist < Settings.fovRadius then
                            if not isWallBetween(Camera.CFrame.Position, targetBodyPart) then
                                if screenDist < closestDistance then
                                    closestDistance = screenDist
                                    closestPart = targetBodyPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if closestPart and closestPart.Parent then
        local newTargetName = closestPart.Parent.Name
        if newTargetName ~= lastTargetName then
            lastTargetName = newTargetName
            TargetData.lockTime = tick()
            
            local humanoid = closestPart.Parent:FindFirstChildOfClass("Humanoid")
            local health = humanoid and math.floor(humanoid.Health) or 0
            local distance = math.floor((myChar.HumanoidRootPart.Position - closestPart.Position).Magnitude)
            
            sendNotification(
                "TARGET LOCKED",
                string.format("%s | %d HP | %d studs", newTargetName, health, distance),
                Color3.fromRGB(255, 180, 100)
            )
        end
    else
        lastTargetName = nil
    end

    TargetData.current = closestPart
    return closestPart
end

-- Calculate Prediction
local function calculatePrediction(velocity, distance)
    if not Settings.autoPrediction then
        return Vector3.new(
            velocity.X * Settings.horizontalPrediction,
            velocity.Y * Settings.verticalPrediction,
            velocity.Z * Settings.horizontalPrediction
        )
    end
    
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    local bulletSpeed = 1000
    local travelTime = distance / bulletSpeed
    local predictionTime = travelTime + ping
    
    return Vector3.new(
        velocity.X * predictionTime * 0.8,
        velocity.Y * predictionTime * 0.6,
        velocity.Z * predictionTime * 0.8
    )
end

-- Main Lock Loop
local lastTargetPosition = nil
RunService.Heartbeat:Connect(function(deltaTime)
    local currentTime = tick()
    if currentTime - lastUpdate < UPDATE_INTERVAL then return end
    lastUpdate = currentTime
    
    local shouldLock = Settings.camlockEnabled or isLocked
    
    if not shouldLock then
        targetLine.Visible = false
        targetNameLabel.Text = "Target: None"
        healthLabel.Text = "Health: -"
        distanceLabel.Text = "Distance: -"
        return
    end

    local part = getValidTarget()
    
    if part and part.Parent then
        local character = part.Parent
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if hrp and humanoid and humanoid.Health > 0 then
            local velocity = hrp.AssemblyLinearVelocity or hrp.Velocity
            local myChar = LocalPlayer.Character
            
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local distance = (myChar.HumanoidRootPart.Position - part.Position).Magnitude
                local predictionOffset = calculatePrediction(velocity, distance)
                local predictedPosition = part.Position + predictionOffset
                
                -- Anti-aim abuse detection
                if Settings.antiAimAbuse then
                    if lastTargetPosition then
                        local movementDelta = (predictedPosition - lastTargetPosition).Magnitude
                        if movementDelta > 50 then
                            predictedPosition = part.Position
                        end
                    end
                    lastTargetPosition = predictedPosition
                end
                
                -- Shake for camlock only
                local shakeOffset = Vector3.zero
                if Settings.camlockEnabled or isLocked then
                    shakeOffset = Vector3.new(
                        (math.random() - 0.5) * Settings.shakeIntensity,
                        (math.random() - 0.5) * Settings.shakeIntensity,
                        (math.random() - 0.5) * Settings.shakeIntensity
                    )
                end

                -- Apply lock
                if Settings.camlockEnabled or isLocked then
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, predictedPosition + shakeOffset)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.camlockSmoothness)
                end
                
                -- Update tracer
                if Settings.showTracers then
                    local screenPos = Camera:WorldToViewportPoint(part.Position)
                    local viewportSize = Camera.ViewportSize
                    targetLine.From = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                    targetLine.To = Vector2.new(screenPos.X, screenPos.Y)
                    targetLine.Visible = true
                    targetLine.Color = Settings.silentAimEnabled and Color3.fromRGB(255, 100, 255) or Color3.fromRGB(88, 101, 242)
                else
                    targetLine.Visible = false
                end
                
                -- Update UI
                local health = math.floor(humanoid.Health)
                local maxHealth = math.floor(humanoid.MaxHealth)
                local distValue = math.floor(distance)
                local accuracy = TargetData.hitCount + TargetData.missCount > 0 
                    and math.floor((TargetData.hitCount / (TargetData.hitCount + TargetData.missCount)) * 100) 
                    or 100
                
                targetNameLabel.Text = "Target: " .. character.Name
                healthLabel.Text = string.format("Health: %d / %d HP", health, maxHealth)
                distanceLabel.Text = string.format("Distance: %d studs", distValue)
                accuracyLabel.Text = string.format("Accuracy: %d%%", accuracy)
                
                -- Health bar color
                local healthPercent = health / maxHealth
                if healthPercent > 0.6 then
                    healthLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
                elseif healthPercent > 0.3 then
                    healthLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                else
                    healthLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            end
        end
    else
        targetLine.Visible = false
        targetNameLabel.Text = "Target: None"
        healthLabel.Text = "Health: -"
        distanceLabel.Text = "Distance: -"
        lastTargetPosition = nil
    end
end)

local mt = getrawmetatable(game)
local old_namecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Settings.silentAimEnabled and (method == "FireServer" or method == "InvokeServer") then
        local part = getValidTarget()
        if part and part.Parent then
            local hrp = part.Parent:FindFirstChild("HumanoidRootPart")
            if hrp then
                local velocity = hrp.AssemblyLinearVelocity or hrp.Velocity
                local myChar = LocalPlayer.Character
                
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    local distance = (myChar.HumanoidRootPart.Position - part.Position).Magnitude
                    local predictionOffset = calculatePrediction(velocity, distance)
                    local targetPosition = part.Position + predictionOffset
                    
                    -- Replace any Vector3 argument with target position
                    for i, v in ipairs(args) do
                        if typeof(v) == "Vector3" then
                            args[i] = targetPosition
                            TargetData.hitCount = TargetData.hitCount + 1
                            break
                        elseif typeof(v) == "CFrame" then
                            args[i] = CFrame.new(targetPosition)
                            TargetData.hitCount = TargetData.hitCount + 1
                            break
                        elseif typeof(v) == "Instance" and v:IsA("BasePart") then
                            -- Some games pass the part itself
                            args[i] = part
                            TargetData.hitCount = TargetData.hitCount + 1
                            break
                        end
                    end
                end
            end
        else
            TargetData.missCount = TargetData.missCount + 1
        end
    end
    
    return old_namecall(unpack(args))
end)

setreadonly(mt, true)

-- Character Reset Handler
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    Camera = Workspace.CurrentCamera
    TargetData.current = nil
    TargetData.hitCount = 0
    TargetData.missCount = 0
end)

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -35, 0, 7.5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeBtn

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    minimizeBtn.Text = isMinimized and "+" or "-"
    
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = isMinimized and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 420)
    }):Play()
    
    content.Visible = not isMinimized
    accentLine.Visible = not isMinimized
end)

-- Startup
task.wait(0.5)
sendNotification("SYSTEM LOADED", "Advanced Lock v3.5 - Tap lock button when enabled", Color3.fromRGB(100, 255, 100))
