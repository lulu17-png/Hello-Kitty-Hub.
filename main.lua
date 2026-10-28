-- ==========================================
-- Hello Kitty Roof-Scan Hub
-- Created by Lulu
-- Optimized for Delta (Fixed English Version)
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Angle = 0
local CalculatedRoofHeight = 350

-- 1. Anti-AFK Connection
if getgenv().LuluAntiAfk then 
    getgenv().LuluAntiAfk:Disconnect() 
end

getgenv().LuluAntiAfk = LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
end)

-- Global Toggles
_G.AutoFarm = false
_G.ResetOnFull = false
_G.AntiAfkWalk = false
local MaxCoins = 40

-- Smart Map Roof Scanner
local function ScanForRoofHeight()
    local CurrentMap = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("Map")
    if CurrentMap then
        local HighestY = 0
        for _, Obj in pairs(CurrentMap:GetDescendants()) do
            if Obj:IsA("BasePart") and Obj.Position.Y > HighestY and Obj.Position.Y < 600 then
                HighestY = Obj.Position.Y
            end
        end
        if HighestY > 0 then
            CalculatedRoofHeight = HighestY + 15
        end
    end
end

-- 2. GUI Creation (Delta Compatible via PlayerGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HelloKittyHub"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Parent = ScreenGui
MainPanel.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
MainPanel.Position = UDim2.new(0.1, 0, 0.2, 0)
MainPanel.Size = UDim2.new(0, 260, 0, 320)
MainPanel.Active = true
MainPanel.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainPanel

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 105, 180)
UIStroke.Thickness = 3
UIStroke.Parent = MainPanel

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainPanel
Title.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎀 Hello Kitty Coin Hub 🎀"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = Title

local Credits = Instance.new("TextLabel")
Credits.Name = "Credits"
Credits.Parent = MainPanel
Credits.BackgroundTransparency = 1
Credits.Position = UDim2.new(0, 0, 0.9, 0)
Credits.Size = UDim2.new(1, 0, 0, 25)
Credits.Font = Enum.Font.GothamItalic
Credits.Text = "🐾 by Lulu 🐾"
Credits.TextColor3 = Color3.fromRGB(255, 20, 147)
Credits.TextSize = 14

local function CreateButton(ButtonText, PosY, Callback)
    local Button = Instance.new("TextButton")
    local ButtonCorner = Instance.new("UICorner")
    local StateLabel = Instance.new("TextLabel")
    local Enabled = false

    Button.Parent = MainPanel
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.Position = UDim2.new(0.05, 0, PosY, 0)
    Button.Size = UDim2.new(0.9, 0, 0, 40)
    Button.Font = Enum.Font.GothamBold
    Button.Text = ButtonText
    Button.TextColor3 = Color3.fromRGB(255, 105, 180)
    Button.TextSize = 14

    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = Button

    StateLabel.Parent = Button
    StateLabel.BackgroundTransparency = 1
    StateLabel.Position = UDim2.new(0.8, 0, 0, 0)
    StateLabel.Size = UDim2.new(0.2, 0, 1, 0)
    StateLabel.Font = Enum.Font.GothamBold
    StateLabel.Text = "❌"
    StateLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    StateLabel.TextSize = 14

    Button.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        StateLabel.Text = Enabled and "✅" or "❌"
        StateLabel.TextColor3 = Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        Callback(Enabled)
    end)
end

-- Create Menu Buttons with Hungarian Labels for you
CreateButton("Auto-Coin Teleport", 0.2, function(Value) _G.AutoFarm = Value end)
CreateButton("Reset ha megtelt", 0.4, function(Value) _G.ResetOnFull = Value end)
CreateButton("Anti-AFK Sétálás", 0.6, function(Value) _G.AntiAfkWalk = Value end)

-- 3. Core Loop (Coin & Event Item Farming)
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoFarm then
            local Character = LocalPlayer.Character
            local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Character and Character:FindFirstChild("Humanoid")
            
            ScanForRoofHeight()

            -- MM2 Coin Bag Check
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local MainGui = PlayerGui and PlayerGui:FindFirstChild("MainGui")
            local GameFrame = MainGui and MainGui:FindFirstChild("Game")
            local CoinBagLabel = GameFrame and GameFrame:FindFirstChild("CoinBag")
            
            if _G.ResetOnFull and Humanoid and Humanoid.Health > 0 and CoinBagLabel then
                -- Safely parse container capacity text (e.g., "40/40")
                local CurrentCoins = string.match(CoinBagLabel.Text, "^(%d+)")
                if CurrentCoins and tonumber(CurrentCoins) >= MaxCoins then
                    Humanoid:BreakJoints()
                    task.wait(5)
                end
            end

            if RootPart and Humanoid and Humanoid.Health > 0 then
                local TargetCoin = nil
                
                for _, Obj in pairs(Workspace:GetDescendants()) do
                    if Obj.Name == "CoinContainer" or Obj.Name == "Coin" or Obj.Name == "Candy" or Obj.Name == "SnowToken" or Obj.Name == "Token" or Obj.Name == "Diamond" then
                        if Obj:IsA("BasePart") then
                            TargetCoin = Obj
                            break
                        end
                    end
                end

                if TargetCoin then
                    local OriginalX = RootPart.Position.X
                    local OriginalZ = RootPart.Position.Z
                    
                    RootPart.CFrame = TargetCoin.CFrame
                    task.wait(0.12)
                    RootPart.CFrame = CFrame.new(OriginalX, CalculatedRoofHeight, originalZ)
                else
                    if RootPart.Position.Y < (CalculatedRoofHeight - 5) or RootPart.Position.Y > (CalculatedRoofHeight + 5) then
                        RootPart.CFrame = CFrame.new(RootPart.Position.X, CalculatedRoofHeight, RootPart.Position.Z)
                    end
                end
            end
        end
    end
end)

-- 4. Safe Walk Loop
RunService.RenderStepped:Connect(function(DeltaTime)
    if _G.AntiAfkWalk and not _G.AutoFarm then
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChild("Humanoid")
        if Humanoid then
            Angle = Angle + (2 * DeltaTime)
            local MoveDirection = Vector3.new(math.sin(Angle) * 6, 0, math.cos(Angle) * 6)
            Humanoid:Move(MoveDirection, false)
        end
    end
end)

-- Success Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Hello Kitty Hub 🎀",
    Text = "GitHub Script Loaded! by Lulu",
    Duration = 5
})
