local G = (getgenv and getgenv()) or _G
if G.MeciHubMultiLoaded and not G.MeciHubMultiForceReload then
  warn("[Meci Hub] Multi hub already loaded. Use getgenv().MeciHubMultiForceReload = true to reload.")
  return
end
G.MeciHubMultiForceReload = false
G.MeciHubMultiLoaded = true

local Registry = {
  [90296841634441] = {
    Name = "Fish For Sea Animals",
    Url = "https://raw.githubusercontent.com/artemizagomes26-eng/MeciHub/refs/heads/main/FSA.lua",
  },
  [82505988558777] = {
    Name = "Shoot to Steal an Egg",
    Url = "https://raw.githubusercontent.com/artemizagomes26-eng/MeciHub/refs/heads/main/ShootStealEgg.lua",
  },
  [110432290690507] = {
    Name = "Hike For Eggs",
    Url = "https://raw.githubusercontent.com/artemizagomes26-eng/MeciHub/refs/heads/main/HikeForEggs.lua",
  },
}

G.MeciHubMultiModules = Registry

function G.MeciHubRegisterGame(placeId, name, url)
  Registry[tonumber(placeId)] = {Name = tostring(name), Url = tostring(url)}
end

local function fetch(url)
  if type(game.HttpGet) == "function" then
    return game:HttpGet(url)
  end
  return game:HttpGetAsync(url)
end

local function findByName()
  local wanted = string.lower(game.Name or "")
  if wanted == "" then return nil end
  for _, entry in pairs(Registry) do
    if string.lower(entry.Name) == wanted or string.find(wanted, string.lower(entry.Name), 1, true) then
      return entry
    end
  end
  return nil
end

local placeId = game.PlaceId
local module = Registry[placeId] or findByName()

if not module then
  local list = {}
  for id, entry in pairs(Registry) do
    list[#list + 1] = id .. " = " .. entry.Name
  end
  warn("[Meci Hub] No module for PlaceId " .. tostring(placeId) .. " (" .. tostring(game.Name) .. ")")
  print("[Meci Hub] Registered games: " .. table.concat(list, " | "))
  return
end

local okSource, source = pcall(fetch, module.Url)
if not okSource or type(source) ~= "string" or source == "" then
  warn("[Meci Hub] Failed to fetch " .. module.Name .. ": " .. tostring(source))
  return
end

local okRun, err = pcall(function()
  loadstring(source)()
end)

if not okRun then
  warn("[Meci Hub] Failed to run " .. module.Name .. ": " .. tostring(err))
  return
end

G.MeciHubMultiGame = module.Name
print("[Meci Hub] Loaded " .. module.Name .. " for PlaceId " .. tostring(placeId))
