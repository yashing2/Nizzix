-- LocalScript placed in StarterPlayerScripts

local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local targetPlayer = nil
local continuousTeleport = false
local teleporting = false
local guiVisible = true
local snowflakes = {}

-- Create GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui", players.LocalPlayer:WaitForChild("PlayerGui"))
    screenGui.DisplayOrder = 999 -- Ensure the GUI is always on top
    screenGui.ResetOnSpawn = false -- Ensure the GUI persists across map changes

    local darkenBackground = Instance.new("Frame", screenGui)
    darkenBackground.Size = UDim2.new(1, 0, 1, 0)
    darkenBackground.Position = UDim2.new(0, 0, 0, 0)
    darkenBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    darkenBackground.BackgroundTransparency = 0.7
    darkenBackground.Visible = false

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0.2, 0, 0.35, 0)
    frame.Position = UDim2.new(0.4, 0, 0.325, 0)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true

    local uiCorner = Instance.new("UICorner", frame)
    uiCorner.CornerRadius = UDim.new(0, 15)

    local uiStroke = Instance.new("UIStroke", frame)
    uiStroke.Thickness = 2
    uiStroke.Color = Color3.fromRGB(0, 0, 0)
    uiStroke.Transparency = 0.5

    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "Teleport to Player"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSans
    titleLabel.TextSize = 18

    local titleCorner = Instance.new("UICorner", titleLabel)
    titleCorner.CornerRadius = UDim.new(0, 15)

    local playerDropdown = Instance.new("TextButton", frame)
    playerDropdown.Size = UDim2.new(0.8, 0, 0.15, 0)
    playerDropdown.Position = UDim2.new(0.1, 0, 0.25, 0)
    playerDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    playerDropdown.BorderSizePixel = 0
    playerDropdown.Text = "Select Player"
    playerDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerDropdown.Font = Enum.Font.SourceSans
    playerDropdown.TextSize = 14

    local teleportButton = Instance.new("TextButton", frame)
    teleportButton.Size = UDim2.new(0.8, 0, 0.15, 0)
    teleportButton.Position = UDim2.new(0.1, 0, 0.45, 0)
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    teleportButton.BorderSizePixel = 0
    teleportButton.Text = "Teleport"
    teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportButton.Font = Enum.Font.SourceSans
    teleportButton.TextSize = 14

    local toggleButton = Instance.new("TextButton", frame)
    toggleButton.Size = UDim2.new(0.8, 0, 0.15, 0)
    toggleButton.Position = UDim2.new(0.1, 0, 0.65, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "Toggle Continuous TP"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.SourceSans
    toggleButton.TextSize = 14

    return screenGui, darkenBackground, playerDropdown, teleportButton, toggleButton
end

local screenGui, darkenBackground, playerDropdown, teleportButton, toggleButton = createGUI()

local function updateDropdown()
    playerDropdown.Text = "Select Player"
    local dropdownMenu = Instance.new("Frame", playerDropdown)
    dropdownMenu.Size = UDim2.new(1, 0, 5, 0)
    dropdownMenu.Position = UDim2.new(0, 0, 1, 0)
    dropdownMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dropdownMenu.BorderSizePixel = 0
    dropdownMenu.Visible = false
    dropdownMenu.ZIndex = 2 -- Ensure the dropdown menu is on top

    local uiListLayout = Instance.new("UIListLayout", dropdownMenu)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    for _, player in pairs(players:GetPlayers()) do
        if player ~= players.LocalPlayer then
            local playerButton = Instance.new("TextButton", dropdownMenu)
            playerButton.Size = UDim2.new(1, 0, 0, 30)
            playerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            playerButton.BorderSizePixel = 0
            playerButton.Text = player.Name
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.Font = Enum.Font.SourceSans
            playerButton.TextSize = 14
            playerButton.ZIndex = 2 -- Ensure the player buttons are on top

            playerButton.MouseButton1Click:Connect(function()
                targetPlayer = player
                playerDropdown.Text = player.Name
                dropdownMenu.Visible = false
            end)
        end
    end

    playerDropdown.MouseButton1Click:Connect(function()
        dropdownMenu.Visible = not dropdownMenu.Visible
    end)
end

updateDropdown()

local function teleportToPlayer()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
        players.LocalPlayer.Character:MoveTo(targetPosition)
        local humanoidRootPart = players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, targetPlayer.Character.HumanoidRootPart.Position)
        end
    end
end

teleportButton.MouseButton1Click:Connect(teleportToPlayer)

toggleButton.MouseButton1Click:Connect(function()
    continuousTeleport = not continuousTeleport
    toggleButton.Text = continuousTeleport and "Continuous TP: ON" or "Continuous TP: OFF"
end)

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.E then
            teleportToPlayer()
        elseif input.KeyCode == Enum.KeyCode.R and continuousTeleport then
            teleporting = true
            -- Move the view downwards
            local humanoid = players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.CameraOffset = Vector3.new(0, -humanoid.CameraOffset.Y, 0)
            end
        elseif input.KeyCode == Enum.KeyCode.Insert then
            guiVisible = not guiVisible
            screenGui.Enabled = guiVisible
            darkenBackground.Visible = guiVisible
            userInputService.MouseBehavior = guiVisible and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
            if guiVisible then
                createSnowEffect()
            else
                clearSnowEffect()
            end
        end
    end
end)

userInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.R then
        teleporting = false
    end
end)

runService.RenderStepped:Connect(function()
    if teleporting and continuousTeleport then
        teleportToPlayer()
    end
end)

-- Snow effect
local function createSnowflake()
    local snowflake = Instance.new("ImageLabel", screenGui)
    snowflake.Size = UDim2.new(0, 10, 0, 10)
    snowflake.Image = "rbxassetid://6071575925" -- Snowflake image
    snowflake.BackgroundTransparency = 1
    snowflake.Position = UDim2.new(math.random(), 0, -0.1, 0)
    snowflake.ZIndex = 1001

    local tween = tweenService:Create(snowflake, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Position = UDim2.new(math.random(), 0, 1.1, 0)})
    tween:Play()

    tween.Completed:Connect(function()
        snowflake:Destroy()
    end)

    table.insert(snowflakes, snowflake)
end

local function createSnowEffect()
    for i = 1, 50 do
        createSnowflake()
    end
end

local function clearSnowEffect()
    for _, snowflake in ipairs(snowflakes) do
        snowflake:Destroy()
    end
    snowflakes = {}
end
