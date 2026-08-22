-- [[ Strawberry Hub - LostCurrents ]]
-- Phiên bản: 2.0
-- Tác giả: nguyen

-- ===== DỊCH VỤ =====
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ===== BIẾN TOÀN CỤC =====
local ScriptRunning = true

-- Trạng thái tính năng
local Features = {
    Fly = false,
    Collect = false,
    ESPItem = false,
    ESPNPC = false,
    KillAura = false,
    Noclip = false,
    Bright = false,
    Speed = false,
    Jump = false,
    BoatSpeed = false,
    NoFuel = false
}

-- Giá trị cấu hình
local Config = {
    FlySpeed = 50,
    KillRange = 25,
    WalkSpeed = 32,
    JumpPower = 100,
    BoatSpeed = 150
}

-- Lưu giá trị gốc của Lighting
local DefaultLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- Danh sách vật phẩm có thể nhặt
local LootNames = {
    ["Scrap"] = true, ["Gold"] = true, ["Chest"] = true, 
    ["La bàn"] = true, ["Compass"] = true, ["Coin"] = true, 
    ["Loot"] = true, ["Item"] = true, ["Treasure"] = true,
    ["Thùng"] = true, ["Thung"] = true, ["Barrel"] = true, 
    ["Crate"] = true, ["Box"] = true, ["Dây"] = true, 
    ["Day"] = true, ["Rope"] = true, ["String"] = true, 
    ["Cable"] = true
}

-- ===== HÀM TIỆN ÍCH =====

-- Xóa tất cả ESP
local function ClearESP(tag)
    for _, obj in pairs(Workspace:GetDescendants()) do
        local target = obj:FindFirstChild(tag)
        if target then target:Destroy() end
    end
end

-- Dọn dẹp khi tắt script
local function CleanupAll()
    ScriptRunning = false
    
    -- Tắt tất cả tính năng
    for name in pairs(Features) do
        Features[name] = false
    end
    
    -- Tắt Fly
    if FlyBV then FlyBV:Destroy(); FlyBV = nil end
    if FlyBG then FlyBG:Destroy(); FlyBG = nil end
    
    -- Khôi phục Lighting
    Lighting.Ambient = DefaultLighting.Ambient
    Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
    
    -- Xóa ESP
    ClearESP("ESPHighlight")
    ClearESP("ESPTextGui")
    ClearESP("NPCHighlight")
    ClearESP("NPCTextGui")
    
    -- Xóa GUI
    if ScreenGui then ScreenGui:Destroy() end
end

-- Teleport đến tọa độ
local function TeleportTo(x, y, z)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

-- ===== HÀM TẠO UI =====

-- Tạo GUI kéo thả
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Tạo nút bấm
local function CreateButton(text, y, parent, width, xPos)
    local btn = Instance.new("TextButton", parent)
    btn.Text = text
    btn.Size = UDim2.new(width or 1, 0, 0, 24)
    btn.Position = UDim2.new(xPos or 0, 0, y, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    return btn
end

-- Tạo ô nhập liệu
local function CreateTextBox(placeholder, text, y, parent, width, xPos)
    local box = Instance.new("TextBox", parent)
    box.PlaceholderText = placeholder
    box.Text = text
    box.Size = UDim2.new(width or 0.48, 0, 0, 24)
    box.Position = UDim2.new(xPos or 0, 0, y, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    return box
end

-- Tạo tab
local function CreateTabButton(text, y)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Text = text
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.Position = UDim2.new(0, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    return btn
end

-- Tạo container
local function CreateContainer()
    local container = Instance.new("Frame", MainFrame)
    container.Size = UDim2.new(1, -124, 1, -38)
    container.Position = UDim2.new(0, 116, 0, 30)
    container.BackgroundTransparency = 1
    return container
end

-- ===== XÂY DỰNG UI =====

-- ScreenGui chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StrawberryHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Frame chính
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 270)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
MakeDraggable(MainFrame)

-- Viền đổi màu
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
task.spawn(function()
    while ScriptRunning do
        for i = 0, 1, 0.05 do
            if not ScriptRunning then break end
            UIStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.1)
        end
    end
end)

-- Tiêu đề
local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "Strawberry / LostCurrents - by nguyen"
Title.Size = UDim2.new(0, 300, 0, 25)
Title.Position = UDim2.new(0.02, 0, 0.02, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Nút ẩn
local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Text = "-"
HideBtn.Size = UDim2.new(0, 22, 0, 22)
HideBtn.Position = UDim2.new(1, -52, 0.02, 0)
HideBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HideBtn.TextColor3 = Color3.new(1, 1, 1)
HideBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 4)

-- Nút đóng
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -26, 0.02, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

-- Nút mở (khi ẩn)
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

-- Viền nút mở
local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Thickness = 2
task.spawn(function()
    while ScriptRunning do
        for i = 0, 1, 0.05 do
            if not ScriptRunning then break end
            FloatStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.1)
        end
    end
end)

