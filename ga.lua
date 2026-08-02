
-- Fall Harvest farm.lua — single max-Leaves config
-- Ladder: Maple Carrot/Bamboo → Maple Mushroom → Atlantic Giant Pumpkin (AG).
-- Regular Syrup Can/Sprinkler only in use. Super Syrup bought + mailed (never used). No LOW/50M/500M tiers.
do
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	if not player then
		player = Players.PlayerAdded:Wait()
	end

	local leaderstats
	repeat
		leaderstats = player:FindFirstChild("leaderstats")
		task.wait(0.2)
	until leaderstats

	-- Wait until currency exists (game ready). No Leaves-based tier pick.
	repeat
		task.wait(0.2)
	until leaderstats:FindFirstChild("Leaves") or leaderstats:FindFirstChild("Sheckles")

	-- Items To Mail.Gear = source of truth: never auto-use / equip mail-bound gears.
	local function filterGearsToUse(config)
		local mailGear = config["Items To Mail"] and config["Items To Mail"]["Gear"]
		local gears = config["Gears"]
		local toUse = gears and gears["Gears To Use"]
		if not mailGear or not toUse then
			return config
		end

		local filtered = {}
		for _, name in ipairs(toUse) do
			if not mailGear[name] then
				filtered[#filtered + 1] = name
			end
		end
		gears["Gears To Use"] = filtered
		return config
	end

	local MAIL_TO = {
		"Pix3lKZDrag0na42",
		"Pix3lat3dZZDrag0n0ZV",
		"Pix3lat3d9TS0nicK199",
		"Buildero1NinjaB",
		"BlizzardyYDawnd20013",
		"Pix3lat3dR6Chill16Kn",
		"Pix3lat3d4vW0lf2",
		"Ash3n7aFoxNaStar2006",
		"Pix3lat3dvFH3rowFSma",
		"Ac30jChillO46",
		"Pix3l5yRiftwyOblivio",
		"Pix3lLiFrostOiTurbo",
		"Pix3lHdRiftu199535",
		"Pix3lb7Scyth3J1994",
		"Pix3lat3d3NDuckBNQu3",
		"Pix3lnLB3astB",
		"Pix3lat3d3gEch0Blad3",
		"Pix3lat3dJcGalaxyj19",
		"Pix3lApLionF200429",
		"C3l3stialmOOblivi0n4",
		"AcerJSurgea1997",
		"Pix3lNCVip3rk199640",
		"Pix3laWDawnrWGiga200",
		"Pix3ln1Ward3nv1Craft",
		"BaneEbSparklyz1995",
		"Blizzard13Furyx20021",
	}

	local function mailPet(keep)
		local t = {}
		for k, v in pairs(keep) do
			t[k] = v
		end
		t.To = MAIL_TO
		return t
	end

	local function applyConfig(fpsCap, note, config)
		pcall(function()
			local userSettings = UserSettings():GetService("UserGameSettings")
			userSettings.SavedQualityLevel = 1
			userSettings.MasterVolume = 0
		end)

		if typeof(setfpscap) == "function" then
			setfpscap(fpsCap)
		elseif typeof(set_fps_cap) == "function" then
			set_fps_cap(fpsCap)
		end

		local env = (getgenv and getgenv()) or _G
		env.LOADED_CONFIG = 1
		env.UserConfig = config
		env.FH_NOTE = note
		-- farm continues in this file
	end

	----------------------------------------------------------------------------------------------------------------------------------------------------------
	-- BASE — single max-Leaves config (cash ladder → AG; regular Syrup use only; Super mailed)
	----------------------------------------------------------------------------------------------------------------------------------------------------------
	local BASE = {
		["FPS Cap"] = 12,
		["World"] = "Fall Harvest",

		-- FPS / map opt (MM2-style, farm-safe) — inlined Opt module + README
		["EnableFPSOpt"] = true,
		["ClearMap"] = true,
		["ClearOtherGardens"] = true,
		["HideOtherPlayers"] = true,
		["MuteSounds"] = true,

		["Auto Double Or Nothing"] = false,
		["Double Or Nothing Target Wins"] = 1,
		["Auto Add Friends"] = false,

		["Auto Buy Seed"] = true,
		["Auto Plant Seed"] = true,
		["Auto Plant"] = true,
		["Limit Auto Plant"] = 777,
		["Auto Sell"] = true,

		-- SellFruitMultiplier = SellFlags.GlobalMultiplier (Game.Sell.GlobalMultiplier)
		["Wait SellFruitMultiplier"] = true,
		["Sell Multiplier Min"] = 1.01,
		["Sell Multiplier Wait"] = 60,
		["Sell Force When Full"] = 35,
		-- Per-fruit hold until max(GlobalMultiplier, PriceMultipliers[fruit]) >= need.
		-- "Mushroom" also matches Fall Harvest "Maple Mushroom" via SeedData.ReskinOf.
		-- Uses SetFruitFavorite so SellAll never dumps held crops early; SellFruit as fallback.
		["Sell Fruit Multiplier"] = {
			["Mushroom"] = 2,
			["Maple Mushroom"] = 2,
			["Atlantic Giant Pumpkin"] = 2,
		},
		-- Max seconds to hold listed fruits before force-sell (broke / softlock). Default 5m.
		["Sell Multiplier Max Wait"] = 300,
		-- Leaves at/below this → skip multi wait, sell immediately, block unaffordable buys
		["Sell Force When Broke"] = 1000,
		-- Platform under feet prevents void; rescue TP only if Y falls catastrophically below this
		["Void Rescue Y"] = -100,
		["Anti Void Platform"] = true,
		-- XZ studs (square). Also used as minimum when sizing from Map/seed/wildpet AABB + margin.
		["Anti Void Size"] = 2000,

		["Shop Restock Wait"] = true,
		["Shop Restock Wait Seconds"] = 25,
		["Anti Stuck"] = true,
		["Anti Stuck Seconds"] = 45,
		["Gear Cooldown"] = 8,
		-- Only water/sprinkle plants still growing (Age < MaxAge / growing fruits); skip harvest-ready.
		["Gear Only Growing"] = true,
		-- Prefer expensive seeds (SeedData PurchasePrice) when aiming can / placing sprinkler.
		["Gear Prefer Expensive"] = true,
		["Loop Wait"] = 1.1,
		["Shovel Dead Plants"] = true,

		["Limit Plant Seed"] = {},
		-- ~1.9 studs: BotScore tradeoff for single money config (1.8–2.0 band).
		["Plant Spacing"] = 1.9,
		-- "spiral" = expand outward from area center; "grid" = rectangular lattice sorted by distance.
		["Plant Cluster Mode"] = "spiral",
		["Plant Burst"] = 40,

		-- Favorite empty = cash rush (favorited fruit cannot sell)
		["Favorite"] = {},
		-- HMO empty = harvest all (AG is MutationImmune; HMO would stall cash)
		["Harvest Mutation Only"] = {},

		-- Cash ladder + AG. Late shop (Venus/Pomegranate/Poison/Venom/Conifer/Cherry/Sunflower) blacklisted.
		-- Amber Cranberry: buy+mail only (plant skipped via Items To Mail.Seed).
		["Limit Buy Seed"] = {
			["Maple Carrot"] = 20,
			["Maple Tulip"] = 40,
			["Maple Bamboo"] = 300,
			["Maple Corn"] = 50,
			["Maple Cactus"] = 40,
			["Maple Pineapple"] = 30,
			["Maple Banana"] = 30,
			["Maple Mushroom"] = 200,
			["Atlantic Giant Pumpkin"] = 999,
			["Amber Cranberry"] = 50,
		},

		-- Lean farm pets only. No Wolf/Fox (money sinks). Shadow Dragon when affordable.
		["Buy Pets"] = {
			["Squirrel"] = { Normal = 6, Big = 99, Huge = 99, Rainbow = 99 },
			["Swan"] = { Normal = 6, Big = 6, Huge = 99, Rainbow = 99 },
			["Shadow Dragon"] = 999,
		},

		["Equip Pets"] = {
			{ "Squirrel", 6, 1 },
			{ "Swan", 6, 2 },
		},

		-- note: Normal = N → GIU N, ban phan du
		["Sell Pets"] = {
			["Dog"] = { Normal = 2 },
			["Hedgehog"] = { Normal = 2 },
			["Turkey"] = { Normal = 2 },
		},

		["Gears"] = {
			["Buy Gear"] = {
				["Syrup Watering Can"] = 50,
				["Syrup Sprinkler"] = 50,
				["Super Syrup Watering Can"] = 999,
				["Super Syrup Sprinkler"] = 999,
				["Harp"] = 30,
				["Legendary Magic Mail"] = 100,
				["Super Magic Mail"] = 100,
			},
			["Gears To Use"] = {
				"Syrup Watering Can",
				"Syrup Sprinkler",
			},
		},

		["Blacklist Shovel"] = {
			"Maple Mushroom",
			"Maple Bamboo",
			"Atlantic Giant Pumpkin",
			"Maple Corn",
			"Maple Cactus",
			"Maple Pineapple",
			"Romanesco",
		},
		["Shovel Plant Once"] = {},

		-- Late trash + junk: never plant (owned leftovers). Buy path is Limit Buy Seed only.
		["Blacklist Seed"] = {
			"Ghost Pepper",
			"Potato",
			"Maple Green Bean",
			"Maple Venus Fly Trap",
			"Maple Pomegranate",
			"Maple Poison Apple",
			"Maple Venom Spitter",
			"Maple Sunflower",
			"Maple Cherry",
			"Conifer Cone",
			"Maple Dragon Fruit",
			"Amber Cranberry",
		},

		["Items To Mail"] = {
			["Pet"] = {
				["Shadow Dragon"] = mailPet({ Normal = 1, Big = 1, Huge = 1, Rainbow = 1 }),
				["Bear"] = mailPet({ Big = 1, Huge = 1, Rainbow = 1 }),
				["Bald Eagle"] = mailPet({ Big = 1, Huge = 1, Rainbow = 1 }),
				["Turtle"] = mailPet({ Big = 1, Huge = 1, Rainbow = 1 }),
				["Bunny"] = mailPet({ Big = 1, Huge = 1 }),
				["Swan"] = mailPet({ Big = 1, Huge = 1 }),
				["Turkey"] = mailPet({ Big = 1, Huge = 1 }),
				["Hedgehog"] = mailPet({ Normal = 2, Big = 1, Huge = 1, Rainbow = 1 }),
				["Dog"] = mailPet({ Huge = 1 }),
				["Squirrel"] = mailPet({ Normal = 1, Big = 1, Huge = 1, Rainbow = 1 }),
				["Wolf"] = mailPet({ Normal = 1, Big = 1, Huge = 1, Rainbow = 1 }),
				["Fox"] = mailPet({ Normal = 1, Big = 1, Huge = 1, Rainbow = 1 }),
			},
			["Seed"] = {
				["Mega"] = { Amount = 5, To = MAIL_TO },
				["Amber Cranberry"] = { Amount = 1, To = MAIL_TO },
			},
			-- Super Syrup mailed (MAIL_TO) — filterGearsToUse + useGears skip mail-bound gears.
			["Gear"] = {
				["Super Syrup Watering Can"] = { Amount = 1, To = MAIL_TO },
				["Super Syrup Sprinkler"] = { Amount = 1, To = MAIL_TO },
				["Super Magic Mail"] = { Amount = 1, To = MAIL_TO },
				["Legendary Magic Mail"] = { Amount = 1, To = MAIL_TO },
			},
		},

		["Expand Plot"] = true,
		["Plot Expansions"] = 3,
		["Unlock Pet Slots"] = 6,
		["Auto Collect Seed Packs"] = true,

		["Webhook Pet URL"] = "https://discord.com/api/webhooks/1528055380297650326/EO-0l39j1yvu7uDJFmG9FNDBs-2us4ZAw9mb9BKyiiKe7mhpYmYzIXPZPVJlGAbC8Y_h",
		["Webhook Pet Name"] = { "Shadow Dragon" },
		["Webhook Pet Rarity"] = { "Super", "Secret" },
		["Webhook Seed Name"] = { "Amber Cranberry" },
		["Webhook Seed URL"] = "https://discord.com/api/webhooks/1528055299808956456/vs8rtiLgE98iNTAx69aSudkdMnkagTKlu_TY9h87I-YRpA6rnlEbvhw6N_KC_ejZ-8TV",
		["Webhook Gear URL"] = "",
		["Webhook Gear Name"] = {},
		["Webhook Note"] = "shuys",
		["Discord ID"] = "601249077975580673",

		["Claim Mail"] = true,
		["Mail To Username"] = MAIL_TO,
	}

	----------------------------------------------------------------------------------------------------------------------------------------------------------
	local CONFIG = filterGearsToUse(BASE)
	local env = (getgenv and getgenv()) or _G
	env.LOADED_CONFIG = 1
	applyConfig(12, "LEAVES", CONFIG)
end

----------------------------------------------------------------
-- Sell module (inlined from sell.lua)
-- Studio: SellFlags.GlobalMultiplier / PriceMultipliers / Apply(name, base)
-- Hold path: SetFruitFavorite so SellAll skips held; SellFruit(Id) selective fallback.
----------------------------------------------------------------
local Sell = {}

local function safe(fn)
	return pcall(fn)
end

local function log(...)
	warn("[FH-Sell]", ...)
end

local function cfg(config, key, default)
	local v = config[key]
	if v == nil then
		return default
	end
	return v
end

function Sell.ResolveFlags()
	local ok, flags = pcall(function()
		return require(game:GetService("ReplicatedStorage").SharedModules.Flags.SellFlags)
	end)
	if ok and type(flags) == "table" then
		return flags
	end
	return nil
end

local function readFlagNumber(flagObj, default)
	if not flagObj then
		return default
	end
	local ok, v = pcall(function()
		return flagObj:Get()
	end)
	if ok and typeof(v) == "number" and v > 0 then
		return v
	end
	ok, v = pcall(function()
		return flagObj.Value
	end)
	if ok and typeof(v) == "number" and v > 0 then
		return v
	end
	return default
end

function Sell.GetGlobalMultiplier(flags)
	flags = flags or Sell.ResolveFlags()
	if not flags then
		return 1
	end
	return readFlagNumber(flags.GlobalMultiplier, 1)
end

function Sell.GetPriceMultipliers(flags)
	flags = flags or Sell.ResolveFlags()
	if not flags or not flags.PriceMultipliers then
		return {}
	end
	local ok, v = pcall(function()
		return flags.PriceMultipliers:Get()
	end)
	if ok and type(v) == "table" then
		return v
	end
	ok, v = pcall(function()
		return flags.PriceMultipliers.Value
	end)
	if ok and type(v) == "table" then
		return v
	end
	return {}
end

function Sell.GetFruitPriceMultiplier(flags, fruitName)
	-- Exact FruitName only. Do NOT inherit ReskinOf base (Mushroom=0.5 tax does not apply to Maple Mushroom).
	if type(fruitName) ~= "string" or fruitName == "" then
		return 1
	end
	local map = Sell.GetPriceMultipliers(flags)
	local v = map[fruitName]
	if typeof(v) == "number" and v > 0 then
		return v
	end
	return 1
end

-- Gate multi for hold config: max(GlobalMultiplier, PriceMultipliers[fruit]).
-- Not Apply() product — static PriceMultiplier taxes are not the timed event multi.
function Sell.GetFruitGateMulti(flags, fruitName)
	local g = Sell.GetGlobalMultiplier(flags)
	local pm = Sell.GetFruitPriceMultiplier(flags, fruitName)
	return math.max(g, pm), g, pm
end

local _reskinOfCache = nil
function Sell.GetReskinOf(fruitName)
	if type(fruitName) ~= "string" then
		return nil
	end
	if _reskinOfCache == nil then
		_reskinOfCache = {}
		local ok, data = pcall(function()
			return require(game:GetService("ReplicatedStorage").SharedModules.SeedData)
		end)
		if ok and type(data) == "table" then
			for _, row in ipairs(data) do
				if type(row) == "table" and type(row.SeedName) == "string" and type(row.ReskinOf) == "string" then
					_reskinOfCache[row.SeedName] = row.ReskinOf
				end
			end
		end
	end
	return _reskinOfCache[fruitName]
end

function Sell.GetHoldMap(config)
	local map = cfg(config, "Sell Fruit Multiplier", nil)
	if type(map) ~= "table" then
		return nil
	end
	local out = nil
	for name, need in pairs(map) do
		if type(name) == "string" and typeof(need) == "number" and need > 1 then
			out = out or {}
			out[name] = need
		end
	end
	return out
end

-- Hold need for fruit: exact name, or ReskinOf base (Maple Mushroom ← Mushroom), or reverse.
function Sell.HoldNeedFor(holdMap, fruitName)
	if not holdMap or type(fruitName) ~= "string" then
		return nil
	end
	local need = holdMap[fruitName]
	if typeof(need) == "number" then
		return need
	end
	local base = Sell.GetReskinOf(fruitName)
	if base then
		need = holdMap[base]
		if typeof(need) == "number" then
			return need
		end
	end
	for key, n in pairs(holdMap) do
		if Sell.GetReskinOf(key) == fruitName and typeof(n) == "number" then
			return n
		end
	end
	return nil
end

function Sell.IsMultiActive(config, flags)
	local minM = cfg(config, "Sell Multiplier Min", 1.01)
	local m = Sell.GetGlobalMultiplier(flags)
	return m >= minM, m
end

function Sell.IsHarvestedFruitTool(t)
	if not t or not t:IsA("Tool") then
		return false
	end
	if t:GetAttribute("HarvestedFruit") == true then
		return true
	end
	local fruit = t:GetAttribute("FruitName") or t:GetAttribute("Fruit")
	if type(fruit) == "string" and fruit ~= "" and t:GetAttribute("SeedTool") == nil then
		return true
	end
	return false
end

function Sell.FruitToolName(t)
	local n = t:GetAttribute("FruitName") or t:GetAttribute("Fruit") or t:GetAttribute("Seed")
	if type(n) == "string" and n ~= "" then
		return n
	end
	return nil
end

function Sell.FruitToolId(t)
	local id = t:GetAttribute("Id") or t:GetAttribute("FruitUUID") or t:GetAttribute("FruitId")
	if id ~= nil then
		return tostring(id)
	end
	return nil
end

function Sell.IsPermanentFavorite(config, fruitName, mutation)
	local fav = config and config["Favorite"]
	if type(fav) ~= "table" or not fruitName then
		return false
	end
	for _, v in ipairs(fav) do
		if v == fruitName then
			return true
		end
	end
	if fav[fruitName] == true then
		return true
	end
	if type(fav[fruitName]) == "table" and mutation then
		for _, m in ipairs(fav[fruitName]) do
			if m == mutation then
				return true
			end
		end
	end
	return false
end

function Sell.CountSellableFruits(eachToolFn)
	local n = 0
	eachToolFn(function(t)
		if t:GetAttribute("IsFavorite") == true then
			return
		end
		if Sell.IsHarvestedFruitTool(t) then
			n += 1
		end
	end)
	return n
end

--[[
  Classify inventory fruits against Sell Fruit Multiplier.
  Returns buckets + per-name counts. Includes favorited multi-hold tools.
]]
function Sell.ClassifyFruits(eachToolFn, config, flags)
	local holdMap = Sell.GetHoldMap(config)
	local global = Sell.GetGlobalMultiplier(flags)
	local free, holding, ready = {}, {}, {}
	local holdCounts, readyCounts, freeCount = {}, {}, 0

	eachToolFn(function(t)
		if not Sell.IsHarvestedFruitTool(t) then
			return
		end
		local name = Sell.FruitToolName(t)
		if not name then
			return
		end
		if Sell.IsPermanentFavorite(config, name, t:GetAttribute("Mutation")) then
			return
		end
		local id = Sell.FruitToolId(t)
		local entry = { tool = t, name = name, id = id }
		local need = Sell.HoldNeedFor(holdMap, name)
		if need then
			local gate = Sell.GetFruitGateMulti(flags, name)
			entry.need = need
			entry.gate = gate
			if gate >= need then
				table.insert(ready, entry)
				readyCounts[name] = (readyCounts[name] or 0) + 1
			else
				table.insert(holding, entry)
				holdCounts[name] = (holdCounts[name] or 0) + 1
			end
		else
			-- permanent IsFavorite (user/UI) — skip from free sell pool
			if t:GetAttribute("IsFavorite") == true then
				return
			end
			table.insert(free, entry)
			freeCount += 1
		end
	end)

	return {
		free = free,
		holding = holding,
		ready = ready,
		freeCount = freeCount,
		holdCounts = holdCounts,
		readyCounts = readyCounts,
		global = global,
		holdMap = holdMap,
	}
end

function Sell.SetFruitFavorite(Networking, fruitId, want)
	if not fruitId or not Networking or not Networking.Backpack then
		return false
	end
	local ok = pcall(function()
		Networking.Backpack.SetFruitFavorite:Fire(tostring(fruitId), want == true)
	end)
	return ok
end

function Sell.SyncHoldFavorites(ctx, classified)
	ctx._multiHoldIds = ctx._multiHoldIds or {}
	local Networking = ctx.Networking
	local changed = 0

	for _, entry in ipairs(classified.holding) do
		if entry.id then
			if entry.tool:GetAttribute("IsFavorite") ~= true then
				if Sell.SetFruitFavorite(Networking, entry.id, true) then
					pcall(function()
						entry.tool:SetAttribute("IsFavorite", true)
					end)
					ctx._multiHoldIds[entry.id] = true
					changed += 1
				end
			else
				ctx._multiHoldIds[entry.id] = true
			end
		end
	end

	-- Unlock ready / free that we previously locked for multi-hold
	local unlock = {}
	for _, entry in ipairs(classified.ready) do
		if entry.id and ctx._multiHoldIds[entry.id] then
			table.insert(unlock, entry)
		end
	end
	for _, entry in ipairs(classified.free) do
		if entry.id and ctx._multiHoldIds[entry.id] then
			table.insert(unlock, entry)
		end
	end
	for _, entry in ipairs(unlock) do
		if entry.tool:GetAttribute("IsFavorite") == true or ctx._multiHoldIds[entry.id] then
			if Sell.SetFruitFavorite(Networking, entry.id, false) then
				pcall(function()
					entry.tool:SetAttribute("IsFavorite", nil)
				end)
				ctx._multiHoldIds[entry.id] = nil
				changed += 1
			end
		end
	end

	if changed > 0 then
		task.wait(0.12)
	end
	return changed
end

function Sell.WatchMultiplier(flags, onChange)
	flags = flags or Sell.ResolveFlags()
	if not flags or not flags.GlobalMultiplier then
		return function() end
	end
	local conns = {}
	local function connectFlag(flagObj)
		if not flagObj then
			return
		end
		local ok = pcall(function()
			local changed = flagObj.Changed
			if changed and typeof(changed.Connect) == "function" then
				table.insert(
					conns,
					changed:Connect(function(newV, prevV)
						onChange(newV, prevV)
					end)
				)
			end
		end)
		return ok
	end
	connectFlag(flags.GlobalMultiplier)
	connectFlag(flags.PriceMultipliers)
	return function()
		for _, conn in ipairs(conns) do
			safe(function()
				conn:Disconnect()
			end)
		end
	end
end

--[[
  Decide whether to sell free (non-hold) fruits now.
  Returns: shouldSell:boolean, reason:string, multi:number
  opts = { money?: number, forceBroke?: boolean }
]]
function Sell.ShouldSellNow(config, fruitCount, flags, waitStartedAt, opts)
	opts = opts or {}
	local multiActive, multi = Sell.IsMultiActive(config, flags)
	if fruitCount <= 0 then
		return false, "empty", multi
	end

	local waitEnabled = cfg(config, "Wait SellFruitMultiplier", cfg(config, "Wait Sell Multiplier", true))
	local forceFull = cfg(config, "Sell Force When Full", 35)
	local brokeThreshold = cfg(config, "Sell Force When Broke", 1000)
	local waitSec = cfg(config, "Sell Multiplier Wait", 60)
	local money = opts.money
	local broke = opts.forceBroke == true
		or (typeof(money) == "number" and money <= brokeThreshold)

	-- broke / near-0 Leaves: never wait on multi — cash out free fruit now
	if broke then
		return true, "broke_force", multi
	end

	if multiActive then
		return true, "multi_active", multi
	end

	if not waitEnabled then
		return true, "wait_disabled", multi
	end

	if fruitCount >= forceFull then
		return true, "inventory_full", multi
	end

	local started = waitStartedAt or tick()
	local elapsed = tick() - started
	if elapsed >= waitSec then
		return true, "wait_timeout", multi
	end

	return false, "waiting_multi", multi
end

function Sell.FireSellAll(Networking)
	local ok, res = pcall(function()
		return Networking.NPCS.SellAll:Fire()
	end)
	return ok, res
end

function Sell.FireSellFruit(Networking, fruitId)
	local ok, res = pcall(function()
		return Networking.NPCS.SellFruit:Fire(tostring(fruitId))
	end)
	return ok, res
end

function Sell.FirePreview(Networking)
	local ok, res = pcall(function()
		return Networking.NPCS.PreviewSellAll:Fire()
	end)
	if ok then
		return res
	end
	return nil
end

function Sell.SellEntriesSelective(Networking, entries)
	local sold = 0
	for _, entry in ipairs(entries) do
		if entry.id then
			local ok, res = Sell.FireSellFruit(Networking, entry.id)
			if ok and (res == nil or res == true or (type(res) == "table" and res.Success ~= false)) then
				sold += 1
			end
			task.wait(0.05)
		end
	end
	return sold
end

--[[
  Full sell routine: free fruits use existing multi-wait; held fruits wait for their gate.
  ctx = { Config, Networking, eachTool, busy, onLog, money/getMoney, forceBroke }
]]
function Sell.TrySellFruits(ctx)
	local config = ctx.Config
	if cfg(config, "Auto Sell", true) ~= true then
		return false, "autosell_off"
	end
	if ctx.busy and ctx.busy.selling then
		return false, "busy"
	end

	local flags = ctx.flags or Sell.ResolveFlags()
	local classified = Sell.ClassifyFruits(ctx.eachTool, config, flags)
	local global = classified.global
	local holdingN = #classified.holding
	local readyN = #classified.ready
	local freeN = classified.freeCount

	if freeN <= 0 and holdingN <= 0 and readyN <= 0 then
		ctx._waitMultiSince = nil
		ctx._holdWaitSince = nil
		return false, "empty"
	end

	if not ctx._waitMultiSince and freeN > 0 then
		ctx._waitMultiSince = tick()
	end
	if freeN <= 0 then
		ctx._waitMultiSince = nil
	end
	if holdingN > 0 and not ctx._holdWaitSince then
		ctx._holdWaitSince = tick()
	end
	if holdingN <= 0 then
		ctx._holdWaitSince = nil
	end

	-- Keep held fruits favorited so SellAll cannot dump them early
	Sell.SyncHoldFavorites(ctx, classified)

	local money = nil
	if typeof(ctx.money) == "number" then
		money = ctx.money
	elseif typeof(ctx.getMoney) == "function" then
		local okM, m = pcall(ctx.getMoney)
		if okM and typeof(m) == "number" then
			money = m
		end
	end

	local brokeThreshold = cfg(config, "Sell Force When Broke", 1000)
	local broke = ctx.forceBroke == true
		or (typeof(money) == "number" and money <= brokeThreshold)
	local maxHoldWait = cfg(config, "Sell Multiplier Max Wait", 300)
	local holdElapsed = ctx._holdWaitSince and (tick() - ctx._holdWaitSince) or 0
	local forceHeld = false
	if holdingN > 0 and holdElapsed >= maxHoldWait then
		-- Softlock / broke-only-held: dump after Max Wait
		if broke or freeN <= 0 then
			forceHeld = true
		end
	end

	-- Periodic hold log
	if holdingN > 0 and (not ctx._lastHoldLog or tick() - ctx._lastHoldLog > 15) then
		ctx._lastHoldLog = tick()
		for name, n in pairs(classified.holdCounts) do
			local need = Sell.HoldNeedFor(classified.holdMap, name) or 0
			local gate = Sell.GetFruitGateMulti(flags, name)
			log(
				string.format(
					"holding %d %s waiting multi=%.2fx need=%.2fx (global=%.2fx)%s",
					n,
					name:lower() .. (n == 1 and "" or "s"),
					gate,
					need,
					global,
					forceHeld and " FORCE_MAX_WAIT" or ""
				)
			)
		end
	end

	local function doSellAll(reason, sellReady)
		if ctx.busy then
			ctx.busy.selling = true
		end
		-- If forcing held, unlock them first
		if sellReady or forceHeld then
			for _, entry in ipairs(classified.holding) do
				if forceHeld and entry.id then
					Sell.SetFruitFavorite(ctx.Networking, entry.id, false)
					pcall(function()
						entry.tool:SetAttribute("IsFavorite", nil)
					end)
					if ctx._multiHoldIds then
						ctx._multiHoldIds[entry.id] = nil
					end
				end
			end
			for _, entry in ipairs(classified.ready) do
				if entry.id then
					Sell.SetFruitFavorite(ctx.Networking, entry.id, false)
					pcall(function()
						entry.tool:SetAttribute("IsFavorite", nil)
					end)
					if ctx._multiHoldIds then
						ctx._multiHoldIds[entry.id] = nil
					end
				end
			end
			task.wait(0.12)
		end

		local ok, res = Sell.FireSellAll(ctx.Networking)
		-- Fallback: selective SellFruit for ready/forced if SellAll fails
		if not ok and (readyN > 0 or forceHeld) then
			local batch = {}
			for _, e in ipairs(classified.ready) do
				table.insert(batch, e)
			end
			if forceHeld then
				for _, e in ipairs(classified.holding) do
					table.insert(batch, e)
				end
			end
			local sold = Sell.SellEntriesSelective(ctx.Networking, batch)
			ok = sold > 0
			res = sold
		end

		if ctx.busy then
			ctx.busy.selling = false
		end

		if readyN > 0 then
			for name, n in pairs(classified.readyCounts) do
				local gate = Sell.GetFruitGateMulti(flags, name)
				log(string.format("selling %s at multi=%.2fx (n=%d reason=%s)", name:lower() .. "s", gate, n, reason))
			end
		end

		local tag = string.format(
			"SellAll reason=%s multi=%.2fx free=%d ready=%d holding=%d money=%s ok=%s",
			reason,
			global,
			freeN,
			readyN,
			holdingN,
			tostring(money),
			tostring(ok)
		)
		if global > 1.01 or readyN > 0 then
			log("SELL WITH MULTI", tag)
		else
			log(tag)
		end
		if ctx.onLog then
			ctx.onLog(tag, global, reason)
		end
		if ctx.webhook and (global > 1.01 or readyN > 0) then
			ctx.webhook(
				string.format(
					"%s sold fruits with **SellFruitMultiplier x%.2f** (%s)",
					tostring(cfg(config, "Webhook Note", "FH")),
					global,
					reason
				)
			)
		end
		return ok, reason, res
	end

	-- 1) Held fruits whose gate multi is met → sell them (prefer multi window)
	if readyN > 0 then
		ctx._holdWaitSince = nil
		return doSellAll("fruit_multi_ready", true)
	end

	-- 2) Force held after Max Wait (broke with only held left, or softlock)
	if forceHeld then
		ctx._holdWaitSince = nil
		return doSellAll("multi_max_wait", true)
	end

	-- 3) Free fruits — existing wait / broke / full / timeout rules
	if freeN > 0 then
		local should, reason, multi = Sell.ShouldSellNow(config, freeN, flags, ctx._waitMultiSince, {
			money = money,
			forceBroke = broke,
		})
		if should then
			-- SellAll: held stay favorited and are skipped by game sell
			ctx._waitMultiSince = nil
			-- Prefer SellAll when holding (favorites protect). If no holding, SellAll dumps free.
			local ok, resReason, res = doSellAll(reason, false)
			return ok, resReason, res
		end
		if reason == "waiting_multi" and (not ctx._lastWaitLog or tick() - ctx._lastWaitLog > 15) then
			ctx._lastWaitLog = tick()
			local left = math.max(0, cfg(config, "Sell Multiplier Wait", 60) - (tick() - (ctx._waitMultiSince or tick())))
			log(
				string.format(
					"waiting SellFruitMultiplier (GlobalMultiplier=%.2fx) free=%d holding=%d money=%s timeout_in=%.0fs",
					multi,
					freeN,
					holdingN,
					tostring(money),
					left
				)
			)
		end
		if holdingN > 0 then
			return false, "holding_fruit_multi"
		end
		return false, reason
	end

	-- 4) Only holding — wait for multi
	if holdingN > 0 then
		return false, "holding_fruit_multi"
	end

	return false, "empty"
