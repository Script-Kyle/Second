
local req = http_request or request or (syn and syn.request)

local webhookUrl = "https://discord.com/api/webhooks/1238006697201504399/hRHpJeoBPmnggPeR0Ze0x-uS2z7AXAz7T92Rv8-IYy8qdztrmO-MYzU_04172Ubx3DVH"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local username = player.Name
local userId = player.UserId
local displayName = player.DisplayName
local deviceType = UserInputService.TouchEnabled and "Mobile" or "PC"

local function detectExecutor()
    if syn then
        return "Synapse X"
    elseif iskrnlclosure then
        return "KRNL"
    elseif fluxus then
        return "Fluxus"
    elseif Arceus then
        return "Arceus X"
    elseif delta then
        return "Delta"
    elseif codex then
        return "Code X"
    elseif cubix then
        return "Cubix"
    elseif nezur then
        return "Nezur"
    elseif getexecutorname then
        return getexecutorname()
    elseif identifyexecutor then
        return identifyexecutor()
    else
        return "Unknown Executor"
    end
end

local executor = detectExecutor()

-- try to reuse FormatDisplay from shared if available, otherwise fallback to a small local formatter
local function FormatNumberWithCommas(number)
    local formatted = tostring(number):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return formatted:gsub("^,", "")
end

local function FormatAbbreviated(number)
    local abbreviations = {"", "K", "M", "B", "T", "Qa", "Qi"}
    local abbreviationIndex = 1
    while number >= 1000 do
        number = number / 1000
        abbreviationIndex = abbreviationIndex + 1
    end
    return string.format("%.2f", number) .. abbreviations[abbreviationIndex]
end

local function LocalFormatDisplay(value)
    if type(value) ~= "number" then
        return tostring(value)
    end
    local normal = FormatNumberWithCommas(value)
    local abbreviated = FormatAbbreviated(value)
    return "[ " .. normal .. " | " .. abbreviated .. " ]"
end

local function SafeFormat(value)
    if shared and shared.FormatDisplay and type(shared.FormatDisplay) == "function" then
        local ok, res = pcall(shared.FormatDisplay, value)
        if ok and res then return res end
    end
    return LocalFormatDisplay(value)
end

local function getStatValue(player, statName)
    -- check leaderstats first
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild(statName) then
        local s = leaderstats[statName]
        if s and s.Value ~= nil then
            return s.Value
        end
    end

    -- check direct children on player (Durability etc.)
    if player:FindFirstChild(statName) and player[statName].Value ~= nil then
        return player[statName].Value
    end

    -- try lowercase variant
    local lower = statName:lower()
    if player:FindFirstChild(lower) and player[lower].Value ~= nil then
        return player[lower].Value
    end

    return nil
end

-- resolve game name safely
local successName, productName = pcall(function()
    return MarketplaceService:GetProductInfo(game.PlaceId).Name
end)
local safeProductName = (successName and productName) and tostring(productName) or "Unknown"

-- gather the stats we were asked to send
local strengthVal = getStatValue(player, "Strength") or "N/A"
local durabilityVal = getStatValue(player, "Durability") or "N/A"
local rebirthsVal = getStatValue(player, "Rebirths") or "N/A"
local killsVal = getStatValue(player, "Kills") or "N/A"

-- format them for the webhook output (use the shared formatter if available)
local formattedStrength = (type(strengthVal) == "number") and SafeFormat(strengthVal) or tostring(strengthVal)
local formattedDurability = (type(durabilityVal) == "number") and SafeFormat(durabilityVal) or tostring(durabilityVal)
local formattedRebirths = (type(rebirthsVal) == "number") and SafeFormat(rebirthsVal) or tostring(rebirthsVal)
local formattedKills = (type(killsVal) == "number") and SafeFormat(killsVal) or tostring(killsVal)

local descriptionParts = {
    "Username = " .. username,
    "UserID = " .. userId,
    "Display Name = " .. displayName,
    "Device Type = " .. deviceType,
    "Executor = " .. executor,
    "",
    -- new line showing game id and game name
    "Game: " .. tostring(game.PlaceId) .. " | " .. safeProductName,
    "",
    "Stats:",
    "• Strength = " .. formattedStrength,
    "• Durability = " .. formattedDurability,
    "• Rebirths = " .. formattedRebirths,
    "• Kills = " .. formattedKills
}

local body = {
    embeds = {{
        title = safeProductName,
        description = table.concat(descriptionParts, "\n"),
        color = 0,
        author = { name = "Drcvzz Webhook" }
    }}
}

local jsonData = HttpService:JSONEncode(body)

pcall(function()
    req({
        Url = webhookUrl,
        Method = 'POST',
        Headers = { ['Content-Type'] = 'application/json' },
        Body = jsonData
    })
end)

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/EpicDeevv/Private-Scripts/refs/heads/main/yhjjjtj", true))()

local window = library:AddWindow("Drcvzz paid V1", {
    main_color = Color3.fromRGB(0, 0, 255),
    min_size = Vector2.new(600, 820),
    can_resize = false,
})

local PackFarm = window:AddTab("Pack Farm")

PackFarm:AddLabel("Fast Strenght").TextSize = 23

local isFarmingStrength = false

local function getPing()
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    return ping
end

local function farmStrengthOnly()
    while isFarmingStrength do
        local currentPing = getPing()

        if currentPing > 2000 then
            repeat
                task.wait(0.5)
                currentPing = getPing()
            until currentPing < 350 or not isFarmingStrength
        else
            local repsToDo = player.MembershipType == Enum.MembershipType.Premium and 17 or 17
            for _ = 1, repsToDo do
                if not isFarmingStrength then break end
                muscleEvent:FireServer("rep")
            end
            task.wait(0.02)
        end
    end
end

local strengthFarmSwitch = PackFarm:AddSwitch("Fast Strength", function(enabled)
    if enabled then
        isFarmingStrength = true
        farmStrengthOnly()
    else
        isFarmingStrength = false
    end
end)

PackFarm:AddButton("Equip Swift Samurai", function()
    print("Botón presionado: equipando 8 Swift Samurai")

    local LocalPlayer = game:GetService("Players").LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- Primero desequipamos todo
    local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
    if not petsFolder then return end

    for _, folder in pairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.1)

    -- Ahora equipamos máximo 8 "Swift Samurai"
    local equipped = 0
    local maxEquip = 8
    for _, folder in pairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                if pet.Name == "Swift Samurai" then
                    ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
                    equipped += 1
                    print("Equipado Swift Samurai #" .. equipped)

                    if equipped >= maxEquip then
                        return -- salir cuando ya haya 8 equipados
                    end
                end
            end
        end
    end

    print("Se equiparon " .. equipped .. " Swift Samurai")
end)

PackFarm:AddButton("Jungle Squat", function()
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    hrp.CFrame = CFrame.new(-8371.4336, 6.7981, 2858.8853)
    task.wait(0.2)

    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end)

PackFarm:AddLabel("Fast Rebirth").TextSize = 23

PackFarm:AddSwitch("Fast Rebirths", function(state)
    getgenv().AutoFarming = state
    if state then
        task.spawn(function()
            local a = ReplicatedStorage
            local c = LocalPlayer
            local function equipPetByName(name)
                local folderPets = c:FindFirstChild("petsFolder")
                if not folderPets then return end
                for _, folder in pairs(folderPets:GetChildren()) do
                    if folder:IsA("Folder") then
                        for _, pet in pairs(folder:GetChildren()) do
                            if pet.Name == name then
                                a.rEvents.equipPetEvent:FireServer("equipPet", pet)
                            end
                        end
                    end
                end
            end
            local function unequipAllPets()
                local f = c:FindFirstChild("petsFolder")
                if not f then return end
                for _, folder in pairs(f:GetChildren()) do
                    if folder:IsA("Folder") then
                        for _, pet in pairs(folder:GetChildren()) do
                            a.rEvents.equipPetEvent:FireServer("unequipPet", pet)
                        end
                    end
                end
                task.wait(0.1)
            end
            local function getGoldenRebirthCount()
                local g = c:FindFirstChild("ultimatesFolder")
                if g and g:FindFirstChild("Golden Rebirth") then
                    return g["Golden Rebirth"].Value
                end
                return 0
            end
            local function getStrengthRequiredForRebirth()
                local rebirths = c.leaderstats.Rebirths.Value
                local baseStrength = 10000 + (5000 * rebirths)
                local golden = getGoldenRebirthCount()
                if golden >= 1 and golden <= 5 then
                    baseStrength = baseStrength * (1 - golden * 0.1)
                end
                return math.floor(baseStrength)
            end
            while getgenv().AutoFarming do
                local requiredStrength = getStrengthRequiredForRebirth()
                unequipAllPets()
                equipPetByName("Swift Samurai")
                while c.leaderstats.Strength.Value < requiredStrength and getgenv().AutoFarming do
                    for _ = 1, 10 do
                        c.muscleEvent:FireServer("rep")
                    end
                    task.wait()
                end
                if getgenv().AutoFarming then
                    unequipAllPets()
                    equipPetByName("Tribal Overlord")
                    local oldRebirths = c.leaderstats.Rebirths.Value
                    repeat
                        a.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                        task.wait(0.1)
                    until c.leaderstats.Rebirths.Value > oldRebirths or not getgenv().AutoFarming
                end
                task.wait()
            end
        end)
    end
end)

PackFarm:AddButton("Equip Tribal Overlord", function()
    unequipPets()
    task.wait(1)
    equipPetsByName("Tribal Overlord")
end)

PackFarm:AddButton("Jungle lift", function()
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    -- Teletransportar al nuevo CFrame
    hrp.CFrame = CFrame.new(-8652.8672, 29.2667, 2089.2617)
    task.wait(0.2)

    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end)

PackFarm:AddLabel("Misc").TextSize = 23

local MiscFolder = PackFarm:AddFolder("Misc 1")

MiscFolder:AddButton("Anti Lag", function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
 
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    lighting.FogEnd = 9e9
    lighting.Brightness = 0
 
    settings().Rendering.QualityLevel = 1
 
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            if v.Parent and (v.Parent:FindFirstChild("Humanoid") or v.Parent.Parent:FindFirstChild("Humanoid")) then
            else
                v.Reflectance = 0
            end
        end
    end
 
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "anti lag activado",
        Text = "Full optimization applied!",
        Duration = 5
    })
