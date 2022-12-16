--- local cache of spawns
---@type { [string]: SpawnCacheEntry }
local spawnCache = {}

---@alias spawnCacheSource 'none' | 'dannet' | 'netbots'

---@class SpawnCacheEntry # Keeps cached information about a spawn
---@field Source spawnCacheSource # Where to get cache data
---@field DannetObservers string[] # if dannet, check which observers are set
---@field IsPoisoned boolean # Is spawn poisoned

---Fetch or generate a cache for a spawn being tracked
---@param name string
---@returns spawnEntry SpawnCacheEntry # Spawn Cache Entry
function SpawnCache(name)    
    local spawnEntry = spawnCache[name]
    spawnEntry.LastRequest = mq.gettime()
    if spawnEntry then return spawnEntry end

    spawnEntry = {
        IsPoisoned = false,
        LastRefresh = mq.gettime(),
        LastRequest = mq.gettime(),
    }
    SetSpawnCache(name, spawnEntry)
    return spawnEntry
end

---Set a spawn cache entry
---@param name string
---@param spawnEntry SpawnCacheEntry # Spawn Cache Data
function SetSpawnCache(name, spawnEntry)
    spawnCache[name] = spawnEntry
end