-- Ẩn/hiện
HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatBtn.Visible = true
end)
FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatBtn.Visible = false
end)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 100, 1, -35)
Sidebar.Position = UDim2.new(0, 8, 0, 30)
Sidebar.BackgroundTransparency = 1

-- Các tab
local TabMain = CreateTabButton("Chính", 0)
local TabMisc = CreateTabButton("Tùy Chỉnh", 34)
local TabTP = CreateTabButton("Teleport", 68)

-- Containers
local MainContainer = CreateContainer()
local MiscContainer = CreateContainer()
MiscContainer.Visible = false
local TPContainer = CreateContainer()
TPContainer.Visible = false

-- Chọn tab
local function SetTab(activeBtn, activeContainer)
    MainContainer.Visible = false
    MiscContainer.Visible = false
    TPContainer.Visible = false
    
    for _, btn in pairs({TabMain, TabMisc, TabTP}) do
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    end
    
    activeContainer.Visible = true
    activeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    activeBtn.TextColor3 = Color3.new(1, 1, 1)
end

TabMain.MouseButton1Click:Connect(function() SetTab(TabMain, MainContainer) end)
TabMisc.MouseButton1Click:Connect(function() SetTab(TabMisc, MiscContainer) end)
TabTP.MouseButton1Click:Connect(function() SetTab(TabTP, TPContainer) end)

-- ===== TAB CHÍNH =====

-- Fly Speed
local FlySpeedInput = CreateTextBox(
    "Vận tốc Fly (VD: 50)",
    "50",
    0,
    MainContainer,
    0.48,
    0
)

-- Nút Fly
local FlyBtn = CreateButton("Fly: TẮT", 0, MainContainer, 0.48, 0.52)

-- Kill Range
local KillDistInput = CreateTextBox(
    "Tầm Kill Aura (VD: 25)",
    "25",
    0.14,
    MainContainer,
    0.48,
    0
)

-- Nút Kill Aura
local KillAuraBtn = CreateButton("Kill Aura: TẮT", 0.14, MainContainer, 0.48, 0.52)

-- Nút Auto Lụm
local CollectBtn = CreateButton("Auto Lụm: TẮT", 0.28, MainContainer, 0.48, 0)

-- Nút ESP Item
local ESPBtn = CreateButton("ESP Item: TẮT", 0.28, MainContainer, 0.48, 0.52)

-- Nút ESP NPC
local ESPNpcBtn = CreateButton("ESP NPC (Đỏ): TẮT", 0.42, MainContainer, 1, 0)

-- ===== TAB TÙY CHỈNH =====

-- Nút Full Bright
local BrightBtn = CreateButton("Full Bright: TẮT", 0, MiscContainer, 1, 0)

-- Nút Noclip
local NoclipBtn = CreateButton("Noclip: TẮT", 0.13, MiscContainer, 1, 0)

-- Nút Fix Lag
local FixLagBtn = CreateButton("Fix Lag (Boost FPS)", 0.26, MiscContainer, 1, 0)

-- WalkSpeed
local SpeedInput = CreateTextBox(
    "Tốc độ chạy",
    tostring(Config.WalkSpeed),
    0.39,
    MiscContainer,
    0.48,
    0
)
local SpeedBtn = CreateButton("WalkSpeed: TẮT", 0.39, MiscContainer, 0.48, 0.52)

