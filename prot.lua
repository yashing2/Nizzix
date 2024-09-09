local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Holding = false
-- Variables Globales
_G.AimbotEnabled = false
_G.ESPEnabled = false
_G.TeamCheck = false
_G.AimPart = "Head"
_G.Sensitivity = 0.1
_G.FOVRadius = 100
_G.MinDistance = 10 -- Distance minimale en mètres
_G.MaxDistance = 300 -- Distance maximale en mètres
_G.JumpHeight = 50 -- Hauteur de saut pour infinite jump
_G.InfiniteJumpEnabled = true -- Activer/Désactiver le saut infini

-- Interface Utilisateur (GUI)
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local MainFrame = Instance.new("Frame")

ScreenGui.Name = "AimbotGUI"
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Titre
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Text = "Aimbot & ESP Settings"
Title.Font = Enum.Font.SourceSans
Title.TextSize = 24
Title.Parent = MainFrame

-- Boutons
local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Size = UDim2.new(0, 200, 0, 50)
AimbotToggle.Position = UDim2.new(0.5, -100, 0, 60)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
AimbotToggle.TextColor3 = Color3.new(1, 1, 1)
AimbotToggle.Text = "Toggle Aimbot"
AimbotToggle.Font = Enum.Font.SourceSans
AimbotToggle.TextSize = 18
AimbotToggle.Parent = MainFrame

-- Slider pour le FOV du cercle
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0, 200, 0, 50)
FOVLabel.Position = UDim2.new(0.5, -100, 0, 180)
FOVLabel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
FOVLabel.TextColor3 = Color3.new(1, 1, 1)
FOVLabel.Text = "FOV: " .. tostring(_G.FOVRadius)
FOVLabel.Font = Enum.Font.SourceSans
FOVLabel.TextSize = 18
FOVLabel.Parent = MainFrame

local FOVSlider = Instance.new("Frame")
FOVSlider.Size = UDim2.new(0, 200, 0, 10)
FOVSlider.Position = UDim2.new(0.5, -100, 0, 230)
FOVSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
FOVSlider.Parent = MainFrame

local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(1, 0, 1, 0)
SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderBar.Parent = FOVSlider

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
SliderFill.Parent = SliderBar

local SliderButton = Instance.new("Frame")
SliderButton.Size = UDim2.new(0, 10, 0, 10)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
SliderButton.Parent = SliderBar

-- Nouveau bouton pour le saut infini
local InfiniteJumpToggle = Instance.new("TextButton")
InfiniteJumpToggle.Size = UDim2.new(0, 200, 0, 50)
InfiniteJumpToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
InfiniteJumpToggle.TextColor3 = Color3.new(1, 1, 1)
InfiniteJumpToggle.Text = "Toggle Infinite Jump"
InfiniteJumpToggle.Position = UDim2.new(0.5, -100, 0, 250)
InfiniteJumpToggle.Font = Enum.Font.SourceSans
InfiniteJumpToggle.TextSize = 18
InfiniteJumpToggle.Parent = MainFrame

