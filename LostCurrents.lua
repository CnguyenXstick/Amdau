-- [[ Strawberry Hub - LostCurrents ]]
-- Phiên bản: 1.4 (Fixed Boat TP Rubberband + Manual Equip KillAura)
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
local UITimer = nil 
local SavedCFrame = nil 

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

local DefaultLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local LootNames = {
    ["Scrap"] = true, ["Gold"] = true, ["Chest"] = true, 
    ["La bàn"] = true, ["Compass"] = true, ["Coin"] = true, 
    ["Loot"] = true, ["Item"] = true, ["Treasure"] = true,
    ["Thùng"] = true, ["Thung"] = true, ["Barrel"] = true, 
    ["Crate"] = true, ["Box"] = true, ["Dây"] = true, 
    ["Day"] = true, ["Rope"] = true, ["String"] = true, 
    ["Cable"] = true
}

local ScreenGui, MainFrame, FloatBtn

-- ===== HÀM TIỆN ÍCH =====
local function ClearESP(tag)
    for _, obj in pairs(Workspace:GetDescendants()) do
        local target = obj:FindFirstChild(tag)
        if target then target:Destroy() end
    end
end

local function TeleportTo(x, y, z)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

local function AutoHideUI()
    if UITimer then UITimer:Disconnect(); UITimer = nil end
    UITimer = task.delay(5, function()
        if ScriptRunning and MainFrame and FloatBtn then
            MainFrame.Visible = false
            FloatBtn.Visible = true
        end
    end)
end

local function ShowUI()
    if MainFrame and FloatBtn then
        MainFrame.Visible = true
        FloatBtn.Visible = false
    end
    if UITimer then UITimer:Disconnect(); UITimer = nil end
    AutoHideUI()
end

local function CleanupAll()
    ScriptRunning = false
    for name in pairs(Features) do Features[name] = false end
    Lighting.Ambient = DefaultLighting.Ambient
    Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
    ClearESP("ESPHighlight")
    ClearESP("ESPTextGui")
    ClearESP("NPCHighlight")
    ClearESP("NPCTextGui")
    if ScreenGui then ScreenGui:Destroy() end
end

-- ===== HÀM TẠO UI =====
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
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
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function CreateButton(text, y, parent, width, xPos)
    local btn = Instance.new("TextButton", parent)
    btn.Text = text
    btn.Size = UDim2.new(width or 1, 0, 0, 24)
    btn.Position = UDim2.new(xPos or 0, 0, y, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    return btn
end

local function CreateTextBox(placeholder, text, y, parent, width, xPos)
    local box = Instance.new("TextBox", parent)
    box.PlaceholderText = placeholder
    box.Text = text
    box.Size = UDim2.new(width or 0.48, 0, 0, 24)
    box.Position = UDim2.new(xPos or 0, 0, y, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    return box
end

-- ===== XÂY DỰNG UI =====
ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StrawberryHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 270)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
MakeDraggable(MainFrame)

-- VIỀN RGB CHO MAINFRAME
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

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "Strawberry / LostCurrents - by nguyen"
Title.Size = UDim2.new(0, 300, 0, 25)
Title.Position = UDim2.new(0.02, 0, 0.02, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Text = "-"
HideBtn.Size = UDim2.new(0, 22, 0, 22)
HideBtn.Position = UDim2.new(1, -52, 0.02, 0)
HideBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HideBtn.TextColor3 = Color3.new(1, 1, 1)
HideBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -26, 0.02, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

FloatBtn = Instance.new("ImageButton", ScreenGui)
FloatBtn.Name = "OpenButton"
FloatBtn.Size = UDim2.new(0, 45, 0, 45)
FloatBtn.Position = UDim2.new(0.02, 0, 0.5, -22.5)
FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FloatBtn.BackgroundTransparency = 0.3
FloatBtn.Image = "rbxassetid://88285387138547"
FloatBtn.Visible = false
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
MakeDraggable(FloatBtn)

-- VIỀN RGB CHO NÚT TRÒN FLOAT
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

HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatBtn.Visible = true
    if UITimer then UITimer:Disconnect(); UITimer = nil end
end)

FloatBtn.MouseButton1Click:Connect(ShowUI)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 100, 1, -35)
Sidebar.Position = UDim2.new(0, 8, 0, 30)
Sidebar.BackgroundTransparency = 1

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

local TabMain = CreateTabButton("Chính", 0)
local TabMisc = CreateTabButton("Tùy Chỉnh", 34)
local TabTP = CreateTabButton("Teleport", 68)

