--[[

    SerhiiUI
    A modern UI library for Roblox script hubs.

    Inspired by the look & feel of WindUI, but built from scratch with its own
    identity (violet accent, native UICorner/UIStroke styling, no external assets).

    Usage:
        local SerhiiUI = loadstring(game:HttpGet("<raw url>/src/SerhiiUI.lua"))()

        local Window = SerhiiUI:CreateWindow({
            Title = "My Hub",
            SubTitle = "v1.0",
        })

        local Tab = Window:Tab({ Title = "Main", Icon = "" })

        Tab:Button({ Title = "Click me", Callback = function() print("hi") end })

    See examples/demo.lua for a full showcase, and CLAUDE.md for architecture.

]]

--//============================================================\\--
--||                       SERVICES                            ||--
--\\============================================================//--

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))

--//============================================================\\--
--||                       CONSTANTS                           ||--
--\\============================================================//--

local FONT_FAMILY = "rbxasset://fonts/families/GothamSSm.json"

local function font(weight)
	return Font.new(FONT_FAMILY, weight or Enum.FontWeight.Medium)
end

local VERSION = "0.1.0-beta"

--//============================================================\\--
--||                         THEMES                            ||--
--\\============================================================//--
-- A theme is a flat map of semantic keys -> Color3 / number.
-- Elements register a "ThemeTag" mapping a Roblox property to one of
-- these keys; SetTheme re-applies them across every registered object.

local function hex(h)
	return Color3.fromHex(h)
end

-- buildTheme fills in the full key set from a short colour spec, so a new
-- theme only needs to specify what makes it distinct.
local function buildTheme(name, c)
	return {
		Name = name,
		Background = c.Background,
		Sidebar = c.Sidebar or c.Background,
		Element = c.Element,
		ElementHover = c.ElementHover,
		Stroke = c.Stroke or hex("#ffffff"),
		StrokeTransparency = c.StrokeTransparency or 0.92,
		Text = c.Text,
		SubText = c.SubText,
		Accent = c.Accent,
		AccentText = c.AccentText or hex("#ffffff"),
		Toggle = c.Toggle or c.Accent,
		ToggleOff = c.ToggleOff or c.ElementHover,
		Slider = c.Slider or c.Accent,
		TabText = c.SubText,
		TabTextActive = c.Text,
		TabActive = c.TabActive or c.ElementHover,
		Notification = c.Notification or c.Element,
	}
end

local Themes = {
	Dark = buildTheme("Dark", {
		Background = hex("#18181b"), Sidebar = hex("#141417"),
		Element = hex("#232328"), ElementHover = hex("#2c2c33"),
		Text = hex("#f4f4f5"), SubText = hex("#a1a1aa"),
		Accent = hex("#8b5cf6"), ToggleOff = hex("#3f3f46"),
		TabActive = hex("#27272d"), Notification = hex("#1f1f23"),
	}),
	Light = buildTheme("Light", {
		Background = hex("#f4f4f5"), Sidebar = hex("#ececef"),
		Element = hex("#ffffff"), ElementHover = hex("#e9e9ec"),
		Stroke = hex("#000000"), StrokeTransparency = 0.9,
		Text = hex("#18181b"), SubText = hex("#71717a"),
		Accent = hex("#7c3aed"), ToggleOff = hex("#d4d4d8"),
		TabActive = hex("#e4e4e7"), Notification = hex("#ffffff"),
	}),
	Aqua = buildTheme("Aqua", {
		Background = hex("#0d1b1e"), Sidebar = hex("#0a1517"),
		Element = hex("#13282c"), ElementHover = hex("#193439"),
		Stroke = hex("#5eead4"), StrokeTransparency = 0.9,
		Text = hex("#ecfeff"), SubText = hex("#7dd3c8"),
		Accent = hex("#14b8a6"), AccentText = hex("#06302b"),
		ToggleOff = hex("#1f4a4a"), Slider = hex("#2dd4bf"),
		TabActive = hex("#163236"), Notification = hex("#102328"),
	}),
	Rose = buildTheme("Rose", {
		Background = hex("#1f0a12"), Sidebar = hex("#180810"),
		Element = hex("#2c1019"), ElementHover = hex("#3a1622"),
		Stroke = hex("#fda4af"), StrokeTransparency = 0.9,
		Text = hex("#fff1f2"), SubText = hex("#e8849b"),
		Accent = hex("#f43f5e"), ToggleOff = hex("#4a1d28"),
		TabActive = hex("#36141f"), Notification = hex("#260c15"),
	}),
	Emerald = buildTheme("Emerald", {
		Background = hex("#06140f"), Sidebar = hex("#040f0b"),
		Element = hex("#0c241a"), ElementHover = hex("#103024"),
		Stroke = hex("#6ee7b7"), StrokeTransparency = 0.9,
		Text = hex("#ecfdf5"), SubText = hex("#6ee7a8"),
		Accent = hex("#10b981"), AccentText = hex("#03241a"),
		ToggleOff = hex("#163a2c"), TabActive = hex("#102c20"),
		Notification = hex("#081b14"),
	}),
	Indigo = buildTheme("Indigo", {
		Background = hex("#0f0f1f"), Sidebar = hex("#0b0b18"),
		Element = hex("#1a1a33"), ElementHover = hex("#222244"),
		Stroke = hex("#a5b4fc"), StrokeTransparency = 0.9,
		Text = hex("#eef2ff"), SubText = hex("#9aa3e0"),
		Accent = hex("#6366f1"), ToggleOff = hex("#2a2a52"),
		TabActive = hex("#1f1f3d"), Notification = hex("#141428"),
	}),
	Amber = buildTheme("Amber", {
		Background = hex("#1c1404"), Sidebar = hex("#150f03"),
		Element = hex("#2a2009"), ElementHover = hex("#382b0d"),
		Stroke = hex("#fcd34d"), StrokeTransparency = 0.9,
		Text = hex("#fffbeb"), SubText = hex("#d6b465"),
		Accent = hex("#f59e0b"), AccentText = hex("#2a1d03"),
		ToggleOff = hex("#473714"), TabActive = hex("#33270c"),
		Notification = hex("#241a06"),
	}),
	Crimson = buildTheme("Crimson", {
		Background = hex("#160606"), Sidebar = hex("#100404"),
		Element = hex("#241010"), ElementHover = hex("#321616"),
		Stroke = hex("#fca5a5"), StrokeTransparency = 0.9,
		Text = hex("#fef2f2"), SubText = hex("#cf8a8a"),
		Accent = hex("#dc2626"), ToggleOff = hex("#421b1b"),
		TabActive = hex("#2e1414"), Notification = hex("#1e0a0a"),
	}),
	Midnight = buildTheme("Midnight", {
		Background = hex("#0a0f1e"), Sidebar = hex("#070b16"),
		Element = hex("#121a30"), ElementHover = hex("#1a2440"),
		Stroke = hex("#93c5fd"), StrokeTransparency = 0.9,
		Text = hex("#dbeafe"), SubText = hex("#7f9ad1"),
		Accent = hex("#2563eb"), ToggleOff = hex("#243150"),
		TabActive = hex("#16213d"), Notification = hex("#0d1426"),
	}),
	Mocha = buildTheme("Mocha", {
		Background = hex("#1a1410"), Sidebar = hex("#130e0b"),
		Element = hex("#271e18"), ElementHover = hex("#332820"),
		Stroke = hex("#d6bfa8"), StrokeTransparency = 0.9,
		Text = hex("#f5ece2"), SubText = hex("#b59c83"),
		Accent = hex("#c08457"), AccentText = hex("#241813"),
		ToggleOff = hex("#42342a"), TabActive = hex("#2e241c"),
		Notification = hex("#221a14"),
	}),
	Neon = buildTheme("Neon", {
		Background = hex("#0a0a12"), Sidebar = hex("#070710"),
		Element = hex("#13131f"), ElementHover = hex("#1c1c2e"),
		Stroke = hex("#22d3ee"), StrokeTransparency = 0.85,
		Text = hex("#f0f9ff"), SubText = hex("#8b8bb0"),
		Accent = hex("#e635c8"), ToggleOff = hex("#262640"),
		Slider = hex("#22d3ee"), TabActive = hex("#19192b"),
		Notification = hex("#101019"),
	}),
}

--//============================================================\\--
--||                       LIBRARY ROOT                        ||--
--\\============================================================//--

local Library = {
	Version = VERSION,
	Theme = Themes.Dark,
	ThemeName = "Dark",
	Themes = Themes,
	Flags = {}, -- Flag -> element, for config / value lookups
	Connections = {}, -- tracked signal connections for :Destroy cleanup
	ThemeObjects = {}, -- { Object, Props } entries for theme re-application
	Windows = {},
}