-- Fonction pour obtenir le joueur le plus proche
local function GetClosestPlayer()
    local MaximumDistance = math.huge
    local Target = nil
    local MouseLocation = UserInputService:GetMouseLocation()

    for _, v in next, Players:GetPlayers() do
        if v ~= LocalPlayer then
            if _G.TeamCheck == false or (v.Team ~= LocalPlayer.Team) then
                if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid").Health > 0 then
                    local TargetPart = v.Character:FindFirstChild(_G.AimPart)
                    if TargetPart then
                        local ScreenPoint = Camera:WorldToScreenPoint(TargetPart.Position)
                        local Distance = (Vector2.new(MouseLocation.X, MouseLocation.Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

                        -- Calculer la distance réelle du joueur
                        local PlayerDistance = (Camera.CFrame.Position - TargetPart.Position).Magnitude

                        -- Vérifier si le joueur est dans la plage de distance et le FOV
                        if PlayerDistance >= _G.MinDistance and PlayerDistance <= _G.MaxDistance and Distance < _G.FOVRadius then
                            if Distance < MaximumDistance then
                                Target = v
                                MaximumDistance = Distance
                            end
                        end
                    end
                end
            end
        end
    end

    return Target
end

-- Fonction pour déplacer la souris vers la cible avec un ajustement de la position et sans recul constant
local function MoveMouseToTarget(Target)
    if Target and Target.Character and Target.Character:FindFirstChild(_G.AimPart) then
        local TargetPart = Target.Character[_G.AimPart]
        local AdjustedPosition = TargetPart.Position + Vector3.new(0, -1, 0) -- Ajuste ici -1 pour viser légèrement plus bas
        local TargetPosition = Camera:WorldToScreenPoint(AdjustedPosition)
        local MouseLocation = UserInputService:GetMouseLocation()

        -- Utilisation de la valeur du slider pour la compensation du recul
        local NoRecoilOffset = _G.NoRecoilOffset or Vector2.new(0, -5) -- Valeur par défaut si le slider n'est pas encore défini

        local MoveVector = (Vector2.new(TargetPosition.X, TargetPosition.Y) - MouseLocation + NoRecoilOffset) * _G.Sensitivity
        mousemoverel(MoveVector.X, MoveVector.Y)
    end
end

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Camera = game:GetService("Workspace").CurrentCamera

local function CreateESP(Player)
    -- Création des éléments ESP
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 105, 180)
    Box.Thickness = 3
    Box.Transparency = 1

    local NameLabel = Drawing.new("Text")
    NameLabel.Visible = false
    NameLabel.Color = Color3.fromRGB(255, 255, 255)
    NameLabel.Size = 15
    NameLabel.Center = true
    NameLabel.Outline = true

    local DistanceLabel = Drawing.new("Text")
    DistanceLabel.Visible = false
    DistanceLabel.Color = Color3.fromRGB(255, 255, 255)
    DistanceLabel.Size = 15
    DistanceLabel.Center = true
    DistanceLabel.Outline = true

    local HealthBarBackground = Drawing.new("Square")
    HealthBarBackground.Visible = false
    HealthBarBackground.Color = Color3.fromRGB(0, 0, 0)
    HealthBarBackground.Thickness = 1
    HealthBarBackground.Transparency = 0.5

    local HealthBar = Drawing.new("Square")
    HealthBar.Visible = false
    HealthBar.Color = Color3.fromRGB(0, 255, 0)
    HealthBar.Thickness = 1
    HealthBar.Transparency = 0.5

    local HealthText = Drawing.new("Text")
    HealthText.Visible = false
    HealthText.Color = Color3.fromRGB(255, 255, 255)
    HealthText.Size = 15
    HealthText.Center = true
    HealthText.Outline = true

    local WeaponLabel = Drawing.new("Text")
    WeaponLabel.Visible = false
    WeaponLabel.Color = Color3.fromRGB(255, 255, 255)
    WeaponLabel.Size = 15
    WeaponLabel.Center = true
    WeaponLabel.Outline = true

    local AmmoLabel = Drawing.new("Text")
    AmmoLabel.Visible = false
    AmmoLabel.Color = Color3.fromRGB(255, 255, 255)
    AmmoLabel.Size = 15
    AmmoLabel.Center = true
    AmmoLabel.Outline = true

    local Snapline = Drawing.new("Line")
    Snapline.Visible = false
    Snapline.Color = Color3.fromRGB(255, 105, 180)
    Snapline.Thickness = 1
    Snapline.Transparency = 1

    local DirectionArrow = Drawing.new("Triangle")
    DirectionArrow.Visible = false
    DirectionArrow.Color = Color3.fromRGB(255, 0, 0)
    DirectionArrow.Thickness = 1
    DirectionArrow.Transparency = 1

    local LevelLabel = Drawing.new("Text")
    LevelLabel.Visible = false
    LevelLabel.Color = Color3.fromRGB(255, 255, 0)
    LevelLabel.Size = 15
    LevelLabel.Center = true
    LevelLabel.Outline = true

    local LastActionLabel = Drawing.new("Text")
    LastActionLabel.Visible = false
    LastActionLabel.Color = Color3.fromRGB(255, 0, 0)
    LastActionLabel.Size = 15
    LastActionLabel.Center = true
    LastActionLabel.Outline = true

    local AccuracyIndicator = Drawing.new("Text")
    AccuracyIndicator.Visible = false
    AccuracyIndicator.Color = Color3.fromRGB(0, 255, 255)
    AccuracyIndicator.Size = 15
    AccuracyIndicator.Center = true
    AccuracyIndicator.Outline = true

    -- Texte global pour afficher le pseudo de chaque joueur visible
    local GlobalNameLabel = Drawing.new("Text")
    GlobalNameLabel.Visible = false
    GlobalNameLabel.Color = Color3.fromRGB(255, 255, 255)
    GlobalNameLabel.Size = 20
    GlobalNameLabel.Center = true
    GlobalNameLabel.Outline = true
    GlobalNameLabel.Position = Vector2.new(Camera.ViewportSize.X / 2, 20) -- Position en haut de l'écran

    local MaxDistance = 300

    local function UpdateBoxColor(distance)
        if distance <= 50 then
            return Color3.fromRGB(255, 0, 0)
        elseif distance <= 150 then
            return Color3.fromRGB(255, 165, 0)
        else
            return Color3.fromRGB(0, 255, 0)
        end
    end

    RunService.RenderStepped:Connect(function()
        local OnScreen, HeadPosition, HumanoidRootPosition
        local playerVisible = false
        local visiblePlayerName = ""

        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            HeadPosition, OnScreen = Camera:WorldToScreenPoint(Player.Character.Head.Position)
            HumanoidRootPosition, OnScreen = Camera:WorldToScreenPoint(Player.Character.HumanoidRootPart.Position)

            if OnScreen then
                playerVisible = true
                visiblePlayerName = Player.Name
                local PlayerDistance = (Camera.CFrame.Position - Player.Character.HumanoidRootPart.Position).Magnitude

                if PlayerDistance <= MaxDistance then
                    Box.Color = UpdateBoxColor(PlayerDistance)

                    local Character = Player.Character
                    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                    local Head = Character:FindFirstChild("Head")
                    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

                    if Humanoid and Head and HumanoidRootPart then
                        HeadPosition, OnScreenHead = Camera:WorldToScreenPoint(Head.Position)
                        HumanoidRootPosition, OnScreenRoot = Camera:WorldToScreenPoint(HumanoidRootPart.Position)

                        if OnScreenHead and OnScreenRoot then
                            local BoxWidth = 100
                            local BoxHeight = BoxWidth * 1.5

                            Box.Size = Vector2.new(BoxWidth, BoxHeight)
                            Box.Position = Vector2.new(HumanoidRootPosition.X - Box.Size.X / 2, HumanoidRootPosition.Y - Box.Size.Y / 2)
                            Box.Visible = true

                            NameLabel.Text = Player.Name
                            NameLabel.Position = Vector2.new(HumanoidRootPosition.X, HumanoidRootPosition.Y - BoxHeight / 2 - 80)
                            NameLabel.Visible = true

                            DistanceLabel.Text = string.format("Distance: %.2f", PlayerDistance)
                            DistanceLabel.Position = Vector2.new(HumanoidRootPosition.X, HumanoidRootPosition.Y - BoxHeight / 2 - 60)
                            DistanceLabel.Visible = true

                            if Humanoid then
                                local Health = Humanoid.Health
                                local MaxHealth = Humanoid.MaxHealth
                                local HealthRatio = Health / MaxHealth

                                HealthBarBackground.Size = Vector2.new(10 + 2, BoxHeight + 2)
                                HealthBarBackground.Position = Vector2.new(HumanoidRootPosition.X + BoxWidth / 2 + 5 - 1, HumanoidRootPosition.Y - BoxHeight / 2 - 1)
                                HealthBarBackground.Visible = true

                                HealthBar.Size = Vector2.new(10, BoxHeight * HealthRatio)
                                HealthBar.Position = Vector2.new(HumanoidRootPosition.X + BoxWidth / 2 + 5, HumanoidRootPosition.Y - BoxHeight / 2 + (BoxHeight - (BoxHeight * HealthRatio)) / 2)
                                HealthBar.Visible = true

                                HealthText.Text = string.format("Health: %d/%d", Health, MaxHealth)
                                HealthText.Position = Vector2.new(HumanoidRootPosition.X, HumanoidRootPosition.Y - BoxHeight / 2 - 40)
                                HealthText.Visible = true
                            else
                                HealthBarBackground.Visible = false
                                HealthBar.Visible = false
                                HealthText.Visible = false
                            end

                            local WeaponLabelText = "Weapon: N/A"
                            local AmmoLabelText = "Ammo: N/A"
                            local Backpack = Player.Backpack
                            local Weapon = Backpack:FindFirstChildOfClass("Tool")
                            if Weapon then
                                WeaponLabelText = "Weapon: " .. Weapon.Name
                                local Ammo = Weapon:FindFirstChild("Ammo")
                                if Ammo then
                                    AmmoLabelText = "Ammo: " .. tostring(Ammo.Value)
                                else
                                    AmmoLabelText = "Ammo: N/A"
                                end
                            else
                                WeaponLabelText = "Weapon: N/A"
                                AmmoLabelText = "Ammo: N/A"
                            end

                            WeaponLabel.Text = WeaponLabelText
                            WeaponLabel.Position = Vector2.new(HumanoidRootPosition.X + BoxWidth / 2 + 10, HumanoidRootPosition.Y - BoxHeight / 2 - 20)
                            WeaponLabel.Visible = true

                            AmmoLabel.Text = AmmoLabelText
                            AmmoLabel.Position = Vector2.new(HumanoidRootPosition.X + BoxWidth / 2 + 10, HumanoidRootPosition.Y - BoxHeight / 2 - 10)
                            AmmoLabel.Visible = true

                            Snapline.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            Snapline.To = Vector2.new(HumanoidRootPosition.X, HumanoidRootPosition.Y)
                            Snapline.Visible = true

                            if not OnScreenHead then
                                DirectionArrow.PointA = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                DirectionArrow.PointB = Vector2.new(Camera.ViewportSize.X / 2 - 15, Camera.ViewportSize.Y - 15)
                                DirectionArrow.PointC = Vector2.new(Camera.ViewportSize.X / 2 + 15, Camera.ViewportSize.Y - 15)
                                DirectionArrow.Visible = true
                            else
                                DirectionArrow.Visible = false
                            end

                            local ActivityText = "Activity: "
                            if Humanoid.MoveDirection.Magnitude > 0 then
                                ActivityText = ActivityText .. "Moving"
                            elseif Humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                                ActivityText = ActivityText .. "Jumping"
                            else
                                ActivityText = ActivityText .. "Idle"
                            end

                            LastActionLabel.Text = ActivityText
                            LastActionLabel.Position = Vector2.new(HumanoidRootPosition.X, HumanoidRootPosition.Y - BoxHeight / 2 + 10)
                            LastActionLabel.Visible = true

                            if Player:FindFirstChild("Level") then
                                LevelLabel.Text = "Level: " .. tostring(Player.Level.Value)
                                LevelLabel.Position = Vector2.new(HumanoidRootPosition.X, HumanoidRootPosition.Y - BoxHeight / 2 + 25)
                                LevelLabel.Visible = true
                            else
                                LevelLabel.Visible = false
                            end

                            -- Indicateur de Précision
                            local Accuracy = "Accuracy: N/A"
                            local Backpack = Player.Backpack
                            local Weapon = Backpack:FindFirstChildOfClass("Tool")
                            if Weapon then
                                local AccuracyStat = Weapon:FindFirstChild("Accuracy")
                                if AccuracyStat then
                                    Accuracy = "Accuracy: " .. tostring(AccuracyStat.Value)
                                end
                            end

                            AccuracyIndicator.Text = Accuracy
                            AccuracyIndicator.Position = Vector2.new(HumanoidRootPosition.X + BoxWidth / 2 + 10, HumanoidRootPosition.Y - BoxHeight / 2 + 45)
                            AccuracyIndicator.Visible = true

                        else
                            Box.Visible = false
                            NameLabel.Visible = false
                            DistanceLabel.Visible = false
                            HealthBarBackground.Visible = false
                            HealthBar.Visible = false
                            HealthText.Visible = false
                            WeaponLabel.Visible = false
                            AmmoLabel.Visible = false
                            Snapline.Visible = false
                            DirectionArrow.Visible = false
                            LastActionLabel.Visible = false
                            LevelLabel.Visible = false
                            AccuracyIndicator.Visible = false
                        end
                    else
                        Box.Visible = false
                        NameLabel.Visible = false
                        DistanceLabel.Visible = false
                        HealthBarBackground.Visible = false
                        HealthBar.Visible = false
                        HealthText.Visible = false
                        WeaponLabel.Visible = false
                        AmmoLabel.Visible = false
                        Snapline.Visible = false
                        DirectionArrow.Visible = false
                        LastActionLabel.Visible = false
                        LevelLabel.Visible = false
                        AccuracyIndicator.Visible = false
                    end
                else
                    Box.Visible = false
                    NameLabel.Visible = false
                    DistanceLabel.Visible = false
                    HealthBarBackground.Visible = false
                    HealthBar.Visible = false
                    HealthText.Visible = false
                    WeaponLabel.Visible = false
                    AmmoLabel.Visible = false
                    Snapline.Visible = false
                    DirectionArrow.Visible = false
                    LastActionLabel.Visible = false
                    LevelLabel.Visible = false
                    AccuracyIndicator.Visible = false
                end
            else
                Box.Visible = false
                NameLabel.Visible = false
                DistanceLabel.Visible = false
                HealthBarBackground.Visible = false
                HealthBar.Visible = false
                HealthText.Visible = false
                WeaponLabel.Visible = false
                AmmoLabel.Visible = false
                Snapline.Visible = false
                DirectionArrow.Visible = false
                LastActionLabel.Visible = false
                LevelLabel.Visible = false
                AccuracyIndicator.Visible = false
            end
        else
            Box.Visible = false
            NameLabel.Visible = false
            DistanceLabel.Visible = false
            HealthBarBackground.Visible = false
            HealthBar.Visible = false
            HealthText.Visible = false
            WeaponLabel.Visible = false
            AmmoLabel.Visible = false
            Snapline.Visible = false
            DirectionArrow.Visible = false
            LastActionLabel.Visible = false
            LevelLabel.Visible = false
            AccuracyIndicator.Visible = false
        end

        -- Mettre à jour le texte global si un joueur est visible
        if playerVisible then
            GlobalNameLabel.Text = visiblePlayerName
            GlobalNameLabel.Visible = true
        else
            GlobalNameLabel.Visible = false
        end
    end)
end





UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJumpEnabled then
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)