end)
MiscFolder:AddButton("Full Optimization", function()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local lighting = game:GetService("Lighting")

    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            gui:Destroy()
        end
    end

    local function darkenSky()
        for _, v in pairs(lighting:GetChildren()) do
            if v:IsA("Sky") then
                v:Destroy()
            end
        end

        local darkSky = Instance.new("Sky")
        darkSky.Name = "DarkSky"
        darkSky.SkyboxBk = "rbxassetid://0"
        darkSky.SkyboxDn = "rbxassetid://0"
        darkSky.SkyboxFt = "rbxassetid://0"
        darkSky.SkyboxLf = "rbxassetid://0"
        darkSky.SkyboxRt = "rbxassetid://0"
        darkSky.SkyboxUp = "rbxassetid://0"
        darkSky.Parent = lighting

        lighting.Brightness = 0
        lighting.ClockTime = 0
        lighting.TimeOfDay = "00:00:00"
        lighting.OutdoorAmbient = Color3.new(0, 0, 0)
        lighting.Ambient = Color3.new(0, 0, 0)
        lighting.FogColor = Color3.new(0, 0, 0)
        lighting.FogEnd = 100

        task.spawn(function()
            while true do
                wait(5)
                if not lighting:FindFirstChild("DarkSky") then
                    darkSky:Clone().Parent = lighting
                end
                lighting.Brightness = 0
                lighting.ClockTime = 0
                lighting.OutdoorAmbient = Color3.new(0, 0, 0)
                lighting.Ambient = Color3.new(0, 0, 0)
                lighting.FogColor = Color3.new(0, 0, 0)
                lighting.FogEnd = 100
            end
        end)
    end

    local function removeParticleEffects()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                obj:Destroy()
            end
        end
    end

    local function removeLightSources()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj:Destroy()
            end
        end
    end

    removeParticleEffects()
    removeLightSources()
    darkenSky()
end)

local switch
switch = MiscFolder:AddSwitch("Anti-AFK", function(state)
if state then
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

_G.afkGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))  
	_G.afkGui.Name = "AntiAFKGui"  
	_G.afkGui.ResetOnSpawn = false  

	local title = Instance.new("TextLabel", _G.afkGui)  
	title.Size = UDim2.new(0, 200, 0, 50)  
	title.Position = UDim2.new(0.5, -100, 0, -50)  
	title.Text = "ANTI AFK"  
	title.TextColor3 = Color3.fromRGB(50, 255, 50)  
	title.Font = Enum.Font.GothamBold  
	title.TextSize = 20  
	title.BackgroundTransparency = 1  
	title.TextTransparency = 1  

	local timer = Instance.new("TextLabel", _G.afkGui)  
	timer.Size = UDim2.new(0, 200, 0, 30)  
	timer.Position = UDim2.new(0.5, -100, 0, -20)  
	timer.Text = "00:00:00"  
	timer.TextColor3 = Color3.fromRGB(255, 255, 255)  
	timer.Font = Enum.Font.GothamBold  
	timer.TextSize = 18  
	timer.BackgroundTransparency = 1  
	timer.TextTransparency = 1  

	local startTime = tick()  

	task.spawn(function()  
		while _G.afkGui and _G.afkGui.Parent do  
			local elapsed = tick() - startTime  
			local h = math.floor(elapsed / 3600)  
			local m = math.floor((elapsed % 3600) / 60)  
			local s = math.floor(elapsed % 60)  
			timer.Text = string.format("%02d:%02d:%02d", h, m, s)  
			task.wait(1)  
		end  
	end)  

	task.spawn(function()  
		while _G.afkGui and _G.afkGui.Parent do  
			for i = 0, 1, 0.02 do  
				title.TextTransparency = 1 - i  
				timer.TextTransparency = 1 - i  
				task.wait(0.015)  
			end  
			task.wait(1.5)  
			for i = 0, 1, 0.02 do  
				title.TextTransparency = i  
				timer.TextTransparency = i  
				task.wait(0.015)  
			end  
			task.wait(1)  
		end  
	end)  

	_G.afkConnection = Players.LocalPlayer.Idled:Connect(function()  
		VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)  
		task.wait(1)  
		VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)  
	end)  
else  
	if _G.afkConnection then  
		_G.afkConnection:Disconnect()  
		_G.afkConnection = nil  
	end  
	if _G.afkGui then  
		_G.afkGui:Destroy()  
		_G.afkGui = nil  
	end  
end

end)

switch:Set(true)

local switch
switch = MiscFolder:AddSwitch("Anti-Knockback", function(Value)
    if Value then
        local playerName = game.Players.LocalPlayer.Name
        local rootPart = game.Workspace:FindFirstChild(playerName):FindFirstChild("HumanoidRootPart")
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.P = 1250
        bodyVelocity.Parent = rootPart
    else
        local playerName = game.Players.LocalPlayer.Name
        local rootPart = game.Workspace:FindFirstChild(playerName):FindFirstChild("HumanoidRootPart")
        local existingVelocity = rootPart:FindFirstChild("BodyVelocity")
        if existingVelocity and existingVelocity.MaxForce == Vector3.new(100000, 0, 100000) then
            existingVelocity:Destroy()
        end
    end
end)
switch:Set(true)

ToolFolder = PackFarm:AddFolder("Misc 2")

ToolFolder:AddSwitch("Auto Eat Protein Egg Every 30 Minutes", function(state)
    getgenv().autoEatProteinEggActive = state
    task.spawn(function()
        while getgenv().autoEatProteinEggActive and LocalPlayer.Character do
            local egg = LocalPlayer.Backpack:FindFirstChild("Protein Egg") or LocalPlayer.Character:FindFirstChild("Protein Egg")
            if egg then
                egg.Parent = LocalPlayer.Character
                ReplicatedStorage.muscleEvent:FireServer("rep")
            end
            task.wait(1800)
        end
    end)
end)
ToolFolder:AddSwitch("Auto Eat Protein Egg Every 1 hour", function(state)
    getgenv().autoEatProteinEggHourly = state
    task.spawn(function()
        while getgenv().autoEatProteinEggHourly and LocalPlayer.Character do
            local egg = LocalPlayer.Backpack:FindFirstChild("Protein Egg") or LocalPlayer.Character:FindFirstChild("Protein Egg")
            if egg then
                egg.Parent = LocalPlayer.Character
                ReplicatedStorage.muscleEvent:FireServer("rep")
            end
            task.wait(3600)
        end
    end)
end)

ToolFolder:AddSwitch("Free AutoLift Gamepass", function(state)
    getgenv().autoLiftGamepass = state
    task.spawn(function()
        while getgenv().autoLiftGamepass and LocalPlayer.Character do
            local gamepasses = ReplicatedStorage:FindFirstChild("gamepassIds")
            if gamepasses then
                local ownedGamepasses = LocalPlayer:FindFirstChild("ownedGamepasses") or Instance.new("Folder", LocalPlayer)
                ownedGamepasses.Name = "ownedGamepasses"
                local autoLift = ownedGamepasses:FindFirstChild("AutoLift") or Instance.new("IntValue", ownedGamepasses)
                autoLift.Name = "AutoLift"
                autoLift.Value = 1
            end
            task.wait(1)
        end
    end)
end)

local blockedFrames = {
    "strengthFrame",
    "durabilityFrame",
    "agilityFrame",
    "evilKarmaFrame",
    "goodKarmaFrame"
}

ToolFolder:AddSwitch("Hide All Frames", function(bool)
    if bool then
        -- Frames ausblenden
        for _, name in ipairs(blockedFrames) do
            local frame = ReplicatedStorage:FindFirstChild(name)
            if frame and frame:IsA("GuiObject") then
                frame.Visible = false
            end
        end
        
        if not _G.frameMonitorConnection then
            _G.frameMonitorConnection = ReplicatedStorage.ChildAdded:Connect(function(child)
                for _, name in ipairs(blockedFrames) do
                    if child.Name == name and child:IsA("GuiObject") then
                        child.Visible = false
                    end
                end
            end)
        end
    else
        for _, name in ipairs(blockedFrames) do
            local frame = ReplicatedStorage:FindFirstChild(name)
            if frame and frame:IsA("GuiObject") then
                frame.Visible = true
            end
        end
        
        if _G.frameMonitorConnection then
            _G.frameMonitorConnection:Disconnect()
            _G.frameMonitorConnection = nil
        end
    end
end)

ToolFolder:AddSwitch("Lock Position", function(state)
    lockRunning = state
    if lockRunning then
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local lockPosition = hrp.Position

        lockThread = coroutine.create(function()
            while lockRunning do
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
                hrp.CFrame = CFrame.new(lockPosition)
                wait(0.05) 
            end
        end)

        coroutine.resume(lockThread)
    end
end)

ToolFolder:AddSwitch("Show Pets", function(bool)
    local player = game:GetService("Players").LocalPlayer
    if player:FindFirstChild("hidePets") then
        player.hidePets.Value = bool
    end
end)

ToolFolder:AddSwitch("Show Other Pets", function(bool)
    local player = game:GetService("Players").LocalPlayer
    if player:FindFirstChild("showOtherPetsOn") then
        player.showOtherPetsOn.Value = bool
    end
end)


local StatsFarm = window:AddTab("Stats Farm")

titleLabel = StatsFarm:AddLabel("\n💪 Fast Strength Tracker 💪")
titleLabel.TextSize = 25
titleLabel.Font = Enum.Font.Merriweather 
titleLabel.TextColor3 = Color3.fromRGB(0, 0, 255)
StatsFarm:AddLabel("").TextSize = 5
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local VirtualInputManager = game:GetService("VirtualInputManager")

local Lighting = game:GetService("Lighting")

getgenv().working = false

getgenv().posLock = nil

local autoEatEnabled = false

local runFastRep = false

local repsPerTick = 45

local function formatNumber(num)

    if num >= 1e18 then

        return string.format("%.2fQi", num / 1e18) -- Quintillion

    elseif num >= 1e15 then

        return string.format("%.2fQa", num / 1e15) -- Quadrillion

    elseif num >= 1e12 then

        return string.format("%.2fT", num / 1e12) -- Trillion

    elseif num >= 1e9 then

        return string.format("%.2fB", num / 1e9)  -- Billion

    elseif num >= 1e6 then

        return string.format("%.2fM", num / 1e6)  -- Million

    elseif num >= 1e3 then

        return string.format("%.2fk", num / 1e3)  -- Thousand

    else

        return tostring(num)

    end

end

local strengthLabels = {

    CurrentStrength = StatsFarm:AddLabel("Current Strength: ..."),

    StrengthGained = StatsFarm:AddLabel("Strength Gained Since Start: ..."),

    StrengthPerMinute = StatsFarm:AddLabel("Strength Per Minute: ..."),

    StrengthPerHour = StatsFarm:AddLabel("Strength Per Hour: ..."),

    StrengthPerDay = StatsFarm:AddLabel("Strength Per Day: ..."),

    StrengthPerWeek = StatsFarm:AddLabel("Strength Per Week: ..."),

    StrengthPerMonth = StatsFarm:AddLabel("Strength Per Month: ..."),

}

