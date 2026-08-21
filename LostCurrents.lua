local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- UI Strawberry Hub (Nhỏ gọn, trong suốt)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "StrawberryHub"
MainFrame.Size = UDim2.new(0, 190, 0, 230)
MainFrame.Position = UDim2.new(0.5, -95, 0.5, -115)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.3
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Viền 7 màu xoay cho MainFrame
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

-- Tiêu đề: Strawberry / LostCurrents - by nguyen
local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "Strawberry / LostCurrents - by nguyen"
Title.Size = UDim2.new(0.65, 0, 0, 25)
Title.Position = UDim2.new(0.02, 0, 0.03, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 9
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Nút Ẩn (-) và Xóa (X)
local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Text = "-"
HideBtn.Size = UDim2.new(0, 22, 0, 22)
HideBtn.Position = UDim2.new(0.70, 0, 0.03, 0)
HideBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HideBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(0.86, 0, 0.03, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
CloseBtn.MouseButton1Click:Connect(function() 
    ScreenGui:Destroy() 
end)

-- Nút tròn thu nhỏ dạng ảnh ID của bạn, có thể kéo thả khắp màn hình
local FloatBtn = Instance.new("ImageButton", ScreenGui)
FloatBtn.Name = "OpenButton"
FloatBtn.Size = UDim2.new(0, 45, 0, 45)
FloatBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FloatBtn.BackgroundTransparency = 0.3
FloatBtn.Image = "rbxassetid://88285387138547"
FloatBtn.Visible = false
FloatBtn.Draggable = true
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

-- Viền 7 màu cho nút tròn
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

-- Logic ẩn/hiện khi bấm dấu trừ
HideBtn.MouseButton1Click:Connect(function() 
    MainFrame.Visible = false 
    FloatBtn.Visible = true
end)

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatBtn.Visible = false
end)

-- Ô nhập Speed
local SpeedInput = Instance.new("TextBox", MainFrame)
SpeedInput.PlaceholderText = "Speed"
SpeedInput.Size = UDim2.new(0.9, 0, 0, 25)
SpeedInput.Position = UDim2.new(0.05, 0, 0.22, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 4)

-- Hàm tạo nút bấm gọn
local function AddBtn(text, y)
    local b = Instance.new("TextButton", MainFrame)
    b.Text = text
    b.Size = UDim2.new(0.9, 0, 0, 25)
    b.Position = UDim2.new(0.05, 0, y, 0)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    return b
end

local FlyBtn = AddBtn("Fly: OFF", 0.42)
local CollectBtn = AddBtn("Auto Lụm: OFF", 0.62)
local ESPBtn = AddBtn("ESP: OFF", 0.82)

local flyOn, collectOn, espOn = false, false, false
FlyBtn.MouseButton1Click:Connect(function() flyOn = not flyOn; FlyBtn.Text = "Fly: "..(flyOn and "ON" or "OFF") end)
CollectBtn.MouseButton1Click:Connect(function() collectOn = not collectOn; CollectBtn.Text = "Lụm: "..(collectOn and "ON" or "OFF") end)
ESPBtn.MouseButton1Click:Connect(function() espOn = not espOn; ESPBtn.Text = "ESP: "..(espOn and "ON" or "OFF") end)

-- Fly mượt mà
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

-- AUTO LỤM & ESP
task.spawn(function()
    while true do
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local rootPos = char.HumanoidRootPart.Position
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name == "La bàn" or obj.Name == "Scrap" or obj.Name == "Gold" or obj.Name == "Chest") then
                    -- ESP
                    if espOn and not obj:FindFirstChild("Highlight") then
                        Instance.new("Highlight", obj)
                    elseif not espOn and obj:FindFirstChild("Highlight") then
                        obj.Highlight:Destroy()
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

-- Auto TP lên ghế (Chỉ TP 1 lần duy nhất khi dính sát thương, có chống lặp debounce)
local isTeleported = false
task.spawn(function()
    while true do
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                local humanoid = char.Humanoid
                
                if humanoid.Health >= humanoid.MaxHealth then
                    isTeleported = false
                end
                
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
                        
                        if nearestSeat then
                            rootPart.CFrame = nearestSeat.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)