-- Application ESP
for _, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        CreateESP(v)
    end
end

InfiniteJumpToggle.MouseButton1Click:Connect(function()
    _G.InfiniteJumpEnabled = not _G.InfiniteJumpEnabled
    InfiniteJumpToggle.BackgroundColor3 = _G.InfiniteJumpEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(70, 70, 70)
end)

Players.PlayerAdded:Connect(function(Player)
    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
end)



-- Dessin du cercle de FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Radius = _G.FOVRadius
FOVCircle.Color = Color3.fromRGB(0, 255, 0)
FOVCircle.Transparency = 1
FOVCircle.Filled = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = _G.FOVRadius
    FOVCircle.Visible = _G.AimbotEnabled
end)

-- Fonction pour mettre à jour le FOV du cercle
local function UpdateFOV(mouseX)
    local SliderWidth = SliderBar.AbsoluteSize.X
    local MousePos = math.clamp(mouseX - SliderBar.AbsolutePosition.X, 0, SliderWidth)
    _G.FOVRadius = math.ceil((MousePos / SliderWidth) * 200)
    FOVLabel.Text = "FOV: " .. tostring(_G.FOVRadius)

    -- Mettre à jour le remplissage du slider
    SliderFill.Size = UDim2.new(MousePos / SliderWidth, 0, 1, 0)
    SliderButton.Position = UDim2.new(MousePos / SliderWidth - 0.05, 0, 0, 0) -- Ajuste pour centrer le bouton
end

-- Événements pour les sliders
SliderBar.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouseX = Input.Position.X
        UpdateFOV(mouseX)
        local dragging = true

        UserInputService.InputChanged:Connect(function(Input)
            if dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateFOV(Input.Position.X)
            end
        end)

        UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
end)

-- Détection des touches pour ouvrir/fermer l'ImGui
local GuiOpen = false

local function ToggleGui()
    GuiOpen = not GuiOpen
    MainFrame.Visible = GuiOpen
end

UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.Insert then
        ToggleGui()
    end
end)

-- Activer/Désactiver l'aimbot
AimbotToggle.MouseButton1Click:Connect(function()
    _G.AimbotEnabled = not _G.AimbotEnabled
end)

-- Activer/Désactiver l'ESP
ESPToggle.MouseButton1Click:Connect(function()
    _G.ESPEnabled = not _G.ESPEnabled
end)

-- L'aimbot verrouille la cible la plus proche dans le FOV
RunService.RenderStepped:Connect(function()
    if Holding and _G.AimbotEnabled then
        local Target = GetClosestPlayer()
        if Target then
            MoveMouseToTarget(Target)
        end
    end
end)

-- Détection du clic droit pour activer l'aimbot
UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
    end
end)
