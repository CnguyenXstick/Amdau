local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

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

-- Hàm tạo nút bấm
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
local BtnAutoCollect = CreateButton("AutoCollectBtn", 0.65, "Auto Lấy Đồ")

local espItemActive = false
local espSharkActive = false
local autoCollectActive = false

-- 1. ESP Vật phẩm (Có loại trừ Shop)
task.spawn(function()
    while true do
        if espItemActive then
            pcall(function()
                for _, item in ipairs(Workspace:GetDescendants()) do
                    if item:IsA("BasePart") and (item.Name == "Gold" or item.Name == "Treasure" or item.Name == "Chest" or item.Name == "Gem") then
                        -- Lọc bỏ vật phẩm ở khu vực Shop/Merchant
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

-- 3. Auto Collect (Có lọc Shop)
task.spawn(function()
    while true do
        if autoCollectActive then
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    for _, item in ipairs(Workspace:GetDescendants()) do
                        if item:IsA("BasePart") and (item.Name == "Gold" or item.Name == "Treasure" or item.Name == "Chest" or item.Name == "Gem") then
                            local isShop = (item.Parent and (item.Parent.Name:lower():find("shop") or item.Parent.Name:lower():find("merchant")))
                            if not isShop then
                                local prompt = item:FindFirstChildWhichIsA("ProximityPrompt")
                                if prompt then
                                    fireproximityprompt(prompt)
                                else
                                    character.HumanoidRootPart.CFrame = item.CFrame + Vector3.new(0, 2, 0)
                                end
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(1)
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
    BtnAutoCollect.Text = "Auto Lấy Đồ: " .. (autoCollectActive and "ON" or "OFF")
end)
