local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Danh sách vật phẩm cần quét
local TargetItems = {"Gold", "Treasure", "Chest", "Gem", "Scrap", "Phế liệu", "Helmet", "Mũ bảo hiểm"}

local function isTargetItem(name)
    for _, v in ipairs(TargetItems) do
        if name:lower() == v:lower() then return true end
    end
    return false
end

-- Tạo Giao Diện (UI)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "LostCurrentsHub"
ScreenGui.Parent = game.CoreGui

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
MainFrame.Size = UDim2.new(0, 220, 0, 200)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Lost Currents Pro"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

local titleCorner = Instance.new("UICorner")
titleCorner.Parent = Title

local function CreateButton(name, posY, defaultText)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.Position = UDim2.new(0.1, 0, posY, 0)
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = defaultText .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    local corner = Instance.new("UICorner")
    corner.Parent = btn
    return btn
end

local BtnESPItem = CreateButton("ESPItemBtn", 0.25, "ESP Vật Phẩm")
local BtnESPShark = CreateButton("ESPSharkBtn", 0.45, "ESP Cá Mập")
local BtnAutoCollect = CreateButton("AutoCollectBtn", 0.65, "Aura Collect")

local espItemActive = false
local espSharkActive = false
local autoCollectActive = false

-- 1. ESP Vật phẩm
task.spawn(function()
    while true do
        if espItemActive then
            pcall(function()
                for _, item in ipairs(Workspace:GetDescendants()) do
                    if item:IsA("BasePart") and isTargetItem(item.Name) then
                        local isShop = (item.Parent and (item.Parent.Name:lower():find("shop") or item.Parent.Name:lower():find("merchant")))
                        if not isShop and not item:FindFirstChild("ItemHighlight") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ItemHighlight"
                            highlight.Adornee = item
                            highlight.FillColor = Color3.fromRGB(255, 215, 0)
                            highlight.Parent = item
                        end
                    end
                end
            end)
        else
            for _, item in ipairs(Workspace:GetDescendants()) do if item:FindFirstChild("ItemHighlight") then item.ItemHighlight:Destroy() end end
        end
        task.wait(2)
    end
end)

-- 2. ESP Cá Mập
task.spawn(function()
    while true do
        if espSharkActive then
            pcall(function()
                for _, mob in ipairs(Workspace:GetDescendants()) do
                    if mob:IsA("Model") and (mob.Name:lower():find("shark") or mob.Name:lower():find("cá mập")) then
                        if not mob:FindFirstChild("SharkHighlight") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "SharkHighlight"
                            highlight.Adornee = mob
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.Parent = mob
                        end
                    end
                end
            end)
        else
            for _, mob in ipairs(Workspace:GetDescendants()) do if mob:FindFirstChild("SharkHighlight") then mob.SharkHighlight:Destroy() end end
        end
        task.wait(2)
    end
end)

-- 3. Aura Collect (Phạm vi 200 mét)
task.spawn(function()
    while true do
        if autoCollectActive then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for _, item in ipairs(Workspace:GetDescendants()) do
                        if item:IsA("BasePart") and isTargetItem(item.Name) then
                            local isShop = (item.Parent and (item.Parent.Name:lower():find("shop") or item.Parent.Name:lower():find("merchant")))
                            if not isShop then
                                local dist = (char.HumanoidRootPart.Position - item.Position).Magnitude
                                if dist <= 200 then
                                    local prompt = item:FindFirstChildWhichIsA("ProximityPrompt")
                                    if prompt then
                                        prompt.HoldDuration = 0
                                        fireproximityprompt(prompt)
                                    else
                                        item.CanCollide = false
                                        item.CFrame = char.HumanoidRootPart.CFrame
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

-- Sự kiện Bấm nút
BtnESPItem.MouseButton1Click:Connect(function()
    espItemActive = not espItemActive
    BtnESPItem.BackgroundColor3 = espItemActive and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    BtnESPItem.Text = "ESP Vật Phẩm: " .. (espItemActive and "ON" or "OFF")
end)

BtnESPShark.MouseButton1Click:Connect(function()
    espSharkActive = not espSharkActive
    BtnESPShark.BackgroundColor3 = espSharkActive and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    BtnESPShark.Text = "ESP Cá Mập: " .. (espSharkActive and "ON" or "OFF")
end)

BtnAutoCollect.MouseButton1Click:Connect(function()
    autoCollectActive = not autoCollectActive
    BtnAutoCollect.BackgroundColor3 = autoCollectActive and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    BtnAutoCollect.Text = "Aura Collect: " .. (autoCollectActive and "ON" or "OFF")
end)
