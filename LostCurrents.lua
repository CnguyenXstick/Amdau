local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Trạng thái tổng
local scriptRunning = true
local flyOn, collectOn, espOn, espNpcOn, killAuraOn, noclipOn, brightOn = false, false, false, false, false, false, false

-- Trạng thái & Giá trị cấu hình (Misc)
local speedOn = false
local speedValue = 32

local jumpOn = false
local jumpValue = 100

local boatSpeedOn = false
local boatSpeedValue = 150

local noFuelBoatOn = false
local boatStepSpeed = 3

local defaultAmbient = Lighting.Ambient
local defaultOutdoor = Lighting.OutdoorAmbient

local LootNames = {
    ["Scrap"] = true, ["Gold"] = true, ["Chest"] = true, ["La bàn"] = true,
    ["Compass"] = true, ["Coin"] = true, ["Loot"] = true, ["Item"] = true, ["Treasure"] = true,
    ["Thùng"] = true, ["Thung"] = true, ["Barrel"] = true, ["Crate"] = true, ["Box"] = true,
    ["Dây"] = true, ["Day"] = true, ["Rope"] = true, ["String"] = true, ["Cable"] = true
}

-- ========================================================
-- BẢO VỆ 1: HOOK CHẶN REMOTEEVENT TRỪ NHIÊN LIỆU (AUTO-RUN)
-- ========================================================
pcall(function()
    local rawmetatable = getrawmetatable(game)
    local oldNamecall = rawmetatable.__namecall
    setreadonly(rawmetatable, false)

    rawmetatable.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and self then
            local name = string.lower(self.Name)
            -- Chặn tất cả Remote gửi dữ liệu hao nhiên liệu
            if name:find("fuel") or name:find("gas") or name:find("consume") or name:find("xang") or name:find("drain") then
                return nil 
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(rawmetatable, true)
end)

-- Hàm Kéo Thả UI
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

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StrawberryHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 270)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -135)
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
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -26, 0.02, 0)
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

-- Sidebar Tabs
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 100, 1, -35)
Sidebar.Position = UDim2.new(0, 8, 0, 30)
Sidebar.BackgroundTransparency = 1

local function CreateTabButton(text, y)
    local b = Instance.new("TextButton", Sidebar)
    b.Text = text
    b.Size = UDim2.new(1, 0, 0, 28)
    b.Position = UDim2.new(0, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    return b
end

local TabMainBtn = CreateTabButton("Main", 0)
local TabMiscBtn = CreateTabButton("Misc", 34)
local TabTPBtn = CreateTabButton("TP", 68)

TabMainBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TabMainBtn.TextColor3 = Color3.new(1, 1, 1)

local function CreateContainer()
    local c = Instance.new("Frame", MainFrame)
    c.Size = UDim2.new(1, -124, 1, -38)
    c.Position = UDim2.new(0, 116, 0, 30)
    c.BackgroundTransparency = 1
    return c
end

local MainContainer = CreateContainer()
local MiscContainer = CreateContainer(); MiscContainer.Visible = false
local TPContainer = CreateContainer(); TPContainer.Visible = false

local function SetTab(activeBtn, activeContainer)
    MainContainer.Visible = false; MiscContainer.Visible = false; TPContainer.Visible = false
    TabMainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabMainBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    TabMiscBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabMiscBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    TabTPBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabTPBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)

    activeContainer.Visible = true
    activeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    activeBtn.TextColor3 = Color3.new(1, 1, 1)
end

TabMainBtn.MouseButton1Click:Connect(function() SetTab(TabMainBtn, MainContainer) end)
TabMiscBtn.MouseButton1Click:Connect(function() SetTab(TabMiscBtn, MiscContainer) end)
TabTPBtn.MouseButton1Click:Connect(function() SetTab(TabTPBtn, TPContainer) end)

local function CreateButton(text, y, parent, widthScale, xPos)
    local b = Instance.new("TextButton", parent)
    b.Text = text
    b.Size = UDim2.new(widthScale or 1, 0, 0, 24)
    b.Position = UDim2.new(xPos or 0, 0, y, 0)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    return b
end

