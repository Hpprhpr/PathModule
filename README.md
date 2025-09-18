# PathModule for Roblox

Robust and easy-to-use pathfinding modules for Roblox characters and objects, inspired by SimplePath + NoobPath.

---

## Versions

### 1. Humanoid Version

Works with any `Humanoid` character (`Player.Character` or NPCs).

**Features:**
- Automatic walking to a target
- Jumping over obstacles
- Dynamic path recalculation if blocked or trapped
- Partial path support
- Waypoint variation
- Timeout per waypoint
- Stop function
- Event system: `OnReached`, `OnWaypointReached`, `OnBlocked`, `OnTrapped`, `OnStopped`

**Usage Example:**
```lua
local PathModule = require(game.ReplicatedStorage.PathModule)
local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()

-- Register events
PathModule.OnReached(char, function(c, partial)
    print(c.Name .. " reached destination" .. (partial and " (partial)" or ""))
end)

-- Walk to target
PathModule.WalkTo(char, Vector3.new(50,0,50))

-- Stop after 3 seconds
task.delay(3, function()
    PathModule.Stop(char)
end)
