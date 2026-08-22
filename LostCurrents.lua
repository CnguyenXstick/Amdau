local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Biến quản lý trạng thái
local scriptRunning = true
local flyOn, collectOn, espOn, espNpcOn, killAuraOn, noclipOn, brightOn = false, false, false, false, false, false, false

-- Lưu trạng thái Lighting ban đầu
local defaultAmbient = Lighting.Ambient
local defaultOutdoor = Lighting.OutdoorAmbient

-- Danh sách vật phẩm Auto Lụm & ESP
local LootNames = {
    ["Scrap"] = true, ["Gold"] = true, ["Chest"] = true, ["La bàn"] = true,
    ["Compass"] = true, ["Coin"] = true, ["Loot"] = true, ["Item"] = true, ["Treasure"] = true,
    ["Thùng"] = true, ["Thung"] = true, ["Barrel"] = true, ["Crate"] = true, ["Box"] = true,
    ["Dây"] = true, ["Day"] = true, ["Rope"] = true, ["String"] = true, ["Cable"] = true
}

-- Hàm Kéo Thả UI
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "StrawberryHub"
MainFrame.Size = UDim2.new(0, 220, 0, 330)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
MakeDraggable(MainFrame)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
task.spawn(function()
    while scriptRunning do
        for i = 0, 1, 0.05 do 
            if not scriptRunning then break end
            UIStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.1) 
        end
    end
end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "Strawberry / LostCurrents - by nguyen"
Title.Size = UDim2.new(0, 140, 0, 25)
Title.Position = UDim2.new(0.03, 0, 0.02, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 9
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Text = "-"
HideBtn.Size = UDim2.new(0, 22, 0, 22)
HideBtn.Position = UDim2.new(0.72, 0, 0.02, 0)
HideBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HideBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(0.86, 0, 0.02, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

local FloatBtn = Instance.new("ImageButton", ScreenGui)
FloatBtn.Name = "OpenButton"
FloatBtn.Size = UDim2.new(0, 45, 0, 45)
FloatBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FloatBtn.BackgroundTransparency = 0.3
FloatBtn.Image = "rbxassetid://88285387138547"
FloatBtn.Visible = false
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
MakeDraggable(FloatBtn)

local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Thickness = 2
task.spawn(function()
    while scriptRunning do
        for i = 0, 1, 0.05 do 
            if not scriptRunning then break end
            FloatStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.1) 
        end
    end
end)

HideBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; FloatBtn.Visible = true end)
FloatBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; FloatBtn.Visible = false end)

-- Nút Chuyển Tab (Main / Misc / TP)
local TabMainBtn = Instance.new("TextButton", MainFrame)
TabMainBtn.Text = "Main"
TabMainBtn.Size = UDim2.new(0.28, 0, 0, 22)
TabMainBtn.Position = UDim2.new(0.04, 0, 0.1, 0)
TabMainBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TabMainBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", TabMainBtn).CornerRadius = UDim.new(0, 4)

local TabMiscBtn = Instance.new("TextButton", MainFrame)
TabMiscBtn.Text = "Misc"
TabMiscBtn.Size = UDim2.new(0.28, 0, 0, 22)
TabMiscBtn.Position = UDim2.new(0.36, 0, 0.1, 0)
TabMiscBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabMiscBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
Instance.new("UICorner", TabMiscBtn).CornerRadius = UDim.new(0, 4)

local TabTPBtn = Instance.new("TextButton", MainFrame)
TabTPBtn.Text = "TP"
TabTPBtn.Size = UDim2.new(0.28, 0, 0, 22)
TabTPBtn.Position = UDim2.new(0.68, 0, 0.1, 0)
TabTPBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabTPBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
Instance.new("UICorner", TabTPBtn).CornerRadius = UDim.new(0, 4)

-- Container Các Tab
local MainContainer = Instance.new("Frame", MainFrame)
MainContainer.Size = UDim2.new(0.92, 0, 0.82, 0)
MainContainer.Position = UDim2.new(0.04, 0, 0.18, 0)
MainContainer.BackgroundTransparency = 1

