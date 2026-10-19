-- The World inspired mobile UI
-- Local UI prototype for your own Roblox Studio experience.
-- This does NOT activate abilities in the original YBA game.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Optional remotes for a game you own. If absent, buttons remain visual-only.
local remoteFolder = ReplicatedStorage:FindFirstChild("TW_Remotes")
local useAbility = remoteFolder and remoteFolder:FindFirstChild("UseAbility")
local toggleStand = remoteFolder and remoteFolder:FindFirstChild("ToggleStand")

local gui = Instance.new("ScreenGui")
gui.Name = "TheWorldMobileUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 20
gui.Parent = playerGui

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = parent
end

local function stroke(parent, thickness, color)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness
    s.Color = color or Color3.fromRGB(28, 27, 33)
    s.Parent = parent
end

local function makeAbilityButton(label, position, size, ability, cooldown)
    local button = Instance.new("TextButton")
    button.Name = ability .. "Button"
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Position = position
    button.Size = size
    button.BackgroundColor3 = Color3.fromRGB(202, 199, 205)
    button.BackgroundTransparency = 0.04
    button.Text = label
    button.TextColor3 = Color3.fromRGB(245, 244, 247)
    button.TextStrokeColor3 = Color3.fromRGB(70, 67, 76)
    button.TextStrokeTransparency = 0.12
    button.TextScaled = true
    button.TextWrapped = true
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = false
    button.Parent = gui
    corner(button)
    stroke(button, 5, Color3.fromRGB(35, 32, 39))

    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.AspectRatio = 0.72
    aspect.Parent = button

    local cooling = false
    button.Activated:Connect(function()
        if cooling then return end
        cooling = true
        local original = label

        -- Only calls remotes intended for your own experience.
        if ability == "Stand" then
            if toggleStand then toggleStand:FireServer() end
        else
            if useAbility then useAbility:FireServer(ability) end
        end

        local endAt = os.clock() + cooldown
        while os.clock() < endAt and button.Parent do
            button.Text = original .. "\n" .. math.ceil(endAt - os.clock())
            button.BackgroundColor3 = Color3.fromRGB(135, 132, 140)
            task.wait(0.1)
        end
        if button.Parent then
            button.Text = original
            button.BackgroundColor3 = Color3.fromRGB(202, 199, 205)
        end
        cooling = false
    end)
    return button
end

-- Positions are normalized to screen size to keep the layout responsive.
-- Two rows of oval ability buttons on the right, inspired by the supplied reference.
local row1Y = 0.635
local row2Y = 0.765
local startX = 0.755
local step = 0.064
local buttonSize = UDim2.fromScale(0.057, 0.145)

makeAbilityButton("Fist\nBarrage", UDim2.fromScale(startX, row1Y), buttonSize, "Barrage", 5)
makeAbilityButton("Time\nSkip", UDim2.fromScale(startX + step, row1Y), buttonSize, "TimeSkip", 7)
makeAbilityButton("Road\nRoller", UDim2.fromScale(startX + step*2, row1Y), buttonSize, "RoadRoller", 12)
makeAbilityButton("Knife\nThrow", UDim2.fromScale(startX + step*3, row1Y), buttonSize, "Knives", 4)

makeAbilityButton("Kick\nBarrage", UDim2.fromScale(startX, row2Y), buttonSize, "KickBarrage", 7)
makeAbilityButton("Heavy\nPunch", UDim2.fromScale(startX + step, row2Y), buttonSize, "M1", 0.45)
makeAbilityButton("Time\nStop", UDim2.fromScale(startX + step*2, row2Y), buttonSize, "TimeStop", 18)
makeAbilityButton("Stand\nBarrage", UDim2.fromScale(startX + step*3, row2Y), buttonSize, "Barrage", 5)

-- Stand summon button, placed lower-left like a separate utility button.
makeAbilityButton("SUMMON\nSTAND", UDim2.fromScale(0.055, 0.80),
    UDim2.fromScale(0.075, 0.17), "Stand", 0.5)

-- Basic movement/action utility circles near the bottom right.
local function makeUtility(text, x, y, symbol)
    local b = Instance.new("TextButton")
    b.Name = "Utility_" .. text
    b.AnchorPoint = Vector2.new(0.5, 0.5)
    b.Position = UDim2.fromScale(x, y)
    b.Size = UDim2.fromScale(0.055, 0.13)
    b.BackgroundColor3 = Color3.fromRGB(195, 192, 199)
    b.Text = symbol
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.fromRGB(245, 244, 247)
    b.TextStrokeTransparency = 0.15
    b.TextStrokeColor3 = Color3.fromRGB(65, 61, 70)
    b.Parent = gui
    corner(b)
    stroke(b, 5)
    return b
end

makeUtility("Block", 0.755, 0.91, "▣")
makeUtility("Dash", 0.82, 0.91, "➤")
makeUtility("Aim", 0.885, 0.91, "⊕")
makeUtility("Jump", 0.95, 0.91, "↑")

-- Desktop keyboard shortcuts for your own game.
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G and toggleStand then
        toggleStand:FireServer()
    elseif input.KeyCode == Enum.KeyCode.Z and useAbility then
        useAbility:FireServer("Barrage")
    elseif input.KeyCode == Enum.KeyCode.X and useAbility then
        useAbility:FireServer("Knives")
    elseif input.KeyCode == Enum.KeyCode.C and useAbility then
        useAbility:FireServer("TimeStop")
    end
end)
