-- ══════════════════════════════════════════════════════════════
--  Multi-Tool  |  Rayfield UI
--  Made by Humbl3Envixity
-- ══════════════════════════════════════════════════════════════

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- ──────────────────────────────────────────────────────────────
--  Master Config  (all disabled by default)
-- ──────────────────────────────────────────────────────────────
local Config = {
	-- ── Fly ───────────────────────────────────────────────────
	FlyMasterEnabled = false,
	FlySpeed         = 50,
	Boost            = 2,
	Acceleration     = 8,

	-- ── Bypass ────────────────────────────────────────────────
	BypassEnabled    = false,

	-- ── Noclip ────────────────────────────────────────────────
	NoclipMasterEnabled = false,

	-- ── Aimbot ────────────────────────────────────────────────
	AimbotMasterEnabled = false,
	AimbotActive        = false,
	AimbotPart          = "Head",
	AimbotFOV           = 120,
	AimbotSmooth        = 0.15,
	AimbotTeamCheck     = false,
	AimbotVisible       = true,
	AimbotShowFOV       = true,
	AimbotKeybind       = Enum.KeyCode.Q,

	-- ── Silent Aim ────────────────────────────────────────────
	SilentAimEnabled    = false,
	SilentAimPart       = "Head",
	SilentAimFOV        = 150,
	SilentAimTeamCheck  = false,
	SilentAimShowFOV    = true,
	SilentAimVisible    = true,
	SilentAimPrediction = 0.1,

	-- ── Triggerbot ────────────────────────────────────────────
	TriggerbotEnabled   = false,
	TriggerbotDelay     = 0.1,
	TriggerbotTeamCheck = false,

	-- ── ESP ───────────────────────────────────────────────────
	ESPMasterEnabled = false,
	ESPShowName      = true,
	ESPShowHealth    = true,
	ESPShowDistance  = true,
	ESPTeamCheck     = false,
	ESPMaxDist       = 1000,

	-- ── Speed ─────────────────────────────────────────────────
	SpeedEnabled     = false,
	WalkSpeed        = 16,
	JumpPower        = 50,

	-- ── Hitbox ────────────────────────────────────────────────
	HitboxEnabled    = false,
	HitboxSize       = 5,
	HitboxVisible    = false,
	HitboxTeamCheck  = false,
}

-- ──────────────────────────────────────────────────────────────
--  Load Rayfield
-- ──────────────────────────────────────────────────────────────
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name                = "🎮  Multi-Tool",
	LoadingTitle        = "Multi-Tool",
	LoadingSubtitle     = "by Humbl3Envixity",
	ConfigurationSaving = { Enabled = false },
	KeySystem           = false,
})

-- ──────────────────────────────────────────────────────────────
--  Helpers
-- ──────────────────────────────────────────────────────────────
local function getHRP()
	return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end
local function getHumanoid()
	return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end
local function getMyPos()
	local h = getHRP(); return h and h.Position or Vector3.new()
end

-- ══════════════════════════════════════════════════════════════
--   FLY  LOGIC
-- ══════════════════════════════════════════════════════════════
local flying      = false
local flyVelocity = Vector3.new()
local bodyVelocity, bodyGyro

local function enableFlight()
	if not Config.FlyMasterEnabled then return end
	local hrp = getHRP(); local hum = getHumanoid()
	if not hrp or not hum then return end
	if flying then return end

	hum.PlatformStand = true

	bodyGyro           = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
	bodyGyro.P = 1e4; bodyGyro.D = 100
	bodyGyro.CFrame = hrp.CFrame; bodyGyro.Parent = hrp

	bodyVelocity          = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
	bodyVelocity.Velocity = Vector3.new()
	bodyVelocity.P = 1e4; bodyVelocity.Parent = hrp

	flying = true
end

local function disableFlight()
	local hum = getHumanoid()
	if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
	if bodyGyro     then bodyGyro:Destroy();     bodyGyro     = nil end
	if hum          then hum.PlatformStand = false end
	flyVelocity = Vector3.new()
	flying = false
end

RunService.Heartbeat:Connect(function(dt)
	if not flying then return end
	local hrp = getHRP()
	if not hrp or not bodyVelocity or not bodyGyro then return end

	local moveDir = Vector3.new(); local cam = camera.CFrame
	local boost = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and Config.Boost or 1

	if UserInputService:IsKeyDown(Enum.KeyCode.W)            then moveDir += cam.LookVector  end
	if UserInputService:IsKeyDown(Enum.KeyCode.S)            then moveDir -= cam.LookVector  end
	if UserInputService:IsKeyDown(Enum.KeyCode.A)            then moveDir -= cam.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D)            then moveDir += cam.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space)        then moveDir += Vector3.new(0,1,0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)  then moveDir -= Vector3.new(0,1,0) end

	if moveDir.Magnitude > 0 then
		moveDir = moveDir.Unit * Config.FlySpeed * boost
	end
	flyVelocity           = flyVelocity:Lerp(moveDir, math.min(1, Config.Acceleration * dt))
	bodyVelocity.Velocity = flyVelocity

	local ld = Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z)
	if ld.Magnitude > 0 then bodyGyro.CFrame = CFrame.lookAt(Vector3.new(), ld) end
end)

player.CharacterAdded:Connect(function()
	flying = false; bodyVelocity = nil; bodyGyro = nil; flyVelocity = Vector3.new()
end)

-- ══════════════════════════════════════════════════════════════
--  🛡  BYPASS  LOGIC
-- ══════════════════════════════════════════════════════════════
local bypassConn; local lastBypassTick = 0

local function startBypass()
	if bypassConn then return end
	bypassConn = RunService.Heartbeat:Connect(function()
		if not Config.BypassEnabled then return end
		local hrp = getHRP(); if not hrp then return end
		if tick() - lastBypassTick >= 0.8 then
			lastBypassTick = tick()
			local saved = bodyVelocity and bodyVelocity.Velocity or Vector3.new()
			hrp.AssemblyLinearVelocity = Vector3.new()
			task.defer(function()
				if bodyVelocity then bodyVelocity.Velocity = saved end
			end)
		end
	end)
end

local function stopBypass()
	if bypassConn then bypassConn:Disconnect(); bypassConn = nil end
end

-- ══════════════════════════════════════════════════════════════
--  👻  NOCLIP  LOGIC
-- ══════════════════════════════════════════════════════════════
local noclipActive = false
local noclipConn

