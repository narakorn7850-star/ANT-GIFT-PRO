
-- ANT GIFT PRO - Build An Ant Empire
-- Player selector + follow + Gift prompt detection
-- Gift sending remains handled by the game's own E interaction.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local PromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local SelectedPlayer = nil
local Following = false
local FollowDistance = 5
local PromptVisible = nil
local FollowToken = 0

-- Remove previous GUI
local old = CoreGui:FindFirstChild("ANT_GIFT_PRO")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ANT_GIFT_PRO"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.fromOffset(290, 365)
frame.Position = UDim2.new(0.5, -145, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local function makeLabel(text, y, h, size)
    local obj = Instance.new("TextLabel")
    obj.Parent = frame
    obj.Position = UDim2.new(0, 10, 0, y)
    obj.Size = UDim2.new(1, -20, 0, h)
    obj.BackgroundTransparency = 1
    obj.TextColor3 = Color3.new(1, 1, 1)
    obj.Text = text
    obj.TextSize = size or 13
    obj.Font = Enum.Font.Gotham
    obj.TextWrapped = true
    return obj
end

local function makeButton(text, y, color)
    local obj = Instance.new("TextButton")
    obj.Parent = frame
    obj.Position = UDim2.new(0, 10, 0, y)
    obj.Size = UDim2.new(1, -20, 0, 32)
    obj.BackgroundColor3 = color
    obj.TextColor3 = Color3.new(1, 1, 1)
    obj.Text = text
    obj.TextSize = 14
    obj.Font = Enum.Font.GothamBold
    obj.BorderSizePixel = 0
    return obj
end

makeLabel("ANT GIFT PRO", 5, 30, 19).TextColor3 =
    Color3.fromRGB(255, 210, 70)

local search = Instance.new("TextBox")
search.Parent = frame
search.Position = UDim2.new(0, 10, 0, 40)
search.Size = UDim2.new(1, -20, 0, 30)
search.BackgroundColor3 = Color3.fromRGB(45, 49, 60)
search.TextColor3 = Color3.new(1, 1, 1)
search.PlaceholderText = "Search player..."
search.Text = ""
search.TextSize = 14
search.Font = Enum.Font.Gotham
search.BorderSizePixel = 0

local list = Instance.new("ScrollingFrame")
list.Parent = frame
list.Position = UDim2.new(0, 10, 0, 78)
list.Size = UDim2.new(1, -20, 0, 125)
list.BackgroundColor3 = Color3.fromRGB(35, 39, 48)
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.CanvasSize = UDim2.new()

local status = makeLabel("Select a player", 208, 42, 13)
local start = makeButton(
    "START FOLLOW", 253, Color3.fromRGB(35, 145, 75)
)
local stop = makeButton(
    "STOP FOLLOW", 290, Color3.fromRGB(180, 55, 55)
)
local hint = makeLabel(
    "Hold your item, approach the target, then use the game's E Gift prompt.",
    326, 34, 11
)
hint.TextColor3 = Color3.fromRGB(255, 210, 100)

local function getRoot(player)
    local char = player and player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function isGiftPrompt(prompt)
    local text = (
        (prompt.ActionText or "") .. " " ..
        (prompt.ObjectText or "")
    ):lower()

    return text:find("gift", 1, true) ~= nil
        or text:find("ของขวัญ", 1, true) ~= nil
end

local function promptPosition(prompt)
    local parent = prompt.Parent

    if parent and parent:IsA("Attachment") then
        parent = parent.Parent
    end

    if parent and parent:IsA("BasePart") then
        return parent.Position
    end

    return nil
end

local function promptNearTarget(prompt, target)
    local root = getRoot(target)
    local pos = promptPosition(prompt)

    if not root or not pos then
        return false
    end

    return (root.Position - pos).Magnitude
        <= math.max(prompt.MaxActivationDistance + 3, 8)
end

PromptService.PromptShown:Connect(function(prompt)
    if SelectedPlayer
        and isGiftPrompt(prompt)
        and promptNearTarget(prompt, SelectedPlayer) then

        PromptVisible = prompt
        status.Text = "Gift prompt detected: "
            .. SelectedPlayer.Name .. ". Press E normally."
    end
end)

PromptService.PromptHidden:Connect(function(prompt)
    if PromptVisible == prompt then
        PromptVisible = nil
        status.Text = "Gift prompt hidden. Move closer."
    end
end)

local refresh

refresh = function()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local y = 0
    local query = search.Text:lower()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer
            and player.Name:lower():find(query, 1, true) then

            local button = Instance.new("TextButton")
            button.Parent = list
            button.Position = UDim2.new(0, 0, 0, y)
            button.Size = UDim2.new(1, -5, 0, 27)
            button.Text = player.Name
            button.TextSize = 13
            button.Font = Enum.Font.Gotham
            button.TextColor3 = Color3.new(1, 1, 1)
            button.BackgroundColor3 =
                SelectedPlayer == player
                and Color3.fromRGB(80, 105, 65)
                or Color3.fromRGB(55, 60, 72)
            button.BorderSizePixel = 0

            button.MouseButton1Click:Connect(function()
                SelectedPlayer = player
                PromptVisible = nil
                status.Text = "Selected: " .. player.Name
                refresh()
            end)

            y = y + 30
        end
    end

    list.CanvasSize = UDim2.new(0, 0, 0, y)
end

search:GetPropertyChangedSignal("Text"):Connect(refresh)
Players.PlayerAdded:Connect(refresh)

Players.PlayerRemoving:Connect(function(player)
    if player == SelectedPlayer then
        SelectedPlayer = nil
        Following = false
        FollowToken = FollowToken + 1
        PromptVisible = nil
        status.Text = "Target left the server"
    end
    refresh()
end)

UIS.InputBegan:Connect(function(input, processed)
    if processed or input.KeyCode ~= Enum.KeyCode.E then
        return
    end

    if not SelectedPlayer then
        status.Text = "Select a player first."
        return
    end

    if PromptVisible
        and PromptVisible.Parent
        and PromptVisible.Enabled then
        status.Text = "Gift prompt detected. The game handles E."
    else
        status.Text = "Gift prompt not detected by this script."
    end
end)

start.MouseButton1Click:Connect(function()
    if not SelectedPlayer then
        status.Text = "Select a player first."
        return
    end

    Following = true
    FollowToken = FollowToken + 1
    local token = FollowToken
    status.Text = "Following: " .. SelectedPlayer.Name

    task.spawn(function()
        while Following and token == FollowToken do
            local targetRoot = getRoot(SelectedPlayer)
            local myRoot = getRoot(LocalPlayer)
            local char = LocalPlayer.Character
            local humanoid = char
                and char:FindFirstChildOfClass("Humanoid")

            if targetRoot and myRoot and humanoid then
                local distance =
                    (myRoot.Position - targetRoot.Position).Magnitude

                if distance > FollowDistance then
                    local destination = targetRoot.Position
                        - targetRoot.CFrame.LookVector * FollowDistance

                    humanoid:MoveTo(destination)
                end
            end

            task.wait(0.3)
        end
    end)
end)

stop.MouseButton1Click:Connect(function()
    Following = false
    FollowToken = FollowToken + 1

    local root = getRoot(LocalPlayer)
    local char = LocalPlayer.Character
    local humanoid = char
        and char:FindFirstChildOfClass("Humanoid")

    if root and humanoid then
        humanoid:MoveTo(root.Position)
    end

    status.Text = "Follow stopped"
end)

refresh()
print("[ANT GIFT PRO] Loaded")