local function CreateContainer()
    local container = Instance.new("Frame", MainFrame)
    container.Size = UDim2.new(1, -124, 1, -38)
    container.Position = UDim2.new(0, 116, 0, 30)
    container.BackgroundTransparency = 1
    return container
end

local MainContainer = CreateContainer()
local MiscContainer = CreateContainer()
MiscContainer.Visible = false
local TPContainer = CreateContainer()
TPContainer.Visible = false

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

-- TAB CHÍNH
local FlySpeedInput = CreateTextBox("Vận tốc Fly", "50", 0, MainContainer, 0.48, 0)
local FlyBtn = CreateButton("Fly: TẮT", 0, MainContainer, 0.48, 0.52)
local KillDistInput = CreateTextBox("Tầm Kill Aura", "25", 0.14, MainContainer, 0.48, 0)
local KillAuraBtn = CreateButton("Kill Aura: TẮT", 0.14, MainContainer, 0.48, 0.52)
local CollectBtn = CreateButton("Auto Lụm: TẮT", 0.28, MainContainer, 0.48, 0)
local ESPBtn = CreateButton("ESP Item: TẮT", 0.28, MainContainer, 0.48, 0.52)
local ESPNpcBtn = CreateButton("ESP NPC (Đỏ): TẮT", 0.42, MainContainer, 1, 0)

-- TAB TÙY CHỈNH
local BrightBtn = CreateButton("Full Bright: TẮT", 0, MiscContainer, 1, 0)
local NoclipBtn = CreateButton("Noclip: TẮT", 0.13, MiscContainer, 1, 0)
local FixLagBtn = CreateButton("Fix Lag (Boost FPS)", 0.26, MiscContainer, 1, 0)
local SpeedInput = CreateTextBox("Tốc độ chạy", tostring(Config.WalkSpeed), 0.39, MiscContainer, 0.48, 0)
local SpeedBtn = CreateButton("WalkSpeed: TẮT", 0.39, MiscContainer, 0.48, 0.52)
local JumpInput = CreateTextBox("Lực nhảy", tostring(Config.JumpPower), 0.52, MiscContainer, 0.48, 0)
local JumpBtn = CreateButton("JumpPower: TẮT", 0.52, MiscContainer, 0.48, 0.52)
local BoatInput = CreateTextBox("Tốc độ thuyền", tostring(Config.BoatSpeed), 0.65, MiscContainer, 0.48, 0)
local BoatSpeedBtn = CreateButton("Boat Speed: TẮT", 0.65, MiscContainer, 0.48, 0.52)
local NoFuelBtn = CreateButton("Băng Nhiên Liệu: TẮT", 0.78, MiscContainer, 1, 0)

-- TAB TELEPORT
local SaveTPBtn = CreateButton("Lưu Vị Trí Hiện Tại", 0, TPContainer, 0.48, 0)
local LoadTPBtn = CreateButton("TP Đến Vị Trí Đã Lưu", 0, TPContainer, 0.48, 0.52)
local SpecificTPBtn = CreateButton("TP Cố Định (1230, 220, 60)", 0.14, TPContainer, 1, 0)
local PirateBaseBtn = CreateButton("Base Hải Tặc", 0.28, TPContainer, 1, 0)

local CustomTPInput = CreateTextBox("Nhập X, Y, Z (VD: 100, 50, -200)", "", 0.42, TPContainer, 1, 0)
local CustomPlayerTPBtn = CreateButton("TP Người Đến Tọa Độ", 0.56, TPContainer, 0.48, 0)
local CustomBoatTPBtn = CreateButton("Lái Thuyền Đến Tọa Độ", 0.56, TPContainer, 0.48, 0.52)

-- THÔNG BÁO TỰ XÓA
local NotificationFrame = Instance.new("Frame", ScreenGui)
NotificationFrame.Name = "AutoDeleteNotice"
NotificationFrame.Size = UDim2.new(0, 280, 0, 65)
NotificationFrame.Position = UDim2.new(0.5, -140, 0.5, -32.5) 
NotificationFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
NotificationFrame.BackgroundTransparency = 0.2
Instance.new("UICorner", NotificationFrame).CornerRadius = UDim.new(0, 8)

local NoticeStroke = Instance.new("UIStroke", NotificationFrame)
NoticeStroke.Thickness = 1.5
task.spawn(function()
    while ScriptRunning and NotificationFrame and NotificationFrame.Parent do
        for i = 0, 1, 0.05 do
            if not ScriptRunning or not NotificationFrame or not NotificationFrame.Parent then break end
            NoticeStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.1)
        end
    end
end)