local function setCollision(char, state)
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then p.CanCollide = state end
	end
end

local function enableNoclip()
	if not Config.NoclipMasterEnabled then return end
	if noclipActive then return end
	noclipActive = true
	noclipConn = RunService.Stepped:Connect(function()
		if player.Character then setCollision(player.Character, false) end
	end)
end

local function disableNoclip()
	noclipActive = false
	if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
	if player.Character then setCollision(player.Character, true) end
end

player.CharacterAdded:Connect(function()
	noclipActive = false
	if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
end)

-- ══════════════════════════════════════════════════════════════
--  👁  ESP  LOGIC  (Drawing API)
-- ══════════════════════════════════════════════════════════════
local espObjects = {}
local espConn

local function hpColor(pct)
	if pct > 0.6 then return Color3.fromRGB(80,220,80)
	elseif pct > 0.3 then return Color3.fromRGB(220,200,50)
	else return Color3.fromRGB(220,60,60) end
end

local function makeText(size, color)
	local t      = Drawing.new("Text")
	t.Size       = size or 13
	t.Color      = color or Color3.fromRGB(255,255,255)
	t.Outline    = true
	t.OutlineColor = Color3.fromRGB(0,0,0)
	t.Font       = Drawing.Fonts.UI
	t.Visible    = false
	return t
end

local function makeLine(color, thickness)
	local l     = Drawing.new("Line")
	l.Color     = color or Color3.fromRGB(255,255,255)
	l.Thickness = thickness or 1
	l.Visible   = false
	return l
end

local function createESPForPlayer(p)
	if espObjects[p] then return end
	espObjects[p] = {
		nameLabel = makeText(13, Color3.fromRGB(255,255,255)),
		hpLabel   = makeText(11, Color3.fromRGB(150,255,150)),
		distLabel = makeText(11, Color3.fromRGB(180,180,255)),
		hpBarBg   = makeLine(Color3.fromRGB(30,30,30), 3),
		hpBar     = makeLine(Color3.fromRGB(80,220,80), 3),
	}
end

local function removeESPForPlayer(p)
	local obj = espObjects[p]; if not obj then return end
	for _, v in pairs(obj) do pcall(function() v:Remove() end) end
	espObjects[p] = nil
end

local function clearAllESP()
	for p in pairs(espObjects) do removeESPForPlayer(p) end
end

local function startESP()
	if espConn then return end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then createESPForPlayer(p) end
	end

	Players.PlayerAdded:Connect(function(p)
		if p ~= player and Config.ESPMasterEnabled then createESPForPlayer(p) end
	end)
	Players.PlayerRemoving:Connect(removeESPForPlayer)

	espConn = RunService.RenderStepped:Connect(function()
		if not Config.ESPMasterEnabled then
			for _, obj in pairs(espObjects) do
				for _, v in pairs(obj) do v.Visible = false end
			end
			return
		end

		local myPos = getMyPos()

		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end

			createESPForPlayer(p)
			local obj = espObjects[p]

			if Config.ESPTeamCheck and p.Team == player.Team then
				for _, v in pairs(obj) do v.Visible = false end; continue
			end

			local char = p.Character
			local hrp  = char and char:FindFirstChild("HumanoidRootPart")
			local hum  = char and char:FindFirstChildOfClass("Humanoid")

			if not hrp or not hum then
				for _, v in pairs(obj) do v.Visible = false end; continue
			end

			local dist = (hrp.Position - myPos).Magnitude
			if dist > Config.ESPMaxDist then
				for _, v in pairs(obj) do v.Visible = false end; continue
			end

			local rootScreen, onScreen = camera:WorldToViewportPoint(hrp.Position)
			local headPart = char:FindFirstChild("Head") or hrp
			local topPos   = headPart.Position + Vector3.new(0, headPart.Size.Y/2 + 0.3, 0)
			local topScreen = camera:WorldToViewportPoint(topPos)

			if not onScreen then
				for _, v in pairs(obj) do v.Visible = false end; continue
			end

			local tx = topScreen.X;  local ty = topScreen.Y
			local fontSize = math.clamp(math.floor(900/dist), 9, 16)
			local hpPct    = math.clamp(hum.Health / math.max(hum.MaxHealth,1), 0, 1)

			if Config.ESPShowName then
				obj.nameLabel.Text     = p.DisplayName ~= "" and p.DisplayName or p.Name
				obj.nameLabel.Size     = fontSize
				obj.nameLabel.Position = Vector2.new(tx, ty - fontSize - 2)
				obj.nameLabel.Visible  = true
			else
				obj.nameLabel.Visible = false
			end

			local hpLabelY = ty - fontSize - 2 + (Config.ESPShowName and fontSize+2 or 0)
			if Config.ESPShowHealth then
				obj.hpLabel.Text     = string.format("HP: %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
				obj.hpLabel.Color    = hpColor(hpPct)
				obj.hpLabel.Size     = math.max(fontSize-1, 9)
				obj.hpLabel.Position = Vector2.new(tx, hpLabelY)
				obj.hpLabel.Visible  = true
			else
				obj.hpLabel.Visible = false
			end

			local distLabelY = hpLabelY + (Config.ESPShowHealth and fontSize+2 or 0)
			if Config.ESPShowDistance then
				obj.distLabel.Text     = string.format("[%.0f studs]", dist)
				obj.distLabel.Color    = Color3.fromRGB(180,180,255)
				obj.distLabel.Size     = math.max(fontSize-2, 8)
				obj.distLabel.Position = Vector2.new(tx, distLabelY)
				obj.distLabel.Visible  = true
			else
				obj.distLabel.Visible = false
			end

			if Config.ESPShowHealth then
				local ok, cf, size = pcall(function()
					return char:GetBoundingBox()
				end)

				if ok and cf and size then
					local worldTop    = cf.Position + Vector3.new(0,  size.Y / 2, 0)
					local worldBottom = cf.Position - Vector3.new(0,  size.Y / 2, 0)

					local screenTop,    topVis = camera:WorldToViewportPoint(worldTop)
					local screenBottom, botVis = camera:WorldToViewportPoint(worldBottom)

					if topVis and botVis and screenTop.Z > 0 then
						local barX      = screenTop.X - 10
						local barTop2   = screenTop.Y
						local barBottom2= screenBottom.Y

						if barBottom2 < barTop2 then
							barTop2, barBottom2 = barBottom2, barTop2
						end

						obj.hpBarBg.From    = Vector2.new(barX, barTop2)
						obj.hpBarBg.To      = Vector2.new(barX, barBottom2)
						obj.hpBarBg.Visible = true

						local filledY   = barBottom2 - (barBottom2 - barTop2) * hpPct
						obj.hpBar.Color = hpColor(hpPct)
						obj.hpBar.From  = Vector2.new(barX, filledY)
						obj.hpBar.To    = Vector2.new(barX, barBottom2)
						obj.hpBar.Visible = true
					else
						obj.hpBarBg.Visible = false
						obj.hpBar.Visible   = false
					end
				else
					obj.hpBarBg.Visible = false
					obj.hpBar.Visible   = false
				end
			else
				obj.hpBarBg.Visible = false
				obj.hpBar.Visible   = false
			end
		end
	end)
end

local function stopESP()
	if espConn then espConn:Disconnect(); espConn = nil end
	clearAllESP()
end

-- ══════════════════════════════════════════════════════════════
--  🎯  AIMBOT  LOGIC
-- ══════════════════════════════════════════════════════════════
local aimbotConn
local screenGui, fovFrame
local rmbAimActive = false

local function createFOVCircle()
	if screenGui then screenGui:Destroy() end
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AimbotFOV"; screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = player.PlayerGui

	fovFrame = Instance.new("Frame")
	fovFrame.BackgroundTransparency = 1; fovFrame.BorderSizePixel = 0
	fovFrame.Parent = screenGui

	local circle = Instance.new("Frame")
	circle.BackgroundTransparency = 1; circle.BorderSizePixel = 0
	circle.AnchorPoint = Vector2.new(0.5, 0.5)
	circle.Size = UDim2.fromScale(1,1); circle.Position = UDim2.fromScale(0.5,0.5)
	circle.Parent = fovFrame

	local uc = Instance.new("UICorner")
	uc.CornerRadius = UDim.new(0.5, 0); uc.Parent = circle

	local us = Instance.new("UIStroke")
	us.Color = Color3.fromRGB(255,65,65); us.Thickness = 1.5; us.Parent = circle
end

local function updateFOVCircle()
	if not fovFrame then return end
	local vp = camera.ViewportSize; local r = Config.AimbotFOV
	fovFrame.Size     = UDim2.fromOffset(r*2, r*2)
	fovFrame.Position = UDim2.fromOffset(vp.X/2 - r, vp.Y/2 - r)
	fovFrame.Visible  = Config.AimbotShowFOV
end

local function destroyFOVCircle()
	if screenGui then screenGui:Destroy(); screenGui = nil; fovFrame = nil end
end

local function isVisible(targetPart)
	local hrp = getHRP(); if not hrp then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }
	local result = workspace:Raycast(hrp.Position, targetPart.Position - hrp.Position, params)
	if result then
		local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
		return hitChar ~= nil and Players:GetPlayerFromCharacter(hitChar) ~= nil
	end
	return false
