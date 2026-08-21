local Modules = {}

Modules.Utility = (function() local UserInputService = game:GetService("UserInputService") local Utility = {}

function Utility.New(className, props, children) local inst = Instance.new(className) if props then for key, value in pairs(props) do if key ~= "Parent" then inst[key] = value end end end if children then for _, child in ipairs(children) do child.Parent = inst end end if props and props.Parent then inst.Parent = props.Parent end return inst end

function Utility.SafeCall(fn, ...) if type(fn) ~= "function" then return end local ok, err = pcall(fn, ...) if not ok then warn("[PISIT HUB] Error: " .. tostring(err)) end end

function Utility.MakeDraggable(frame, handle) handle = handle or frame local dragging, dragStart, startPos handle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = frame.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end) handle.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end) end

function Utility.Round(val, dec) local mult = 10 ^ (dec or 0) return math.floor(val * mult + 0.5) / mult end

function Utility.Clamp(val, min, max) return math.max(min, math.min(max, val)) end

return Utility end)()

Modules.Window = (function()
local Players = game:GetService("Players")
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Window = {}
Window.__index = Window

function Window.new(config)
	config = config or {}
	local self = setmetatable({}, Window)
	self.Tabs = {}
	self.ActiveTab = nil
	self.Minimized = false

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	self.ScreenGui = Utility.New("ScreenGui", { Name = "PISIT_HUB", ResetOnSpawn = false, Parent = playerGui })

	self.Main = Utility.New("Frame", { Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(400, 320), BackgroundColor3 = Theme.Get("Background"), ClipsDescendants = true, Parent = self.ScreenGui })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.Main })
	self.MainStroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Thickness = 1.2, Transparency = 0.2, Parent = self.Main })

	self:_buildTopBar(config.Title or "PISIT HUB")
	self:_buildBody()
	self:_buildTogglePill()
	Modules.Notification.Init(self.ScreenGui)
	Utility.MakeDraggable(self.Main, self.TopBar)
	Utility.MakeDraggable(self.TogglePill)
	Animation.OpenWindow(self.Main)

	Theme.OnChanged:Connect(function()
		self.Main.BackgroundColor3 = Theme.Get("Background")
		self.MainStroke.Color = Theme.Get("Border")
		self.TopBar.BackgroundColor3 = Theme.Get("SecondaryBackground")
		self.TitleLabel.TextColor3 = Theme.Get("Accent")
		self.CloseBtn.BackgroundColor3 = Theme.Get("ElementBackground")
		self.CloseBtn.TextColor3 = Theme.Get("Text")
		self.MinBtn.BackgroundColor3 = Theme.Get("ElementBackground")
		self.MinBtn.TextColor3 = Theme.Get("Text")
		self.Sidebar.BackgroundColor3 = Theme.Get("SecondaryBackground")
		self.TogglePill.BackgroundColor3 = Theme.Get("SecondaryBackground")
		self.PillStroke.Color = Theme.Get("Accent")
		self.PillLabel.TextColor3 = Theme.Get("Text")
	end)

	return self
end

function Window:_buildTopBar(titleText)
	self.TopBar = Utility.New("Frame", { Name = "TopBar", BackgroundColor3 = Theme.Get("SecondaryBackground"), Size = UDim2.new(1, 0, 0, 40), Parent = self.Main })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.TopBar })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 8), Parent = self.TopBar })

	self.TitleLabel = Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -65, 1, 0), Text = titleText, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Accent"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.TopBar })

	self.CloseBtn = Utility.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.Get("ElementBackground"), Text = "x", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Text"), AutoButtonColor = false, Parent = self.TopBar })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = self.CloseBtn })
	self.CloseBtn.MouseButton1Click:Connect(function() self.ScreenGui:Destroy() end)

	self.MinBtn = Utility.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -50, 0.5, 0), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.Get("ElementBackground"), Text = "-", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Text"), AutoButtonColor = false, Parent = self.TopBar })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = self.MinBtn })
	self.MinBtn.MouseButton1Click:Connect(function()
		self.Minimized = true
		Animation.CloseWindow(self.Main, function()
			self.TogglePill.Visible = true
		end)
	end)
end

function Window:_buildBody()
	self.Body = Utility.New("Frame", { Name = "Body", Position = UDim2.new(0, 0, 0, 40), Size = UDim2.new(1, 0, 1, -40), BackgroundTransparency = 1, Parent = self.Main })
	self.Sidebar = Utility.New("ScrollingFrame", { Name = "Sidebar", BackgroundColor3 = Theme.Get("SecondaryBackground"), Size = UDim2.new(0, 110, 1, 0), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Parent = self.Body })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), Parent = self.Sidebar })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 3), Parent = self.Sidebar })

	self.PageContainer = Utility.New("Frame", { Name = "PageContainer", Position = UDim2.new(0, 110, 0, 0), Size = UDim2.new(1, -110, 1, 0), BackgroundTransparency = 1, Parent = self.Body })
end