end



----------------------------------------------------------------
-- Opt module (kaitun-style FPS — Destroy map + strip 3D meshes, keep farm essentials)
----------------------------------------------------------------
local Opt
do
	local Players = game:GetService("Players")
	local Lighting = game:GetService("Lighting")
	local SoundService = game:GetService("SoundService")
	local MaterialService = game:GetService("MaterialService")

	Opt = {}

	-- Workspace roots that farming / remotes still need.
	-- SellAll / shops are remote-only → NPCS + Map.Stands / Middle are DELETED.
	-- SeedPackSpawnServerLocations kept for proximity claim (Gold/Rainbow/Mega/packs).
	-- WildPetRef/Spawns kept for WildPetTame(Instance).
	local KEEP_WORKSPACE = {
		Camera = true,
		CurrentCamera = true,
		Terrain = true,
		Gardens = true, -- own plot only kept below
		Map = true, -- pruned to KEEP_MAP_CHILDREN
		DroppedItems = true, -- prompt pickup (no tele)
		Handles = true, -- fruit/seed handle controller
		PlayerPetReferences = true, -- own pets; others stripped
		FH_AntiVoid = true, -- never Destroy; huge collide floor for seed/water TPs
		FH_Platform = true,
		-- Baseplate DESTROYED — own plot Visual + FH_AntiVoid are the floor
	}

	local KEEP_MAP_CHILDREN = {
		SeedPackSpawnServerLocations = true, -- NEVER Destroy folder; claim via proximity
		SeedPackSpawnClient = true, -- keep Folder; children wiped (visuals only)
		WildPetRef = true,
		WildPetSpawns = true,
	}

	-- Own-plot Visual names that are floor / PlantArea (collision). Everything else under Visual can die.
	local function isFloorPart(name)
		return name == "PRIM"
			or name == "GardenZonePart"
			or name == "GardenTotalArea"
			or name == "PlotSizeReferenceVisual"
			or name == "Move"
			or name:find("PlantArea", 1, true) ~= nil
			or name:find("Garden", 1, true) ~= nil
			or name:find("Bed", 1, true) ~= nil
	end

	local FX_CLASS = {
		ParticleEmitter = true,
		Trail = true,
		Beam = true,
		Smoke = true,
		Fire = true,
		Sparkles = true,
		Highlight = true,
	}

	local DESTROY_CLASS = {
		ParticleEmitter = true,
		Trail = true,
		Beam = true,
		Smoke = true,
		Fire = true,
		Sparkles = true,
		Highlight = true,
		PointLight = true,
		SpotLight = true,
		SurfaceLight = true,
		Explosion = true,
		BillboardGui = true,
		SurfaceGui = true,
		Accessory = true,
		Hat = true,
		Shirt = true,
		Pants = true,
		ShirtGraphic = true,
		CharacterMesh = true,
		BodyColors = true,
		Decal = true,
		Texture = true,
		Atmosphere = true,
		Sky = true,
		BloomEffect = true,
		ColorCorrectionEffect = true,
		DepthOfFieldEffect = true,
		SunRaysEffect = true,
		BlurEffect = true,
		ColorGradingEffect = true,
		Clouds = true,
		WrapLayer = true,
		WrapTarget = true,
		SurfaceAppearance = true,
		MaterialVariant = true,
	}

	local Stats = { destroyed = 0, stripped = 0 }

	local function safe(fn)
		return pcall(fn)
	end

	local function log(...)
		warn("[FH-Opt]", ...)
	end

	local function cfgBool(config, key, default)
		local v = config[key]
		if v == nil then
			return default
		end
		return v == true
	end

	local function getOwnPlotId(player)
		return player and player:GetAttribute("PlotId")
	end

	local function isOwnPlot(inst, plotId)
		if not plotId or not inst then
			return false
		end
		return inst.Name == ("Plot" .. tostring(plotId))
	end

	local function bumpDestroyed(n)
		n = n or 1
		Stats.destroyed += n
		return n
	end

	local function bumpStripped(n)
		n = n or 1
		Stats.stripped += n
		return n
	end

	local function destroyInst(inst)
		if not inst then
			return 0
		end
		local ok = pcall(function()
			inst:Destroy()
		end)
		if ok then
			return bumpDestroyed(1)
		end
		return 0
	end

	local function destroyChildren(folder)
		local n = 0
		if not folder then
			return 0
		end
		for _, child in ipairs(folder:GetChildren()) do
			n += destroyInst(child)
		end
		return n
	end

	-- Clear MeshId / TextureID so streamed 3D assets stop rendering; keep Part for collision if needed.
	local function clearMeshIds(inst)
		if not inst then
			return 0
		end
		local n = 0
		if inst:IsA("MeshPart") then
			local changed = false
			safe(function()
				if inst.MeshId ~= "" then
					inst.MeshId = ""
					changed = true
				end
			end)
			safe(function()
				if inst.TextureID ~= "" then
					inst.TextureID = ""
					changed = true
				end
			end)
			safe(function()
				inst.Material = Enum.Material.SmoothPlastic
				inst.Reflectance = 0
				inst.CastShadow = false
			end)
			if changed then
				n += bumpStripped(1)
			end
		elseif inst:IsA("SpecialMesh") or inst:IsA("FileMesh") then
			safe(function()
				if inst.MeshId ~= "" then
					inst.MeshId = ""
					n += bumpStripped(1)
				end
			end)
			safe(function()
				if inst.TextureId ~= "" then
					inst.TextureId = ""
				end
			end)
		end
		return n
	end

	local function neutralizePart(part, keepCollide)
		if not part or not part:IsA("BasePart") then
			return 0
		end
		local n = clearMeshIds(part)
		local keep = keepCollide == true
		safe(function()
			part.Material = Enum.Material.SmoothPlastic
		end)
		safe(function()
			part.Reflectance = 0
			part.CastShadow = false
		end)
		safe(function()
			part.Transparency = 1
			part.LocalTransparencyModifier = 1
		end)
		safe(function()
			part.CanCollide = keep
			part.CanQuery = keep
			part.CanTouch = false
		end)
		safe(function()
			part.AudioCanCollide = false
		end)
		for _, c in ipairs(part:GetChildren()) do
			if c:IsA("SpecialMesh") or c:IsA("FileMesh") then
				n += clearMeshIds(c)
				destroyInst(c)
			elseif c:IsA("Decal") or c:IsA("Texture") then
				destroyInst(c)
			end
		end
		return n
	end

	-- Destroy FX / clothing / decals / lights; clear meshes on remaining BaseParts.
	local function stripVisualTree(root, opts)
		opts = opts or {}
		if not root then
			return 0, 0
		end
		local beforeD, beforeS = Stats.destroyed, Stats.stripped
		local budget = opts.budget
		local keepCollideFn = opts.keepCollideFn -- function(part) -> bool
		local skipFn = opts.skipFn -- function(inst) -> bool (do not destroy/strip)
		local destroyMeshParts = opts.destroyMeshParts == true
		local list = root:GetDescendants()
		-- reverse so children die before parents when destroying
		for i = #list, 1, -1 do
			local d = list[i]
			if not d.Parent then
				continue
			end
			if skipFn and skipFn(d) then
				continue
			end
			local cls = d.ClassName
			if DESTROY_CLASS[cls] or FX_CLASS[cls] then
				destroyInst(d)
			elseif d:IsA("Sound") then
				destroyInst(d)
			elseif d:IsA("SpecialMesh") or d:IsA("FileMesh") then
				clearMeshIds(d)
				destroyInst(d)
			elseif d:IsA("MeshPart") then
				if destroyMeshParts and not (keepCollideFn and keepCollideFn(d)) then
					destroyInst(d)
				else
					local keep = keepCollideFn and keepCollideFn(d)
					neutralizePart(d, keep)
				end
			elseif d:IsA("BasePart") then
				local keep = keepCollideFn and keepCollideFn(d)
				if keep then
					neutralizePart(d, true)
				else
					-- non-floor parts: invisible, no collide, mesh cleared
					neutralizePart(d, false)
				end
			end
			if budget and (Stats.destroyed - beforeD + Stats.stripped - beforeS) >= budget then
				break
			end
		end
		return Stats.destroyed - beforeD, Stats.stripped - beforeS
	end

	local function stripFxAndLights(root, budget)
		local n = 0
		if not root then
			return 0
		end
		for _, d in ipairs(root:GetDescendants()) do
			if DESTROY_CLASS[d.ClassName] or FX_CLASS[d.ClassName] or d:IsA("Sound") then
				n += destroyInst(d)
				if budget and n >= budget then
					return n
				end
			end
		end
		return n
	end

	-- Harvest uses plant attrs + Fruits/*.FruitId; occupancy uses Base.Position.
	-- Destroy cosmetic numbered Parts / Decals; keep Base + Fruits models.
	local function stripOwnPlant(plant)
		if not plant or not plant:IsA("Model") then
			return
		end
		for _, child in ipairs(plant:GetChildren()) do
			if child.Name == "Base" and child:IsA("BasePart") then
				neutralizePart(child, false)
			elseif child.Name == "Fruits" then
				for _, fruit in ipairs(child:GetChildren()) do
					-- keep fruit Instance (attrs); nuke visual descendants
					for _, d in ipairs(fruit:GetChildren()) do
						if d.Name == "Base" and d:IsA("BasePart") then
							neutralizePart(d, false)
						elseif d:IsA("ProximityPrompt") then
							-- harvest uses attrs / tags; prompt optional — destroy for FPS
							destroyInst(d)
						else
							destroyInst(d)
						end
					end
					-- any leftover descendants (nested)
					stripVisualTree(fruit, {
						keepCollideFn = function(p)
							return p.Name == "Base"
						end,
						destroyMeshParts = true,
					})
					-- re-neutralize Base if strip destroyed nothing essential
					local base = fruit:FindFirstChild("Base")
					if base and base:IsA("BasePart") then
						neutralizePart(base, false)
					end
				end
			elseif child.Name == "FruitSpawnLocations" then
				stripVisualTree(child, { destroyMeshParts = true })
			else
				-- stem / leaf visual Parts (named "1","2",…) — not needed client-side
				destroyInst(child)
			end
		end
	end

	local function stripOwnPlot(plot)
		if not plot then
			return 0, 0
		end
		local beforeD, beforeS = Stats.destroyed, Stats.stripped
		for _, junkName in ipairs({ "LoadingCam", "LoadingScreenCam", "Signs" }) do
			local junk = plot:FindFirstChild(junkName)
			if junk then
				destroyInst(junk)
			end
		end

		local visual = plot:FindFirstChild("Visual")
		if visual then
			for _, child in ipairs(visual:GetChildren()) do
				local name = child.Name
				if name:find("Fence", 1, true) or name == "FencePole" or name == "FenceConnectors" then
					destroyInst(child)
				elseif child:IsA("BasePart") and isFloorPart(name) then
					neutralizePart(child, true)
					child.CanCollide = true
				elseif child:IsA("Model") and (name:find("Bed", 1, true) or name:find("Garden", 1, true)) then
					-- keep bed collision parts, strip meshes/decals inside
					stripVisualTree(child, {
						keepCollideFn = function(p)
							return isFloorPart(p.Name) or p.Name == "Part" or p.Name == "BottomFace"
						end,
					})
					for _, p in ipairs(child:GetDescendants()) do
						if p:IsA("BasePart") then
							neutralizePart(p, true)
							p.CanCollide = true
						end
					end
				else
					-- unknown visual clutter
					if child:IsA("BasePart") and isFloorPart(name) then
						neutralizePart(child, true)
					else
						destroyInst(child)
					end
				end
			end
		end

		local plants = plot:FindFirstChild("Plants")
		if plants then
			for _, plant in ipairs(plants:GetChildren()) do
				stripOwnPlant(plant)
			end
		end

		local spr = plot:FindFirstChild("Sprinklers")
		if spr then
			-- keep sprinkler instances for position queries; strip meshes/FX
			stripVisualTree(spr, {
				keepCollideFn = function()
					return false
				end,
				destroyMeshParts = false,
			})
		end

		local spawn = plot:FindFirstChild("SpawnPoint")
		if spawn and spawn:IsA("BasePart") then
			neutralizePart(spawn, false)
		end
		local psr = plot:FindFirstChild("PlotSizeReference")
		if psr and psr:IsA("BasePart") then
			neutralizePart(psr, false)
		end

		stripFxAndLights(plot, 800)
		return Stats.destroyed - beforeD, Stats.stripped - beforeS
	end

	-- World Gold/Rainbow claim is server proximity/touch on these Parts.
	-- Keep CanTouch+CanQuery; never Destroy the folder or its spawn Parts.
	local function prepareSeedSpawnPart(part)
		if not part or not part:IsA("BasePart") then
			return
		end
		neutralizePart(part, false)
		safe(function()
			part.CanTouch = true
			part.CanQuery = true
			part.CanCollide = false
			part.Transparency = 1
		end)
	end

	local function stripSeedPackFolder(folder)
		if not folder then
			return
		end
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("BasePart") then
				prepareSeedSpawnPart(child)
			else
				stripVisualTree(child, { destroyMeshParts = true })
				for _, d in ipairs(child:GetDescendants()) do
					if d:IsA("BasePart") then
						prepareSeedSpawnPart(d)
					end
				end
			end
		end
		stripFxAndLights(folder, 400)
	end

	function Opt.ApplyRendering(config)
		if not cfgBool(config, "EnableFPSOpt", true) then
			return
		end
		safe(function()
			local ugs = UserSettings():GetService("UserGameSettings")
			ugs.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
			ugs.MasterVolume = 0
		end)
		safe(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)
		safe(function()
			local ren = settings().Rendering
			if ren.MeshPartDetailLevel ~= nil then
				ren.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
			end
			pcall(function()
				ren.EditQualityLevel = Enum.QualityLevel.Level01
			end)
			pcall(function()
				ren.EagerBulkExecution = false
			end)
		end)
		safe(function()
			Lighting.GlobalShadows = false
			Lighting.Brightness = 0
			Lighting.FogEnd = 0
			Lighting.FogStart = 0
			Lighting.FogColor = Color3.new(0, 0, 0)
			Lighting.EnvironmentDiffuseScale = 0
			Lighting.EnvironmentSpecularScale = 0
			Lighting.ClockTime = 12
			Lighting.GeographicLatitude = 0
			pcall(function()
				Lighting.Ambient = Color3.new(0, 0, 0)
				Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
				Lighting.ShadowSoftness = 0
				Lighting.ExposureCompensation = -2
			end)
			for _, child in ipairs(Lighting:GetChildren()) do
				destroyInst(child)
			end
		end)
		safe(function()
			local terrain = workspace:FindFirstChildOfClass("Terrain")
			if terrain then
				terrain.Decoration = false
				terrain.WaterWaveSize = 0
				terrain.WaterWaveSpeed = 0
				terrain.WaterReflectance = 0
				terrain.WaterTransparency = 1
				pcall(function()
					terrain.WaterColor = Color3.new(0, 0, 0)
				end)
			end
		end)
		safe(function()
			if MaterialService then
				MaterialService.Use2022Materials = false
			end
		end)
		safe(function()
			-- client may not write Streaming*; best-effort shrink
			pcall(function()
				workspace.StreamingMinRadius = 64
				workspace.StreamingTargetRadius = 64
			end)
		end)
		local cap = config["FPS Cap"]
		if typeof(cap) == "number" then
			if typeof(setfpscap) == "function" then
				setfpscap(cap)
			elseif typeof(set_fps_cap) == "function" then
				set_fps_cap(cap)
			end
		end
	end

	function Opt.MuteSounds(config)
		if not (cfgBool(config, "EnableFPSOpt", true) and cfgBool(config, "MuteSounds", true)) then
			return 0
		end
		safe(function()
			SoundService.AmbientReverb = Enum.ReverbType.NoReverb
			SoundService.RespectFilteringEnabled = true
			SoundService.Volume = 0
		end)
		local n = 0
		for _, root in ipairs({ SoundService, workspace }) do
			safe(function()
				for _, s in ipairs(root:GetDescendants()) do
					if s:IsA("Sound") then
						n += destroyInst(s)
					end
				end
			end)
		end
		return n
	end

	-- Destroy almost every Workspace child not on KEEP_WORKSPACE.
	function Opt.ClearWorkspaceJunk(config)
		if not (cfgBool(config, "EnableFPSOpt", true) and cfgBool(config, "ClearMap", true)) then
			return 0
		end
		local n = 0
		local localChar = Players.LocalPlayer and Players.LocalPlayer.Character
		for _, child in ipairs(workspace:GetChildren()) do
			if child == localChar then
				continue
			end
			if KEEP_WORKSPACE[child.Name] then
				continue
			end
			if child:IsA("Terrain") or child:IsA("Camera") then
				continue
			end
			-- players' characters: handled by HideOtherPlayers (never Destroy → locked parent)
			if child:IsA("Model") and Players:GetPlayerFromCharacter(child) then
				continue
			end
			n += destroyInst(child)
		end
		-- strip kept utility folders (DroppedItems / Handles meshes)
		for _, name in ipairs({ "DroppedItems", "Handles", "PlayerPetReferences" }) do
			local folder = workspace:FindFirstChild(name)
			if folder then
				stripVisualTree(folder, {
					skipFn = function(d)
						return d:IsA("ProximityPrompt")
					end,
					destroyMeshParts = false,
				})
			end
		end
		return n
	end

	-- Map: keep only seed-server + wild-pet folders; wipe client visuals; Destroy Middle/Stands/etc.
	function Opt.ClearMapJunk(config)
		if not (cfgBool(config, "EnableFPSOpt", true) and cfgBool(config, "ClearMap", true)) then
			return 0
		end
		local map = workspace:FindFirstChild("Map")
		if not map then
			return 0
		end
		local n = 0
		for _, child in ipairs(map:GetChildren()) do
			if KEEP_MAP_CHILDREN[child.Name] then
				if child.Name == "SeedPackSpawnClient" then
					n += destroyChildren(child)
				elseif child.Name == "WildPetRef" or child.Name == "WildPetSpawns" then
					stripVisualTree(child, { destroyMeshParts = false, budget = 800 })
					n += stripFxAndLights(child, 600)
				elseif child.Name == "SeedPackSpawnServerLocations" then
					stripSeedPackFolder(child)
				end
			else
				n += destroyInst(child)
			end
		end
		return n
	end

	function Opt.ClearOtherGardens(config, localPlayer)
		if not (cfgBool(config, "EnableFPSOpt", true) and cfgBool(config, "ClearOtherGardens", true)) then
			return 0
		end
		local gardens = workspace:FindFirstChild("Gardens")
		if not gardens then
			return 0
		end
		local plotId = getOwnPlotId(localPlayer)
		if plotId == nil then
			log("ClearOtherGardens skipped — PlotId unset")
			return 0
		end
		local n = 0
		for _, plot in ipairs(gardens:GetChildren()) do
			if plot:IsA("Folder") or plot:IsA("Model") then
				if isOwnPlot(plot, plotId) then
					local d0 = Stats.destroyed
					stripOwnPlot(plot)
					n += (Stats.destroyed - d0)
					continue
				end
				-- foreign plot: Destroy entire model
				n += destroyInst(plot)
			end
		end
		return n
	end

	function Opt.HideOtherPlayers(config, localPlayer)
		if not (cfgBool(config, "EnableFPSOpt", true) and cfgBool(config, "HideOtherPlayers", true)) then
			return 0
		end
		-- Never Destroy other characters — locked-parent errors from handle reparent.
		local n = 0
		local function hideModel(model)
			if not model then
				return
			end
			safe(function()
				for _, d in ipairs(model:GetDescendants()) do
					if DESTROY_CLASS[d.ClassName] or FX_CLASS[d.ClassName] then
						destroyInst(d)
					elseif d:IsA("SpecialMesh") or d:IsA("FileMesh") then
						clearMeshIds(d)
						destroyInst(d)
					elseif d:IsA("MeshPart") or d:IsA("BasePart") then
						clearMeshIds(d)
						d.LocalTransparencyModifier = 1
						d.Transparency = 1
						d.CanCollide = false
						d.CanQuery = false
						d.CastShadow = false
						bumpStripped(1)
					end
				end
				local hum = model:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				end
			end)
			n += 1
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= localPlayer then
				hideModel(plr.Character)
				local refs = workspace:FindFirstChild("PlayerPetReferences")
				if refs then
					local theirs = refs:FindFirstChild(tostring(plr.UserId)) or refs:FindFirstChild(plr.Name)
					if theirs then
						n += destroyInst(theirs)
					end
				end
			end
		end
		local petVis = workspace:FindFirstChild("_PetVisualClient")
		if petVis then
			n += destroyInst(petVis)
		end
		return n
	end

	-- Continuous stripper for newly streamed meshes / FX under kept roots.
	local function shouldProtectInstance(inst, localPlayer)
		if not inst then
			return true
		end
		if inst:IsA("Terrain") or inst:IsA("Camera") then
			return true
		end
		if localPlayer and (inst == localPlayer.Character or inst:IsDescendantOf(localPlayer.Character)) then
			-- strip FX on own char, but never Destroy HRP/Humanoid
			if inst.Name == "HumanoidRootPart" or inst:IsA("Humanoid") then
				return true
			end
			return false -- allow FX/accessory strip
		end
		local plotId = getOwnPlotId(localPlayer)
		local gardens = workspace:FindFirstChild("Gardens")
		if gardens and plotId then
			local own = gardens:FindFirstChild("Plot" .. tostring(plotId))
			if own and inst:IsDescendantOf(own) then
				-- protect plant identity + floor parts
				if inst:IsA("Model") and inst.Parent and inst.Parent.Name == "Plants" then
					return true
				end
				if inst.Name == "Fruits" or (inst.Parent and inst.Parent.Name == "Fruits") then
					return true
				end
				if inst.Name == "Base" then
					return true
				end
				if inst:IsA("BasePart") and isFloorPart(inst.Name) then
					return true
				end
				if inst.Name == "Plants" or inst.Name == "Sprinklers" or inst.Name == "Visual" or inst.Name == "SpawnPoint" then
					return true
				end
			end
		end
		if KEEP_WORKSPACE[inst.Name] or KEEP_MAP_CHILDREN[inst.Name] then
			return true
		end
		return false
	end

	local function stripIncomingInstance(inst, localPlayer)
		if not inst or not inst.Parent then
			return
		end
		if DESTROY_CLASS[inst.ClassName] or FX_CLASS[inst.ClassName] or inst:IsA("Sound") then
			-- never strip from protected floor? FX on floor can go
			destroyInst(inst)
			return
		end
		if inst:IsA("SpecialMesh") or inst:IsA("FileMesh") then
			clearMeshIds(inst)
			destroyInst(inst)
			return
		end
		if inst:IsA("MeshPart") then
			local protect = shouldProtectInstance(inst, localPlayer)
			if protect and inst:IsA("BasePart") and isFloorPart(inst.Name) then
				neutralizePart(inst, true)
				inst.CanCollide = true
			elseif protect and inst.Name == "Base" then
				neutralizePart(inst, false)
			else
				-- under own plant non-Base mesh → destroy; else clear
				local inPlants = false
				local p = inst.Parent
				while p and p ~= workspace do
					if p.Name == "Plants" then
						inPlants = true
						break
					end
					p = p.Parent
				end
				if inPlants and inst.Name ~= "Base" then
					destroyInst(inst)
				else
					neutralizePart(inst, isFloorPart(inst.Name))
				end
			end
			return
		end
		-- new plant model under own Plants → strip cosmetics
		if inst:IsA("Model") and inst.Parent and inst.Parent.Name == "Plants" then
			task.defer(function()
				if inst.Parent then
					stripOwnPlant(inst)
				end
			end)
		end
	end

	function Opt.WatchIncoming(config, localPlayer)
		if not cfgBool(config, "EnableFPSOpt", true) then
			return function() end
		end
		local conns = {}

		if cfgBool(config, "ClearMap", true) then
			table.insert(
				conns,
				workspace.ChildAdded:Connect(function(child)
					if KEEP_WORKSPACE[child.Name] or child:IsA("Terrain") or child:IsA("Camera") then
						return
					end
					if child:IsA("Model") and Players:GetPlayerFromCharacter(child) then
						return
					end
					if localPlayer and child == localPlayer.Character then
						return
					end
					task.defer(function()
						if not child.Parent then
							return
						end
						if KEEP_WORKSPACE[child.Name] then
							return
						end
						if child:IsA("Model") and Players:GetPlayerFromCharacter(child) then
							return
						end
						destroyInst(child)
					end)
				end)
			)

			-- global descendant stripper (streamed meshes / FX)
			table.insert(
				conns,
				workspace.DescendantAdded:Connect(function(inst)
					task.defer(function()
						if not inst.Parent then
							return
						end
						-- don't delete characters wholesale
						if inst:IsA("Model") and Players:GetPlayerFromCharacter(inst) then
							if localPlayer and inst ~= localPlayer.Character then
								Opt.HideOtherPlayers(config, localPlayer)
							end
							return
						end
						stripIncomingInstance(inst, localPlayer)
					end)
				end)
			)
		end

		local map = workspace:FindFirstChild("Map")
		if map and cfgBool(config, "ClearMap", true) then
			table.insert(
				conns,
				map.ChildAdded:Connect(function(child)
					if KEEP_MAP_CHILDREN[child.Name] then
						if child.Name == "SeedPackSpawnClient" then
							task.defer(function()
								destroyChildren(child)
							end)
						elseif child.Name == "SeedPackSpawnServerLocations" then
							task.defer(function()
								stripSeedPackFolder(child)
							end)
						end
						return
					end
					task.defer(function()
						if child.Parent == map and not KEEP_MAP_CHILDREN[child.Name] then
							destroyInst(child)
						end
					end)
				end)
			)
			local clientFolder = map:FindFirstChild("SeedPackSpawnClient")
			if clientFolder then
				table.insert(
					conns,
					clientFolder.ChildAdded:Connect(function(child)
						task.defer(function()
							if child.Parent then
								destroyInst(child)
							end
						end)
					end)
				)
			end
			local serverFolder = map:FindFirstChild("SeedPackSpawnServerLocations")
			if serverFolder then
				table.insert(
					conns,
					serverFolder.ChildAdded:Connect(function(child)
						task.defer(function()
							if not child.Parent then
								return
							end
							-- Do NOT Destroy spawn Parts — only strip visuals / keep touch.
							if child:IsA("BasePart") then
								prepareSeedSpawnPart(child)
							else
								stripVisualTree(child, { destroyMeshParts = true })
								for _, d in ipairs(child:GetDescendants()) do
									if d:IsA("BasePart") then
										prepareSeedSpawnPart(d)
									end
								end
							end
						end)
					end)
				)
			end
		end

		if cfgBool(config, "ClearOtherGardens", true) then
			local gardens = workspace:FindFirstChild("Gardens")
			if gardens then
				table.insert(
					conns,
					gardens.ChildAdded:Connect(function(plot)
						local plotId = getOwnPlotId(localPlayer)
						if plotId == nil then
							return
						end
						if isOwnPlot(plot, plotId) then
							task.defer(function()
								if plot.Parent then
									stripOwnPlot(plot)
								end
							end)
							return
						end
						task.defer(function()
							if plot.Parent and not isOwnPlot(plot, getOwnPlotId(localPlayer)) then
								destroyInst(plot)
							end
						end)
					end)
				)
				-- new plants under own plot
				local plotId = getOwnPlotId(localPlayer)
				local own = plotId and gardens:FindFirstChild("Plot" .. tostring(plotId))
				local plants = own and own:FindFirstChild("Plants")
				if plants then
					table.insert(
						conns,
						plants.ChildAdded:Connect(function(plant)
							task.defer(function()
								if plant.Parent then
									stripOwnPlant(plant)
								end
							end)
						end)
					)
				end
			end
		end

		if cfgBool(config, "HideOtherPlayers", true) then
			table.insert(
				conns,
				Players.PlayerAdded:Connect(function(plr)
					table.insert(
						conns,
						plr.CharacterAdded:Connect(function(char)
							if plr ~= localPlayer then
								task.defer(function()
									if char and char.Parent then
										Opt.HideOtherPlayers(config, localPlayer)
									end
								end)
							end
						end)
					)
				end)
			)
		end

		table.insert(
			conns,
			Lighting.ChildAdded:Connect(function(child)
				task.defer(function()
					if child and child.Parent == Lighting then
						destroyInst(child)
					end
				end)
			end)
		)

		if cfgBool(config, "MuteSounds", true) then
			table.insert(
				conns,
				SoundService.DescendantAdded:Connect(function(inst)
					if inst:IsA("Sound") then
						task.defer(function()
							if inst.Parent then
								destroyInst(inst)
							end
						end)
					end
				end)
			)
		end

		return function()
			for _, c in ipairs(conns) do
				safe(function()
					c:Disconnect()
				end)
			end
		end
	end

	function Opt.GetStats()
		return Stats.destroyed, Stats.stripped
	end

	function Opt.Run(config, localPlayer)
		if not cfgBool(config, "EnableFPSOpt", true) then
			log("disabled")
			return function() end
		end
		Stats.destroyed = 0
		Stats.stripped = 0

		Opt.ApplyRendering(config)
		Opt.MuteSounds(config)
		local a = Opt.ClearWorkspaceJunk(config)
		local b = Opt.ClearMapJunk(config)
		local plotWait = 0
		while getOwnPlotId(localPlayer) == nil and plotWait < 20 do
			task.wait(0.25)
			plotWait += 0.25
		end
		local c = Opt.ClearOtherGardens(config, localPlayer)
		local d = Opt.HideOtherPlayers(config, localPlayer)
		log(string.format(
			"NUKE ws=%d map=%d plotOps=%d hidePlayers=%d | destroyed=%d stripped(meshes)=%d plotId=%s keep={own Plants/Base/Fruits,PlantArea,Sprinklers,SeedServer,WildPet*,DroppedItems,Handles,FH_AntiVoid}",
			a,
			b,
			c,
			d,
			Stats.destroyed,
			Stats.stripped,
			tostring(getOwnPlotId(localPlayer))
		))
		local stopWatch = Opt.WatchIncoming(config, localPlayer)

		local running = true
		task.spawn(function()
			while running do
				task.wait(6)
				if not running then
					break
				end
				local d0, s0 = Stats.destroyed, Stats.stripped
				if cfgBool(config, "ClearMap", true) then
					Opt.ClearWorkspaceJunk(config)
					Opt.ClearMapJunk(config)
					Opt.MuteSounds(config)
					Opt.ApplyRendering(config)
				end
				if cfgBool(config, "ClearOtherGardens", true) then
					Opt.ClearOtherGardens(config, localPlayer)
				end
				if cfgBool(config, "HideOtherPlayers", true) then
					Opt.HideOtherPlayers(config, localPlayer)
				end
				local dd, ss = Stats.destroyed - d0, Stats.stripped - s0
				if dd > 0 or ss > 0 then
					log(string.format(
						"re-sweep +destroyed=%d +stripped=%d total destroyed=%d stripped=%d",
						dd,
						ss,
						Stats.destroyed,
						Stats.stripped
					))
				end
			end
		end)

		return function()
			running = false
			if stopWatch then
				stopWatch()
			end
		end
	end
end

----------------------------------------------------------------
-- Farm loop
----------------------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	LocalPlayer = Players.PlayerAdded:Wait()
end

if not game:IsLoaded() then
	game.Loaded:Wait()
end

----------------------------------------------------------------
-- Polyfills
----------------------------------------------------------------
local env = (getgenv and getgenv()) or _G
if typeof(setfpscap) ~= "function" then
	if typeof(set_fps_cap) == "function" then
		setfpscap = set_fps_cap
	else
		function setfpscap(_) end
	end
end

local function log(...)
	warn("[FH-Farm]", ...)
end

local function now()
	return os.clock()
end

----------------------------------------------------------------
-- Networking / data
----------------------------------------------------------------
local Networking = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Networking"))
local SeedData = require(ReplicatedStorage.SharedModules.SeedData)
local GearShopData = require(ReplicatedStorage.SharedModules.GearShopData)
local PetData = require(ReplicatedStorage.SharedData.PetData)
local Worlds = require(ReplicatedStorage.SharedModules.Worlds)
local PlayerStateClient = require(ReplicatedStorage.ClientModules.PlayerStateClient)
local WateringcanData = require(ReplicatedStorage.SharedModules.WateringcanData)
local SprinklerData = require(ReplicatedStorage.SharedModules.SprinklerData)

-- SeedData is an ARRAY of { SeedName, PurchasePrice, ... } — NOT a name-keyed map.
local SeedDataByName = {}
do
	for _, row in ipairs(SeedData) do
		if type(row) == "table" and type(row.SeedName) == "string" then
			SeedDataByName[row.SeedName] = row
		end
	end
end

local function getSeedInfo(seedName)
	if type(seedName) ~= "string" or seedName == "" then
		return nil
	end
	return SeedDataByName[seedName]
end

local function getSeedPrice(seedName)
	local info = getSeedInfo(seedName)
	if not info then
		return nil
	end
	local p = info.PurchasePrice or info.Price or info.Cost
	if typeof(p) == "number" then
		return p
	end
	return nil
end

local Config = env.UserConfig
if type(Config) ~= "table" then
	error("[FH-Farm] getgenv().UserConfig missing — config bootstrap failed")
end

----------------------------------------------------------------
-- Busy / state machine
----------------------------------------------------------------
local Busy = {
	selling = false,
	planting = false,
	harvesting = false,
	mailing = false,
	shopping = false,
	gearing = false,
	expanding = false,
}

local State = {
	name = "BOOT",
	since = now(),
	loop = 0,
	errors = 0,
	lastError = nil,
	lastPlantAt = 0,
	lastHarvestAt = 0,
	lastSellAt = 0,
	lastShopAt = 0,
	lastMailAt = 0,
	lastExpandAt = 0,
	lastGearAt = 0,
	lastAntiStuckAt = 0,
	lastWebhookAt = 0,
	lastStockEmptyAt = 0,
	shopRestockWaitUntil = 0,
	stuckChecks = 0,
	lastPos = nil,
	posStuckSince = nil,
	-- PlantId -> { at, seed, price, growWindow } for plants this script planted
	recentPlants = {},
	sellCtx = { Config = Config, Networking = Networking, busy = Busy },
	stats = {
		plants = 0,
		harvests = 0,
		sells = 0,
		buys = 0,
		mails = 0,
		retries = 0,
	},
}

local function setState(name, reason)
	-- only log transitions that did real work (reason provided) or BOOT/READY/RECOVER
	local forceLog = name == "BOOT" or name == "READY" or name == "RECOVER" or reason ~= nil
	if State.name ~= name then
		if forceLog or reason then
			if reason then
				log("state", State.name, "->", name, "(" .. tostring(reason) .. ")")
			else
				log("state", State.name, "->", name)
			end
		end
		State.name = name
		State.since = now()
	elseif reason then
		log("state", name, "(" .. tostring(reason) .. ")")
	end
end

local function withBusy(key, fn)
	if Busy[key] then
		return false, "busy"
	end
	Busy[key] = true
	local ok, a, b, c = pcall(fn)
	Busy[key] = false
	if not ok then
		State.errors += 1
		State.lastError = a
		State.stats.retries += 1
		return false, a
	end
	return a, b, c
end

local function retry(times, delaySec, fn)
	local lastErr
	for i = 1, times do
		local ok, res = pcall(fn)
		if ok then
			return true, res
		end
		lastErr = res
		State.stats.retries += 1
		task.wait(delaySec or 0.15)
	end
	return false, lastErr
end

----------------------------------------------------------------
-- Config helpers
----------------------------------------------------------------
local function cfg(key, default)
	local v = Config[key]
	if v == nil then
		return default
	end
	return v
end

local function limitOf(entry)
	if type(entry) == "number" then
		return entry
	end
	if type(entry) == "table" then
		return entry.Limit or entry.Amount or entry[1]
	end
	return nil
end

local function minMoneyOf(entry)
	if type(entry) ~= "table" then
		return 0
	end
	local m = entry["Min Sheckles"] or entry.MinSheckles or entry.Min
	if type(m) == "number" then
		return m
	end
	if type(m) == "string" then
		local n, suf = m:lower():match("^([%d%.]+)([kmb]?)$")
		n = tonumber(n)
		if not n then
			return 0
		end
		if suf == "k" then
			return n * 1e3
		elseif suf == "m" then
			return n * 1e6
		elseif suf == "b" then
			return n * 1e9
		end
		return n
	end
	return 0
end

local function listHas(list, name)
	if type(list) ~= "table" then
		return false
	end
	if list[name] ~= nil then
		return true
	end
	for _, v in ipairs(list) do
		if v == name then
			return true
		end
	end
	return false
end

local function isBlacklistedSeed(name)
	return listHas(Config["Blacklist Seed"], name)
end

-- Seeds listed under Items To Mail.Seed are buy/mail only — never plant.
local function isMailBoundSeed(name)
	local mail = Config["Items To Mail"]
	local seeds = mail and mail.Seed
	if type(seeds) ~= "table" or type(name) ~= "string" then
		return false
	end
	return seeds[name] ~= nil
end

local function shovelBlocked(seedName, mutation)
	local bl = Config["Blacklist Shovel"]
	if type(bl) ~= "table" then
		return false
	end
	if bl[seedName] ~= nil then
		local rule = bl[seedName]
		if type(rule) == "table" then
			if not mutation or mutation == "" then
				return false
			end
			return listHas(rule, mutation)
		end
		return true
	end
	return listHas(bl, seedName)
end

-- HMO: array → any non-mut plant blocked; map → per-seed mut whitelist
local function harvestAllowed(seedName, mutation)
	local hmo = Config["Harvest Mutation Only"]
	if type(hmo) ~= "table" then
		return true
	end
	local hasKey = false
	for _ in pairs(hmo) do
		hasKey = true
		break
	end
	if not hasKey then
		return true
	end
	local isArray = hmo[1] ~= nil
	local hasMut = type(mutation) == "string" and mutation ~= ""
	if isArray then
		if listHas(hmo, seedName) then
			return hasMut
		end
		return hasMut
	end
	local rule = hmo[seedName]
	if rule == nil then
		return true
	end
	if type(rule) == "table" then
		return hasMut and listHas(rule, mutation)
	end
	return hasMut
end

----------------------------------------------------------------
-- Money / world
----------------------------------------------------------------
local function currencyName()
	local world = cfg("World", "Fall Harvest")
	if world == "Fall Harvest" or world == "FallHarvest" then
		return "Leaves"
	end
	local w = Worlds.Current
	return (w and w.CurrencyName) or "Sheckles"
end

local function getMoney()
	local ls = LocalPlayer:FindFirstChild("leaderstats")
	if not ls then
		return 0
	end
	local m = ls:FindFirstChild(currencyName()) or ls:FindFirstChild("Leaves") or ls:FindFirstChild("Sheckles")
	return m and m.Value or 0
end

local function brokeThreshold()
	return cfg("Sell Force When Broke", 1000)
end

local function isBroke(money)
	money = money or getMoney()
	return money <= brokeThreshold()
end

----------------------------------------------------------------
-- Plot / plants
----------------------------------------------------------------
local function getPlot()
	local plotId = LocalPlayer:GetAttribute("PlotId")
	if not plotId then
		return nil
	end
	local gardens = workspace:FindFirstChild("Gardens")
	if not gardens then
		return nil
	end
	return gardens:FindFirstChild("Plot" .. tostring(plotId))
end

local function getPlantAreaParts(plot)
	local areas = {}
	if not plot then
		return areas
	end
	local visual = plot:FindFirstChild("Visual")
	local root = visual or plot
	local seen = {}
	local function consider(d)
		if not d:IsA("BasePart") or seen[d] then
			return
		end
		if CollectionService:HasTag(d, "PlantArea") or d.Name:find("PlantArea") then
			seen[d] = true
			table.insert(areas, d)
		end
	end
	for _, d in ipairs(root:GetDescendants()) do
		consider(d)
	end
	if #areas == 0 then
		for _, d in ipairs(plot:GetDescendants()) do
			consider(d)
		end
	end
	table.sort(areas, function(a, b)
		return a.Name < b.Name
	end)
	return areas
end

local function getPlantAreaCenters(plot)
	local centers = {}
	for _, area in ipairs(getPlantAreaParts(plot)) do
		table.insert(centers, area.Position + Vector3.new(0, 0.5, 0))
	end
	if #centers == 0 and plot then
		local spawn = plot:FindFirstChild("SpawnPoint")
		if spawn and spawn:IsA("BasePart") then
			table.insert(centers, spawn.Position)
		end
	end
	return centers
end

local function getPlantWorldPos(plant)
	if not plant then
		return nil
	end
	local base = plant:FindFirstChild("Base")
	if base and base:IsA("BasePart") then
		return base.Position
	end
	if plant:IsA("Model") then
		local ok, pivot = pcall(function()
			return plant:GetPivot().Position
		end)
		if ok and typeof(pivot) == "Vector3" then
			return pivot
		end
		local pp = plant.PrimaryPart
		if pp then
			return pp.Position
		end
	end
	if plant:IsA("BasePart") then
		return plant.Position
	end
	return nil
end

local function collectOccupiedXZ(plot)
	local pts = {}
	if not plot then
		return pts
	end
	local folder = plot:FindFirstChild("Plants")
	if not folder then
		return pts
	end
	for _, plant in ipairs(folder:GetChildren()) do
		if plant:IsA("Model") then
			local p = getPlantWorldPos(plant)
			if p then
				table.insert(pts, Vector2.new(p.X, p.Z))
			end
		end
	end
	return pts
end

local function xzOccupied(pts, x, z, minDist)
	local d2 = minDist * minDist
	for _, p in ipairs(pts) do
		local dx = p.X - x
		local dz = p.Y - z
		if dx * dx + dz * dz < d2 then
			return true
		end
	end
	return false
end

-- Candidate plant slots for one PlantArea, ordered outward from center.
local function generateClusterSlots(area, spacing, mode)
	local slots = {}
	if not area or not area:IsA("BasePart") then
		return slots
	end
	spacing = math.max(1, tonumber(spacing) or 1.5)
	local margin = math.max(0.5, spacing * 0.25)
	local half = area.Size * 0.5
	local maxX = math.max(0, half.X - margin)
	local maxZ = math.max(0, half.Z - margin)
	local nx = math.floor(maxX / spacing)
	local nz = math.floor(maxZ / spacing)
	local cf = area.CFrame
	-- snap to top of PlantArea (matches PlantController raycast hit surface)
	local topY = area.Position.Y + area.Size.Y * 0.5 + 0.05

	local function worldAt(ix, iz)
		local p = (cf * CFrame.new(ix * spacing, 0, iz * spacing)).Position
		return Vector3.new(p.X, topY, p.Z)
	end

	mode = string.lower(tostring(mode or "spiral"))
	if mode == "grid" then
		local cands = {}
		for ix = -nx, nx do
			for iz = -nz, nz do
				table.insert(cands, {
					pos = worldAt(ix, iz),
					dist2 = ix * ix + iz * iz,
				})
			end
		end
		table.sort(cands, function(a, b)
			if a.dist2 == b.dist2 then
				return a.pos.X < b.pos.X
			end
			return a.dist2 < b.dist2
		end)
		for _, c in ipairs(cands) do
			table.insert(slots, c.pos)
		end
		return slots
	end

	-- spiral (default): ring outward around area center
	local function tryAdd(ix, iz)
		if math.abs(ix) <= nx and math.abs(iz) <= nz then
			table.insert(slots, worldAt(ix, iz))
			return true
		end
		return false
	end
	tryAdd(0, 0)
	local x, z = 0, 0
	local dx, dz = 1, 0
	local segmentLen = 1
	local segmentPassed = 0
	local turns = 0
	local target = (2 * nx + 1) * (2 * nz + 1)
	-- square spiral must cover max(nx,nz) rings even when the area is rectangular
	local maxRing = math.max(nx, nz)
	local guard = (2 * maxRing + 1) * (2 * maxRing + 1) + 8
	for _ = 1, guard do
		if #slots >= target then
			break
		end
		x += dx
		z += dz
		tryAdd(x, z)
		segmentPassed += 1
		if segmentPassed >= segmentLen then
			segmentPassed = 0
			dx, dz = -dz, dx
			turns += 1
			if turns % 2 == 0 then
				segmentLen += 1
			end
		end
	end
	return slots
end

-- Free slots across PlantAreas in stable order (fill Column1, then Column2, ...).
local function buildPlantSlotQueue(plot, spacing, mode)
	local queue = {}
	local occupied = collectOccupiedXZ(plot)
	-- Slightly under half-spacing so grid/spiral neighbors aren't false-"occupied".
	local minDist = math.min((tonumber(spacing) or 1.5) * 0.45, 0.9)
	local areas = getPlantAreaParts(plot)
	if #areas == 0 then
		-- fallback: world-axis spiral around SpawnPoint / first center
		local centers = getPlantAreaCenters(plot)
		if #centers == 0 then
			return queue
		end
		local anchor = centers[1]
		local sp = math.max(1, tonumber(spacing) or 1.5)
		local x, z = 0, 0
		local dx, dz = 1, 0
		local segmentLen = 1
		local segmentPassed = 0
		local turns = 0
		local function trySlot(ix, iz)
			local pos = anchor + Vector3.new(ix * sp, 0, iz * sp)
			if not xzOccupied(occupied, pos.X, pos.Z, minDist) then
				table.insert(queue, pos)
				table.insert(occupied, Vector2.new(pos.X, pos.Z))
			end
		end
		trySlot(0, 0)
		for _ = 1, 120 do
			x += dx
			z += dz
			trySlot(x, z)
			segmentPassed += 1
			if segmentPassed >= segmentLen then
				segmentPassed = 0
				dx, dz = -dz, dx
				turns += 1
				if turns % 2 == 0 then
					segmentLen += 1
				end
			end
		end
		return queue
	end

	for _, area in ipairs(areas) do
		for _, pos in ipairs(generateClusterSlots(area, spacing, mode)) do
			if not xzOccupied(occupied, pos.X, pos.Z, minDist) then
				table.insert(queue, pos)
				table.insert(occupied, Vector2.new(pos.X, pos.Z))
			end
		end
	end
	return queue
end

local function countPlants(plot)
	if not plot then
		return 0, {}
	end
	local folder = plot:FindFirstChild("Plants")
	if not folder then
		return 0, {}
	end
	local bySeed = {}
	local n = 0
	for _, plant in ipairs(folder:GetChildren()) do
		if plant:IsA("Model") then
			n += 1
			local seed = plant:GetAttribute("SeedName") or "?"
			bySeed[seed] = (bySeed[seed] or 0) + 1
		end
	end
	return n, bySeed
end

local function safePivot(hrp, cf)
	pcall(function()
		if hrp.Parent and hrp.Parent:IsA("Model") then
			hrp.Parent:PivotTo(cf)
		else
			hrp.CFrame = cf
		end
	end)
end

local function plotStandCFrame(plot)
	if not plot then
		return nil
	end
	local spawn = plot:FindFirstChild("SpawnPoint")
	if spawn and spawn:IsA("BasePart") then
		return spawn.CFrame + Vector3.new(0, 3, 0)
	end
	local ref = plot:FindFirstChild("PlotSizeReference")
	if ref and ref:IsA("BasePart") then
		return ref.CFrame + Vector3.new(0, 5, 0)
	end
	local visual = plot:FindFirstChild("Visual")
	if visual then
		for _, name in ipairs({ "GardenTotalArea", "GardenZonePart", "PRIM" }) do
			local p = visual:FindFirstChild(name)
			if p and p:IsA("BasePart") then
				return p.CFrame + Vector3.new(0, 5, 0)
			end
		end
		local bed = visual:FindFirstChild("BedSection")
		if bed then
			local part = bed:FindFirstChildWhichIsA("BasePart", true)
			if part then
				return part.CFrame + Vector3.new(0, 5, 0)
			end
		end
	end
	if plot:IsA("Model") and plot.PrimaryPart then
		return plot.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
	end
	local any = plot:FindFirstChildWhichIsA("BasePart", true)
	if any then
		return any.CFrame + Vector3.new(0, 5, 0)
	end
	return nil
end

local function teleportToPlot(reason)
	local plot = getPlot()
	local cf = plotStandCFrame(plot)
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp and cf then
		if reason then
			log("tele reason=", reason)
		end
		pcall(function()
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.PlatformStand = false
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
		end)
		safePivot(hrp, cf)
		return true
	end
	return false
end

local function teleportNear(worldPos, reason, horizontalStuds)
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not (hrp and typeof(worldPos) == "Vector3") then
		return false
	end
	horizontalStuds = horizontalStuds or 3
	if reason then
		log("tele reason=", reason, string.format("at=(%.1f,%.1f,%.1f)", worldPos.X, worldPos.Y, worldPos.Z))
	end
	pcall(function()
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.PlatformStand = false
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end)
	-- stand 2–5 studs beside the plant, slightly above ground
	local angle = (tick() * 2.1) % (math.pi * 2)
	local dist = math.clamp(horizontalStuds, 2, 5)
	local offset = Vector3.new(math.cos(angle) * dist, 3, math.sin(angle) * dist)
	safePivot(hrp, CFrame.new(worldPos + offset, worldPos))
	return true
end

----------------------------------------------------------------
-- Anti-void platform (huge Part under map — watering / seed / wildpet TPs)
----------------------------------------------------------------
-- AABB of remaining playable anchors (seed spawns, wild pets, own plot).
local function antiVoidPlayableAABB()
	local minX, minZ = math.huge, math.huge
	local maxX, maxZ = -math.huge, -math.huge
	local found = false

	local function absorbPos(pos)
		if typeof(pos) ~= "Vector3" then
			return
		end
		minX = math.min(minX, pos.X)
		maxX = math.max(maxX, pos.X)
		minZ = math.min(minZ, pos.Z)
		maxZ = math.max(maxZ, pos.Z)
		found = true
	end

	local function absorbPart(p)
		if not p or not p:IsA("BasePart") then
			return
		end
		-- include extents so large PlantArea / plot refs expand the floor
		local half = p.Size * 0.5
		local pos = p.Position
		absorbPos(pos + Vector3.new(half.X, 0, half.Z))
		absorbPos(pos + Vector3.new(-half.X, 0, -half.Z))
		absorbPos(pos + Vector3.new(half.X, 0, -half.Z))
		absorbPos(pos + Vector3.new(-half.X, 0, half.Z))
	end

	local function absorbRoot(root)
		if not root then
			return
		end
		if root:IsA("BasePart") then
			absorbPart(root)
		end
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("BasePart") then
				absorbPart(d)
			end
		end
	end

	local map = workspace:FindFirstChild("Map")
	if map then
		absorbRoot(map:FindFirstChild("SeedPackSpawnServerLocations"))
		absorbRoot(map:FindFirstChild("WildPetRef"))
		absorbRoot(map:FindFirstChild("WildPetSpawns"))
		-- leftover Map BaseParts (SafeZones etc.) if Opt kept them
		for _, child in ipairs(map:GetChildren()) do
			if child:IsA("BasePart") then
				absorbPart(child)
			end
		end
	end

	local plot = getPlot()
	if plot then
		absorbRoot(plot)
		local stand = plotStandCFrame(plot)
		if stand then
			absorbPos(stand.Position)
		end
	end

	if not found then
		return nil
	end
	return {
		minX = minX,
		maxX = maxX,
		minZ = minZ,
		maxZ = maxZ,
		centerX = (minX + maxX) * 0.5,
		centerZ = (minZ + maxZ) * 0.5,
		spanX = maxX - minX,
		spanZ = maxZ - minZ,
	}
end

local function ensureAntiVoidPlatform()
	if not cfg("Anti Void Platform", true) then
		return nil
	end
	local plot = getPlot()
	local cf = plotStandCFrame(plot)
	local folder = workspace:FindFirstChild("FH_AntiVoid")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "FH_AntiVoid"
		folder.Parent = workspace
	end
	local part = folder:FindFirstChild("Platform")
	local created = false
	if not part or not part:IsA("BasePart") then
		if part then
			pcall(function()
				part:Destroy()
			end)
		end
		part = Instance.new("Part")
		part.Name = "Platform"
		part.Parent = folder
		created = true
	end

	local cfgSize = cfg("Anti Void Size", 2000)
	if typeof(cfgSize) ~= "number" or cfgSize < 100 then
		cfgSize = 2000
	end
	local margin = 250
	local thickness = 4
	local side = cfgSize
	local centerX, centerZ

	local bounds = antiVoidPlayableAABB()
	if bounds then
		local need = math.max(bounds.spanX, bounds.spanZ) + margin * 2
		side = math.max(cfgSize, need)
		centerX, centerZ = bounds.centerX, bounds.centerZ
	end

	-- Y: just under plot stand / typical walk height so feet land on the slab
	local y
	if cf then
		y = cf.Position.Y - 5
		if centerX == nil then
			centerX, centerZ = cf.Position.X, cf.Position.Z
		end
	elseif LocalPlayer.Character then
		local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			y = hrp.Position.Y - 6
			if centerX == nil then
				centerX, centerZ = hrp.Position.X, hrp.Position.Z
			end
		end
	end
	if y == nil or centerX == nil then
		return part
	end

	local wantSize = Vector3.new(side, thickness, side)
	part.Anchored = true
	part.CanCollide = true
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.fromRGB(35, 35, 35)
	if (part.Size - wantSize).Magnitude > 1 then
		part.Size = wantSize
	end
	part.CFrame = CFrame.new(centerX, y, centerZ)

	if created then
		log(
			"anti-void platform created",
			string.format("size=%.0fx%.0f y=%.1f center=(%.0f,%.0f)", side, side, y, centerX, centerZ)
		)
	end
	return part
end

----------------------------------------------------------------
-- Tools / inventory
----------------------------------------------------------------
local function eachTool(fn)
	local function scan(container)
		if not container then
			return
		end
		for _, t in ipairs(container:GetChildren()) do
			if t:IsA("Tool") then
				fn(t)
			end
		end
	end
	scan(LocalPlayer:FindFirstChildOfClass("Backpack"))
	scan(LocalPlayer.Character)
end

-- Resolve seed name from a backpack/character tool (SeedTool attr preferred).
local function resolveSeedName(tool)
	if not tool or not tool:IsA("Tool") then
		return nil
	end
	local sn = tool:GetAttribute("SeedTool")
	if type(sn) == "string" and sn ~= "" then
		return sn
	end
	-- Name fallbacks used by tutorial / older tools
	local name = tool.Name
	if type(name) ~= "string" or name == "" then
		return nil
	end
	if getSeedInfo(name) then
		return name
	end
	local stripped = name:match("^(.-)%s*[Ss]eed%s*$")
	if stripped and stripped ~= "" and getSeedInfo(stripped) then
		return stripped
	end
	-- last resort: any tool whose Name equals a known seed (even without SeedTool yet)
	if SeedDataByName[name] then
		return name
	end
	return nil
end

local function toolSeedCount(tool)
	local c = tool and tool:GetAttribute("Count")
	if typeof(c) == "number" and c > 0 then
		return math.floor(c)
	end
	return 1
end

local function equipTool(tool)
	if not tool or not tool.Parent then
		return false
	end
	local char = LocalPlayer.Character
	if not char then
		return false
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		return false
	end
	if tool.Parent == char then
		return true
	end
	local ok = pcall(function()
		hum:EquipTool(tool)
	end)
	if not ok then
		return false
	end
	-- SeedHandleController spawns Handle after equip; give it a few frames
	for _ = 1, 8 do
		if tool.Parent == char then
			return true
		end
		task.wait(0.05)
	end
	return tool.Parent == char
end

local function findToolByAttr(attrName, attrValue)
	local found
	eachTool(function(t)
		if found then
			return
		end
		local v = t:GetAttribute(attrName)
		if attrValue == nil then
			if v ~= nil then
				found = t
			end
		elseif v == attrValue or t.Name == attrValue then
			found = t
		end
	end)
	return found
end

local function findSeedTool(seedName)
	local found
	eachTool(function(t)
		if found then
			return
		end
		if resolveSeedName(t) == seedName then
			found = t
		end
	end)
	return found
end

local function countSeedTools(seedName)
	local n = 0
	eachTool(function(t)
		if resolveSeedName(t) == seedName then
			n += toolSeedCount(t)
		end
	end)
	return n
end

local function collectOwnedSeedTools()
	local list = {}
	local seen = {}
	eachTool(function(t)
		if seen[t] then
			return
		end
		local sn = resolveSeedName(t)
		if sn then
			seen[t] = true
			table.insert(list, { tool = t, seed = sn, count = toolSeedCount(t) })
		end
	end)
	return list
end

local function countGearTools(gearName)
	local n = 0
	eachTool(function(t)
		if t.Name == gearName
			or t:GetAttribute("WateringCan") == gearName
			or t:GetAttribute("Sprinkler") == gearName
			or t:GetAttribute("ItemName") == gearName
		then
			n += 1
		end
	end)
	return n
end

local function isFruitTool(t)
	if not t or not t:IsA("Tool") then
		return false
	end
	if t:GetAttribute("IsFavorite") == true then
		return false
	end
	if t:GetAttribute("HarvestedFruit") == true then
		return true
	end
	-- some fruit tools expose Fruit/FruitName without HarvestedFruit bool
	local fruit = t:GetAttribute("Fruit") or t:GetAttribute("FruitName")
	if type(fruit) == "string" and fruit ~= "" and t:GetAttribute("SeedTool") == nil then
		return true
	end
	return false
end

local function countFruitTools()
	local n = 0
	eachTool(function(t)
		if isFruitTool(t) then
			n += 1
		end
	end)
	return n
end

local function getReplicaInventory()
	local ok, rep = pcall(function()
		return PlayerStateClient:WaitForLocalReplica(5)
	end)
	if ok and rep and rep.Data and rep.Data.Inventory then
		return rep.Data.Inventory
	end
	return nil
end

local function petVariant(petEntry)
	if type(petEntry) ~= "table" then
		return "Normal"
	end
	if petEntry.Type == "Rainbow" or petEntry.Rainbow == true then
		return "Rainbow"
	end
	local size = petEntry.Size or petEntry.DisplaySize or "Normal"
	if size == "Big" or size == "Huge" or size == "Normal" then
		return size
	end
	return "Normal"
end

-- Config often uses DisplayName ("Shadow Dragon"); WildPetRef / PetData use key ("ShadowDragon").
local PET_NAME_ALIASES = {
	["Shadow Dragon"] = "ShadowDragon",
	["Golden Dragonfly"] = "GoldenDragonfly",
	["Black Dragon"] = "BlackDragon",
	["Bald Eagle"] = "BaldEagle",
	["Ice Serpent"] = "IceSerpent",
}

local function canonicalPetName(name)
	if type(name) ~= "string" or name == "" then
		return nil
	end
	if PET_NAME_ALIASES[name] then
		return PET_NAME_ALIASES[name]
	end
	if type(PetData[name]) == "table" then
		return name
	end
	for key, data in pairs(PetData) do
		if type(key) == "string" and type(data) == "table" and data.DisplayName == name then
			return key
		end
	end
	return name
end

local function wildPetVariant(ref)
	if not ref then
		return "Normal"
	end
	local petType = ref:GetAttribute("PetType")
	if petType == "Rainbow" then
		return "Rainbow"
	end
	local size = ref:GetAttribute("PetSize")
	if size == "Big" or size == "Huge" then
		return size
	end
	return "Normal"
end

local function countPetsByName()
	local counts = {}
	local function bump(name, var, idInfo)
		local canon = canonicalPetName(name) or name
		local bucket = counts[canon] or { Normal = 0, Big = 0, Huge = 0, Rainbow = 0, total = 0, ids = {} }
		bucket[var] = (bucket[var] or 0) + 1
		bucket.total += 1
		table.insert(bucket.ids, idInfo)
		counts[canon] = bucket
	end
	local inv = getReplicaInventory()
	if inv and type(inv.Pets) == "table" then
		for id, pet in pairs(inv.Pets) do
			if type(pet) == "table" and pet.Name then
				local var = petVariant(pet)
				bump(pet.Name, var, { id = pet.Id or id, variant = var, equipped = pet.Equipped == true })
			end
		end
		return counts
	end
	eachTool(function(t)
		local name = t:GetAttribute("PetName") or t:GetAttribute("Pet")
		if not name and t:GetAttribute("PetId") then
			name = t.Name:gsub("^Big ", ""):gsub("^Huge ", ""):gsub("^Rainbow ", "")
		end
		if not name then
			return
		end
		local var = "Normal"
		if t:GetAttribute("PetType") == "Rainbow" or t:GetAttribute("Rainbow") or t.Name:find("Rainbow") then
			var = "Rainbow"
		elseif t.Name:find("^Huge ") or t:GetAttribute("Size") == "Huge" or t:GetAttribute("PetSize") == "Huge" then
			var = "Huge"
		elseif t.Name:find("^Big ") or t:GetAttribute("Size") == "Big" or t:GetAttribute("PetSize") == "Big" then
			var = "Big"
		end
		bump(name, var, { id = t:GetAttribute("PetId") or t.Name, variant = var, tool = t })
	end)
	return counts
end

local function findBuyPetRule(rules, petName)
	if type(rules) ~= "table" or type(petName) ~= "string" then
		return nil, nil
	end
	if rules[petName] ~= nil then
		return rules[petName], petName
	end
	local canon = canonicalPetName(petName)
	if canon and rules[canon] ~= nil then
		return rules[canon], canon
	end
	for key, rule in pairs(rules) do
		if type(key) == "string" and canonicalPetName(key) == canon then
			return rule, key
		end
	end
	return nil, nil
end

-- number = any variant until total; table = ONLY listed variants (Normal/Big/Huge/Rainbow).
local function petRuleNeedsVariant(rule, bucket, variant)
	bucket = bucket or { Normal = 0, Big = 0, Huge = 0, Rainbow = 0, total = 0 }
	if type(rule) == "number" then
		return bucket.total < rule
	end
	if type(rule) ~= "table" then
		return false
	end
	local cap = rule[variant]
	if type(cap) ~= "number" then
		return false
	end
	return (bucket[variant] or 0) < cap
end

----------------------------------------------------------------
-- Gear category / prices
----------------------------------------------------------------
local function gearMailCategory(gearName)
	local lower = gearName:lower()
	if lower:find("watering") then
		return "WateringCans"
	end
	if lower:find("sprinkler") then
		return "Sprinklers"
	end
	if lower:find("mushroom") then
		return "Mushrooms"
	end
	if lower:find("gnome") then
		return "Gnomes"
	end
	if lower:find("crate") then
		return "Crates"
	end
	if lower:find("seed pack") then
		return "SeedPacks"
	end
	if lower:find("magic mail") then
		return "Sprinklers"
	end
	return "Sprinklers"
end

local function mailboxSend(username, category, itemKey, count)
	local ok, userId = pcall(function()
		return Networking.Mailbox.LookupPlayer:Fire(username)
	end)
	if not ok or type(userId) ~= "number" or userId <= 0 then
		return false
	end
	local ok2 = pcall(function()
		Networking.Mailbox.SendBatch:Fire(userId, {
			{ Category = category, ItemKey = itemKey, Count = count },
		}, "")
	end)
	return ok2
end

local GEAR_PRICE = {}
do
	for _, row in ipairs(GearShopData.Data or {}) do
		if type(row) == "table" and row.ItemName then
			GEAR_PRICE[row.ItemName] = row.PurchasePrice or row.Price or row.Cost
		end
	end
end

local GearCooldown = {} -- name -> nextOkAt
local GEAR_CD = cfg("Gear Cooldown", 8)

local WATER_SPLASH_BY_NAME = {}
do
	for _, row in ipairs(WateringcanData or {}) do
		if type(row) == "table" and row.Name then
			WATER_SPLASH_BY_NAME[row.Name] = row.SplashRadius or 5
		end
	end
end

local SPRINKLER_RADIUS_BY_NAME = {}
do
	local list = SprinklerData
	if type(SprinklerData) == "table" and SprinklerData.Data then
		list = SprinklerData.Data
	end
	for _, row in ipairs(list or {}) do
		if type(row) == "table" then
			local name = row.SprinklerName or row.Name
			if name then
				SPRINKLER_RADIUS_BY_NAME[name] = row.Radius or 20
			end
		end
	end
end

local function getPlantWorldPositions(plot)
	local out = {}
	if not plot then
		return out
	end
	local folder = plot:FindFirstChild("Plants")
	if not folder then
		return out
	end
	for _, plant in ipairs(folder:GetChildren()) do
		if plant:IsA("Model") then
			local p = getPlantWorldPos(plant)
			if p then
				table.insert(out, { plant = plant, pos = p })
			end
		end
	end
	return out
end

local function getExistingSprinklerPositions(plot)
	local out = {}
	if not plot then
		return out
	end
	local folder = plot:FindFirstChild("Sprinklers")
	if not folder then
		return out
	end
	for _, s in ipairs(folder:GetChildren()) do
		if s:IsA("Model") or s:IsA("BasePart") then
			local pp = s:IsA("BasePart") and s or (s.PrimaryPart or s:FindFirstChildWhichIsA("BasePart", true))
			if pp then
				table.insert(out, pp.Position)
			end
		end
	end
	return out
end

local function xzDist(a, b)
	local dx = a.X - b.X
	local dz = a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

local function isWateringImmuneSeed(seedName)
	local info = getSeedInfo(seedName)
	return info ~= nil and info.WateringImmune == true
end

local function isGrowsForeverSeed(seedName)
	local info = getSeedInfo(seedName)
	return info ~= nil and info.GrowsForever == true
end

local function getPlantValue(plant)
	local seedName = plant and plant:GetAttribute("SeedName")
	local price = getSeedPrice(seedName)
	if typeof(price) == "number" and price > 0 then
		return price
	end
	local pid = plant and plant:GetAttribute("PlantId")
	local tracked = pid and State.recentPlants[pid]
	if tracked and typeof(tracked.price) == "number" then
		return tracked.price
	end
	return 0
end

-- Still developing if plant Age < MaxAge, any fruit Age < MaxAge, GrowsForever, or
-- script-tracked within PrimeTime window. PlantGrowthReady only means visualizer init done.
local function isPlantStillGrowing(plant)
	if not plant or not plant:IsA("Model") then
		return false
	end
	local seedName = plant:GetAttribute("SeedName")
	if isGrowsForeverSeed(seedName) then
		return true
	end

	local age = tonumber(plant:GetAttribute("Age")) or 0
	local maxAge = tonumber(plant:GetAttribute("MaxAge")) or 0
	if maxAge > 0 and age < maxAge - 1e-4 then
		return true
	end

	local fruits = plant:FindFirstChild("Fruits")
	if fruits then
		local sawFruit = false
		for _, fruit in ipairs(fruits:GetChildren()) do
			sawFruit = true
			local fAge = tonumber(fruit:GetAttribute("Age")) or 0
			local fMax = tonumber(fruit:GetAttribute("MaxAge")) or 0
			local ready = fruit:GetAttribute("HarvestReady") == true
			if ready then
				continue
			end
			if fMax > 0 and fAge < fMax - 1e-4 then
				return true
			end
			if fMax <= 0 then
				return true
			end
		end
		-- plant body done + every fruit ripe → gear waste
		if sawFruit and maxAge > 0 and age >= maxAge then
			return false
		end
	end

	if maxAge > 0 and age >= maxAge then
		return false
	end

	-- Attribute gap: fall back to PlantedAt + PrimeTime / script track
	local info = getSeedInfo(seedName)
	local prime = info and tonumber(info.PrimeTime) or nil
	local plantedAt = tonumber(plant:GetAttribute("PlantedAt"))
	if plantedAt and prime and prime > 0 then
		local serverNow = workspace:GetServerTimeNow()
		local elapsed = serverNow - plantedAt
		if elapsed < 0 then
			elapsed = os.time() - plantedAt
		end
		if elapsed >= 0 and elapsed < prime then
			return true
		end
	end

	local pid = plant:GetAttribute("PlantId")
	local tracked = pid and State.recentPlants[pid]
	if tracked then
		local window = tracked.growWindow or prime or 120
		if (now() - tracked.at) < window then
			return true
		end
	end

	return false
end

local function pruneRecentPlants()
	local t = now()
	for pid, info in pairs(State.recentPlants) do
		local window = (info and info.growWindow) or 600
		if not info or (t - info.at) > math.max(window * 2, 600) then
			State.recentPlants[pid] = nil
		end
	end
end

local function trackPlantedNear(plot, worldPos, seedName)
	if not plot or typeof(worldPos) ~= "Vector3" then
		return
	end
	local folder = plot:FindFirstChild("Plants")
	if not folder then
		return
	end
	local best, bestD, bestPlanted = nil, 6, -1
	for _, plant in ipairs(folder:GetChildren()) do
		if not plant:IsA("Model") then
			continue
		end
		local sn = plant:GetAttribute("SeedName")
		if type(sn) == "string" and sn ~= seedName then
			continue
		end
		local pid = plant:GetAttribute("PlantId")
		local p = getPlantWorldPos(plant)
		if not pid or not p then
			continue
		end
		local d = xzDist(p, worldPos)
		local plantedAt = tonumber(plant:GetAttribute("PlantedAt")) or 0
		if d < bestD or (math.abs(d - bestD) < 0.05 and plantedAt > bestPlanted) then
			bestD = d
			bestPlanted = plantedAt
			best = plant
		end
	end
	if not best then
		return
	end
	local pid = best:GetAttribute("PlantId")
	if not pid then
		return
	end
	local info = getSeedInfo(seedName)
	State.recentPlants[pid] = {
		at = now(),
		seed = seedName,
		price = getSeedPrice(seedName) or 0,
		growWindow = (info and tonumber(info.PrimeTime)) or 120,
	}
end

-- Growing (+ optionally waterable) gear targets, expensive-first when configured.
local function getGearTargetPlants(plot, forWateringCan)
	local out = {}
	local onlyGrowing = cfg("Gear Only Growing", true)
	local preferExpensive = cfg("Gear Prefer Expensive", true)
	pruneRecentPlants()
	for _, entry in ipairs(getPlantWorldPositions(plot)) do
		local plant = entry.plant
		local seedName = plant:GetAttribute("SeedName")
		if forWateringCan and isWateringImmuneSeed(seedName) then
			continue
		end
		if onlyGrowing and not isPlantStillGrowing(plant) then
			continue
		end
		local value = getPlantValue(plant)
		table.insert(out, {
			plant = plant,
			pos = entry.pos,
			value = value,
			seed = seedName,
		})
	end
	if preferExpensive then
		table.sort(out, function(a, b)
			if a.value ~= b.value then
				return a.value > b.value
			end
			-- fresher PlantedAt first among equal price
			local pa = tonumber(a.plant:GetAttribute("PlantedAt")) or 0
			local pb = tonumber(b.plant:GetAttribute("PlantedAt")) or 0
			return pa > pb
		end)
	end
	return out
end

-- Densest / highest-value growing cluster not already covered by a sprinkler.
local function pickSprinklerSpot(plantEntries, existing, radius)
	local preferExpensive = cfg("Gear Prefer Expensive", true)
	local bestPos, bestScore, bestCount = nil, -1, 0
	for _, entry in ipairs(plantEntries) do
		local p = entry.pos
		local occupied = false
		local alreadyCovered = false
		for _, sp in ipairs(existing) do
			local d = xzDist(p, sp)
			if d < 1.05 then
				occupied = true
				break
			end
			if d < radius * 0.8 then
				alreadyCovered = true
			end
		end
		if occupied or alreadyCovered then
			continue
		end
		local count = 0
		local valueSum = 0
		for _, other in ipairs(plantEntries) do
			if xzDist(p, other.pos) <= radius then
				count += 1
				valueSum += (other.value or 0)
			end
		end
		if count <= 0 then
			continue
		end
		-- Prefer expensive cluster value; fall back to plant count.
		local score = preferExpensive and (valueSum + count * 0.01) or count
		if score > bestScore then
			bestScore = score
			bestCount = count
			bestPos = p
		end
	end
	return bestPos, bestCount, bestScore
end

----------------------------------------------------------------
-- Stock helpers / restock wait
----------------------------------------------------------------
local function stockNodeValue(node)
	if not node then
		return nil
	end
	if node:IsA("ValueBase") then
		return node.Value
	end
	local s = node:FindFirstChild("Stock")
	if s and s:IsA("ValueBase") then
		return s.Value
	end
	return nil
end

local function anySeedInStock(limits)
	local stockFolder = ReplicatedStorage:FindFirstChild("StockValues")
	stockFolder = stockFolder and stockFolder:FindFirstChild("SeedShop")
	local items = stockFolder and stockFolder:FindFirstChild("Items")
	if not items then
		return true -- unknown → don't block
	end
	local anyListed = false
	for seedName, entry in pairs(limits) do
		if type(seedName) == "string" and limitOf(entry) then
			anyListed = true
			local node = items:FindFirstChild(seedName)
			local stock = stockNodeValue(node)
			if stock == nil or stock > 0 then
				return true
			end
		end
	end
	return not anyListed
end

local function maybeWaitShopRestock()
	if not cfg("Shop Restock Wait", true) then
		return false
	end
	if now() < State.shopRestockWaitUntil then
		return true
	end
	local limits = Config["Limit Buy Seed"]
	if type(limits) ~= "table" then
		return false
	end
	if anySeedInStock(limits) then
		return false
	end
	local waitSec = cfg("Shop Restock Wait Seconds", 25)
	State.shopRestockWaitUntil = now() + waitSec
	State.lastStockEmptyAt = now()
	log("seed shop empty — restock wait", waitSec, "s")
	return true
end

----------------------------------------------------------------
-- Webhook
----------------------------------------------------------------
local function webhook(url, content)
	if type(url) ~= "string" or url == "" or not url:find("discord") then
		return
	end
	pcall(function()
		local body = HttpService:JSONEncode({ content = content })
		local req = request or (syn and syn.request) or http_request or http and http.request
		if req then
			req({
				Url = url,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = body,
			})
		end
	end)
end

local function webhookFilterActive(list)
	if type(list) ~= "table" then
		return false
	end
	for _ in pairs(list) do
		return true
	end
	return false
end

-- Status only on dedicated Status URL — never spam Pet/Seed webhook channels
local function webhookStatus(extra)
	local url = cfg("Webhook Status URL", "")
	if url == "" then
		return
	end
	local note = cfg("Webhook Note", "FH")
	local discord = cfg("Discord ID", "")
	local ping = discord ~= "" and ("<@" .. discord .. "> ") or ""
	local multi = 1
	if Sell then
		multi = Sell.GetGlobalMultiplier()
	end
	local msg = string.format(
		"%s%s status money=%s plants=%d fruits=%d multi=%.2fx state=%s loop=%d err=%d %s",
		ping,
		note,
		tostring(getMoney()),
		(countPlants(getPlot())),
		countFruitTools(),
		multi,
		State.name,
		State.loop,
		State.errors,
		extra or ""
	)
	webhook(url, msg)
end

----------------------------------------------------------------
-- Sell module wiring
----------------------------------------------------------------
if Sell then
	State.sellCtx.eachTool = eachTool
	State.sellCtx.flags = Sell.ResolveFlags()
	State.sellCtx.onLog = function(tag, multi, reason)
		State.lastSellAt = now()
		State.stats.sells += 1
	end
	-- do NOT dump sell notices onto Webhook Seed URL (filter-only channel)
	State.sellCtx.webhook = nil
	Sell.WatchMultiplier(State.sellCtx.flags, function(newV, prevV)
		log("SellFruitMultiplier changed", prevV, "->", newV)
		-- multiplier notices only on Status URL (never Seed/Pet filter channels)
		if typeof(newV) == "number" and newV > 1.01 then
			local statusUrl = cfg("Webhook Status URL", "")
			if statusUrl ~= "" then
				local discord = cfg("Discord ID", "")
				local ping = discord ~= "" and ("<@" .. discord .. "> ") or ""
				webhook(
					statusUrl,
					ping .. cfg("Webhook Note", "FH") .. " SellFruitMultiplier **x" .. string.format("%.2f", newV) .. "** active"
				)
			end
		end
	end)
end

----------------------------------------------------------------
-- Actions: buy / plant / gear / harvest / shovel
----------------------------------------------------------------
local function buySeeds()
	if not cfg("Auto Buy Seed", true) then
		return
	end
	if Busy.shopping then
		return
	end
	if maybeWaitShopRestock() and now() < State.shopRestockWaitUntil then
		-- still buy gears/other; skip seed spam
		return
	end
	local limits = Config["Limit Buy Seed"]
	if type(limits) ~= "table" then
		return
	end

	withBusy("shopping", function()
		local money = getMoney()
		if money <= 0 then
			return -- never PurchaseSeed when broke (stops "Not enough Leaves" spam)
		end
		local stockFolder = ReplicatedStorage:FindFirstChild("StockValues")
		stockFolder = stockFolder and stockFolder:FindFirstChild("SeedShop")
		local items = stockFolder and stockFolder:FindFirstChild("Items")
		local bought = 0

		for seedName, entry in pairs(limits) do
			if type(seedName) == "string" then
				local maxBag = limitOf(entry)
				if maxBag and money >= minMoneyOf(entry) then
					local have = countSeedTools(seedName)
					local need = maxBag - have
					if need > 0 then
						local stockOk = true
						if items then
							local stock = stockNodeValue(items:FindFirstChild(seedName))
							if typeof(stock) == "number" and stock <= 0 then
								stockOk = false
							end
						end
						if stockOk then
							local price = getSeedPrice(seedName)
							-- require known affordable price — never Fire when cost unknown / unaffordable
							if typeof(price) ~= "number" or money < price then
								continue
							end
							local attempts = math.min(need, cfg("Buy Burst", 5))
							for _ = 1, attempts do
								money = getMoney()
								if money < price then
									break
								end
								local ok = retry(2, 0.08, function()
									Networking.SeedShop.PurchaseSeed:Fire(seedName)
								end)
								if ok then
									bought += 1
									State.stats.buys += 1
									money = getMoney()
								end
								task.wait(0.1)
							end
						end
					end
				end
			end
		end
		State.lastShopAt = now()
		if bought > 0 then
			log("bought seeds x", bought)
		end
	end)
end

local function buyGears()
	local gears = Config["Gears"]
	local buy = gears and gears["Buy Gear"]
	if type(buy) ~= "table" then
		return
	end
	withBusy("shopping", function()
		local money = getMoney()
		if money <= 0 then
			return
		end
		local stockFolder = ReplicatedStorage:FindFirstChild("StockValues")
		stockFolder = stockFolder and stockFolder:FindFirstChild("GearShop")
		local items = stockFolder and stockFolder:FindFirstChild("Items")

		for gearName, entry in pairs(buy) do
			if type(gearName) == "string" then
				local maxBag = limitOf(entry)
				if maxBag and money >= minMoneyOf(entry) then
					local have = countGearTools(gearName)
					if have < maxBag then
						local stockOk = true
						if items then
							local stock = stockNodeValue(items:FindFirstChild(gearName))
							if typeof(stock) == "number" and stock <= 0 then
								stockOk = false
							end
						end
						local price = GEAR_PRICE[gearName]
						-- never PurchaseGear without known affordable price
						if stockOk and typeof(price) == "number" and money >= price then
							retry(2, 0.1, function()
								Networking.GearShop.PurchaseGear:Fire(gearName)
							end)
							State.stats.buys += 1
							task.wait(0.12)
							money = getMoney()
						end
					end
				end
			end
		end
	end)
end

local _lastPlantSkipLog = 0
local _lastPlantSkipReason = ""

local function plantSkip(reason, ...)
	local t = now()
	if reason ~= _lastPlantSkipReason or (t - _lastPlantSkipLog) > 8 then
		_lastPlantSkipReason = reason
		_lastPlantSkipLog = t
		log("plant skip:", reason, ...)
	end
end

local function plantSeeds()
	if not cfg("Auto Plant", true) or not cfg("Auto Plant Seed", true) then
		plantSkip("Auto Plant disabled")
		return 0
	end
	if not Networking.Plant or not Networking.Plant.PlantSeed then
		plantSkip("PlantSeed remote missing")
		return 0
	end
	local plot = getPlot()
	if not plot then
		plantSkip("no plot PlotId=" .. tostring(LocalPlayer:GetAttribute("PlotId")))
		return 0
	end

	local planted = 0
	withBusy("planting", function()
		-- stand on plot so server distance / ownership checks pass
		teleportToPlot("plant stand")

		local limitTotal = cfg("Limit Auto Plant", 777)
		local limitPer = Config["Limit Plant Seed"] or {}
		local buyLimits = Config["Limit Buy Seed"] or {}
		local spacing = cfg("Plant Spacing", 1.5)
		local clusterMode = cfg("Plant Cluster Mode", "spiral")
		local slots = buildPlantSlotQueue(plot, spacing, clusterMode)
		if #slots == 0 then
			local areas = getPlantAreaParts(plot)
			plantSkip("no free slots", "areas=", #areas, "spacing=", spacing)
			return
		end

		local total, bySeed = countPlants(plot)
		if total >= limitTotal then
			plantSkip("plot full", total, "/", limitTotal)
			return
		end

		-- Own seeds in backpack/hotbar plantable unless blacklisted or mail-bound.
		-- Limit Plant Seed = per-seed plot cap when set; Limit Buy = buy/sort priority only.
		-- Items To Mail.Seed = skip plant (buy+mail only).
		local plantable = collectOwnedSeedTools()
		if #plantable == 0 then
			plantSkip("no seed tools in Backpack/Character")
			return
		end

		table.sort(plantable, function(a, b)
			local inBuyA = buyLimits[a.seed] ~= nil and 1 or 0
			local inBuyB = buyLimits[b.seed] ~= nil and 1 or 0
			if inBuyA ~= inBuyB then
				return inBuyA > inBuyB
			end
			local pa = getSeedPrice(a.seed) or 0
			local pb = getSeedPrice(b.seed) or 0
			return pa > pb
		end)

		local slotIdx = 1
		local maxBurst = cfg("Plant Burst", 40)
		local attempted = 0
		local skippedBlacklist, skippedMail, skippedCap, skippedEquip = 0, 0, 0, 0

		for _, entry in ipairs(plantable) do
			if total >= limitTotal or planted >= maxBurst then
				break
			end
			if slotIdx > #slots then
				log("plant slots exhausted after", planted, "plants")
				break
			end
			local seed = entry.seed
			local tool = entry.tool
			if not tool or not tool.Parent then
				continue
			end
			if isBlacklistedSeed(seed) then
				skippedBlacklist += 1
				continue
			end
			if isMailBoundSeed(seed) then
				skippedMail += 1
				continue
			end
			local perCap = limitPer[seed]
			if typeof(perCap) == "number" and (bySeed[seed] or 0) >= perCap then
				skippedCap += 1
				continue
			end

			-- plant up to stack Count (same tool), still bounded by burst/slots
			local stackLeft = entry.count or 1
			while stackLeft > 0 and planted < maxBurst and total < limitTotal and slotIdx <= #slots do
				if not equipTool(tool) then
					skippedEquip += 1
					break
				end
				-- Prefer SeedTool attr (server validates); fall back to resolved name
				local fireSeed = tool:GetAttribute("SeedTool")
				if type(fireSeed) ~= "string" or fireSeed == "" then
					fireSeed = seed
				end

				local fired = false
				local firedPos = nil
				local tries = 0
				while slotIdx <= #slots and not fired and tries < 3 do
					local pos = slots[slotIdx]
					slotIdx += 1
					tries += 1
					attempted += 1
					local ok = pcall(function()
						Networking.Plant.PlantSeed:Fire(pos, fireSeed, tool)
					end)
					if ok then
						fired = true
						firedPos = pos
					end
				end

				if fired then
					total += 1
					planted += 1
					stackLeft -= 1
					bySeed[seed] = (bySeed[seed] or 0) + 1
					State.stats.plants += 1
					task.wait(0.12)
					if firedPos then
						trackPlantedNear(plot, firedPos, seed)
					end

					if listHas(Config["Shovel Plant Once"], seed) then
						task.wait(0.12)
						local plants = plot:FindFirstChild("Plants")
						if plants then
							for _, plant in ipairs(plants:GetChildren()) do
								if plant:GetAttribute("SeedName") == seed then
									local shovel = findToolByAttr("Shovel")
									if shovel and equipTool(shovel) then
										pcall(function()
											Networking.Shovel.UseShovel:Fire(
												plant:GetAttribute("PlantId"),
												"",
												shovel:GetAttribute("Shovel"),
												shovel
											)
										end)
									end
									break
								end
							end
						end
						-- re-equip seed for next stack plant
						equipTool(tool)
					end
				else
					break
				end

				-- tool consumed / destroyed after last seed
				if not tool.Parent then
					break
				end
			end
		end

		State.lastPlantAt = now()
		log(
			string.format(
				"plant done planted=%d attempted=%d seeds=%d slots=%d total=%d skip(bl=%d mail=%d cap=%d equip=%d)",
				planted,
				attempted,
				#plantable,
				#slots,
				total,
				skippedBlacklist,
				skippedMail,
				skippedCap,
				skippedEquip
			)
		)
	end)
	return planted
end

local function useGears()
	local gears = Config["Gears"]
	local toUse = gears and gears["Gears To Use"]
	if type(toUse) ~= "table" then
		return
	end
	local plot = getPlot()
	if not plot then
		return
	end
	withBusy("gearing", function()
		-- Growing targets only (default). Skip empty / fully-ripe plots.
		local growingWater = getGearTargetPlants(plot, true)
		local growingAll = getGearTargetPlants(plot, false)
		if #growingWater == 0 and #growingAll == 0 then
			log("gear skip — no growing plants")
			return
		end
		local plotId = LocalPlayer:GetAttribute("PlotId") or 1
		if type(plotId) ~= "number" then
			plotId = tonumber(plotId) or 1
		end
		local tnow = now()
		local mailGear = Config["Items To Mail"] and Config["Items To Mail"]["Gear"] or {}
		local existingSpr = getExistingSprinklerPositions(plot)
		local wateredN, placedN = 0, 0
		local topSeed = growingAll[1] and growingAll[1].seed or "?"
		local topVal = growingAll[1] and growingAll[1].value or 0

		for _, gearName in ipairs(toUse) do
			-- Items To Mail.Gear = never auto-use / equip
			if mailGear[gearName] then
				continue
			end
			local cdUntil = GearCooldown[gearName] or 0
			if tnow < cdUntil then
				continue
			end
			local tool = findToolByAttr("WateringCan", gearName) or findToolByAttr("Sprinkler", gearName)
			if not tool then
				eachTool(function(t)
					if not tool and t.Name == gearName then
						tool = t
					end
				end)
			end
			if not tool or not equipTool(tool) then
				continue
			end

			local can = tool:GetAttribute("WateringCan")
			local spr = tool:GetAttribute("Sprinkler")

			if can then
				-- UseWateringCan(Vector3 aim, String canName, Instance tool)
				-- Only growing / non-WateringImmune plants; expensive-first order.
				local plants = growingWater
				if #plants == 0 then
					log("water skip — no growing (non-immune) plants", tostring(can))
					continue
				end
				local splash = WATER_SPLASH_BY_NAME[can] or WATER_SPLASH_BY_NAME[gearName] or 5
				local covered = {}
				local bursts = 0
				local maxBursts = 14
				for i, entry in ipairs(plants) do
					if covered[i] then
						continue
					end
					if bursts >= maxBursts then
						break
					end
					local p = entry.pos
					teleportNear(p, "water:" .. tostring(can), 3)
					task.wait(0.06)
					local aim = p - Vector3.new(0, 0.3, 0)
					retry(2, 0.08, function()
						Networking.WateringCan.UseWateringCan:Fire(aim, can, tool)
					end)
					bursts += 1
					wateredN += 1
					for j, other in ipairs(plants) do
						if xzDist(p, other.pos) <= splash then
							covered[j] = true
						end
					end
					-- client TryWater gate is 0.5s
					task.wait(0.55)
				end
				log(string.format(
					"watered clusters=%d splash=%.1f growing=%d top=%s($%s) can=%s",
					bursts,
					splash,
					#plants,
					tostring(topSeed),
					tostring(topVal),
					tostring(can)
				))
			elseif spr then
				-- PlaceSprinkler on densest/expensive growing cluster; skip ripe/empty areas.
				local plants = growingAll
				if #plants == 0 then
					log("sprinkler skip — no growing plants", tostring(spr))
					continue
				end
				local radius = SPRINKLER_RADIUS_BY_NAME[spr] or SPRINKLER_RADIUS_BY_NAME[gearName] or 20
				local spot, coverCount, score = pickSprinklerSpot(plants, existingSpr, radius)
				if spot and coverCount and coverCount > 0 then
					local tooClose = false
					for _, sp in ipairs(existingSpr) do
						if xzDist(spot, sp) < 1.05 then
							tooClose = true
							break
						end
					end
					if not tooClose then
						teleportNear(spot, "sprinkler:" .. tostring(spr), 4)
						task.wait(0.06)
						retry(2, 0.1, function()
							Networking.Place.PlaceSprinkler:Fire(spot, spr, tool, plotId)
						end)
						table.insert(existingSpr, spot)
						placedN += 1
						log(string.format(
							"placed sprinkler=%s cover~%d score=%.0f radius=%d growing=%d top=%s($%s) at=(%.1f,%.1f,%.1f)",
							tostring(spr),
							coverCount,
							score or 0,
							radius,
							#plants,
							tostring(topSeed),
							tostring(topVal),
							spot.X,
							spot.Y,
							spot.Z
						))
					end
				else
					log("sprinkler skip — no uncovered growing cluster", tostring(spr))
				end
			end

			GearCooldown[gearName] = now() + GEAR_CD
			task.wait(0.12)
		end

		State.lastGearAt = now()
		if wateredN > 0 or placedN > 0 then
			return wateredN + placedN
		end
	end)
end

local function harvestReady()
	local plot = getPlot()
	if not plot then
		return 0
	end
	local harvestedOut = 0
	withBusy("harvesting", function()
		local plants = plot:FindFirstChild("Plants")
		if not plants then
			return
		end
		local harvested = 0
		local shoveled = 0
		local maxBurst = cfg("Harvest Burst", 80)

		for _, plant in ipairs(plants:GetChildren()) do
			if harvested + shoveled >= maxBurst then
				break
			end
			if not plant:IsA("Model") then
				continue
			end
			local seedName = plant:GetAttribute("SeedName") or ""
			local plantId = plant:GetAttribute("PlantId")
			local plantMut = plant:GetAttribute("Mutation")
			local fruits = plant:FindFirstChild("Fruits")

			if fruits then
				for _, fruit in ipairs(fruits:GetChildren()) do
					if harvested + shoveled >= maxBurst then
						break
					end
					local fruitId = fruit:GetAttribute("FruitId")
					local age = fruit:GetAttribute("Age") or 0
					local maxAge = fruit:GetAttribute("MaxAge") or 0
					local mut = fruit:GetAttribute("Mutation") or plantMut
					local ready = fruit:GetAttribute("HarvestReady") == true
						or (maxAge > 0 and age >= maxAge)
						or CollectionService:HasTag(fruit, "HarvestPrompt")

					if not ready then
						for _, d in ipairs(fruit:GetDescendants()) do
							if CollectionService:HasTag(d, "HarvestPrompt") then
								ready = true
								break
							end
						end
					end

					if ready and plantId and fruitId ~= nil then
						if harvestAllowed(seedName, mut) then
							local ok = retry(2, 0.04, function()
								Networking.Garden.CollectFruit:Fire(tostring(plantId), tostring(fruitId))
							end)
							if ok then
								harvested += 1
								State.stats.harvests += 1
							end
							task.wait(0.04)
						elseif not shovelBlocked(seedName, mut) then
							local shovel = findToolByAttr("Shovel")
							if shovel and equipTool(shovel) then
								pcall(function()
									Networking.Shovel.UseShovel:Fire(
										tostring(plantId),
										tostring(fruitId),
										shovel:GetAttribute("Shovel"),
										shovel
									)
								end)
								shoveled += 1
								task.wait(0.08)
							end
						end
					end
				end
			end

			local maxAge = plant:GetAttribute("MaxAge") or 0
			local age = plant:GetAttribute("Age") or 0
			local readyPlant = plant:GetAttribute("PlantGrowthReady") == true and maxAge > 0 and age >= maxAge
			if readyPlant and plantId and (not fruits or #fruits:GetChildren() == 0) then
				if harvestAllowed(seedName, plantMut) then
					local ok = retry(2, 0.04, function()
						Networking.Garden.CollectFruit:Fire(tostring(plantId), "")
					end)
					if ok then
						harvested += 1
						State.stats.harvests += 1
					end
					task.wait(0.04)
				elseif not shovelBlocked(seedName, plantMut) then
					local shovel = findToolByAttr("Shovel")
					if shovel and equipTool(shovel) then
						pcall(function()
							Networking.Shovel.UseShovel:Fire(
								tostring(plantId),
								"",
								shovel:GetAttribute("Shovel"),
								shovel
							)
						end)
						shoveled += 1
					end
				end
			end
		end

		-- mutation-aware cleanup: shovel blacklisted-growth junk if configured
		if cfg("Shovel Dead Plants", true) then
			for _, plant in ipairs(plants:GetChildren()) do
				if not plant:IsA("Model") then
					continue
				end
				local seedName = plant:GetAttribute("SeedName") or ""
				local plantMut = plant:GetAttribute("Mutation")
				local dead = plant:GetAttribute("Dead") == true or plant:GetAttribute("IsDead") == true
				if dead and not shovelBlocked(seedName, plantMut) then
					local shovel = findToolByAttr("Shovel")
					local plantId = plant:GetAttribute("PlantId")
					if shovel and plantId and equipTool(shovel) then
						pcall(function()
							Networking.Shovel.UseShovel:Fire(
								tostring(plantId),
								"",
								shovel:GetAttribute("Shovel"),
								shovel
							)
						end)
						task.wait(0.08)
					end
				end
			end
		end

		State.lastHarvestAt = now()
		harvestedOut = harvested
		if harvested > 0 or shoveled > 0 then
			log("harvest", harvested, "shovel", shoveled)
		end
	end)
	return harvestedOut
end

local function favoriteFruits()
	local fav = Config["Favorite"]
	if type(fav) ~= "table" then
		return
	end
	local empty = true
	for _ in pairs(fav) do
		empty = false
		break
	end
	if empty then
		return
	end
	eachTool(function(t)
		if t:GetAttribute("HarvestedFruit") ~= true then
			return
		end
		local name = t:GetAttribute("FruitName") or t:GetAttribute("Seed")
		local mut = t:GetAttribute("Mutation")
		local want = false
		if listHas(fav, name) then
			want = true
		elseif type(fav[name]) == "table" and mut and listHas(fav[name], mut) then
			want = true
		end
		if want and t:GetAttribute("IsFavorite") ~= true then
			local id = t:GetAttribute("FruitUUID") or t:GetAttribute("Id") or t.Name
			pcall(function()
				Networking.Backpack.SetFruitFavorite:Fire(tostring(id), true)
			end)
		end
	end)
end

local function sellFruits()
	local fruitN = countFruitTools()
	if Sell then
		State.sellCtx.money = getMoney()
		State.sellCtx.getMoney = getMoney
		State.sellCtx.forceBroke = isBroke()
		-- Include multi-hold favorites in reported fruit count (countFruitTools skips IsFavorite)
		if State.sellCtx.eachTool then
			local c = Sell.ClassifyFruits(State.sellCtx.eachTool, Config, State.sellCtx.flags)
			fruitN = c.freeCount + #c.holding + #c.ready
		end
		local ok, reason = Sell.TrySellFruits(State.sellCtx)
		if ok then
			State.stats.sells += 1
			State.lastSellAt = now()
			return true, "sold", fruitN
		end
		return false, reason or "skip", fruitN
	end
	if not cfg("Auto Sell", true) then
		return false, "autosell_off", fruitN
	end
	if fruitN <= 0 then
		return false, "empty", 0
	end
	local sold = false
	withBusy("selling", function()
		local ok, res = pcall(function()
			return Networking.NPCS.SellAll:Fire()
		end)
		if ok then
			sold = true
			State.stats.sells += 1
			State.lastSellAt = now()
			log("SellAll fallback fruits~", fruitN, "res=", tostring(res))
		end
	end)
	return sold, sold and "sold" or "fail", fruitN
end

local function sellPets()
	local rules = Config["Sell Pets"]
	if type(rules) ~= "table" then
		return
	end
	local counts = countPetsByName()
	for petName, keep in pairs(rules) do
		local bucket = counts[canonicalPetName(petName) or petName] or counts[petName]
		if bucket and type(keep) == "table" then
			for _, info in ipairs(bucket.ids) do
				local var = info.variant
				local keepN = keep[var]
				if keepN ~= nil then
					local have = bucket[var] or 0
					if have > keepN then
						retry(2, 0.1, function()
							Networking.NPCS.SellPet:Fire(tostring(info.id))
						end)
						bucket[var] = have - 1
						task.wait(0.1)
					end
				end
			end
		end
	end
end

local function petOwnedInInventory(petName)
	if not petName then
		return false
	end
	local canon = canonicalPetName(petName) or petName
	local counts = countPetsByName()
	local bucket = counts[canon] or counts[petName]
	if bucket and (bucket.total or 0) > 0 then
		return true
	end
	local inv = getReplicaInventory()
	if inv and type(inv.Pets) == "table" then
		for _, pet in pairs(inv.Pets) do
			if type(pet) == "table" and pet.Name then
				if pet.Name == petName or canonicalPetName(pet.Name) == canon then
					return true
				end
			end
		end
	end
	local found = false
	eachTool(function(t)
		if found then
			return
		end
		local n = t:GetAttribute("PetName") or t:GetAttribute("Pet")
		if n == petName or (n and canonicalPetName(n) == canon) then
			found = true
			return
		end
		if t.Name == petName or t.Name:find(petName, 1, true) then
			found = true
		end
	end)
	return found
end

local function equipPets()
	local list = Config["Equip Pets"]
	if type(list) ~= "table" then
		return
	end
	local sorted = {}
	for _, row in ipairs(list) do
		if type(row) == "table" and row[1] then
			table.insert(sorted, row)
		end
	end
	table.sort(sorted, function(a, b)
		return (a[3] or 99) < (b[3] or 99)
	end)
	for _, row in ipairs(sorted) do
		local name = row[1]
		local want = row[2] or 1
		-- skip quietly if pet not in inventory (stops "No inventory folder for pet 'Squirrel'" spam)
		if not petOwnedInInventory(name) then
			continue
		end
		local counts = countPetsByName()
		local bucket = counts[canonicalPetName(name) or name] or counts[name]
		local owned = bucket and bucket.total or 1
		local equipped = 0
		if bucket then
			for _, info in ipairs(bucket.ids or {}) do
				if info.equipped then
					equipped += 1
				end
			end
		end
		local need = math.min(want, owned) - equipped
		if need <= 0 then
			continue
		end
		for _ = 1, need do
			pcall(function()
				Networking.Pets.RequestEquipByName:Fire(name)
			end)
			task.wait(0.12)
		end
	end
end

-- Pets are wild-tamed only (no PetShop Purchase remote). Studio:
-- WildPetRef Part → WildPetTame(Instance); visual BuyPrompt MaxDistance=12 Hold=1.
-- Config: number = total any variant; { Normal/Big/Huge/Rainbow = N } = that size only.
local function buyWildPets()
	local rules = Config["Buy Pets"]
	if type(rules) ~= "table" then
		return
	end
	local money = getMoney()
	local counts = countPetsByName()
	local wildRoot = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WildPetRef")
	if not wildRoot then
		return
	end
	local spawns = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WildPetSpawns")

	for _, ref in ipairs(wildRoot:GetChildren()) do
		if not ref:IsA("BasePart") then
			continue
		end
		local petName = ref:GetAttribute("PetName")
		if type(petName) ~= "string" or petName == "" then
			continue
		end
		local rule, ruleKey = findBuyPetRule(rules, petName)
		if rule == nil then
			continue
		end
		local ownerId = ref:GetAttribute("OwnerUserId")
		if ownerId == LocalPlayer.UserId then
			continue -- already claiming
		end
		local variant = wildPetVariant(ref)
		local canon = canonicalPetName(petName) or petName
		local bucket = counts[canon] or { Normal = 0, Big = 0, Huge = 0, Rainbow = 0, total = 0 }
		if not petRuleNeedsVariant(rule, bucket, variant) then
			continue
		end
		local price = ref:GetAttribute("Price")
		if type(price) ~= "number" then
			local data = PetData[canon] or PetData[petName]
			price = data and data.BasePrice or 0
		end
		local minM = type(rule) == "table" and minMoneyOf(rule) or 0
		if money < minM or (price > 0 and money < price) then
			log(
				"BuyPets skip money name=",
				petName,
				"var=",
				variant,
				"price=",
				tostring(price),
				"have=",
				tostring(money),
				"ruleKey=",
				tostring(ruleKey)
			)
			continue
		end

		log(
			"BuyPets tame name=",
			petName,
			"var=",
			variant,
			"price=",
			tostring(price),
			"owned=",
			string.format("N=%d B=%d H=%d R=%d tot=%d", bucket.Normal or 0, bucket.Big or 0, bucket.Huge or 0, bucket.Rainbow or 0, bucket.total or 0),
			"ruleKey=",
			tostring(ruleKey)
		)
		teleportNear(ref.Position, "wildpet:" .. petName .. ":" .. variant, 4)
		-- Prefer authoritative ref Part (SpawnPetController fires WildPetTame(ref)).
		retry(3, 0.12, function()
			Networking.Pets.WildPetTame:Fire(ref)
		end)
		-- Also trigger visual BuyPrompt if present (HoldDuration=1, MaxDistance=12).
		if spawns then
			local visualName = "WildPet_" .. petName .. "_" .. ref.Name
			local visual = spawns:FindFirstChild(visualName)
			if visual then
				for _, d in ipairs(visual:GetDescendants()) do
					if d:IsA("ProximityPrompt") and (d.Name == "BuyPrompt" or d.ActionText == "Buy") then
						pcall(function()
							if typeof(fireproximityprompt) == "function" then
								fireproximityprompt(d)
							else
								d:InputHoldBegin()
								task.wait(d.HoldDuration > 0 and d.HoldDuration or 0.05)
								d:InputHoldEnd()
							end
						end)
						break
					end
				end
			end
		end
		task.wait(0.45)
		money = getMoney()
		counts = countPetsByName()
		local after = counts[canon] or bucket
		log(
			"BuyPets after name=",
			petName,
			"var=",
			variant,
			"owned=",
			string.format("N=%d B=%d H=%d R=%d tot=%d", after.Normal or 0, after.Big or 0, after.Huge or 0, after.Rainbow or 0, after.total or 0)
		)
	end
end

local function expandAndSlots()
	withBusy("expanding", function()
		local money = getMoney()
		if isBroke(money) then
			-- never ExpandGarden / buy pet slots while broke
			return
		end
		if cfg("Expand Plot", true) then
			local target = cfg("Plot Expansions", 3)
			local inv = getReplicaInventory()
			local have = 0
			if inv and type(inv.Garden) == "table" then
				have = inv.Garden.Expansions or inv.Garden.ExpansionLevel or 0
			end
			local plot = getPlot()
			if plot then
				have = math.max(have, plot:GetAttribute("Expansions") or plot:GetAttribute("ExpansionLevel") or 0)
			end
			local tries = 0
			while have < target and tries < 3 do
				money = getMoney()
				if isBroke(money) then
					break
				end
				local ok = retry(2, 0.15, function()
					Networking.Actions.ExpandGarden:Fire()
				end)
				tries += 1
				task.wait(0.35)
				if plot then
					have = math.max(have, plot:GetAttribute("Expansions") or plot:GetAttribute("ExpansionLevel") or have + (ok and 1 or 0))
				elseif ok then
					have += 1
				end
			end
		end
		local slotTarget = cfg("Unlock Pet Slots", 6)
		if slotTarget and slotTarget > 0 and not isBroke() then
			for _ = 1, 3 do
				if isBroke() then
					break
				end
				pcall(function()
					Networking.Pets.RequestPurchasePetSlot:Fire()
				end)
				task.wait(0.18)
			end
		end
		State.lastExpandAt = now()
	end)
end

local function claimMail()
	if not cfg("Claim Mail", true) then
		return
	end
	withBusy("mailing", function()
		retry(2, 0.15, function()
			Networking.Mailbox.ClaimAll:Fire()
		end)
		task.wait(0.2)
		retry(2, 0.15, function()
			Networking.MagicMail.ClaimAll:Fire()
		end)
		State.lastMailAt = now()
	end)
end

local function pickMailTarget(toField)
	local list = toField
	if type(list) == "string" then
		return list
	end
	if type(list) == "table" and #list > 0 then
		return list[math.random(1, #list)]
	end
	local fallback = Config["Mail To Username"]
	if type(fallback) == "string" then
		return fallback
	end
	if type(fallback) == "table" and #fallback > 0 then
		return fallback[math.random(1, #fallback)]
	end
	return nil
end

local function mailItems()
	local mail = Config["Items To Mail"]
	if type(mail) ~= "table" then
		return
	end
	withBusy("mailing", function()
		if type(mail.Seed) == "table" then
			for seedName, rule in pairs(mail.Seed) do
				local amount = limitOf(rule) or (type(rule) == "number" and rule)
				local to = type(rule) == "table" and rule.To or nil
				if amount and countSeedTools(seedName) >= amount then
					local user = pickMailTarget(to)
					if user then
						local okSend, res = pcall(function()
							return Networking.MagicMail.Send:Fire(user, "Seeds", seedName, amount)
						end)
						if not okSend or res == false then
							mailboxSend(user, "Seeds", seedName, amount)
						end
						State.stats.mails += 1
						task.wait(0.35)
					end
				end
			end
		end

		if type(mail.Gear) == "table" then
			for gearName, rule in pairs(mail.Gear) do
				local amount = limitOf(rule) or (type(rule) == "number" and rule)
				local to = type(rule) == "table" and rule.To or nil
				if amount and countGearTools(gearName) >= amount then
					local user = pickMailTarget(to)
					local cat = gearMailCategory(gearName)
					if user then
						local okSend, res = pcall(function()
							return Networking.MagicMail.Send:Fire(user, cat, gearName, amount)
						end)
						if not okSend or res == false then
							mailboxSend(user, cat, gearName, amount)
						end
						State.stats.mails += 1
						task.wait(0.35)
					end
				end
			end
		end

		if type(mail.Pet) == "table" then
			local counts = countPetsByName()
			for petName, rule in pairs(mail.Pet) do
				if type(rule) == "table" then
					local bucket = counts[canonicalPetName(petName) or petName] or counts[petName]
					if bucket then
						local should = false
						for _, var in ipairs({ "Normal", "Big", "Huge", "Rainbow" }) do
							local need = rule[var]
							if need and (bucket[var] or 0) >= need then
								should = true
								break
							end
						end
						if should then
							local user = pickMailTarget(rule.To)
							if user then
								pcall(function()
									Networking.MagicMail.Send:Fire(user, "Pets", petName, 1)
								end)
								State.stats.mails += 1
								task.wait(0.4)
							end
						end
					end
				end
			end
		end

		if type(mail.Other) == "table" then
			for itemName, rule in pairs(mail.Other) do
				local amount = limitOf(rule) or (type(rule) == "number" and rule) or 1
				local to = type(rule) == "table" and rule.To or nil
				local user = pickMailTarget(to)
				local cat = "SeedPacks"
				if itemName:lower():find("egg") then
					cat = "Eggs"
				end
				if user then
					pcall(function()
						Networking.MagicMail.Send:Fire(user, cat, itemName, amount)
					end)
					State.stats.mails += 1
					task.wait(0.35)
				end
			end
		end
		State.lastMailAt = now()
	end)
end

local function fireTouchInterest(part)
	if not part or not part:IsA("BasePart") then
		return
	end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	pcall(function()
		if typeof(firetouchinterest) == "function" then
			firetouchinterest(hrp, part, 0)
			task.wait(0.05)
			firetouchinterest(hrp, part, 1)
		end
	end)
end

local function firePrompt(prompt)
	if not prompt or not prompt:IsA("ProximityPrompt") then
		return
	end
	pcall(function()
		if typeof(fireproximityprompt) == "function" then
			fireproximityprompt(prompt)
		else
			prompt:InputHoldBegin()
			task.wait(prompt.HoldDuration > 0 and prompt.HoldDuration or 0.05)
			prompt:InputHoldEnd()
		end
	end)
end

local function spawnKindLabel(inst)
	if not inst then
		return "pack"
	end
	if inst:GetAttribute("RainbowSeed") == true then
		return "rainbow"
	end
	if inst:GetAttribute("GoldSeed") == true then
		return "gold"
	end
	if inst:GetAttribute("MegaSeed") == true then
		return "mega"
	end
	local pack = inst:GetAttribute("SeedPack")
	if type(pack) == "string" and pack ~= "" then
		return "pack:" .. pack
	end
	return "pack"
end

-- Active world spawn = server Part with Gold/Rainbow/Mega/SeedPack attrs.
-- Empty folder Parts without attrs = NOT claimable.
local function isClaimableWorldSpawn(inst)
	if not inst or not inst.Parent then
		return false
	end
	if inst:GetAttribute("RainbowSeed") == true then
		return true
	end
	if inst:GetAttribute("GoldSeed") == true then
		return true
	end
	if inst:GetAttribute("MegaSeed") == true then
		return true
	end
	local pack = inst:GetAttribute("SeedPack")
	return type(pack) == "string" and pack ~= ""
end

-- Attrs often arrive AFTER ChildAdded (SpawnSeedPackController waits ~1s).
local function waitForClaimableAttrs(inst, timeoutSec)
	if not inst then
		return false
	end
	if isClaimableWorldSpawn(inst) then
		return true
	end
	local deadline = os.clock() + (timeoutSec or 1.25)
	while inst.Parent and os.clock() < deadline do
		task.wait(0.05)
		if isClaimableWorldSpawn(inst) then
			return true
		end
	end
	return isClaimableWorldSpawn(inst)
end

local function resolveWorldSeedClickId(inst)
	if not inst then
		return nil
	end
	if type(inst.Name) == "string" and inst.Name ~= "" and inst.Name ~= "Part" and inst.Name ~= "Model" then
		return inst.Name
	end
	local id = inst:GetAttribute("PackId")
		or inst:GetAttribute("Id")
		or inst:GetAttribute("UID")
		or inst:GetAttribute("GUID")
		or inst:GetAttribute("SpawnId")
	if type(id) == "string" and id ~= "" then
		return id
	end
	if type(id) == "number" then
		return tostring(id)
	end
	return nil
end

local function seedInvSnapshot()
	return {
		Gold = countSeedTools("Gold"),
		Rainbow = countSeedTools("Rainbow"),
		Mega = countSeedTools("Mega"),
	}
end

local function formatSeedInv(snap)
	return string.format("inv Gold=%d Rainbow=%d Mega=%d", snap.Gold or 0, snap.Rainbow or 0, snap.Mega or 0)
end

local function spawnPartPosition(inst)
	if not inst then
		return nil
	end
	if inst:IsA("BasePart") then
		return inst.Position
	end
	if inst:IsA("Model") then
		local ok, pivot = pcall(function()
			return inst:GetPivot().Position
		end)
		if ok and typeof(pivot) == "Vector3" then
			return pivot
		end
		local part = inst:FindFirstChildWhichIsA("BasePart", true)
		return part and part.Position or nil
	end
	return nil
end

-- Studio findings:
-- - SpawnSeedPackController only renders client visuals from SeedPackSpawnServerLocations attrs.
-- - ClickPack (ClickSeedPack, String) is used by SeedPackEffect during OpenSeedPack animation
--   (session id) — NOT proven as world-claim. No client claim remote for world Gold/Rainbow.
-- - SeedPackSpawn has FX/Announce/Claimed (server→client only).
-- → World claim = teleport near server Part + touch; ClickPack kept as secondary attempt.
local _seedClaimBusy = {}
local _seedClaimHooked = false

local function claimWorldSeedSpawn(inst, counts)
	if not inst or not inst.Parent then
		return false
	end
	local id = resolveWorldSeedClickId(inst) or tostring(inst)
	if _seedClaimBusy[id] then
		return false
	end
	_seedClaimBusy[id] = true
	local okClaim, err = pcall(function()
		if not waitForClaimableAttrs(inst, 1.25) then
			log("seed spawn skip (no attrs yet) id=", tostring(id), "name=", inst.Name)
			return
		end
		if not isClaimableWorldSpawn(inst) then
			return
		end
		local kind = spawnKindLabel(inst)
		local attrs = {
			GoldSeed = tostring(inst:GetAttribute("GoldSeed")),
			RainbowSeed = tostring(inst:GetAttribute("RainbowSeed")),
			MegaSeed = tostring(inst:GetAttribute("MegaSeed")),
			SeedPack = tostring(inst:GetAttribute("SeedPack")),
		}
		local before = seedInvSnapshot()
		log(
			"seed spawn FOUND id=",
			tostring(id),
			"kind=",
			kind,
			"attrs=",
			string.format(
				"Gold=%s Rainbow=%s Mega=%s Pack=%s",
				attrs.GoldSeed,
				attrs.RainbowSeed,
				attrs.MegaSeed,
				attrs.SeedPack
			),
			formatSeedInv(before)
		)
		if counts then
			if kind == "rainbow" then
				counts.rainbow += 1
			elseif kind == "gold" then
				counts.gold += 1
			elseif kind == "mega" then
				counts.mega += 1
			else
				counts.pack += 1
			end
		end

		local part = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart", true)
		if part then
			pcall(function()
				part.CanTouch = true
				part.CanQuery = true
			end)
		end
		local pos = spawnPartPosition(inst)
		if pos then
			teleportNear(pos, "seed:" .. kind, 2)
		end
		if part then
			for _ = 1, 4 do
				fireTouchInterest(part)
				task.wait(0.08)
			end
		end
		-- Secondary: some builds may accept spawn Name on ClickPack.
		local clickOk, clickErr = pcall(function()
			if id and id ~= "" then
				Networking.SeedPack.ClickPack:Fire(tostring(id))
			end
		end)
		if counts then
			counts.clicked += 1
		end
		log(
			"seed ClickPack id=",
			tostring(id),
			"ok=",
			tostring(clickOk),
			"err=",
			tostring(clickErr),
			"kind=",
			kind
		)

		-- Wait for server to despawn claimed Part and/or grant seed.
		local granted = false
		for _ = 1, 12 do
			task.wait(0.12)
			if not inst.Parent then
				granted = true
				break
			end
			local after = seedInvSnapshot()
			if after.Gold > before.Gold or after.Rainbow > before.Rainbow or after.Mega > before.Mega then
				granted = true
				break
			end
		end
		local after = seedInvSnapshot()
		log(
			"seed claim result id=",
			tostring(id),
			"kind=",
			kind,
			"despawned=",
			tostring(not inst.Parent),
			"delta=",
			tostring(granted),
			formatSeedInv(after)
		)
	end)
	_seedClaimBusy[id] = nil
	if not okClaim then
		log("seed claim err id=", tostring(id), err)
	end
	return okClaim
end

local function ensureSeedSpawnHooks()
	if _seedClaimHooked then
		return
	end
	_seedClaimHooked = true
	pcall(function()
		Networking.SeedPackSpawn.Claimed.OnClientEvent:Connect(function(playerName, packName)
			log("seed Claimed event player=", tostring(playerName), "pack=", tostring(packName), formatSeedInv(seedInvSnapshot()))
		end)
	end)
	task.spawn(function()
		local map = workspace:WaitForChild("Map", 30)
		if not map then
			return
		end
		local function bindFolder(folder)
			if not folder then
				return
			end
			folder.ChildAdded:Connect(function(child)
				task.spawn(function()
					task.wait(0.05)
					if child and child.Parent then
						claimWorldSeedSpawn(child, nil)
					end
				end)
			end)
		end
		local existing = map:FindFirstChild("SeedPackSpawnServerLocations")
		if existing then
			bindFolder(existing)
		end
		map.ChildAdded:Connect(function(child)
			if child.Name == "SeedPackSpawnServerLocations" then
				log("seed server folder reappeared — Opt did not permanently destroy it")
				bindFolder(child)
			end
		end)
	end)
end

local function collectSeedPacks()
	if not cfg("Auto Collect Seed Packs", true) then
		return 0
	end
	ensureSeedSpawnHooks()
	local counts = { rainbow = 0, gold = 0, mega = 0, pack = 0, dropped = 0, opened = 0, clicked = 0 }
	local map = workspace:FindFirstChild("Map")
	local serverFolder = map and map:FindFirstChild("SeedPackSpawnServerLocations")

	if not serverFolder then
		log("seed server folder MISSING (Map.SeedPackSpawnServerLocations) — cannot claim world Gold/Rainbow")
	else
		local children = serverFolder:GetChildren()
		if #children == 0 then
			-- quiet when empty (normal)
		else
			log("seed server folder children=", tostring(#children))
		end
		for _, child in ipairs(children) do
			if child:IsA("BasePart") or child:IsA("Model") then
				if isClaimableWorldSpawn(child) then
					claimWorldSeedSpawn(child, counts)
				elseif child:GetAttribute("GoldSeed") ~= nil
					or child:GetAttribute("RainbowSeed") ~= nil
					or child:GetAttribute("MegaSeed") ~= nil
					or child:GetAttribute("SeedPack") ~= nil
				then
					-- attrs present but not truthy yet — wait path
					claimWorldSeedSpawn(child, counts)
				end
			end
		end
	end

	-- DroppedItems (bird / ground drops): prompt + touch; tele if special seed
	local dropped = workspace:FindFirstChild("DroppedItems")
	if dropped then
		for _, item in ipairs(dropped:GetChildren()) do
			local cat = item:GetAttribute("ItemCategory")
			local special = item:GetAttribute("RainbowSeed") == true
				or item:GetAttribute("GoldSeed") == true
				or item:GetAttribute("MegaSeed") == true
			local isSeedish = special or cat == "Seeds" or cat == "SeedPacks"
			if isSeedish then
				counts.dropped += 1
				local part = item:FindFirstChildWhichIsA("BasePart", true) or (item:IsA("BasePart") and item)
				if special and part then
					teleportNear(part.Position, "dropped-seed", 2)
				end
				for _, d in ipairs(item:GetDescendants()) do
					if d:IsA("ProximityPrompt") then
						firePrompt(d)
					end
				end
				if part then
					fireTouchInterest(part)
				end
			end
		end
	end

	-- Open backpack seed packs (OpenSeedPack) — inventory tools only
	eachTool(function(t)
		local packName = t:GetAttribute("SeedPack")
		if type(packName) == "string" and packName ~= "" or (t.Name and t.Name:find("Seed Pack")) then
			local fireArg = type(packName) == "string" and packName ~= "" and packName or t.Name
			retry(3, 0.1, function()
				Networking.SeedPack.OpenSeedPack:Fire(tostring(fireArg))
			end)
			counts.opened += 1
			task.wait(0.12)
		end
	end)

	local total = counts.rainbow + counts.gold + counts.mega + counts.pack + counts.dropped
	if total > 0 or counts.opened > 0 then
		log(
			string.format(
				"seed pickup rainbow=%d gold=%d mega=%d pack=%d dropped=%d clicked=%d opened=%d | %s",
				counts.rainbow,
				counts.gold,
				counts.mega,
				counts.pack,
				counts.dropped,
				counts.clicked,
				counts.opened,
				formatSeedInv(seedInvSnapshot())
			)
		)
	end
	return total + counts.opened
end

local function doubleOrNothing()
	if not cfg("Auto Double Or Nothing", false) then
		return
	end
	local target = cfg("Double Or Nothing Target Wins", 1)
	for _ = 1, target do
		local ok = pcall(function()
			Networking.NPCS.DoubleOrNothing:Fire()
		end)
		if not ok then
			break
		end
		task.wait(0.5)
	end
	pcall(function()
		Networking.NPCS.CashOutDoubleOrNothing:Fire()
	end)
end

----------------------------------------------------------------
-- Anti-stuck
----------------------------------------------------------------
local function antiStuck()
	if not cfg("Anti Stuck", true) then
		return
	end
	-- keep platform under plot / feet (no per-frame TP)
	ensureAntiVoidPlatform()

	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then
		if now() - State.lastAntiStuckAt < 8 then
			return
		end
		State.lastAntiStuckAt = now()
		pcall(function()
			LocalPlayer:LoadCharacter()
		end)
		return
	end

	local pos = hrp.Position
	-- catastrophic void only (platform handles normal freefall); default -100
	local voidY = cfg("Void Rescue Y", -100)
	if pos.Y < voidY then
		log("catastrophic void rescue y=", string.format("%.1f", pos.Y))
		ensureAntiVoidPlatform()
		teleportToPlot("void rescue")
		State.lastAntiStuckAt = now()
		State.lastPos = nil
		State.posStuckSince = nil
		return
	end

	if now() - State.lastAntiStuckAt < 8 then
		return
	end
	if hum.Health <= 0 then
		State.lastAntiStuckAt = now()
		task.wait(1)
		ensureAntiVoidPlatform()
		teleportToPlot("death respawn")
		return
	end
	if State.lastPos then
		local dist = (pos - State.lastPos).Magnitude
		if dist < 0.8 then
			if not State.posStuckSince then
				State.posStuckSince = now()
			elseif now() - State.posStuckSince > cfg("Anti Stuck Seconds", 45) then
				ensureAntiVoidPlatform()
				teleportToPlot("anti-stuck idle")
				State.posStuckSince = nil
				State.stuckChecks += 1
				State.lastAntiStuckAt = now()
			end
		else
			State.posStuckSince = nil
		end
	end
	State.lastPos = pos
end

----------------------------------------------------------------
-- Webhook watch — STRICT filters only (no spam for other pets/seeds)
-- Pet: name ∈ Webhook Pet Name AND rarity ∈ Webhook Pet Rarity
--      (if one list empty, apply the non-empty filter; if both empty → send none)
-- Seed: name ∈ Webhook Seed Name only (never match mutation alone)
----------------------------------------------------------------
local seenPets, seenSeeds = {}, {}
local function webhookWatch()
	local petUrl = cfg("Webhook Pet URL", "")
	local seedUrl = cfg("Webhook Seed URL", "")
	local note = cfg("Webhook Note", "")
	local discord = cfg("Discord ID", "")
	local ping = discord ~= "" and ("<@" .. discord .. "> ") or ""
	local petNames = cfg("Webhook Pet Name", {})
	local petRar = cfg("Webhook Pet Rarity", {})
	local seedNames = cfg("Webhook Seed Name", {})
	local nameFilterOn = webhookFilterActive(petNames)
	local rarFilterOn = webhookFilterActive(petRar)
	local seedFilterOn = webhookFilterActive(seedNames)

	if petUrl ~= "" and (nameFilterOn or rarFilterOn) then
		local counts = countPetsByName()
		for name, bucket in pairs(counts) do
			for _, info in ipairs(bucket.ids or {}) do
				local key = name .. ":" .. tostring(info.id)
				if not seenPets[key] then
					local data = PetData[name]
					local display = data and data.DisplayName or name
					local rar = data and data.Rarity
					local nameOk = (not nameFilterOn)
						or listHas(petNames, name)
						or listHas(petNames, display)
					local rarOk = (not rarFilterOn) or listHas(petRar, rar)
					if nameOk and rarOk then
						seenPets[key] = true
						webhook(
							petUrl,
							ping
								.. note
								.. " pet: **"
								.. name
								.. "** ("
								.. tostring(rar)
								.. ") var="
								.. tostring(info.variant)
						)
					end
				end
			end
		end
	end

	if seedUrl ~= "" and seedFilterOn then
		eachTool(function(t)
			-- fruit tools: match fruit/seed NAME only (not mutation)
			local fn = t:GetAttribute("FruitName") or t:GetAttribute("Seed") or t:GetAttribute("Fruit")
			local seedTool = resolveSeedName(t)
			local mut = t:GetAttribute("Mutation")
			local candidates = {}
			if type(fn) == "string" and fn ~= "" then
				candidates[#candidates + 1] = fn
			end
			if type(seedTool) == "string" and seedTool ~= "" then
				candidates[#candidates + 1] = seedTool
			end
			local matched = nil
			for _, c in ipairs(candidates) do
				if listHas(seedNames, c) then
					matched = c
					break
				end
			end
			if matched then
				local key = matched
					.. ":"
					.. tostring(mut)
					.. ":"
					.. tostring(t:GetAttribute("FruitUUID") or t:GetAttribute("Id") or t.Name)
				if not seenSeeds[key] then
					seenSeeds[key] = true
					webhook(
						seedUrl,
						ping .. note .. " seed: **" .. matched .. "** mut=" .. tostring(mut)
					)
				end
			end
		end)
	end

	-- gear webhook only when Gear Name filter is non-empty
	local gearUrl = cfg("Webhook Gear URL", "")
	local gearNames = cfg("Webhook Gear Name", {})
	if gearUrl ~= "" and webhookFilterActive(gearNames) then
		for _, gname in ipairs(gearNames) do
			local n = countGearTools(gname)
			local sk = "gear:" .. gname
			if n > 0 and not seenPets[sk] then
				seenPets[sk] = true
				webhook(gearUrl, ping .. note .. " gear: **" .. gname .. "** x" .. n)
			end
		end
	end
end

----------------------------------------------------------------
-- Boot
----------------------------------------------------------------
local function waitReady()
	local deadline = tick() + 60
	while tick() < deadline do
		if LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer:GetAttribute("PlotId") then
			local plot = getPlot()
			if plot then
				return true
			end
		end
		task.wait(0.25)
	end
	return getPlot() ~= nil
end

setState("BOOT")
do
	local seedN = 0
	for _ in pairs(SeedDataByName) do
		seedN += 1
	end
	log(
		"boot world=",
		cfg("World", "?"),
		"money=",
		getMoney(),
		"currency=",
		currencyName(),
		"seedData=",
		seedN,
		"plantRemote=",
		tostring(Networking.Plant and Networking.Plant.PlantSeed ~= nil),
		"opt=",
		tostring(cfg("EnableFPSOpt", true)),
		"waitMulti=",
		tostring(cfg("Wait SellFruitMultiplier", cfg("Wait Sell Multiplier", true)))
	)
end

if not waitReady() then
	log("plot not ready — still starting loop")
end

-- FPS / map opt (safe for own farm — waits PlotId, never kills Baseplate / own plot)
local stopOpt = Opt.Run(Config, LocalPlayer)

pcall(function()
	Networking.Garden.RequestGardens:Fire()
end)
teleportToPlot("boot stand")
ensureAntiVoidPlatform()

-- catastrophic void only after platform placed
do
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp and hrp.Position.Y < cfg("Void Rescue Y", -100) then
		ensureAntiVoidPlatform()
		teleportToPlot("boot void rescue")
	end
end

-- continuous world seed pickup (Gold/Rainbow/Mega/packs) — denser than main loop
ensureSeedSpawnHooks()
task.spawn(function()
	while true do
		local ok, err = pcall(collectSeedPacks)
		if not ok then
			log("seed pickup err:", err)
		end
		task.wait(0.85)
	end
end)

if Sell then
	State.sellCtx.getMoney = getMoney
	local m = Sell.GetGlobalMultiplier(State.sellCtx.flags)
	local pm = Sell.GetPriceMultipliers(State.sellCtx.flags)
	local hold = Sell.GetHoldMap(Config)
	log("SellFruitMultiplier (GlobalMultiplier) =", string.format("%.2fx", m))
	if next(pm) then
		local parts = {}
		for k, v in pairs(pm) do
			table.insert(parts, string.format("%s=%.2f", k, v))
		end
		table.sort(parts)
		log("PriceMultipliers:", table.concat(parts, ", "))
	end
	if hold then
		local parts = {}
		for k, v in pairs(hold) do
			table.insert(parts, string.format("%s>=%.2fx", k, v))
		end
		table.sort(parts)
		log("Sell Fruit Multiplier hold:", table.concat(parts, ", "), "maxWait=", cfg("Sell Multiplier Max Wait", 300))
	end
end

setState("READY")

----------------------------------------------------------------
-- Main state machine loop
----------------------------------------------------------------
--[[
  Phases per tick (busy-flag gated, order matters):
    When broke (Leaves <= Sell Force When Broke):
      antiStuck → claim mail → harvest → sell → (buy only if affordable)
    Otherwise:
      1. antiStuck / expand
      2. shop (seeds/gears) — gated by price/affordability
      3. plant / gear use
      4. harvest / favorite
      5. seed packs / wild pets / equip (skip missing pets)
      6. mail / claim
      7. sell pets / sell fruits (multi-aware; force when broke)
      8. periodic: DON, webhook, status
]]

local LOOP_WAIT = cfg("Loop Wait", 1.1)
local IDLE_EXTRA = 0.4

while true do
	State.loop += 1
	local didWork = false
	local ok, err = pcall(function()
		antiStuck()

		local money = getMoney()
		local broke = isBroke(money)

		local function step(name, fn)
			local result = fn()
			local worked = result == true or (typeof(result) == "number" and result > 0)
			if worked then
				didWork = true
				setState(name, "work")
			end
			return result
		end

		if broke then
			-- poor path: harvest → sell → plant owned seeds (buy only if affordable)
			if State.loop % 2 == 0 then
				claimMail()
			end

			step("HARVEST", harvestReady)
			favoriteFruits()

			do
				local sold, reason, fruitN = sellFruits()
				if sold then
					didWork = true
					setState("SELL", "sold~" .. tostring(fruitN))
				elseif fruitN and fruitN > 0 and reason and reason ~= "waiting_multi" and reason ~= "holding_fruit_multi" then
					setState("SELL", tostring(reason))
				elseif reason == "holding_fruit_multi" then
					setState("SELL", "holding_multi")
				end
			end
			if State.loop % 3 == 0 then
				sellPets()
			end

			money = getMoney()
			if money > 0 then
				local buysBefore = State.stats.buys
				buySeeds()
				buyGears()
				if State.stats.buys > buysBefore then
					didWork = true
					setState("SHOP", "bought")
				end
			end

			step("PLANT", plantSeeds)

			if State.loop % 2 == 0 then
				useGears()
			end
			if State.loop % 5 == 0 then
				equipPets()
			end
			-- seed packs collected by background loop; light nudge here
			if State.loop % 2 == 0 then
				step("SEEDPACK", collectSeedPacks)
			end
		else
			if State.loop % 4 == 1 then
				expandAndSlots()
			end

			do
				local buysBefore = State.stats.buys
				buySeeds()
				buyGears()
				if State.stats.buys > buysBefore then
					didWork = true
					setState("SHOP", "bought")
				end
			end

			step("PLANT", plantSeeds)

			if State.loop % 2 == 0 then
				useGears()
			end

			step("HARVEST", harvestReady)
			favoriteFruits()

			if State.loop % 2 == 0 then
				step("SEEDPACK", collectSeedPacks)
			end
			if State.loop % 2 == 0 then
				step("BUYPETS", buyWildPets)
			end
			if State.loop % 5 == 0 then
				equipPets()
			end

			if State.loop % 4 == 0 then
				mailItems()
				claimMail()
			end

			if State.loop % 3 == 0 then
				sellPets()
			end
			do
				local sold, reason, fruitN = sellFruits()
				if sold then
					didWork = true
					setState("SELL", "sold~" .. tostring(fruitN))
				elseif fruitN and fruitN > 0 and reason and reason ~= "waiting_multi" and reason ~= "holding_fruit_multi" then
					setState("SELL", tostring(reason))
				elseif reason == "holding_fruit_multi" then
					setState("SELL", "holding_multi")
				end
			end
		end

		if State.loop % 5 == 0 then
			doubleOrNothing()
			webhookWatch()
		end

		if State.loop % 60 == 0 then
			webhookStatus("heartbeat")
			local multi = Sell and Sell.GetGlobalMultiplier(State.sellCtx.flags) or 1
			log(
				string.format(
					"heartbeat money=%s broke=%s plants=%d fruits=%d seeds~=%d multi=%.2fx sells=%d harvests=%d plants_stat=%d errs=%d",
					tostring(getMoney()),
					tostring(isBroke()),
					(countPlants(getPlot())),
					countFruitTools(),
					#collectOwnedSeedTools(),
					multi,
					State.stats.sells,
					State.stats.harvests,
					State.stats.plants,
					State.errors
				)
			)
			pcall(function()
				Networking.Garden.RequestGardens:Fire()
			end)
		end

		-- idle marker only when nothing happened (no spam on every no-op phase)
		if not didWork then
			State.name = "FARMING"
		end
	end)

	if not ok then
		State.errors += 1
		State.lastError = err
		log("loop error:", err)
		setState("RECOVER", tostring(err))
		task.wait(0.5)
		teleportToPlot("loop error recover")
	end

	task.wait(LOOP_WAIT + (didWork and 0 or IDLE_EXTRA))
end

-- unreachable; keep reference so opt stopper isn't GC'd early in some executors
env.FH_STOP_OPT = stopOpt
