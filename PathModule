-- v 1.0.0
-- Inspired by SimplePath + NoobPath
-- Made by @drassiles

local PathModule = {}
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

-- Default agent settings
local agentParams = {
	AgentRadius = 2,
	AgentHeight = 5,
	AgentCanJump = true,
	AgentJumpHeight = 7,
	AgentMaxSlope = 45,
}

-- State control
local activeWalks = {}
local callbacks = {
	Reached = {},
	WaypointReached = {},
	Blocked = {},
	Stopped = {},
	Trapped = {},
}

-- Internal function to calculate path
local function computePath(startPos, targetPos)
	local path = PathfindingService:CreatePath(agentParams)
	path:ComputeAsync(startPos, targetPos)
	if path.Status == Enum.PathStatus.Success then
		return path, false
	elseif path.Status == Enum.PathStatus.ClosestNoPath then
		return path, true -- partial
	end
	return nil, false
end

-- Filters redundant waypoints
local function filterWaypoints(waypoints)
	local filtered = {}
	local lastPos
	for _, wp in ipairs(waypoints) do
		if not lastPos or (wp.Position - lastPos).Magnitude > 2 then
			table.insert(filtered, wp)
			lastPos = wp.Position
		end
	end
	return filtered
end

-- Walk to a point
function PathModule.WalkTo(character, targetPosition)
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return end

	-- Interrupts if there is already another path
	PathModule.Stop(character)
	activeWalks[character] = true

	local path, isPartial = computePath(rootPart.Position, targetPosition)
	if not path then
		if callbacks.Blocked[character] then callbacks.Blocked[character](character) end
		return
	end

	local waypoints = filterWaypoints(path:GetWaypoints())

	-- Variation
	for i, wp in ipairs(waypoints) do
		local offset = Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
		waypoints[i] = {
			Position = wp.Position + offset,
			Action = wp.Action,
		}
	end

	-- Follow the waypoints
	for i, waypoint in ipairs(waypoints) do
		if not activeWalks[character] then break end

		if waypoint.Action == Enum.PathWaypointAction.Jump then
			humanoid.Jump = true
		end

		humanoid:MoveTo(waypoint.Position)
		if callbacks.WaypointReached[character] then
			callbacks.WaypointReached[character](character, i, #waypoints)
		end

		-- Timeout
		local startTime = tick()
		local reached = false
		local conn
		conn = humanoid.MoveToFinished:Connect(function(success)
			reached = success
		end)

		while tick() - startTime < 5 do -- 5s timeout
			RunService.Heartbeat:Wait()
			if reached then break end
		end
		conn:Disconnect()

		if not reached then
			if callbacks.Trapped[character] then
				callbacks.Trapped[character](character)
			end
			-- try to recalculate
			return PathModule.WalkTo(character, targetPosition)
		end

		-- Last waypoint
		if i == #waypoints and activeWalks[character] then
			activeWalks[character] = nil
			if callbacks.Reached[character] then
				callbacks.Reached[character](character, isPartial)
			end
		end
	end
end

-- Stop movement
function PathModule.Stop(character)
	if activeWalks[character] then
		activeWalks[character] = nil
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid and character:FindFirstChild("HumanoidRootPart") then
			humanoid:MoveTo(character.HumanoidRootPart.Position)
		end
		if callbacks.Stopped[character] then
			callbacks.Stopped[character](character)
		end
	end
end

-- Register callbacks
function PathModule.OnReached(character, fn) callbacks.Reached[character] = fn end
function PathModule.OnWaypointReached(character, fn) callbacks.WaypointReached[character] = fn end
function PathModule.OnBlocked(character, fn) callbacks.Blocked[character] = fn end
function PathModule.OnStopped(character, fn) callbacks.Stopped[character] = fn end
function PathModule.OnTrapped(character, fn) callbacks.Trapped[character] = fn end

return PathModule
