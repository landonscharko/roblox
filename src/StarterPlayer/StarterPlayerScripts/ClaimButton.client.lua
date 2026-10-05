-- Builds a "Claim Free Credits" button and calls the server on click.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local claim = ReplicatedStorage:WaitForChild("ClaimCredit")

local gui = Instance.new("ScreenGui")
gui.Name = "ClaimCreditGui"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(220, 50)
button.Position = UDim2.new(0.5, -110, 1, -80)
button.Text = "Claim Free Credits"
button.TextScaled = true
button.Parent = gui

local busy = false
button.Activated:Connect(function()
	if busy then return end
	busy = true
	local ok, value = claim:InvokeServer()
	if ok then
		button.Text = "Claimed! Total: " .. value
	else
		local h = math.ceil(value / 3600)
		button.Text = "Come back in ~" .. h .. "h"
	end
	task.wait(3)
	button.Text = "Claim Free Credits"
	busy = false
end)