--//============================================================\\--
--||                    INSTANCE CREATION                      ||--
--\\============================================================//--

local DefaultProps = {
	Frame = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1) },
	CanvasGroup = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1) },
	ScrollingFrame = { BorderSizePixel = 0, ScrollBarImageTransparency = 1, Active = true },
	TextLabel = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = font(),
		Text = "",
		RichText = true,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
	},
	TextButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		FontFace = font(),
		Text = "",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
	},
	TextBox = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		FontFace = font(),
		Text = "",
		ClearTextOnFocus = false,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
	},
	ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0 },
	ImageButton = { BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false },
}

-- Register a theme tag so the object's properties track theme changes.
local function tag(object, props)
	table.insert(Library.ThemeObjects, { Object = object, Props = props })
	for prop, key in pairs(props) do
		local value = Library.Theme[key]
		if value ~= nil then
			object[prop] = value
		end
	end
end

-- New(className, properties, children) - the workhorse builder.
-- `ThemeTag` is a special property: { RobloxProperty = "ThemeKey", ... }
local function New(className, props, children)
	local object = Instance.new(className)

	local defaults = DefaultProps[className]
	if defaults then
		for k, v in pairs(defaults) do
			object[k] = v
		end
	end

	local themeTag
	if props then
		themeTag = props.ThemeTag
		for k, v in pairs(props) do
			if k ~= "ThemeTag" then
				object[k] = v
			end
		end
	end

	if children then
		for _, child in ipairs(children) do
			child.Parent = object
		end
	end

	if themeTag then
		tag(object, themeTag)
	end

	return object
end

--//============================================================\\--
--||                        UTILITIES                          ||--
--\\============================================================//--

local function tween(object, time, props, style, direction)
	local info = TweenInfo.new(
		time or 0.18,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)
	local t = TweenService:Create(object, info, props)
	t:Play()
	return t
end

local function connect(signal, fn)
	local conn = signal:Connect(fn)
	table.insert(Library.Connections, conn)
	return conn
end

local function safeCallback(fn, ...)
	if typeof(fn) ~= "function" then
		return
	end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[SerhiiUI] callback error: " .. tostring(err))
	end
end

local function corner(radius)
	return New("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

local function padding(all, extra)
	local p = New("UIPadding", {
		PaddingTop = UDim.new(0, all),
		PaddingBottom = UDim.new(0, all),
		PaddingLeft = UDim.new(0, all),
		PaddingRight = UDim.new(0, all),
	})
	if extra then
		for k, v in pairs(extra) do
			p[k] = v
		end
	end
	return p
end

local function listLayout(gap, dir, props)
	local l = New("UIListLayout", {
		Padding = UDim.new(0, gap or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = dir or Enum.FillDirection.Vertical,
	})
	if props then
		for k, v in pairs(props) do
			l[k] = v
		end
	end
	return l
end

-- Make a frame draggable by a handle.
local function dragify(frame, handle)
	handle = handle or frame
	local dragging, startPos, startInput

	connect(handle.InputBegan, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			startPos = frame.Position
			startInput = input.Position

			local changed
			changed = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					changed:Disconnect()
				end
			end)
		end
	end)

	connect(UserInputService.InputChanged, function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local delta = input.Position - startInput
			tween(frame, 0.06, {
				Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				),
			})
		end
	end)
end

local function round(value, step)
	if step and step > 0 then
		return math.floor(value / step + 0.5) * step
	end
	return value
end

--//============================================================\\--
--||                      LUCIDE ICONS                         ||--
--\\============================================================//--
-- Icons are referenced by name (e.g. "house", "settings", "bird") and
-- resolved from a remote Lucide spritesheet pack at runtime, then cached.
--
-- Avoiding blurry icons:
--   * The window root is a plain Frame, NOT a CanvasGroup. CanvasGroups
--     flatten children to a texture and soften every icon/text inside them.
--   * Icon images use ScaleType = Fit so the square glyph keeps its aspect.
--   * Icons are only ever downscaled (sheet glyph -> small label), never
--     upscaled past their source rect, which keeps the lines clean.

local HttpService = cloneref(game:GetService("HttpService"))

local Icons = {
	URL = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua",
	Pack = nil,
	Loaded = false,
	Cache = {},
}
Library.Icons = Icons

local httpGet = function(url)
	if game.HttpGet then
		local ok, body = pcall(function()
			return game:HttpGet(url)
		end)
		if ok then
			return body
		end
	end
	local request = (syn and syn.request) or (http and http.request) or http_request or request
	if request then
		local ok, res = pcall(request, { Url = url, Method = "GET" })
		if ok and res and res.Body then
			return res.Body
		end
	end
	return nil
end

local function ensureIcons()
	if Icons.Loaded then
		return
	end
	Icons.Loaded = true
	local ok, pack = pcall(function()
		local body = httpGet(Icons.URL)
		if not body then
			return nil
		end
		return loadstring(body)()
	end)
	if ok and pack then
		Icons.Pack = pack
		pcall(function()
			if pack.SetIconsType then
				pack.SetIconsType("lucide")
			end
		end)
	else
		warn("[SerhiiUI] failed to load the Lucide icon pack; icons will be skipped")
	end
end

-- Resolve an icon name to { Image, RectOffset, RectSize } (or nil).
function Library:GetIcon(name)
	if not name or name == "" then
		return nil
	end
	-- Direct asset ids pass straight through.
	if typeof(name) == "string" and name:match("^rbxassetid://") then
		return { Image = name, RectOffset = Vector2.new(0, 0), RectSize = Vector2.new(0, 0) }
	end
	if Icons.Cache[name] ~= nil then
		return Icons.Cache[name] or nil
	end

	ensureIcons()
	local data
	if Icons.Pack then
		pcall(function()
			local result = Icons.Pack.Icon2 and Icons.Pack.Icon2(name)
				or (Icons.Pack.GetIcon and Icons.Pack.GetIcon(name))
			if typeof(result) == "string" then
				data = { Image = result, RectOffset = Vector2.new(0, 0), RectSize = Vector2.new(0, 0) }
			elseif typeof(result) == "table" and result[1] then
				local rect = result[2] or {}
				data = {
					Image = result[1],
					RectOffset = rect.ImageRectPosition or Vector2.new(0, 0),
					RectSize = rect.ImageRectSize or Vector2.new(0, 0),
				}
			end
		end)
	end

	Icons.Cache[name] = data or false
	return data
end

