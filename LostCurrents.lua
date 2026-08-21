local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Hàm hỗ trợ Kéo Thả Mượt Cả Trên PC & Mobile
local function MakeDraggable(gui)
    local dragging = false
    local dragInput, dragStart, startPos

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
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- UI Strawberry Hub
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "StrawberryHub"
MainFrame.Size = UDim2.new(0, 220, 0, 270)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Bật kéo thả cho MainFrame
MakeDraggable(MainFrame)

-- Viền 7 màu MainFrame
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
task.spawn(function()
    while true do
        for i = 0, 1, 0.05 do 
            UIStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.1) 
        end
    end
end)

-- Tiêu đề
local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "Strawberry / LostCurrents - by nguyen"
Title.Size = UDim2.new(0, 140, 0, 25)
Title.Position = UDim2.new(0.03, 0, 0.02, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 9
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Nút Ẩn (-) và Xóa (X)
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
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Floating Logo Button (Có thể kéo thả khắp màn hình)
local FloatBtn = Instance.new("ImageButton", ScreenGui)
FloatBtn.Name = "OpenButton"
FloatBtn.Size = UDim2.new(0, 45, 0, 45)
FloatBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FloatBtn.BackgroundTransparency = 0.3
FloatBtn.Image = "rbxassetid://88285387138547"
FloatBtn.Visible = false
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

-- Bật kéo thả cho Logo Thu Nhỏ
MakeDraggable(FloatBtn)

local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Thickness = 2
task.spawn(function()
    while true do
        for i = 0, 1, 0.05 do 
            FloatStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.1) 
        end
    end
end)

HideBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; FloatBtn.Visible = true end)
FloatBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; FloatBtn.Visible = false end)

-- Khung Nút Chuyển Tab (Main / Misc)
local TabMainBtn = Instance.new("TextButton", MainFrame)
TabMainBtn.Text = "Main"
TabMainBtn.Size = UDim2.new(0.44, 0, 0, 22)
TabMainBtn.Position = UDim2.new(0.04, 0, 0.12, 0)
TabMainBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TabMainBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", TabMainBtn).CornerRadius = UDim.new(0, 4)

local TabMiscBtn = Instance.new("TextButton", MainFrame)
TabMiscBtn.Text = "Misc"
TabMiscBtn.Size = UDim2.new(0.44, 0, 0, 22)
TabMiscBtn.Position = UDim2.new(0.52, 0, 0.12, 0)
TabMiscBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabMiscBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
Instance.new("UICorner", TabMiscBtn).CornerRadius = UDim.new(0, 4)

-- Container chứa nội dung Tab
local MainContainer = Instance.new("Frame", MainFrame)
MainContainer.Size = UDim2.new(0.92, 0, 0.78, 0)
MainContainer.Position = UDim2.new(0.04, 0, 0.22, 0)
MainContainer.BackgroundTransparency = 1

local MiscContainer = Instance.new("Frame", MainFrame)
MiscContainer.Size = UDim2.new(0.92, 0, 0.78, 0)
MiscContainer.Position = UDim2.new(0.04, 0, 0.22, 0)
MiscContainer.BackgroundTransparency = 1
MiscContainer.Visible = false

-- Chuyển Tab
TabMainBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = true
    MiscContainer.Visible = false
    TabMainBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    TabMainBtn.TextColor3 = Color3.new(1, 1, 1)
    TabMiscBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabMiscBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
end)

TabMiscBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = false
    MiscContainer.Visible = true
    TabMiscBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    TabMiscBtn.TextColor3 = Color3.new(1, 1, 1)
    TabMainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabMainBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
end)

-- Hàm tạo nút bấm
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
local SpeedInput = Instance.new("TextBox", MainContainer)
SpeedInput.PlaceholderText = "Speed (Mặc định 50)"
SpeedInput.Size = UDim2.new(1, 0, 0, 25)
SpeedInput.Position = UDim2.new(0, 0, 0, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 4)

local FlyBtn = CreateButton("Fly: OFF", 0.18, MainContainer)
local CollectBtn = CreateButton("Auto Lụm: OFF", 0.36, MainContainer)
local ESPBtn = CreateButton("ESP: OFF", 0.54, MainContainer)

-- TAB MISC
local BrightBtn = CreateButton("Full Bright: OFF", 0, MiscContainer)

-- Trạng thái tính năng
local flyOn, collectOn, espOn, brightOn = false, false, false, false

FlyBtn.MouseButton1Click:Connect(function() flyOn = not flyOn; FlyBtn.Text = "Fly: "..(flyOn and "ON" or "OFF") end)
CollectBtn.MouseButton1Click:Connect(function() collectOn = not collectOn; CollectBtn.Text = "Auto Lụm: "..(collectOn and "ON" or "OFF") end)
ESPBtn.MouseButton1Click:Connect(function() 
    espOn = not espOn
    ESPBtn.Text = "ESP: "..(espOn and "ON" or "OFF")
    if not espOn then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:FindFirstChild("ESPHighlight") then
                obj.ESPHighlight.Enabled = false
            end
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
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end
end)

-- Fly mượt
RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    
    if flyOn then
        local speed = tonumber(SpeedInput.Text) or 50
        local cam = Workspace.CurrentCamera
        local moveDir = Vector3.new(0,0,0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        
        root.CFrame = root.CFrame + (moveDir * speed * dt)
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end)

-- ESP KHÔNG GIẬT LẮC & AUTO LỤM
task.spawn(function()
    while true do
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local rootPos = char.HumanoidRootPart.Position
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name == "La bàn" or obj.Name == "Scrap" or obj.Name == "Gold" or obj.Name == "Chest") then
                    -- ESP Tối ưu (Tạo 1 lần, chỉ bật/tắt Enabled)
                    if espOn then
                        local hl = obj:FindFirstChild("ESPHighlight")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "ESPHighlight"
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.Parent = obj
                        end
                        hl.Enabled = true
                    end
                    
                    -- Auto Lụm
                    if collectOn then
                        local dist = (rootPos - obj.Position).Magnitude
                        if dist < 25 then
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
            end
        end)
        task.wait(0.3)
    end
end)

-- Auto TP lên ghế (Sát thương 1 lần)
local isTeleported = false
task.spawn(function()
    while true do
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
        task.wait(0.1)
    end
end)
