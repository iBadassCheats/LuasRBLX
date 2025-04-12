local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local tool = nil
local remote = nil
local rocket = nil
local holding = false
local enabled = false
local extraShots = 5 -- <- anpassen wie viele Schüsse du beim Klick willst

local function startRapidFire()
    RunService:BindToRenderStep(
        'RPGRapidFire',
        Enum.RenderPriority.Input.Value,
        function()
            if enabled and holding then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player then
                        local char = plr.Character
                        if char then
                            local tool = char:FindFirstChildOfClass('Tool')
                            if tool and tool:FindFirstChild('Remote') and tool:FindFirstChild('Folder') then
                                local remote = tool:FindFirstChild('Remote')
                                local rocket = tool:FindFirstChild('Folder'):FindFirstChild('Rocket')
                                if remote and rocket then
                                    remote:FireServer(mouse.Hit.Position, rocket.Position)
                                end
                            end
                        end
                    end
                end
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
    holding = true
    if enabled then
        startRapidFire()
    else
        if remote and rocket then
            for i = 1, extraShots do
                local direction = (mouse.Hit.Position - rocket.Position).Unit * 1000
                remote:FireServer(rocket.Position + direction, rocket.Position)
            end
        end
    end
end)

mouse.Button1Up:Connect(function()
    holding = false
    stopRapidFire()
end)

-- Haupt GUI
local gui = Instance.new('ScreenGui', game.CoreGui)
gui.Name = 'RPGGui'
gui.ResetOnSpawn = false

local frame = Instance.new('Frame', gui)
frame.Size = UDim2.new(0, 250, 0, 130)
frame.Position = UDim2.new(0.5, -125, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

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

-- Externes transparentes Fenster für RPG-Spieler
local listGui = Instance.new("ScreenGui", game.CoreGui)
listGui.Name = "RPGListGui"
listGui.ResetOnSpawn = false
listGui.IgnoreGuiInset = true

local listFrame = Instance.new("Frame", listGui)
listFrame.Size = UDim2.new(0, 300, 0, 40)
listFrame.Position = UDim2.new(0.5, -150, 0, 50)
listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
listFrame.BackgroundTransparency = 0.5
listFrame.Active = true
listFrame.Draggable = true

local playerListLabel = Instance.new("TextLabel", listFrame)
playerListLabel.Size = UDim2.new(1, -10, 1, 0)
playerListLabel.Position = UDim2.new(0, 5, 0, 0)
playerListLabel.BackgroundTransparency = 1
playerListLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
playerListLabel.Font = Enum.Font.SourceSans
playerListLabel.TextSize = 18
playerListLabel.Text = "Mit RPG: Wird geladen..."

-- Durchklickbar
listGui.DisplayOrder = 10
listGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
listFrame.ZIndex = 0
playerListLabel.ZIndex = 1

local function hasRPG(plr)
    local char = plr.Character
    if char then
        local tool = char:FindFirstChildOfClass('Tool')
        if tool and tool:FindFirstChild('Remote') and tool:FindFirstChild('Folder') and tool.Folder:FindFirstChild('Rocket') then
            return true
        end
    end
    local backpack = plr:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("Remote") and item:FindFirstChild("Folder") and item.Folder:FindFirstChild("Rocket") then
                return true
            end
        end
    end
    return false
end

local function updateRPGPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if hasRPG(plr) then
            table.insert(list, plr.DisplayName or plr.Name)
        end
    end
    if #list > 0 then
        playerListLabel.Text = "Mit RPG: " .. table.concat(list, ", ")
    else
        playerListLabel.Text = "Mit RPG: Keiner"
    end
end

task.spawn(function()
    while true do
        updateRPGPlayerList()
        wait(2)
    end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(updateRPGPlayerList)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    plr.CharacterAdded:Connect(updateRPGPlayerList)
end