-- Register custom icons by name. Use this in a real game (where the remote
-- Lucide pack can't load, since game clients have no HttpGet/loadstring) to map
-- names to your own image assets:
--   SerhiiUI:AddIcons({ shield = "rbxassetid://123", boot = 456 })
-- A value may be a "rbxassetid://" string, an asset id number, or a spritesheet
-- table { Image, RectOffset, RectSize }. Registered names win over the pack and
-- never hit the network.
function Library:AddIcons(map)
	if typeof(map) ~= "table" then
		return
	end
	for name, value in pairs(map) do
		if typeof(value) == "number" then
			Icons.Cache[name] = {
				Image = "rbxassetid://" .. value,
				RectOffset = Vector2.new(0, 0),
				RectSize = Vector2.new(0, 0),
			}
		elseif typeof(value) == "string" then
			Icons.Cache[name] = {
				Image = value,
				RectOffset = Vector2.new(0, 0),
				RectSize = Vector2.new(0, 0),
			}
		elseif typeof(value) == "table" and value.Image then
			Icons.Cache[name] = {
				Image = value.Image,
				RectOffset = value.RectOffset or value.ImageRectOffset or Vector2.new(0, 0),
				RectSize = value.RectSize or value.ImageRectSize or Vector2.new(0, 0),
			}
		end
	end
end

-- Build an ImageLabel for an icon name. `sizeUDim` defaults to 18x18.
local function makeIcon(name, sizeUDim, themeKey, color)
	local img = New("ImageLabel", {
		Size = sizeUDim or UDim2.new(0, 18, 0, 18),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		ResampleMode = Enum.ResamplerMode.Default,
		ThemeTag = themeKey and { ImageColor3 = themeKey } or nil,
	})

	local data = Library:GetIcon(name)
	if data then
		img.Image = data.Image
		if data.RectSize and (data.RectSize.X > 0 or data.RectSize.Y > 0) then
			img.ImageRectOffset = data.RectOffset
			img.ImageRectSize = data.RectSize
		end
	end
	if color then
		img.ImageColor3 = color
	end
	return img
end

--//============================================================\\--
--||                     THEME SWITCHING                       ||--
--\\============================================================//--

function Library:SetTheme(name)
	local theme = Themes[name] or (typeof(name) == "table" and name)
	if not theme then
		warn("[SerhiiUI] unknown theme: " .. tostring(name))
		return
	end

	Library.Theme = theme
	Library.ThemeName = theme.Name or name

	for i = #Library.ThemeObjects, 1, -1 do
		local entry = Library.ThemeObjects[i]
		local object = entry.Object
		if object and object.Parent ~= nil then
			for prop, key in pairs(entry.Props) do
				local value = theme[key]
				if value ~= nil then
					if typeof(value) == "Color3" or typeof(value) == "number" then
						tween(object, 0.25, { [prop] = value })
					else
						pcall(function()
							object[prop] = value
						end)
					end
				end
			end
		end
	end

	return theme
end

-- AddTheme registers a fully-specified theme table (must contain every key).
function Library:AddTheme(theme)
	Themes[theme.Name] = theme
	return theme
end

-- CreateTheme builds a complete theme from a short colour spec (see buildTheme).
-- e.g. SerhiiUI:CreateTheme("Sunset", { Background=..., Element=..., Accent=... })
function Library:CreateTheme(name, colours)
	local theme = buildTheme(name, colours)
	Themes[name] = theme
	return theme
end

function Library:RemoveTheme(name)
	if name == "Dark" then
		warn("[SerhiiUI] the Dark theme cannot be removed")
		return false
	end
	if not Themes[name] then
		return false
	end
	Themes[name] = nil
	if Library.ThemeName == name then
		Library:SetTheme("Dark")
	end
	return true
end

-- Returns a sorted list of theme names (Dark and Light first).
function Library:GetThemes()
	local names = {}
	for themeName in pairs(Themes) do
		table.insert(names, themeName)
	end
	table.sort(names, function(a, b)
		local rank = { Dark = 1, Light = 2 }
		local ra, rb = rank[a] or 3, rank[b] or 3
		if ra ~= rb then
			return ra < rb
		end
		return a < b
	end)
	return names
end

function Library:GetTheme()
	return Library.ThemeName
end

--//============================================================\\--
--||                       SCREEN GUI                          ||--
--\\============================================================//--

local function getParentGui()
	-- Executor: gethui() gives a protected, persistent parent.
	local ok, hui = pcall(function()
		return gethui and gethui()
	end)
	if ok and hui then
		return hui
	end

	local LocalPlayer = Players.LocalPlayer

	-- Studio (and normal in-game LocalScripts) cannot write to CoreGui, so
	-- parent to PlayerGui. This is the path that makes the module work when
	-- required as a ModuleScript from a LocalScript in Studio.
	if RunService:IsStudio() and LocalPlayer then
		return LocalPlayer:WaitForChild("PlayerGui")
	end

	-- Executor without gethui (or Studio command bar): use CoreGui only if we
	-- can actually parent into it; otherwise fall back to PlayerGui.
	local canCore = pcall(function()
		local probe = Instance.new("Folder")
		probe.Parent = CoreGui
		probe:Destroy()
	end)
	if canCore then
		return CoreGui
	end

	return LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")
end

local function protect(gui)
	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		elseif protectgui then
			protectgui(gui)
		end
	end)
end

local ScreenGui = New("ScreenGui", {
	Name = "SerhiiUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset = true,
	DisplayOrder = 999999,
	Parent = getParentGui(),
})
protect(ScreenGui)
Library.ScreenGui = ScreenGui

-- Separate layer for notifications so they always render above windows.
local NotificationLayer = New("Frame", {
	Name = "Notifications",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -20, 1, -20),
	Position = UDim2.new(0, 10, 0, 10),
	Parent = ScreenGui,
}, {
	listLayout(8, Enum.FillDirection.Vertical, {
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	}),
})

--//============================================================\\--
--||                      NOTIFICATIONS                        ||--
--\\============================================================//--

function Library:Notify(config)
	config = config or {}
	local title = config.Title or "Notification"
	local content = config.Content or ""
	local duration = config.Duration or 4

	local holder = New("Frame", {
		Size = UDim2.new(0, 280, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = NotificationLayer,
	})

	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(1, 20, 0, 0),
		BackgroundTransparency = 0,
		ThemeTag = { BackgroundColor3 = "Notification" },
		Parent = holder,
	}, {
		corner(10),
		New("UIStroke", {
			Thickness = 1,
			Transparency = 0.85,
			ThemeTag = { Color = "Stroke" },
		}),
		padding(12),
		listLayout(4),
		-- accent bar
		New("Frame", {
			Size = UDim2.new(0, 3, 1, -16),
			Position = UDim2.new(0, 0, 0, 8),
			ThemeTag = { BackgroundColor3 = "Accent" },
		}, { corner(2) }),
		New("TextLabel", {
			Text = title,
			FontFace = font(Enum.FontWeight.SemiBold),
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 18),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			ThemeTag = { TextColor3 = "Text" },
		}),
		content ~= "" and New("TextLabel", {
			Text = content,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			ThemeTag = { TextColor3 = "SubText" },
		}) or nil,
	})

	tween(card, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint)

	task.delay(duration, function()
		tween(card, 0.3, { Position = UDim2.new(1, 20, 0, 0) }, Enum.EasingStyle.Quint)
		task.wait(0.32)
		holder:Destroy()
	end)
end

--//============================================================\\--
--||                    ELEMENT FACTORY                        ||--
--\\============================================================//--
-- Shared card used by Button/Toggle/Slider/Dropdown/Input/Paragraph.

local function makeElement(parent, opts)
	opts = opts or {}
	local hasDesc = opts.Desc ~= nil and opts.Desc ~= ""
	local controlWidth = opts.ControlWidth or 44
	local minHeight = opts.Height or 40

	-- The card never gets top/bottom UIPadding (that would squash the
	-- full-height control). Instead the text column carries its own
	-- vertical padding, which is what drives the card's automatic height.
	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, minHeight),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0,
		ThemeTag = { BackgroundColor3 = "Element" },
		Parent = parent,
		LayoutOrder = opts.LayoutOrder or 1,
	}, {
		corner(8),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
		New("UISizeConstraint", { MinSize = Vector2.new(0, minHeight) }),
	})

	-- Optional left icon (by Lucide name). Shifts the text column right.
	local iconInset = 14
	local iconImage
	if opts.Icon and opts.Icon ~= "" then
		iconImage = makeIcon(opts.Icon, UDim2.new(0, 18, 0, 18), "Text")
		iconImage.AnchorPoint = Vector2.new(0, 0.5)
		iconImage.Position = UDim2.new(0, 14, 0.5, 0)
		iconImage.Parent = card
		iconInset = 14 + 18 + 10
	end

	-- Left text column (drives card height via its own vertical padding)
	local textCol = New("Frame", {
		Size = UDim2.new(1, -(controlWidth + iconInset + 12), 0, 0),
		Position = UDim2.new(0, iconInset, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = card,
	}, {
		listLayout(2),
		padding(0, { PaddingTop = UDim.new(0, 11), PaddingBottom = UDim.new(0, 11) }),
	})

	local titleLabel = New("TextLabel", {
		Text = opts.Title or "",
		FontFace = font(Enum.FontWeight.Medium),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 16),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		ThemeTag = { TextColor3 = "Text" },
		Parent = textCol,
	})

	local descLabel
	if hasDesc then
		descLabel = New("TextLabel", {
			Text = opts.Desc,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			ThemeTag = { TextColor3 = "SubText" },
			Parent = textCol,
		})
	end

	-- Right control slot. Scale height (1,0) makes it fill the final card
	-- height and centre its widget; AutomaticSize ignores scale-sized
	-- children, so it never feeds back into the card's height.
	local control = New("Frame", {
		Size = UDim2.new(0, controlWidth, 1, 0),
		Position = UDim2.new(1, -12, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Parent = card,
	})

	local element = {
		Card = card,
		Control = control,
		TitleLabel = titleLabel,
		DescLabel = descLabel,
		Icon = iconImage,
	}

	if opts.Hover ~= false then
		connect(card.MouseEnter, function()
			tween(card, 0.15, { BackgroundColor3 = Library.Theme.ElementHover })
		end)
		connect(card.MouseLeave, function()
			tween(card, 0.15, { BackgroundColor3 = Library.Theme.Element })
		end)
	end

	function element:SetTitle(text)
		titleLabel.Text = text
	end
	function element:SetDesc(text)
		if descLabel then
			descLabel.Text = text
		end
	end

	return element
end

--//============================================================\\--
--||                  ELEMENT CONSTRUCTORS                     ||--
--\\============================================================//--
-- Each is attached to a "page" (a tab's content ScrollingFrame).
-- They return an element table with :Set / :Get / control methods.

local Elements = {}

function Elements.Section(page, config)
	config = config or {}
	local label = New("TextLabel", {
		Text = string.upper(config.Title or "Section"),
		FontFace = font(Enum.FontWeight.SemiBold),
		TextSize = config.TextSize or 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ThemeTag = { TextColor3 = "SubText" },
		Parent = page,
	}, {
		padding(0, { PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 2) }),
	})
	return { Object = label, Set = function(_, t) label.Text = string.upper(t) end }
end

function Elements.Divider(page)
	local line = New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 0.85,
		ThemeTag = { BackgroundColor3 = "Stroke" },
		Parent = page,
	})
	return { Object = line }