-- JumpPower
local JumpInput = CreateTextBox(
    "Lực nhảy",
    tostring(Config.JumpPower),
    0.52,
    MiscContainer,
    0.48,
    0
)
local JumpBtn = CreateButton("JumpPower: TẮT", 0.52, MiscContainer, 0.48, 0.52)

-- Boat Speed
local BoatInput = CreateTextBox(
    "Tốc độ thuyền",
    tostring(Config.BoatSpeed),
    0.65,
    MiscContainer,
    0.48,
    0
)
local BoatSpeedBtn = CreateButton("Boat Speed: TẮT", 0.65, MiscContainer, 0.48, 0.52)

-- No-Fuel
local NoFuelBtn = CreateButton("Băng Nhiên Liệu: TẮT", 0.78, MiscContainer, 1, 0)

-- ===== TAB TELEPORT =====

-- TP Cố định
local SpecificTPBtn = CreateButton("TP Cố Định (1230, 220, 60)", 0, TPContainer, 1, 0)

-- TP Base Hải Tặc
local PirateBaseBtn = CreateButton("Base Hải Tặc", 0.14, TPContainer, 1, 0)

-- Custom TP
local CustomTPInput = Instance.new("TextBox", TPContainer)
CustomTPInput.PlaceholderText = "X, Y, Z (VD: 100, 50, -200)"
CustomTPInput.Size = UDim2.new(1, 0, 0, 24)
CustomTPInput.Position = UDim2.new(0, 0, 0.28, 0)
CustomTPInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CustomTPInput.TextColor3 = Color3.new(1, 1, 1)
CustomTPInput.Font = Enum.Font.Gotham
CustomTPInput.TextSize = 13
Instance.new("UICorner", CustomTPInput).CornerRadius = UDim.new(0, 4)

local CustomTPBtn = CreateButton("TP Tọa Độ Đã Nhập", 0.42, TPContainer, 1, 0)

-- ===== BẢNG THÔNG TIN CUSTOM (PROFILE) =====
local ProfileFrame = Instance.new("Frame", ScreenGui)
ProfileFrame.Name = "ProfileFrame"
ProfileFrame.Size = UDim2.new(0, 240, 0, 75)
ProfileFrame.Position = UDim2.new(0.5, -225, 0.5, 145)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ProfileFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 8)
MakeDraggable(ProfileFrame)

-- Viền Profile
local ProfileStroke = Instance.new("UIStroke", ProfileFrame)
ProfileStroke.Thickness = 1.5
ProfileStroke.Color = Color3.fromRGB(80, 80, 80)

-- Hiệu ứng viền đổi màu cho Profile
task.spawn(function()
    while ScriptRunning do
        for i = 0, 1, 0.05 do
            if not ScriptRunning then break end
            ProfileStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.1)
        end
    end
end)

-- Khung Ảnh
local CustomImg = Instance.new("ImageLabel", ProfileFrame)
CustomImg.Name = "CustomImage"
CustomImg.Size = UDim2.new(0, 55, 0, 55)
CustomImg.Position = UDim2.new(0, 10, 0.5, -27.5)
CustomImg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CustomImg.BackgroundTransparency = 0.5
CustomImg.Image = "rbxassetid://88285387138547"
Instance.new("UICorner", CustomImg).CornerRadius = UDim.new(0, 8)

-- Viền ảnh
local ImgStroke = Instance.new("UIStroke", CustomImg)
ImgStroke.Thickness = 2
ImgStroke.Color = Color3.fromRGB(255, 255, 255)

-- Tên Custom
local CustomNameLabel = Instance.new("TextLabel", ProfileFrame)
CustomNameLabel.Name = "CustomNameLabel"
CustomNameLabel.Size = UDim2.new(1, -75, 0, 32)
CustomNameLabel.Position = UDim2.new(0, 70, 0, 6)
CustomNameLabel.BackgroundTransparency = 1
CustomNameLabel.Text = "owr: Nguyen / Builder : Nam"
CustomNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CustomNameLabel.TextSize = 11
CustomNameLabel.Font = Enum.Font.GothamBold
CustomNameLabel.TextXAlignment = Enum.TextXAlignment.Left
CustomNameLabel.TextWrapped = true

