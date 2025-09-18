-- PathModule v1.0.1
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
		return path, true -- partial path
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

-- Walk to a point (Non-Humanoid)
-- moveFunc: function(targetVector3) called every step to move the object
-- jumpFunc: optional function() called if the waypoint requires jump
function PathModule.WalkTo(object, targetPosition, moveFunc, jumpFunc)
	if not object or not moveFunc then return end

	PathModule.Stop(object)
	activeWalks[object] = true

	local startPos = object.Position or object:GetPivot().Position
	local path, isPartial = computePath(startPos, targetPosition)
	if not path then
		if callbacks.Blocked[object] then callbacks.Blocked[object](object) end
		return
	end

	local waypoints = filterWaypoints(path:GetWaypoints())

	-- Waypoint variation
	for i, wp in ipairs(waypoints) do
		local offset = Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
		waypoints[i] = { Position = wp.Position + offset, Action = wp.Action }
	end

	for i, waypoint in ipairs(waypoints) do
		if not activeWalks[object] then break end

		if waypoint.Action == Enum.PathWaypointAction.Jump and jumpFunc then
			jumpFunc()
		end

		moveFunc(waypoint.Position)

		if callbacks.WaypointReached[object] then
			callbacks.WaypointReached[object](object, i, #waypoints)
		end

		-- Timeout handling
		local startTime = tick()
		local reached = false
		local conn
		conn = RunService.Heartbeat:Connect(function()
			local currentPos = object.Position or object:GetPivot().Position
			if (currentPos - waypoint.Position).Magnitude < 2 then
				reached = true
			end
		end)

		while tick() - startTime < 5 do
			RunService.Heartbeat:Wait()
			if reached then break end
		end
		conn:Disconnect()

		if not reached then
			if callbacks.Trapped[object] then callbacks.Trapped[object](object) end
			return PathModule.WalkTo(object, targetPosition, moveFunc, jumpFunc)
		end

		if i == #waypoints and activeWalks[object] then
			activeWalks[object] = nil
			if callbacks.Reached[object] then
				callbacks.Reached[object](object, isPartial)
			end
		end
	end
end

-- Stop movement
function PathModule.Stop(object)
	if activeWalks[object] then
		activeWalks[object] = nil
		if callbacks.Stopped[object] then
			callbacks.Stopped[object](object)
		end
	end
end

-- Register callbacks
function PathModule.OnReached(object, fn) callbacks.Reached[object] = fn end
function PathModule.OnWaypointReached(object, fn) callbacks.WaypointReached[object] = fn end
function PathModule.OnBlocked(object, fn) callbacks.Blocked[object] = fn end
function PathModule.OnStopped(object, fn) callbacks.Stopped[object] = fn end
function PathModule.OnTrapped(object, fn) callbacks.Trapped[object] = fn end

return PathModule