local NoticeImg = Instance.new("ImageLabel", NotificationFrame)
NoticeImg.Size = UDim2.new(0, 48, 0, 48)
NoticeImg.Position = UDim2.new(0, 8, 0.5, -24)
NoticeImg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
NoticeImg.BackgroundTransparency = 0.5
NoticeImg.Image = "rbxassetid://88285387138547"
Instance.new("UICorner", NoticeImg).CornerRadius = UDim.new(0, 6)

local NoticeText = Instance.new("TextLabel", NotificationFrame)
NoticeText.Size = UDim2.new(1, -70, 1, 0)
NoticeText.Position = UDim2.new(0, 62, 0, 0)
NoticeText.BackgroundTransparency = 1
NoticeText.Text = "owr : Nguyen / build : Nam"
NoticeText.TextColor3 = Color3.fromRGB(255, 255, 255)
NoticeText.TextSize = 12
NoticeText.Font = Enum.Font.GothamBold
NoticeText.TextXAlignment = Enum.TextXAlignment.Left
NoticeText.TextYAlignment = Enum.TextYAlignment.Center
NoticeText.TextWrapped = true

task.delay(3, function() if NotificationFrame then NotificationFrame:Destroy() end end)

-- EVENT HANDLERS
CloseBtn.MouseButton1Click:Connect(CleanupAll)

MainFrame.MouseEnter:Connect(function()
    if MainFrame.Visible then
        if UITimer then UITimer:Disconnect(); UITimer = nil end
        AutoHideUI()
    end
end)

-- XỬ LÝ LƯU & TP TỌA ĐỘ
SaveTPBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        SavedCFrame = char.HumanoidRootPart.CFrame
        local pos = SavedCFrame.Position
        SaveTPBtn.Text = string.format("Đã Lưu: %.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z)
        task.delay(2, function()
            SaveTPBtn.Text = "Lưu Vị Trí Hiện Tại"
        end)
    end
end)

LoadTPBtn.MouseButton1Click:Connect(function()
    if SavedCFrame then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = SavedCFrame
        end
    else
        LoadTPBtn.Text = "Chưa Lưu Vị Trí!"
        task.delay(1.5, function()
            LoadTPBtn.Text = "TP Đến Vị Trí Đã Lưu"
        end)
    end
end)

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

SpecificTPBtn.MouseButton1Click:Connect(function() TeleportTo(1230, 220, 60) end)
PirateBaseBtn.MouseButton1Click:Connect(function() TeleportTo(-2500, 250, -1500) end)

-- NÚT 1: TP NGƯỜI THẲNG ĐẾN TỌA ĐỘ
CustomPlayerTPBtn.MouseButton1Click:Connect(function()
    local text = CustomTPInput.Text
    local coords = {}
    for num in string.gmatch(text, "[-?%d%.]+") do table.insert(coords, tonumber(num)) end
    if #coords >= 3 then 
        TeleportTo(coords[1], coords[2], coords[3]) 
    end
end)

-- NÚT 2: LÁI THUYỀN ĐẾN TỌA ĐỘ (CHỐNG GIẬT RUBBERBAND)
CustomBoatTPBtn.MouseButton1Click:Connect(function()
    local text = CustomTPInput.Text
    local coords = {}
    for num in string.gmatch(text, "[-?%d%.]+") do table.insert(coords, tonumber(num)) end
    
    if #coords >= 3 then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            local seat = char.Humanoid.SeatPart
            if seat then
                local boat = seat.Parent
                local root = (boat and boat:IsA("Model") and boat.PrimaryPart) or seat or (boat and boat:FindFirstChildWhichIsA("BasePart"))
                
                if root then
                    local targetCFrame = CFrame.new(coords[1], coords[2], coords[3])
                    
                    -- Triệt tiêu vận tốc cũ tránh bị kéo lại
                    pcall(function()
                        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end)
                    
                    -- Anchor tạm thời để khóa vị trí trên Server
                    root.Anchored = true
                    
                    -- Dịch chuyển toàn bộ Model thuyền
                    if boat and boat:IsA("Model") then
                        boat:PivotTo(targetCFrame)
                    else
                        root.CFrame = targetCFrame
                    end
                    
                    -- Chờ 0.15 giây cho Server ghi nhận rồi nhả Anchor
                    task.wait(0.15)
                    root.Anchored = false
                    
                    -- Triệt tiêu vận tốc dư thừa một lần nữa
                    pcall(function()
                        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end)
                end
            else
                CustomBoatTPBtn.Text = "Chưa Ngồi Thuyền!"
                task.delay(1.5, function()
                    CustomBoatTPBtn.Text = "Lái Thuyền Đến Tọa Độ"
                end)
            end
        end
    end
end)