local MiscContainer = Instance.new("Frame", MainFrame)
MiscContainer.Size = UDim2.new(0.92, 0, 0.82, 0)
MiscContainer.Position = UDim2.new(0.04, 0, 0.18, 0)
MiscContainer.BackgroundTransparency = 1
MiscContainer.Visible = false

local TPContainer = Instance.new("Frame", MainFrame)
TPContainer.Size = UDim2.new(0.92, 0, 0.82, 0)
TPContainer.Position = UDim2.new(0.04, 0, 0.18, 0)
TPContainer.BackgroundTransparency = 1
TPContainer.Visible = false

local function SetTab(activeBtn, activeContainer)
    MainContainer.Visible = false; MiscContainer.Visible = false; TPContainer.Visible = false
    TabMainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabMainBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    TabMiscBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabMiscBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    TabTPBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabTPBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)

    activeContainer.Visible = true
    activeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    activeBtn.TextColor3 = Color3.new(1, 1, 1)
end

TabMainBtn.MouseButton1Click:Connect(function() SetTab(TabMainBtn, MainContainer) end)
TabMiscBtn.MouseButton1Click:Connect(function() SetTab(TabMiscBtn, MiscContainer) end)
TabTPBtn.MouseButton1Click:Connect(function() SetTab(TabTPBtn, TPContainer) end)

local function CreateButton(text, y, parent)
    local b = Instance.new("TextButton", parent)
    b.Text = text
    b.Size = UDim2.new(1, 0, 0, 25)
    b.Position = UDim2.new(0, 0, y, 0)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    return b
end

-- TAB MAIN
local FlySpeedInput = Instance.new("TextBox", MainContainer)
FlySpeedInput.PlaceholderText = "Vận tốc Fly (VD: 50)"
FlySpeedInput.Text = "50"
FlySpeedInput.Size = UDim2.new(1, 0, 0, 25)
FlySpeedInput.Position = UDim2.new(0, 0, 0, 0)
FlySpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlySpeedInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", FlySpeedInput).CornerRadius = UDim.new(0, 4)

local FlyBtn = CreateButton("Fly: OFF", 0.12, MainContainer)

local KillDistInput = Instance.new("TextBox", MainContainer)
KillDistInput.PlaceholderText = "Tầm Kill Aura (VD: 25)"
KillDistInput.Text = "25"
KillDistInput.Size = UDim2.new(1, 0, 0, 25)
KillDistInput.Position = UDim2.new(0, 0, 0.24, 0)
KillDistInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KillDistInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", KillDistInput).CornerRadius = UDim.new(0, 4)

local KillAuraBtn = CreateButton("Kill Aura: OFF", 0.36, MainContainer)
local CollectBtn = CreateButton("Auto Lụm: OFF", 0.48, MainContainer)
local ESPBtn = CreateButton("ESP Item: OFF", 0.60, MainContainer)
local ESPNpcBtn = CreateButton("ESP NPC (Đỏ): OFF", 0.72, MainContainer)

-- TAB MISC
local BrightBtn = CreateButton("Full Bright: OFF", 0, MiscContainer)
local NoclipBtn = CreateButton("Noclip: OFF", 0.12, MiscContainer)
local FixLagBtn = CreateButton("Fix Lag (Boost FPS)", 0.24, MiscContainer)

-- TAB TELEPORT (TP)
local SpecificTPBtn = CreateButton("TP Cố Định (1230, 220, 60)", 0, TPContainer)
local PirateBaseBtn = CreateButton("Base hải tặc", 0.12, TPContainer)

local CustomTPInput = Instance.new("TextBox", TPContainer)
CustomTPInput.PlaceholderText = "X, Y, Z (VD: 100, 50, -200)"
CustomTPInput.Size = UDim2.new(1, 0, 0, 25)
CustomTPInput.Position = UDim2.new(0, 0, 0.24, 0)
CustomTPInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CustomTPInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CustomTPInput).CornerRadius = UDim.new(0, 4)