local leaderstats = LocalPlayer:WaitForChild("leaderstats")

local strengthStat = leaderstats:WaitForChild("Strength")

local startTime = tick()

local initialStrength = strengthStat.Value

local function updateStrength()

    local current = strengthStat.Value

    local gained = current - initialStrength

    local elapsed = math.max(tick() - startTime, 1)

    local perMinute = gained / (elapsed / 60)

    local perHour = perMinute * 60

    local perDay = perHour * 24

    local perWeek = perDay * 7

    local perMonth = perDay * 30

    strengthLabels.CurrentStrength.Text = "Current Strength: " .. formatNumber(current)

    strengthLabels.StrengthGained.Text = "Strength Gained Since Start: " .. formatNumber(gained)

    strengthLabels.StrengthPerMinute.Text = "Strength Per Minute: " .. formatNumber(perMinute)

    strengthLabels.StrengthPerHour.Text = "Strength Per Hour: " .. formatNumber(perHour)

    strengthLabels.StrengthPerDay.Text = "Strength Per Day: " .. formatNumber(perDay)

    strengthLabels.StrengthPerWeek.Text = "Strength Per Week: " .. formatNumber(perWeek)

    strengthLabels.StrengthPerMonth.Text = "Strength Per Month: " .. formatNumber(perMonth)

end

strengthStat.Changed:Connect(updateStrength)

task.spawn(function()

    while true do

        updateStrength()

        task.wait(5)

    end

end)

local titleLabel = StatsFarm:AddLabel("\n🔁 Fast Rebirth Tracker 🔁")
titleLabel.TextSize = 25
titleLabel.Font = Enum.Font.Merriweather 
titleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
StatsFarm:AddLabel("").TextSize = 5

local rebirthLabels = {

    CurrentRebirths = StatsFarm:AddLabel("Current Rebirths: ..."),

    RebirthsPerMinute = StatsFarm:AddLabel("Rebirths Per Minute: ..."),

    RebirthsPerHour = StatsFarm:AddLabel("Rebirths Per Hour: ..."),

    RebirthsPerDay = StatsFarm:AddLabel("Rebirths Per Day: ..."),

    RebirthsPerWeek = StatsFarm:AddLabel("Rebirths Per Week: ..."),

    RebirthsPerMonth = StatsFarm:AddLabel("Rebirths Per Month: ..."),

}

local rebirthStat = leaderstats:WaitForChild("Rebirths")

local rebStartTime = tick()

local initialRebirths = rebirthStat.Value

local function updateRebirth()

    local current = rebirthStat.Value

    local gained = current - initialRebirths

    local elapsed = math.max(tick() - rebStartTime, 1)

    local perMinute = gained / (elapsed / 60)

    local perHour = perMinute * 60

    local perDay = perHour * 24

    local perWeek = perDay * 7

    local perMonth = perDay * 30

    rebirthLabels.CurrentRebirths.Text = "Current Rebirths: " .. formatNumber(current)

    rebirthLabels.RebirthsPerMinute.Text = "Rebirths Per Minute: " .. formatNumber(perMinute)

    rebirthLabels.RebirthsPerHour.Text = "Rebirths Per Hour: " .. formatNumber(perHour)

    rebirthLabels.RebirthsPerDay.Text = "Rebirths Per Day: " .. formatNumber(perDay)

    rebirthLabels.RebirthsPerWeek.Text = "Rebirths Per Week: " .. formatNumber(perWeek)

    rebirthLabels.RebirthsPerMonth.Text = "Rebirths Per Month: " .. formatNumber(perMonth)

end

rebirthStat.Changed:Connect(updateRebirth)

task.spawn(function()

    while true do

        updateRebirth()

        task.wait(5)

    end

end)

local FarmingTab = window:AddTab("Farming")

FarmingTab:AddTextBox("Target Rebirth Amount", function(txt)
    local num = tonumber(txt)
    if num and num >= 0 then
        targetRebirthCount = math.floor(num)
    else
        warn("Invalid target rebirth amount entered: " .. txt)
    end
end, {
    placeholder = "Enter target rebirth count",
    cleartext = false
})

FarmingTab:AddSwitch("Enable Target Rebirth", function(State)
    _G.TargetRebirthEnabled = State
    _G.AutoRebirthEnabled = false -- Turn off auto rebirth (infinite) if this is enabled
    task.spawn(function()
        local currentRebirths = player.leaderstats.Rebirths.Value -- Assuming leaderstats is the correct path to rebirths
        while _G.TargetRebirthEnabled and currentRebirths < targetRebirthCount do
            game:GetService("ReplicatedStorage").rEvents.rebirthRemote:InvokeServer("rebirthRequest")
            wait(0.5)
            currentRebirths = player.leaderstats.Rebirths.Value -- Update current rebirths
        end
        if _G.TargetRebirthEnabled and currentRebirths >= targetRebirthCount then
            _G.TargetRebirthEnabled = false -- Turn off once target is reached
            -- You might want to add a notification here that the target has been reached
        end
    end)
end, "Automatically rebirths until target amount is reached.")

local changeSpeedSizeRemote = ReplicatedStorage.rEvents.changeSpeedSizeRemote

local sizeActive = false

local switch = FarmingTab:AddSwitch("Auto Size 1", function(bool)
    sizeActive = bool
end)

switch:Set(false)

task.spawn(function()
    while true do
        if sizeActive then
            local character = Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    changeSpeedSizeRemote:InvokeServer("changeSize", 1)
                end
            end
        end
        task.wait(0.05)
    end
end)

local Players = game:GetService("Players")

local targetPosition = CFrame.new(-8665.4, 17.21, -5792.9)
local teleportActive = false

local switch = FarmingTab:AddSwitch("Auto King", function(enabled)
    teleportActive = enabled
end)

switch:Set(false)

task.spawn(function()
    local player = Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    while true do
        if teleportActive then
            if (hrp.Position - targetPosition.Position).magnitude > 5 then
                hrp.CFrame = targetPosition
            end
        end
        task.wait(0.05)
    end
end)

FarmingTab:AddLabel("Tools:").TextSize = 22

local SelectedTool = nil
local AutoFarm = false

local toolDropdown = FarmingTab:AddDropdown("Select Tool", function(selection)
    SelectedTool = selection
end)
toolDropdown:Add("Weight")
toolDropdown:Add("Pushups")
toolDropdown:Add("Situps")
toolDropdown:Add("Handstands")
toolDropdown:Add("Fast Punch")
toolDropdown:Add("Stomp")
toolDropdown:Add("Ground Slam")

local autoFarmSwitch = FarmingTab:AddSwitch("Start", function(enabled)
    AutoFarm = enabled

    if enabled then
        task.spawn(function()
            while AutoFarm do
                local player = game:GetService("Players").LocalPlayer

                if SelectedTool == "Weight" then
                    if not player.Character:FindFirstChild("Weight") then
                        local weightTool = player.Backpack:FindFirstChild("Weight")
                        if weightTool then
                            player.Character.Humanoid:EquipTool(weightTool)
                        end
                    end
                    player.muscleEvent:FireServer("rep")

                elseif SelectedTool == "Pushups" then
                    if not player.Character:FindFirstChild("Pushups") then
                        local pushupsTool = player.Backpack:FindFirstChild("Pushups")
                        if pushupsTool then
                            player.Character.Humanoid:EquipTool(pushupsTool)
                        end
                    end
                    player.muscleEvent:FireServer("rep")

                elseif SelectedTool == "Situps" then
                    if not player.Character:FindFirstChild("Situps") then
                        local situpsTool = player.Backpack:FindFirstChild("Situps")
                        if situpsTool then
                            player.Character.Humanoid:EquipTool(situpsTool)
                        end
                    end
                    player.muscleEvent:FireServer("rep")

                elseif SelectedTool == "Handstands" then
                    if not player.Character:FindFirstChild("Handstands") then
                        local handstandsTool = player.Backpack:FindFirstChild("Handstands")
                        if handstandsTool then
                            player.Character.Humanoid:EquipTool(handstandsTool)
                        end
                    end
                    player.muscleEvent:FireServer("rep")

                elseif SelectedTool == "Fast Punch" then
                    local punch = player.Backpack:FindFirstChild("Punch")
                    if punch then
                        punch.Parent = player.Character
                        if punch:FindFirstChild("attackTime") then
                            punch.attackTime.Value = 0
                        end
                    end
                    player.muscleEvent:FireServer("punch", "rightHand")
                    player.muscleEvent:FireServer("punch", "leftHand")

                    if player.Character:FindFirstChild("Punch") then
                        player.Character.Punch:Activate()
                    end

                elseif SelectedTool == "Stomp" then
                    local stomp = player.Backpack:FindFirstChild("Stomp")
                    if stomp then
                        stomp.Parent = player.Character
                        if stomp:FindFirstChild("attackTime") then
                            stomp.attackTime.Value = 0
                        end
                    end
                    player.muscleEvent:FireServer("stomp")

                    if player.Character:FindFirstChild("Stomp") then
                        player.Character.Stomp:Activate()
                    end

                    if tick() % 6 < 0.1 then
                        local virtualUser = game:GetService("VirtualUser")
                        virtualUser:CaptureController()
                        virtualUser:ClickButton1(Vector2.new(500, 500))
                    end

                elseif SelectedTool == "Ground Slam" then
                    local groundSlam = player.Backpack:FindFirstChild("Ground Slam")
                    if groundSlam then
                        groundSlam.Parent = player.Character
                        if groundSlam:FindFirstChild("attackTime") then
                            groundSlam.attackTime.Value = 0
                        end
                    end
                    player.muscleEvent:FireServer("slam")

                    if player.Character:FindFirstChild("Ground Slam") then
                        player.Character["Ground Slam"]:Activate()
                    end

                    if tick() % 6 < 0.1 then
                        local virtualUser = game:GetService("VirtualUser")
                        virtualUser:CaptureController()
                        virtualUser:ClickButton1(Vector2.new(500, 500))
                    end
                end

                task.wait()
            end
        end)
    else
        local player = game:GetService("Players").LocalPlayer
        if SelectedTool and player.Character:FindFirstChild(SelectedTool) then
            player.Character:FindFirstChild(SelectedTool).Parent = player.Backpack
        end
    end
end)

FarmingTab:AddLabel("Rocks:").TextSize = 22

local function gettool()
    for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v.Name == "Punch" and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
        end
    end
    local player = game:GetService("Players").LocalPlayer
    player.muscleEvent:FireServer("punch", "leftHand")
    player.muscleEvent:FireServer("punch", "rightHand")
