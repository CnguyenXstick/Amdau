local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- UI Strawberry Hub (Nhỏ gọn, trong suốt)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "StrawberryHub"
MainFrame.Size = UDim2.new(0, 180, 0, 220)
MainFrame.Position = UDim2.new(0.5, -90, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.3
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Viền 7 màu xoay
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

-- Logo & Nút Điều khiển (-) và (X)
local Logo = Instance.new("ImageLabel", MainFrame)
Logo.Size = UDim2.new(0, 25, 0, 25)
Logo.Position = UDim2.new(0.05, 0, 0.05, 0)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://88285387138547"

local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Text = "-"
HideBtn.Size = UDim2.new(0, 25, 0, 25)
HideBtn.Position = UDim2.new(0.7, 0, 0.05, 0)
HideBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HideBtn.TextColor3 = Color3.new(1, 1, 1)
HideBtn.MouseButton1Click:Connect(function() 
    MainFrame.Visible = false 
    task.wait(3) 
    MainFrame.Visible = true 
end)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.MouseButton1Click:Connect(function() 
    ScreenGui:Destroy() 
end)

-- Ô nhập Speed
local SpeedInput = Instance.new("TextBox", MainFrame)
SpeedInput.PlaceholderText = "Speed"
SpeedInput.Size = UDim2.new(0.9, 0, 0, 25)
SpeedInput.Position = UDim2.new(0.05, 0, 0.25, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.TextColor3 = Color3.new(1, 1, 1)

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

local FlyBtn = AddBtn("Fly: OFF", 0.45)
local CollectBtn = AddBtn("Auto Lụm: OFF", 0.65)
local ESPBtn = AddBtn("ESP: OFF", 0.85)

-- Trạng thái
local flyOn, collectOn, espOn = false, false, false
FlyBtn.MouseButton1Click:Connect(function() flyOn = not flyOn; FlyBtn.Text = "Fly: "..(flyOn and "ON" or "OFF") end)
CollectBtn.MouseButton1Click:Connect(function() collectOn = not collectOn; CollectBtn.Text = "Lụm: "..(collectOn and "ON" or "OFF") end)
ESPBtn.MouseButton1Click:Connect(function() espOn = not espOn; ESPBtn.Text = "ESP: "..(espOn and "ON" or "OFF") end)

-- Vòng lặp tính năng (Fly & Lụm & ESP)
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    -- Fly
    if flyOn then
        local s = tonumber(SpeedInput.Text) or 50
        local cam = Workspace.CurrentCamera
        local move = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = cam.CFrame.LookVector end
        char.HumanoidRootPart.Velocity = move * s
    end
    
    -- Auto Lụm
    if collectOn then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name == "La bàn" or obj.Name == "Scrap") then
                if (char.HumanoidRootPart.Position - obj.Position).Magnitude < 15 then 
                    obj.CFrame = char.HumanoidRootPart.CFrame 
                end
            end
        end
    end
    
    -- ESP
    if espOn then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name == "La bàn" or obj.Name == "Scrap") then
                if not obj:FindFirstChild("Highlight") then
                    Instance.new("Highlight", obj)
                end
            end
        end
    end
end)

-- Auto TP lên ghế thông minh (Quét chữ Khí và tìm ghế gần nhất)
task.spawn(function()
    while true do
        pcall(function()
            for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if gui:IsA("TextLabel") and string.find(gui.Text, "Khí") then
                    local v = tonumber(gui.Text:match("%d+"))
                    if v and v <= 10 then
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local rootPos = char.HumanoidRootPart.Position
                            local nearestSeat = nil
                            local shortestDist = math.huge
                            
                            -- Tìm tất cả các ghế trong Workspace và lấy ghế gần nhất
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
                                char.HumanoidRootPart.CFrame = nearestSeat.CFrame + Vector3.new(0, 3, 0)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)