-- FIX LAG
FixLagBtn.MouseButton1Click:Connect(function()
    FixLagBtn.Text = "Đang tối ưu..."
    task.spawn(function()
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 0
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") then
                    v.Enabled = false
                end
            end
        end)
        
        local descendants = Workspace:GetDescendants()
        for i, obj in ipairs(descendants) do
            pcall(function()
                if obj:IsA("BasePart") and not obj:IsA("MeshPart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj:Destroy()
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = false
                end
            end)
            if i % 100 == 0 then task.wait() end
        end
        FixLagBtn.Text = "Đã Fix Lag!"
        task.wait(1.5)
        FixLagBtn.Text = "Fix Lag (Boost FPS)"
    end)
end)

-- TOGGLES
SpeedBtn.MouseButton1Click:Connect(function()
    Features.Speed = not Features.Speed
    SpeedBtn.Text = "WalkSpeed: " .. (Features.Speed and "BẬT" or "TẮT")
end)

JumpBtn.MouseButton1Click:Connect(function()
    Features.Jump = not Features.Jump
    JumpBtn.Text = "JumpPower: " .. (Features.Jump and "BẬT" or "TẮT")
end)

BrightBtn.MouseButton1Click:Connect(function()
    Features.Bright = not Features.Bright
    BrightBtn.Text = "Full Bright: " .. (Features.Bright and "BẬT" or "TẮT")
    if not Features.Bright then
        Lighting.Ambient = DefaultLighting.Ambient
        Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
    end
end)

NoclipBtn.MouseButton1Click:Connect(function()
    Features.Noclip = not Features.Noclip
    NoclipBtn.Text = "Noclip: " .. (Features.Noclip and "BẬT" or "TẮT")
end)

BoatSpeedBtn.MouseButton1Click:Connect(function()
    Features.BoatSpeed = not Features.BoatSpeed
    BoatSpeedBtn.Text = "Boat Speed: " .. (Features.BoatSpeed and "BẬT" or "TẮT")
end)

NoFuelBtn.MouseButton1Click:Connect(function()
    Features.NoFuel = not Features.NoFuel
    NoFuelBtn.Text = "Băng Nhiên Liệu: " .. (Features.NoFuel and "BẬT" or "TẮT")
    if Features.NoFuel then
        pcall(function()
            local rawmeta = getrawmetatable(game)
            local oldNamecall = rawmeta.__namecall
            setreadonly(rawmeta, false)
            rawmeta.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "FireServer" and self and Features.NoFuel then
                    local name = string.lower(self.Name)
                    if name:find("fuel") or name:find("gas") or name:find("consume") or name:find("xang") or name:find("drain") or name:find("use") then
                        return nil
                    end
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(rawmeta, true)
        end)
    end
end)

-- STEPPED LOOP
RunService.Stepped:Connect(function()
    if not ScriptRunning then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Features.Speed then hum.WalkSpeed = Config.WalkSpeed end
            if Features.Jump then 
                hum.UseJumpPower = true
                hum.JumpPower = Config.JumpPower 
            end
        end
        if Features.Noclip then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
    if Features.Bright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end
end)

-- FLY LOGIC
local FlyBV, FlyBG = nil, nil
local UpPressed, DownPressed = false, false

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space then UpPressed = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then DownPressed = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then UpPressed = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then DownPressed = false end
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
        local cam = Workspace.CurrentCamera
        if root and hum and cam and FlyBG and FlyBV then
            FlyBG.cframe = cam.CFrame
            local speed = tonumber(FlySpeedInput.Text) or 50
            local moveDir = hum.MoveDirection
            local verticalVelocity = UpPressed and speed or (DownPressed and -speed or 0)
            
            if moveDir.Magnitude > 0 or UpPressed or DownPressed then
                local finalDir = Vector3.new(0, 0, 0)
                if moveDir.Magnitude > 0 then
                    local relativeMove = cam.CFrame:VectorToObjectSpace(moveDir)
                    finalDir = (cam.CFrame.LookVector * -relativeMove.Z) + (cam.CFrame.RightVector * relativeMove.X)
                end
                FlyBV.velocity = (finalDir * speed) + Vector3.new(0, verticalVelocity, 0)
            else
                FlyBV.velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- BOAT SPEED