-- Tên người chơi
local PlayerNameLabel = Instance.new("TextLabel", ProfileFrame)
PlayerNameLabel.Name = "PlayerNameLabel"
PlayerNameLabel.Size = UDim2.new(1, -75, 0, 16)
PlayerNameLabel.Position = UDim2.new(0, 70, 0, 28)
PlayerNameLabel.BackgroundTransparency = 1
PlayerNameLabel.Text = "Player: " .. LocalPlayer.Name
PlayerNameLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
PlayerNameLabel.TextSize = 12
PlayerNameLabel.Font = Enum.Font.GothamBold
PlayerNameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ID Người chơi
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

-- Nút đóng Profile
local ProfileHideBtn = Instance.new("TextButton", ProfileFrame)
ProfileHideBtn.Text = "-"
ProfileHideBtn.Size = UDim2.new(0, 22, 0, 22)
ProfileHideBtn.Position = UDim2.new(1, -26, 0.02, 0)
ProfileHideBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ProfileHideBtn.TextColor3 = Color3.new(1, 1, 1)
ProfileHideBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ProfileHideBtn).CornerRadius = UDim.new(0, 4)

-- Nút lưu thông tin Profile
local SaveProfileBtn = Instance.new("TextButton", ProfileFrame)
SaveProfileBtn.Text = "💾"
SaveProfileBtn.Size = UDim2.new(0, 22, 0, 22)
SaveProfileBtn.Position = UDim2.new(1, -52, 0.02, 0)
SaveProfileBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 30)
SaveProfileBtn.TextColor3 = Color3.new(1, 1, 1)
SaveProfileBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", SaveProfileBtn).CornerRadius = UDim.new(0, 4)

-- Nút mở Profile (khi ẩn)
local ProfileFloatBtn = Instance.new("ImageButton", ScreenGui)
ProfileFloatBtn.Name = "ProfileOpenBtn"
ProfileFloatBtn.Size = UDim2.new(0, 40, 0, 40)
ProfileFloatBtn.Position = UDim2.new(0.75, 0, 0.1, 0)
ProfileFloatBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ProfileFloatBtn.BackgroundTransparency = 0.3
ProfileFloatBtn.Image = "rbxassetid://88285387138547"
ProfileFloatBtn.Visible = false
Instance.new("UICorner", ProfileFloatBtn).CornerRadius = UDim.new(1, 0)
MakeDraggable(ProfileFloatBtn)

local ProfileFloatStroke = Instance.new("UIStroke", ProfileFloatBtn)
ProfileFloatStroke.Thickness = 2
task.spawn(function()
    while ScriptRunning do
        for i = 0, 1, 0.05 do
            if not ScriptRunning then break end
            ProfileFloatStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.1)
        end
    end
end)

-- Ẩn/Hiện Profile
ProfileHideBtn.MouseButton1Click:Connect(function()
    ProfileFrame.Visible = false
    ProfileFloatBtn.Visible = true
end)

ProfileFloatBtn.MouseButton1Click:Connect(function()
    ProfileFrame.Visible = true
    ProfileFloatBtn.Visible = false
end)

-- Lưu thông tin Profile
SaveProfileBtn.MouseButton1Click:Connect(function()
    local info = string.format(
        "Tên: %s\nID: %d\nCustom: owr: Nguyen / Builder : Nam",
        LocalPlayer.Name,
        LocalPlayer.UserId
    )
    
    pcall(function()
        local clip = game:GetService("Clipboard")
        if clip then
            clip:SetAsync(info)
            SaveProfileBtn.Text = "✓"
            task.wait(2)
            SaveProfileBtn.Text = "💾"
        end
    end)
end)

-- Cập nhật thông tin người chơi
task.spawn(function()
    while ScriptRunning do
        pcall(function()
            PlayerNameLabel.Text = "Player: " .. LocalPlayer.Name
            UserIdLabel.Text = "ID: " .. LocalPlayer.UserId
        end)
        task.wait(5)
    end
end)

-- ===== XỬ LÝ SỰ KIỆN =====

CloseBtn.MouseButton1Click:Connect(CleanupAll)

-- Cập nhật cấu hình từ TextBox
SpeedInput.FocusLost:Connect(function()
    local v = tonumber(SpeedInput.Text)
    if v then Config.WalkSpeed = v else SpeedInput.Text = tostring(Config.WalkSpeed) end
end)

