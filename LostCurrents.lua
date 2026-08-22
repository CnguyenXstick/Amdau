local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Biến quản lý trạng thái
local scriptRunning = true
local flyOn, collectOn, espOn, noclipOn, brightOn = false, false, false, false, false
local tpwalking = false

-- Lưu trạng thái Lighting ban đầu để Restore
local defaultAmbient = Lighting.Ambient
local defaultOutdoor = Lighting.OutdoorAmbient

-- Danh sách tên vật phẩm ĐƯỢC PHÉP Auto Lụm (Tránh nhầm nút Kéo/Chèo thuyền)
local LootNames = {
    ["Scrap"] = true,
    ["Gold"] = true,
    ["Chest"] = true,
    ["La bàn"] = true,
    ["Compass"] = true,
    ["Coin"] = true,
    ["Loot"] = true,
    ["Item"] = true,
    ["Treasure"] = true
}

-- Hàm Kéo Thả
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
MainFrame.Size = UDim2.new(0, 220, 0, 270)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -135)
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

-- Tab Main & Misc
local TabMainBtn = Instance.new("TextButton", MainFrame)
TabMainBtn.Text = "Main"
TabMainBtn.Size = UDim2.new(0.44, 0, 0, 22)
TabMainBtn.Position = UDim2.new(0.04, 0, 0.1, 0)
TabMainBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TabMainBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", TabMainBtn).CornerRadius = UDim.new(0, 4)

local TabMiscBtn = Instance.new("TextButton", MainFrame)
TabMiscBtn.Text = "Misc"
TabMiscBtn.Size = UDim2.new(0.44, 0, 0, 22)
TabMiscBtn.Position = UDim2.new(0.52, 0, 0.1, 0)
TabMiscBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabMiscBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
Instance.new("UICorner", TabMiscBtn).CornerRadius = UDim.new(0, 4)

local MainContainer = Instance.new("Frame", MainFrame)
MainContainer.Size = UDim2.new(0.92, 0, 0.82, 0)
MainContainer.Position = UDim2.new(0.04, 0, 0.18, 0)
MainContainer.BackgroundTransparency = 1

local MiscContainer = Instance.new("Frame", MainFrame)
MiscContainer.Size = UDim2.new(0.92, 0, 0.82, 0)
MiscContainer.Position = UDim2.new(0.04, 0, 0.18, 0)
MiscContainer.BackgroundTransparency = 1
MiscContainer.Visible = false

TabMainBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = true; MiscContainer.Visible = false
    TabMainBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); TabMainBtn.TextColor3 = Color3.new(1, 1, 1)
    TabMiscBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabMiscBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
end)

TabMiscBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = false; MiscContainer.Visible = true
    TabMiscBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); TabMiscBtn.TextColor3 = Color3.new(1, 1, 1)
    TabMainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabMainBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
end)

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

local SpeedInput = Instance.new("TextBox", MainContainer)
SpeedInput.PlaceholderText = "Speed (Mặc định 1)"
SpeedInput.Size = UDim2.new(1, 0, 0, 25)
SpeedInput.Position = UDim2.new(0, 0, 0, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 4)

local FlyBtn = CreateButton("Fly: OFF", 0.18, MainContainer)
local CollectBtn = CreateButton("Auto Lụm: OFF", 0.36, MainContainer)
local ESPBtn = CreateButton("ESP: OFF", 0.54, MainContainer)
local BrightBtn = CreateButton("Full Bright: OFF", 0, MiscContainer)
local NoclipBtn = CreateButton("Noclip: OFF", 0.18, MiscContainer)

-- HÀM DỌN SẠCH TOÀN BỘ (SỰ KIỆN NÚT X)
local function CleanupAll()
    scriptRunning = false
    flyOn = false
    collectOn = false
    espOn = false
    noclipOn = false
    brightOn = false
    tpwalking = false

    Lighting.Ambient = defaultAmbient
    Lighting.OutdoorAmbient = defaultOutdoor

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                hum:SetStateEnabled(state, true)
            end
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
        if char:FindFirstChild("Animate") then
            char.Animate.Disabled = false
        end
    end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:FindFirstChild("ESPHighlight") then obj.ESPHighlight:Destroy() end
        if obj:FindFirstChild("ESPTextGui") then obj.ESPTextGui:Destroy() end
    end

    ScreenGui:Destroy()
