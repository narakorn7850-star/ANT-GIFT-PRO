
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local GUI = Instance.new("ScreenGui")
GUI.Name = "ANT_GIFT_PRO"
GUI.ResetOnSpawn = false
GUI.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame", GUI)
Frame.Size = UDim2.fromOffset(270, 260)
Frame.Position = UDim2.new(.5,-135,.5,-130)
Frame.BackgroundColor3 = Color3.fromRGB(25,28,40)
Frame.Active = true
Frame.Draggable = true

local function make(class, text, pos, size)
    local obj = Instance.new(class)
    obj.Text = text
    obj.Position = pos
    obj.Size = size
    obj.Parent = Frame
    return obj
end

local Title = make("TextLabel","ANT GIFT PRO",
    UDim2.fromOffset(10,5),UDim2.fromOffset(210,30))
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 20

local Min = make("TextButton","-",
    UDim2.new(1,-40,0,5),UDim2.fromOffset(30,30))

local Search = make("TextBox","",
    UDim2.fromOffset(10,45),UDim2.fromOffset(250,30))
Search.PlaceholderText = "Search player..."

local List = Instance.new("ScrollingFrame",Frame)
List.Position = UDim2.fromOffset(10,85)
List.Size = UDim2.fromOffset(250,100)
List.CanvasSize = UDim2.new()
List.ScrollBarThickness = 4

local Layout = Instance.new("UIListLayout",List)
Layout.Padding = UDim.new(0,3)

local Status = make("TextLabel","Status: Waiting",
    UDim2.fromOffset(10,190),UDim2.fromOffset(250,25))
Status.TextColor3 = Color3.new(1,1,1)

local Start = make("TextButton","START",
    UDim2.fromOffset(10,220),UDim2.fromOffset(120,30))
Start.BackgroundColor3 = Color3.fromRGB(30,150,70)

local Stop = make("TextButton","STOP",
    UDim2.fromOffset(140,220),UDim2.fromOffset(120,30))
Stop.BackgroundColor3 = Color3.fromRGB(180,45,45)

local Selected = nil
local Running = false

local function Refresh()
    for _,v in ipairs(List:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Name:lower():find(Search.Text:lower(),1,true) then
            local B = Instance.new("TextButton",List)
            B.Size = UDim2.new(1,-5,0,28)
            B.Text = p.Name
            B.MouseButton1Click:Connect(function()
                Selected = p
                Status.Text = "Selected: "..p.Name
            end)
        end
    end

    task.wait()
    List.CanvasSize = UDim2.fromOffset(0,Layout.AbsoluteContentSize.Y)
end

Search:GetPropertyChangedSignal("Text"):Connect(Refresh)
Players.PlayerAdded:Connect(Refresh)
Players.PlayerRemoving:Connect(Refresh)

Start.MouseButton1Click:Connect(function()
    if not Selected then
        Status.Text = "Select player first!"
        return
    end
    Running = true
    Status.Text = "Monitoring: "..Selected.Name
end)

Stop.MouseButton1Click:Connect(function()
    Running = false
    Status.Text = "Stopped"
end)

local Minimized = false
Min.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Frame.Size = Minimized and UDim2.fromOffset(270,40)
        or UDim2.fromOffset(270,260)
    for _,v in ipairs(Frame:GetChildren()) do
        if v ~= Min and v ~= Title then
            v.Visible = not Minimized
        end
    end
    Min.Text = Minimized and "+" or "-"
end)

Refresh()