end

function Elements.Paragraph(page, config)
	config = config or {}
	local el = makeElement(page, {
		Title = config.Title,
		Desc = config.Desc,
		Icon = config.Icon,
		Hover = false,
		ControlWidth = 0,
	})
	return {
		Object = el.Card,
		SetTitle = function(_, t) el:SetTitle(t) end,
		SetDesc = function(_, d) el:SetDesc(d) end,
	}
end

function Elements.Button(page, config)
	config = config or {}
	local el = makeElement(page, {
		Title = config.Title or "Button",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 18,
	})

	-- chevron
	New("TextLabel", {
		Text = "›",
		FontFace = font(Enum.FontWeight.Bold),
		TextSize = 22,
		Size = UDim2.new(1, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		ThemeTag = { TextColor3 = "SubText" },
		Parent = el.Control,
	})

	local hit = New("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = el.Card,
		ZIndex = 5,
	})

	connect(hit.MouseButton1Click, function()
		tween(el.Card, 0.08, { BackgroundColor3 = Library.Theme.ElementHover }, Enum.EasingStyle.Quad)
		task.delay(0.08, function()
			tween(el.Card, 0.2, { BackgroundColor3 = Library.Theme.Element })
		end)
		task.spawn(safeCallback, config.Callback)
	end)

	return {
		Object = el.Card,
		SetTitle = function(_, t) el:SetTitle(t) end,
		SetCallback = function(_, fn) config.Callback = fn end,
	}
end

function Elements.Toggle(page, config)
	config = config or {}
	local value = config.Default or config.Value or false

	local el = makeElement(page, {
		Title = config.Title or "Toggle",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 44,
	})

	local track = New("Frame", {
		Size = UDim2.new(0, 42, 0, 22),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = value and Library.Theme.Toggle or Library.Theme.ToggleOff,
		Parent = el.Control,
	}, {
		corner(11),
	})

	local knob = New("Frame", {
		Size = UDim2.new(0, 18, 0, 18),
		Position = value and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(value and 1 or 0, 0.5),
		BackgroundColor3 = Color3.fromHex("#ffffff"),
		Parent = track,
	}, {
		corner(9),
	})

	local hit = New("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = el.Card,
		ZIndex = 5,
	})

	local object

	local function visualUpdate(animate)
		local t = animate and 0.16 or 0
		tween(track, t, { BackgroundColor3 = value and Library.Theme.Toggle or Library.Theme.ToggleOff })
		tween(knob, t, {
			Position = value and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			AnchorPoint = Vector2.new(value and 1 or 0, 0.5),
		}, Enum.EasingStyle.Quint)
	end

	local function set(v, fireCallback, animate)
		value = v and true or false
		visualUpdate(animate ~= false)
		if fireCallback ~= false then
			task.spawn(safeCallback, config.Callback, value)
		end
	end

	connect(hit.MouseButton1Click, function()
		set(not value, true, true)
	end)

	object = {
		Object = el.Card,
		Set = function(_, v, fire) set(v, fire ~= false, true) end,
		Get = function() return value end,
		Value = value,
	}

	if config.Flag then
		Library.Flags[config.Flag] = object
	end

	return object
end