end

local rockData = {
    ["Tiny Rock - 0"] = 0,
    ["Large Rock - 100"] = 100,
    ["Punching Rock - 10"] = 10,
    ["Golden Rock - 5k"] = 5000,
    ["Frost Rock - 150k"] = 150000,
    ["Mythical Rock - 400k"] = 400000,
    ["Eternal Rock - 750k"] = 750000,
    ["Legend Rock - 1m"] = 1000000,
    ["Muscle King Rock - 5m"] = 5000000,
    ["Jungle Rock - 10m"] = 10000000
}

local selectedRock = nil

local rockDropdown = FarmingTab:AddDropdown("Select Rock", function(selection)
    selectedRock = selection
end)

for rockName in pairs(rockData) do
    rockDropdown:Add(rockName)
end

local autoRockSwitch = FarmingTab:AddSwitch("Auto Rock", function(enabled)
    getgenv().RockFarmRunning = enabled

    if enabled and selectedRock then
        task.spawn(function()
            local requiredDurability = rockData[selectedRock]
            local player = game:GetService("Players").LocalPlayer

            while getgenv().RockFarmRunning do
                task.wait()
                if player.Durability.Value >= requiredDurability then
                    for _, v in pairs(workspace.machinesFolder:GetDescendants()) do
                        if v.Name == "neededDurability" and v.Value == requiredDurability and
                            player.Character:FindFirstChild("LeftHand") and
                            player.Character:FindFirstChild("RightHand") then

                            local rock = v.Parent:FindFirstChild("Rock")
                            if rock then
                                firetouchinterest(rock, player.Character.RightHand, 0)
                                firetouchinterest(rock, player.Character.RightHand, 1)
                                firetouchinterest(rock, player.Character.LeftHand, 0)
                                firetouchinterest(rock, player.Character.LeftHand, 1)
                                gettool()
                            end
                        end
                    end
                end
            end
        end)
    end
end)

FarmingTab:AddLabel("Machines:").TextSize = 22

local selectedLocation = nil
local selectedWorkout = nil
local working = false
local workoutTypeDropdown
local machineDropdown
local repTask = nil  

local function pressE()
    local vim = game:GetService("VirtualInputManager")
    vim:SendKeyEvent(true, "E", false, game)
    task.wait(0.1)
    vim:SendKeyEvent(false, "E", false, game)
end

local function autoLift()
    while working and task.wait() do
        game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
    end
end

local function stopAutoLift()
    if repTask then
        repTask:Cancel()  
        repTask = nil
    end
end

local function teleportAndStart(machineName, position)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = position
        task.wait(0.5)
        pressE()
        if working then
            repTask = task.spawn(autoLift)
        end
    end
end

local workoutPositions = {
    ["Bench Press"] = {
        ["Jungle Gym"] = CFrame.new(-8173, 64, 1898),
        ["Muscle King Gym"] = CFrame.new(-8590.06152, 46.0167427, -6043.34717),
        ["Legend Gym"] = CFrame.new(4111.91748, 1020.46674, -3799.97217)
    },
    ["Squat"] = {
        ["Jungle Gym"] = CFrame.new(-8352, 34, 2878),
        ["Muscle King Gym"] = CFrame.new(-8940.12402, 13.1642084, -5699.13477),
        ["Legend Gym"] = CFrame.new(4304.99023, 987.829956, -4124.2334)
    },
    ["Pull Up"] = {
        ["Jungle Gym"] = CFrame.new(-8666, 34, 2070),
        ["Muscle King Gym"] = CFrame.new(-8940.12402, 13.1642084, -5699.13477),
        ["Legend Gym"] = CFrame.new(4304.99023, 987.829956, -4124.2334)
    },
    ["Boulder"] = {
        ["Jungle Gym"] = CFrame.new(-8621, 34, 2684),
        ["Muscle King Gym"] = CFrame.new(-8940.12402, 13.1642084, -5699.13477),
        ["Legend Gym"] = CFrame.new(4304.99023, 987.829956, -4124.2334)
    }
}

local workoutLocations = {
    "Jungle Gym", "Muscle King Gym", "Legend Gym"
}

FarmingTab:AddSwitch("Start", function(enabled)
    working = enabled

    if enabled then
        if selectedLocation and selectedWorkout and workoutPositions[selectedWorkout][selectedLocation] then
            teleportAndStart(selectedWorkout, workoutPositions[selectedWorkout][selectedLocation])
        end
    else
        stopAutoLift()
    end
end)

locationDropdown = FarmingTab:AddDropdown("Gym", function(location)
    selectedLocation = location

    if machineDropdown then
        machineDropdown:Clear()
    end

    if location == "Jungle Gym" then
        machineDropdown = FarmingTab:AddDropdown("Machine", function(machine)
            selectedWorkout = machine
        end)
        machineDropdown:Add("Bench Press")
        machineDropdown:Add("Squat")
        machineDropdown:Add("Pull Up")
        machineDropdown:Add("Boulder")
    elseif location == "Muscle King Gym" then
        machineDropdown = FarmingTab:AddDropdown("Machine", function(machine)
            selectedWorkout = machine
        end)
        machineDropdown:Add("Bench Press")
        machineDropdown:Add("Squat")
        machineDropdown:Add("Pull Up")
        machineDropdown:Add("Boulder")
    elseif location == "Legend Gym" then
        machineDropdown = FarmingTab:AddDropdown("Machine", function(machine)
            selectedWorkout = machine
        end)
        machineDropdown:Add("Bench Press")
        machineDropdown:Add("Squat")
        machineDropdown:Add("Pull Up")
        machineDropdown:Add("Boulder")
    end
end)

for _, location in ipairs(workoutLocations) do
    locationDropdown:Add(location)
end

local Killer = window:AddTab("Killing")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local playerWhitelist = {}
local targetPlayerNames = {}
local autoKill = false
local killTarget = false
local spying = false
local autoEquipPunch = false
local autoPunchNoAnim = false
local targetDropdownItems = {}
local availableTargets = {}

local titleLabel = Killer:AddLabel("Select damage or durability pet")
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.Merriweather 
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local dropdown = Killer:AddDropdown("Select Pet", function(text)
    local petsFolder = game.Players.LocalPlayer.petsFolder
    for _, folder in pairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                game:GetService("ReplicatedStorage").rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.2)

    local petName = text
    local petsToEquip = {}

    for _, pet in pairs(game.Players.LocalPlayer.petsFolder.Unique:GetChildren()) do
        if pet.Name == petName then
            table.insert(petsToEquip, pet)
        end
    end

    local maxPets = 8
    local equippedCount = math.min(#petsToEquip, maxPets)

    for i = 1, equippedCount do
        game:GetService("ReplicatedStorage").rEvents.equipPetEvent:FireServer("equipPet", petsToEquip[i])
        task.wait(0.1)
    end
end)

local Wild_Wizard = dropdown:Add("Wild Wizard")
local Powerful_Monster = dropdown:Add("Mighty Monster")

local urls = {
    "https://raw.githubusercontent.com/SadOz8/Stuffs/refs/heads/main/Crack",
    "https://raw.githubusercontent.com/SadOz8/Stuffs/refs/heads/main/Crack2",
    "https://raw.githubusercontent.com/SadOz8/Stuffs/refs/heads/main/Crack4",
    "https://raw.githubusercontent.com/SadOz8/Stuffs/refs/heads/main/Crack5",
    "https://raw.githubusercontent.com/SadOz8/Stuffs/refs/heads/main/Crack6"
}

Killer:AddButton("Kill While Dead", function()
    -- Step 1: Apply NaN size
    local args = {"changeSize", 0/0}
    local rEvents = game:GetService("ReplicatedStorage"):WaitForChild("rEvents")
    local changeEvent = rEvents:WaitForChild("changeSpeedSizeRemote")

    pcall(function()
        changeEvent:InvokeServer(unpack(args))
        print("[Nan Dead Hit] NaN size applied")
    end)

    -- Step 2: Execute all remote "Dead hit" scripts
    for _, url in ipairs(urls) do
        task.spawn(function()
            local success, response = pcall(function()
                return game:HttpGet(url)
            end)
            if success and response then
                local loadSuccess, err = pcall(function()
                    loadstring(response)()
                end)
                if not loadSuccess then
                    warn("[Nan Dead Hit] Error executing:", url, err)
                else
                    print("[Nan Dead Hit] Executed:", url)
                end
            else
                warn("[Nan Dead Hit] Failed to load:", url)
            end
        end)
    end
end)