function Window:_buildTogglePill()
	self.TogglePill = Utility.New("TextButton", {
		Name = "TogglePill", Text = "", AutoButtonColor = false,
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 16),
		Size = UDim2.fromOffset(150, 38),
		BackgroundColor3 = Theme.Get("SecondaryBackground"), Visible = false, Parent = self.ScreenGui
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.TogglePill })
	self.PillStroke = Utility.New("UIStroke", { Color = Theme.Get("Accent"), Thickness = 1.5, Transparency = 0.1, Parent = self.TogglePill })
	local pillStroke = self.PillStroke

	self.PillLabel = Utility.New("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 16, 0, 0),
		Text = "ค่าย PISIT HUB", Font = Enum.Font.GothamBold, TextSize = 13,
		TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.TogglePill
	})

	task.spawn(function()
		while self.TogglePill.Parent do
			if self.TogglePill.Visible then
				Animation.Glow(pillStroke, true)
				task.wait(0.8)
				Animation.Glow(pillStroke, false)
				task.wait(0.8)
			else
				task.wait(0.3)
			end
		end
	end)
	
	self.TogglePill.MouseButton1Click:Connect(function()
		self.Minimized = false
		self.TogglePill.Visible = false
		Animation.OpenWindow(self.Main)
	end)
end

function Window:CreateTab(config)
	local tab = Modules.Tab.new(self, self.Sidebar, self.PageContainer, config)
	table.insert(self.Tabs, tab)
	if #self.Tabs == 1 then self:SelectTab(tab) end
	return tab
end

function Window:SelectTab(tab)
	if self.ActiveTab then self.ActiveTab:SetActive(false) end
	self.ActiveTab = tab
	tab:SetActive(true)
end

return Window
end)()

Modules.Tab = (function() local Theme = Modules.Theme local Utility = Modules.Utility local Animation = Modules.Animation local Tab = {} Tab.__index = Tab

function Tab.new(window, tabListParent, pageParent, config) config = config or {} local self = setmetatable({}, Tab) self.Window = window

self.Button = Utility.New("TextButton", { Name = "Tween (movement)", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), Parent = tabListParent })
Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Button })
Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = self.Button })

self.Indicator = Utility.New("Frame", { Size = UDim2.new(0, 2, 0, 14), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.Get("Accent"), BackgroundTransparency = 1, Parent = self.Button })
Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Indicator })

self.Label = Utility.New("TextLabel", { Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -8, 1, 0), BackgroundTransparency = 1, Text = config.Title or "Tab", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Get("SubText"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Button })

self.Page = Utility.New("ScrollingFrame", { Name = "Page", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Visible = false, Parent = pageParent })
Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8), Parent = self.Page })
Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 2), Parent = self.Page })

self.Button.MouseButton1Click:Connect(function() self.Window:SelectTab(self) end)

Theme.OnChanged:Connect(function()
	self.Indicator.BackgroundColor3 = Theme.Get("Accent")
	self.Label.TextColor3 = self.Active and Theme.Get("Text") or Theme.Get("SubText")
end)

return self


end

function Tab:CreateSection(cfg) return Modules.Section.new(self.Page, cfg) end

function Tab:SetActive(active) self.Active = active self.Page.Visible = active Animation.Tween(self.Indicator, Animation.Easing.Normal, { BackgroundTransparency = active and 0 or 1 }) Animation.Tween(self.Label, Animation.Easing.Normal, { TextColor3 = active and Theme.Get("Text") or Theme.Get("SubText") }) end

return Tab end)()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Map = workspace:WaitForChild("Map")

local TWEEN_SPEED = 200
local SelectedIsland
local CurrentTween

local function GetTeleportPart(Object)
	if Object:IsA("BasePart") then
		return Object
	end

	if Object:IsA("Model") then
		if Object.PrimaryPart then
			return Object.PrimaryPart
		end

		return Object:FindFirstChildWhichIsA("BasePart", true)
	end

	return Object:FindFirstChildWhichIsA("BasePart", true)
end

local function StopTween()
	if CurrentTween then
		CurrentTween:Cancel()
		CurrentTween = nil
	end
end

local function TweenToIsland(Island)
	if not Island then
		return
	end

	local Character = Player.Character
	if not Character then
		return
	end

	local Root = Character:FindFirstChild("HumanoidRootPart")
	if not Root then
		return
	end

	local Part = GetTeleportPart(Island)
	if not Part then
		warn("ไม่พบจุด Tween ของ " .. Island.Name)
		return
	end

	StopTween()

	local Target = Part.Position + Vector3.new(0, 5, 0)
	local Distance = (Root.Position - Target).Magnitude
	local Duration = math.max(Distance / TWEEN_SPEED, 0.05)

	CurrentTween = TweenService:Create(
		Root,
		TweenInfo.new(
			Duration,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out
		),
		{
			CFrame = CFrame.new(Target)
		}
	)

	CurrentTween:Play()

	CurrentTween.Completed:Connect(function()
		CurrentTween = nil
	end)
end

local IslandNames = {}

for _, Island in ipairs(Map:GetChildren()) do
	if Island:IsA("Model")
		or Island:IsA("BasePart")
		or Island:IsA("Folder") then

		table.insert(IslandNames, Island.Name)
	end
end

table.sort(IslandNames)

local IslandDropdown = Modules.Dropdown.new(parent, {
	Title = "Island",
	Options = IslandNames,
	Default = IslandNames[1],

	Callback = function(Value)
		SelectedIsland = Map:FindFirstChild(Value)
	end
})

SelectedIsland = Map:FindFirstChild(IslandNames[1])

Modules.Button.new(parent, {
	Title = "🏝️ Tween To Island",

	Callback = function()
		if SelectedIsland then
			TweenToIsland(SelectedIsland)
		end
	end
})

Modules.Button.new(parent, {
	Title = "🛑 Stop Tween",

	Callback = function()
		StopTween()
	end
})
