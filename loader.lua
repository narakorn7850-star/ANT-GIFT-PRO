
-- ANT GIFT PRO - FOLLOW EDITION
-- Follow selected player. Press E manually to gift.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SelectedPlayer = nil
local Running = false
local FollowDistance = 5

local old = game:GetService("CoreGui"):FindFirstChild("ANT_GIFT_PRO")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ANT_GIFT_PRO"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 270, 0, 330)
frame.Position = UDim2.new(0.5, -135, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
frame.Active = true
frame.Draggable = true

local function makeButton(text, y, color)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -20, 0, 32)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.TextSize = 14
    return b
end

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "ANT GIFT PRO"
title.TextColor3 = Color3.fromRGB(255, 210, 70)
title.TextSize = 19

local search = Instance.new("TextBox", frame)
search.Size = UDim2.new(1, -20, 0, 30)
search.Position = UDim2.new(0, 10, 0, 40)
search.PlaceholderText = "Search player..."
search.Text = ""
search.TextSize = 14

local list = Instance.new("ScrollingFrame", frame)
list.Size = UDim2.new(1, -20, 0, 130)
list.Position = UDim2.new(0, 10, 0, 78)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 5

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 25)
status.Position = UDim2.new(0, 10, 0, 215)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1,1,1)
status.Text = "Select a player"
status.TextSize = 13

local start = makeButton("START FOLLOW", 245, Color3.fromRGB(35, 145, 75))
local stop = makeButton("STOP", 282, Color3.fromRGB(180, 55, 55))

local function refresh()
    for _, v in ipairs(list:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    local y = 0
    local query = search.Text:lower()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Name:lower():find(query, 1, true) then
            local b = Instance.new("TextButton", list)
            b.Size = UDim2.new(1, -5, 0, 27)
            b.Position = UDim2.new(0, 0, 0, y)
            b.Text = p.Name
            b.TextSize = 13
            b.BackgroundColor3 = Color3.fromRGB(55, 60, 72)
            b.TextColor3 = Color3.new(1,1,1)

            b.MouseButton1Click:Connect(function()
                SelectedPlayer = p
                status.Text = "Selected: " .. p.Name
            end)

            y = y + 30
        end
    end

    list.CanvasSize = UDim2.new(0, 0, 0, y)
end

search:GetPropertyChangedSignal("Text"):Connect(refresh)
Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(function(p)
    if SelectedPlayer == p then
        SelectedPlayer = nil
        Running = false
        status.Text = "Target left the server"
    end
    refresh()
end)

refresh()

start.MouseButton1Click:Connect(function()
    if not SelectedPlayer then
        status.Text = "Select a player first"
        return
    end

    Running = true
    status.Text = "Following: " .. SelectedPlayer.Name

    task.spawn(function()
        while Running do
            local target = SelectedPlayer
            local myChar = LocalPlayer.Character
            local targetChar = target and target.Character

            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

            if myRoot and myHum and targetRoot then
                local distance = (myRoot.Position - targetRoot.Position).Magnitude

                if distance > FollowDistance then
                    local destination = targetRoot.Position -
                        targetRoot.CFrame.LookVector * FollowDistance
                    myHum:MoveTo(destination)
                end
            end

            task.wait(0.3)
        end
    end)
end)

stop.MouseButton1Click:Connect(function()
    Running = false
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:MoveTo(hum.RootPart.Position) end
    status.Text = "Stopped"
end)

print("ANT GIFT PRO loaded")