end

CloseBtn.MouseButton1Click:Connect(CleanupAll)

-- LOGIC FLY V3
task.spawn(function()
    while scriptRunning do
        task.wait(0.1)
        if flyOn and scriptRunning then
            local char = LocalPlayer.Character
            if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if not hum or not root then continue end

            if char:FindFirstChild("Animate") then char.Animate.Disabled = true end
            for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:AdjustSpeed(0) end

            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                hum:SetStateEnabled(state, false)
            end
            hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
            hum:ChangeState(Enum.HumanoidStateType.Swimming)
            hum.PlatformStand = true

            local bg = Instance.new("BodyGyro", root)
            bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.cframe = root.CFrame

            local bv = Instance.new("BodyVelocity", root)
            bv.velocity = Vector3.new(0, 0.1, 0); bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

            tpwalking = true
            task.spawn(function()
                local hb = RunService.Heartbeat
                while tpwalking and flyOn and scriptRunning and char and hum and hum.Parent do
                    hb:Wait()
                    if hum.MoveDirection.Magnitude > 0 then
                        local multiplier = tonumber(SpeedInput.Text) or 1
                        for i = 1, math.max(1, math.floor(multiplier)) do
                            char:TranslateBy(hum.MoveDirection)
                        end
                    end
                end
            end)

            while flyOn and scriptRunning and hum.Health > 0 do
                RunService.RenderStepped:Wait()
                bg.cframe = Workspace.CurrentCamera.CFrame
            end

            tpwalking = false
            bg:Destroy(); bv:Destroy()
            hum.PlatformStand = false
            if char:FindFirstChild("Animate") then char.Animate.Disabled = false end
            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                hum:SetStateEnabled(state, true)
            end
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end)

FlyBtn.MouseButton1Click:Connect(function()
    flyOn = not flyOn
    FlyBtn.Text = "Fly: "..(flyOn and "ON" or "OFF")
end)

CollectBtn.MouseButton1Click:Connect(function() collectOn = not collectOn; CollectBtn.Text = "Auto Lụm: "..(collectOn and "ON" or "OFF") end)
NoclipBtn.MouseButton1Click:Connect(function() noclipOn = not noclipOn; NoclipBtn.Text = "Noclip: "..(noclipOn and "ON" or "OFF") end)

ESPBtn.MouseButton1Click:Connect(function() 
    espOn = not espOn
    ESPBtn.Text = "ESP: "..(espOn and "ON" or "OFF")
    if not espOn then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:FindFirstChild("ESPHighlight") then obj.ESPHighlight.Enabled = false end
            if obj:FindFirstChild("ESPTextGui") then obj.ESPTextGui.Enabled = false end
        end
    end
end)

BrightBtn.MouseButton1Click:Connect(function()
    brightOn = not brightOn
    BrightBtn.Text = "Full Bright: "..(brightOn and "ON" or "OFF")
    if brightOn then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = defaultAmbient
        Lighting.OutdoorAmbient = defaultOutdoor
    end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if noclipOn and scriptRunning then
        local char = LocalPlayer.Character
        if char then
            for _, child in pairs(char:GetChildren()) do
                if child:IsA("BasePart") then child.CanCollide = false end
            end
        end
    end
end)

-- ESP + AUTO LỤM (Đã lọc chính xác vật phẩm Loot)
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
                        
                        -- ESP
                        if isTarget and espOn then
                            local hl = obj:FindFirstChild("ESPHighlight")
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "ESPHighlight"
                                hl.FillColor = Color3.fromRGB(255, 0, 0)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.Parent = obj
                            end
                            hl.Enabled = true
                            
                            local bgui = obj:FindFirstChild("ESPTextGui")
                            if not bgui then
                                bgui = Instance.new("BillboardGui")
                                bgui.Name = "ESPTextGui"
                                bgui.Size = UDim2.new(0, 150, 0, 30)
                                bgui.AlwaysOnTop = true
                                bgui.ExtentsOffset = Vector3.new(0, 2, 0)
                                bgui.Parent = obj
                                
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
                        
                        -- Auto Lụm (Chỉ kích hoạt trên vật phẩm Loot)
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
        task.wait(0.2)
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
        task.wait(0.3)
    end
end)