JumpInput.FocusLost:Connect(function()
    local v = tonumber(JumpInput.Text)
    if v then Config.JumpPower = v else JumpInput.Text = tostring(Config.JumpPower) end
end)

BoatInput.FocusLost:Connect(function()
    local v = tonumber(BoatInput.Text)
    if v then Config.BoatSpeed = v else BoatInput.Text = tostring(Config.BoatSpeed) end
end)

-- Xử lý nút Teleport
SpecificTPBtn.MouseButton1Click:Connect(function() TeleportTo(1230, 220, 60) end)
PirateBaseBtn.MouseButton1Click:Connect(function() TeleportTo(-2500, 250, -1500) end)

CustomTPBtn.MouseButton1Click:Connect(function()
    local text = CustomTPInput.Text
    local coords = {}
    for num in string.gmatch(text, "[-?%d%.]+") do 
        table.insert(coords, tonumber(num)) 
    end
    if #coords >= 3 then 
        TeleportTo(coords[1], coords[2], coords[3]) 
    end
end)

-- Xử lý nút Fix Lag
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

-- Xử lý nút No-Fuel
NoFuelBtn.MouseButton1Click:Connect(function()
    Features.NoFuel = not Features.NoFuel
    NoFuelBtn.Text = "Băng Nhiên Liệu: " .. (Features.NoFuel and "BẬT" or "TẮT")
    
    -- Setup hook khi bật
    if Features.NoFuel then
        pcall(function()
            local rawmeta = getrawmetatable(game)
            local oldNamecall = rawmeta.__namecall
            setreadonly(rawmeta, false)
            
            rawmeta.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "FireServer" and self and Features.NoFuel then
                    local name = string.lower(self.Name)
                    if name:find("fuel") or name:find("gas") or 
                       name:find("consume") or name:find("xang") or 
                       name:find("drain") or name:find("use") then
                        return nil
                    end
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(rawmeta, true)
        end)
    end
end)

-- ===== TÍNH NĂNG: FLY =====

local FlyBV, FlyBG = nil, nil
local UpPressed, DownPressed = false, false

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space then
        UpPressed = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then
        DownPressed = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        UpPressed = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then
        DownPressed = false
    end
end)

local function StopFly()
    if FlyBG then FlyBG:Destroy(); FlyBG = nil end
    if FlyBV then FlyBV:Destroy(); FlyBV = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

FlyBtn.MouseButton1Click:Connect(function()
    Features.Fly = not Features.Fly
    FlyBtn.Text = "Fly: " .. (Features.Fly and "BẬT" or "TẮT")
    
    if Features.Fly then
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if root and hum then
            FlyBG = Instance.new("BodyGyro", root)
            FlyBG.P = 9e4
            FlyBG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            FlyBG.cframe = root.CFrame
            
            FlyBV = Instance.new("BodyVelocity", root)
            FlyBV.velocity = Vector3.new(0, 0, 0)
            FlyBV.maxForce = Vector3.new(9e9, 9e9, 9e9)
            
            hum.PlatformStand = true
        end
    else
        StopFly()
    end
end)

