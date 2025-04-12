local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local tool = nil
local remote = nil
local rocket = nil
local holding = false
local enabled = false

local function startRapidFire()
    RunService:BindToRenderStep(
        'RPGRapidFire',
        Enum.RenderPriority.Input.Value,
        function()
            if enabled and holding and tool and remote and rocket then
                remote:FireServer(mouse.Hit.Position, rocket.Position)
            end
        end
    )
end

local function stopRapidFire()
    RunService:UnbindFromRenderStep('RPGRapidFire')
end

player.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA('Tool') and child:FindFirstChild('Remote') then
            tool = child
            remote = tool:WaitForChild('Remote')
            rocket = tool:WaitForChild('Folder'):WaitForChild('Rocket')
        end
    end)
end)

task.spawn(function()
    while true do
        local char = player.Character
        if char then
            local t = char:FindFirstChildOfClass('Tool')
            if t and t:FindFirstChild('Remote') then
                tool = t
                remote = tool:WaitForChild('Remote')
                rocket = tool:WaitForChild('Folder'):WaitForChild('Rocket')
                break
            end
        end
        wait(0.2)
    end
end)

mouse.Button1Down:Connect(function()
    if enabled then
        holding = true
        startRapidFire()
    end
end)

mouse.Button1Up:Connect(function()
    holding = false
    stopRapidFire()
end)

local gui = Instance.new('ScreenGui', game.CoreGui)
gui.Name = 'RPGGui'

local frame = Instance.new('Frame', gui)
frame.Size = UDim2.new(0, 250, 0, 100)
frame.Position = UDim2.new(0.5, -125, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true -- movebar

local title = Instance.new('TextLabel', frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = 'RPG Rapid Fire by Jan (iBadassCheats)'
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local checkbox = Instance.new('TextButton', frame)
checkbox.Size = UDim2.new(0.8, 0, 0, 35)
checkbox.Position = UDim2.new(0.1, 0, 0.55, 0)
checkbox.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
checkbox.Font = Enum.Font.SourceSans
checkbox.TextSize = 18
checkbox.Text = 'Rapid Fire: OFF'

checkbox.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        checkbox.Text = 'Rapid Fire: ON'
        checkbox.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    else
        checkbox.Text = 'Rapid Fire: OFF'
        checkbox.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
    end
end)
