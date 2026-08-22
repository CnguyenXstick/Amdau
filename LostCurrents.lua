-- ========================================================
-- BẢNG THÔNG TIN CUSTOM (ID ÁNH & TÊN CUSTOM)
-- ========================================================
local ProfileFrame = Instance.new("Frame", ScreenGui)
ProfileFrame.Name = "ProfileFrame"
ProfileFrame.Size = UDim2.new(0, 240, 0, 75)
ProfileFrame.Position = UDim2.new(0.5, -225, 0.5, 145) -- Vị trí bên dưới MainFrame
ProfileFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ProfileFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 8)
MakeDraggable(ProfileFrame)

local ProfileStroke = Instance.new("UIStroke", ProfileFrame)
ProfileStroke.Thickness = 1.5
ProfileStroke.Color = Color3.fromRGB(80, 80, 80)

-- Khung Ảnh (Sử dụng ID Custom của bạn)
local CustomImg = Instance.new("ImageLabel", ProfileFrame)
CustomImg.Name = "CustomImage"
CustomImg.Size = UDim2.new(0, 55, 0, 55)
CustomImg.Position = UDim2.new(0, 10, 0.5, -27.5)
CustomImg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CustomImg.BackgroundTransparency = 0.5
CustomImg.Image = "rbxassetid://88285387138547"
Instance.new("UICorner", CustomImg).CornerRadius = UDim.new(0, 8)

-- Tên Custom (owr: Nguyen / Builder : Nam)
local CustomNameLabel = Instance.new("TextLabel", ProfileFrame)
CustomNameLabel.Name = "CustomNameLabel"
CustomNameLabel.Size = UDim2.new(1, -75, 0, 32)
CustomNameLabel.Position = UDim2.new(0, 70, 0, 10)
CustomNameLabel.BackgroundTransparency = 1
CustomNameLabel.Text = "owr: Nguyen / Builder : Nam"
CustomNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CustomNameLabel.TextSize = 11
CustomNameLabel.Font = Enum.Font.GothamBold
CustomNameLabel.TextXAlignment = Enum.TextXAlignment.Left
CustomNameLabel.TextWrapped = true

-- ID Người chơi (UserId)
local UserIdLabel = Instance.new("TextLabel", ProfileFrame)
UserIdLabel.Name = "UserIdLabel"
UserIdLabel.Size = UDim2.new(1, -75, 0, 16)
UserIdLabel.Position = UDim2.new(0, 70, 0, 46)
UserIdLabel.BackgroundTransparency = 1
UserIdLabel.Text = "ID: " .. LocalPlayer.UserId
UserIdLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
UserIdLabel.TextSize = 11
UserIdLabel.Font = Enum.Font.GothamMedium
UserIdLabel.TextXAlignment = Enum.TextXAlignment.Left