RunService.RenderStepped:Connect(function()
    if Features.Fly and ScriptRunning then
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        
        local cam = Workspace.CurrentCamera
        if not cam then return end
        
        if FlyBG and FlyBV then
            FlyBG.cframe = cam.CFrame
            local speed = tonumber(FlySpeedInput.Text) or 50
            local moveDir = hum.MoveDirection
            
            local verticalVelocity = 0
            if UpPressed then verticalVelocity = speed
            elseif DownPressed then verticalVelocity = -speed end
            
            if moveDir.Magnitude > 0 or UpPressed or DownPressed then
                local finalDir = Vector3.new(0, 0, 0)
                if moveDir.Magnitude > 0 then
                    local relativeMove = cam.CFrame:VectorToObjectSpace(moveDir)
                    finalDir = (cam.CFrame.LookVector * -relativeMove.Z) + 
                               (cam.CFrame.RightVector * relativeMove.X)
                end
                FlyBV.velocity = (finalDir * speed) + Vector3.new(0, verticalVelocity, 0)
            else
                FlyBV.velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- ===== TÍNH NĂNG: KILL AURA =====

KillAuraBtn.MouseButton1Click:Connect(function()
    Features.KillAura = not Features.KillAura
    KillAuraBtn.Text = "Kill Aura: " .. (Features.KillAura and "BẬT" or "TẮT")
end)

task.spawn(function()
    while ScriptRunning do
        if Features.KillAura then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local rootPos = root.Position
                local maxDist = tonumber(KillDistInput.Text) or 25
                local tool = char:FindFirstChildOfClass("Tool")
                
                if tool then
                    for _, model in pairs(Workspace:GetChildren()) do
                        if model:IsA("Model") and model ~= char then
                            local hum = model:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                if not Players:GetPlayerFromCharacter(model) then
                                    local npcRoot = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                                    if npcRoot then
                                        local dist = (rootPos - npcRoot.Position).Magnitude
                                        if dist <= maxDist then
                                            tool:Activate()
                                            local handle = tool:FindFirstChild("Handle") or 
                                                         tool:FindFirstChildWhichIsA("BasePart")
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
                end
            end)
        end
        task.wait(0.15)
    end
end)

-- ===== TÍNH NĂNG: AUTO LỤM =====

CollectBtn.MouseButton1Click:Connect(function()
    Features.Collect = not Features.Collect
    CollectBtn.Text = "Auto Lụm: " .. (Features.Collect and "BẬT" or "TẮT")
end)

task.spawn(function()
    while ScriptRunning do
        if Features.Collect then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local rootPos = root.Position
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if not ScriptRunning or not Features.Collect then break end
                    
                    if LootNames[obj.Name] then
                        local part = obj:IsA("BasePart") and obj or 
                                    obj.PrimaryPart or 
                                    obj:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local dist = (rootPos - part.Position).Magnitude
                            
                            if dist <= 20 then
                                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then
                                    prompt.HoldDuration = 0
                                    prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 30)
                                    fireproximityprompt(prompt)
                                elseif part:IsA("BasePart") then
                                    firetouchinterest(root, part, 0)
                                    firetouchinterest(root, part, 1)
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.05)
    end
end)

-- ===== TÍNH NĂNG: ESP ITEM =====

ESPBtn.MouseButton1Click:Connect(function()
    Features.ESPItem = not Features.ESPItem
    ESPBtn.Text = "ESP Item: " .. (Features.ESPItem and "BẬT" or "TẮT")
    if not Features.ESPItem then
        ClearESP("ESPHighlight")
        ClearESP("ESPTextGui")
    end
end)