end

local function getBestTarget()
	local vp     = camera.ViewportSize
	local center = Vector2.new(vp.X/2, vp.Y/2)
	local bestDist, bestPart = Config.AimbotFOV, nil

	for _, p in ipairs(Players:GetPlayers()) do
		if p == player then continue end
		if Config.AimbotTeamCheck and p.Team == player.Team then continue end
		local char = p.Character; if not char then continue end
		local hum  = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then continue end
		local part = char:FindFirstChild(Config.AimbotPart) or char:FindFirstChild("HumanoidRootPart")
		if not part then continue end
		local sp, onScreen = camera:WorldToViewportPoint(part.Position)
		if not onScreen then continue end
		local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
		if d > Config.AimbotFOV then continue end
		if Config.AimbotVisible and not isVisible(part) then continue end
		if d < bestDist then bestDist = d; bestPart = part end
	end
	return bestPart
end

local function startAimbot()
	if aimbotConn then return end
	aimbotConn = RunService.RenderStepped:Connect(function()
		updateFOVCircle()
		if not Config.AimbotActive then return end
		local target = getBestTarget(); if not target then return end
		local targetCF = CFrame.lookAt(camera.CFrame.Position, target.Position)
		camera.CFrame  = camera.CFrame:Lerp(targetCF, Config.AimbotSmooth)
	end)
end

local function stopAimbot()
	Config.AimbotActive = false
	if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end
	destroyFOVCircle()
end

-- ══════════════════════════════════════════════════════════════
--  🔇  SILENT AIM  LOGIC  (FIXED - Multiple Methods)
-- ══════════════════════════════════════════════════════════════
local silentAimFOVCircle = nil
local silentAimConn = nil
local silentAimTarget = nil
local silentAimTargetPart = nil

-- Store original functions
local oldNamecall = nil
local oldIndex = nil
local hooksEnabled = false

-- Create FOV Circle using Drawing API
local function createSilentFOVCircle()
	pcall(function()
		if silentAimFOVCircle then
			silentAimFOVCircle:Remove()
		end
	end)

	local success, circle = pcall(function()
		local c = Drawing.new("Circle")
		c.Color = Color3.fromRGB(0, 255, 150)
		c.Thickness = 2
		c.Filled = false
		c.Transparency = 1
		c.NumSides = 64
		c.Visible = false
		c.Radius = Config.SilentAimFOV
		c.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		return c
	end)

	if success then
		silentAimFOVCircle = circle
	end
end

local function updateSilentFOVCircle()
	if silentAimFOVCircle then
		pcall(function()
			silentAimFOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
			silentAimFOVCircle.Radius = Config.SilentAimFOV
			silentAimFOVCircle.Visible = Config.SilentAimShowFOV and Config.SilentAimEnabled
		end)
	end
end

local function destroySilentFOVCircle()
	if silentAimFOVCircle then
		pcall(function()
			silentAimFOVCircle:Remove()
		end)
		silentAimFOVCircle = nil
	end
end

-- Check if target is valid
local function isValidSilentTarget(targetPlayer)
	if not targetPlayer then return false end
	if targetPlayer == player then return false end
	if Config.SilentAimTeamCheck and targetPlayer.Team == player.Team then return false end

	local char = targetPlayer.Character
	if not char then return false end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end

	return true
end