function Elements.Slider(page, config)
	config = config or {}
	local valueCfg = config.Value or {}
	local min = valueCfg.Min or 0
	local max = valueCfg.Max or 100
	local default = valueCfg.Default or min
	local step = config.Step or 1
	local current = math.clamp(default, min, max)

	local sliderHeight = config.Desc and 64 or 54
	local el = makeElement(page, {
		Title = config.Title or "Slider",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 56,
		Height = sliderHeight,
	})
	-- Slider has a fixed height (title row + track row), so disable autosize.
	el.Card.AutomaticSize = Enum.AutomaticSize.None
	el.Card.Size = UDim2.new(1, 0, 0, sliderHeight)

	-- value readout, top-right, aligned with the title row
	local valueLabel = New("TextLabel", {
		Text = tostring(current),
		FontFace = font(Enum.FontWeight.SemiBold),
		TextSize = 13,
		Size = UDim2.new(0, 56, 0, 16),
		Position = UDim2.new(1, -12, 0, 11),
		AnchorPoint = Vector2.new(1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		ThemeTag = { TextColor3 = "Accent" },
		Parent = el.Card,
	})

	-- the track lives full-width along the bottom of the card
	local trackHolder = New("Frame", {
		Size = UDim2.new(1, -26, 0, 14),
		Position = UDim2.new(0, 14, 1, -12),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Parent = el.Card,
	})

	local track = New("Frame", {
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ThemeTag = { BackgroundColor3 = "ToggleOff" },
		Parent = trackHolder,
	}, { corner(3) })

	local fill = New("Frame", {
		Size = UDim2.new((current - min) / (max - min), 0, 1, 0),
		ThemeTag = { BackgroundColor3 = "Slider" },
		Parent = track,
	}, { corner(3) })

	local knob = New("Frame", {
		Size = UDim2.new(0, 14, 0, 14),
		Position = UDim2.new((current - min) / (max - min), 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("#ffffff"),
		Parent = track,
		ZIndex = 3,
	}, { corner(7) })

	local object

	local function set(v, fireCallback)
		current = math.clamp(round(v, step), min, max)
		local scale = (max - min) ~= 0 and (current - min) / (max - min) or 0
		valueLabel.Text = tostring(current)
		tween(fill, 0.06, { Size = UDim2.new(scale, 0, 1, 0) })
		tween(knob, 0.06, { Position = UDim2.new(scale, 0, 0.5, 0) })
		if fireCallback ~= false then
			task.spawn(safeCallback, config.Callback, current)
		end
	end

	local dragging = false
	local function updateFromInput(input)
		local relative = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
		set(min + (max - min) * math.clamp(relative, 0, 1))
	end

	local hit = New("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 2, 0),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Parent = trackHolder,
		ZIndex = 4,
	})

	connect(hit.InputBegan, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			tween(knob, 0.12, { Size = UDim2.new(0, 18, 0, 18) })
			updateFromInput(input)
		end
	end)
	connect(UserInputService.InputEnded, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if dragging then
				dragging = false
				tween(knob, 0.12, { Size = UDim2.new(0, 14, 0, 14) })
			end
		end
	end)
	connect(UserInputService.InputChanged, function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			updateFromInput(input)
		end
	end)

	object = {
		Object = el.Card,
		Set = function(_, v, fire) set(v, fire ~= false) end,
		Get = function() return current end,
		Value = current,
	}

	if config.Flag then
		Library.Flags[config.Flag] = object
	end

	return object
end

function Elements.Input(page, config)
	config = config or {}
	local el = makeElement(page, {
		Title = config.Title or "Input",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 140,
	})

	local box = New("Frame", {
		Size = UDim2.new(0, 140, 0, 28),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = { BackgroundColor3 = "ElementHover" },
		Parent = el.Control,
	}, {
		corner(6),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
		padding(0, { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
	})

	local input = New("TextBox", {
		Text = config.Default or "",
		PlaceholderText = config.Placeholder or "...",
		TextSize = 13,
		Size = UDim2.new(1, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "SubText" },
		Parent = box,
	})

	connect(input.FocusLost, function(enterPressed)
		task.spawn(safeCallback, config.Callback, input.Text, enterPressed)
	end)

	connect(input.Focused, function()
		tween(box, 0.15, { BackgroundColor3 = Library.Theme.Element })
	end)
	connect(input.FocusLost, function()
		tween(box, 0.15, { BackgroundColor3 = Library.Theme.ElementHover })
	end)

	local object = {
		Object = el.Card,
		Set = function(_, v) input.Text = tostring(v) end,
		Get = function() return input.Text end,
	}

	if config.Flag then
		Library.Flags[config.Flag] = object
	end

	return object
end

function Elements.Dropdown(page, config)
	config = config or {}
	local values = config.Values or {}
	local multi = config.Multi or false

	-- Normalize selection state
	local selected = {}
	if multi then
		if typeof(config.Default) == "table" then
			for _, v in ipairs(config.Default) do
				selected[v] = true
			end
		end
	end
	local single = (not multi) and config.Default or nil

	local el = makeElement(page, {
		Title = config.Title or "Dropdown",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 150,
	})

	local function displayText()
		if multi then
			local list = {}
			for v in pairs(selected) do
				table.insert(list, tostring(v))
			end
			return #list > 0 and table.concat(list, ", ") or "None"
		else
			return single ~= nil and tostring(single) or "None"
		end
	end

	-- Header is anchored to the card's top-right so it stays put when the
	-- card grows to reveal the option list.
	local header = New("Frame", {
		Size = UDim2.new(0, 150, 0, 30),
		Position = UDim2.new(1, -12, 0, 8),
		AnchorPoint = Vector2.new(1, 0),
		ThemeTag = { BackgroundColor3 = "ElementHover" },
		Parent = el.Card,
	}, {
		corner(6),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
	})

	local headerText = New("TextLabel", {
		Text = displayText(),
		TextSize = 13,
		Size = UDim2.new(1, -34, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ThemeTag = { TextColor3 = "Text" },
		Parent = header,
	})

	local arrow = New("TextLabel", {
		Text = "▾",
		TextSize = 14,
		Size = UDim2.new(0, 24, 1, 0),
		Position = UDim2.new(1, -26, 0, 0),
		ThemeTag = { TextColor3 = "SubText" },
		Parent = header,
	})

	-- The expandable list lives inside the card, below the header row,
	-- so it pushes following elements down (clip-safe, no popup layer).
	-- While hidden it does not count toward the card's automatic height.
	local listContainer = New("Frame", {
		Size = UDim2.new(1, -26, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, 14, 0, 46),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = el.Card,
	}, {
		listLayout(4),
		padding(0, { PaddingBottom = UDim.new(0, 12) }),
	})

	local open = false
	local function setOpen(state)
		open = state
		listContainer.Visible = state
		tween(arrow, 0.15, { Rotation = state and 180 or 0 })
	end

	local headerHit = New("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = header,
		ZIndex = 5,
	})

	local optionButtons = {}
	local function refresh()
		headerText.Text = displayText()
		for value, btn in pairs(optionButtons) do
			local isSel = multi and selected[value] or (not multi and single == value)
			tween(btn, 0.12, { BackgroundColor3 = isSel and Library.Theme.Accent or Library.Theme.Element })
			btn.TextColor3 = isSel and Library.Theme.AccentText or Library.Theme.Text
		end
	end

	local object

	local function choose(value)
		if multi then
			selected[value] = (not selected[value]) or nil
		else
			single = value
			setOpen(false)
		end
		refresh()
		if config.Callback then
			task.spawn(safeCallback, config.Callback, multi and selected or single)
		end
	end

	for _, value in ipairs(values) do
		local label = typeof(value) == "table" and (value.Title or "Option") or tostring(value)
		local key = typeof(value) == "table" and (value.Title or label) or value

		local btn = New("TextButton", {
			Text = label,
			TextSize = 13,
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 28),
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Library.Theme.Element,
			ThemeTag = { TextColor3 = "Text" },
			Parent = listContainer,
		}, {
			corner(6),
			padding(0, { PaddingLeft = UDim.new(0, 10) }),
		})
		optionButtons[key] = btn

		connect(btn.MouseButton1Click, function()
			if typeof(value) == "table" and value.Callback then
				task.spawn(safeCallback, value.Callback)
			end
			choose(key)
		end)
	end

	connect(headerHit.MouseButton1Click, function()
		setOpen(not open)
	end)

	refresh()

	object = {
		Object = el.Card,
		Set = function(_, v)
			if multi then
				selected = {}
				if typeof(v) == "table" then
					for _, item in ipairs(v) do
						selected[item] = true
					end
				end
			else
				single = v
			end
			refresh()
		end,
		Get = function()
			return multi and selected or single
		end,
	}

	if config.Flag then
		Library.Flags[config.Flag] = object
	end

	return object
end

function Elements.Text(page, config)
	config = config or {}
	local align = config.Align == "Center" and Enum.TextXAlignment.Center
		or config.Align == "Right" and Enum.TextXAlignment.Right
		or Enum.TextXAlignment.Left

	local label = New("TextLabel", {
		Text = config.Title or config.Text or "",
		FontFace = font(config.FontWeight or Enum.FontWeight.Medium),
		TextSize = config.TextSize or 14,
		TextXAlignment = align,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		RichText = true,
		BackgroundTransparency = 1,
		ThemeTag = { TextColor3 = config.Muted and "SubText" or "Text" },
		Parent = page,
	}, {
		padding(0, { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2) }),
	})
	if config.Color then
		label.TextColor3 = config.Color
	end

	return {
		Object = label,
		Set = function(_, t) label.Text = t end,
		SetText = function(_, t) label.Text = t end,
	}
end

function Elements.Space(page, config)
	config = config or {}
	local space = New("Frame", {
		Size = UDim2.new(1, 0, 0, config.Height or config.Size or 6),
		BackgroundTransparency = 1,
		Parent = page,
	})
	return { Object = space }
end

function Elements.Keybind(page, config)
	config = config or {}
	local current = config.Default
	if typeof(current) == "string" then
		current = (current ~= "None" and current ~= "") and Enum.KeyCode[current] or nil
	end

	local el = makeElement(page, {
		Title = config.Title or "Keybind",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 92,
	})

	local btn = New("TextButton", {
		Text = current and current.Name or "None",
		FontFace = font(Enum.FontWeight.Medium),
		TextSize = 13,
		AutoButtonColor = false,
		Size = UDim2.new(0, 90, 0, 28),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = { BackgroundColor3 = "ElementHover", TextColor3 = "Text" },
		Parent = el.Control,
	}, {
		corner(6),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
	})

	local binding = false

	local function setKey(key)
		current = key
		btn.Text = key and key.Name or "None"
	end

	connect(btn.MouseButton1Click, function()
		binding = true
		btn.Text = "..."
		tween(btn, 0.12, { BackgroundColor3 = Library.Theme.Accent })
	end)

	connect(UserInputService.InputBegan, function(input, processed)
		if binding then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				binding = false
				tween(btn, 0.12, { BackgroundColor3 = Library.Theme.ElementHover })
				if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
					setKey(nil)
				else
					setKey(input.KeyCode)
				end
			end
			return
		end
		if processed then
			return
		end
		if current and input.KeyCode == current then
			task.spawn(safeCallback, config.Callback, current)
		end
	end)

	local object = {
		Object = el.Card,
		Set = function(_, k)
			if typeof(k) == "string" then
				k = (k ~= "None" and k ~= "") and Enum.KeyCode[k] or nil
			end
			setKey(k)
		end,
		Get = function() return current end,
	}
	if config.Flag then
		Library.Flags[config.Flag] = object
	end
	return object
end

function Elements.Colorpicker(page, config)
	config = config or {}

	local h, s, v = 0, 1, 1
	if typeof(config.Default) == "Color3" then
		local ok, hh, ss, vv = pcall(function()
			return config.Default:ToHSV()
		end)
		if ok and hh then
			h, s, v = hh, ss, vv
		end
	end

	local el = makeElement(page, {
		Title = config.Title or "Colorpicker",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 44,
	})

	local swatch = New("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(0, 40, 0, 24),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromHSV(h, s, v),
		Parent = el.Control,
	}, {
		corner(6),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
	})

	-- inline panel (revealed below the row; grows the card)
	local panel = New("Frame", {
		Size = UDim2.new(1, -26, 0, 124),
		Position = UDim2.new(0, 14, 0, 46),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = el.Card,
	})

	-- saturation/value square
	local svSquare = New("Frame", {
		Size = UDim2.new(1, -26, 1, 0),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		Parent = panel,
	}, {
		corner(6),
		New("Frame", { -- white -> transparent (saturation)
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromHex("#ffffff"),
		}, {
			corner(6),
			New("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		}),
		New("Frame", { -- transparent -> black (value)
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromHex("#000000"),
		}, {
			corner(6),
			New("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 0),
				}),
			}),
		}),
	})

	local svCursor = New("Frame", {
		Size = UDim2.new(0, 10, 0, 10),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(s, 0, 1 - v, 0),
		BackgroundColor3 = Color3.fromHex("#ffffff"),
		ZIndex = 5,
		Parent = svSquare,
	}, {
		corner(5),
		New("UIStroke", { Thickness = 1.5, Color = Color3.fromHex("#000000"), Transparency = 0.4 }),
	})

	-- hue bar (vertical, right side)
	local hueBar = New("Frame", {
		Size = UDim2.new(0, 16, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromHex("#ffffff"),
		Parent = panel,
	}, {
		corner(6),
		New("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0, 1, 1)),
				ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
				ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
				ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
				ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
				ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
				ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1, 1, 1)),
			}),
		}),
	})

	local hueCursor = New("Frame", {
		Size = UDim2.new(1, 4, 0, 4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, h, 0),
		BackgroundColor3 = Color3.fromHex("#ffffff"),
		ZIndex = 5,
		Parent = hueBar,
	}, {
		corner(2),
		New("UIStroke", { Thickness = 1, Color = Color3.fromHex("#000000"), Transparency = 0.4 }),
	})

	local object

	local function fire()
		if config.Callback then
			task.spawn(safeCallback, config.Callback, Color3.fromHSV(h, s, v))
		end
	end

	local function updateVisual(doFire)
		local colour = Color3.fromHSV(h, s, v)
		swatch.BackgroundColor3 = colour
		svSquare.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
		hueCursor.Position = UDim2.new(0.5, 0, h, 0)
		if doFire ~= false then
			fire()
		end
	end

	-- drag helpers
	local function bindDrag(frame, onMove)
		local dragging = false
		connect(frame.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				onMove(input)
			end
		end)
		connect(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		connect(UserInputService.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				onMove(input)
			end
		end)
	end

	bindDrag(svSquare, function(input)
		local rx = math.clamp((input.Position.X - svSquare.AbsolutePosition.X) / svSquare.AbsoluteSize.X, 0, 1)
		local ry = math.clamp((input.Position.Y - svSquare.AbsolutePosition.Y) / svSquare.AbsoluteSize.Y, 0, 1)
		s, v = rx, 1 - ry
		updateVisual()
	end)
	bindDrag(hueBar, function(input)
		h = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
		updateVisual()
	end)

	local open = false
	connect(swatch.MouseButton1Click, function()
		open = not open
		panel.Visible = open
	end)

	object = {
		Object = el.Card,
		Set = function(_, colour)
			if typeof(colour) == "Color3" then
				local ok, hh, ss, vv = pcall(function()
					return colour:ToHSV()
				end)
				if ok and hh then
					h, s, v = hh, ss, vv
					updateVisual(false)
				end
			end
		end,
		Get = function() return Color3.fromHSV(h, s, v) end,
	}
	if config.Flag then
		Library.Flags[config.Flag] = object
	end
	return object
end

function Elements.Code(page, config)
	config = config or {}
	local codeText = config.Code or config.Text or ""

	-- clipboard shim (executor-dependent; falls back to a no-op)
	local setClip = setclipboard
		or toclipboard
		or writeclipboard
		or (syn and syn.write_clipboard)
		or function() end

	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ThemeTag = { BackgroundColor3 = "Element" },
		Parent = page,
	}, {
		corner(8),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
		listLayout(8),
		padding(12),
	})

	local header = New("Frame", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Parent = card,
	})
	New("TextLabel", {
		Text = config.Title or "Code",
		FontFace = font(Enum.FontWeight.SemiBold),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -60, 1, 0),
		ThemeTag = { TextColor3 = "SubText" },
		Parent = header,
	})
	local copyBtn = New("TextButton", {
		Text = "Copy",
		FontFace = font(Enum.FontWeight.Medium),
		TextSize = 12,
		AutoButtonColor = false,
		Size = UDim2.new(0, 56, 0, 22),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = { BackgroundColor3 = "ElementHover", TextColor3 = "Text" },
		Parent = header,
	}, { corner(5) })

	local codeLabel = New("TextLabel", {
		Text = codeText,
		FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json"),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		RichText = false,
		BackgroundTransparency = 1,
		ThemeTag = { TextColor3 = "Text" },
		Parent = card,
	})

	connect(copyBtn.MouseButton1Click, function()
		pcall(setClip, codeLabel.Text)
		copyBtn.Text = "Copied!"
		task.delay(1, function()
			copyBtn.Text = "Copy"
		end)
	end)

	return {
		Object = card,
		Set = function(_, t) codeLabel.Text = t end,
		Get = function() return codeLabel.Text end,
	}
