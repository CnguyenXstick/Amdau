local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- UI Strawberry Hub
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "StrawberryHub"
MainFrame.Size = UDim2.new(0, 220, 0, 420)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Viền 7 màu xoay
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 3
task.spawn(function()
    while true do
        for i = 0, 1, 0.02 do
            UIStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.05)
        end
    end
end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "Strawberry Hub"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold

-- Tạo nút bấm
local function CreateBtn(text, pos)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Text = text; btn.Size = UDim2.new(0.8, 0, 0, 30)
    btn.Position = UDim2.new(0.1, 0, pos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    return btn
end

local SpeedInput = Instance.new("TextBox", MainFrame)
SpeedInput.PlaceholderText = "Speed (50)"; SpeedInput.Size = UDim2.new(0.8, 0, 0, 30)
SpeedInput.Position = UDim2.new(0.1, 0, 0.1, 0); SpeedInput.BackgroundColor3 = Color3.fromRGB(40,40,40)

local FlyBtn = CreateBtn("Fly: OFF", 0.25)
local ESPBtn = CreateBtn("ESP Items: OFF", 0.35)
local AutoCollectBtn = CreateBtn("Auto Collect: OFF", 0.45)
local FullBrightBtn = CreateBtn("Full Bright: OFF", 0.55)

local flyOn, espOn, collectOn, brightOn = false, false, false, false

-- Chức năng
FlyBtn.MouseButton1Click:Connect(function()
    flyOn = not flyOn; FlyBtn.Text = "Fly: "..(flyOn and "ON" or "OFF")
    local char = LocalPlayer.Character
    if flyOn then
        local bv = Instance.new("BodyVelocity", char.HumanoidRootPart); bv.Name = "FlyVel"
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    else
        if char.HumanoidRootPart:FindFirstChild("FlyVel") then char.HumanoidRootPart.FlyVel:Destroy() end
    end
end)

ESPBtn.MouseButton1Click:Connect(function()
    espOn = not espOn; ESPBtn.Text = "ESP Items: "..(espOn and "ON" or "OFF")
end)

AutoCollectBtn.MouseButton1Click:Connect(function()
    collectOn = not collectOn; AutoCollectBtn.Text = "Auto Collect: "..(collectOn and "ON" or "OFF")
end)

FullBrightBtn.MouseButton1Click:Connect(function()
    brightOn = not brightOn; FullBrightBtn.Text = "Full Bright: "..(brightOn and "ON" or "OFF")
end)

-- Vòng lặp chính
RunService.RenderStepped:Connect(function()
    if flyOn and LocalPlayer.Character:FindFirstChild("FlyVel") then
        local speed = tonumber(SpeedInput.Text) or 50
        local cam = Workspace.CurrentCamera
        local dir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        LocalPlayer.Character.HumanoidRootPart.FlyVel.Velocity = dir * speed
    end
    if brightOn then Lighting.Brightness = 2; Lighting.ClockTime = 14 end
end)

-- ESP & Auto Collect
task.spawn(function()
    while true do
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name == "La bàn" or obj.Name == "Scrap") then
                if espOn and not obj:FindFirstChild("Highlight") then Instance.new("Highlight", obj) end
                if collectOn then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                    if dist < 15 then obj.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- Auto TP lên ghế (Quét chữ Khí)
task.spawn(function()
    while true do
        for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and string.find(gui.Text, "Khí") then
                local val = tonumber(gui.Text:match("%d+"))
                if val and val <= 10 then
                    local seat = Workspace:FindFirstChild("Seat", true) or Workspace:FindFirstChild("VehicleSeat", true)
                    if seat then LocalPlayer.Character.HumanoidRootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0) end
                end
            end
        end
        task.wait(0.5)
    end
end)