-- TAB MAIN
local FlySpeedInput = Instance.new("TextBox", MainContainer)
FlySpeedInput.PlaceholderText = "Vận tốc Fly (VD: 50)"
FlySpeedInput.Text = "50"
FlySpeedInput.Size = UDim2.new(0.48, 0, 0, 24)
FlySpeedInput.Position = UDim2.new(0, 0, 0, 0)
FlySpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlySpeedInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", FlySpeedInput).CornerRadius = UDim.new(0, 4)

local FlyBtn = CreateButton("Fly: OFF", 0, MainContainer, 0.48, 0.52)

local KillDistInput = Instance.new("TextBox", MainContainer)
KillDistInput.PlaceholderText = "Tầm Kill Aura (VD: 25)"
KillDistInput.Text = "25"
KillDistInput.Size = UDim2.new(0.48, 0, 0, 24)
KillDistInput.Position = UDim2.new(0, 0, 0.14, 0)
KillDistInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KillDistInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", KillDistInput).CornerRadius = UDim.new(0, 4)

local KillAuraBtn = CreateButton("Kill Aura: OFF", 0.14, MainContainer, 0.48, 0.52)
local CollectBtn = CreateButton("Auto Lụm: OFF", 0.28, MainContainer, 0.48, 0)
local ESPBtn = CreateButton("ESP Item: OFF", 0.28, MainContainer, 0.48, 0.52)
local ESPNpcBtn = CreateButton("ESP NPC (Đỏ): OFF", 0.42, MainContainer, 1, 0)

-- TAB MISC
local BrightBtn = CreateButton("Full Bright: OFF", 0, MiscContainer, 1, 0)
local NoclipBtn = CreateButton("Noclip: OFF", 0.13, MiscContainer, 1, 0)
local FixLagBtn = CreateButton("Fix Lag (Boost FPS)", 0.26, MiscContainer, 1, 0)

-- WalkSpeed
local SpeedInput = Instance.new("TextBox", MiscContainer)
SpeedInput.PlaceholderText = "Tốc độ chạy"
SpeedInput.Text = tostring(speedValue)
SpeedInput.Size = UDim2.new(0.48, 0, 0, 24)
SpeedInput.Position = UDim2.new(0, 0, 0.39, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 4)

local SpeedBtn = CreateButton("WalkSpeed: OFF", 0.39, MiscContainer, 0.48, 0.52)

-- JumpPower
local JumpInput = Instance.new("TextBox", MiscContainer)
JumpInput.PlaceholderText = "Lực nhảy"
JumpInput.Text = tostring(jumpValue)
JumpInput.Size = UDim2.new(0.48, 0, 0, 24)
JumpInput.Position = UDim2.new(0, 0, 0.52, 0)
JumpInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
JumpInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", JumpInput).CornerRadius = UDim.new(0, 4)

local JumpBtn = CreateButton("JumpPower: OFF", 0.52, MiscContainer, 0.48, 0.52)

-- Boat Speed
local BoatInput = Instance.new("TextBox", MiscContainer)
BoatInput.PlaceholderText = "Tốc độ thuyền"
BoatInput.Text = tostring(boatSpeedValue)
BoatInput.Size = UDim2.new(0.48, 0, 0, 24)
BoatInput.Position = UDim2.new(0, 0, 0.65, 0)
BoatInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BoatInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", BoatInput).CornerRadius = UDim.new(0, 4)

local BoatSpeedBtn = CreateButton("Boat Speed: OFF", 0.65, MiscContainer, 0.48, 0.52)

-- No-Fuel Drive
local NoFuelBtn = CreateButton("Lái Không Mất Xăng: OFF", 0.78, MiscContainer, 1, 0)

-- Cập nhật thông số từ TextBox
SpeedInput.FocusLost:Connect(function() local v = tonumber(SpeedInput.Text); if v then speedValue = v else SpeedInput.Text = tostring(speedValue) end end)
JumpInput.FocusLost:Connect(function() local v = tonumber(JumpInput.Text); if v then jumpValue = v else JumpInput.Text = tostring(jumpValue) end end)
BoatInput.FocusLost:Connect(function() local v = tonumber(BoatInput.Text); if v then boatSpeedValue = v else BoatInput.Text = tostring(boatSpeedValue) end end)