end

--//============================================================\\--
--||                          TAB                              ||--
--\\============================================================//--

local function createTab(window, config)
	config = config or {}
	local Tab = {
		Title = config.Title or "Tab",
		Icon = config.Icon,
	}

	window.TabCount = window.TabCount + 1
	local index = window.TabCount

	-- Sidebar button
	local button = New("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = window.Library.Theme.TabActive,
		BackgroundTransparency = 1,
		Parent = window.TabList,
		LayoutOrder = index,
	}, {
		corner(7),
	})

	local activeBar = New("Frame", {
		Size = UDim2.new(0, 3, 0, 16),
		Position = UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ThemeTag = { BackgroundColor3 = "Accent" },
		BackgroundTransparency = 1,
		Parent = button,
	}, { corner(2) })

	-- Optional tab icon
	local textInset = 14
	if config.Icon and config.Icon ~= "" then
		local icon = makeIcon(config.Icon, UDim2.new(0, 17, 0, 17), "TabText")
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.Position = UDim2.new(0, 12, 0.5, 0)
		icon.Parent = button
		Tab.IconImage = icon
		textInset = 12 + 17 + 8
	end

	local label = New("TextLabel", {
		Text = Tab.Title,
		FontFace = font(Enum.FontWeight.Medium),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -textInset - 8, 1, 0),
		Position = UDim2.new(0, textInset, 0, 0),
		ThemeTag = { TextColor3 = "TabText" },
		Parent = button,
	})

	-- Content page
	local page = New("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0.5,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
		Visible = false,
		Parent = window.ContentHolder,
	}, {
		listLayout(8),
		padding(2, { PaddingRight = UDim.new(0, 8) }),
	})

	Tab.SidebarButton = button
	Tab.Page = page
	Tab.Index = index

	function Tab:Select()
		window:SelectTab(index)
	end

	-- Wire element constructors onto the tab (Tab:Button, Tab:Toggle, ...).
	for name, constructor in pairs(Elements) do
		Tab[name] = function(_, elementConfig)
			return constructor(page, elementConfig)
		end
	end

	connect(button.MouseButton1Click, function()
		window:SelectTab(index)
	end)
	connect(button.MouseEnter, function()
		if window.CurrentTab ~= index then
			tween(button, 0.15, { BackgroundTransparency = 0.6 })
		end
	end)
	connect(button.MouseLeave, function()
		if window.CurrentTab ~= index then
			tween(button, 0.15, { BackgroundTransparency = 1 })
		end
	end)

	window.Tabs[index] = {
		Button = button,
		Page = page,
		Label = label,
		ActiveBar = activeBar,
		Icon = Tab.IconImage,
	}

	-- An explicit tab (not the implicit window-level page) reveals the sidebar.
	if not config.Implicit and window.SetSidebar then
		window:SetSidebar(true)
	end

	if not window.CurrentTab then
		window:SelectTab(index)
	end

	return Tab
end

--//============================================================\\--
--||                       KEY SYSTEM                          ||--
--\\============================================================//--
-- Optional gate shown before a window loads. Blocks (yields) until a valid
-- key is entered, or returns false if the user closes it.