-- Check visibility for silent aim
local function isSilentVisible(targetPart)
	if not Config.SilentAimVisible then return true end

	local hrp = getHRP()
	if not hrp then return false end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }

	local direction = (targetPart.Position - hrp.Position)
	local result = workspace:Raycast(hrp.Position, direction, params)

	if result then
		local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
		if hitModel then
			local hitPlayer = Players:GetPlayerFromCharacter(hitModel)
			if hitPlayer then
				return true
			end
		end
		return false
	end
	return true
end

-- Get best silent aim target
local function getSilentAimTarget()
	local vp = camera.ViewportSize
	local center = Vector2.new(vp.X / 2, vp.Y / 2)
	local bestDist = Config.SilentAimFOV
	local bestPart = nil
	local bestPlayer = nil

	for _, p in ipairs(Players:GetPlayers()) do
		if not isValidSilentTarget(p) then continue end

		local char = p.Character
		if not char then continue end

		local part = char:FindFirstChild(Config.SilentAimPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
		if not part then continue end

		local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
		if not onScreen then continue end

		local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
		if dist > Config.SilentAimFOV then continue end

		if not isSilentVisible(part) then continue end

		if dist < bestDist then
			bestDist = dist
			bestPart = part
			bestPlayer = p
		end
	end

	return bestPart, bestPlayer
end

-- Get predicted position for moving targets
local function getPredictedPosition(targetPart, targetPlayer)
	if not targetPart then return nil end
	if Config.SilentAimPrediction <= 0 then return targetPart.Position end

	local char = targetPlayer and targetPlayer.Character
	if not char then return targetPart.Position end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return targetPart.Position end

	local velocity = hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.new(0, 0, 0)
	local predicted = targetPart.Position + (velocity * Config.SilentAimPrediction)

	return predicted
end

-- Update target every frame
local function updateSilentTarget()
	if Config.SilentAimEnabled then
		silentAimTargetPart, silentAimTarget = getSilentAimTarget()
	else
		silentAimTargetPart = nil
		silentAimTarget = nil
	end
end

-- Setup hooks for silent aim
local function setupSilentAimHooks()
	if hooksEnabled then return end

	-- Check if hookmetamethod exists
	if not hookmetamethod then
		warn("[Silent Aim] hookmetamethod not found - using alternative method")
		return false
	end

	-- Hook __namecall
	local namecallSuccess = pcall(function()
		oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
			local args = {...}
			local method = getnamecallmethod()

			if Config.SilentAimEnabled and silentAimTargetPart then
				local predictedPos = getPredictedPosition(silentAimTargetPart, silentAimTarget)

				if predictedPos then
					-- Hook FindPartOnRay
					if method == "FindPartOnRay" or method == "findPartOnRay" then
						if typeof(args[1]) == "Ray" then
							local origin = args[1].Origin
							local newDirection = (predictedPos - origin).Unit * 5000
							args[1] = Ray.new(origin, newDirection)
							return oldNamecall(self, unpack(args))
						end
					end

					-- Hook FindPartOnRayWithIgnoreList
					if method == "FindPartOnRayWithIgnoreList" or method == "findPartOnRayWithIgnoreList" then
						if typeof(args[1]) == "Ray" then
							local origin = args[1].Origin
							local newDirection = (predictedPos - origin).Unit * 5000
							args[1] = Ray.new(origin, newDirection)
							return oldNamecall(self, unpack(args))
						end
					end

					-- Hook FindPartOnRayWithWhitelist
					if method == "FindPartOnRayWithWhitelist" or method == "findPartOnRayWithWhitelist" then
						if typeof(args[1]) == "Ray" then
							local origin = args[1].Origin
							local newDirection = (predictedPos - origin).Unit * 5000
							args[1] = Ray.new(origin, newDirection)
							return oldNamecall(self, unpack(args))
						end
					end

					-- Hook Raycast (modern method)
					if method == "Raycast" and self == workspace then
						if typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
							local origin = args[1]
							local newDirection = (predictedPos - origin).Unit * 5000
							args[2] = newDirection
							return oldNamecall(self, unpack(args))
						end
					end
				end
			end

			return oldNamecall(self, ...)
		end))
	end)

	-- Hook __index for mouse properties
	local indexSuccess = pcall(function()
		oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
			if Config.SilentAimEnabled and silentAimTargetPart then
				local predictedPos = getPredictedPosition(silentAimTargetPart, silentAimTarget)

				if predictedPos then
					-- Mouse.Hit
					if key == "Hit" and tostring(self) == "Mouse" then
						return CFrame.new(predictedPos)
					end

					-- Mouse.Target
					if key == "Target" and tostring(self) == "Mouse" then
						return silentAimTargetPart
					end

					-- Mouse.UnitRay
					if key == "UnitRay" and tostring(self) == "Mouse" then
						local origin = camera.CFrame.Position
						return Ray.new(origin, (predictedPos - origin).Unit)
					end

					-- Mouse.X and Mouse.Y (optional - for some games)
					if (key == "X" or key == "Y") and tostring(self) == "Mouse" then
						local screenPos = camera:WorldToViewportPoint(predictedPos)
						if key == "X" then
							return screenPos.X
						else
							return screenPos.Y
						end
					end
				end
			end

			return oldIndex(self, key)
		end))
	end)

	if namecallSuccess or indexSuccess then
		hooksEnabled = true
		return true
	end

	return false
end

-- Start silent aim
local function startSilentAim()
	-- Create FOV circle
	createSilentFOVCircle()

	-- Setup hooks
	local hookSuccess = setupSilentAimHooks()

	if not hookSuccess then
		Rayfield:Notify({
			Title = "Silent Aim Warning",
			Content = "Hooks may not work on this executor. Try using Hitbox Expander instead.",
			Duration = 5,
		})
	end

	-- Update loop
	if silentAimConn then silentAimConn:Disconnect() end
	silentAimConn = RunService.RenderStepped:Connect(function()
		updateSilentFOVCircle()
		updateSilentTarget()
	end)
end

-- Stop silent aim
local function stopSilentAim()
	Config.SilentAimEnabled = false
	silentAimTarget = nil
	silentAimTargetPart = nil

	if silentAimConn then
		silentAimConn:Disconnect()
		silentAimConn = nil
	end

	destroySilentFOVCircle()
end