task.spawn(function()
    while ScriptRunning do
        if Features.ESPItem then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local rootPos = root.Position
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if not ScriptRunning or not Features.ESPItem then break end
                    
                    if obj:IsA("BasePart") and LootNames[obj.Name] then
                        local dist = (rootPos - obj.Position).Magnitude
                        
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
                            
                            local label = Instance.new("TextLabel", bgui)
                            label.Name = "ESPLabel"
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.fromRGB(255, 255, 0)
                            label.TextStrokeTransparency = 0
                            label.TextSize = 11
                            label.Font = Enum.Font.GothamBold
                        end
                        bgui.Enabled = true
                        bgui.ESPLabel.Text = obj.Name .. " [" .. math.floor(dist) .. "m]"
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ===== TÍNH NĂNG: ESP NPC =====

ESPNpcBtn.MouseButton1Click:Connect(function()
    Features.ESPNPC = not Features.ESPNPC
    ESPNpcBtn.Text = "ESP NPC (Đỏ): " .. (Features.ESPNPC and "BẬT" or "TẮT")
    if not Features.ESPNPC then
        ClearESP("NPCHighlight")
        ClearESP("NPCTextGui")
    end
end)

task.spawn(function()
    while ScriptRunning do
        if Features.ESPNPC then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local rootPos = root.Position
                
                for _, model in pairs(Workspace:GetChildren()) do
                    if not ScriptRunning then break end
                    
                    if model:IsA("Model") and model ~= char then
                        local hum = model:FindFirstChildOfClass("Humanoid")
                        if hum then
                            if not Players:GetPlayerFromCharacter(model) then
                                local npcRoot = model:FindFirstChild("HumanoidRootPart") or 
                                               model:FindFirstChild("Head") or 
                                               model.PrimaryPart
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
                                        
                                        local label = Instance.new("TextLabel", bgui)
                                        label.Name = "NPCLabel"
                                        label.Size = UDim2.new(1, 0, 1, 0)
                                        label.BackgroundTransparency = 1
                                        label.TextColor3 = Color3.fromRGB(255, 50, 50)
                                        label.TextStrokeTransparency = 0
                                        label.TextSize = 12
                                        label.Font = Enum.Font.GothamBold
                                    end
                                    bgui.Enabled = true
                                    bgui.NPCLabel.Text = "[NPC] " .. model.Name .. " [" .. math.floor(dist) .. "m]"
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ===== TÍNH NĂNG: NOCLIP =====

NoclipBtn.MouseButton1Click:Connect(function()
    Features.Noclip = not Features.Noclip
    NoclipBtn.Text = "Noclip: " .. (Features.Noclip and "BẬT" or "TẮT")
end)

RunService.Stepped:Connect(function()
    if Features.Noclip and ScriptRunning then
        local char = LocalPlayer.Character
        if char then
            for _, child in pairs(char:GetDescendants()) do
                if child:IsA("BasePart") then
                    child.CanCollide = false
                end
            end
        end
    end
end)

-- ===== TÍNH NĂNG: FULL BRIGHT =====

BrightBtn.MouseButton1Click:Connect(function()
    Features.Bright = not Features.Bright
    BrightBtn.Text = "Full Bright: " .. (Features.Bright and "BẬT" or "TẮT")
    
    if Features.Bright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = DefaultLighting.Ambient
        Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
    end
end)

-- ===== TÍNH NĂNG: WALKSPEED & JUMPPOWER =====

SpeedBtn.MouseButton1Click:Connect(function()
    Features.Speed = not Features.Speed
    SpeedBtn.Text = "WalkSpeed: " .. (Features.Speed and "BẬT" or "TẮT")
    if not Features.Speed then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
end)

JumpBtn.MouseButton1Click:Connect(function()
    Features.Jump = not Features.Jump
    JumpBtn.Text = "JumpPower: " .. (Features.Jump and "BẬT" or "TẮT")
    if not Features.Jump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = 50
            end
        end
    end
end)

-- Vòng lặp duy trì WalkSpeed & JumpPower
task.spawn(function()
    while ScriptRunning do
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    if Features.Speed then
                        hum.WalkSpeed = Config.WalkSpeed
                    end
                    if Features.Jump then
                        hum.UseJumpPower = true
                        hum.JumpPower = Config.JumpPower
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)

-- ===== TÍNH NĂNG: BOAT SPEED =====

BoatSpeedBtn.MouseButton1Click:Connect(function()
    Features.BoatSpeed = not Features.BoatSpeed
    BoatSpeedBtn.Text = "Boat Speed: " .. (Features.BoatSpeed and "BẬT" or "TẮT")
end)

task.spawn(function()
    while ScriptRunning do
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                local seat = char.Humanoid.SeatPart
                if seat and seat:IsA("VehicleSeat") then
                    local bv = seat:FindFirstChild("SmoothBoatVelocity")
                    if Features.BoatSpeed then
                        if not bv then
                            bv = Instance.new("BodyVelocity")
                            bv.Name = "SmoothBoatVelocity"
                            bv.MaxForce = Vector3.new(1e5, 0, 1e5)
                            bv.Parent = seat
                        end
                        bv.Velocity = seat.CFrame.LookVector * (seat.Throttle * Config.BoatSpeed)
                    else
                        if bv then bv:Destroy() end
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- ===== AUTO TP GHẾ KHI MẤT MÁU =====

local IsTeleported = false
task.spawn(function()
    while ScriptRunning do
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                local humanoid = char.Humanoid
                if humanoid.Health >= humanoid.MaxHealth then 
                    IsTeleported = false 
                end
                
                if humanoid.Health < humanoid.MaxHealth and humanoid.Health > 0 and not IsTeleported then
                    IsTeleported = true
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
        task.wait(0.5)
    end
end)

print("Strawberry Hub đã tải thành công!")
