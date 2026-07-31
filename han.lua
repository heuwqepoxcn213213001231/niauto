
local G = (type(getgenv) == "function" and getgenv()) or _G

    if G.MM2KaitunV2 and type(G.MM2KaitunV2) == "table" and type(G.MM2KaitunV2.Destroy) == "function" then
        pcall(function()
            G.MM2KaitunV2:Destroy("reload")
        end)
        G.MM2KaitunV2 = nil
    end
    
    
    local DEFAULT_CONFIG = {
        Enabled = true,
        AutoStart = true,           
        CoinType = "Any",         
        TweenSpeed = 28,           
        TweenSpeedMax = 60,         
        TweenMinTime = 0.1,
        TweenMaxTime = 6,
        CoinBelowOffset = 2.5,     
        CollectTouchDelay = 0.05,
        CollectSettleDelay = 0.08,  
        CoinCycleDelay = 0.02,
        ResetWhenFull = true,      
        TouchInterestWait = 8,      
        RoundReadyTimeout = 45,
        RoundMaxDuration = 400,     
    
    
        OptimizationMode = "best",
        StripLobby = true,
        StripMap = true,            
        StripMapDecor = true,
        StripCoinVisuals = true,   
        MuteSounds = true,
        LowRendering = true,        
        Disable3DRender = false,    
                                    
        HideOtherPlayers = true,
        MinimizeLocalCharacter = true,
    
        InstantOpt = true,       
        BlockMapLoad = true,       
                               
                                    
                                    
                                   
        FilterIncomingInstances = true, 
                                  
        FilterRemoteHandlers = true, 
                                   
                                  
        EssentialRemotes = {      
            "GetCoin", "CoinCollected", "CoinsStarted", "RoundStart", "LoadingMap",
            "VictoryScreen", "RoundEndFade", "TeleportToPart", "PlayerDataChanged",
            "GetCurrentPlayerData", "Fade", "GameOver", "SpecialRound",
            "ShowRoleSelect", "ShowRoleSelectNew", "ShowTeammates", "GiveWeapon",
            "ChangeLastDevice", "LoadedCompletely", "GetData2", "GetSyncData",
            "ChangeProfileData", "ChangeInventoryItem",
            "LoadingUpdate", "ClientLoaded",
            "EventQuestProgressed",
        },
        DowngradeTechnology = true,
        FreezeCharacter = true,    
        DisableHeavyScripts = true,
        StripPlayerGui = true,
        KeepGameHud = true,
        BatchDestroyPerFrame = 30,  
    
        LockFps = true,
        FpsCap = 30,              
        AntiAfk = true,
        AutoRejoin = true,         
        RejoinScriptUrl = "",      
    
        AutoSelectDevice = true,    
        AutoDevice = "Phone",       
        WaitForGameReady = true,
        GameReadyTimeout = 120,
    
    
        ShowHud = true,
        HudUpdateInterval = 1,
        VoidRescueBelowY = 15,      
        AutoCreatePad = true,      
        PadSize = 128,
        FixFallenPartsHeight = true,
        CleanupWaitTimeout = 8,

        EnableSummer2026 = true,
        Summer2026Interval = 15,
        MinShellsForBox = 0,
        Summer2026EventTitle = "Summer2026",
        Summer2026KeyCurrency = "SummerKey2026",
        Summer2026BoxId = "Summer2026Box",
        Summer2026ClaimBattlePass = true,
        Summer2026AutoUnbox = true,
        EnableCoinBoxAutoUnbox = true,
        CoinBoxId = "MysteryBox2",
        CoinBoxCurrency = "Coins",
        CoinBoxCategory = "MysteryBox",
        CoinBoxMinCoins = 0,
        CoinBoxReserveCoins = 0,
        AccountOpsAutoswapMaxShells = 120,
        AccountOpsBaseUrl = "https://accountops.org",
        AccountOpsApiKey = "",         
        AccountOpsAutoswapDelaySeconds = 60,
        AccountOpsAutoswapOnDailyComplete = true,
        AccountOpsAutoswapOption = 2,
        AccountOpsAutoswapGodlyOption = 3,
        AccountOpsAutoswapMinLevel = 10,
        AccountOpsAutoswapIntervalSeconds = 60,
        DiscordWebhookGodly = "",
        DiscordWebhookGodlyEnabled = true,

        Debug = false,
    }
    
    local Config = {}
    do
        local userCfg = type(G.MM2KaitunV2Config) == "table" and G.MM2KaitunV2Config or {}
        for k, v in DEFAULT_CONFIG do
            if userCfg[k] ~= nil then
                Config[k] = userCfg[k]
            else
                Config[k] = v
            end
        end
        if Config.OptimizationMode == "off" then
            Config.StripLobby = false
            Config.StripMap = false
            Config.StripMapDecor = false
            Config.StripCoinVisuals = false
            Config.MuteSounds = false
            Config.LowRendering = false
            Config.HideOtherPlayers = false
            Config.DisableHeavyScripts = false
            Config.StripPlayerGui = false
            Config.InstantOpt = false
            Config.BlockMapLoad = false
            Config.FilterIncomingInstances = false
            Config.FilterRemoteHandlers = false
        elseif Config.OptimizationMode == "light" then
            Config.StripLobby = false
            Config.StripMap = false
            Config.StripMapDecor = false
            Config.DisableHeavyScripts = false
            Config.StripPlayerGui = false
            Config.BlockMapLoad = false
        end
    end
    
    
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Lighting = game:GetService("Lighting")
    local SoundService = game:GetService("SoundService")
    local StarterGui = game:GetService("StarterGui")
    local UserInputService = game:GetService("UserInputService")
    local GuiService = game:GetService("GuiService")
    local VirtualUser = game:GetService("VirtualUser")
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    
    local player = Players.LocalPlayer
    
    local Exec = {
        fireTouch = (type(firetouchinterest) == "function" and firetouchinterest) or nil,
        getHui = (type(gethui) == "function" and gethui) or nil,
        queueTeleport = nil,
        setFps = nil,
        getConnections = nil,
        setHidden = nil,
        identify = "",
    }
    do
        pcall(function()
            Exec.queueTeleport = (type(queue_on_teleport) == "function" and queue_on_teleport)
                or (type(syn) == "table" and type(syn.queue_on_teleport) == "function" and syn.queue_on_teleport)
                or (type(fluxus) == "table" and type(fluxus.queue_on_teleport) == "function" and fluxus.queue_on_teleport)
                or nil
        end)
        pcall(function()
            Exec.setFps = (type(setfpscap) == "function" and setfpscap)
                or (type(set_fps_cap) == "function" and set_fps_cap)
                or (type(syn) == "table" and type(syn.set_fps_cap) == "function" and syn.set_fps_cap)
                or nil
        end)
        pcall(function()
            Exec.getConnections = (type(getconnections) == "function" and getconnections)
                or (type(get_signal_cons) == "function" and get_signal_cons)
                or nil
        end)
        pcall(function()
            Exec.setHidden = (type(sethiddenproperty) == "function" and sethiddenproperty) or nil
        end)
        pcall(function()
            if type(identifyexecutor) == "function" then
                Exec.identify = string.lower(tostring(identifyexecutor() or ""))
            end
        end)
    end
    
    local LinuxSafe = Exec.identify:find("arceus", 1, true) ~= nil
        or Exec.identify:find("linux", 1, true) ~= nil
    
    
    local function log(msg)
        warn("[KaitunV2] " .. tostring(msg))
    end
    
    local function dbg(msg)
        if Config.Debug then
            log("· " .. tostring(msg))
        end
    end
    
    local function safe(fn, ...)
        local ok, err = pcall(fn, ...)
        if not ok then
            dbg("pcall: " .. tostring(err))
        end
        return ok
    end
    
    local function getCharacter()
        local char = player.Character
        if not char then
            return nil
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then
            return nil
        end
        return char, hrp, hum
    end
    
    local LOBBY_ROOT_NAMES = { Lobby = true, RegularLobby = true }

    local function getLobbySpawnY(model)
        local spawns = model and model:FindFirstChild("Spawns")
        if not spawns then
            return nil
        end
        local sp = spawns:FindFirstChildWhichIsA("BasePart")
        return sp and sp.Position.Y or nil
    end

    local function isLobbyModel(model)
        if not model or not model:IsA("Model") or model:FindFirstChild("CoinContainer") then
            return false
        end
        if not model:FindFirstChild("Spawns") then
            return false
        end
        if LOBBY_ROOT_NAMES[model.Name] then
            return true
        end
        local sy = getLobbySpawnY(model)
        return sy ~= nil and (sy > 400 or sy < 200)
    end

    local function isLobbyY(y)
        return y > 400 or y < 200
    end
    
    local Maid = {}
    Maid.__index = Maid
    
    function Maid.new()
        return setmetatable({ _items = {} }, Maid)
    end
    
    function Maid:Give(key, item)
        self:Clean(key)
        self._items[key] = item
        return item
    end
    
    function Maid:Clean(key)
        local item = self._items[key]
        if not item then
            return
        end
        self._items[key] = nil
        local t = typeof(item)
        if t == "RBXScriptConnection" then
            safe(function() item:Disconnect() end)
        elseif t == "Instance" then
            safe(function() item:Destroy() end)
        elseif t == "thread" then
            if item ~= coroutine.running() then
                safe(function() task.cancel(item) end)
            end
        elseif type(item) == "function" then
            safe(item)
        end
    end
    
    function Maid:CleanPrefix(prefix)
        for key in self._items do
            if string.sub(key, 1, #prefix) == prefix then
                self:Clean(key)
            end
        end
    end
    
    function Maid:DestroyAll()
        for key in self._items do
            self:Clean(key)
        end
    end
    
    
    local PHASE = { BOOT = "boot", LOBBY = "lobby", LOADING = "loading", ROUND = "round", DEAD = "dead" }
    
    local K = {
        Version = "2.1.0",
        Config = Config,
        Phase = PHASE.BOOT,
        Destroyed = false,
    
        CoinsActive = false,
        AwaitNextRound = false,   
        TeleportSeen = false,     
        LoadingMapAt = nil,
        RoundStartedAt = nil,
        ExpectedMapName = nil,
    
        Running = false,
        BagFull = false,
        FullBags = {},           
        Visited = nil,           
        LastFarmCF = nil,
        IsTweening = false,
        CharacterFrozen = false,
    
        CoinContainer = nil,
        CoinSet = nil,            
        PlayerData = nil,
        ProfileData = nil,       
        _profileInitStarted = false,
        _profileSignalsConnected = false,
        CurrentRoundClient = nil,
        LobbySpawnCF = nil,
        PadTopY = nil,           
        PadStandCF = nil,         
        LobbyPadTopY = nil,      
        LobbyPadCX = nil,
        LobbyPadCZ = nil,
        LobbyStandCF = nil,       
    
        Stats = {
            collected = 0, rounds = 0, bagCurrent = 0, bagMax = 0,
            inventoryCoins = nil, inventoryBase = nil, inventoryBaseAt = nil,
            startedAt = os.clock(),
        },
    
        GameReady = false,
        OptEarlyApplied = false,   
        OptApplied = false,      
        DestroyQueue = {},
        DestroyedMark = setmetatable({}, { __mode = "k" }),
    
        _maid = Maid.new(),
        _roundToken = 0,
        _blockedMaps = setmetatable({}, { __mode = "k" }), 
        _cleanupRetryArmed = false,
        _disabledConns = {},       
        _essentialRemotes = nil,   
    }
    K.Visited = setmetatable({}, { __mode = "k" })
    
    
    local Remotes = {}
    
    local function resolveRemotes()
        if Remotes.GetCoin then
            return true
        end
        local ok = pcall(function()
            local root = ReplicatedStorage:WaitForChild("Remotes", 30)
            local gp = root:WaitForChild("Gameplay", 30)
            Remotes.Gameplay = gp
            Remotes.GetCoin = gp:WaitForChild("GetCoin", 10)
            Remotes.CoinCollected = gp:WaitForChild("CoinCollected", 10)
            Remotes.CoinsStarted = gp:WaitForChild("CoinsStarted", 10)
            Remotes.RoundStart = gp:WaitForChild("RoundStart", 10)
            Remotes.LoadingMap = gp:WaitForChild("LoadingMap", 10)
            Remotes.VictoryScreen = gp:WaitForChild("VictoryScreen", 10)
            Remotes.RoundEndFade = gp:WaitForChild("RoundEndFade", 10)
            Remotes.TeleportToPart = gp:FindFirstChild("TeleportToPart")
            Remotes.PlayerDataChanged = gp:FindFirstChild("PlayerDataChanged")
            Remotes.Extras = root:FindFirstChild("Extras")
        end)
        return ok and Remotes.GetCoin ~= nil
    end
    
    function K:InitPlayerData()
        safe(function()
            local mod = ReplicatedStorage:WaitForChild("Modules", 15)
            mod = mod and mod:WaitForChild("CurrentRoundClient", 15)
            if mod then
                self.CurrentRoundClient = require(mod)
            end
        end)
        local crc = self.CurrentRoundClient
        if type(crc) == "table" then
            if type(crc.PlayerData) == "table" then
                self.PlayerData = crc.PlayerData
            end

            local sig = crc.PlayerDataChanged
            if typeof(sig) == "Instance" and sig:IsA("BindableEvent") then
                sig = sig.Event
            end
            if typeof(sig) == "RBXScriptSignal" or (type(sig) == "table" and type(sig.Connect) == "function") then
                safe(function()
                    self._maid:Give("playerDataSig", sig:Connect(function()
                        if type(crc.PlayerData) == "table" then
                            K.PlayerData = crc.PlayerData
                        end
                    end))
                end)
            end
        end
        if Remotes.PlayerDataChanged and Remotes.PlayerDataChanged:IsA("RemoteEvent") then
            self._maid:Give("playerDataRemote", Remotes.PlayerDataChanged.OnClientEvent:Connect(function(payload)
                if type(payload) == "table" then
                    K.PlayerData = payload
                end
            end))
        end
    end
    
    function K:GetMyRoundData()
        local data = self.PlayerData
        if type(data) ~= "table" then
            return nil
        end
        return data[player.Name]
    end
    
    function K:GetRole()
        local my = self:GetMyRoundData()
        return my and my.Role or nil
    end
    
    function K:IsAliveInRound()
        local _, _, hum = getCharacter()
        if not hum or hum.Health <= 0 then
            return false
        end
        local my = self:GetMyRoundData()
        if my then
            if my.Dead == true then
                return false
            end
            if my.Role ~= nil then
                return true
            end
        end
        return self.CoinsActive
    end
    
    
    local function extractInventoryCoins(pd)
        if type(pd) ~= "table" then
            return nil
        end
        local mats = pd.Materials
        if type(mats) == "table" then
            local owned = mats.Owned
            if type(owned) == "table" then
                local coins = tonumber(owned.Coins)
                if coins then
                    return coins
                end
            end
        end
        return tonumber(pd.Coins)
    end
    
    function K:SnapshotInventoryCoins(coins)
        coins = tonumber(coins)
        if coins == nil then
            return
        end
        local stats = self.Stats
        if stats.inventoryBase == nil then
            stats.inventoryBase = coins
            stats.inventoryBaseAt = os.clock()
        end
        stats.inventoryCoins = coins
    end
    
    function K:TryRequireProfileData()
        local mod = ReplicatedStorage:FindFirstChild("Modules")
        mod = mod and mod:FindFirstChild("ProfileData")
        if not mod then
            return nil
        end
        local ok, pd = pcall(require, mod)
        if ok and type(pd) == "table" then
            return pd
        end
        return nil
    end
    
    function K:RefreshInventoryCoinsFromProfile()
        local pd = self.ProfileData or self:TryRequireProfileData()
        if pd then
            self.ProfileData = pd
        end
        local coins = extractInventoryCoins(pd)
        if coins ~= nil then
            self:SnapshotInventoryCoins(coins)
        end
        return coins
    end
    
    function K:ConnectProfileDataSignals()
        if self._profileSignalsConnected then
            return
        end
        self._profileSignalsConnected = true
    
        local function onCoinsChanged(coins)
            coins = tonumber(coins)
            if coins == nil then
                K:RefreshInventoryCoinsFromProfile()
            else
                K:SnapshotInventoryCoins(coins)
            end
            K:UpdateHud()
        end
    
        safe(function()
            local inv = ReplicatedStorage:WaitForChild("Remotes", 15)
            inv = inv and inv:WaitForChild("Inventory", 15)
            if not inv then
                return
            end
    
            local invChanged = inv:FindFirstChild("InventoryDataChanged")
            if invChanged and invChanged:IsA("BindableEvent") then
                invChanged = invChanged.Event
            end
            if typeof(invChanged) == "RBXScriptSignal"
                or (type(invChanged) == "table" and type(invChanged.Connect) == "function")
            then
                self._maid:Give("inventoryDataChanged", invChanged:Connect(function(itemType, itemId, amount)
                    if itemType == "Materials" and itemId == "Coins" then
                        onCoinsChanged(amount)
                    end
                end))
            end
    
            local profChanged = inv:FindFirstChild("ProfileDataChanged")
            if profChanged and profChanged:IsA("BindableEvent") then
                profChanged = profChanged.Event
            end
            if typeof(profChanged) == "RBXScriptSignal"
                or (type(profChanged) == "table" and type(profChanged.Connect) == "function")
            then
                self._maid:Give("profileDataChanged", profChanged:Connect(function(key, val)
                    if key == "Coins" then
                        onCoinsChanged(val)
                    elseif key == "Materials" then
                        if type(val) == "table" and type(val.Owned) == "table" then
                            onCoinsChanged(val.Owned.Coins)
                        else
                            onCoinsChanged(nil)
                        end
                    end
                end))
            end
        end)
    
        safe(function()
            local ev = ReplicatedStorage:FindFirstChild("UpdateData2")
            if ev and ev:IsA("RemoteEvent") then
                self._maid:Give("updateData2", ev.OnClientEvent:Connect(function()
                    onCoinsChanged(nil)
                end))
            end
        end)
    end
    
    function K:InitProfileData()
        if self._profileInitStarted then
            return
        end
        self._profileInitStarted = true
        self:ConnectProfileDataSignals()
    
        self._maid:Give("profileInit", task.spawn(function()
            local timeout = 90
            local deadline = os.clock() + timeout
            while not K.Destroyed and os.clock() < deadline do
                local coins = K:RefreshInventoryCoinsFromProfile()
                if coins ~= nil then
                    K:UpdateHud()
                    dbg(string.format("ProfileData ready — inventory coins=%d", coins))
                    return
                end
                task.wait(0.5)
            end
            dbg("ProfileData coin read timeout — HUD may show 0 until sync")
        end))
    end
    
    function K:GetInventoryCoins()
        local coins = self:RefreshInventoryCoinsFromProfile()
        if coins ~= nil then
            return coins
        end
        return self.Stats.inventoryCoins or 0
    end
    
    function K:GetInventoryCoinRate()
        local stats = self.Stats
        local base, at = stats.inventoryBase, stats.inventoryBaseAt
        if not base or not at then
            return 0
        end
        local mins = math.max((os.clock() - at) / 60, 1 / 60)
        return math.max(0, (self:GetInventoryCoins() - base) / mins)
    end
    
    
    local function isCharacterProtected(inst)
        if not inst then
            return false
        end
        local char = player.Character
        if char and (inst == char or inst:IsDescendantOf(char)) then
            return true
        end
        if inst.Name == "Raggy" or inst.Name == "Characters" then
            return true
        end
        local p = inst.Parent
        while p and p ~= workspace do
            if p.Name == "Raggy" or p.Name == "Characters" then
                return true
            end
            p = p.Parent
        end
        return false
    end
    
    local COIN_KEEP = {
        CoinContainer = true, Coin_Server = true, TouchInterest = true,
        MainCoin = true, DecalPart = true,
    }
    
    local function isCoinRelated(inst)
        if not inst then
            return false
        end
        if COIN_KEEP[inst.Name] then
            return true
        end
        local p = inst.Parent
        while p do
            local n = p.Name
            if n == "CoinContainer" or n == "Coin_Server" then
                return true
            end
            p = p.Parent
        end
        return false
    end
    
    local function isSpawnRelated(inst)
        if not inst then
            return false
        end
        if string.find(string.lower(inst.Name), "spawn", 1, true) then
            return true
        end
        local p = inst.Parent
        while p do
            if string.find(string.lower(p.Name), "spawn", 1, true) then
                return true
            end
            p = p.Parent
        end
        return false
    end
    
    local function isKaitunPart(inst)
        local p = inst
        while p do
            if p.Name == "KaitunV2Pads" then
                return true
            end
            p = p.Parent
        end
        return false
    end
    
    function K:QueueDestroy(inst)
        if not inst or not inst.Parent or self.DestroyedMark[inst] then
            return
        end
        if isCoinRelated(inst) or isSpawnRelated(inst) or isCharacterProtected(inst) or isKaitunPart(inst) then
            return
        end
        self.DestroyedMark[inst] = true
        table.insert(self.DestroyQueue, inst)
    end
    
    function K:PumpDestroyQueue()
        local limit = Config.BatchDestroyPerFrame or 30
        local q = self.DestroyQueue
        local n = 0
        while n < limit and #q > 0 do
            local inst = table.remove(q)
            if inst and inst.Parent then
                safe(function() inst:Destroy() end)
                n += 1
            end
        end
        return n
    end

    function K:FlushDestroyQueue(maxItems)
        maxItems = maxItems or 5000
        local total = 0
        while #self.DestroyQueue > 0 and total < maxItems do
            local pumped = self:PumpDestroyQueue()
            if pumped <= 0 then
                break
            end
            total += pumped
        end
        return total
    end
    
    
    local WORKSPACE_LOBBY_DESTROY = {
        "Lobby", "RegularLobby", "LoadLobby", "ServerStatus", "EffectLoader", "PetContainer",
        "WeaponDisplays", "GameSettings", "RoundTimerPart", "VotePads", "ServerVersion",
    }
    
    local SCRIPT_KEEP = {
        "Kaitun", "CharacterClient", "CoinVisualizer", "CoinBag", "Unfade",
        "RoleSelector", "Preloader", "ControlsEnable", "PlayerScriptsLoader",
        "ClientEventManager", "Menu/GUI", "Menu.GUI", "FadeModule", "SpawnFade",
        "CameraFade", "StatUpdater", "Sync.Client", "ProfileLoader",
        "DatabaseUpdater", "EquipWeapons", "CoinBagContainerScript",
        "CurrentRoundClient", "Animate", "Ragdoll", "Health", "Game/Names",
    }
    
    local MAP_DECOR_DESTROY = {
        "Decoration_Regular", "Decorations", "Decoration", "Interactive",
        "VaultSystem", "Props", "Props2", "Details", "Ambient", "Effects",
        "Particles", "Lights", "Lighting", "Furniture",
    }
    
    local GAME_HUD_SCREENGUIS = { MainGUI = true, GameUI = true, MobileUI = true, TabletUI = true }
    
    local function shouldKeepScript(s)
        local path = s:GetFullName()
        for _, kw in SCRIPT_KEEP do
            if path:find(kw, 1, true) then
                return true
            end
        end
        return false
    end
    
    function K:ApplyRenderingSettings()
        if not Config.LowRendering then
            return
        end
        safe(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        safe(function()
            settings().Rendering.MeshQuality = Enum.MeshQuality.Level01
        end)
        safe(function()
            Lighting.GlobalShadows = false
            Lighting.Brightness = 1
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 9e9
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            for _, child in Lighting:GetChildren() do
                child:Destroy()
            end
        end)
        if Config.DowngradeTechnology and Exec.setHidden then
            safe(function()
                Exec.setHidden(Lighting, "Technology", Enum.Technology.Compatibility)
            end)
        end
        safe(function()
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.Decoration = false
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 1
            end
        end)
        if Config.Disable3DRender and not LinuxSafe then
            safe(function()
                RunService:Set3dRenderingEnabled(false)
            end)
        end
    end
    
    function K:MuteSounds()
        if not Config.MuteSounds then
            return
        end
        for _, root in { SoundService, workspace } do
            safe(function()
                for _, s in root:GetDescendants() do
                    if s:IsA("Sound") then
                        s.Volume = 0
                        s.Playing = false
                    end
                end
            end)
        end
        safe(function()
            SoundService.AmbientReverb = Enum.ReverbType.NoReverb
        end)
    end
    
    function K:StripLobbyModels()
        if not Config.StripLobby then
            return 0
        end
        self:EnsureLobbyPad()
        local totalQueued = 0
        local strippedPaths = {}
        local processed = {}

        local function stripLobbyShell(lobby)
            if processed[lobby] then
                return 0
            end
            processed[lobby] = true
            local n = 0
            for _, child in lobby:GetChildren() do
                if not isSpawnRelated(child) then
                    self:QueueDestroy(child)
                    n += 1
                end
            end
            if n > 0 then
                table.insert(strippedPaths, lobby:GetFullName())
            end
            return n
        end

        for _, name in WORKSPACE_LOBBY_DESTROY do
            local inst = workspace:FindFirstChild(name)
            if inst then
                if inst:IsA("Model") and inst:FindFirstChild("Spawns") then
                    totalQueued += stripLobbyShell(inst)
                else
                    self:QueueDestroy(inst)
                    totalQueued += 1
                    table.insert(strippedPaths, inst:GetFullName())
                end
            end
        end

        for _, child in workspace:GetChildren() do
            if child:IsA("Model") and isLobbyModel(child) then
                totalQueued += stripLobbyShell(child)
            end
        end

        print(string.format(
            "[KaitunV2] StripLobby: queued %d items from %d paths (%s)",
            totalQueued,
            #strippedPaths,
            #strippedPaths > 0 and table.concat(strippedPaths, "; ") or "none"
        ))
        return totalQueued
    end

    function K:ProcessExistingMapModels()
        if not Config.BlockMapLoad then
            return 0
        end
        local blocked = 0
        for _, child in workspace:GetChildren() do
            if child:IsA("Model") then
                if child:FindFirstChild("CoinContainer") or isLobbyModel(child) then
                    self:BlockIncomingModel(child)
                    blocked += 1
                end
            end
        end
        return blocked
    end

    function K:RunMapCleanupPass()
        local queued, blocked, flushed = 0, 0, 0
        if Config.StripLobby then
            self:EnsureLobbyPad()
            queued = self:StripLobbyModels() or 0
        end
        blocked = self:ProcessExistingMapModels()
        flushed = self:FlushDestroyQueue(5000)
        return queued, blocked, flushed
    end

    function K:RunStartupMapCleanup()
        print("[KaitunV2] map cleanup start...")
        local function runPass(label)
            local q, b, f = self:RunMapCleanupPass()
            print(string.format(
                "[KaitunV2] map cleanup %s: queued=%d blocked=%d flushed=%d",
                label, q, b, f
            ))
            return q, b, f
        end

        local ok, err = pcall(function()
            runPass("pass 1")
        end)
        if not ok then
            warn("[KaitunV2] map cleanup error (pass 1): " .. tostring(err))
        end

        if self._cleanupRetryArmed then
            return
        end
        self._cleanupRetryArmed = true

        self._maid:Give("cleanupRetry", task.spawn(function()
            local timeout = Config.CleanupWaitTimeout or 8
            local deadline = os.clock() + timeout
            while os.clock() < deadline and not K.Destroyed do
                local hasLobby = workspace:FindFirstChild("Lobby")
                    or workspace:FindFirstChild("RegularLobby")
                local hasMap = false
                for _, c in workspace:GetChildren() do
                    if c:IsA("Model") and c:FindFirstChild("CoinContainer") then
                        hasMap = true
                        break
                    end
                end
                if hasLobby or hasMap then
                    task.wait(0.15)
                    local ok2, err2 = pcall(function()
                        runPass("retry")
                    end)
                    if not ok2 then
                        warn("[KaitunV2] map cleanup error (retry): " .. tostring(err2))
                    end
                    break
                end
                task.wait(0.15)
            end
            print("[KaitunV2] map cleanup retry loop finished")
        end))
    end
    
    function K:HideOtherPlayers()
        if not Config.HideOtherPlayers then
            return
        end
        for _, model in workspace:GetChildren() do
            if model:IsA("Model") and model ~= player.Character
                and model:FindFirstChildOfClass("Humanoid")
                and not isCharacterProtected(model)
            then
                self:QueueDestroy(model)
            end
        end
    end
    
    function K:ArmHideOtherPlayers()
        if not Config.HideOtherPlayers then
            return
        end
        local function hook(plr)
            if plr == player then
                return
            end
            self._maid:Give("hide_" .. plr.UserId, plr.CharacterAdded:Connect(function(char)
                task.defer(function()
                    if char.Parent then
                        safe(function() char:Destroy() end)
                    end
                end)
            end))
            if plr.Character then
                safe(function() plr.Character:Destroy() end)
            end
        end
        for _, plr in Players:GetPlayers() do
            hook(plr)
        end
        self._maid:Give("hidePlayerAdded", Players.PlayerAdded:Connect(hook))
        self._maid:Give("hidePlayerRemoving", Players.PlayerRemoving:Connect(function(plr)
            K._maid:Clean("hide_" .. plr.UserId)
        end))
    end
    
    function K:DisableHeavyScripts()
        if not Config.DisableHeavyScripts then
            return
        end
        local roots = { game:GetService("StarterPlayer"), StarterGui, ReplicatedStorage }
        local pg = player:FindFirstChild("PlayerGui")
        if pg then
            table.insert(roots, pg)
        end
        for _, root in roots do
            safe(function()
                for _, s in root:GetDescendants() do
                    if (s:IsA("LocalScript") or s:IsA("Script")) and not s.Disabled then
                        if not isCharacterProtected(s) and not shouldKeepScript(s) then
                            s.Disabled = true
                        end
                    end
                end
            end)
        end
        self:EnsureCharacterClient()
    end
    
    function K:EnsureCharacterClient()
        safe(function()
            local char = player.Character
            local cc = char and char:FindFirstChild("CharacterClient")
            if cc and (cc:IsA("LocalScript") or cc:IsA("Script")) then
                cc.Disabled = false
            end
            local starter = game:GetService("StarterPlayer"):FindFirstChild("StarterCharacterScripts")
            cc = starter and starter:FindFirstChild("CharacterClient")
            if cc and (cc:IsA("LocalScript") or cc:IsA("Script")) then
                cc.Disabled = false
            end
        end)
    end
    
    function K:StripPlayerGuiScreens()
        if not Config.StripPlayerGui then
            return
        end
        local pg = player:FindFirstChild("PlayerGui")
        if not pg then
            return
        end
        for _, child in pg:GetChildren() do
            if child:IsA("ScreenGui") and child.Name ~= "KaitunV2Hud" then
                if not (Config.KeepGameHud and GAME_HUD_SCREENGUIS[child.Name]) then
                    safe(function() child:Destroy() end)
                end
            end
        end
        for _, spec in { { "CameraFade", "ScreenGui" }, { "SpawnFade", "ScreenGui" }, { "InputContext", "Folder" } } do
            if not pg:FindFirstChild(spec[1]) then
                safe(function()
                    local stub = Instance.new(spec[2])
                    stub.Name = spec[1]
                    if stub:IsA("ScreenGui") then
                        stub.ResetOnSpawn = false
                    end
                    stub.Parent = pg
                end)
            end
        end
    end
    
    function K:MinimizeCharacter()
        if not Config.MinimizeLocalCharacter then
            return
        end
        local char = player.Character
        if not char then
            return
        end
        safe(function()
            for _, part in char:GetDescendants() do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.LocalTransparencyModifier = 1
                    part.CastShadow = false
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = 1
                end
            end
        end)
    end
    
    local function isDecorName(name)
        for _, decor in MAP_DECOR_DESTROY do
            if name:find(decor, 1, true) then
                return true
            end
        end
        return false
    end
    
    function K:StripMapModel(map)
        if not map or not map.Parent then
            return
        end
        if Config.StripMap then
            for _, child in map:GetChildren() do
                if child.Name ~= "CoinContainer" and not isSpawnRelated(child) and not isCharacterProtected(child) then
                    self:QueueDestroy(child)
                end
            end
        elseif Config.StripMapDecor then
            for _, child in map:GetChildren() do
                if isDecorName(child.Name) and not isSpawnRelated(child) and not isCharacterProtected(child) then
                    self:QueueDestroy(child)
                end
            end
        end
        if Config.StripCoinVisuals then
            local cc = map:FindFirstChild("CoinContainer")
            if cc then
                safe(function()
                    for _, coin in cc:GetChildren() do
                        local vis = coin:FindFirstChild("CoinVisual")
                        if vis then
                            vis:Destroy()
                        end
                    end
                end)
            end
        end
    end
    
    function K:ArmMapStripper()
        if Config.BlockMapLoad and self._blockMapArmed then
            return
        end
        if not (Config.StripMap or Config.StripMapDecor or Config.StripCoinVisuals) then
            return
        end
        local token = self._roundToken
        self._maid:Give("round_mapChildAdded", workspace.ChildAdded:Connect(function(child)
            if token ~= K._roundToken then
                return
            end
            if child:IsA("Model") and child ~= player.Character then
                task.defer(function()
                    if token ~= K._roundToken or not child.Parent then
                        return
                    end
                    if child:FindFirstChild("CoinContainer")
                        or (K.ExpectedMapName and child.Name == K.ExpectedMapName)
                    then
                        K:StripMapModel(child)
                    end
                end)
            end
        end))
        self._maid:Give("round_mapDescAdded", workspace.DescendantAdded:Connect(function(desc)
            if token ~= K._roundToken then
                return
            end
            if desc.Name == "CoinContainer" then
                local map = desc:FindFirstAncestorOfClass("Model")
                if map and map ~= player.Character then
                    task.defer(function()
                        if token == K._roundToken then
                            K:StripMapModel(map)
                        end
                    end)
                end
            elseif Config.StripCoinVisuals and desc.Name == "CoinVisual" and isCoinRelated(desc) then
                task.defer(function()
                    if desc.Parent then
                        safe(function() desc:Destroy() end)
                    end
                end)
            end
        end))
        for _, child in workspace:GetChildren() do
            if child:IsA("Model") and child ~= player.Character and child:FindFirstChild("CoinContainer") then
                self:StripMapModel(child)
            end
        end
    end
    
    
    local JUNK_DESTROY_CLASSES = {
        ParticleEmitter = true, Trail = true, Beam = true, Smoke = true,
        Fire = true, Sparkles = true, Decal = true, Texture = true,
        BillboardGui = true, SurfaceGui = true, Highlight = true,
        ProximityPrompt = true, ClickDetector = true,
        PointLight = true, SpotLight = true, SurfaceLight = true,
    }
    
    function K:ProcessInboundInstance(inst)
        if not inst or not inst.Parent then
            return
        end
        local cls = inst.ClassName
        if cls == "Explosion" then
            safe(function()
                inst.BlastPressure = 0
                inst.BlastRadius = 0
                inst.Visible = false
            end)
            self:QueueDestroy(inst)
            return
        end
        if cls == "Sound" then
            if Config.MuteSounds then
                safe(function()
                    inst.Volume = 0
                    inst.Playing = false
                    inst.Looped = false
                end)
            end
            return
        end
        if JUNK_DESTROY_CLASSES[cls] then
            if cls == "ParticleEmitter" or cls == "Trail" or cls == "Beam" then
                safe(function() inst.Enabled = false end)
            end
            self:QueueDestroy(inst)
        end
    end
    
    function K:ArmInboundFilter()
        if not Config.FilterIncomingInstances then
            return
        end
        self._maid:Give("inboundFilter", workspace.DescendantAdded:Connect(function(inst)
            task.defer(function()
                if not K.Destroyed then
                    K:ProcessInboundInstance(inst)
                end
            end)
        end))
        self._maid:Give("inboundLighting", Lighting.ChildAdded:Connect(function(child)
            if Config.LowRendering then
                task.defer(function()
                    if child.Parent then
                        safe(function() child:Destroy() end)
                    end
                end)
            end
        end))
        self._maid:Give("inboundSound", SoundService.DescendantAdded:Connect(function(inst)
            if Config.MuteSounds and inst:IsA("Sound") then
                task.defer(function()
                    if inst.Parent then
                        safe(function()
                            inst.Volume = 0
                            inst.Playing = false
                        end)
                    end
                end)
            end
        end))
    end
    
    function K:BlockIncomingModel(model)
        if not model or not model.Parent or self._blockedMaps[model] then
            return
        end
        if model == player.Character or isCharacterProtected(model) or isKaitunPart(model) then
            return
        end
        if model:FindFirstChildOfClass("Humanoid") then
            return
        end
        local isPlayerChar = false
        safe(function()
            isPlayerChar = Players:GetPlayerFromCharacter(model) ~= nil
        end)
        if isPlayerChar then
            return
        end
        if isLobbyModel(model) then
            if not Config.StripLobby then
                return
            end
            self:EnsureLobbyPad()
        end
        self._blockedMaps[model] = true
    
        local function stripChild(child)
            if child.Name == "CoinContainer" or isSpawnRelated(child)
                or isCharacterProtected(child) or isKaitunPart(child)
            then
                return
            end
            self:QueueDestroy(child)
        end
    
        for _, child in model:GetChildren() do
            stripChild(child)
        end
        if Config.StripCoinVisuals then
            local cc = model:FindFirstChild("CoinContainer")
            if cc then
                safe(function()
                    for _, coin in cc:GetChildren() do
                        local vis = coin:FindFirstChild("CoinVisual")
                        if vis then
                            vis:Destroy()
                        end
                    end
                end)
            end
        end
    
        self._blockMapN = (self._blockMapN or 0) + 1
        local key = "blockmap_" .. self._blockMapN
        self._maid:Give(key, model.ChildAdded:Connect(function(child)
            task.defer(function()
                if not K.Destroyed and child.Parent then
                    if child.Name == "CoinContainer" then
                        if Config.StripCoinVisuals then
                            K:StripMapModel(model)
                        end
                    else
                        stripChild(child)
                    end
                end
            end)
        end))
        self._maid:Give(key .. "_gone", model.AncestryChanged:Connect(function(_, parent)
            if parent == nil then
                K._maid:Clean(key)
                K._maid:Clean(key .. "_gone")
            end
        end))
        dbg("BlockMapLoad: stripped incoming model " .. model.Name)
        print(string.format("[KaitunV2] BlockMapLoad: stripped model %s (kept Spawns/CoinContainer)", model:GetFullName()))
    end
    
    function K:ArmBlockMapLoad()
        if not Config.BlockMapLoad or self._blockMapArmed then
            return
        end
        self._blockMapArmed = true
        self._maid:Give("blockMapWatch", workspace.ChildAdded:Connect(function(child)
            if child:IsA("Model") then
                task.defer(function()
                    if not K.Destroyed and child.Parent then
                        K:BlockIncomingModel(child)
                    end
                end)
            end
        end))
        local blocked = self:ProcessExistingMapModels()
        print(string.format("[KaitunV2] BlockMapLoad armed — processing %d existing model(s)", blocked))
        log("BlockMapLoad armed — map geometry sẽ bị chặn, chỉ coins/spawns load")
    end
    
    function K:ApplyRemoteHandlerFilter()
        if not Config.FilterRemoteHandlers or not Exec.getConnections then
            return
        end
        if (self._remoteFilterPasses or 0) >= 2 then
            return
        end
        self._remoteFilterPasses = (self._remoteFilterPasses or 0) + 1
        if not self._essentialRemotes then
            local set = {}
            if type(Config.EssentialRemotes) == "table" then
                for _, name in Config.EssentialRemotes do
                    set[tostring(name)] = true
                end
            end
            set.EventQuestProgressed = true
            self._essentialRemotes = set
        end
        local disabled = 0
        safe(function()
            for _, inst in ReplicatedStorage:GetDescendants() do
                if (inst:IsA("RemoteEvent") or inst:IsA("UnreliableRemoteEvent"))
                    and not self._essentialRemotes[inst.Name]
                then
                    local ok, conns = pcall(Exec.getConnections, inst.OnClientEvent)
                    if ok and type(conns) == "table" then
                        for _, conn in conns do
                            if pcall(function() conn:Disable() end) then
                                table.insert(self._disabledConns, conn)
                                disabled += 1
                            end
                        end
                    end
                end
            end
        end)
        if disabled > 0 then
            log(string.format("Remote handler filter: disabled %d connections (pass %d)",
                disabled, self._remoteFilterPasses))
        end
    end
    
    function K:RestoreRemoteHandlerFilter()
        for _, conn in self._disabledConns do
            pcall(function() conn:Enable() end)
        end
        table.clear(self._disabledConns)
    end
    
    function K:ApplyEarlyOpt()
        if self.OptEarlyApplied or Config.OptimizationMode == "off" then
            return
        end
        self.OptEarlyApplied = true
        self:ApplyRenderingSettings()
        self:MuteSounds()
        self:HideOtherPlayers()
        self:ArmHideOtherPlayers()
        self:MinimizeCharacter()
        self:ArmInboundFilter()
        self:ArmBlockMapLoad()
        self:RunStartupMapCleanup()
        log("Instant opt applied (mode=" .. tostring(Config.OptimizationMode)
            .. (Config.BlockMapLoad and ", BlockMapLoad" or "")
            .. (LinuxSafe and ", LinuxSafe" or "") .. ")")
    end
    
    function K:ApplyOptimizationOnce()
        if self.OptApplied or Config.OptimizationMode == "off" then
            return
        end
        self.OptApplied = true
        self:ApplyEarlyOpt()
        self:DisableHeavyScripts()
        self:StripPlayerGuiScreens()
        self:ApplyRemoteHandlerFilter()
        self:MinimizeCharacter()
        log("Optimization applied (mode=" .. tostring(Config.OptimizationMode)
            .. (LinuxSafe and ", LinuxSafe" or "") .. ")")
    end
    
    
    function K:GetUprightCF(pos, hrp)
        if hrp then
            local _, ry = hrp.CFrame:ToOrientation()
            return CFrame.new(pos) * CFrame.Angles(0, ry, 0)
        end
        return CFrame.new(pos)
    end
    
    function K:ZeroVelocity(hrp)
        safe(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    
    function K:ApplyCF(cf)
        local char, hrp = getCharacter()
        if not hrp or not cf then
            return
        end
        safe(function()
            char:PivotTo(cf)
        end)
        self:ZeroVelocity(hrp)
        self.LastFarmCF = cf
    end
    
    function K:FreezeCharacter()
        if not Config.FreezeCharacter or self.CharacterFrozen then
            return
        end
        local char, hrp, hum = getCharacter()
        if not char or not hum then
            return
        end
        hum.PlatformStand = true
        hum.AutoRotate = false
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        safe(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            if not LinuxSafe then
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
        end)
        if not LinuxSafe then
            safe(function()
                for _, desc in char:GetDescendants() do
                    if desc:IsA("Animator") then
                        for _, track in desc:GetPlayingAnimationTracks() do
                            track:Stop(0)
                        end
                    end
                end
            end)
        end
        self.CharacterFrozen = true
        if hrp then
            self:ZeroVelocity(hrp)
        end
    end
    
    function K:UnfreezeCharacter()
        self.CharacterFrozen = false
        local _, _, hum = getCharacter()
        if not hum then
            return
        end
        safe(function()
            hum.PlatformStand = false
            hum.AutoRotate = true
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end)
    end
    
    function K:TweenTo(targetPos, token)
        local _, hrp = getCharacter()
        if not hrp then
            return false
        end
        local speed = math.clamp(Config.TweenSpeed or 28, 4, Config.TweenSpeedMax or 60)
        local from = (self.LastFarmCF and self.LastFarmCF.Position) or hrp.Position
        local dist = (targetPos - from).Magnitude
        if dist < 0.1 then
            self:ApplyCF(self:GetUprightCF(targetPos, hrp))
            return true
        end
        local duration = math.clamp(dist / speed, Config.TweenMinTime or 0.1, Config.TweenMaxTime or 6)
        self.IsTweening = true
        local elapsed = 0
        while elapsed < duration do
            if token ~= self._roundToken or not self.Running then
                self.IsTweening = false
                return false
            end
            local dt = task.wait()
            elapsed += dt
            local alpha = math.clamp(elapsed / duration, 0, 1)
            local _, hrp2 = getCharacter()
            if not hrp2 then
                self.IsTweening = false
                return false
            end
            self:ApplyCF(self:GetUprightCF(from:Lerp(targetPos, alpha), hrp2))
        end
        self.IsTweening = false
        return true
    end
    
    
    local function ensurePadPart(name)
        local folder = workspace:FindFirstChild("KaitunV2Pads")
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = "KaitunV2Pads"
            folder.Parent = workspace
        end
        local pad = folder:FindFirstChild(name)
        if not pad then
            pad = Instance.new("Part")
            pad.Name = name
            pad.Anchored = true
            pad.CanCollide = true
            pad.CanQuery = false
            pad.CanTouch = false
            pad.Transparency = 1
            pad.CastShadow = false
            pad.Size = Vector3.new(Config.PadSize or 128, 4, Config.PadSize or 128)
            pad.Parent = folder
        end
        return pad
    end
    
    function K:EnsurePad(centerX, centerZ, topY)
        if not Config.AutoCreatePad then
            return
        end
        local pad = ensurePadPart("Pad")
        pad.CFrame = CFrame.new(centerX, topY - 2, centerZ)
        self.PadTopY = topY
        self.PadStandCF = CFrame.new(centerX, topY + 3, centerZ)
    end
    
    function K:SyncPadToCoins()
        if not Config.AutoCreatePad or not self.CoinSet then
            return
        end
        local minX, maxX, minZ, maxZ, minY = math.huge, -math.huge, math.huge, -math.huge, math.huge
        local count = 0
        for coin in self.CoinSet do
            if coin.Parent then
                local p = coin.Position
                minX, maxX = math.min(minX, p.X), math.max(maxX, p.X)
                minZ, maxZ = math.min(minZ, p.Z), math.max(maxZ, p.Z)
                minY = math.min(minY, p.Y)
                count += 1
            end
        end
        if count > 0 then
            self:EnsurePad((minX + maxX) * 0.5, (minZ + maxZ) * 0.5, minY - 4)
        end
    end
    
    function K:EnsureLobbyPad()
        if not Config.AutoCreatePad then
            return
        end
        if not self.LobbyPadTopY then
            local topY, cx, cz
            safe(function()
                for _, model in workspace:GetChildren() do
                    if model:IsA("Model") and isLobbyModel(model) then
                        local spawns = model:FindFirstChild("Spawns")
                        if spawns then
                            local minX, maxX = math.huge, -math.huge
                            local minZ, maxZ = math.huge, -math.huge
                            local maxY, n = -math.huge, 0
                            for _, s in spawns:GetChildren() do
                                if s:IsA("BasePart") then
                                    local p = s.Position
                                    minX, maxX = math.min(minX, p.X), math.max(maxX, p.X)
                                    minZ, maxZ = math.min(minZ, p.Z), math.max(maxZ, p.Z)
                                    maxY = math.max(maxY, p.Y + s.Size.Y * 0.5)
                                    n += 1
                                end
                            end
                            if n > 0 then
                                topY = maxY
                                cx, cz = (minX + maxX) * 0.5, (minZ + maxZ) * 0.5
                                break
                            end
                        end
                    end
                end
            end)
            if not topY then
                local _, hrp = getCharacter()
                if hrp and isLobbyY(hrp.Position.Y) then
                    local p = hrp.Position
                    topY, cx, cz = p.Y - 3.1, p.X, p.Z
                elseif self.LobbySpawnCF then
                    local p = self.LobbySpawnCF.Position
                    topY, cx, cz = p.Y - 3.1, p.X, p.Z
                end
            end
            if not topY then
                return
            end
            self.LobbyPadTopY = topY
            self.LobbyPadCX, self.LobbyPadCZ = cx, cz
            self.LobbyStandCF = CFrame.new(cx, topY + 3, cz)
        end
        if not self.LobbyPadTopY or not self.LobbyPadCX or not self.LobbyPadCZ then
            return
        end
        local pad = ensurePadPart("LobbyPad")
        pad.CFrame = CFrame.new(self.LobbyPadCX, self.LobbyPadTopY - 2, self.LobbyPadCZ)
    end
    
    function K:RemoveMapPad()
        local folder = workspace:FindFirstChild("KaitunV2Pads")
        local pad = folder and folder:FindFirstChild("Pad")
        if pad then
            safe(function() pad:Destroy() end)
        end
        self.PadTopY = nil
        self.PadStandCF = nil
    end
    
    function K:RemoveAllPads()
        local folder = workspace:FindFirstChild("KaitunV2Pads")
        if folder then
            safe(function() folder:Destroy() end)
        end
        self.PadTopY = nil
        self.PadStandCF = nil
        self.LobbyPadTopY = nil
    end
    
    
    function K:FindCoinContainer()
        local cc = self.CoinContainer
        if cc and cc.Parent then
            return cc
        end
        self.CoinContainer = nil
        for _, child in workspace:GetChildren() do
            if child:IsA("Model") and child ~= player.Character then
                local found = child:FindFirstChild("CoinContainer")
                if found then
                    self:SetCoinContainer(found)
                    return found
                end
            end
        end
        local deep = workspace:FindFirstChild("CoinContainer", true)
        if deep and not isCharacterProtected(deep) then
            self:SetCoinContainer(deep)
        end
        return self.CoinContainer
    end
    
    function K:SetCoinContainer(container)
        if self.CoinContainer == container then
            return
        end
        self.CoinContainer = container
        self.CoinSet = {}
        for _, child in container:GetChildren() do
            if child.Name == "Coin_Server" and child:IsA("BasePart") then
                self.CoinSet[child] = true
            end
        end
        self._maid:Give("round_coinAdded", container.ChildAdded:Connect(function(child)
            if child.Name == "Coin_Server" and child:IsA("BasePart") then
                K.CoinSet[child] = true
                if Config.StripCoinVisuals then
                    task.defer(function()
                        local vis = child:FindFirstChild("CoinVisual")
                        if vis then
                            safe(function() vis:Destroy() end)
                        end
                    end)
                end
            end
        end))
        self._maid:Give("round_coinRemoved", container.ChildRemoved:Connect(function(child)
            K.CoinSet[child] = nil
        end))
        dbg("CoinContainer cached: " .. container:GetFullName())
    end
    
    function K:IsCoinCollectable(coin)
        return coin
            and coin.Parent ~= nil
            and coin:FindFirstChild("TouchInterest") ~= nil
            and not self.Visited[coin]
    end
    
    function K:MatchesCoinType(coin)
        if Config.CoinType == "Any" or not Config.CoinType then
            return true
        end
        local id = coin:GetAttribute("CoinID")
        if id == Config.CoinType then
            return true
        end
        return (id == nil or id == "") and Config.CoinType == "Coin"
    end
    
    function K:NearestCoin(fromPos)
        local best, bestDist = nil, math.huge
        local coinSet = self.CoinSet
        if not coinSet then
            return nil
        end
        for coin in coinSet do
            if self:IsCoinCollectable(coin) and self:MatchesCoinType(coin) then
                local id = coin:GetAttribute("CoinID")
                if not (id and self.FullBags[id]) then
                    local d = coin.Position - fromPos
                    local dist = d.X * d.X + d.Y * d.Y + d.Z * d.Z
                    if dist < bestDist then
                        best, bestDist = coin, dist
                    end
                end
            end
        end
        return best
    end
    
    function K:CountCollectableCoins()
        local n = 0
        if self.CoinSet then
            for coin in self.CoinSet do
                if self:IsCoinCollectable(coin) then
                    n += 1
                end
            end
        end
        return n
    end
    
    function K:WaitForTouchInterest(token)
        local deadline = os.clock() + (Config.TouchInterestWait or 8)
        while os.clock() < deadline and token == self._roundToken and self.CoinsActive do
            if self:FindCoinContainer() and self:CountCollectableCoins() > 0 then
                return true
            end
            task.wait(0.25)
        end
        return self:CountCollectableCoins() > 0
    end
    
    
    function K:GetCollectPosition(coin, hrp)
        if Exec.fireTouch then
            local hrpHalf = ((hrp and hrp.Size.Y) or 2) * 0.5
            local y = coin.Position.Y - coin.Size.Y * 0.5 - hrpHalf - (Config.CoinBelowOffset or 2.5)
            return Vector3.new(coin.Position.X, y, coin.Position.Z)
        end
        return coin.Position
    end
    
    function K:CollectCoin(coin, hrp)
        if not self:IsCoinCollectable(coin) then
            return false
        end
        if Exec.fireTouch then
            safe(function()
                Exec.fireTouch(hrp, coin, 0)
                task.wait(Config.CollectTouchDelay or 0.05)
                Exec.fireTouch(hrp, coin, 1)
            end)
        end
        local coinId = coin:GetAttribute("CoinID")
        if type(coinId) == "string" and coinId ~= "" and Remotes.GetCoin then
            safe(function()
                Remotes.GetCoin:FireServer(coinId)
            end)
        end
        task.wait(Config.CollectSettleDelay or 0.08)
        if not coin.Parent or not coin:FindFirstChild("TouchInterest") then
            self.Visited[coin] = true
            self.Stats.collected += 1
            return true
        end
        self.Visited[coin] = true
        return false
    end
    
    
    function K:StartFarm()
        if self.Running or not Config.Enabled then
            return
        end
        if self.AwaitNextRound or not self.CoinsActive or not self:IsAliveInRound() then
            return
        end
        local container = self:FindCoinContainer()
        if not container then
            return
        end
        self.Running = true
        self.BagFull = false
        local token = self._roundToken
    
        self:FreezeCharacter()
        self:MinimizeCharacter()
    
        self:SyncPadToCoins()
    
        log(string.format("Farm start — role=%s coins=%d", tostring(self:GetRole()), self:CountCollectableCoins()))
    
        self._maid:Give("round_farmLoop", task.spawn(function()
            local idleSince = nil
            while K.Running and token == K._roundToken do
                if not K:IsAliveInRound() then
                    task.wait(0.5)
                    continue
                end
                if K.BagFull then
                    K:OnBagFull()
                    break
                end
                local _, hrp = getCharacter()
                if not hrp then
                    task.wait(0.5)
                    continue
                end
                local coin = K:NearestCoin((K.LastFarmCF and K.LastFarmCF.Position) or hrp.Position)
                if not coin then
                    idleSince = idleSince or os.clock()
                    if os.clock() - idleSince > 5 then
                        K.Visited = setmetatable({}, { __mode = "k" })
                        idleSince = os.clock()
                    end
                    task.wait(0.4)
                    continue
                end
                idleSince = nil
                if K:TweenTo(K:GetCollectPosition(coin, hrp), token) then
                    K:CollectCoin(coin, hrp)
                end
                task.wait(Config.CoinCycleDelay or 0.02)
            end
        end))
    end
    
    function K:StopFarm()
        self.Running = false
        self.IsTweening = false
        self.LastFarmCF = nil
        self._maid:Clean("round_farmLoop")
    end
    
    function K:OnBagFull()
        log(string.format("Bag full (%d/%d) — collected %d total",
            self.Stats.bagCurrent, self.Stats.bagMax, self.Stats.collected))
        self:StopFarm()
        if Config.ResetWhenFull then
            self.AwaitNextRound = true
            safe(function()
                local _, _, hum = getCharacter()
                if hum then
                    hum.Health = 0
                end
            end)
        end
    end
    
    
    function K:SetPhase(phase, why)
        if self.Phase == phase then
            return
        end
        dbg(string.format("Phase %s -> %s (%s)", self.Phase, phase, why or "?"))
        self.Phase = phase
        self:UpdateHud()
    end
    
    function K:CleanupRound()
        self._roundToken += 1
        self:StopFarm()
        self._maid:CleanPrefix("round_")
        self.CoinContainer = nil
        self.CoinSet = nil
        self.Visited = setmetatable({}, { __mode = "k" })
        self.FullBags = {}
        self.BagFull = false
        self:RemoveMapPad()
    end
    
    function K:OnLoadingMap(mapName)
        self:CleanupRound()
        self.CoinsActive = false
        self.TeleportSeen = false
        self.LoadingMapAt = os.clock()
        self.AwaitNextRound = false
        self.ExpectedMapName = (type(mapName) == "string" and mapName ~= "") and mapName or nil
        self:SetPhase(PHASE.LOADING, "LoadingMap")
        self:UnfreezeCharacter()
        self:EnsureCharacterClient()
        self:CaptureLobbySpawn()
        self:ArmMapStripper()
        self:ApplyRemoteHandlerFilter()
        if Config.MuteSounds then
            task.defer(function() self:MuteSounds() end)
        end
    end
    
    function K:OnRoundStart()
        if self.CoinsActive or self.Running then
            return
        end
        if self.Phase ~= PHASE.LOADING then
            self:SetPhase(PHASE.LOADING, "RoundStart")
            self:ArmMapStripper()
        end
    end
    
    function K:OnTeleportToPart(spawnPart)
        self.TeleportSeen = true
        if typeof(spawnPart) == "Instance" and spawnPart:IsA("BasePart") then
            dbg("TeleportToPart -> " .. spawnPart:GetFullName())
            local p = spawnPart.Position
            self:EnsurePad(p.X, p.Z, p.Y - 3)
        end
    end
    
    function K:OnCoinsStarted(bags)
        if self.Running then
            self:CleanupRound()
        end
        self.CoinsActive = true
        self.RoundStartedAt = os.clock()
        self.Stats.rounds += 1
        self.Stats.bagCurrent = 0
        self.FullBags = {}
        self:SetPhase(PHASE.ROUND, "CoinsStarted")
        if type(bags) == "table" then
            local names = {}
            for name in bags do
                table.insert(names, tostring(name))
            end
            dbg("Bags: " .. table.concat(names, ", "))
        end
        if self.AwaitNextRound then
            dbg("CoinsStarted while AwaitNextRound — skip farm")
            return
        end
        if not Config.Enabled or not Config.AutoStart then
            return
        end
        local token = self._roundToken
        self._maid:Give("round_startFarm", task.spawn(function()
            if not K:WaitForTouchInterest(token) then
                dbg("No TouchInterest coins within timeout")
            end
            local deadline = os.clock() + (Config.RoundReadyTimeout or 45)
            while token == K._roundToken and K.CoinsActive and os.clock() < deadline do
                if K.Running then
                    return
                end
                if K:IsAliveInRound() and K:CountCollectableCoins() > 0 then
                    K:StartFarm()
                    if K.Running then
                        return
                    end
                end
                task.wait(0.35)
            end
        end))
    end
    
    function K:OnCoinCollected(coinType, current, max)
        current, max = tonumber(current), tonumber(max)
        if current then
            self.Stats.bagCurrent = current
        end
        if max then
            self.Stats.bagMax = max
        end
        if current and max and max > 0 and current >= max then
            if type(coinType) == "string" then
                self.FullBags[coinType] = true
            end
            if Config.CoinType == "Any" or Config.CoinType == coinType then
                self.BagFull = true
            end
        end
        self:UpdateHud()
    end
    
    function K:OnRoundEnded(why)
        self:CleanupRound()
        self.CoinsActive = false
        self.TeleportSeen = false
        self.LoadingMapAt = nil
        self.RoundStartedAt = nil
        self.ExpectedMapName = nil
        self.AwaitNextRound = false
        self:SetPhase(PHASE.LOBBY, why)
        self:UnfreezeCharacter()
        self:CaptureLobbySpawn()
        self:EnsureLobbyPad()
        log(string.format("Round end (%s) — total collected: %d", why, self.Stats.collected))
    end
    
    function K:OnDied()
        self:StopFarm()
        self.AwaitNextRound = true
        self.CharacterFrozen = false
        self:SetPhase(PHASE.DEAD, "Humanoid.Died")
    end
    
    function K:CaptureLobbySpawn()
        local _, hrp = getCharacter()
        if hrp and isLobbyY(hrp.Position.Y) then
            self.LobbySpawnCF = hrp.CFrame
        end
    end
    
    function K:SyncMidRound()
        if self.CoinsActive then
            return
        end
        local container = self:FindCoinContainer()
        if not container then
            return
        end
        if self:CountCollectableCoins() > 0 and self:IsAliveInRound() then
            log("Mid-round inject detected — starting farm")
            self:OnCoinsStarted(nil)
        end
    end
    
    
    function K:StartHeartbeat()
        local rescueAccum = 0
        self._maid:Give("heartbeat", RunService.Heartbeat:Connect(function(dt)
            if #K.DestroyQueue > 0 then
                K:PumpDestroyQueue()
            end
    
            if K.Running and not K.IsTweening and K.LastFarmCF then
                local _, hrp = getCharacter()
                if hrp then
                    if (hrp.Position - K.LastFarmCF.Position).Magnitude > 0.5 then
                        safe(function()
                            player.Character:PivotTo(K.LastFarmCF)
                        end)
                    end
                    K:ZeroVelocity(hrp)
                end
            end
    
            rescueAccum += dt
            if rescueAccum >= 0.25 then
                rescueAccum = 0
                local _, hrp, hum = getCharacter()
                if hrp and hum and hum.Health > 0 then
                    local y = hrp.Position.Y
                    local below = Config.VoidRescueBelowY or 15
                    if K.Running then
                        if K.PadTopY and K.LastFarmCF and y < K.PadTopY - below then
                            K:ApplyCF(K.LastFarmCF)
                        end
                    elseif K.PadTopY and K.PadStandCF then
                        if y < K.PadTopY - below then
                            K:ZeroVelocity(hrp)
                            safe(function()
                                player.Character:PivotTo(K.PadStandCF)
                            end)
                        end
                    elseif K.Phase ~= PHASE.ROUND and not (K.Phase == PHASE.LOADING and K.TeleportSeen) then
                        local standCF = K.LobbySpawnCF or K.LobbyStandCF
                        local topY = K.LobbyPadTopY or (standCF and standCF.Position.Y - 3.1)
                        if standCF and topY and y < topY - below
                            and hrp.AssemblyLinearVelocity.Y < -10
                        then
                            K:EnsureLobbyPad()
                            K:ZeroVelocity(hrp)
                            safe(function()
                                player.Character:PivotTo(standCF)
                            end)
                        end
                    end
                end
            end
        end))
    end
    
    
    function K:StartWatchdog()
        self._maid:Give("watchdog", task.spawn(function()
            while not K.Destroyed do
                task.wait(5)
                safe(function()
                    if K.CoinsActive and K.RoundStartedAt
                        and os.clock() - K.RoundStartedAt > (Config.RoundMaxDuration or 400)
                    then
                        log("Watchdog: round timeout — force lobby state")
                        K:OnRoundEnded("watchdog-timeout")
                        return
                    end
                    if K.CoinsActive and not K.Running and not K.AwaitNextRound
                        and Config.Enabled and Config.AutoStart and K:IsAliveInRound()
                        and K:CountCollectableCoins() > 0
                    then
                        K:StartFarm()
                    end
                    if K.Phase == PHASE.LOBBY and not K.CoinsActive then
                        local _, hrp = getCharacter()
                        if hrp and not isLobbyY(hrp.Position.Y) then
                            K:SyncMidRound()
                        end
                    end
                    K:EnsureCharacterClient()
                end)
            end
        end))
    end
    
    
    function K:GetDeviceChoice()
        if Config.AutoDevice == "Phone" or Config.AutoDevice == "Tablet" or Config.AutoDevice == "PC" then
            return Config.AutoDevice
        end
        local touch = false
        safe(function()
            touch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        end)
        return touch and "Phone" or "PC"
    end
    
    function K:InstallMainGui(device)
        local pg = player:WaitForChild("PlayerGui", 10)
        if not pg or pg:FindFirstChild("MainGUI") then
            return pg ~= nil
        end
        local templateName = "MainPC"
        safe(function()
            if GuiService:IsTenFootInterface() then
                templateName = "MainXbox"
            elseif device == "Phone" or device == "Tablet" then
                templateName = "MainMobile"
            end
        end)
        local ok = false
        safe(function()
            local guiRoot = ReplicatedStorage:FindFirstChild("GUI")
            local template = guiRoot and guiRoot:FindFirstChild(templateName)
            if not template then
                template = ReplicatedStorage:FindFirstChild("MainGUI")
            end
            if template then
                local clone = template:Clone()
                clone.Name = "MainGUI"
                clone.Parent = pg
                ok = true
            end
        end)
        return ok
    end
    
    function K:CompleteBootIfNeeded()
        if not Config.AutoSelectDevice then
            return false
        end
        local pg = player:FindFirstChild("PlayerGui")
        if not pg then
            return false
        end
        local deviceSelect = pg:FindFirstChild("DeviceSelect")
        local hasMain = pg:FindFirstChild("MainGUI") ~= nil
        if not deviceSelect and hasMain then
            return true
        end
        if not deviceSelect then
            return false
        end
        local device = self:GetDeviceChoice()
        if device == "PC" then
            device = "Phone"
        end
        pg:SetAttribute("Device", device)
        _G.MobileDevice = device
        safe(function()
            Remotes.Extras:WaitForChild("ChangeLastDevice", 5):FireServer(device)
        end)
        if not hasMain then
            self:InstallMainGui(device)
        end
        for _, name in { "DeviceSelect", "JoinPhone", "Join", "Join_Old", "Loading" } do
            local inst = pg:FindFirstChild(name)
            if inst then
                safe(function() inst:Destroy() end)
            end
        end
        safe(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
        end)
        safe(function()
            Remotes.Extras:WaitForChild("LoadedCompletely", 5):FireServer()
        end)
        log("Boot completed (device=" .. device .. ")")
        return true
    end
    
    function K:WaitForGameReady()
        if not Config.WaitForGameReady then
            self.GameReady = true
            return true
        end
        local deadline = os.clock() + (Config.GameReadyTimeout or 120)
        safe(function()
            local pg = player:WaitForChild("PlayerGui", 15)
            if pg then
                self._maid:Give("bootWatcher", pg.ChildAdded:Connect(function(child)
                    if K.GameReady then
                        return
                    end
                    if child.Name == "DeviceSelect" then
                        task.defer(function()
                            task.wait(0.5)
                            K:CompleteBootIfNeeded()
                        end)
                    end
                end))
            end
        end)
        while os.clock() < deadline and not self.Destroyed do
            local pg = player:FindFirstChild("PlayerGui")
            if pg then
                self:CompleteBootIfNeeded()
                local main = pg:FindFirstChild("MainGUI")
                local ds = pg:FindFirstChild("DeviceSelect")
                local loading = pg:FindFirstChild("Loading")
                local dsBlocking = ds and ds:IsA("ScreenGui") and ds.Enabled
                local loadBlocking = loading and loading:IsA("ScreenGui") and loading.Enabled
                if main and not dsBlocking and not loadBlocking then
                    if not pg:GetAttribute("Device") then
                        pg:SetAttribute("Device", self:GetDeviceChoice())
                    end
                    self.GameReady = true
                    self._maid:Clean("bootWatcher")
                    return true
                end
            end
            task.wait(0.5)
        end
        self.GameReady = true
        self._maid:Clean("bootWatcher")
        return false
    end
    
    
    function K:EnsureHud()
        if not Config.ShowHud or self.HudLabel then
            return
        end
        local parent = player:FindFirstChild("PlayerGui")
        if Exec.getHui then
            local ok, hui = pcall(Exec.getHui)
            if ok and hui then
                parent = hui
            end
        end
        if not parent then
            return
        end
        local gui = Instance.new("ScreenGui")
        gui.Name = "KaitunV2Hud"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 10000
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromOffset(220, 58)
        label.AutomaticSize = Enum.AutomaticSize.Y
        label.Position = UDim2.new(0.5, -110, 0, 8)
        label.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
        label.BackgroundTransparency = 0.3
        label.TextColor3 = Color3.fromRGB(180, 255, 190)
        label.TextSize = 13
        label.Font = Enum.Font.Code
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Text = "Kaitun V2"
        label.Parent = gui
        safe(function()
            Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
        end)
        gui.Parent = parent
        self.Hud = gui
        self.HudLabel = label
        self._maid:Give("hudGui", gui)
        self._maid:Give("hudLoop", task.spawn(function()
            while not K.Destroyed do
                K:UpdateHud()
                task.wait(Config.HudUpdateInterval or 1)
            end
        end))
    end
    
    function K:UpdateHud()
        local label = self.HudLabel
        if not label or not label.Parent then
            return
        end
        safe(function()
            local text = string.format(
                " [KaitunV2] %s%s | %s\n bag %d/%d | coins %d (%.0f/m)\n rounds %d | %s",
                self.Phase,
                self.Running and ":farm" or "",
                tostring(self:GetRole() or "-"),
                self.Stats.bagCurrent, self.Stats.bagMax,
                self:GetInventoryCoins(), self:GetInventoryCoinRate(),
                self.Stats.rounds,
                self.AwaitNextRound and "wait next" or "ok"
            )
            local summer = self.Summer2026HudLines and self:Summer2026HudLines()
            if summer and summer ~= "" then
                text = text .. "\n " .. summer
            end
            label.Text = text
        end)
    end
    
    
    function K:ApplyFpsCap()
        if not Config.LockFps then
            return
        end
        local fps = math.floor(tonumber(Config.FpsCap) or 0)
        if fps < 1 then
            return
        end
        if Exec.setFps then
            if safe(function() Exec.setFps(fps) end) then
                log("FPS capped at " .. fps)
            end
        else
            dbg("No setfpscap API on this executor")
        end
    end
    
    function K:StartAntiAfk()
        if not Config.AntiAfk then
            return
        end
        self._maid:Give("antiAfk", player.Idled:Connect(function()
            safe(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end))
    end
    
    function K:ArmAutoRejoin()
        if not Config.AutoRejoin then
            return
        end
        local function queueSelf()
            if Exec.queueTeleport and type(Config.RejoinScriptUrl) == "string" and Config.RejoinScriptUrl ~= "" then
                safe(function()
                    Exec.queueTeleport(string.format(
                        'getgenv().MM2KaitunV2Config = %s loadstring(game:HttpGet(%q))()',
                        "{}", Config.RejoinScriptUrl
                    ))
                end)
            end
        end
        self._maid:Give("rejoin", GuiService.ErrorMessageChanged:Connect(function(msg)
            if K.Destroyed or type(msg) ~= "string" or msg == "" then
                return
            end
            log("Disconnected (" .. msg .. ") — rejoining...")
            queueSelf()
            safe(function()
                TeleportService:Teleport(game.PlaceId, player)
            end)
            task.delay(10, function()
                if not K.Destroyed then
                    safe(function()
                        TeleportService:Teleport(game.PlaceId, player)
                    end)
                end
            end)
        end))
        self._maid:Give("teleportInit", player.OnTeleport:Connect(function(state)
            if state == Enum.TeleportState.Started then
                queueSelf()
            end
        end))
    end
    
    
    function K:BindCharacter(char)
        self.CharacterFrozen = false
        local token = self._roundToken
        task.defer(function()
            local hrp = char:WaitForChild("HumanoidRootPart", 15)
            local hum = char:WaitForChild("Humanoid", 10)
            if hum then
                self._maid:Give("charDied", hum.Died:Connect(function()
                    K:OnDied()
                end))
            end
            if not hrp then
                return
            end
            self:EnsureCharacterClient()
            self:MinimizeCharacter()
            task.wait(0.2)
            if isLobbyY(hrp.Position.Y) then
                if self.Phase == PHASE.DEAD then
                    self:SetPhase(PHASE.LOBBY, "respawn-lobby")
                end
                self:CaptureLobbySpawn()
                self:EnsureLobbyPad()
            elseif self.CoinsActive and not self.AwaitNextRound and token == self._roundToken then
                self:StartFarm()
            end
        end)
    end
    
    
    function K:ConnectRemotes()
        if not resolveRemotes() then
            log("WARNING: remotes not resolved — retrying in background")
            self._maid:Give("remoteRetry", task.spawn(function()
                while not K.Destroyed and not resolveRemotes() do
                    task.wait(2)
                end
                if not K.Destroyed then
                    K:ConnectRemotes()
                end
            end))
            return
        end
        self._maid:Clean("remoteRetry")
    
        self._maid:Give("rLoadingMap", Remotes.LoadingMap.OnClientEvent:Connect(function(mapName)
            safe(function() K:OnLoadingMap(mapName) end)
        end))
        self._maid:Give("rRoundStart", Remotes.RoundStart.OnClientEvent:Connect(function()
            safe(function() K:OnRoundStart() end)
        end))
        self._maid:Give("rCoinsStarted", Remotes.CoinsStarted.OnClientEvent:Connect(function(bags)
            safe(function() K:OnCoinsStarted(bags) end)
        end))
        self._maid:Give("rCoinCollected", Remotes.CoinCollected.OnClientEvent:Connect(function(coinType, current, max)
            safe(function() K:OnCoinCollected(coinType, current, max) end)
        end))
        self._maid:Give("rVictory", Remotes.VictoryScreen.OnClientEvent:Connect(function()
            safe(function() K:OnRoundEnded("VictoryScreen") end)
        end))
        self._maid:Give("rEndFade", Remotes.RoundEndFade.OnClientEvent:Connect(function()
            safe(function() K:OnRoundEnded("RoundEndFade") end)
        end))
        if Remotes.TeleportToPart
            and (Remotes.TeleportToPart:IsA("RemoteEvent") or Remotes.TeleportToPart:IsA("UnreliableRemoteEvent"))
        then
            self._maid:Give("rTeleport", Remotes.TeleportToPart.OnClientEvent:Connect(function(spawnPart)
                safe(function() K:OnTeleportToPart(spawnPart) end)
            end))
        end
        dbg("Remotes connected")
    end
    
    
    function K:Destroy(why)
        if self.Destroyed then
            return
        end
        self.Destroyed = true
        self:StopFarm()
        self._maid:DestroyAll()
        self:RestoreRemoteHandlerFilter()
        self:RemoveAllPads()
        self:UnfreezeCharacter()
        safe(function()
            if Config.Disable3DRender then
                RunService:Set3dRenderingEnabled(true)
            end
        end)
        if G.MM2KaitunV2 == self then
            G.MM2KaitunV2 = nil
        end
        log("Destroyed (" .. tostring(why or "manual") .. ")")
    end
    
    
    local Summer2026 = {
        _ready = false,
        _warnedInactive = false,
        _dailyDone = false,
        _autoswapLoopActive = false,
        _autoswapNextSendAt = nil,
        _autoswapStatus = nil,
        _autoswapOption = nil,
        _hasGodly = false,
        _accountOpsWarnedNoKey = false,
        _eventRemotes = nil,
        _shopRemotes = nil,
        _eventInfo = nil,
        _questsConfig = nil,
        _boxPrice = nil,
        _coinBoxPrice = nil,
        _summerOpenBusy = false,
        _coinBoxOpenBusy = false,
        _dailyProgress = nil,
        _dailyTrackId = nil,
        _dailyPollAt = nil,
        _dailyPollBusy = false,
        _serverProfile = nil,
        _godlyScanStamp = nil,
        _profileSignalsConnected = false,
        _sync = nil,
        _levelModule = nil,
    }

    local DAILY_COMPLETE_PROGRESS = 960
    local DAILY_POLL_INTERVAL = 10
    
    local SUMMER_QUEST_FALLBACK = {
        Rewards = { 1, 6, 12, 20 },
        Daily = { 240, 480, 720, 960 },
        DailyCoins = { 240, 480, 720, 960 },
        Weekly = { 6, 18, 26 },
    }
    
    local function summerPrint(msg)
        print("[S26] " .. tostring(msg))
    end

    local function cratePrint(msg)
        print("[Crate] " .. tostring(msg))
    end

    local function accountOpsHttpRequest(opts)
        if typeof(syn) == "table" and syn.request then
            return syn.request(opts)
        end
        if typeof(http) == "table" and http.request then
            return http.request(opts)
        end
        if typeof(request) == "function" then
            return request(opts)
        end
        if HttpService.RequestAsync then
            return HttpService:RequestAsync(opts)
        end
    end

    local function accountOpsHttpOk(resp)
        if not resp then
            return false
        end
        local code = resp.StatusCode or resp.status or resp.Status
        local numCode = code and tonumber(code)
        if numCode and numCode >= 200 and numCode < 300 then
            return true
        end
        return resp.Success == true or resp.success == true
    end

    local function summerGetSync()
        if Summer2026._sync then
            return Summer2026._sync
        end
        local ok, sync = pcall(function()
            return require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
        end)
        if ok then
            Summer2026._sync = sync
            return sync
        end
    end

    local function summerGetLevelModule()
        if Summer2026._levelModule then
            return Summer2026._levelModule
        end
        local ok, mod = pcall(function()
            local modules = ReplicatedStorage:FindFirstChild("Modules")
            modules = modules and modules:FindFirstChild("LevelModule")
            return modules and require(modules)
        end)
        if ok and type(mod) == "table" then
            Summer2026._levelModule = mod
            return mod
        end
    end

    local function discordWebhookResolveGodlyUrl()
        if Config.DiscordWebhookGodlyEnabled == false then
            return ""
        end
        local url = Config.DiscordWebhookGodly
        if type(url) == "string" and url ~= "" then
            return url
        end
        local niAuto = type(G.NiAutoConfig) == "table" and G.NiAutoConfig or nil
        if niAuto and type(niAuto.DiscordWebhookGodly) == "string" and niAuto.DiscordWebhookGodly ~= "" then
            return niAuto.DiscordWebhookGodly
        end
        return ""
    end

    local function summerItemIsChroma(data, itemId, rewardTable)
        if type(rewardTable) == "table" and rewardTable.Chroma == true then
            return true
        end
        if type(data) == "table" and data.Chroma == true then
            return true
        end
        if type(itemId) == "string" and itemId:sub(-6) == "Chroma" then
            return true
        end
        return false
    end

    local function summerResolveRewardItem(rewardId)
        local rewardTable = type(rewardId) == "table" and rewardId or nil
        local itemId = rewardId
        if rewardTable then
            itemId = rewardTable.Id or rewardTable.ItemId or rewardTable.Name or rewardTable[1]
        end
        if type(itemId) ~= "string" or itemId == "" then
            return nil
        end

        local sync = summerGetSync()
        if not sync then
            return {
                id = itemId,
                name = itemId,
                rarity = nil,
                type = nil,
                chroma = summerItemIsChroma(nil, itemId, rewardTable),
            }
        end

        local lookup = {
            { sync.Weapons, "Weapons" },
            { sync.Guns, "Guns" },
            { sync.Knives, "Knives" },
            { sync.Pets, "Pets" },
            { sync.Item, "Item" },
        }
        for _, entry in lookup do
            local bucket, itemType = entry[1], entry[2]
            local data = type(bucket) == "table" and bucket[itemId]
            if type(data) == "table" and data.Rarity and sync.Rarities and sync.Rarities[data.Rarity] then
                return {
                    id = itemId,
                    name = data.Name or data.ItemName or itemId,
                    rarity = data.Rarity,
                    type = itemType,
                    chroma = summerItemIsChroma(data, itemId, rewardTable),
                }
            end
        end

        return {
            id = itemId,
            name = itemId,
            rarity = nil,
            type = nil,
            chroma = summerItemIsChroma(nil, itemId, rewardTable),
        }
    end

    local function summerIsGodlyRarity(rarity)
        return type(rarity) == "string" and string.lower(rarity) == "godly"
    end

    local function summerScanOwnedGodly(owned, checked)
        for key, val in owned do
            local itemId
            if type(key) == "string" then
                if type(val) ~= "number" or val > 0 then
                    itemId = key
                end
            elseif type(val) == "string" then
                itemId = val
            end
            if itemId and itemId ~= "" then
                checked += 1
                local item = summerResolveRewardItem(itemId)
                if item and summerIsGodlyRarity(item.rarity) then
                    return item, checked
                end
            end
        end
        return nil, checked
    end

    local function summerProfileHasGodlyItem(pd)
        if type(pd) ~= "table" then
            return false, nil, 0
        end
        local checked = 0
        for _, category in pd do
            if type(category) == "table" and type(category.Owned) == "table" then
                local item
                item, checked = summerScanOwnedGodly(category.Owned, checked)
                if item then
                    return true, item, checked
                end
            end
        end
        if type(pd.Uniques) == "table" then
            for _, unique in pd.Uniques do
                if type(unique) == "table" and type(unique.BaseItem) == "string" then
                    checked += 1
                    local item = summerResolveRewardItem(unique.BaseItem)
                    if item and summerIsGodlyRarity(item.rarity) then
                        return true, item, checked
                    end
                end
            end
        end
        return false, nil, checked
    end

    local function summerSendGodlyWebhook(rewardItem, boxId)
        local url = discordWebhookResolveGodlyUrl()
        if url == "" or type(rewardItem) ~= "table" then
            return
        end

        local username = player and player.Name or "?"
        local itemName = rewardItem.name or rewardItem.id or "?"
        local rarity = rewardItem.rarity or "Godly"
        local boxName = boxId or Config.Summer2026BoxId
        local chromaSuffix = rewardItem.chroma and " | Chroma: Yes" or ""
        local content = string.format(
            "**Godly unbox** | `%s` got **%s** (%s) from `%s`%s",
            username,
            itemName,
            rarity,
            boxName,
            chromaSuffix
        )

        task.spawn(function()
            pcall(function()
                local resp = accountOpsHttpRequest({
                    Url = url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                    },
                    Body = HttpService:JSONEncode({
                        content = content,
                    }),
                })
                if accountOpsHttpOk(resp) then
                    summerPrint("Discord godly webhook sent for " .. tostring(rewardItem.id))
                else
                    summerPrint("Discord godly webhook failed for " .. tostring(rewardItem.id))
                end
            end)
        end)
    end

    local function accountOpsResolveCredentials()
        local key = Config.AccountOpsApiKey
        if type(key) == "string" and key ~= "" then
            return key, Config.AccountOpsBaseUrl
        end
        local cfg = type(G.Config) == "table" and G.Config or nil
        local niAuto = type(G.NiAutoConfig) == "table" and G.NiAutoConfig or nil
        if niAuto and type(niAuto.AccountOpsApiKey) == "string" and niAuto.AccountOpsApiKey ~= "" then
            return niAuto.AccountOpsApiKey, niAuto.AccountOpsBaseUrl or Config.AccountOpsBaseUrl
        end
        local fv = (cfg and cfg.FarmersV5) or (niAuto and niAuto.FarmersV5)
        if type(fv) == "table" and type(fv.APIKey) == "string" and fv.APIKey ~= "" then
            return fv.APIKey, fv.BaseUrl or Config.AccountOpsBaseUrl
        end
        return "", Config.AccountOpsBaseUrl
    end

    local function summerGetQuestsConfig()
        return Summer2026._questsConfig
    end

    local function summerGetEventQuests(pd, title)
        title = title or Config.Summer2026EventTitle
        if type(pd) ~= "table" or type(pd[title]) ~= "table" then
            return nil, title
        end
        return pd[title].Quests, title
    end

    local function summerGetTrackMaxTier(trackId)
        local maxTier = 0
        local cfg = summerGetQuestsConfig()
        if cfg and cfg[trackId] and cfg[trackId].Quests then
            for _, q in cfg[trackId].Quests do
                if q.ChallengeAmount > maxTier then
                    maxTier = q.ChallengeAmount
                end
            end
        elseif SUMMER_QUEST_FALLBACK[trackId] then
            for _, challengeAmount in SUMMER_QUEST_FALLBACK[trackId] do
                if challengeAmount > maxTier then
                    maxTier = challengeAmount
                end
            end
        end
        return maxTier
    end

    local function summerResolveDailyTrackId(cfg, quests)
        if Summer2026._dailyTrackId then
            return Summer2026._dailyTrackId
        end

        cfg = cfg or summerGetQuestsConfig()
        quests = type(quests) == "table" and quests or nil

        if type(quests) == "table" then
            if type(quests.DailyCoins) == "table" then
                Summer2026._dailyTrackId = "DailyCoins"
                return "DailyCoins"
            end
            if type(quests.Daily) == "table" then
                Summer2026._dailyTrackId = "Daily"
                return "Daily"
            end
        end

        if cfg and cfg.DailyCoins then
            Summer2026._dailyTrackId = "DailyCoins"
            return "DailyCoins"
        end
        if cfg and cfg.Daily then
            Summer2026._dailyTrackId = "Daily"
            return "Daily"
        end

        if type(quests) == "table" then
            for trackId, trackData in quests do
                if type(trackData) == "table" then
                    local progress = tonumber(trackData.Progress) or 0
                    if progress >= DAILY_COMPLETE_PROGRESS then
                        Summer2026._dailyTrackId = trackId
                        return trackId
                    end
                end
            end
        end

        Summer2026._dailyTrackId = "DailyCoins"
        return "DailyCoins"
    end

    local function summerReadProfileDailyProgress(pd, title)
        title = title or Config.Summer2026EventTitle
        if type(pd) ~= "table" then
            return nil, nil, title
        end

        local quests = summerGetEventQuests(pd, title)
        local cfg = summerGetQuestsConfig()
        local trackId = summerResolveDailyTrackId(cfg, quests)
        if type(quests) == "table" and type(quests[trackId]) == "table" then
            local progress = tonumber(quests[trackId].Progress)
            if progress ~= nil then
                return progress, trackId, title
            end
        end

        if type(quests) == "table" then
            local bestProgress, bestTrack = nil, trackId
            for questTrackId, trackData in quests do
                if type(trackData) == "table" then
                    local questProgress = tonumber(trackData.Progress)
                    if questProgress ~= nil and questProgress >= DAILY_COMPLETE_PROGRESS then
                        Summer2026._dailyTrackId = questTrackId
                        return questProgress, questTrackId, title
                    end
                    if questProgress ~= nil then
                        local maxTier = summerGetTrackMaxTier(questTrackId)
                        if maxTier >= DAILY_COMPLETE_PROGRESS
                            and (bestProgress == nil or questProgress >= bestProgress)
                        then
                            bestProgress = questProgress
                            bestTrack = questTrackId
                        end
                    end
                end
            end
            if bestProgress ~= nil then
                Summer2026._dailyTrackId = bestTrack
                return bestProgress, bestTrack, title
            end
        end

        return nil, trackId, title
    end

    local function summerCacheDailyProgress(progress, source, trackId)
        progress = tonumber(progress)
        if progress == nil then
            return
        end
        local prev = Summer2026._dailyProgress
        if source == "profile" and prev ~= nil and progress <= prev then
            return
        end
        if trackId then
            Summer2026._dailyTrackId = trackId
        end
        if prev == progress then
            return
        end
        Summer2026._dailyProgress = progress
        dbg(string.format(
            "daily progress %s → %d/%d (%s)",
            prev and tostring(prev) or "?",
            progress,
            DAILY_COMPLETE_PROGRESS,
            tostring(source or "?")
        ))
        if progress >= DAILY_COMPLETE_PROGRESS
            and (prev == nil or prev < DAILY_COMPLETE_PROGRESS)
        then
            summerPrint(string.format("daily complete (%d/%d)", progress, DAILY_COMPLETE_PROGRESS))
        end
    end

    local function summerGetProfile(self)
        local pd = self.ProfileData or self:TryRequireProfileData()
        if pd then
            self.ProfileData = pd
        end
        return pd
    end

    local function summerRequestServerProfile()
        if Summer2026._dailyPollBusy then
            return Summer2026._serverProfile
        end
        local now = os.clock()
        if Summer2026._dailyPollAt and now < Summer2026._dailyPollAt then
            return Summer2026._serverProfile
        end
        Summer2026._dailyPollAt = now + DAILY_POLL_INTERVAL
        Summer2026._dailyPollBusy = true
        task.spawn(function()
            local ok, fresh = pcall(function()
                local inv = ReplicatedStorage:FindFirstChild("Remotes")
                inv = inv and inv:FindFirstChild("Inventory")
                local getPd = inv and inv:FindFirstChild("GetProfileData")
                if getPd and getPd:IsA("RemoteFunction") then
                    return getPd:InvokeServer()
                end
            end)
            Summer2026._dailyPollBusy = false
            if not ok or type(fresh) ~= "table" then
                return
            end
            Summer2026._serverProfile = fresh
            local progress, trackId = summerReadProfileDailyProgress(fresh)
            if progress ~= nil then
                summerCacheDailyProgress(progress, "server", trackId)
            end
        end)
        return Summer2026._serverProfile
    end

    local function summerPollDailyFromServer()
        if (Summer2026._dailyProgress or 0) >= DAILY_COMPLETE_PROGRESS then
            return
        end
        summerRequestServerProfile()
    end

    local function summerGetDailyProgress(self)
        summerPollDailyFromServer()
        local progress = summerReadProfileDailyProgress(summerGetProfile(self))
        if progress ~= nil then
            summerCacheDailyProgress(progress, "profile")
        end
        return Summer2026._dailyProgress or 0
    end

    local function accountOpsAutoswapComplete(apiKey, baseUrl, option)
        local url = tostring(baseUrl or Config.AccountOpsBaseUrl or "https://accountops.org"):gsub("/$", "")
            .. "/api/accounts/autoswap-complete"
        local resp = accountOpsHttpRequest({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-Api-Key"] = apiKey,
            },
            Body = HttpService:JSONEncode({
                username = player.Name,
                option = option,
            }),
        })
        return accountOpsHttpOk(resp), resp
    end

    function K:ShopRemotesResolve()
        if Summer2026._shopRemotes then
            return true
        end
        local shop = ReplicatedStorage:FindFirstChild("Remotes")
        shop = shop and shop:FindFirstChild("Shop")
        if not shop or not shop:FindFirstChild("OpenCrate") then
            return false
        end
        Summer2026._shopRemotes = shop
        return true
    end
    
    function K:Summer2026Resolve()
        if Summer2026._ready then
            return true
        end
        if not Config.EnableSummer2026
            and not Config.AccountOpsAutoswapOnDailyComplete then
            return false
        end
    
        local events = ReplicatedStorage:FindFirstChild("Remotes")
        events = events and events:FindFirstChild("Events")
        local remotes = events and events:FindFirstChild(Config.Summer2026EventTitle .. "Remotes")
        if not remotes then
            if not Summer2026._warnedInactive then
                summerPrint("event remotes missing — skip (event not live?)")
                Summer2026._warnedInactive = true
            end
            return false
        end
    
        local shop = ReplicatedStorage:FindFirstChild("Remotes")
        shop = shop and shop:FindFirstChild("Shop")
        if not shop or not shop:FindFirstChild("OpenCrate") then
            return false
        end
    
        Summer2026._eventRemotes = remotes
        Summer2026._shopRemotes = shop
    
        safe(function()
            local sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
            local entry = sync.NewShop[Config.Summer2026BoxId]
            if entry and entry.Price then
                Summer2026._boxPrice = entry.Price[Config.Summer2026KeyCurrency]
                    or entry.Price.Shells
            end
        end)
        if not Summer2026._boxPrice or Summer2026._boxPrice <= 0 then
            Summer2026._boxPrice = 1
        end
    
        safe(function()
            local eis = require(ReplicatedStorage:WaitForChild("SharedServices"):WaitForChild("EventInfoService"))
            eis:WaitForInitializedAsync()
            local main = eis:GetMainEvent()
            if main and main.Title == Config.Summer2026EventTitle then
                Summer2026._eventInfo = main
                if main.EventStartInfo and main.EventStartInfo.Quests then
                    Summer2026._questsConfig = main.EventStartInfo.Quests
                end
            end
        end)
    
        Summer2026._ready = true
        summerPrint(string.format(
            "ready — box=%s shells>=%s",
            Config.Summer2026BoxId,
            Config.MinShellsForBox > 0 and Config.MinShellsForBox or Summer2026._boxPrice
        ))
        return true
    end
    
    function K:Summer2026GetShells()
        local pd = summerGetProfile(self)
        if not pd or not pd.Materials or not pd.Materials.Owned then
            return 0
        end
        return pd.Materials.Owned[Config.Summer2026KeyCurrency] or 0
    end
    
    function K:Summer2026GetBoxPrice()
        if Config.MinShellsForBox and Config.MinShellsForBox > 0 then
            return Config.MinShellsForBox
        end
        return Summer2026._boxPrice or 1
    end

    function K:AccountOpsGetShellSwapThreshold()
        return tonumber(Config.AccountOpsAutoswapMaxShells) or 120
    end

    function K:AccountOpsGetMinAutoswapLevel()
        return tonumber(Config.AccountOpsAutoswapMinLevel) or 10
    end

    function K:GetPlayerLevel()
        local pd = summerGetProfile(self)
        if type(pd) ~= "table" or pd.NewXP == nil then
            return 0
        end
        local levelMod = summerGetLevelModule()
        if not levelMod or type(levelMod.GetLevel) ~= "function" then
            return 0
        end
        local ok, level = pcall(function()
            return levelMod.GetLevel(pd.NewXP)
        end)
        if not ok then
            return 0
        end
        return tonumber(level) or 0
    end
    
    function K:Summer2026GetQuestTiers(trackId)
        local cfg = Summer2026._questsConfig
        if cfg and cfg[trackId] and cfg[trackId].Quests then
            local tiers = {}
            for i, q in cfg[trackId].Quests do
                tiers[i] = q.ChallengeAmount
            end
            return tiers
        end
        return SUMMER_QUEST_FALLBACK[trackId]
    end
    
    function K:Summer2026IsQuestTierClaimed(eventData, trackId, tierIndex, progress, challengeAmount)
        if type(eventData) ~= "table" then
            return progress < challengeAmount
        end
        local quests = eventData.Quests
        local track = quests and quests[trackId]
        if type(track) ~= "table" then
            return progress < challengeAmount
        end
        local claimed = track.Claimed
        if type(claimed) == "table" then
            return claimed[tierIndex] == true or claimed[tostring(tierIndex)] == true
        end
        if track.ClaimedRewards and type(track.ClaimedRewards) == "table" then
            return track.ClaimedRewards[tierIndex] == true or track.ClaimedRewards[tostring(tierIndex)] == true
        end
        return progress < challengeAmount
    end
    
    function K:Summer2026ClaimQuests()
        if not self:Summer2026Resolve() then
            return 0
        end
        local pd = summerGetProfile(self)
        if not pd then
            return 0
        end
    
        local eventData = pd[Config.Summer2026EventTitle]
        if type(eventData) ~= "table" then
            eventData = { Quests = {} }
        end
        eventData.Quests = eventData.Quests or {}
    
        local remotes = Summer2026._eventRemotes
        local claimRemote = remotes:FindFirstChild("ClaimEventQuestReward")
            or remotes:FindFirstChild("ClaimQuestReward")
            or remotes:FindFirstChild("ClaimEventQuest")
        local claimed = 0
    
        for _, trackId in { "Rewards", "Daily", "Weekly" } do
            local tiers = self:Summer2026GetQuestTiers(trackId)
            if not tiers then
                continue
            end
            local trackData = eventData.Quests[trackId]
            local progress = type(trackData) == "table" and (trackData.Progress or 0) or 0
    
            for tierIndex, challengeAmount in tiers do
                if progress >= challengeAmount
                    and not self:Summer2026IsQuestTierClaimed(eventData, trackId, tierIndex, progress, challengeAmount)
                then
                    if claimRemote and claimRemote:IsA("RemoteEvent") then
                        local ok = pcall(function()
                            claimRemote:FireServer(trackId, tierIndex)
                        end)
                        if ok then
                            claimed += 1
                            summerPrint(string.format("claim quest %s tier %s (progress %d/%d)", trackId, tierIndex, progress, challengeAmount))
                        end
                    else
                        dbg(string.format(
                            "quest %s tier %s ready (%d/%d) — no claim remote (server may auto-grant)",
                            trackId, tierIndex, progress, challengeAmount
                        ))
                    end
                end
            end
        end
    
        return claimed
    end
    
    function K:Summer2026ClaimBattlePass()
        if not Config.Summer2026ClaimBattlePass or not self:Summer2026Resolve() then
            return 0
        end
        local pd = summerGetProfile(self)
        if not pd then
            return 0
        end
    
        local eventData = pd[Config.Summer2026EventTitle]
        if type(eventData) ~= "table" then
            return 0
        end
    
        local remotes = Summer2026._eventRemotes
        local claimRemote = remotes:FindFirstChild("ClaimBattlePassReward")
        if not claimRemote or not claimRemote:IsA("RemoteEvent") then
            return 0
        end
    
        local currentTier = tonumber(eventData.CurrentTier) or 0
        eventData.ClaimedRewards = eventData.ClaimedRewards or {}
        local claimed = 0
    
        local total = 25
        if Summer2026._eventInfo
            and Summer2026._eventInfo.EventStartInfo
            and Summer2026._eventInfo.EventStartInfo.BattlePass
        then
            total = Summer2026._eventInfo.EventStartInfo.BattlePass.TotalTiers or total
        end
    
        for i = 1, total do
            local key = tostring(i)
            if i <= currentTier
                and eventData.ClaimedRewards[key] ~= true
                and eventData.ClaimedRewards[i] ~= true
            then
                local ok = pcall(function()
                    claimRemote:FireServer(key)
                end)
                if ok then
                    claimed += 1
                    summerPrint("claim battle pass tier " .. key)
                end
            end
        end
    
        return claimed
    end

    local function shopOpenCrate(shop, boxId, category, currency)
        local openCrate = shop:FindFirstChild("OpenCrate")
        local crateComplete = shop:FindFirstChild("CrateComplete")
        if not openCrate or not openCrate:IsA("RemoteFunction") then
            return false
        end

        local rewardId
        local okOpen = pcall(function()
            rewardId = openCrate:InvokeServer(boxId, category, currency)
        end)
        if not okOpen or not rewardId then
            return false
        end

        if crateComplete and crateComplete:IsA("RemoteEvent") then
            pcall(function()
                crateComplete:FireServer(rewardId)
            end)
        end

        return true, rewardId
    end

    local function handleCrateGodlyReward(rewardId, boxId, logFn)
        local rewardItem = summerResolveRewardItem(rewardId)
        if rewardItem and summerIsGodlyRarity(rewardItem.rarity) then
            Summer2026._hasGodly = true
            logFn(string.format(
                "Godly unboxed (%s) — autoswap will use option %d",
                tostring(rewardItem.name or rewardItem.id),
                tonumber(Config.AccountOpsAutoswapGodlyOption) or 3
            ))
            summerSendGodlyWebhook(rewardItem, boxId)
        end
    end
    
    function K:Summer2026BuyAndOpenBox()
        if not Config.Summer2026AutoUnbox or not self:Summer2026Resolve() then
            return false
        end
    
        local price = self:Summer2026GetBoxPrice()
        local shells = self:Summer2026GetShells()
        if shells < price then
            return false
        end
    
        local shop = Summer2026._shopRemotes
        local okOpen, rewardId = shopOpenCrate(
            shop,
            Config.Summer2026BoxId,
            "MysteryBox",
            Config.Summer2026KeyCurrency
        )
        if not okOpen then
            summerPrint("OpenCrate failed for " .. Config.Summer2026BoxId)
            return false
        end
    
        summerPrint(string.format(
            "opened %s (-%d shells, reward=%s)",
            Config.Summer2026BoxId,
            price,
            tostring(rewardId)
        ))

        handleCrateGodlyReward(rewardId, Config.Summer2026BoxId, summerPrint)
        return true
    end

    function K:CoinBoxGetPrice()
        if Config.CoinBoxMinCoins and Config.CoinBoxMinCoins > 0 then
            return Config.CoinBoxMinCoins
        end
        if not Summer2026._coinBoxPrice then
            safe(function()
                local sync = summerGetSync()
                local entry = sync and sync.NewShop[Config.CoinBoxId]
                if entry and entry.Price then
                    Summer2026._coinBoxPrice = entry.Price[Config.CoinBoxCurrency]
                        or entry.Price.Coins
                end
            end)
        end
        return Summer2026._coinBoxPrice or 1000
    end

    function K:CoinBoxBuyAndOpen()
        if not Config.EnableCoinBoxAutoUnbox or not self:ShopRemotesResolve() then
            return false
        end

        local price = self:CoinBoxGetPrice()
        local reserve = tonumber(Config.CoinBoxReserveCoins) or 0
        local coins = self:GetInventoryCoins()
        if coins < price + reserve then
            return false
        end

        local shop = Summer2026._shopRemotes
        local okOpen, rewardId = shopOpenCrate(
            shop,
            Config.CoinBoxId,
            Config.CoinBoxCategory or "MysteryBox",
            Config.CoinBoxCurrency or "Coins"
        )
        if not okOpen then
            cratePrint("OpenCrate failed for " .. tostring(Config.CoinBoxId))
            return false
        end

        cratePrint(string.format(
            "opened %s (-%d coins, reward=%s)",
            Config.CoinBoxId,
            price,
            tostring(rewardId)
        ))

        handleCrateGodlyReward(rewardId, Config.CoinBoxId, cratePrint)
        return true
    end

    local function spawnParallelCrateOpen(self, fn, busyKey)
        if Summer2026[busyKey] then
            return
        end
        Summer2026[busyKey] = true
        task.spawn(function()
            safe(function()
                fn(self)
            end)
            Summer2026[busyKey] = false
        end)
    end

    function K:ConnectSummer2026ProfileSignals()
        if Summer2026._profileSignalsConnected or Summer2026._dailyDone then
            return
        end

        local title = Config.Summer2026EventTitle
        local remotes = Summer2026._eventRemotes
        if not remotes then
            safe(function()
                local events = ReplicatedStorage:WaitForChild("Remotes", 15)
                events = events and events:WaitForChild("Events", 15)
                remotes = events and events:WaitForChild(title .. "Remotes", 15)
            end)
        end
        if not remotes then
            return
        end

        Summer2026._profileSignalsConnected = true
        Summer2026._eventRemotes = remotes

        local function onDailyProgress(progress, trackId)
            if Summer2026._dailyDone then
                return
            end
            summerCacheDailyProgress(progress, "event", trackId)
            if tonumber(progress) and tonumber(progress) >= DAILY_COMPLETE_PROGRESS then
                self:AccountOpsTagOnDailyComplete()
            end
        end

        local function readDailyFromEventVal(val)
            if type(val) ~= "table" or type(val.Quests) ~= "table" then
                return
            end
            local dailyTrackId = summerResolveDailyTrackId(summerGetQuestsConfig(), val.Quests)
            local track = val.Quests[dailyTrackId]
            if type(track) == "table" and track.Progress ~= nil then
                onDailyProgress(track.Progress, dailyTrackId)
                return
            end
            for questTrackId, questTrack in val.Quests do
                if type(questTrack) == "table" and questTrack.Progress ~= nil
                    and summerGetTrackMaxTier(questTrackId) >= DAILY_COMPLETE_PROGRESS
                then
                    onDailyProgress(questTrack.Progress, questTrackId)
                end
            end
        end

        local eqp = remotes:FindFirstChild("EventQuestProgressed")
        if eqp and eqp:IsA("RemoteEvent") then
            self._maid:Give("summerEventQuestProgressed", eqp.OnClientEvent:Connect(function(track, progress)
                if track == Summer2026._dailyTrackId
                    or track == "DailyCoins"
                    or track == "Daily"
                    or summerGetTrackMaxTier(track) >= DAILY_COMPLETE_PROGRESS
                then
                    onDailyProgress(progress, track)
                end
            end))
        end

        safe(function()
            local inv = ReplicatedStorage:WaitForChild("Remotes", 10)
            inv = inv and inv:WaitForChild("Inventory", 10)
            if not inv then
                return
            end

            local profChanged = inv:FindFirstChild("ProfileDataChanged")
            if profChanged and profChanged:IsA("BindableEvent") then
                profChanged = profChanged.Event
            end
            if typeof(profChanged) == "RBXScriptSignal"
                or (type(profChanged) == "table" and type(profChanged.Connect) == "function")
            then
                self._maid:Give("summerProfileDataChanged", profChanged:Connect(function(key, val)
                    if key == title then
                        readDailyFromEventVal(val)
                    end
                end))
            end

            local changeProf = inv:FindFirstChild("ChangeProfileData")
            if changeProf and changeProf:IsA("RemoteEvent") then
                self._maid:Give("summerChangeProfileData", changeProf.OnClientEvent:Connect(function(key, val)
                    if key == title then
                        readDailyFromEventVal(val)
                    end
                end))
            end
        end)

        local pd = summerGetProfile(self)
        local progress, trackId = summerReadProfileDailyProgress(pd, title)
        if progress ~= nil then
            onDailyProgress(progress, trackId)
        end
    end

    function K:AccountOpsAutoswapConditionsMet()
        self:Summer2026Resolve()
        if summerGetDailyProgress(self) < DAILY_COMPLETE_PROGRESS then
            return false
        end
        if self:GetPlayerLevel() < self:AccountOpsGetMinAutoswapLevel() then
            return false
        end
        local maxShells = self:AccountOpsGetShellSwapThreshold()
        return self:Summer2026GetShells() < maxShells
    end

    function K:AccountOpsHasGodlyItem()
        if Summer2026._hasGodly then
            return true
        end

        local source = "server"
        local found, item, checked = summerProfileHasGodlyItem(summerRequestServerProfile())
        if not found then
            local localFound, localItem, localChecked = summerProfileHasGodlyItem(summerGetProfile(self))
            if localFound or localChecked > checked then
                source = "profile"
                found, item, checked = localFound, localItem, localChecked
            end
        end

        local stamp = found
            and ("found:" .. tostring(item and (item.name or item.id)))
            or ("none:" .. tostring(checked) .. ":" .. source)
        if Summer2026._godlyScanStamp ~= stamp then
            Summer2026._godlyScanStamp = stamp
            if found then
                dbg(string.format(
                    "godly scan: found %s (%s) via %s",
                    tostring(item and (item.name or item.id)),
                    tostring(item and item.rarity),
                    source
                ))
            else
                dbg(string.format("godly scan: none (%d items checked, %s)", checked, source))
            end
        end

        if found then
            Summer2026._hasGodly = true
            return true
        end
        return false
    end

    function K:AccountOpsResolveSwapOption()
        local baseOption = tonumber(Config.AccountOpsAutoswapOption) or 2
        local godlyOption = tonumber(Config.AccountOpsAutoswapGodlyOption) or 3
        if self:AccountOpsHasGodlyItem() then
            return godlyOption, true
        end
        return baseOption, false
    end

    function K:Summer2026HudLines()
        if not Config.EnableSummer2026 and not Config.AccountOpsAutoswapOnDailyComplete then
            return nil
        end
        local progress = tonumber(summerGetDailyProgress(self)) or 0
        local dailyDone = progress >= DAILY_COMPLETE_PROGRESS
        local dailyStr = dailyDone
            and "Daily: DONE"
            or string.format("Daily: %d/%d", progress, DAILY_COMPLETE_PROGRESS)

        local option = Summer2026._autoswapOption
        local optSuffix = option and string.format(" (opt %d)", option) or ""
        local swapStr
        if Summer2026._autoswapLoopActive then
            if Summer2026._autoswapStatus == "swapping" then
                swapStr = "wait next | swapping..." .. optSuffix
            elseif Summer2026._autoswapNextSendAt then
                local remain = math.max(0, math.ceil(Summer2026._autoswapNextSendAt - os.clock()))
                swapStr = string.format("wait next | %ds%s", remain, optSuffix)
            else
                swapStr = "wait next | ..." .. optSuffix
            end
        elseif not Config.AccountOpsAutoswapOnDailyComplete then
            swapStr = "wait next | off"
        elseif not dailyDone then
            swapStr = "wait next | need daily"
        elseif self:GetPlayerLevel() < self:AccountOpsGetMinAutoswapLevel() then
            swapStr = string.format("wait next | need lv %d", self:AccountOpsGetMinAutoswapLevel())
        elseif self:Summer2026GetShells() >= self:AccountOpsGetShellSwapThreshold() then
            swapStr = string.format("wait next | shells>=%d", self:AccountOpsGetShellSwapThreshold())
        else
            swapStr = "wait next | idle"
        end

        return dailyStr .. "\n " .. swapStr
    end

    function K:AccountOpsTagOnDailyComplete()
        if Config.AccountOpsAutoswapOnDailyComplete ~= true then
            return
        end
        if Summer2026._autoswapLoopActive then
            return
        end
        if not self:AccountOpsAutoswapConditionsMet() then
            return
        end

        local apiKey, baseUrl = accountOpsResolveCredentials()
        if apiKey == "" then
            if not Summer2026._accountOpsWarnedNoKey then
                Summer2026._accountOpsWarnedNoKey = true
                warn("[KaitunV2] AccountOps skipped — no API key (set Config.AccountOpsApiKey, NiAutoConfig.AccountOpsApiKey, or FarmersV5.APIKey)")
            end
            return
        end

        local option = self:AccountOpsResolveSwapOption()
        self:AccountOpsStartAutoswapLoop({ apiKey = apiKey, baseUrl = baseUrl, option = option })
    end

    function K:AccountOpsStartAutoswapLoop(ctx)
        if Summer2026._autoswapLoopActive then
            return
        end
        Summer2026._autoswapLoopActive = true

        local delaySec = tonumber(Config.AccountOpsAutoswapDelaySeconds) or 60
        if delaySec < 0 then
            delaySec = 0
        end
        local interval = tonumber(Config.AccountOpsAutoswapIntervalSeconds) or 60
        if interval < 1 then
            interval = 1
        end

        summerPrint(string.format(
            "Daily done & shells < %d — autoswap in %ds, then every %ds",
            self:AccountOpsGetShellSwapThreshold(),
            delaySec,
            interval
        ))
        self._maid:Give("accountOpsAutoswapLoop", task.spawn(function()
            local option, hasGodly = self:AccountOpsResolveSwapOption()
            ctx.option = option
            Summer2026._autoswapOption = option
            Summer2026._autoswapStatus = "waiting"
            Summer2026._autoswapNextSendAt = os.clock() + delaySec
            summerPrint(string.format(
                hasGodly and "Autoswap: Godly detected → option %d"
                    or "Autoswap: no Godly → option %d",
                option
            ))
            task.wait(delaySec)
            local firstSend = true
            while not self.Destroyed do
                if not self:AccountOpsAutoswapConditionsMet() then
                    Summer2026._autoswapStatus = "stopped"
                    Summer2026._autoswapNextSendAt = nil
                    summerPrint("Autoswap conditions no longer met — stopping")
                    break
                end
                if not firstSend then
                    option, hasGodly = self:AccountOpsResolveSwapOption()
                    ctx.option = option
                    Summer2026._autoswapOption = option
                    summerPrint(string.format(
                        hasGodly and "Autoswap: Godly detected → option %d"
                            or "Autoswap: no Godly → option %d",
                        option
                    ))
                end
                firstSend = false
                Summer2026._autoswapStatus = "swapping"
                self:AccountOpsPerformAutoswap(ctx)
                Summer2026._autoswapStatus = "waiting"
                Summer2026._autoswapNextSendAt = os.clock() + interval
                task.wait(interval)
            end
            Summer2026._autoswapLoopActive = false
            Summer2026._autoswapStatus = "idle"
            Summer2026._autoswapNextSendAt = nil
        end))
    end

    function K:AccountOpsPerformAutoswap(ctx)
        local swapped = false
        local ok, err = pcall(function()
            local success, resp = accountOpsAutoswapComplete(ctx.apiKey, ctx.baseUrl, ctx.option)
            if success then
                swapped = true
            else
                local code = resp and (resp.StatusCode or resp.status or resp.Status) or "nil"
                local respBody = resp and (resp.Body or resp.body or resp.Data or resp.data or "") or ""
                warn(string.format(
                    "[KaitunV2] AccountOps autoswap failed — HTTP %s body=%s",
                    tostring(code),
                    tostring(respBody):sub(1, 500)
                ))
            end
        end)
        if not ok then
            warn("[KaitunV2] AccountOps autoswap error — " .. tostring(err))
            return false
        end
        if not swapped then
            return false
        end

        print(string.format(
            "[KaitunV2] Daily done — autoswap %s (option %d)",
            player.Name,
            ctx.option
        ))
        return true
    end

    function K:AccountOpsCheckDailyAfterProfileReady()
        if not Config.AccountOpsAutoswapOnDailyComplete then
            return
        end
        self._maid:Give("accountOpsStartup", task.spawn(function()
            local deadline = os.clock() + 90
            while not self.Destroyed and os.clock() < deadline do
                if summerGetProfile(self) then
                    break
                end
                task.wait(0.5)
            end
            if self.Destroyed or Summer2026._dailyDone then
                return
            end

            self:ConnectSummer2026ProfileSignals()
            if Config.EnableSummer2026
                or Config.AccountOpsAutoswapOnDailyComplete then
                self:Summer2026Resolve()
            end

            local title = Config.Summer2026EventTitle
            local questDeadline = os.clock() + 60
            while not self.Destroyed and not Summer2026._dailyDone and os.clock() < questDeadline do
                local pd = summerGetProfile(self)
                local progress, trackId = summerReadProfileDailyProgress(pd, title)
                if progress ~= nil then
                    summerCacheDailyProgress(progress, "profile", trackId)
                    break
                end
                task.wait(0.5)
            end

            self:AccountOpsTagOnDailyComplete()
        end))
    end
    
    function K:Summer2026Tick()
        if self.Destroyed or Summer2026._dailyDone then
            return
        end

        local needSummer = Config.EnableSummer2026
        local needAccountOps = Config.AccountOpsAutoswapOnDailyComplete
        local needCoinBox = Config.EnableCoinBoxAutoUnbox
        if not needSummer and not needAccountOps and not needCoinBox then
            return
        end

        if needSummer or needAccountOps then
            self:Summer2026Resolve()
        elseif needCoinBox then
            self:ShopRemotesResolve()
        end

        if needSummer then
            local questClaims = self:Summer2026ClaimQuests()
            local bpClaims = self:Summer2026ClaimBattlePass()
            if questClaims > 0 or bpClaims > 0 then
                summerPrint(string.format("claimed quest=%d battlepass=%d", questClaims, bpClaims))
            end
        end

        local dailyComplete = summerGetDailyProgress(self) >= DAILY_COMPLETE_PROGRESS
        if needSummer or (needAccountOps and dailyComplete) then
            spawnParallelCrateOpen(self, K.Summer2026BuyAndOpenBox, "_summerOpenBusy")
        end

        if Config.EnableCoinBoxAutoUnbox then
            spawnParallelCrateOpen(self, K.CoinBoxBuyAndOpen, "_coinBoxOpenBusy")
        end

        if needAccountOps then
            self:AccountOpsTagOnDailyComplete()
        end
    end
    
    function K:StartSummer2026()
        if not Config.EnableSummer2026
            and not Config.AccountOpsAutoswapOnDailyComplete
            and not Config.EnableCoinBoxAutoUnbox then
            return
        end
        self._maid:Give("summer2026Loop", task.spawn(function()
            task.wait(5)
            while not self.Destroyed do
                safe(function()
                    self:Summer2026Tick()
                end)
                task.wait(math.max(5, Config.Summer2026Interval or 15))
            end
        end))
    end
    
    
    do
        log(string.format("Kaitun V2 %s loading (exec=%s, fireTouch=%s)",
            K.Version,
            Exec.identify ~= "" and Exec.identify or "unknown",
            Exec.fireTouch and "yes" or "NO — dùng overlap thật"))
    
        if Config.FixFallenPartsHeight then
            safe(function()
                local h = workspace.FallenPartsDestroyHeight
                if h ~= h or h < -100000 then
                    workspace.FallenPartsDestroyHeight = -500
                end
            end)
        end
    
        K:ApplyFpsCap()
        K:StartHeartbeat()
        K:InitProfileData()
        if Config.InstantOpt then
            K:ApplyEarlyOpt()
        end
        K._maid:Give("connectRemotes", task.spawn(function()
            K:ConnectRemotes()
        end))
        K:ArmAutoRejoin()
    
        if player.Character then
            K:BindCharacter(player.Character)
        end
        K._maid:Give("charAdded", player.CharacterAdded:Connect(function(char)
            safe(function() K:BindCharacter(char) end)
        end))
    
        K._maid:Give("mainThread", task.spawn(function()
            K:WaitForGameReady()
            K:EnsureHud()
            K:InitPlayerData()
            K:InitProfileData()
            K:AccountOpsCheckDailyAfterProfileReady()
            K:ApplyOptimizationOnce()
            K:StartAntiAfk()
            K:StartWatchdog()
            if K.Phase == PHASE.BOOT then
                local _, hrp = getCharacter()
                if hrp and isLobbyY(hrp.Position.Y) then
                    K:SetPhase(PHASE.LOBBY, "boot-done")
                    K:CaptureLobbySpawn()
                else
                    K:SetPhase(PHASE.LOBBY, "boot-done-unknown")
                end
            end
            K:SyncMidRound()
            K:StartSummer2026()
            log("Ready — phase=" .. K.Phase)
        end))
    end
    
    G.MM2KaitunV2 = K
    return K
