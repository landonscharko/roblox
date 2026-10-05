-- Daily free credit claim. Credits and last-claim time persist in a DataStore.
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DAILY_AMOUNT = 100
local COOLDOWN = 24 * 60 * 60

local store = DataStoreService:GetDataStore("Credits_v1")

local claimEvent = Instance.new("RemoteFunction")
claimEvent.Name = "ClaimCredit"
claimEvent.Parent = ReplicatedStorage

local data = {} -- [player] = { credits = number, lastClaim = number }

local function load(player)
	local ok, saved = pcall(function()
		return store:GetAsync(tostring(player.UserId))
	end)
	if not ok then
		warn("Credit load failed for", player.Name, saved)
		player:Kick("Could not load your data. Please rejoin.")
		return
	end
	data[player] = saved or { credits = 0, lastClaim = 0 }

	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local credits = Instance.new("IntValue")
	credits.Name = "Credits"
	credits.Value = data[player].credits
	credits.Parent = stats
	stats.Parent = player
end

local function save(player)
	local d = data[player]
	if not d then return end
	local ok, err = pcall(function()
		store:SetAsync(tostring(player.UserId), d)
	end)
	if not ok then warn("Credit save failed for", player.Name, err) end
end

-- Returns success, creditsOrSecondsRemaining
claimEvent.OnServerInvoke = function(player)
	local d = data[player]
	if not d then return false, 0 end
	local now = os.time()
	local remaining = d.lastClaim + COOLDOWN - now
	if remaining > 0 then
		return false, remaining
	end
	d.lastClaim = now
	d.credits += DAILY_AMOUNT
	player.leaderstats.Credits.Value = d.credits
	save(player)
	return true, d.credits
end

Players.PlayerAdded:Connect(load)
Players.PlayerRemoving:Connect(function(player)
	save(player)
	data[player] = nil
end)
for _, p in Players:GetPlayers() do task.spawn(load, p) end

game:BindToClose(function()
	for _, p in Players:GetPlayers() do save(p) end
end)
