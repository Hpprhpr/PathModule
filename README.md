# PathModule - Roblox Pathfinding Module

A robust and easy-to-use pathfinding module for Roblox characters, inspired by SimplePath and NoobPath.

## Features

- Walks characters to a target position automatically
- Handles jumping over obstacles
- Dynamic path recalculation if blocked or trapped
- Partial path support (goes to the closest reachable point if destination is unreachable)
- Waypoint variation to avoid repetitive paths
- Timeout for waypoints to prevent stuck characters
- Full event system:
  - `OnReached` - triggered when character reaches destination
  - `OnWaypointReached` - triggered at every waypoint
  - `OnBlocked` - triggered if path cannot be computed
  - `OnTrapped` - triggered if character gets stuck mid-path
  - `OnStopped` - triggered when movement is manually stopped
- Stop function to cancel movement at any time

## Installation

1. Place `PathModule` in `ReplicatedStorage`.
2. Require the module in a LocalScript or ServerScript:

```lua
local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()

-- Register events
PathModule.OnReached(character, function(c, partial)
    print(c.Name .. " reached destination" .. (partial and " (partial)" or ""))
end)

PathModule.OnWaypointReached(character, function(c, index, total)
    print(c.Name .. " reached waypoint " .. index .. "/" .. total)
end)

PathModule.OnBlocked(character, function(c)
    print(c.Name .. " cannot compute path")
end)

PathModule.OnTrapped(character, function(c)
    print(c.Name .. " is trapped, recalculating")
end)

PathModule.OnStopped(character, function(c)
    print(c.Name .. " stopped manually")
end)

-- Move character
PathModule.WalkTo(character, Vector3.new(50,0,50))

-- Stop movement after 3 seconds
task.delay(3, function()
    PathModule.Stop(character)
end)