SpeedBtn.MouseButton1Click:Connect(function() 
    speedOn = not speedOn 
    SpeedBtn.Text = "WalkSpeed: "..(speedOn and "ON" or "OFF") 
    if not speedOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 
    end 
end) 

JumpBtn.MouseButton1Click:Connect(function() 
    jumpOn = not jumpOn 
    JumpBtn.Text = "JumpPower: "..(jumpOn and "ON" or "OFF") 
    if not jumpOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
        LocalPlayer.Character.Humanoid.UseJumpPower = true 
        LocalPlayer.Character.Humanoid.JumpPower = 50 
    end 
end) 

BoatSpeedBtn.MouseButton1Click:Connect(function() 
    boatSpeedOn = not boatSpeedOn 
    BoatSpeedBtn.Text = "Boat Speed: "..(boatSpeedOn and "ON" or "OFF") 
end)

NoFuelBtn.MouseButton1Click:Connect(function()
    noFuelBoatOn = not noFuelBoatOn
    NoFuelBtn.Text = "Lái Không Mất Xăng: "..(noFuelBoatOn and "ON" or "OFF")
end)

-- TAB TELEPORT
local SpecificTPBtn = CreateButton("TP Cố Định (1230, 220, 60)", 0, TPContainer, 1, 0)
local PirateBaseBtn = CreateButton("Base hải tặc", 0.14, TPContainer, 1, 0)

local CustomTPInput = Instance.new("TextBox", TPContainer)
CustomTPInput.PlaceholderText = "X, Y, Z (VD: 100, 50, -200)"
CustomTPInput.Size = UDim2.new(1, 0, 0, 24)
CustomTPInput.Position = UDim2.new(0, 0, 0.28, 0)
CustomTPInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CustomTPInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CustomTPInput).CornerRadius = UDim.new(0, 4)

local CustomTPBtn = CreateButton("TP Tọa Độ Đã Nhập", 0.42, TPContainer, 1, 0)

local function TeleportTo(x, y, z)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

SpecificTPBtn.MouseButton1Click:Connect(function() TeleportTo(1230, 220, 60) end)
PirateBaseBtn.MouseButton1Click:Connect(function() TeleportTo(-2500, 250, -1500) end)

CustomTPBtn.MouseButton1Click:Connect(function()
    local text = CustomTPInput.Text
    local coords = {}
    for num in string.gmatch(text, "[-?%d%.]+") do table.insert(coords, tonumber(num)) end
    if #coords >= 3 then TeleportTo(coords[1], coords[2], coords[3]) end
end)

-- LOGIC FIX LAG
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

-- LOGIC FLY
local flyBV, flyBG = nil, nil
local upPressed, downPressed = false, false

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space then upPressed = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then downPressed = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then upPressed = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then downPressed = false end
end)

local function StopFly()
    if flyBG then flyBG:Destroy(); flyBG = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

FlyBtn.MouseButton1Click:Connect(function()
    flyOn = not flyOn
    FlyBtn.Text = "Fly: "..(flyOn and "ON" or "OFF")

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if flyOn then
        if root and hum then
            flyBG = Instance.new("BodyGyro", root)
            flyBG.P = 9e4
            flyBG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBG.cframe = root.CFrame

            flyBV = Instance.new("BodyVelocity", root)
            flyBV.velocity = Vector3.new(0, 0, 0)
            flyBV.maxForce = Vector3.new(9e9, 9e9, 9e9)

            hum.PlatformStand = true
        end
    else
        StopFly()
    end
end)

RunService.RenderStepped:Connect(function()
    if flyOn and scriptRunning then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local cam = Workspace.CurrentCamera

            if flyBG and flyBV and hum then
                flyBG.cframe = cam.CFrame
                local speed = tonumber(FlySpeedInput.Text) or 50
                local moveDir = hum.MoveDirection

                local verticalVelocity = 0
                if upPressed then verticalVelocity = speed
                elseif downPressed then verticalVelocity = -speed end

                if moveDir.Magnitude > 0 or upPressed or downPressed then
                    local finalDir = Vector3.new(0, 0, 0)
                    if moveDir.Magnitude > 0 then
                        local relativeMove = cam.CFrame:VectorToObjectSpace(moveDir)
                        finalDir = (cam.CFrame.LookVector * -relativeMove.Z) + (cam.CFrame.RightVector * relativeMove.X)
                    end
                    flyBV.velocity = (finalDir * speed) + Vector3.new(0, verticalVelocity, 0)
                else
                    flyBV.velocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end)