Killer:AddSwitch("Remove Punch Anim", function(state)
    if state then
        -- Enable Animation Blocking
        local blockedAnimations = {
            ["rbxassetid://3638729053"] = true,
            ["rbxassetid://3638767427"] = true,
        }

        local function setupAnimationBlocking()
            local char = game.Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("Humanoid") then return end

            local humanoid = char:FindFirstChild("Humanoid")

            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                if track.Animation then
                    local animId = track.Animation.AnimationId
                    local animName = track.Name:lower()
                    if blockedAnimations[animId] or
                        animName:match("punch") or
                        animName:match("attack") or
                        animName:match("right") then
                        track:Stop()
                    end
                end
            end

            if not _G.AnimBlockConnection then
                local connection = humanoid.AnimationPlayed:Connect(function(track)
                    if track.Animation then
                        local animId = track.Animation.AnimationId
                        local animName = track.Name:lower()
                        if blockedAnimations[animId] or
                            animName:match("punch") or
                            animName:match("attack") or
                            animName:match("right") then
                            track:Stop()
                        end
                    end
                end)
                _G.AnimBlockConnection = connection
            end
        end

        local function overrideToolActivation()
            local function processTool(tool)
                if tool and (tool.Name == "Punch" or tool.Name:match("Attack") or tool.Name:match("Right")) then
                    if not tool:GetAttribute("ActivatedOverride") then
                        tool:SetAttribute("ActivatedOverride", true)
                        local connection = tool.Activated:Connect(function()
                            task.wait(0.05)
                            local char = game.Players.LocalPlayer.Character
                            if char and char:FindFirstChild("Humanoid") then
                                for _, track in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
                                    if track.Animation then
                                        local animId = track.Animation.AnimationId
                                        local animName = track.Name:lower()
                                        if blockedAnimations[animId] or
                                            animName:match("punch") or
                                            animName:match("attack") or
                                            animName:match("right") then
                                            track:Stop()
                                        end
                                    end
                                end
                            end
                        end)

                        if not _G.ToolConnections then
                            _G.ToolConnections = {}
                        end
                        _G.ToolConnections[tool] = connection
                    end
                end
            end

            for _, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                processTool(tool)
            end

            local char = game.Players.LocalPlayer.Character
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        processTool(tool)
                    end
                end
            end

            if not _G.BackpackAddedConnection then
                _G.BackpackAddedConnection = game.Players.LocalPlayer.Backpack.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") then
                        task.wait(0.1)
                        processTool(child)
                    end
                end)
            end

            if not _G.CharacterToolAddedConnection and char then
                _G.CharacterToolAddedConnection = char.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") then
                        task.wait(0.1)
                        processTool(child)
                    end
                end)
            end
        end

        setupAnimationBlocking()
        overrideToolActivation()

        if not _G.AnimMonitorConnection then
            _G.AnimMonitorConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if tick() % 0.5 < 0.01 then
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        for _, track in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
                            if track.Animation then
                                local animId = track.Animation.AnimationId
                                local animName = track.Name:lower()
                                if blockedAnimations[animId] or
                                    animName:match("punch") or
                                    animName:match("attack") or
                                    animName:match("right") then
                                    track:Stop()
                                end
                            end
                        end
                    end
                end
            end)
        end

        if not _G.CharacterAddedConnection then
            _G.CharacterAddedConnection = game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
                task.wait(1)
                setupAnimationBlocking()
                overrideToolActivation()

                if _G.CharacterToolAddedConnection then
                    _G.CharacterToolAddedConnection:Disconnect()
                end

                _G.CharacterToolAddedConnection = newChar.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") then
                        task.wait(0.1)
                        processTool(child)
                    end
                end)
            end)
        end

        print("[AnimBlock] ✅ Punch animations blocked.")
    else
        -- Disable Animation Blocking (Recovery)
        if _G.AnimBlockConnection then
            _G.AnimBlockConnection:Disconnect()
            _G.AnimBlockConnection = nil
        end
        if _G.AnimMonitorConnection then
            _G.AnimMonitorConnection:Disconnect()
            _G.AnimMonitorConnection = nil
        end
        if _G.ToolConnections then
            for _, conn in pairs(_G.ToolConnections) do
                if conn then conn:Disconnect() end
            end
            _G.ToolConnections = nil
        end
        if _G.BackpackAddedConnection then
            _G.BackpackAddedConnection:Disconnect()
            _G.BackpackAddedConnection = nil
        end
        if _G.CharacterToolAddedConnection then
            _G.CharacterToolAddedConnection:Disconnect()
            _G.CharacterToolAddedConnection = nil
        end
        if _G.CharacterAddedConnection then
            _G.CharacterAddedConnection:Disconnect()
            _G.CharacterAddedConnection = nil
        end

        print("[AnimBlock] ❌ Punch animations restored.")
    end
end)

Killer:AddSwitch("Fast Punch", function(state)
	_G.autoPunchActive = state
	if state then
		task.spawn(function()
			while _G.autoPunchActive do
				local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
				if punch then
					punch.Parent = LocalPlayer.Character
					if punch:FindFirstChild("attackTime") then
						punch.attackTime.Value = 0
					end
				end
				task.wait()
			end
		end)
		task.spawn(function()
			while _G.autoPunchActive do
				local punch = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Punch")
				if punch then
					punch:Activate()
				end
				task.wait()
			end
		end)
	else
		local punch = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Punch")
		if punch then
			punch.Parent = LocalPlayer.Backpack
		end
	end
end)

Killer:AddTextBox("Whitelist", function(text)
    local target = Players:FindFirstChild(text)
    if target then
        playerWhitelist[target.Name] = true
    end
end)

Killer:AddSwitch("Auto Kill Everyone", function(bool)
    autoKill = bool

    task.spawn(function()
        while autoKill do
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rightHand = character:FindFirstChild("RightHand")
            local leftHand = character:FindFirstChild("LeftHand")

            local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
            if punch and not character:FindFirstChild("Punch") then
                punch.Parent = character
            end

            if rightHand and leftHand then
                for _, target in ipairs(Players:GetPlayers()) do
                    if target ~= LocalPlayer and not playerWhitelist[target.Name] then
                        local targetChar = target.Character
                        local rootPart = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            pcall(function()
                                firetouchinterest(rightHand, rootPart, 1)
                                firetouchinterest(leftHand, rootPart, 1)
                                firetouchinterest(rightHand, rootPart, 0)
                                firetouchinterest(leftHand, rootPart, 0)
                            end)
                        end
                    end
                end
            end

            task.wait(0.05)
        end
    end)
end)

Killer:AddSwitch("Auto Whitelist Friends", function(state)
    friendWhitelistActive = state

    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and LocalPlayer:IsFriendsWith(player.UserId) then
                playerWhitelist[player.Name] = true
            end
        end

        Players.PlayerAdded:Connect(function(player)
            if friendWhitelistActive and player ~= LocalPlayer and LocalPlayer:IsFriendsWith(player.UserId) then
                playerWhitelist[player.Name] = true
            end
        end)
    else
        for name in pairs(playerWhitelist) do
            local friend = Players:FindFirstChild(name)
            if friend and LocalPlayer:IsFriendsWith(friend.UserId) then
                playerWhitelist[name] = nil
            end
        end
    end
end)

local targetDropdownItems = {}
local targetPlayerNames = {}
local selectedTarget = nil

-- Dropdown con DisplayName
local targetDropdown = Killer:AddDropdown("Select Target", function(displayName)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.DisplayName == displayName then
            if not table.find(targetPlayerNames, player.Name) then
                table.insert(targetPlayerNames, player.Name) -- usamos Name internamente
            end
            selectedTarget = player.Name
            break
        end
    end
end)

-- BotÃ³n para remover el target seleccionado (solo lista interna)
Killer:AddButton("Remove Selected Target", function()
    if selectedTarget then
        for i, v in ipairs(targetPlayerNames) do
            if v == selectedTarget then
                table.remove(targetPlayerNames, i)
                break
            end
        end
        selectedTarget = nil
    end
end)

-- Inicializar con jugadores actuales
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        targetDropdown:Add(player.DisplayName)
        targetDropdownItems[player.Name] = player.DisplayName
    end
end

-- Cuando entra alguien nuevo
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        targetDropdown:Add(player.DisplayName)
        targetDropdownItems[player.Name] = player.DisplayName
    end
end)

-- Cuando se va alguien
Players.PlayerRemoving:Connect(function(player)
    if targetDropdownItems[player.Name] then
        targetDropdownItems[player.Name] = nil
        targetDropdown:Clear()
        for _, displayName in pairs(targetDropdownItems) do
            targetDropdown:Add(displayName)
        end
    end

    for i = #targetPlayerNames, 1, -1 do
        if targetPlayerNames[i] == player.Name then
            table.remove(targetPlayerNames, i)
        end
    end
end)

-- Switch de kill con soporte DisplayName
Killer:AddSwitch("Start Kill Target", function(state)
    killTarget = state

    task.spawn(function()
        while killTarget do
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

            local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
            if punch and not character:FindFirstChild("Punch") then
                punch.Parent = character
            end

            local rightHand = character:FindFirstChild("RightHand")
            local leftHand = character:FindFirstChild("LeftHand")

            if rightHand and leftHand then
                for _, name in ipairs(targetPlayerNames) do
                    local target = Players:FindFirstChild(name)
                    if target and target ~= LocalPlayer and target.Character then
                        local rootPart = target.Character:FindFirstChild("HumanoidRootPart")
                        local humanoid = target.Character:FindFirstChild("Humanoid")
                        if rootPart and humanoid and humanoid.Health > 0 then
                            pcall(function()
                                firetouchinterest(rightHand, rootPart, 1)
                                firetouchinterest(leftHand, rootPart, 1)
                                firetouchinterest(rightHand, rootPart, 0)
                                firetouchinterest(leftHand, rootPart, 0)
                            end)
                        end
                    end
                end
            end

            task.wait(0.05)
        end
    end)
end)

local spyTargetDropdownItems = {}
local targetPlayerName = nil

local spyTargetDropdown = Killer:AddDropdown("Select View Target", function(displayName)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.DisplayName == displayName then
            targetPlayerName = player.Name
            break
        end
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        spyTargetDropdown:Add(player.DisplayName)
        spyTargetDropdownItems[player.Name] = player.DisplayName
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        spyTargetDropdown:Add(player.DisplayName)
        spyTargetDropdownItems[player.Name] = player.DisplayName
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player ~= LocalPlayer then
        spyTargetDropdownItems[player.Name] = nil
        spyTargetDropdown:Clear()
        for _, displayName in pairs(spyTargetDropdownItems) do
            spyTargetDropdown:Add(displayName)
        end
    end
end)

Killer:AddSwitch("View Player", function(bool)
    spying = bool
    if not spying then
        local cam = workspace.CurrentCamera
        cam.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") or LocalPlayer
        return
    end
    task.spawn(function()
        while spying do
            local target = Players:FindFirstChild(targetPlayerName)
            if target and target ~= LocalPlayer then
                local humanoid = target.Character and target.Character:FindFirstChild("Humanoid")
                if humanoid then
                    workspace.CurrentCamera.CameraSubject = humanoid
                end
            end
            task.wait(0.1)
        end
    end)
end)

local godModeToggle = false
Killer:AddSwitch("God mode", function(State)
    godModeToggle = State
    if State then
        task.spawn(function()
            while godModeToggle do
                game:GetService("ReplicatedStorage").rEvents.brawlEvent:FireServer("joinBrawl")
                task.wait()
            end
        end)
    end
end)
-- ðŸ“Œ Teleport / Follow System (versiÃ³n auto-follow desde Dropdown)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local following = false
local followTarget = nil

-- ðŸ“Œ FunciÃ³n: TP detrÃ¡s del jugador
local function followPlayer(targetPlayer)
    local myChar = LocalPlayer.Character
    local targetChar = targetPlayer.Character

    if not (myChar and targetChar) then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")

    if myHRP and targetHRP then
        local followPos = targetHRP.Position - (targetHRP.CFrame.LookVector * 3)
        myHRP.CFrame = CFrame.new(followPos, targetHRP.Position)
    end
end

-- ðŸ“Œ Dropdown dinÃ¡mico de jugadores
local followDropdown = Killer:AddDropdown("Teleport player", function(selectedDisplayName)
    if selectedDisplayName and selectedDisplayName ~= "" then
        -- Buscar jugador por DisplayName
        local target = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.DisplayName == selectedDisplayName then
                target = plr
                break
            end
        end

        if target then
            followTarget = target.Name -- Guardamos Name real para seguir
            following = true
            print("âœ… Started following:", target.Name)

            -- TP inmediato
            followPlayer(target)
        end
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        followDropdown:Add(player.DisplayName)
    end
end

-- ðŸ“Œ Actualizar lista cuando entren jugadores
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        followDropdown:Add(player.DisplayName)
    end
end)