-- ══════════════════════════════════════════════════════════════
--  🔫  TRIGGERBOT  LOGIC
-- ══════════════════════════════════════════════════════════════
local triggerbotConn
local lastTriggerTime = 0

local function getTargetFromMouse()
	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }

	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)

	if result and result.Instance then
		local model = result.Instance:FindFirstAncestorOfClass("Model")
		if model then
			return Players:GetPlayerFromCharacter(model)
		end
	end
	return nil
end

local function isEnemyTarget(targetPlayer)
	if not targetPlayer then return false end
	if targetPlayer == player then return false end
	if Config.TriggerbotTeamCheck and targetPlayer.Team == player.Team then return false end

	local char = targetPlayer.Character
	if not char then return false end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end

	return true
end

local function simulateClick()
	local success = pcall(function()
		VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
		task.wait(0.01)
		VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
	end)

	if not success then
		pcall(function()
			if mouse1click then
				mouse1click()
			end
		end)
	end
end

local function startTriggerbot()
	if triggerbotConn then return end

	triggerbotConn = RunService.RenderStepped:Connect(function()
		if not Config.TriggerbotEnabled then return end

		local currentTime = tick()
		if currentTime - lastTriggerTime < Config.TriggerbotDelay then return end

		local targetPlayer = getTargetFromMouse()

		if isEnemyTarget(targetPlayer) then
			lastTriggerTime = currentTime
			simulateClick()
		end
	end)
end

local function stopTriggerbot()
	if triggerbotConn then triggerbotConn:Disconnect(); triggerbotConn = nil end
end

-- ══════════════════════════════════════════════════════════════
--  🏃  SPEED  LOGIC
-- ══════════════════════════════════════════════════════════════
local speedConn
local originalWalkSpeed = 16
local originalJumpPower = 50

local function applySpeed()
	local hum = getHumanoid()
	if hum then
		hum.WalkSpeed = Config.WalkSpeed
		hum.JumpPower = Config.JumpPower
	end
end

local function resetSpeed()
	local hum = getHumanoid()
	if hum then
		hum.WalkSpeed = originalWalkSpeed
		hum.JumpPower = originalJumpPower
	end
end

local function startSpeedLoop()
	if speedConn then return end
	speedConn = RunService.Heartbeat:Connect(function()
		if Config.SpeedEnabled then
			applySpeed()
		end
	end)
end

local function stopSpeedLoop()
	if speedConn then speedConn:Disconnect(); speedConn = nil end
	resetSpeed()
end

player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid", 5)
	if hum then
		originalWalkSpeed = hum.WalkSpeed
		originalJumpPower = hum.JumpPower
		if Config.SpeedEnabled then
			applySpeed()
		end
	end
end)

-- ══════════════════════════════════════════════════════════════
--  📦  HITBOX EXPANDER  LOGIC
-- ══════════════════════════════════════════════════════════════
local hitboxConn
local originalHitboxSizes = {}

local function expandHitboxes()
	for _, p in ipairs(Players:GetPlayers()) do
		if p == player then continue end
		if Config.HitboxTeamCheck and p.Team == player.Team then continue end

		local char = p.Character
		if not char then continue end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			if not originalHitboxSizes[p] then
				originalHitboxSizes[p] = hrp.Size
			end

			hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
			hrp.Transparency = Config.HitboxVisible and 0.5 or 1
			hrp.CanCollide = false
			hrp.Material = Enum.Material.Neon
			hrp.BrickColor = BrickColor.new("Really red")
		end
	end
end

local function resetHitboxes()
	for p, originalSize in pairs(originalHitboxSizes) do
		if p and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Size = originalSize
				hrp.Transparency = 1
				hrp.CanCollide = false
			end
		end
	end
	originalHitboxSizes = {}
end

local function startHitboxLoop()
	if hitboxConn then return end
	hitboxConn = RunService.Heartbeat:Connect(function()
		if Config.HitboxEnabled then
			expandHitboxes()
		end
	end)
end

local function stopHitboxLoop()
	if hitboxConn then hitboxConn:Disconnect(); hitboxConn = nil end
	resetHitboxes()
end

Players.PlayerRemoving:Connect(function(p)
	originalHitboxSizes[p] = nil
end)

-- ══════════════════════════════════════════════════════════════
--  GLOBAL KEYBINDS
-- ══════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.KeyCode == Enum.KeyCode.F then
		if not Config.FlyMasterEnabled then return end
		if flying then
			disableFlight()
		else
			enableFlight()
		end
		return
	end

	if input.KeyCode == Enum.KeyCode.N then
		if not Config.NoclipMasterEnabled then return end
		if noclipActive then
			disableNoclip()
		else
			enableNoclip()
		end
		Rayfield:Notify({
			Title   = "Noclip",
			Content = noclipActive and "Noclip ON" or "Noclip OFF",
			Duration= 2,
		})
		return
	end

	if input.KeyCode == Config.AimbotKeybind then
		if not Config.AimbotMasterEnabled then return end
		if Config.AimbotActive then
			Config.AimbotActive = false
			destroyFOVCircle()
		else
			Config.AimbotActive = true
			createFOVCircle(); startAimbot(); updateFOVCircle()
		end
		Rayfield:Notify({
			Title   = "Aimbot",
			Content = Config.AimbotActive and "Aimbot Active ✅" or "Aimbot Paused ⏸",
			Duration= 2,
		})
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		if not Config.AimbotMasterEnabled then return end
		if Config.AimbotActive then return end
		rmbAimActive        = true
		Config.AimbotActive = true
		createFOVCircle(); startAimbot(); updateFOVCircle()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and rmbAimActive then
		rmbAimActive        = false
		Config.AimbotActive = false
		destroyFOVCircle()
	end
end)

-- ══════════════════════════════════════════════════════════════
--  UI ─ ✈  FLY & NOCLIP TAB
-- ══════════════════════════════════════════════════════════════
local FlyTab = Window:CreateTab("✈  Movement", 4483362458)

FlyTab:CreateSection("✈  Flight")

FlyTab:CreateToggle({
	Name = "Enable Fly Feature  [then press F to fly]",
	CurrentValue = false, Flag = "FlyMaster",
	Callback = function(v)
		Config.FlyMasterEnabled = v
		if not v and flying then disableFlight() end
	end,
})

FlyTab:CreateSlider({ Name="Fly Speed", Range={1,300}, Increment=1, Suffix=" studs/s",
	CurrentValue=Config.FlySpeed, Flag="FlySpeed",
	Callback=function(v) Config.FlySpeed=v end })