-- LOGIC KILL AURA
KillAuraBtn.MouseButton1Click:Connect(function()
    killAuraOn = not killAuraOn
    KillAuraBtn.Text = "Kill Aura: "..(killAuraOn and "ON" or "OFF")
end)

task.spawn(function()
    while scriptRunning do
        if killAuraOn then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local rootPos = char.HumanoidRootPart.Position
                local maxDist = tonumber(KillDistInput.Text) or 25
                local equippedTool = char:FindFirstChildOfClass("Tool")

                if equippedTool then
                    for _, model in pairs(Workspace:GetChildren()) do
                        if model:IsA("Model") and model ~= char and model:FindFirstChildOfClass("Humanoid") then
                            local hum = model:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 and not Players:GetPlayerFromCharacter(model) then
                                local npcRoot = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                                if npcRoot then
                                    local dist = (rootPos - npcRoot.Position).Magnitude
                                    if dist <= maxDist then
                                        equippedTool:Activate()
                                        local handle = equippedTool:FindFirstChild("Handle") or equippedTool:FindFirstChildWhichIsA("BasePart")
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
            end)
        end
        task.wait(0.15)
    end
end)

-- LOGIC NOCLIP
RunService.Stepped:Connect(function()
    if noclipOn and scriptRunning then
        local char = LocalPlayer.Character
        if char then
            for _, child in pairs(char:GetDescendants()) do
                if child:IsA("BasePart") then child.CanCollide = false end
            end
        end
    end
end)

-- HÀM DỌN DẸP ESP
local function ClearESP(tag)
    for _, obj in pairs(Workspace:GetDescendants()) do
        local target = obj:FindFirstChild(tag)
        if target then target:Destroy() end
    end
end

-- CLEANUP KHI TẮT GUI
local function CleanupAll()
    scriptRunning = false
    flyOn, collectOn, espOn, espNpcOn, killAuraOn, noclipOn, brightOn = false, false, false, false, false, false, false
    speedOn, jumpOn, boatSpeedOn, noFuelBoatOn = false, false, false, false

    StopFly()

    Lighting.Ambient = defaultAmbient
    Lighting.OutdoorAmbient = defaultOutdoor

    ClearESP("ESPHighlight")
    ClearESP("ESPTextGui")
    ClearESP("NPCHighlight")
    ClearESP("NPCTextGui")

    ScreenGui:Destroy()
end

CloseBtn.MouseButton1Click:Connect(CleanupAll)

CollectBtn.MouseButton1Click:Connect(function() collectOn = not collectOn; CollectBtn.Text = "Auto Lụm: "..(collectOn and "ON" or "OFF") end)
NoclipBtn.MouseButton1Click:Connect(function() noclipOn = not noclipOn; NoclipBtn.Text = "Noclip: "..(noclipOn and "ON" or "OFF") end)

ESPBtn.MouseButton1Click:Connect(function() 
    espOn = not espOn
    ESPBtn.Text = "ESP Item: "..(espOn and "ON" or "OFF")
    if not espOn then
        ClearESP("ESPHighlight")
        ClearESP("ESPTextGui")
    end
end)

ESPNpcBtn.MouseButton1Click:Connect(function()
    espNpcOn = not espNpcOn
    ESPNpcBtn.Text = "ESP NPC (Đỏ): "..(espNpcOn and "ON" or "OFF")
    if not espNpcOn then
        ClearESP("NPCHighlight")
        ClearESP("NPCTextGui")
    end
end)

BrightBtn.MouseButton1Click:Connect(function()
    brightOn = not brightOn
    BrightBtn.Text = "Full Bright: "..(brightOn and "ON" or "OFF")
    if brightOn then
        Lighting.Ambient = Color3.new(1, 1, 1); Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = defaultAmbient; Lighting.OutdoorAmbient = defaultOutdoor
    end
end)

