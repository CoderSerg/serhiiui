--[[
    SerhiiUI - secure admin menu example

    ⚠️ READ THIS FIRST - THE SECURITY MODEL ⚠️

    SerhiiUI is a CLIENT-SIDE UI library. Element callbacks run on the player's
    own machine, so an exploiter can run them, fake them, or call your code
    directly. "The menu only opens for admins" means NOTHING on its own.

    The ONLY safe pattern for an admin menu:
      1. The client UI just ASKS the server (fires a RemoteEvent).
      2. The SERVER independently checks the requester is really an admin
         before doing anything privileged. The server is the source of truth.

    This file contains BOTH halves. Split them into two scripts:
      • SERVER  -> a Script in ServerScriptService   (the block marked SERVER)
      • CLIENT  -> a LocalScript in StarterPlayerScripts (the block marked CLIENT)
    Put the SerhiiUI source in a ModuleScript named "SerhiiUI" in ReplicatedStorage.
]]

--==================================================================--
-- SERVER  -  ServerScriptService > AdminServer (Script)
--==================================================================--
--[[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Source of truth. The client has a copy for UX only; THIS is what's enforced.
local ADMINS = {
    [1] = true,          -- replace with real UserIds
    [156] = true,
}

local function isAdmin(player)
    return player ~= nil and ADMINS[player.UserId] == true
end

local remote = Instance.new("RemoteEvent")
remote.Name = "AdminAction"
remote.Parent = ReplicatedStorage

remote.OnServerEvent:Connect(function(player, action, arg)
    -- EVERY request is re-checked here. Never trust that the client gated it.
    if not isAdmin(player) then
        warn(("[Admin] %s (%d) tried '%s' without permission")
            :format(player.Name, player.UserId, tostring(action)))
        return
    end

    if action == "kick" and typeof(arg) == "Instance" and arg:IsA("Player") then
        arg:Kick("Kicked by an admin.")

    elseif action == "announce" and type(arg) == "string" then
        -- keep server-authoritative limits on anything the client sends
        local msg = string.sub(arg, 1, 200)
        for _, p in ipairs(Players:GetPlayers()) do
            -- fire your own announcement RemoteEvent to clients here
        end

    elseif action == "speed" and type(arg) == "number" then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = math.clamp(arg, 16, 200) -- clamp on the server, always
        end
    end
end)
]]

--==================================================================--
-- CLIENT  -  StarterPlayerScripts > AdminClient (LocalScript)
--==================================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Client-side admin list is for UX only (so non-admins never see the menu).
-- It is NOT a security boundary - the server checks again on every action.
local ADMINS = {
	[1] = true,
	[156] = true,
}
if not ADMINS[LocalPlayer.UserId] then
	return -- not an admin: don't even build the menu
end

local remote = ReplicatedStorage:WaitForChild("AdminAction")
local SerhiiUI = require(ReplicatedStorage:WaitForChild("SerhiiUI"))

-- Named Lucide icons can't load in a published game (no HttpGet/loadstring on
-- the client), so register your own image assets by name first:
SerhiiUI:AddIcons({
	shield = "rbxassetid://10709810572",  -- replace with your own asset ids
	boot = "rbxassetid://10709790644",
	megaphone = "rbxassetid://10723415903",
	gauge = "rbxassetid://10709788537",
})

local Window = SerhiiUI:CreateWindow({
	Title = "Admin Menu",
	SubTitle = "server-validated",
	Icon = "shield",
	ToggleKey = Enum.KeyCode.RightControl,
})

local Tab = Window:Tab({ Title = "Moderation", Icon = "boot" })

-- Kick: the client only asks; the server decides + acts.
local targetName = ""
Tab:Input({
	Title = "Target player",
	Icon = "boot",
	Placeholder = "exact username",
	Callback = function(text)
		targetName = text
	end,
})
Tab:Button({
	Title = "Kick player",
	Icon = "boot",
	Callback = function()
		local target = Players:FindFirstChild(targetName)
		if target then
			remote:FireServer("kick", target) -- request only
		else
			SerhiiUI:Notify({ Title = "Kick", Content = "No player named '" .. targetName .. "'." })
		end
	end,
})

Tab:Divider()

-- Announce: server clamps/sanitizes the text it receives.
local message = ""
Tab:Input({
	Title = "Announcement",
	Icon = "megaphone",
	Placeholder = "message…",
	Callback = function(text)
		message = text
	end,
})
Tab:Button({
	Title = "Broadcast",
	Icon = "megaphone",
	Callback = function()
		if message ~= "" then
			remote:FireServer("announce", message)
		end
	end,
})

-- Speed: the slider just requests a value; the server clamps it.
Tab:Slider({
	Title = "My walk speed",
	Icon = "gauge",
	Value = { Min = 16, Max = 200, Default = 16 },
	Step = 1,
	Callback = function(value)
		remote:FireServer("speed", value)
	end,
})

SerhiiUI:Notify({ Title = "Admin", Content = "Menu ready (RightControl to toggle)." })