FlyTab:CreateSlider({ Name="Shift Boost", Range={1,10}, Increment=0.5, Suffix="×",
	CurrentValue=Config.Boost, Flag="BoostMult",
	Callback=function(v) Config.Boost=v end })

FlyTab:CreateSlider({ Name="Acceleration", Range={1,30}, Increment=1,
	CurrentValue=Config.Acceleration, Flag="FlyAccel",
	Callback=function(v) Config.Acceleration=v end })

FlyTab:CreateSection("👻  Noclip")

FlyTab:CreateParagraph({ Title="How to use",
	Content="1. Toggle 'Enable Noclip Feature' ON.\n"
		.."2. Press N to activate/deactivate noclip.\n"
		.."N does nothing until the feature is enabled here." })

FlyTab:CreateToggle({
	Name = "Enable Noclip Feature  [then press N]",
	CurrentValue = false, Flag = "NoclipMaster",
	Callback = function(v)
		Config.NoclipMasterEnabled = v
		if not v and noclipActive then disableNoclip() end
	end,
})

FlyTab:CreateSection("🛡  Anti-Kick Bypass")

FlyTab:CreateParagraph({ Title="How it works",
	Content="Every ~0.8 s your server-side velocity is briefly zeroed then restored. "
		.."Prevents the server flagging impossible speeds. Enable when flying fast." })

FlyTab:CreateToggle({ Name="Enable Bypass", CurrentValue=false, Flag="BypassToggle",
	Callback=function(v)
		Config.BypassEnabled = v
		if v then startBypass() else stopBypass() end
	end })

FlyTab:CreateSlider({ Name="Max Safe Speed (cap when bypass off)",
	Range={10,300}, Increment=5, Suffix=" studs/s", CurrentValue=150, Flag="SafeSpeed",
	Callback=function(v)
		if not Config.BypassEnabled then Config.FlySpeed = math.min(Config.FlySpeed, v) end
	end })

FlyTab:CreateButton({ Name="Ping – Teleport to Self",
	Callback=function()
		local hrp = getHRP()
		if hrp then
			hrp.CFrame = hrp.CFrame
			Rayfield:Notify({Title="Bypass", Content="Position pulse sent.", Duration=3})
		end
	end })

-- ══════════════════════════════════════════════════════════════
--  UI ─ 🏃  SPEED TAB
-- ══════════════════════════════════════════════════════════════
local SpeedTab = Window:CreateTab("🏃  Speed", 4483362458)

SpeedTab:CreateSection("Speed Control")

SpeedTab:CreateToggle({
	Name = "Enable Speed Modifier",
	CurrentValue = false,
	Flag = "SpeedEnabled",
	Callback = function(v)
		Config.SpeedEnabled = v
		if v then
			startSpeedLoop()
			Rayfield:Notify({Title="Speed", Content="Speed modifier enabled!", Duration=2})
		else
			stopSpeedLoop()
			Rayfield:Notify({Title="Speed", Content="Speed reset to default!", Duration=2})
		end
	end,
})

SpeedTab:CreateSlider({
	Name = "Walk Speed",
	Range = {1, 500},
	Increment = 1,
	Suffix = " studs/s",
	CurrentValue = 16,
	Flag = "WalkSpeed",
	Callback = function(v)
		Config.WalkSpeed = v
		if Config.SpeedEnabled then applySpeed() end
	end,
})

SpeedTab:CreateSlider({
	Name = "Jump Power",
	Range = {1, 500},
	Increment = 1,
	Suffix = " power",
	CurrentValue = 50,
	Flag = "JumpPower",
	Callback = function(v)
		Config.JumpPower = v
		if Config.SpeedEnabled then applySpeed() end
	end,
})

SpeedTab:CreateDropdown({
	Name = "Speed Presets",
	Options = {"Normal (16)", "Fast (50)", "Very Fast (100)", "Super Speed (200)", "Insane (500)"},
	CurrentOption = {"Normal (16)"},
	MultipleOptions = false,
	Flag = "SpeedPreset",
	Callback = function(Option)
		local preset = Option[1]
		if preset == "Normal (16)" then
			Config.WalkSpeed = 16
			Config.JumpPower = 50
		elseif preset == "Fast (50)" then
			Config.WalkSpeed = 50
			Config.JumpPower = 75
		elseif preset == "Very Fast (100)" then
			Config.WalkSpeed = 100
			Config.JumpPower = 100
		elseif preset == "Super Speed (200)" then
			Config.WalkSpeed = 200
			Config.JumpPower = 150
		elseif preset == "Insane (500)" then
			Config.WalkSpeed = 500
			Config.JumpPower = 250
		end
		if Config.SpeedEnabled then applySpeed() end
		Rayfield:Notify({Title="Speed Preset", Content="Applied: " .. preset, Duration=2})
	end,
})

SpeedTab:CreateSection("Info")

SpeedTab:CreateParagraph({
	Title = "Notes",
	Content = "• Speed modifier changes your walk speed and jump power.\n"
		.. "• Some games may detect speed modifications.\n"
		.. "• Use with caution in competitive games."
})

-- ══════════════════════════════════════════════════════════════
--  UI ─ 🎯  AIMBOT TAB  (with Silent Aim + Triggerbot)
-- ══════════════════════════════════════════════════════════════
local AimbotTab = Window:CreateTab("🎯  Aimbot", 4483362458)

-- ── Regular Aimbot Section ────────────────────────────────────
AimbotTab:CreateSection("🎯  Aimbot (Camera Lock)")

AimbotTab:CreateToggle({
	Name = "Enable Aimbot Feature",
	CurrentValue = false, Flag = "AimbotMaster",
	Callback = function(v)
		Config.AimbotMasterEnabled = v
		if v then
			createFOVCircle(); startAimbot(); updateFOVCircle()
		else
			stopAimbot()
			rmbAimActive = false
		end
	end,
})

AimbotTab:CreateKeybind({
	Name          = "Aimbot Toggle Key  (default Q)",
	CurrentKeybind= "Q",
	HoldToInteract= false,
	Flag          = "AimbotKey",
	Callback      = function(key)
		local ok, code = pcall(function() return Enum.KeyCode[key] end)
		if ok and code then Config.AimbotKeybind = code end
	end,
})