-- ESP ITEM + AUTO LỤM
task.spawn(function()
    while scriptRunning do
        if espOn or collectOn then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local rootPos = char.HumanoidRootPart.Position
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if not scriptRunning then break end
                    if obj:IsA("BasePart") and LootNames[obj.Name] then
                        local dist = (rootPos - obj.Position).Magnitude
                        
                        if espOn then
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
                        
                        if collectOn and dist <= 15 then
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
        task.wait(0.5)
    end
end)

-- ESP NPC MÀU ĐỎ
task.spawn(function()
    while scriptRunning do
        if espNpcOn then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local rootPos = char.HumanoidRootPart.Position

                for _, model in pairs(Workspace:GetChildren()) do
                    if not scriptRunning then break end
                    if model:IsA("Model") and model ~= char and model:FindFirstChildOfClass("Humanoid") then
                        if not Players:GetPlayerFromCharacter(model) then
                            local npcRoot = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model.PrimaryPart
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

                                    local textLabel = Instance.new("TextLabel", bgui)
                                    textLabel.Name = "NPCLabel"
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                                    textLabel.TextStrokeTransparency = 0
                                    textLabel.TextSize = 12
                                    textLabel.Font = Enum.Font.GothamBold
                                end
                                bgui.Enabled = true
                                bgui.NPCLabel.Text = string.format("[NPC] %s [%dm]", model.Name, math.floor(dist))
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
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
        task.wait(0.5)
    end
end)

-- Loop 1: Tốc độ thuyền vật lý (BodyVelocity)
task.spawn(function() 
    while scriptRunning do 
        pcall(function() 
            local char = LocalPlayer.Character 
            if char and char:FindFirstChild("Humanoid") then 
                local seat = char.Humanoid.SeatPart 
                if seat and seat:IsA("VehicleSeat") then 
                    local bv = seat:FindFirstChild("BoatSpeedBV")
                    if boatSpeedOn and not noFuelBoatOn then
                        if not bv then
                            bv = Instance.new("BodyVelocity")
                            bv.Name = "BoatSpeedBV"
                            bv.MaxForce = Vector3.new(9e5, 0, 9e5)
                            bv.Parent = seat
                        end
                        seat.MaxSpeed = boatSpeedValue
                        if seat.Throttle ~= 0 then 
                            bv.Velocity = seat.CFrame.LookVector * (seat.Throttle * boatSpeedValue)
                        else
                            bv.Velocity = Vector3.new(0, 0, 0)
                        end
                    else
                        if bv then bv:Destroy() end
                    end
                end 
            end 
        end) 
        task.wait(0.05) 
    end 
end) 

-- Loop 2: Tốc độ chạy & Lực nhảy
task.spawn(function() 
    while scriptRunning do 
        pcall(function() 
            local char = LocalPlayer.Character 
            if char and char:FindFirstChild("Humanoid") then 
                if speedOn then 
                    char.Humanoid.WalkSpeed = speedValue 
                end 
                if jumpOn then 
                    char.Humanoid.UseJumpPower = true 
                    char.Humanoid.JumpPower = jumpValue 
                end 
            end 
        end) 
        task.wait(0.1) 
    end 
end)

-- BẢO VỆ 2: DI CHUYỂN BẰNG CFRAME (LÁI KHÔNG MẤT XĂNG)
task.spawn(function()
    while scriptRunning do
        if noFuelBoatOn then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    local seat = char.Humanoid.SeatPart
                    if seat and seat:IsA("VehicleSeat") then
                        local boatModel = seat:FindFirstAncestorOfClass("Model") or seat
                        
                        -- Di chuyển tiến / lùi
                        if seat.Throttle > 0 then
                            boatModel:PivotTo(boatModel:GetPivot() + (seat.CFrame.LookVector * (boatStepSpeed * (boatSpeedValue / 50))))
                        elseif seat.Throttle < 0 then
                            boatModel:PivotTo(boatModel:GetPivot() - (seat.CFrame.LookVector * (boatStepSpeed * (boatSpeedValue / 50))))
                        end
                        
                        -- Xoay hướng
                        if seat.Steer ~= 0 then
                            boatModel:PivotTo(boatModel:GetPivot() * CFrame.Angles(0, math.rad(-seat.Steer * 3), 0))
                        end
                    end
                end
            end)
        end
        task.wait(0.03)
    end
end)