task.spawn(function()
    while ScriptRunning do
        if Features.BoatSpeed then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
                    local vehicle = char.Humanoid.SeatPart.Parent
                    if vehicle and vehicle:IsA("Model") then
                        local root = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
                        if root then
                            root.AssemblyLinearVelocity = root.CFrame.LookVector * Config.BoatSpeed
                        end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- KILL AURA (KHÔNG TỰ ĐỘNG CẦM VŨ KHÍ)
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

                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    local rootPos = root.Position
                    local maxDist = tonumber(KillDistInput.Text) or 25
                    
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Humanoid") and obj.Parent ~= char and obj.Health > 0 then
                            local model = obj.Parent
                            if model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
                                local npcRoot = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                                if npcRoot and (rootPos - npcRoot.Position).Magnitude <= maxDist then
                                    tool:Activate()
                                    
                                    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                                    if handle and firetouchinterest then
                                        firetouchinterest(handle, npcRoot, 0)
                                        firetouchinterest(handle, npcRoot, 1)
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

-- AUTO COLLECT
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
                        local part = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if part and (rootPos - part.Position).Magnitude <= 20 then
                            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt and fireproximityprompt then
                                prompt.HoldDuration = 0
                                prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 30)
                                fireproximityprompt(prompt)
                            elseif part:IsA("BasePart") and firetouchinterest then
                                firetouchinterest(root, part, 0)
                                firetouchinterest(root, part, 1)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- ESP ITEM
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
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local rootPos = char.HumanoidRootPart.Position
                    local items = Workspace:GetDescendants()
                    
                    for i, obj in ipairs(items) do
                        if not ScriptRunning or not Features.ESPItem then break end
                        
                        if obj:IsA("BasePart") and LootNames[obj.Name] then
                            local dist = math.floor((rootPos - obj.Position).Magnitude)
                            if dist <= 1000 then
                                local hl = obj:FindFirstChild("ESPHighlight") or Instance.new("Highlight", obj)
                                hl.Name = "ESPHighlight"
                                hl.FillColor = Color3.fromRGB(255, 255, 0)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.Enabled = true
                                
                                local bgui = obj:FindFirstChild("ESPTextGui")
                                if not bgui then
                                    bgui = Instance.new("BillboardGui", obj)
                                    bgui.Name = "ESPTextGui"
                                    bgui.Size = UDim2.new(0, 100, 0, 30)
                                    bgui.AlwaysOnTop = true
                                    bgui.StudsOffset = Vector3.new(0, 2, 0)
                                    local lbl = Instance.new("TextLabel", bgui)
                                    lbl.Name = "TextLabel"
                                    lbl.Size = UDim2.new(1, 0, 1, 0)
                                    lbl.BackgroundTransparency = 1
                                    lbl.TextColor3 = Color3.fromRGB(255, 255, 0)
                                    lbl.Font = Enum.Font.GothamBold
                                    lbl.TextSize = 11
                                end
                                
                                if bgui:FindFirstChild("TextLabel") then
                                    bgui.TextLabel.Text = string.format("%s [%dm]", obj.Name, dist)
                                end
                            end
                        end
                        if i % 150 == 0 then task.wait() end
                    end
                end
            end)
        end
        task.wait(1.5)
    end
end)

-- ESP NPC
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
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local rootPos = char.HumanoidRootPart.Position
                    for _, model in pairs(Workspace:GetChildren()) do
                        if not ScriptRunning or not Features.ESPNPC then break end
                        if model:IsA("Model") and model ~= char then
                            local hum = model:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 and not Players:GetPlayerFromCharacter(model) then
                                local npcRoot = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                                if npcRoot then
                                    local dist = math.floor((rootPos - npcRoot.Position).Magnitude)
                                    local hl = model:FindFirstChild("NPCHighlight") or Instance.new("Highlight", model)
                                    hl.Name = "NPCHighlight"
                                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    hl.Enabled = true
                                    
                                    local bgui = npcRoot:FindFirstChild("NPCTextGui")
                                    if not bgui then
                                        bgui = Instance.new("BillboardGui", npcRoot)
                                        bgui.Name = "NPCTextGui"
                                        bgui.Size = UDim2.new(0, 120, 0, 30)
                                        bgui.AlwaysOnTop = true
                                        bgui.StudsOffset = Vector3.new(0, 3, 0)
                                        local lbl = Instance.new("TextLabel", bgui)
                                        lbl.Name = "TextLabel"
                                        lbl.Size = UDim2.new(1, 0, 1, 0)
                                        lbl.BackgroundTransparency = 1
                                        lbl.TextColor3 = Color3.fromRGB(255, 50, 50)
                                        lbl.Font = Enum.Font.GothamBold
                                        lbl.TextSize = 11
                                    end
                                    if bgui:FindFirstChild("TextLabel") then
                                        bgui.TextLabel.Text = string.format("%s [%d HP] [%dm]", model.Name, math.floor(hum.Health), dist)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

ShowUI()
print("Strawberry Hub v1.4 - Con cu!")