AimbotTab:CreateDropdown({
	Name = "Target Body Part",
	Options = { "Head","HumanoidRootPart","UpperTorso","LowerTorso","Torso" },
	CurrentOption = {"Head"}, Flag = "AimbotPart", MultipleOptions = false,
	Callback = function(v) Config.AimbotPart = type(v)=="table" and v[1] or v end,
})

AimbotTab:CreateToggle({ Name="Team Check (skip teammates)", CurrentValue=false, Flag="AimbotTeam",
	Callback=function(v) Config.AimbotTeamCheck=v end })

AimbotTab:CreateToggle({ Name="Visible Players Only", CurrentValue=true, Flag="AimbotVis",
	Callback=function(v) Config.AimbotVisible=v end })

AimbotTab:CreateSlider({ Name="FOV Radius", Range={20,600}, Increment=5, Suffix=" px",
	CurrentValue=Config.AimbotFOV, Flag="AimbotFOV",
	Callback=function(v) Config.AimbotFOV=v; updateFOVCircle() end })

AimbotTab:CreateSlider({ Name="Smoothness  (1=slow · 100=snap)", Range={1,100}, Increment=1,
	CurrentValue=15, Flag="AimbotSmooth",
	Callback=function(v) Config.AimbotSmooth=v/100 end })

AimbotTab:CreateToggle({ Name="Show FOV Circle (Red)", CurrentValue=true, Flag="AimbotFOVShow",
	Callback=function(v) Config.AimbotShowFOV=v; updateFOVCircle() end })

-- ── Silent Aim Section ────────────────────────────────────────
AimbotTab:CreateSection("🔇  Silent Aim (No Camera Movement)")

AimbotTab:CreateToggle({
	Name = "Enable Silent Aim",
	CurrentValue = false,
	Flag = "SilentAimEnabled",
	Callback = function(v)
		Config.SilentAimEnabled = v
		if v then
			startSilentAim()
			Rayfield:Notify({
				Title = "Silent Aim",
				Content = "Silent Aim ON - Bullets redirect to enemies!",
				Duration = 3
			})
		else
			stopSilentAim()
			Rayfield:Notify({
				Title = "Silent Aim",
				Content = "Silent Aim OFF",
				Duration = 2
			})
		end
	end,
})

AimbotTab:CreateDropdown({
	Name = "Target Part",
	Options = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso" },
	CurrentOption = {"Head"},
	MultipleOptions = false,
	Flag = "SilentAimPart",
	Callback = function(v)
		Config.SilentAimPart = type(v)=="table" and v[1] or v
	end,
})

AimbotTab:CreateSlider({
	Name = "Silent FOV Radius",
	Range = {50, 800},
	Increment = 10,
	Suffix = " px",
	CurrentValue = 150,
	Flag = "SilentAimFOV",
	Callback = function(v)
		Config.SilentAimFOV = v
		updateSilentFOVCircle()
	end,
})

AimbotTab:CreateSlider({
	Name = "Prediction (for moving targets)",
	Range = {0, 50},
	Increment = 1,
	Suffix = " %",
	CurrentValue = 10,
	Flag = "SilentAimPrediction",
	Callback = function(v)
		Config.SilentAimPrediction = v / 100
	end,
})

AimbotTab:CreateToggle({
	Name = "Team Check (skip teammates)",
	CurrentValue = false,
	Flag = "SilentAimTeamCheck",
	Callback = function(v)
		Config.SilentAimTeamCheck = v
	end,
})

AimbotTab:CreateToggle({
	Name = "Visible Players Only",
	CurrentValue = true,
	Flag = "SilentAimVisible",
	Callback = function(v)
		Config.SilentAimVisible = v
	end,
})

AimbotTab:CreateToggle({
	Name = "Show Silent FOV Circle (Green)",
	CurrentValue = true,
	Flag = "SilentAimShowFOV",
	Callback = function(v)
		Config.SilentAimShowFOV = v
		updateSilentFOVCircle()
	end,
})

AimbotTab:CreateParagraph({
	Title = "How Silent Aim Works",
	Content = "• Redirects bullets to enemies WITHOUT moving camera\n"
		.. "• Hooks raycast functions used by guns\n"
		.. "• Green FOV = silent aim range\n"
		.. "• Prediction helps hit moving targets\n"
		.. "• Requires executor with hookmetamethod\n"
		.. "• If not working, use Hitbox Expander instead"
})

-- ── Triggerbot Section ────────────────────────────────────────
AimbotTab:CreateSection("🔫  Triggerbot (Auto-Fire)")

AimbotTab:CreateToggle({
	Name = "Enable Triggerbot",
	CurrentValue = false,
	Flag = "TriggerbotEnabled",
	Callback = function(v)
		Config.TriggerbotEnabled = v
		if v then
			startTriggerbot()
			Rayfield:Notify({Title="Triggerbot", Content="Auto-fire when aiming at enemies!", Duration=3})
		else
			stopTriggerbot()
			Rayfield:Notify({Title="Triggerbot", Content="Triggerbot OFF", Duration=2})
		end
	end,
})

AimbotTab:CreateSlider({
	Name = "Trigger Delay",
	Range = {0, 500},
	Increment = 10,
	Suffix = " ms",
	CurrentValue = 100,
	Flag = "TriggerbotDelay",
	Callback = function(v)
		Config.TriggerbotDelay = v / 1000
	end,
})

AimbotTab:CreateToggle({
	Name = "Team Check (skip teammates)",
	CurrentValue = false,
	Flag = "TriggerbotTeamCheck",
	Callback = function(v)
		Config.TriggerbotTeamCheck = v
	end,
})

-- ══════════════════════════════════════════════════════════════
--  UI ─ 👁  VISUALS TAB  (ESP + Hitbox)
-- ══════════════════════════════════════════════════════════════
local VisualsTab = Window:CreateTab("👁  Visuals", 4483362458)

VisualsTab:CreateSection("👁  ESP")

VisualsTab:CreateToggle({
	Name = "Enable ESP",
	CurrentValue = false, Flag = "ESPMaster",
	Callback = function(v)
		Config.ESPMasterEnabled = v
		if v then
			startESP()
			Rayfield:Notify({Title="ESP", Content="ESP enabled!", Duration=2})
		else
			stopESP()
			Rayfield:Notify({Title="ESP", Content="ESP disabled!", Duration=2})
		end
	end,
})