local CustomTPBtn = CreateButton("TP Tọa Độ Đã Nhập", 0.36, TPContainer)

-- Logic TP
local function TeleportTo(x, y, z)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

SpecificTPBtn.MouseButton1Click:Connect(function() TeleportTo(1230, 220, 60) end)
PirateBaseBtn.MouseButton1Click:Connect(function() TeleportTo(-2500, 250, -1500) end)

CustomTPBtn.MouseButton1Click:Connect(function()
    local text = CustomTPInput.Text
    local coords = {}
    for num in string.gmatch(text, "[-?%d%.]+") do table.insert(coords, tonumber(num)) end
    if #coords >= 3 then TeleportTo(coords[1], coords[2], coords[3]) end
end)

-- LOGIC FIX LAG
FixLagBtn.MouseButton1Click:Connect(function()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 0
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") then
                v.Enabled = false
            end
        end
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsA("MeshPart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
    end)
    FixLagBtn.Text = "Đã Fix Lag!"
    task.wait(1.5)
    FixLagBtn.Text = "Fix Lag (Boost FPS)"
end)

-- LOGIC FLY
local flyBV, flyBG = nil, nil
local upPressed, downPressed = false, false

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space then upPressed = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then downPressed = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then upPressed = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then downPressed = false end
end)

FlyBtn.MouseButton1Click:Connect(function()
    flyOn = not flyOn
    FlyBtn.Text = "Fly: "..(flyOn and "ON" or "OFF")

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if flyOn then
        if root and hum then
            flyBG = Instance.new("BodyGyro", root)
            flyBG.P = 9e4
            flyBG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBG.cframe = root.CFrame

            flyBV = Instance.new("BodyVelocity", root)
            flyBV.velocity = Vector3.new(0, 0, 0)
            flyBV.maxForce = Vector3.new(9e9, 9e9, 9e9)

            hum.PlatformStand = true
        end
    else
        if flyBG then flyBG:Destroy() end
        if flyBV then flyBV:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end)

RunService.RenderStepped:Connect(function()
    if flyOn and scriptRunning then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local cam = Workspace.CurrentCamera

            if flyBG and flyBV and hum then
                flyBG.cframe = cam.CFrame
                local speed = tonumber(FlySpeedInput.Text) or 50
                local moveDir = hum.MoveDirection

                local verticalVelocity = 0
                if upPressed then verticalVelocity = speed
                elseif downPressed then verticalVelocity = -speed end

                if moveDir.Magnitude > 0 or upPressed or downPressed then
                    local finalDir = Vector3.new(0, 0, 0)
                    if moveDir.Magnitude > 0 then
                        local relativeMove = cam.CFrame:VectorToObjectSpace(moveDir)
                        finalDir = (cam.CFrame.LookVector * -relativeMove.Z) + (cam.CFrame.RightVector * relativeMove.X)
                    end
                    flyBV.velocity = (finalDir * speed) + Vector3.new(0, verticalVelocity, 0)
                else
                    flyBV.velocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end)

-- LOGIC KILL AURA (TUỲ CHỈNH KHOẢNG CÁCH)
KillAuraBtn.MouseButton1Click:Connect(function()
    killAuraOn = not killAuraOn
    KillAuraBtn.Text = "Kill Aura: "..(killAuraOn and "ON" or "OFF")
end)

