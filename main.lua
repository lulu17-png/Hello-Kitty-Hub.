-- ==========================================
-- 🎀 Hello Kitty Roof-Scan Hub 🎀
-- ✨ Created by Lulu ✨
-- Optimized for Delta (GitHub Edition)
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local angle = 0
local CalculatedRoofHeight = 350

if getgenv().LuluAntiAfk then getgenv().LuluAntiAfk:Disconnect() end
getgenv().LuluAntiAfk = LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
end)

local _G.AutoFarm = false
local _G.ResetOnFull = false
local _G.AntiAfkWalk = false
local MaxCoins = 40

local function ScanForRoofHeight()
    local currentMap = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("Map")
    if currentMap then
        local highestY = 0
        for _, obj in pairs(currentMap:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Position.Y > highestY and obj.Position.Y < 600 then
                highestY = obj.Position.Y
            end
        end
        if highestY > 0 then
            CalculatedRoofHeight = highestY + 15
        end
    end
end

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

local function CreateButton(text, posy, callback)
    local Button = Instance.new("TextButton")
    local ButtonCorner = Instance.new("UICorner")
    local StateLabel = Instance.new("TextLabel")
    local enabled = false

    Button.Parent = MainPanel
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.Position = UDim2.new(0.05, 0, posy, 0)
    Button.Size = UDim2.new(0.9, 0, 0, 40)
    Button.Font = Enum.Font.GothamBold
    Button.Text = text
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
        enabled = not enabled
        StateLabel.Text = enabled and "✅" or "❌"
        StateLabel.TextColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(enabled)
    end)
end

CreateButton("Auto-Coin Teleport", 0.2, function(val) _G.AutoFarm = val end)
CreateButton("Reset on Full Bag", 0.4, function(val) _G.ResetOnFull = val end)
CreateButton("Anti-AFK Circle Walk", 0.6, function(val) _G.AntiAfkWalk = val end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoFarm then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChild("Humanoid")
            
            ScanForRoofHeight()

            local coinData = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Coins")
            if _G.ResetOnFull and coinData and coinData.Value >= MaxCoins and humanoid and humanoid.Health > 0 then
                humanoid:BreakJoints()
                task.wait(5)
            end

            if root and humanoid and humanoid.Health > 0 then
                local targetCoin = nil
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "CoinContainer" or obj.Name == "Coin" or obj.Name == "Candy" or obj.Name == "SnowToken" or obj.Name == "Token" or obj.Name == "Diamond" then
                        if obj:IsA("BasePart") then
                            targetCoin = obj
                            break
                        end
                    end
                end

                if targetCoin then
                    local originalX = root.Position.X
                    local originalZ = root.Position.Z
                    
                    root.CFrame = targetCoin.CFrame
                    task.wait(0.12)
                    root.CFrame = CFrame.new(originalX, CalculatedRoofHeight, originalZ)
                else
                    if root.Position.Y < (CalculatedRoofHeight - 5) or root.Position.Y > (CalculatedRoofHeight + 5) then
                        root.CFrame = CFrame.new(root.Position.X, CalculatedRoofHeight, root.Position.Z)
                    end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function(deltaTime)
    if _G.AntiAfkWalk and not _G.AutoFarm then
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
            angle = angle + (2 * deltaTime)
            local moveDirection = Vector3.new(math.sin(angle) * 6, 0, math.cos(angle) * 6)
            humanoid:Move(moveDirection, false)
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Hello Kitty Hub 🎀",
    Text = "GitHub Szkript sikeresen elindult! by Lulu",
    Duration = 5
})