VisualsTab:CreateToggle({ Name="Show Name", CurrentValue=true, Flag="ESPName",
	Callback=function(v) Config.ESPShowName=v end })

VisualsTab:CreateToggle({ Name="Show Health (label + bar)", CurrentValue=true, Flag="ESPHealth",
	Callback=function(v) Config.ESPShowHealth=v end })

VisualsTab:CreateToggle({ Name="Show Distance", CurrentValue=true, Flag="ESPDist",
	Callback=function(v) Config.ESPShowDistance=v end })

VisualsTab:CreateToggle({ Name="Team Check (skip teammates)", CurrentValue=false, Flag="ESPTeam",
	Callback=function(v) Config.ESPTeamCheck=v end })

VisualsTab:CreateSlider({ Name="Max ESP Distance", Range={50,2000}, Increment=50, Suffix=" studs",
	CurrentValue=Config.ESPMaxDist, Flag="ESPRange",
	Callback=function(v) Config.ESPMaxDist=v end })

VisualsTab:CreateSection("📦  Hitbox Expander")

VisualsTab:CreateToggle({
	Name = "Enable Hitbox Expander",
	CurrentValue = false,
	Flag = "HitboxEnabled",
	Callback = function(v)
		Config.HitboxEnabled = v
		if v then
			startHitboxLoop()
			Rayfield:Notify({Title="Hitbox", Content="Hitbox expander enabled!", Duration=2})
		else
			stopHitboxLoop()
			Rayfield:Notify({Title="Hitbox", Content="Hitboxes reset to normal!", Duration=2})
		end
	end,
})

VisualsTab:CreateSlider({
	Name = "Hitbox Size",
	Range = {1, 50},
	Increment = 1,
	Suffix = " studs",
	CurrentValue = 5,
	Flag = "HitboxSize",
	Callback = function(v)
		Config.HitboxSize = v
	end,
})

VisualsTab:CreateToggle({
	Name = "Show Hitboxes (Visible)",
	CurrentValue = false,
	Flag = "HitboxVisible",
	Callback = function(v)
		Config.HitboxVisible = v
		if Config.HitboxEnabled then
			expandHitboxes()
		end
	end,
})

VisualsTab:CreateToggle({
	Name = "Team Check (Skip Teammates)",
	CurrentValue = false,
	Flag = "HitboxTeamCheck",
	Callback = function(v)
		Config.HitboxTeamCheck = v
	end,
})

VisualsTab:CreateDropdown({
	Name = "Hitbox Presets",
	Options = {"Small (3)", "Medium (5)", "Large (10)", "Huge (20)", "Massive (35)", "Maximum (50)"},
	CurrentOption = {"Medium (5)"},
	MultipleOptions = false,
	Flag = "HitboxPreset",
	Callback = function(Option)
		local preset = Option[1]
		if preset == "Small (3)" then
			Config.HitboxSize = 3
		elseif preset == "Medium (5)" then
			Config.HitboxSize = 5
		elseif preset == "Large (10)" then
			Config.HitboxSize = 10
		elseif preset == "Huge (20)" then
			Config.HitboxSize = 20
		elseif preset == "Massive (35)" then
			Config.HitboxSize = 35
		elseif preset == "Maximum (50)" then
			Config.HitboxSize = 50
		end
		Rayfield:Notify({Title="Hitbox Preset", Content="Applied: " .. preset, Duration=2})
	end,
})

VisualsTab:CreateParagraph({
	Title = "Hitbox Info",
	Content = "• Makes enemy hitboxes larger (client-side)\n"
		.. "• Works on ALL games reliably\n"
		.. "• Best alternative if Silent Aim doesn't work\n"
		.. "• Combine with aimbot for easy hits"
})

-- ══════════════════════════════════════════════════════════════
--  UI ─ 🔧  TOOLS TAB
-- ══════════════════════════════════════════════════════════════
local ToolsTab = Window:CreateTab("🔧  Tools", 4483362458)

ToolsTab:CreateSection("Infinite Yield")

ToolsTab:CreateParagraph({ Title="About Infinite Yield",
	Content="Feature-rich admin/exploit console with hundreds of commands "
		.."(:fly :noclip :speed :god :tp :bring :view etc.)." })

local iyLoaded = false

ToolsTab:CreateButton({ Name="Load Infinite Yield",
	Callback=function()
		if iyLoaded then
			Rayfield:Notify({Title="Inf Yield",Content="Already loaded!",Duration=3}); return
		end
		local ok, err = pcall(function()
			loadstring(game:HttpGet(
				"https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
		end)
		if ok then
			iyLoaded = true
			Rayfield:Notify({Title="Infinite Yield",Content="Loaded! Type ; in chat.",Duration=5})
		else
			Rayfield:Notify({Title="IY Error",Content=tostring(err),Duration=6})
		end
	end })

ToolsTab:CreateSection("Eject")

ToolsTab:CreateButton({ Name="⏏  Eject Script",
	Callback=function()
		if flying       then disableFlight()  end
		if noclipActive then disableNoclip()  end
		if Config.AimbotMasterEnabled then stopAimbot() end
		if Config.ESPMasterEnabled    then stopESP()    end
		if Config.SpeedEnabled        then stopSpeedLoop() end
		if Config.HitboxEnabled       then stopHitboxLoop() end
		if Config.TriggerbotEnabled   then stopTriggerbot() end
		if Config.SilentAimEnabled    then stopSilentAim() end
		stopBypass()

		Rayfield:Destroy()
		warn("[Multi-Tool] Ejected!")
	end
})

ToolsTab:CreateSection("IY Command Reference")

ToolsTab:CreateParagraph({ Title="Useful Commands",
	Content=":speed [n]      — walkspeed\n"
		..":jump [n]       — jump power\n"
		..":god            — god mode\n"
		..":invisible      — go invisible\n"
		..":tp [player]    — teleport to player\n"
		..":bring [player] — bring player to you\n"
		..":view [player]  — spectate player\n"
		..":noclip         — noclip toggle\n"
		..":fly            — IY fly mode" })

-- ══════════════════════════════════════════════════════════════
--  Done
-- ══════════════════════════════════════════════════════════════
Rayfield:Notify({
	Title    = "Multi-Tool Ready",
	Content  = "All features OFF by default. Enable each in its tab first.",
	Duration = 6,
})