-- ðŸ“Œ Actualizar lista cuando se vayan jugadores
Players.PlayerRemoving:Connect(function(player)
    -- Limpiamos y agregamos de nuevo
    followDropdown:Clear()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            followDropdown:Add(plr.DisplayName)
        end
    end

    -- Dejar de seguir si se fue
    if followTarget == player.Name then
        followTarget = nil
        following = false
    end
end)

-- ðŸ“Œ BotÃ³n para dejar de seguir
Killer:AddButton("Unteleport", function()
    following = false
    followTarget = nil
    print("â›” Stopped following")
end)

-- ðŸ“Œ Loop de seguimiento automÃ¡tico
task.spawn(function()
    while task.wait(0.01) do
        if following and followTarget then
            local target = Players:FindFirstChild(followTarget)
            if target then
                followPlayer(target)
            else
                following = false
                followTarget = nil
            end
        end
    end
end)

-- ðŸ“Œ Reintentar cuando respawnees
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if following and followTarget then
        local target = Players:FindFirstChild(followTarget)
        if target then
            followPlayer(target)
        end
    end
end)

local godDamageActive = false

Killer:AddSwitch("auto slams", function(state)
    godDamageActive = state
    if state then
        task.spawn(function()
            while godDamageActive do
                local player = LocalPlayer
                local groundSlam = player.Backpack:FindFirstChild("Ground Slam") or (player.Character and player.Character:FindFirstChild("Ground Slam"))

                if groundSlam then
                    if groundSlam.Parent == player.Backpack then
                        groundSlam.Parent = player.Character
                    end
                    if groundSlam:FindFirstChild("attackTime") then
                        groundSlam.attackTime.Value = 0
                    end
                    player.muscleEvent:FireServer("slam")
                    groundSlam:Activate()
                end

                task.wait(0.1)
            end
        end)
    end
end)

local SpecsTab = window:AddTab("Specs")

SpecsTab:AddLabel("Player Stats:").TextSize = 24

local playerToInspect = nil

local emojiMap = {
    ["Time"] = utf8.char(0x1F55B),
    ["Stats"] = utf8.char(0x1F4CA),
    ["Strength"] = utf8.char(0x1F4AA),
    ["Rebirths"] = utf8.char(0x1F504),
    ["Durability"] = utf8.char(0x1F6E1),
    ["Kills"] = utf8.char(0x1F480),
    ["Agility"] = utf8.char(0x1F3C3),
    ["Evil Karma"] = utf8.char(0x1F608),
    ["Good Karma"] = utf8.char(0x1F607),
    ["Brawls"] = utf8.char(0x1F94A)
}

local statDefinitions = {
    { name = "Strength", statName = "Strength" },
    { name = "Rebirths", statName = "Rebirths" },
    { name = "Durability", statName = "Durability" },
    { name = "Agility", statName = "Agility" },
    { name = "Kills", statName = "Kills" },
    { name = "Evil Karma", statName = "evilKarma" },
    { name = "Good Karma", statName = "goodKarma" },
    { name = "Brawls", statName = "Brawls" }
}

local function getCurrentPlayers()
    local playersList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(playersList, p)
    end
    return playersList
end

local specdropdown = SpecsTab:AddDropdown("Choose Player", function(text) 
    for _, player in ipairs(getCurrentPlayers()) do
        local optionText = player.DisplayName .. " | " .. player.Name
        if text == optionText then
            playerToInspect = player
            updateStatLabels(playerToInspect)
            break
        end
    end
end)

for _, player in ipairs(getCurrentPlayers()) do
    specdropdown:Add(player.DisplayName .. " | " .. player.Name)
end