local function runKeySystem(cfg)
	cfg = cfg or {}
	local keys = cfg.Key
	if typeof(keys) == "string" then
		keys = { keys }
	end

	local function isValid(input)
		input = tostring(input)
		if cfg.Validator then
			local ok, res = pcall(cfg.Validator, input)
			return ok and res and true or false
		end
		if keys then
			for _, k in ipairs(keys) do
				if tostring(k) == input then
					return true
				end
			end
		end
		return false
	end

	-- Saved key shortcut
	local savePath = cfg.SaveKey and ((cfg.Folder or "SerhiiUI") .. "/key.txt") or nil
	if savePath and isfile then
		local ok, saved = pcall(function()
			return isfile(savePath) and readfile(savePath) or nil
		end)
		if ok and saved and isValid(saved) then
			return true
		end
	end

	local done, result = false, false

	local overlay = New("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromHex("#000000"),
		BackgroundTransparency = 0.4,
		ZIndex = 50,
		Parent = ScreenGui,
	})

	local card = New("Frame", {
		Size = UDim2.new(0, 320, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ThemeTag = { BackgroundColor3 = "Background" },
		ZIndex = 51,
		Parent = overlay,
	}, {
		corner(12),
		New("UIStroke", { Thickness = 1, ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" } }),
		listLayout(10),
		padding(18),
	})

	New("TextLabel", {
		Text = cfg.Title or "Key System",
		FontFace = font(Enum.FontWeight.Bold),
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 22),
		ZIndex = 51,
		ThemeTag = { TextColor3 = "Text" },
		Parent = card,
	})

	New("TextLabel", {
		Text = cfg.Note or cfg.Subtitle or "Enter your key to continue.",
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		ZIndex = 51,
		ThemeTag = { TextColor3 = "SubText" },
		Parent = card,
	})

	local box = New("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		ThemeTag = { BackgroundColor3 = "Element" },
		ZIndex = 51,
		Parent = card,
	}, {
		corner(8),
		New("UIStroke", { Thickness = 1, ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" } }),
		padding(0, { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
	})
	local input = New("TextBox", {
		Text = "",
		PlaceholderText = "Key...",
		TextSize = 14,
		Size = UDim2.new(1, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = 52,
		ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "SubText" },
		Parent = box,
	})

	local status = New("TextLabel", {
		Text = "",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 14),
		ZIndex = 51,
		TextColor3 = Color3.fromHex("#f87171"),
		Parent = card,
	})

	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		ZIndex = 51,
		Parent = card,
	}, {
		listLayout(8, Enum.FillDirection.Horizontal, { HorizontalAlignment = Enum.HorizontalAlignment.Right }),
	})

	local function makeKeyBtn(text, accent)
		return New("TextButton", {
			Text = text,
			FontFace = font(Enum.FontWeight.SemiBold),
			TextSize = 13,
			AutoButtonColor = false,
			Size = UDim2.new(0, accent and 90 or 80, 1, 0),
			ZIndex = 51,
			ThemeTag = accent and { BackgroundColor3 = "Accent", TextColor3 = "AccentText" }
				or { BackgroundColor3 = "Element", TextColor3 = "Text" },
			Parent = row,
		}, {
			corner(8),
			accent and nil or New("UIStroke", {
				Thickness = 1,
				ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
			}),
		})
	end

	local closeBtn = makeKeyBtn("Cancel", false)
	if cfg.GetKey then
		local getBtn = makeKeyBtn("Get Key", false)
		connect(getBtn.MouseButton1Click, function()
			local copy = setclipboard or toclipboard or writeclipboard or function() end
			pcall(copy, tostring(cfg.GetKey))
			status.TextColor3 = Library.Theme.SubText
			status.Text = "Link copied to clipboard."
		end)
	end
	local submitBtn = makeKeyBtn("Submit", true)

	local function submit()
		if isValid(input.Text) then
			if savePath and writefile then
				pcall(function()
					if makefolder and not (isfolder and isfolder(cfg.Folder or "SerhiiUI")) then
						makefolder(cfg.Folder or "SerhiiUI")
					end
					writefile(savePath, input.Text)
				end)
			end
			result = true
			done = true
			overlay:Destroy()
		else
			status.TextColor3 = Color3.fromHex("#f87171")
			status.Text = "Invalid key, try again."
			tween(card, 0.08, { Position = UDim2.new(0.5, 6, 0.5, 0) })
			task.delay(0.08, function()
				tween(card, 0.12, { Position = UDim2.new(0.5, 0, 0.5, 0) })
			end)
		end
	end

	connect(submitBtn.MouseButton1Click, submit)
	connect(input.FocusLost, function(enter)
		if enter then
			submit()
		end
	end)
	connect(closeBtn.MouseButton1Click, function()
		result = false
		done = true
		overlay:Destroy()
	end)

	repeat
		task.wait()
	until done

	return result
end

--//============================================================\\--
--||                         WINDOW                            ||--
--\\============================================================//--

function Library:CreateWindow(config)
	config = config or {}

	if config.KeySystem then
		local ok = runKeySystem(config.KeySystem)
		if not ok then
			return nil
		end
	end

	local Window = {
		Library = Library,
		Title = config.Title or "SerhiiUI",
		SubTitle = config.SubTitle or config.Author,
		ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl,
		Tabs = {},
		TabCount = 0,
		CurrentTab = nil,
		Minimized = false,
	}

	local size = config.Size or UDim2.fromOffset(560, 420)
	local sidebarWidth = config.SidebarWidth or 168
	local topbarHeight = 46

	-- Root -------------------------------------------------------------
	local main = New("Frame", {
		Name = "Window",
		Size = size,
		Position = config.Position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = ScreenGui,
	})

	-- soft drop shadow (built-in sliced shadow asset)
	New("ImageLabel", {
		Image = "rbxassetid://8992230677",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(99, 99, 99, 99),
		Size = UDim2.new(1, 120, 1, 120),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = main,
	})

	-- NOTE: a plain Frame, deliberately NOT a CanvasGroup. CanvasGroups
	-- flatten their descendants into a single texture, which makes icons and
	-- text render soft/blurry. The open/close animation uses size, not group
	-- transparency, so everything stays crisp.
	local root = New("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		ClipsDescendants = true,
		ThemeTag = { BackgroundColor3 = "Background" },
		Parent = main,
	}, {
		corner(config.Radius or 12),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
	})
	Window.Root = root

	-- Topbar -----------------------------------------------------------
	local topbar = New("Frame", {
		Size = UDim2.new(1, 0, 0, topbarHeight),
		BackgroundTransparency = 1,
		Parent = root,
	}, {
		padding(0, { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 12) }),
	})

	-- title block (left): optional icon + (title / subtitle)
	local titleRow = New("Frame", {
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = topbar,
	}, {
		listLayout(8, Enum.FillDirection.Horizontal, {
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
	})

	if config.Icon and config.Icon ~= "" then
		local winIcon = makeIcon(config.Icon, UDim2.new(0, config.IconSize or 22, 0, config.IconSize or 22), "Text")
		winIcon.LayoutOrder = 1
		winIcon.Parent = titleRow
		Window.IconImage = winIcon
	end

	New("Frame", {
		Size = UDim2.new(1, -32, 1, 0),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = titleRow,
	}, {
		listLayout(1, Enum.FillDirection.Vertical, {
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		New("TextLabel", {
			Text = Window.Title,
			FontFace = font(Enum.FontWeight.SemiBold),
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 18),
			ThemeTag = { TextColor3 = "Text" },
		}),
		Window.SubTitle and New("TextLabel", {
			Text = Window.SubTitle,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 14),
			ThemeTag = { TextColor3 = "SubText" },
		}) or nil,
	})

	-- window controls (right)
	local controls = New("Frame", {
		Size = UDim2.new(0, 64, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Parent = topbar,
	}, {
		listLayout(6, Enum.FillDirection.Horizontal, {
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
	})

	local function controlButton(symbol, callback)
		local btn = New("TextButton", {
			Text = symbol,
			FontFace = font(Enum.FontWeight.Bold),
			TextSize = 16,
			AutoButtonColor = false,
			Size = UDim2.new(0, 26, 0, 26),
			BackgroundTransparency = 1,
			ThemeTag = { TextColor3 = "SubText", BackgroundColor3 = "ElementHover" },
			Parent = controls,
		}, { corner(7) })

		connect(btn.MouseEnter, function()
			tween(btn, 0.12, { BackgroundTransparency = 0, TextColor3 = Library.Theme.Text })
		end)
		connect(btn.MouseLeave, function()
			tween(btn, 0.12, { BackgroundTransparency = 1, TextColor3 = Library.Theme.SubText })
		end)
		connect(btn.MouseButton1Click, callback)
		return btn
	end

	controlButton("—", function()
		Window:Minimize()
	end)
	controlButton("✕", function()
		Window:Close()
	end)

	-- Sidebar ----------------------------------------------------------
	local sidebarFrame = New("Frame", {
		Size = UDim2.new(0, sidebarWidth, 1, -topbarHeight),
		Position = UDim2.new(0, 0, 0, topbarHeight),
		ThemeTag = { BackgroundColor3 = "Sidebar" },
		BackgroundTransparency = 0,
		Parent = root,
	})

	local tabList = New("ScrollingFrame", {
		Size = UDim2.new(0, sidebarWidth, 1, -topbarHeight - 12),
		Position = UDim2.new(0, 0, 0, topbarHeight + 6),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = root,
	}, {
		listLayout(4),
		padding(0, {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 2),
		}),
	})
	Window.TabList = tabList

	-- vertical divider
	local divider = New("Frame", {
		Size = UDim2.new(0, 1, 1, -topbarHeight - 16),
		Position = UDim2.new(0, sidebarWidth, 0, topbarHeight + 8),
		BackgroundTransparency = 0.85,
		ThemeTag = { BackgroundColor3 = "Stroke" },
		Parent = root,
	})

	-- Content ----------------------------------------------------------
	local contentHolder = New("Frame", {
		Size = UDim2.new(1, -sidebarWidth - 12, 1, -topbarHeight - 12),
		Position = UDim2.new(0, sidebarWidth + 12, 0, topbarHeight + 6),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = root,
	})
	Window.ContentHolder = contentHolder

	-- Sidebar can be hidden so elements added straight to the window (no
	-- explicit tabs) use the full width. Hidden until the first real Tab.
	function Window:SetSidebar(visible)
		Window.SidebarVisible = visible
		sidebarFrame.Visible = visible
		tabList.Visible = visible
		divider.Visible = visible
		if visible then
			contentHolder.Size = UDim2.new(1, -sidebarWidth - 12, 1, -topbarHeight - 12)
			contentHolder.Position = UDim2.new(0, sidebarWidth + 12, 0, topbarHeight + 6)
		else
			contentHolder.Size = UDim2.new(1, -24, 1, -topbarHeight - 12)
			contentHolder.Position = UDim2.new(0, 12, 0, topbarHeight + 6)
		end
	end
	Window:SetSidebar(false)

	-- Behaviour --------------------------------------------------------
	dragify(main, topbar)

	function Window:SelectTab(targetIndex)
		Window.CurrentTab = targetIndex
		for i, data in pairs(Window.Tabs) do
			local active = i == targetIndex
			data.Page.Visible = active
			tween(data.Button, 0.15, { BackgroundTransparency = active and 0 or 1 })
			tween(data.Label, 0.15, {
				TextColor3 = active and Library.Theme.TabTextActive or Library.Theme.TabText,
			})
			if data.Icon then
				tween(data.Icon, 0.15, {
					ImageColor3 = active and Library.Theme.TabTextActive or Library.Theme.TabText,
				})
			end
			tween(data.ActiveBar, 0.15, { BackgroundTransparency = active and 0 or 1 })
		end
	end

	function Window:Tab(tabConfig)
		return createTab(Window, tabConfig)
	end

	-- Window-level elements (optional tabs). Calling Window:Button(...) etc.
	-- appends to an implicit "Main" page; if no explicit tabs exist the
	-- sidebar stays hidden and the page fills the window.
	local function defaultPage()
		if not Window.DefaultTab then
			Window.DefaultTab = createTab(Window, {
				Title = config.DefaultTabTitle or "Main",
				Implicit = true,
			})
		end
		return Window.DefaultTab
	end
	for name in pairs(Elements) do
		Window[name] = function(_, elementConfig)
			local tab = defaultPage()
			return tab[name](tab, elementConfig)
		end
	end

	-- Config save system ----------------------------------------------
	-- Opt-in: pass `ConfigFolder` (or `Folder`). Only elements created with
	-- a `Flag` are saved. Values round-trip through JSON on disk; Color3 and
	-- KeyCode are tagged so they deserialize back to the right type.
	local configFolder = config.ConfigFolder or config.Folder
	local hasFS = (writefile and readfile and isfile) and true or false

	local function color3ToHex(c)
		return string.format(
			"#%02X%02X%02X",
			math.floor(c.R * 255 + 0.5),
			math.floor(c.G * 255 + 0.5),
			math.floor(c.B * 255 + 0.5)
		)
	end

	local function serializeValue(v)
		local t = typeof(v)
		if t == "Color3" then
			return { __type = "Color3", value = color3ToHex(v) }
		elseif t == "EnumItem" then
			return { __type = "KeyCode", value = v.Name }
		elseif t == "table" then
			local arr = {}
			for key, on in pairs(v) do
				if on then
					table.insert(arr, key)
				end
			end
			return { __type = "Set", value = arr }
		end
		return v
	end

	local function deserializeValue(v)
		if typeof(v) == "table" and v.__type then
			if v.__type == "Color3" then
				return Color3.fromHex(v.value)
			elseif v.__type == "KeyCode" then
				return Enum.KeyCode[v.value]
			elseif v.__type == "Set" then
				return v.value
			end
		end
		return v
	end

	local Config = { Folder = configFolder }
	Window.Config = Config

	local function ensureFolder()
		if configFolder and makefolder and isfolder and not isfolder(configFolder) then
			pcall(makefolder, configFolder)
		end
	end

	function Config:Save(name)
		if not hasFS or not configFolder then
			warn("[SerhiiUI] config saving unavailable (need an executor + ConfigFolder)")
			return false
		end
		ensureFolder()
		local data = {}
		for flag, element in pairs(Library.Flags) do
			if element.Get then
				local ok, value = pcall(function()
					return element:Get()
				end)
				if ok and value ~= nil then
					data[flag] = serializeValue(value)
				end
			end
		end
		local ok, encoded = pcall(function()
			return HttpService:JSONEncode(data)
		end)
		if ok then
			pcall(writefile, configFolder .. "/" .. (name or "default") .. ".json", encoded)
			return true
		end
		return false
	end

	function Config:Load(name)
		if not hasFS or not configFolder then
			return false
		end
		local path = configFolder .. "/" .. (name or "default") .. ".json"
		if not isfile(path) then
			return false
		end
		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(readfile(path))
		end)
		if not ok or typeof(decoded) ~= "table" then
			return false
		end
		for flag, raw in pairs(decoded) do
			local element = Library.Flags[flag]
			if element and element.Set then
				pcall(function()
					element:Set(deserializeValue(raw))
				end)
			end
		end
		return true
	end

	function Config:List()
		local out = {}
		if not hasFS or not configFolder or not listfiles or not isfolder or not isfolder(configFolder) then
			return out
		end
		for _, file in ipairs(listfiles(configFolder)) do
			local name = tostring(file):match("([^/\\]+)%.json$")
			if name then
				table.insert(out, name)
			end
		end
		return out
	end

	function Config:Delete(name)
		if hasFS and configFolder and delfile then
			local path = configFolder .. "/" .. (name or "default") .. ".json"
			if isfile(path) then
				pcall(delfile, path)
				return true
			end
		end
		return false
	end

	-- Floating reopen button (shown while minimized; also reopened via key).
	local openButton = New("TextButton", {
		Text = config.Icon and "" or "≡",
		FontFace = font(Enum.FontWeight.Bold),
		TextSize = 24,
		AutoButtonColor = false,
		Size = UDim2.new(0, 46, 0, 46),
		Position = UDim2.new(0, 20, 0, 20),
		ThemeTag = { BackgroundColor3 = "Accent", TextColor3 = "AccentText" },
		Visible = false,
		Parent = ScreenGui,
	}, {
		corner(23),
	})
	if config.Icon and config.Icon ~= "" then
		local obIcon = makeIcon(config.Icon, UDim2.new(0, 24, 0, 24), "AccentText")
		obIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		obIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
		obIcon.Parent = openButton
	end
	dragify(openButton)

	-- Animations use Size only (no GroupTransparency) to keep icons crisp.
	local collapsed = UDim2.new(size.X.Scale, size.X.Offset, 0, 0)

	function Window:Minimize()
		Window.Minimized = true
		tween(main, 0.3, { Size = collapsed }, Enum.EasingStyle.Quint)
		task.delay(0.31, function()
			if Window.Minimized then
				main.Visible = false
				openButton.Visible = true
			end
		end)
	end

	function Window:Open()
		Window.Minimized = false
		openButton.Visible = false
		main.Visible = true
		main.Size = collapsed
		tween(main, 0.4, { Size = size }, Enum.EasingStyle.Back)
	end

	function Window:Close()
		tween(main, 0.3, { Size = collapsed }, Enum.EasingStyle.Quint)
		task.delay(0.32, function()
			Window:Destroy()
		end)
	end

	function Window:Destroy()
		Window.Destroyed = true
		for _, conn in ipairs(Library.Connections) do
			pcall(function()
				conn:Disconnect()
			end)
		end
		ScreenGui:Destroy()
	end

	connect(openButton.MouseButton1Click, function()
		Window:Open()
	end)

	connect(UserInputService.InputBegan, function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Window.ToggleKey then
			if Window.Minimized then
				Window:Open()
			else
				Window:Minimize()
			end
		end
	end)

	-- Intro animation --------------------------------------------------
	main.Size = collapsed
	tween(main, 0.45, { Size = size }, Enum.EasingStyle.Back)

	table.insert(Library.Windows, Window)
	return Window
end

return Library