task.spawn(function()
    while scriptRunning do
        if killAuraOn then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local rootPos = char.HumanoidRootPart.Position

                -- Lấy khoảng cách người dùng đã nhập
                local maxDist = tonumber(KillDistInput.Text) or 25

                -- Lấy vũ khí đang cầm trên tay
                local equippedTool = char:FindFirstChildOfClass("Tool")

                if equippedTool then
                    for _, model in pairs(Workspace:GetDescendants()) do
                        if model:IsA("Model") and model ~= char and model:FindFirstChildOfClass("Humanoid") then
                            local hum = model:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 and not Players:GetPlayerFromCharacter(model) then
                                local npcRoot = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                                if npcRoot then
                                    local dist = (rootPos - npcRoot.Position).Magnitude
                                    if dist <= maxDist then
                                        equippedTool:Activate()
                                        
                                        local handle = equippedTool:FindFirstChild("Handle") or equippedTool:FindFirstChildWhichIsA("BasePart")
                                        if handle then
                                            firetouchinterest(handle, npcRoot, 0)
                                            firetouchinterest(handle, npcRoot, 1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- LOGIC NOCLIP
RunService.Stepped:Connect(function()
    if noclipOn and scriptRunning then
        local char = LocalPlayer.Character
        if char then
            for _, child in pairs(char:GetDescendants()) do
                if child:IsA("BasePart") then child.CanCollide = false end
            end
        end
    end
end)

-- CLEANUP KHI TẮT GUI
local function CleanupAll()
    scriptRunning = false
    flyOn = false; collectOn = false; espOn = false; espNpcOn = false; killAuraOn = false; noclipOn = false; brightOn = false

    if flyBG then flyBG:Destroy() end
    if flyBV then flyBV:Destroy() end

    Lighting.Ambient = defaultAmbient
    Lighting.OutdoorAmbient = defaultOutdoor

    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then char.Humanoid.PlatformStand = false end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:FindFirstChild("ESPHighlight") then obj.ESPHighlight:Destroy() end
        if obj:FindFirstChild("ESPTextGui") then obj.ESPTextGui:Destroy() end
        if obj:FindFirstChild("NPCHighlight") then obj.NPCHighlight:Destroy() end
        if obj:FindFirstChild("NPCTextGui") then obj.NPCTextGui:Destroy() end
    end

    ScreenGui:Destroy()
end

CloseBtn.MouseButton1Click:Connect(CleanupAll)

CollectBtn.MouseButton1Click:Connect(function() collectOn = not collectOn; CollectBtn.Text = "Auto Lụm: "..(collectOn and "ON" or "OFF") end)
NoclipBtn.MouseButton1Click:Connect(function() noclipOn = not noclipOn; NoclipBtn.Text = "Noclip: "..(noclipOn and "ON" or "OFF") end)

ESPBtn.MouseButton1Click:Connect(function() 
    espOn = not espOn
    ESPBtn.Text = "ESP Item: "..(espOn and "ON" or "OFF")
    if not espOn then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:FindFirstChild("ESPHighlight") then obj.ESPHighlight.Enabled = false end
            if obj:FindFirstChild("ESPTextGui") then obj.ESPTextGui.Enabled = false end
        end
    end
end)

ESPNpcBtn.MouseButton1Click:Connect(function()
    espNpcOn = not espNpcOn
    ESPNpcBtn.Text = "ESP NPC (Đỏ): "..(espNpcOn and "ON" or "OFF")
    if not espNpcOn then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:FindFirstChild("NPCHighlight") then obj.NPCHighlight.Enabled = false end
            if obj:FindFirstChild("NPCTextGui") then obj.NPCTextGui.Enabled = false end
        end
    end
end)

BrightBtn.MouseButton1Click:Connect(function()
    brightOn = not brightOn
    BrightBtn.Text = "Full Bright: "..(brightOn and "ON" or "OFF")
    if brightOn then
        Lighting.Ambient = Color3.new(1, 1, 1); Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = defaultAmbient; Lighting.OutdoorAmbient = defaultOutdoor
    end
end)

-- ESP ITEM + AUTO LỤM
task.spawn(function()
    while scriptRunning do
        if espOn or collectOn then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local rootPos = char.HumanoidRootPart.Position
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if not scriptRunning then break end
                    if obj:IsA("BasePart") then
                        local isTarget = LootNames[obj.Name] ~= nil
                        local dist = (rootPos - obj.Position).Magnitude
                        
                        if isTarget and espOn then
                            local hl = obj:FindFirstChild("ESPHighlight") or Instance.new("Highlight", obj)
                            hl.Name = "ESPHighlight"
                            hl.FillColor = Color3.fromRGB(255, 255, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.Enabled = true
                            
                            local bgui = obj:FindFirstChild("ESPTextGui")
                            if not bgui then
                                bgui = Instance.new("BillboardGui", obj)
                                bgui.Name = "ESPTextGui"
                                bgui.Size = UDim2.new(0, 150, 0, 30)
                                bgui.AlwaysOnTop = true
                                bgui.ExtentsOffset = Vector3.new(0, 2, 0)
                                
                                local textLabel = Instance.new("TextLabel", bgui)
                                textLabel.Name = "ESPLabel"
                                textLabel.Size = UDim2.new(1, 0, 1, 0)
                                textLabel.BackgroundTransparency = 1
                                textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                                textLabel.TextStrokeTransparency = 0
                                textLabel.TextSize = 11
                                textLabel.Font = Enum.Font.GothamBold
                            end
                            bgui.Enabled = true
                            bgui.ESPLabel.Text = string.format("%s [%dm]", obj.Name, math.floor(dist))
                        end
                        
                        if collectOn and isTarget and dist <= 15 then
                            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then
                                prompt.HoldDuration = 0
                                fireproximityprompt(prompt)
                            else
                                obj.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.3)
    end
end)

-- ESP NPC MÀU ĐỎ
task.spawn(function()
    while scriptRunning do
        if espNpcOn then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local rootPos = char.HumanoidRootPart.Position

                for _, model in pairs(Workspace:GetDescendants()) do
                    if not scriptRunning then break end
                    if model:IsA("Model") and model ~= char and model:FindFirstChildOfClass("Humanoid") then
                        if not Players:GetPlayerFromCharacter(model) then
                            local npcRoot = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model.PrimaryPart
                            if npcRoot then
                                local dist = (rootPos - npcRoot.Position).Magnitude
                                
                                local hl = model:FindFirstChild("NPCHighlight") or Instance.new("Highlight", model)
                                hl.Name = "NPCHighlight"
                                hl.FillColor = Color3.fromRGB(255, 0, 0)
                                hl.OutlineColor = Color3.fromRGB(150, 0, 0)
                                hl.FillTransparency = 0.4
                                hl.Enabled = true

                                local bgui = npcRoot:FindFirstChild("NPCTextGui")
                                if not bgui then
                                    bgui = Instance.new("BillboardGui", npcRoot)
                                    bgui.Name = "NPCTextGui"
                                    bgui.Size = UDim2.new(0, 150, 0, 30)
                                    bgui.AlwaysOnTop = true
                                    bgui.ExtentsOffset = Vector3.new(0, 2.5, 0)

                                    local textLabel = Instance.new("TextLabel", bgui)
                                    textLabel.Name = "NPCLabel"
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                                    textLabel.TextStrokeTransparency = 0
                                    textLabel.TextSize = 12
                                    textLabel.Font = Enum.Font.GothamBold
                                end
                                bgui.Enabled = true
                                bgui.NPCLabel.Text = string.format("[NPC] %s [%dm]", model.Name, math.floor(dist))
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.4)
    end
end)

-- Auto TP Ghế khi mất máu
local isTeleported = false
task.spawn(function()
    while scriptRunning do
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                local humanoid = char.Humanoid
                if humanoid.Health >= humanoid.MaxHealth then isTeleported = false end
                
                if humanoid.Health < humanoid.MaxHealth and humanoid.Health > 0 and not isTeleported then
                    isTeleported = true
                    local rootPart = char:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local rootPos = rootPart.Position
                        local nearestSeat = nil
                        local shortestDist = math.huge
                        
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
                                local dist = (rootPos - obj.Position).Magnitude
                                if dist < 300 and dist < shortestDist then
                                    shortestDist = dist
                                    nearestSeat = obj
                                end
                            end
                        end
                        if nearestSeat then rootPart.CFrame = nearestSeat.CFrame + Vector3.new(0, 3, 0) end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)