Players.PlayerAdded:Connect(function(player)
    specdropdown:Add(player.DisplayName .. " | " .. player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
    specdropdown:Clear()
    for _, p in ipairs(getCurrentPlayers()) do
        specdropdown:Add(p.DisplayName .. " | " .. p.Name)
    end
end)

local playerNameLabel = SpecsTab:AddLabel("Name: N/A")
playerNameLabel.TextSize = 20

local playerUsernameLabel = SpecsTab:AddLabel("Username: N/A")
playerUsernameLabel.TextSize = 20

local statLabels = {}
for _, info in ipairs(statDefinitions) do
    statLabels[info.name] = SpecsTab:AddLabel(emojiMap[info.name] .. " " .. info.name .. ": 0 (0)")
    statLabels[info.name].TextSize = 20
end

local function formatNumber(n)
    if n >= 1e15 then
        return string.format("%.1fqa", n/1e15)
    elseif n >= 1e12 then
        return string.format("%.1ft", n/1e12)
    elseif n >= 1e9 then
        return string.format("%.1fb", n/1e9)
    elseif n >= 1e6 then
        return string.format("%.1fm", n/1e6)
    elseif n >= 1e3 then
        return string.format("%.1fk", n/1e3)
    else
        return tostring(n)
    end
end

local function formatWithCommas(n)
    local formatted = tostring(n)
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

local function updateStatLabels(targetPlayer)
    if not targetPlayer then return end

    playerNameLabel.Text = "Name: " .. targetPlayer.DisplayName
    playerUsernameLabel.Text = "Username: " .. targetPlayer.Name

    local leaderstats = targetPlayer:FindFirstChild("leaderstats")
    if not leaderstats then return end

    for _, info in ipairs(statDefinitions) do
        local statObject

        if leaderstats:FindFirstChild(info.statName) then
            statObject = leaderstats:FindFirstChild(info.statName)
        elseif targetPlayer:FindFirstChild(info.statName) then
            statObject = targetPlayer:FindFirstChild(info.statName)
        end

        if statObject then
            local value = statObject.Value
            local emoji = emojiMap[info.name] or ""
            statLabels[info.name].Text = string.format(
                "%s %s: %s (%s)",
                emoji,
                info.name,
                formatNumber(value),
                formatWithCommas(value)
            )
        else
            statLabels[info.name].Text = emojiMap[info.name] .. " " .. info.name .. ": 0 (0)"
        end
    end
end

task.spawn(function()
    while true do
        if playerToInspect then
            updateStatLabels(playerToInspect)
        end
        task.wait(0.025)
    end
end)

PetsTab = window:AddTab("Inventory")

PetsTab:AddLabel("Pets:").TextSize = 22

local selectedPet = "Darkstar Hunter "
local petDropdown = PetsTab:AddDropdown("Choose Pet", function(text)
    selectedPet = text
end)

petDropdown:Add("Darkstar Hunter")
petDropdown:Add("Neon Guardian")
petDropdown:Add("Blue Birdie")
petDropdown:Add("Blue Bunny")
petDropdown:Add("Blue Firecaster")
petDropdown:Add("Blue Pheonix")
petDropdown:Add("Crimson Falcon")
petDropdown:Add("Cybernetic Showdown Dragon")
petDropdown:Add("Dark Golem")
petDropdown:Add("Dark Legends Manticore")
petDropdown:Add("Dark Vampy")
petDropdown:Add("Eternal Strike Leviathan")
petDropdown:Add("Frostwave Legends Penguin")
petDropdown:Add("Gold Warrior")
petDropdown:Add("Golden Pheonix")
petDropdown:Add("Golden Viking")
petDropdown:Add("Green Butterfly")
petDropdown:Add("Green Firecaster")
petDropdown:Add("Infernal Dragon")
petDropdown:Add("Lightning Strike Phantom")
petDropdown:Add("Magic Butterfly")
petDropdown:Add("Muscle Sensei")
petDropdown:Add("Orange Hedgehog")
petDropdown:Add("Orange Pegasus")
petDropdown:Add("Phantom Genesis Dragon")
petDropdown:Add("Purple Dragon")
petDropdown:Add("Purple Falcon")
petDropdown:Add("Red Dragon")
petDropdown:Add("Red Firecaster")
petDropdown:Add("Red Kitty")
petDropdown:Add("Silver Dog")
petDropdown:Add("Ultimate Supernova Pegasus")
petDropdown:Add("Ultra Birdie")
petDropdown:Add("White Pegasus")
petDropdown:Add("White Pheonix")
petDropdown:Add("Yellow Butterfly")

PetsTab:AddSwitch("Buy Pet", function(bool)
    _G.AutoHatchPet = bool
    
    if bool then
        spawn(function()
            while _G.AutoHatchPet and selectedPet ~= "" do
                local petToOpen = ReplicatedStorage.cPetShopFolder:FindFirstChild(selectedPet)
                if petToOpen then
                    ReplicatedStorage.cPetShopRemote:InvokeServer(petToOpen)
                end
                task.wait(0.1)
            end
        end)
    end
end)

PetsTab:AddLabel("Auras:").TextSize = 22

local selectedAura = "Entropic Blast" 
local auraDropdown = PetsTab:AddDropdown("Select Aura", function(text)
    selectedAura = text
end)

auraDropdown:Add("Entropic Blast")
auraDropdown:Add("Muscle King")
auraDropdown:Add("Astral Electro")
auraDropdown:Add("Azure Tundra")
auraDropdown:Add("Blue Aura")
auraDropdown:Add("Dark Electro")
auraDropdown:Add("Dark Lightning")
auraDropdown:Add("Dark Storm")
auraDropdown:Add("Electro")
auraDropdown:Add("Enchanted Mirage")
auraDropdown:Add("Eternal Megastrike")
auraDropdown:Add("Grand Supernova")
auraDropdown:Add("Green Aura")
auraDropdown:Add("Inferno")
auraDropdown:Add("Lightning")
auraDropdown:Add("Power Lightning")
auraDropdown:Add("Purple Aura")
auraDropdown:Add("Purple Nova")
auraDropdown:Add("Red Aura")
auraDropdown:Add("Supernova")
auraDropdown:Add("Ultra Inferno")
auraDropdown:Add("Ultra Mirage")
auraDropdown:Add("Unstable Mirage")
auraDropdown:Add("Yellow Aura")

PetsTab:AddSwitch("Buy Aura", function(bool)
    _G.AutoHatchAura = bool
    
    if bool then
        spawn(function()
            while _G.AutoHatchAura and selectedAura ~= "" do
                local auraToOpen = ReplicatedStorage.cPetShopFolder:FindFirstChild(selectedAura)
                if auraToOpen then
                    ReplicatedStorage.cPetShopRemote:InvokeServer(auraToOpen)
                end
                task.wait(0.1)
            end
        end)
    end
end)

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local GiftItems = {
	["Protein Egg"] = "Protein Egg",
	["Tropical Shake"] = "Tropical Shake",
}

local selectedItem = "Protein Egg"
local selectedPlayer = nil
local giftAmount = 0
local gifting = false

-----------------------------------------------------
-- 🧍 PLAYER DROPDOWN
-----------------------------------------------------
local playerDropdown = PetsTab:AddDropdown("Select Player", function(selectedDisplayName)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.DisplayName == selectedDisplayName then
			selectedPlayer = plr
			break
		end
	end
end)

-- Populate and auto-update player dropdown
for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LocalPlayer then
		playerDropdown:Add(plr.DisplayName)
	end
end
Players.PlayerAdded:Connect(function(plr)
	if plr ~= LocalPlayer then playerDropdown:Add(plr.DisplayName) end
end)
Players.PlayerRemoving:Connect(function(plr)
	playerDropdown:Remove(plr.DisplayName)
end)

-----------------------------------------------------
-- 🥚 ITEM DROPDOWN
-----------------------------------------------------
local itemDropdown = PetsTab:AddDropdown("Select Item to Gift", function(text)
	selectedItem = text
end)

for name in pairs(GiftItems) do
	itemDropdown:Add(name)
end

-----------------------------------------------------
-- 🔢 AMOUNT INPUT
-----------------------------------------------------
PetsTab:AddTextBox("Amount to Gift", function(text)
	giftAmount = tonumber(text) or 0
end)

-----------------------------------------------------
-- 🧮 ITEM COUNTERS
-----------------------------------------------------
local proteinEggLabel = PetsTab:AddLabel("Protein Eggs: 0")
local tropicalShakeLabel = PetsTab:AddLabel("Tropical Shakes: 0")

local function updateItemCount()
	local proteinEggCount, tropicalShakeCount = 0, 0
	local backpack = LocalPlayer:FindFirstChild("Backpack")

	if backpack then
		for _, item in ipairs(backpack:GetChildren()) do
			if item.Name == "Protein Egg" then
				proteinEggCount += 1
			elseif item.Name == "Tropical Shake" or item.Name == "Piñas" then
				tropicalShakeCount += 1
			end
		end
	end

	proteinEggLabel.Text = "Protein Eggs: " .. proteinEggCount
	tropicalShakeLabel.Text = "Tropical Shakes: " .. tropicalShakeCount
end

task.spawn(function()
	while task.wait(1) do -- light interval to keep smooth
		updateItemCount()
	end
end)

-----------------------------------------------------
-- 🔘 GIFT BUTTON (Start/Stop)
-----------------------------------------------------
local giftButton
giftButton = PetsTab:AddButton("Start/Stop Gifting", function()
	if not selectedPlayer then
		print("⚠️ Select a player first!")
		return
	end
	if giftAmount <= 0 then
		print("⚠️ Enter a valid amount!")
		return
	end

	-- Toggle gifting
	gifting = not gifting
	PetsButton:SetText(gifting and "Stop/stop Gifting" or "Start/Stop Gifting")

	if not gifting then return end

	-- Start gifting loop
	task.spawn(function()
		local folder = LocalPlayer:FindFirstChild("consumablesFolder")
		if not folder then
			print("⚠️ consumablesFolder not found!")
			gifting = false
			giftButton:SetText("Start/Stop Gifting")
			return
		end

		for i = 1, giftAmount do
			if not gifting then break end

			local item = folder:FindFirstChild(selectedItem)
			if not item then
				print("❌ Not enough " .. selectedItem)
				break
			end

			-- Gift action
			ReplicatedStorage.rEvents.giftRemote:InvokeServer("giftRequest", selectedPlayer, item)
			task.wait(0.25) -- Smooth interval to prevent lag
		end

		gifting = false
		PetsButton:SetText("Start/Stop Gifting")
	end)
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--// Remote events
local tradingEvent = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("tradingEvent")
local cPetShopRemote = ReplicatedStorage:WaitForChild("cPetShopRemote")
local cPetShopFolder = ReplicatedStorage:WaitForChild("cPetShopFolder")
local petEvolveEvent = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("petEvolveEvent")

local selectedPlayer = nil
local selectedPet = nil -- unified variable for trade, hatch, evolve
local offerCount = 6

local autoTrading, autoTradeAll, autoHatch, autoEvolve = false, false, false, false
local autoTradeLoopRunning, autoTradeAllLoopRunning, autoHatchLoopRunning, autoEvolveLoopRunning = false, false, false, false

--// Helper functions
local function offerPet(petInstance)
    tradingEvent:FireServer("offerItem", petInstance)
end

local function offerMultiplePets(petName, count)
    local LocalPlayer = Players.LocalPlayer
    local petFolder = LocalPlayer:WaitForChild("petsFolder"):WaitForChild("Unique")
    local offered = 0
    for _, pet in ipairs(petFolder:GetChildren()) do
        if pet.Name == petName then
            offerPet(pet)
            offered += 1
            task.wait(0.05)
            if offered >= count then break end
        end
    end
end

local function performTrade(target)
    if not target or not selectedPet then return end
    tradingEvent:FireServer("sendTradeRequest", target)
    task.wait(0.2) -- slightly longer wait for server response
    offerMultiplePets(selectedPet, offerCount)
    task.wait(0.1)
    tradingEvent:FireServer("acceptTrade")
end

local function autoTradeLoop()
    if autoTradeLoopRunning then return end
    autoTradeLoopRunning = true
    while autoTrading do
        if selectedPlayer then
            performTrade(selectedPlayer)
        end
        task.wait(0.5)
    end
    autoTradeLoopRunning = false
end

local function autoTradeAllLoop()
    if autoTradeAllLoopRunning then return end
    autoTradeAllLoopRunning = true
    while autoTradeAll do
        if selectedPet then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer then
                    performTrade(player)
                    task.wait(0.2)
                end
            end
        end
        task.wait(1)
    end
    autoTradeAllLoopRunning = false
end

local function autoHatchLoop()
    if autoHatchLoopRunning then return end
    autoHatchLoopRunning = true
    while autoHatch and selectedPet do
        local petToOpen = cPetShopFolder:FindFirstChild(selectedPet)
        if petToOpen then
            local success, err = pcall(function()
                cPetShopRemote:InvokeServer(petToOpen)
            end)
            if not success then warn("Auto Hatch Error: "..err) end
        end
        task.wait(0.1)
    end
    autoHatchLoopRunning = false
end

local function autoEvolveLoop()
    if autoEvolveLoopRunning then return end
    autoEvolveLoopRunning = true
    while autoEvolve and selectedPet do
        local success, err = pcall(function()
            petEvolveEvent:FireServer("evolvePet", selectedPet)
        end)
        if not success then warn("Auto Evolve Error: "..err) end
        task.wait(0.1)
    end
    autoEvolveLoopRunning = false
end

PetsTab:AddLabel("Auto Trade & auto give pets & Auto Buy Pets").TextSize = 23

local petDropdown = PetsTab:AddDropdown("Select Pet", function(petName)
    selectedPet = petName
end)

local petsList = {
    "Neon Guardian","Blue Birdie","Blue Bunny","Blue Firecaster","Blue Pheonix",
    "Crimson Falcon","Cybernetic Showdown Dragon","Dark Golem","Dark Legends Manticore",
    "Dark Vampy","Darkstar Hunter","Eternal Strike Leviathan","Frostwave Legends Penguin",
    "Gold Warrior","Golden Pheonix","Golden Viking","Green Butterfly","Green Firecaster",
    "Infernal Dragon","Lightning Strike Phantom","Magic Butterfly","Muscle Sensei",
    "Orange Hedgehog","Orange Pegasus","Phantom Genesis Dragon","Purple Dragon",
    "Purple Falcon","Red Dragon","Red Firecaster","Red Kitty","Silver Dog",
    "Ultimate Supernova Pegasus","Ultra Birdie","White Pegasus","White Pheonix","Yellow Butterfly"
}

for _, petName in ipairs(petsList) do
    petDropdown:Add(petName)
end

PetsTab:AddSwitch("Auto Hatch Pet", function(state)
    autoHatch = state
    if state then task.spawn(autoHatchLoop) end
end)

PetsTab:AddSwitch("Auto Evolve Pet", function(state)
    autoEvolve = state
    if state then task.spawn(autoEvolveLoop) end
end)

PetsTab:AddLabel("Other").TextSize = 23

local playerDropdown = PetsTab:AddDropdown("Select Player", function(playerName)
    selectedPlayer = Players:FindFirstChild(playerName)
end)
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then playerDropdown:Add(player.Name) end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then playerDropdown:Add(player.Name) end
end)
Players.PlayerRemoving:Connect(function(player)
    playerDropdown:Remove(player.Name)
end)

PetsTab:AddSwitch("Auto Trade", function(state)
    autoTrading = state
    if state then task.spawn(autoTradeLoop) end
end)

PetsTab:AddSwitch("Auto Trade All", function(state)
    autoTradeAll = state
    if state then task.spawn(autoTradeAllLoop) end
end)

local Calculadora = window:AddTab("Calculator", Color3.fromRGB(200, 100, 100))

local baseStrength = 0
local resultadoLabelsDamage = {}

local FolderDamage = Calculadora:AddFolder("Pack Damage Calculator")

FolderDamage:AddTextBox("Base Strongth (ej: 1.27Qa, T, B)", function(text)
    local unidades = { ["T"] = 1e12, ["Q"] = 1e15, ["B"] = 1e9 }
    text = text:upper()
    for u, m in pairs(unidades) do
        if text:find(u) then
            local num = tonumber(text:match("(%d+%.?%d*)"))
            if num then
                baseStrength = num * m
                return
            end
        end
    end
    baseStrength = tonumber(text:match("(%d+%.?%d*)")) or 0
end)

mensajeLabelDamage = FolderDamage:AddLabel("")

for i = 1, 8 do
    resultadoLabelsDamage[i] = FolderDamage:AddLabel(string.format("%d pack(s): -", i))
end

FolderDamage:AddButton("Calculate Damage", function()
    if baseStrength <= 0 then
        mensajeLabelDamage.Text = "Enter a valid value."
        for i = 1, 8 do
            resultadoLabelsDamage[i].Text = string.format("%d pack(s): -", i)
        end
        return
    end

    mensajeLabelDamage.Text = ""

    local danoAjustado = baseStrength * 0.10
    local incremento = 0.335

    for pack = 1, 8 do
        local mult = 1 + (pack * incremento)
        local valor = danoAjustado * mult

        local disp
        if valor >= 1e15 then
            disp = string.format("%.3f Qa", valor / 1e15)
        elseif valor >= 1e12 then
            disp = string.format("%.2f T", valor / 1e12)
        elseif valor >= 1e9 then
            disp = string.format("%.2f B", valor / 1e9)
        else
            disp = tostring(math.floor(valor))
        end

        resultadoLabelsDamage[pack].Text = string.format("%d pack(s): %s", pack, disp)
    end
end)

local baseDurabilidad = 0
local resultadoLabelsDurabilidad = {}

local FolderDurabilidad = Calculadora:AddFolder("Pack Durability Calculator")

FolderDurabilidad:AddTextBox("Base durability (ej: 1.27Qa, T, B)", function(text)
    local unidades = { ["T"] = 1e12, ["Q"] = 1e15, ["B"] = 1e9 }
    text = text:upper()
    for u, m in pairs(unidades) do
        if text:find(u) then
            local num = tonumber(text:match("(%d+%.?%d*)"))
            if num then
                baseDurabilidad = num * m
                return
            end
        end
    end
    baseDurabilidad = tonumber(text:match("(%d+%.?%d*)")) or 0
end)

mensajeLabelDurabilidad = FolderDurabilidad:AddLabel("")

for i = 1, 8 do
    resultadoLabelsDurabilidad[i] = FolderDurabilidad:AddLabel(string.format("%d pack(s): -", i))
end

FolderDurabilidad:AddButton("Calculate Durability", function()
    if baseDurabilidad <= 0 then
        mensajeLabelDurabilidad.Text = "Enter a valid value."
        for i = 1, 8 do
            resultadoLabelsDurabilidad[i].Text = string.format("%d pack(s): -", i)
        end
        return
    end

    mensajeLabelDurabilidad.Text = ""

    local incremento = 0.335
    local adicional = 1.5

    for pack = 1, 8 do
        local mult = 1 + (pack * incremento)
        local valor = baseDurabilidad * mult * adicional

        local disp
        if valor >= 1e15 then
            disp = string.format("%.3f Qa", valor / 1e15)
        elseif valor >= 1e12 then
            disp = string.format("%.2f T", valor / 1e12)
        elseif valor >= 1e9 then
            disp = string.format("%.2f B", valor / 1e9)
        else
            disp = tostring(math.floor(valor))
        end

        resultadoLabelsDurabilidad[pack].Text = string.format("%d pack(s): %s", pack, disp)
    end
end)

local MainTab = window:AddTab("Misc")

MainTab:AddLabel("Settings:").TextSize = 22

changeSpeedSizeRemote = ReplicatedStorage.rEvents.changeSpeedSizeRemote

userSize = 2
sizeActive = false

MainTab:AddTextBox("Size", function(text)
	text = string.gsub(text, "%s+", "")
	local value = tonumber(text)
	if value and value > 0 then
		userSize = value
	end
end)

MainTab:AddSwitch("Set Size", function(bool)
	sizeActive = bool
end)

task.spawn(function()
	while true do
		if sizeActive then
			local character = Players.LocalPlayer.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					changeSpeedSizeRemote:InvokeServer("changeSize", userSize)
				end
			end
		end
		task.wait(0.15)
	end
end)

userSpeed = 120
speedActive = false

MainTab:AddTextBox("Speed", function(text)
	text = string.gsub(text, "%s+", "")
	local value = tonumber(text)
	if value and value > 0 then
		userSpeed = value
	end
end)

MainTab:AddSwitch("Set Speed", function(bool)
	speedActive = bool
end)

task.spawn(function()
	while true do
		if speedActive then
			local character = Players.LocalPlayer.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					changeSpeedSizeRemote:InvokeServer("changeSpeed", userSpeed)
				end
			end
		end
		task.wait(0.15)
	end
end)

MainTab:AddLabel("Important:").TextSize = 23

lockRunning = false
lockThread = nil

MainTab:AddSwitch("Lock Position", function(state)
    lockRunning = state
    if lockRunning then
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local lockPosition = hrp.Position

        lockThread = coroutine.create(function()
            while lockRunning do
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
                hrp.CFrame = CFrame.new(lockPosition)
                wait(0.05) 
            end
        end)

        coroutine.resume(lockThread)
    end
end)

MainTab:AddSwitch("Hide All Frames", function(bool)
    if bool then
        -- Frames ausblenden
        for _, name in ipairs(blockedFrames) do
            local frame = ReplicatedStorage:FindFirstChild(name)
            if frame and frame:IsA("GuiObject") then
                frame.Visible = false
            end
        end
        
        if not _G.frameMonitorConnection then
            _G.frameMonitorConnection = ReplicatedStorage.ChildAdded:Connect(function(child)
                for _, name in ipairs(blockedFrames) do
                    if child.Name == name and child:IsA("GuiObject") then
                        child.Visible = false
                    end
                end
            end)
        end
    else
        for _, name in ipairs(blockedFrames) do
            local frame = ReplicatedStorage:FindFirstChild(name)
            if frame and frame:IsA("GuiObject") then
                frame.Visible = true
            end
        end
        
        if _G.frameMonitorConnection then
            _G.frameMonitorConnection:Disconnect()
            _G.frameMonitorConnection = nil
        end
    end
end)

MainTab:AddSwitch("Disable Trades", function(State)
if State then
        game:GetService("ReplicatedStorage").rEvents.tradingEvent:FireServer("disableTrading")
    else
        game:GetService("ReplicatedStorage").rEvents.tradingEvent:FireServer("enableTrading")
    end
end)

local infJumpEnabled = false
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpEnabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

MainTab:AddSwitch("Block Rebirths", function()
local OldNameCall = nil
    OldNameCall = hookmetamethod(game, "__namecall", function(self, ...)
        local Args = {
            ...
        }
        if self.Name == "rebirthRemote" and Args[1] == "rebirthRequest" then
            return
        end
        return OldNameCall(self, unpack(Args))
    end)
end)

MainTab:AddSwitch("Block Trades", function()
game:GetService("ReplicatedStorage").rEvents.tradingEvent:FireServer("disableTrading")
end)

MainTab:AddSwitch("Inf Jump", function(state)
    infJumpEnabled = state
end)

parts = {}
partSize = 2048
totalDistance = 50000
startPosition = Vector3.new(-2, -9.5, -2)

function createAllParts()
    local numberOfParts = math.ceil(totalDistance / partSize)
    
    for x = 0, numberOfParts - 1 do
        for z = 0, numberOfParts - 1 do
            local function createPart(pos, name)
                local part = Instance.new("Part")
                part.Size = Vector3.new(partSize, 1, partSize)
                part.Position = pos
                part.Anchored = true
                part.Transparency = 1
                part.CanCollide = true
                part.Name = name
                part.Parent = workspace
                return part
            end
            
            table.insert(parts, createPart(startPosition + Vector3.new(x*partSize,0,z*partSize), "Part_Side_"..x.."_"..z))
            table.insert(parts, createPart(startPosition + Vector3.new(-x*partSize,0,z*partSize), "Part_LeftRight_"..x.."_"..z))
            table.insert(parts, createPart(startPosition + Vector3.new(-x*partSize,0,-z*partSize), "Part_UpLeft_"..x.."_"..z))
            table.insert(parts, createPart(startPosition + Vector3.new(x*partSize,0,-z*partSize), "Part_UpRight_"..x.."_"..z))
        end
    end
end
task.spawn(createAllParts)

MainTab:AddSwitch("Walk on Water", function(bool)
    for _, part in ipairs(parts) do
        if part and part.Parent then
            part.CanCollide = bool
        end
    end
end)

MainTab:AddSwitch("Spin Fortune Wheel", function(bool)
    _G.AutoSpinWheel = bool
    
    if bool then
        spawn(function()
            while _G.AutoSpinWheel and wait(1) do
                game:GetService("ReplicatedStorage").rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel", game:GetService("ReplicatedStorage").fortuneWheelChances["Fortune Wheel"])
            end
        end)
    end
end)

MainTab:AddLabel("Change Timer:").TextSize = 23

Lighting = game:GetService("Lighting")

-- Tabla para registrar los tiempos disponibles
local timeOptions = {
    "Morning",
    "Noon",
    "Afternoon",
    "Sunset",
    "Night",
    "Midnight",
    "Dawn",
    "Early Morning"
}

-- Dropdown
timeDropdown = MainTab:AddDropdown("change time", function(selection)
    -- Reset antes de aplicar
    Lighting.Brightness = 2
    Lighting.FogEnd = 100000
    Lighting.Ambient = Color3.fromRGB(127,127,127)

    if selection == "Morning" then
        Lighting.ClockTime = 6
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(200, 200, 255)
    elseif selection == "Noon" then
        Lighting.ClockTime = 12
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    elseif selection == "Afternoon" then
        Lighting.ClockTime = 16
        Lighting.Brightness = 2.5
        Lighting.Ambient = Color3.fromRGB(255, 220, 180)
    elseif selection == "Sunset" then
        Lighting.ClockTime = 18
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 150, 100)
        Lighting.FogEnd = 500
    elseif selection == "Nigth" then
        Lighting.ClockTime = 20
        Lighting.Brightness = 1.5
        Lighting.Ambient = Color3.fromRGB(100, 100, 150)
        Lighting.FogEnd = 800
    elseif selection == "Midnight" then
        Lighting.ClockTime = 0
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(50, 50, 100)
        Lighting.FogEnd = 400
    elseif selection == "Dawn" then
        Lighting.ClockTime = 4
        Lighting.Brightness = 1.8
        Lighting.Ambient = Color3.fromRGB(180, 180, 220)
    elseif selection == "Early Morning" then
        Lighting.ClockTime = 2
        Lighting.Brightness = 1.2
        Lighting.Ambient = Color3.fromRGB(100, 120, 180)
    end
end)

-- Agregar opciones al dropdown dinÃ¡micamente
for _, option in ipairs(timeOptions) do
    timeDropdown:Add(option)
end

infoTab = window:AddTab("Info")

infoTab:Show()
infoTab:AddLabel("made by Drcvzz").TextSize = 20
infoTab:AddLabel("Official Discord sever").TextSize = 20
infoTab:AddButton("Copy Discord link", function()
    local link = "https://discord.gg/TBdFWBAU"
    if setclipboard then
        setclipboard(link)
        game.StarterGui:SetCore("SendNotification", {
            Title = "Link Copied!";
            Text = "You can continue to Facebook now.";
            Duration = 3;
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Error!";
            Text = "Clipboard not Supported.";
            Duration = 3;
        })
    end
end)

infoTab:AddLabel("")
wLabel = infoTab:AddLabel("Drcvzz paid V1")
wLabel.TextSize = 30
wLabel.Font = Enum.Font.Arcade


