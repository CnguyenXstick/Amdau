local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Danh sách vật phẩm
local TargetItems = {"Gold", "Treasure", "Chest", "Gem", "Scrap", "Phế liệu", "Helmet", "Mũ bảo hiểm"}
local function isTargetItem(name)
    for _, v in ipairs(TargetItems) do
        if name:lower() == v:lower() then return true end
    end
    return false
end

-- Tạo Giao Diện UI Hiện đại
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")

ScreenGui.Name = "LostCurrentsHub"
ScreenGui.Parent = game.CoreGui

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -150)
MainFrame.Size = UDim2.new(0, 200, 0, 310)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Tiêu đề và Logo
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "   Lost Currents"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local Logo = Instance.new("ImageLabel", Title)
Logo.Size = UDim2.new(0, 25, 0, 25)
Logo.Position = UDim2.new(0, 5, 0.15, 0)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://88285387138547" 

local function CreateButton(name, posY, defaultText)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Position = UDim2.new(0.05, 0, posY, 0)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Font = Enum.Font.Gotham
    btn.Text = defaultText .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local BtnESPItem = CreateButton("ESPItemBtn", 0.15, "ESP Item")
local BtnESPShark = CreateButton("ESPSharkBtn", 0.26, "ESP Shark")
local BtnAutoCollect = CreateButton("AutoCollectBtn", 0.37, "Aura Collect")
local BtnSpeed = CreateButton("SpeedBtn", 0.48, "Speed")
local BtnFly = CreateButton("FlyBtn", 0.59, "Fly")
local BtnFullBright = CreateButton("FullBrightBtn", 0.70, "Full Bright")

local espItemActive, espSharkActive, autoCollectActive, speedActive, flyActive, fullBrightActive = false, false, false, false, false, false

-- Chức năng hoạt động
task.spawn(function()
    while true do
        if espItemActive then
            pcall(function()
                for _, item in ipairs(Workspace:GetDescendants()) do
                    if item:IsA("BasePart") and isTargetItem(item.Name) and not item:FindFirstChild("ItemHighlight") then
                        local highlight = Instance.new("Highlight", item)
                        highlight.Name = "ItemHighlight"
                        highlight.FillColor = Color3.fromRGB(255, 215, 0)
                    end
                end
            end)
        else
            for _, item in ipairs(Workspace:GetDescendants()) do if item:FindFirstChild("ItemHighlight") then item.ItemHighlight:Destroy() end end
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if autoCollectActive then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for _, item in ipairs(Workspace:GetDescendants()) do
                        if item:IsA("BasePart") and isTargetItem(item.Name) then
                            local dist = (char.HumanoidRootPart.Position - item.Position).Magnitude
                            if dist <= 50 then
                                local prompt = item:FindFirstChildWhichIsA("ProximityPrompt")
                                if prompt then fireproximityprompt(prompt) else item.CFrame = char.HumanoidRootPart.CFrame end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- Nút bấm cập nhật trạng thái
local function ToggleButton(btn, varName)
    btn.MouseButton1Click:Connect(function()
        if varName == "ESPItem" then espItemActive = not espItemActive; btn.Text = "ESP Item: " .. (espItemActive and "ON" or "OFF")
        elseif varName == "ESPShark" then espSharkActive = not espSharkActive; btn.Text = "ESP Shark: " .. (espSharkActive and "ON" or "OFF")
        elseif varName == "AutoCollect" then autoCollectActive = not autoCollectActive; btn.Text = "Aura Collect: " .. (autoCollectActive and "ON" or "OFF")
        elseif varName == "Speed" then speedActive = not speedActive; btn.Text = "Speed: " .. (speedActive and "ON" or "OFF")
        elseif varName == "Fly" then flyActive = not flyActive; btn.Text = "Fly: " .. (flyActive and "ON" or "OFF")
        elseif varName == "FullBright" then fullBrightActive = not fullBrightActive; btn.Text = "Full Bright: " .. (fullBrightActive and "ON" or "OFF")
        end
    end)
end

ToggleButton(BtnESPItem, "ESPItem")
ToggleButton(BtnESPShark, "ESPShark")
ToggleButton(BtnAutoCollect, "AutoCollect")
ToggleButton(BtnSpeed, "Speed")
ToggleButton(BtnFly, "Fly")
ToggleButton(BtnFullBright, "FullBright")

-- Chạy bổ trợ (Speed, Fly, FullBright)
RunService.RenderStepped:Connect(function()
    if speedActive then LocalPlayer.Character.Humanoid.WalkSpeed = 50 end
    if fullBrightActive then Lighting.Brightness = 2; Lighting.ClockTime = 14 end
    if flyActive then
        local cam = Workspace.CurrentCamera
        local root = LocalPlayer.Character.HumanoidRootPart
        root.Velocity = (UserInputService:IsKeyDown(Enum.KeyCode.W) and cam.CFrame.LookVector or Vector3.new()) * 50
    end
end)
