 --[[
    SerhiiUI - demo / showcase

    This loader works in BOTH environments:
      * Roblox Studio - place SerhiiUI's source in a ModuleScript named
        "SerhiiUI" inside ReplicatedStorage, then run this from a LocalScript. (Look at README.md for proper use in a non-executor enviorment or Studio.)
      * Executor - falls back to loading the single file from a raw URL.
]]

local SerhiiUI
do
	local moduleScript = game:GetService("ReplicatedStorage"):FindFirstChild("SerhiiUI") -- Update this with your actual ModuleScript name
	if moduleScript then
		SerhiiUI = require(moduleScript)
	else
		SerhiiUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/serhiiui/main/src/SerhiiUI.lua"))()
	end
end

-- */ Optional key system /* --
-- Uncomment to require a key before the window loads:
-- local KeySystem = {
--     Title = "SerhiiUI Hub",
--     Note = "Enter your key to continue.",
--     Key = { "serhii123", "vip-key" },   -- string or list, or use Validator = function(k) return ... end
--     SaveKey = true,                      -- remembers a valid key (executor only)
--     Folder = "SerhiiUI",
--     GetKey = "https://example.com/getkey", -- shows a "Get Key" button that copies this
-- }

-- */ Window (icons load by Lucide name) /* --
local Window = SerhiiUI:CreateWindow({
	Title = "SerhiiUI",
	SubTitle = "v" .. SerhiiUI.Version,
	Icon = "panels-top-left",            -- Lucide icon name
	Size = UDim2.fromOffset(600, 460),
	ToggleKey = Enum.KeyCode.RightControl,
	ConfigFolder = "SerhiiUI/Demo",      -- enables Window.Config (flagged elements persist)
	-- KeySystem = KeySystem,
})

-- */ Home tab example /* --
local Home = Window:Tab({ Title = "Home", Icon = "house" })

Home:Section({ Title = "Welcome" })
Home:Paragraph({
	Title = "SerhiiUI",
	Icon = "sparkles",
	Desc = "A clean UI library for Roblox script hubs. Press RightControl to hide/show.",
})
Home:Text({ Title = "Plain text supports <b>rich text</b> and colors.", Muted = true })

-- Tags: small pill badges (Title / Radius / Icon / Color). Color defaults to
-- the theme accent; text colour is auto-picked for contrast.
Home:Tag({ Title = "v" .. SerhiiUI.Version, Color = Color3.fromHex("#fbbf24") })
Home:Tag({ Title = "UI Library", Icon = "box", Color = Color3.fromHex("#34d399") })
Home:Tag({ Title = "Accent", Icon = "sparkles" }) -- no Color → follows the theme

-- Image: a full-width picture block (asset id / url / icon name).
Home:Image({ Image = "panels-top-left", Height = 90, Radius = 10 })
Home:Space({ Height = 6 })

Home:Section({ Title = "Theme" })
Home:Dropdown({
	Title = "Color theme",
	Icon = "palette",
	Values = SerhiiUI:GetThemes(),  -- all built-in themes
	Default = "Dark",
	Callback = function(theme) SerhiiUI:SetTheme(theme) end,
})

-- */ Controls tab example /* --
local Controls = Window:Tab({ Title = "Controls", Icon = "sliders-horizontal" })

Controls:Toggle({
	Title = "Enable feature",
	Icon = "power",
	Default = false,
	Flag = "FeatureEnabled",
	Callback = function(on) print("feature:", on) end,
})

Controls:Slider({
	Title = "Walk speed",
	Icon = "gauge",
	Value = { Min = 16, Max = 200, Default = 16 },
	Step = 1,
	Flag = "WalkSpeed",
	Callback = function(v)
		local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v end
	end,
})

Controls:Input({ Title = "Name", Placeholder = "type…", Flag = "Name", Callback = function(t) print(t) end })

Controls:Keybind({
	Title = "Fly bind",
	Icon = "keyboard",
	Default = Enum.KeyCode.F,
	Flag = "FlyBind",
	Callback = function() print("fly key pressed") end,
})

Controls:Colorpicker({
	Title = "ESP color",
	Icon = "paintbrush",
	Default = Color3.fromRGB(139, 92, 246),
	Flag = "EspColor",
	Callback = function(c) print("color:", c) end,
})

Controls:Dropdown({
	Title = "Targets",
	Icon = "users",
	Values = { "Players", "NPCs", "Items" },
	Multi = true,
	Flag = "Targets",
	Callback = function(sel) for k in pairs(sel) do print("target:", k) end end,
})

-- */ Config + Misc tab example /* --
local Misc = Window:Tab({ Title = "Misc", Icon = "settings" })

Misc:Section({ Title = "Config (flagged elements persist)" })
Misc:Button({ Title = "Save config", Icon = "save", Callback = function()
	Window.Config:Save("myconfig")
	SerhiiUI:Notify({ Title = "Config", Content = "Saved!" })
end })
Misc:Button({ Title = "Load config", Icon = "folder-open", Callback = function()
	Window.Config:Load("myconfig")
end })

Misc:Section({ Title = "Code block" })
Misc:Code({
	Title = "loadstring",
	Code = 'local SerhiiUI = loadstring(game:HttpGet("...SerhiiUI.lua"))()',
})

Misc:Divider()
Misc:Button({ Title = "Minimize", Icon = "minus", Callback = function() Window:Minimize() end })
Misc:Button({ Title = "Close", Icon = "x", Callback = function() Window:Close() end })

SerhiiUI:Notify({ Title = "Loaded", Content = "SerhiiUI demo is ready.", Duration = 4 })
