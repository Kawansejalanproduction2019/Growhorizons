local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

local purchaseRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PurchaseShopItem")
local sellRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SellItems")
local harvestRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("HarvestFruit")
local plantRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PlantSeed")
local removeRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):FindFirstChild("RemovePlant")

local isAutoBuyWhitelistOn = false
local isAutoBuyAllOn = false
local isAutoBuyGearWhitelistOn = false
local isAutoBuyAllGearOn = false
local isAutoSellOn = false
local isAutoFarmOn = false
local isAutoPlantOn = false
local isAutoShovelOn = false
local isAntiAfkOn = false

local autoBuyMode = "Normal"
local sellIntervalSeconds = 60
local harvestDuration = 60
local harvestCooldown = 300
local harvestState = "Harvesting"
local harvestTimer = 0
local sellTimer = 0
local antiAfkIntervalMinutes = 5
local afkTimer = 0

local plantSourceMode = "All"
local plantLocationMode = "Player"
local shovelMode = "All"
local stackedPosition = nil

local isFlying = false
local flySpeed = 50
local flyUpMobile = false
local flyDownMobile = false
local bodyVelocity = nil
local bodyGyro = nil

local activeSeedWhitelist = {}
local activeGearWhitelist = {}

local allSeedsList = {
    "Carrot Seed", "Corn Seed", "Onion Seed", "Strawberry Seed", 
    "Mushroom Seed", "Beetroot Seed", "Tomato Seed", "Apple Seed", 
    "Rose Seed", "Wheat Seed", "Banana Seed", "Plum Seed", 
    "Potato Seed", "Cabbage Seed", "Cherry Seed", "Lemon Seed", 
    "Watermelon Seed", "Pumpkin Seed", "Grape Seed", "Blueberry Seed"
}

local allGearsList = {
    "Watering Can", "Basic Sprinkler", "Harvest Bell", 
    "Turbo Sprinkler", "Favorite Tool", "Super Sprinkler"
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RhdevsHubUI"
screenGui.Parent = CoreGui

local openHubBtn = Instance.new("TextButton")
openHubBtn.Size = UDim2.new(0, 50, 0, 50)
openHubBtn.Position = UDim2.new(0, 20, 0.5, -25)
openHubBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
openHubBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openHubBtn.Text = "HUB"
openHubBtn.Font = Enum.Font.GothamBold
openHubBtn.Visible = false
openHubBtn.Parent = screenGui
Instance.new("UICorner", openHubBtn).CornerRadius = UDim.new(1, 0)

local flyUpBtn = Instance.new("TextButton")
flyUpBtn.Size = UDim2.new(0, 60, 0, 60)
flyUpBtn.Position = UDim2.new(1, -80, 0.5, -70)
flyUpBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
flyUpBtn.BackgroundTransparency = 0.5
flyUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyUpBtn.Text = "NAIK"
flyUpBtn.Font = Enum.Font.GothamBold
flyUpBtn.Visible = false
flyUpBtn.Parent = screenGui
Instance.new("UICorner", flyUpBtn).CornerRadius = UDim.new(1, 0)

local flyDownBtn = Instance.new("TextButton")
flyDownBtn.Size = UDim2.new(0, 60, 0, 60)
flyDownBtn.Position = UDim2.new(1, -80, 0.5, 10)
flyDownBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
flyDownBtn.BackgroundTransparency = 0.5
flyDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyDownBtn.Text = "TURUN"
flyDownBtn.Font = Enum.Font.GothamBold
flyDownBtn.Visible = false
flyDownBtn.Parent = screenGui
Instance.new("UICorner", flyDownBtn).CornerRadius = UDim.new(1, 0)

flyUpBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        flyUpMobile = true
    end
end)
flyUpBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        flyUpMobile = false
    end
end)

flyDownBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        flyDownMobile = true
    end
end)
flyDownBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        flyDownMobile = false
    end
end)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 550, 0, 450)
mainFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Rhdevs Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local btnMinimize = Instance.new("TextButton")
btnMinimize.Size = UDim2.new(0, 40, 0, 40)
btnMinimize.Position = UDim2.new(1, -40, 0, 0)
btnMinimize.BackgroundTransparency = 1
btnMinimize.TextColor3 = Color3.fromRGB(200, 50, 50)
btnMinimize.Text = "-"
btnMinimize.Font = Enum.Font.GothamBold
btnMinimize.TextSize = 24
btnMinimize.Parent = topBar

local fixCorner = Instance.new("Frame")
fixCorner.Size = UDim2.new(1, 0, 0, 10)
fixCorner.Position = UDim2.new(0, 0, 1, -10)
fixCorner.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
fixCorner.BorderSizePixel = 0
fixCorner.Parent = topBar

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 35)
tabContainer.Position = UDim2.new(0, 0, 0, 40)
tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
tabContainer.Parent = mainFrame

local btnTabInfo = Instance.new("TextButton")
btnTabInfo.Size = UDim2.new(0.25, 0, 1, 0)
btnTabInfo.Position = UDim2.new(0, 0, 0, 0)
btnTabInfo.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
btnTabInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTabInfo.Text = "Info"
btnTabInfo.Font = Enum.Font.GothamBold
btnTabInfo.Parent = tabContainer

local btnTabFarm = Instance.new("TextButton")
btnTabFarm.Size = UDim2.new(0.25, 0, 1, 0)
btnTabFarm.Position = UDim2.new(0.25, 0, 0, 0)
btnTabFarm.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
btnTabFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTabFarm.Text = "Farm"
btnTabFarm.Font = Enum.Font.GothamBold
btnTabFarm.Parent = tabContainer

local btnTabPlayer = Instance.new("TextButton")
btnTabPlayer.Size = UDim2.new(0.25, 0, 1, 0)
btnTabPlayer.Position = UDim2.new(0.5, 0, 0, 0)
btnTabPlayer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
btnTabPlayer.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTabPlayer.Text = "Player"
btnTabPlayer.Font = Enum.Font.GothamBold
btnTabPlayer.Parent = tabContainer

local btnTabTeleport = Instance.new("TextButton")
btnTabTeleport.Size = UDim2.new(0.25, 0, 1, 0)
btnTabTeleport.Position = UDim2.new(0.75, 0, 0, 0)
btnTabTeleport.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
btnTabTeleport.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTabTeleport.Text = "Teleport"
btnTabTeleport.Font = Enum.Font.GothamBold
btnTabTeleport.Parent = tabContainer

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, -75)
contentContainer.Position = UDim2.new(0, 0, 0, 75)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local infoScroll = Instance.new("ScrollingFrame")
infoScroll.Size = UDim2.new(1, 0, 1, 0)
infoScroll.BackgroundTransparency = 1
infoScroll.CanvasSize = UDim2.new(0, 0, 0, 750)
infoScroll.ScrollBarThickness = 6
infoScroll.Parent = contentContainer

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(0.9, 0, 1, 0)
infoText.Position = UDim2.new(0.05, 0, 0.02, 0)
infoText.BackgroundTransparency = 1
infoText.TextColor3 = Color3.fromRGB(200, 200, 200)
infoText.Text = "Rhdevs Hub - Control Panel\n\nKEUNGGULAN TOOLS:\n- UTC Global Time Beta Mode: Mode Auto Buy Beta sinkron langsung dengan jam UTC dunia.\n- Teleport & Return: Fitur Sell dan Buy merekam posisi asli dan mengembalikan karakter instan.\n- Advanced Harvest: Target GrowthAnchorIndex diubah hingga skala 6 untuk melibas semua tipe pohon (seperti Banana).\n- Auto Shovel/Remove Plant: Fitur baru mencabut tanaman/buah langsung dari map dengan pencocokan nama dan mode Whitelist.\n- Filter Buah KG: Auto Plant mengabaikan semua item yang mengandung teks 'KG'.\n- Auto Copy Clipboard: Tombol Dapatkan Posisi otomatis menyalin nilai.\n\nCARA PENGGUNAAN:\n1. Auto Buy Mode: Gunakan mode Normal untuk jarak jauh. Gunakan mode Beta (Teleport) untuk Bypass tingkat tinggi.\n2. Auto Harvest: Atur slider Durasi dan Jeda.\n3. Auto Sell: Geser slider interval detik.\n4. Auto Plant & Shovel: Pilih mode sumber (All/Whitelist). Mode Shovel (mencabut tanaman) bergantung pada whitelist seed yang kamu pilih!\n5. Terbang & Anti-AFK: Nyalakan dari tab Player."
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 13
infoText.TextWrapped = true
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = infoScroll

local farmScroll = Instance.new("ScrollingFrame")
farmScroll.Size = UDim2.new(1, 0, 1, 0)
farmScroll.BackgroundTransparency = 1
farmScroll.Visible = false
farmScroll.ScrollBarThickness = 6
farmScroll.Parent = contentContainer

local farmLayout = Instance.new("UIListLayout")
farmLayout.SortOrder = Enum.SortOrder.LayoutOrder
farmLayout.Padding = UDim.new(0, 10)
farmLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
farmLayout.Parent = farmScroll

local farmPadding = Instance.new("UIPadding")
farmPadding.PaddingTop = UDim.new(0, 10)
farmPadding.PaddingBottom = UDim.new(0, 10)
farmPadding.Parent = farmScroll

farmLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    farmScroll.CanvasSize = UDim2.new(0, 0, 0, farmLayout.AbsoluteContentSize.Y + 20)
end)

local function createSlider(parent, labelText, minVal, maxVal, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = labelText .. ": " .. tostring(defaultVal)
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.9, 0, 0, 10)
    sliderBg.Position = UDim2.new(0.05, 0, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    sliderBg.Parent = frame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
    fill.Parent = sliderBg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = sliderBg
    
    local isDragging = false
    
    local function update(input)
        local rawPos = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
        local pos = math.clamp(rawPos, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(minVal + ((maxVal - minVal) * pos))
        label.Text = labelText .. ": " .. tostring(val)
        callback(val)
    end
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            update(input)
        end
    end)
    
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    frame.Parent = parent
    return frame
end

local btnToggleSeedView = Instance.new("TextButton")
btnToggleSeedView.Size = UDim2.new(0.9, 0, 0, 40)
btnToggleSeedView.BackgroundColor3 = Color3.fromRGB(180, 130, 40)
btnToggleSeedView.TextColor3 = Color3.fromRGB(255, 255, 255)
btnToggleSeedView.Text = "Buka Pilihan Whitelist Seed"
btnToggleSeedView.Font = Enum.Font.GothamBold
btnToggleSeedView.Parent = farmScroll
Instance.new("UICorner", btnToggleSeedView).CornerRadius = UDim.new(0, 6)

local seedListContainer = Instance.new("ScrollingFrame")
seedListContainer.Size = UDim2.new(0.9, 0, 0, 150)
seedListContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
seedListContainer.CanvasSize = UDim2.new(0, 0, 0, 400)
seedListContainer.ScrollBarThickness = 4
seedListContainer.Visible = false
seedListContainer.Parent = farmScroll
Instance.new("UICorner", seedListContainer).CornerRadius = UDim.new(0, 6)

local seedGridLayout = Instance.new("UIGridLayout")
seedGridLayout.CellSize = UDim2.new(0.48, 0, 0, 35)
seedGridLayout.CellPadding = UDim2.new(0.02, 0, 0, 5)
seedGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
seedGridLayout.Parent = seedListContainer

for _, seedName in ipairs(allSeedsList) do
    local seedBtn = Instance.new("TextButton")
    seedBtn.Text = seedName
    seedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    seedBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    seedBtn.Font = Enum.Font.Gotham
    seedBtn.TextSize = 12
    seedBtn.Parent = seedListContainer
    Instance.new("UICorner", seedBtn).CornerRadius = UDim.new(0, 4)
    
    seedBtn.MouseButton1Click:Connect(function()
        if activeSeedWhitelist[seedName] then
            activeSeedWhitelist[seedName] = nil
            seedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            seedBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        else
            activeSeedWhitelist[seedName] = true
            seedBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            seedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
end

btnToggleSeedView.MouseButton1Click:Connect(function()
    seedListContainer.Visible = not seedListContainer.Visible
    if seedListContainer.Visible then
        btnToggleSeedView.Text = "Tutup Pilihan Whitelist Seed"
    else
        btnToggleSeedView.Text = "Buka Pilihan Whitelist Seed"
    end
end)

local btnAutoBuyMode = Instance.new("TextButton")
btnAutoBuyMode.Size = UDim2.new(0.9, 0, 0, 40)
btnAutoBuyMode.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
btnAutoBuyMode.TextColor3 = Color3.fromRGB(200, 255, 200)
btnAutoBuyMode.Text = "Mode Auto Buy: Normal"
btnAutoBuyMode.Font = Enum.Font.GothamBold
btnAutoBuyMode.Parent = farmScroll
Instance.new("UICorner", btnAutoBuyMode).CornerRadius = UDim.new(0, 6)

btnAutoBuyMode.MouseButton1Click:Connect(function()
    if autoBuyMode == "Normal" then
        autoBuyMode = "Beta"
        btnAutoBuyMode.Text = "Mode Auto Buy: Beta (Teleport UTC)"
    else
        autoBuyMode = "Normal"
        btnAutoBuyMode.Text = "Mode Auto Buy: Normal"
    end
end)

local btnAutoBuySeedWhitelist = Instance.new("TextButton")
btnAutoBuySeedWhitelist.Size = UDim2.new(0.9, 0, 0, 40)
btnAutoBuySeedWhitelist.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
btnAutoBuySeedWhitelist.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAutoBuySeedWhitelist.Text = "Auto Buy Seed Whitelist [OFF]"
btnAutoBuySeedWhitelist.Font = Enum.Font.GothamBold
btnAutoBuySeedWhitelist.Parent = farmScroll
Instance.new("UICorner", btnAutoBuySeedWhitelist).CornerRadius = UDim.new(0, 6)

local btnAutoBuyAllSeed = Instance.new("TextButton")
btnAutoBuyAllSeed.Size = UDim2.new(0.9, 0, 0, 40)
btnAutoBuyAllSeed.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
btnAutoBuyAllSeed.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAutoBuyAllSeed.Text = "Auto Buy ALL Seeds [OFF]"
btnAutoBuyAllSeed.Font = Enum.Font.GothamBold
btnAutoBuyAllSeed.Parent = farmScroll
Instance.new("UICorner", btnAutoBuyAllSeed).CornerRadius = UDim.new(0, 6)

local btnToggleGearView = Instance.new("TextButton")
btnToggleGearView.Size = UDim2.new(0.9, 0, 0, 40)
btnToggleGearView.BackgroundColor3 = Color3.fromRGB(130, 80, 180)
btnToggleGearView.TextColor3 = Color3.fromRGB(255, 255, 255)
btnToggleGearView.Text = "Buka Pilihan Whitelist Gear"
btnToggleGearView.Font = Enum.Font.GothamBold
btnToggleGearView.Parent = farmScroll
Instance.new("UICorner", btnToggleGearView).CornerRadius = UDim.new(0, 6)

local gearListContainer = Instance.new("ScrollingFrame")
gearListContainer.Size = UDim2.new(0.9, 0, 0, 120)
gearListContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
gearListContainer.CanvasSize = UDim2.new(0, 0, 0, 150)
gearListContainer.ScrollBarThickness = 4
gearListContainer.Visible = false
gearListContainer.Parent = farmScroll
Instance.new("UICorner", gearListContainer).CornerRadius = UDim.new(0, 6)

local gearGridLayout = Instance.new("UIGridLayout")
gearGridLayout.CellSize = UDim2.new(0.48, 0, 0, 35)
gearGridLayout.CellPadding = UDim2.new(0.02, 0, 0, 5)
gearGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gearGridLayout.Parent = gearListContainer

for _, gearName in ipairs(allGearsList) do
    local gearBtn = Instance.new("TextButton")
    gearBtn.Text = gearName
    gearBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    gearBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    gearBtn.Font = Enum.Font.Gotham
    gearBtn.TextSize = 12
    gearBtn.Parent = gearListContainer
    Instance.new("UICorner", gearBtn).CornerRadius = UDim.new(0, 4)
    
    gearBtn.MouseButton1Click:Connect(function()
        if activeGearWhitelist[gearName] then
            activeGearWhitelist[gearName] = nil
            gearBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            gearBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        else
            activeGearWhitelist[gearName] = true
            gearBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            gearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
end

btnToggleGearView.MouseButton1Click:Connect(function()
    gearListContainer.Visible = not gearListContainer.Visible
    if gearListContainer.Visible then
        btnToggleGearView.Text = "Tutup Pilihan Whitelist Gear"
    else
        btnToggleGearView.Text = "Buka Pilihan Whitelist Gear"
    end
end)

local btnAutoBuyGearWhitelist = Instance.new("TextButton")
btnAutoBuyGearWhitelist.Size = UDim2.new(0.9, 0, 0, 40)
btnAutoBuyGearWhitelist.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
btnAutoBuyGearWhitelist.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAutoBuyGearWhitelist.Text = "Auto Buy Gear Whitelist [OFF]"
btnAutoBuyGearWhitelist.Font = Enum.Font.GothamBold
btnAutoBuyGearWhitelist.Parent = farmScroll
Instance.new("UICorner", btnAutoBuyGearWhitelist).CornerRadius = UDim.new(0, 6)

local btnAutoBuyAllGear = Instance.new("TextButton")
btnAutoBuyAllGear.Size = UDim2.new(0.9, 0, 0, 40)
btnAutoBuyAllGear.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
btnAutoBuyAllGear.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAutoBuyAllGear.Text = "Auto Buy ALL Gear [OFF]"
btnAutoBuyAllGear.Font = Enum.Font.GothamBold
btnAutoBuyAllGear.Parent = farmScroll
Instance.new("UICorner", btnAutoBuyAllGear).CornerRadius = UDim.new(0, 6)

createSlider(farmScroll, "Interval Auto Sell (Detik)", 1, 600, 60, function(val)
    sellIntervalSeconds = val
end)

local btnAutoSell = Instance.new("TextButton")
btnAutoSell.Size = UDim2.new(0.9, 0, 0, 40)
btnAutoSell.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
btnAutoSell.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAutoSell.Text = "Auto Sell [OFF]"
btnAutoSell.Font = Enum.Font.GothamBold
btnAutoSell.Parent = farmScroll
Instance.new("UICorner", btnAutoSell).CornerRadius = UDim.new(0, 6)

createSlider(farmScroll, "Durasi Harvest (Detik)", 1, 300, 60, function(val)
    harvestDuration = val
end)

createSlider(farmScroll, "Jeda Cooldown Harvest (Detik)", 1, 600, 300, function(val)
    harvestCooldown = val
end)

local harvestStatusLabel = Instance.new("TextLabel")
harvestStatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
harvestStatusLabel.BackgroundTransparency = 1
harvestStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
harvestStatusLabel.Font = Enum.Font.GothamBold
harvestStatusLabel.Text = "Status Harvest: IDLE"
harvestStatusLabel.Parent = farmScroll

local btnAutoFarm = Instance.new("TextButton")
btnAutoFarm.Size = UDim2.new(0.9, 0, 0, 45)
btnAutoFarm.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
btnAutoFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAutoFarm.Text = "Loop Auto Harvest [OFF]"
btnAutoFarm.Font = Enum.Font.GothamBold
btnAutoFarm.Parent = farmScroll
Instance.new("UICorner", btnAutoFarm).CornerRadius = UDim.new(0, 6)

local btnPlantMode = Instance.new("TextButton")
btnPlantMode.Size = UDim2.new(0.9, 0, 0, 40)
btnPlantMode.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
btnPlantMode.TextColor3 = Color3.fromRGB(200, 200, 255)
btnPlantMode.Text = "Mode Plant: Semua Inventory"
btnPlantMode.Font = Enum.Font.GothamBold
btnPlantMode.Parent = farmScroll
Instance.new("UICorner", btnPlantMode).CornerRadius = UDim.new(0, 6)

local btnLocationMode = Instance.new("TextButton")
btnLocationMode.Size = UDim2.new(0.9, 0, 0, 40)
btnLocationMode.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
btnLocationMode.TextColor3 = Color3.fromRGB(200, 255, 200)
btnLocationMode.Text = "Lokasi Plant: Mengikuti Posisi"
btnLocationMode.Font = Enum.Font.GothamBold
btnLocationMode.Parent = farmScroll
Instance.new("UICorner", btnLocationMode).CornerRadius = UDim.new(0, 6)

local btnAutoPlant = Instance.new("TextButton")
btnAutoPlant.Size = UDim2.new(0.9, 0, 0, 45)
btnAutoPlant.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
btnAutoPlant.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAutoPlant.Text = "Auto Plant [OFF]"
btnAutoPlant.Font = Enum.Font.GothamBold
btnAutoPlant.Parent = farmScroll
Instance.new("UICorner", btnAutoPlant).CornerRadius = UDim.new(0, 6)

local btnShovelMode = Instance.new("TextButton")
btnShovelMode.Size = UDim2.new(0.9, 0, 0, 40)
btnShovelMode.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
btnShovelMode.TextColor3 = Color3.fromRGB(255, 200, 200)
btnShovelMode.Text = "Mode Shovel: Semua Tanaman"
btnShovelMode.Font = Enum.Font.GothamBold
btnShovelMode.Parent = farmScroll
Instance.new("UICorner", btnShovelMode).CornerRadius = UDim.new(0, 6)

local btnAutoShovel = Instance.new("TextButton")
btnAutoShovel.Size = UDim2.new(0.9, 0, 0, 45)
btnAutoShovel.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
btnAutoShovel.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAutoShovel.Text = "Auto Shovel / Remove Plant [OFF]"
btnAutoShovel.Font = Enum.Font.GothamBold
btnAutoShovel.Parent = farmScroll
Instance.new("UICorner", btnAutoShovel).CornerRadius = UDim.new(0, 6)

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, 0, 1, 0)
playerScroll.BackgroundTransparency = 1
playerScroll.Visible = false
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 800)
playerScroll.ScrollBarThickness = 6
playerScroll.Parent = contentContainer

local playerLayout = Instance.new("UIListLayout")
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Padding = UDim.new(0, 10)
playerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
playerLayout.Parent = playerScroll

local playerPadding = Instance.new("UIPadding")
playerPadding.PaddingTop = UDim.new(0, 10)
playerPadding.PaddingBottom = UDim.new(0, 10)
playerPadding.Parent = playerScroll

createSlider(playerScroll, "Walk Speed", 16, 200, 16, function(val)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = val
    end
end)

createSlider(playerScroll, "Jump Power", 50, 300, 50, function(val)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.UseJumpPower = true
        player.Character.Humanoid.JumpPower = val
    end
end)

createSlider(playerScroll, "Kecepatan Terbang", 10, 200, 50, function(val)
    flySpeed = val
end)

local btnFly = Instance.new("TextButton")
btnFly.Size = UDim2.new(0.9, 0, 0, 45)
btnFly.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
btnFly.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFly.Text = "Toggle Fly [OFF]"
btnFly.Font = Enum.Font.GothamBold
btnFly.Parent = playerScroll
Instance.new("UICorner", btnFly).CornerRadius = UDim.new(0, 6)

createSlider(playerScroll, "Interval Anti-AFK (Menit)", 1, 15, 5, function(val)
    antiAfkIntervalMinutes = val
end)

local btnAntiAfk = Instance.new("TextButton")
btnAntiAfk.Size = UDim2.new(0.9, 0, 0, 45)
btnAntiAfk.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
btnAntiAfk.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAntiAfk.Text = "Anti-AFK & Auto Jump [OFF]"
btnAntiAfk.Font = Enum.Font.GothamBold
btnAntiAfk.Parent = playerScroll
Instance.new("UICorner", btnAntiAfk).CornerRadius = UDim.new(0, 6)

local tpScroll = Instance.new("ScrollingFrame")
tpScroll.Size = UDim2.new(1, 0, 1, 0)
tpScroll.BackgroundTransparency = 1
tpScroll.Visible = false
tpScroll.ScrollBarThickness = 6
tpScroll.Parent = contentContainer

local tpLayout = Instance.new("UIListLayout")
tpLayout.SortOrder = Enum.SortOrder.LayoutOrder
tpLayout.Padding = UDim.new(0, 10)
tpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tpLayout.Parent = tpScroll

local tpPadding = Instance.new("UIPadding")
tpPadding.PaddingTop = UDim.new(0, 10)
tpPadding.PaddingBottom = UDim.new(0, 10)
tpPadding.Parent = tpScroll

tpLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    tpScroll.CanvasSize = UDim2.new(0, 0, 0, tpLayout.AbsoluteContentSize.Y + 20)
end)

local btnTeleportQuest = Instance.new("TextButton")
btnTeleportQuest.Size = UDim2.new(0.9, 0, 0, 45)
btnTeleportQuest.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
btnTeleportQuest.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTeleportQuest.Text = "Teleport Instan ke Quest"
btnTeleportQuest.Font = Enum.Font.GothamBold
btnTeleportQuest.Parent = tpScroll
Instance.new("UICorner", btnTeleportQuest).CornerRadius = UDim.new(0, 6)

local btnTeleportGear = Instance.new("TextButton")
btnTeleportGear.Size = UDim2.new(0.9, 0, 0, 45)
btnTeleportGear.BackgroundColor3 = Color3.fromRGB(50, 150, 150)
btnTeleportGear.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTeleportGear.Text = "Teleport ke Gear Shop"
btnTeleportGear.Font = Enum.Font.GothamBold
btnTeleportGear.Parent = tpScroll
Instance.new("UICorner", btnTeleportGear).CornerRadius = UDim.new(0, 6)

local btnTeleportSell = Instance.new("TextButton")
btnTeleportSell.Size = UDim2.new(0.9, 0, 0, 45)
btnTeleportSell.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
btnTeleportSell.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTeleportSell.Text = "Teleport ke Area Sell"
btnTeleportSell.Font = Enum.Font.GothamBold
btnTeleportSell.Parent = tpScroll
Instance.new("UICorner", btnTeleportSell).CornerRadius = UDim.new(0, 6)

local btnTeleportShop = Instance.new("TextButton")
btnTeleportShop.Size = UDim2.new(0.9, 0, 0, 45)
btnTeleportShop.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
btnTeleportShop.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTeleportShop.Text = "Teleport ke Area Shop"
btnTeleportShop.Font = Enum.Font.GothamBold
btnTeleportShop.Parent = tpScroll
Instance.new("UICorner", btnTeleportShop).CornerRadius = UDim.new(0, 6)

local manualTpFrame = Instance.new("Frame")
manualTpFrame.Size = UDim2.new(0.9, 0, 0, 80)
manualTpFrame.BackgroundTransparency = 1
manualTpFrame.Parent = tpScroll

local btnGetPos = Instance.new("TextButton")
btnGetPos.Size = UDim2.new(1, 0, 0, 35)
btnGetPos.Position = UDim2.new(0, 0, 0, 0)
btnGetPos.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
btnGetPos.TextColor3 = Color3.fromRGB(255, 255, 255)
btnGetPos.Text = "Copy Posisi ke Clipboard"
btnGetPos.Font = Enum.Font.GothamBold
btnGetPos.Parent = manualTpFrame
Instance.new("UICorner", btnGetPos).CornerRadius = UDim.new(0, 6)

local inputCopiedPos = Instance.new("TextBox")
inputCopiedPos.Size = UDim2.new(1, 0, 0, 35)
inputCopiedPos.Position = UDim2.new(0, 0, 0, 45)
inputCopiedPos.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
inputCopiedPos.TextColor3 = Color3.fromRGB(255, 255, 255)
inputCopiedPos.Text = ""
inputCopiedPos.PlaceholderText = "Koordinat akan muncul di sini"
inputCopiedPos.Font = Enum.Font.Gotham
inputCopiedPos.TextEditable = false
inputCopiedPos.ClearTextOnFocus = false
inputCopiedPos.Parent = manualTpFrame
Instance.new("UICorner", inputCopiedPos).CornerRadius = UDim.new(0, 6)

btnMinimize.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openHubBtn.Visible = true
end)

openHubBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openHubBtn.Visible = false
end)

local function switchTab(tabName)
    infoScroll.Visible = (tabName == "Info")
    farmScroll.Visible = (tabName == "Farm")
    playerScroll.Visible = (tabName == "Player")
    tpScroll.Visible = (tabName == "Teleport")
    
    btnTabInfo.BackgroundColor3 = (tabName == "Info") and Color3.fromRGB(60, 60, 65) or Color3.fromRGB(35, 35, 40)
    btnTabFarm.BackgroundColor3 = (tabName == "Farm") and Color3.fromRGB(60, 60, 65) or Color3.fromRGB(35, 35, 40)
    btnTabPlayer.BackgroundColor3 = (tabName == "Player") and Color3.fromRGB(60, 60, 65) or Color3.fromRGB(35, 35, 40)
    btnTabTeleport.BackgroundColor3 = (tabName == "Teleport") and Color3.fromRGB(60, 60, 65) or Color3.fromRGB(35, 35, 40)
end

btnTabInfo.MouseButton1Click:Connect(function() switchTab("Info") end)
btnTabFarm.MouseButton1Click:Connect(function() switchTab("Farm") end)
btnTabPlayer.MouseButton1Click:Connect(function() switchTab("Player") end)
btnTabTeleport.MouseButton1Click:Connect(function() switchTab("Teleport") end)

btnTeleportQuest.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(109, 204, 636)
    end
end)

btnTeleportGear.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(210, 204, 610)
    end
end)

btnTeleportSell.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(148, 204, 673)
    end
end)

btnTeleportShop.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(175, 204, 673)
    end
end)

btnGetPos.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local pos = player.Character.HumanoidRootPart.Position
        local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
        inputCopiedPos.Text = roundedPos
        if setclipboard then
            setclipboard(roundedPos)
            btnGetPos.Text = "Tercopy ke Clipboard!"
            task.delay(1.5, function()
                btnGetPos.Text = "Copy Posisi ke Clipboard"
            end)
        end
    end
end)

btnAutoBuySeedWhitelist.MouseButton1Click:Connect(function()
    isAutoBuyWhitelistOn = not isAutoBuyWhitelistOn
    if isAutoBuyWhitelistOn then
        btnAutoBuySeedWhitelist.Text = "Auto Buy Seed Whitelist [ON]"
        btnAutoBuySeedWhitelist.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        btnAutoBuySeedWhitelist.Text = "Auto Buy Seed Whitelist [OFF]"
        btnAutoBuySeedWhitelist.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
end)

btnAutoBuyAllSeed.MouseButton1Click:Connect(function()
    isAutoBuyAllOn = not isAutoBuyAllOn
    if isAutoBuyAllOn then
        btnAutoBuyAllSeed.Text = "Auto Buy ALL Seeds [ON]"
        btnAutoBuyAllSeed.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        btnAutoBuyAllSeed.Text = "Auto Buy ALL Seeds [OFF]"
        btnAutoBuyAllSeed.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
end)

btnAutoBuyGearWhitelist.MouseButton1Click:Connect(function()
    isAutoBuyGearWhitelistOn = not isAutoBuyGearWhitelistOn
    if isAutoBuyGearWhitelistOn then
        btnAutoBuyGearWhitelist.Text = "Auto Buy Gear Whitelist [ON]"
        btnAutoBuyGearWhitelist.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        btnAutoBuyGearWhitelist.Text = "Auto Buy Gear Whitelist [OFF]"
        btnAutoBuyGearWhitelist.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
end)

btnAutoBuyAllGear.MouseButton1Click:Connect(function()
    isAutoBuyAllGearOn = not isAutoBuyAllGearOn
    if isAutoBuyAllGearOn then
        btnAutoBuyAllGear.Text = "Auto Buy ALL Gear [ON]"
        btnAutoBuyAllGear.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        btnAutoBuyAllGear.Text = "Auto Buy ALL Gear [OFF]"
        btnAutoBuyAllGear.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
end)

btnAutoSell.MouseButton1Click:Connect(function()
    isAutoSellOn = not isAutoSellOn
    if isAutoSellOn then
        btnAutoSell.Text = "Auto Sell [ON]"
        btnAutoSell.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        sellTimer = 0
    else
        btnAutoSell.Text = "Auto Sell [OFF]"
        btnAutoSell.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
end)

btnAutoFarm.MouseButton1Click:Connect(function()
    isAutoFarmOn = not isAutoFarmOn
    if isAutoFarmOn then
        btnAutoFarm.Text = "Loop Auto Harvest [ON]"
        btnAutoFarm.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        harvestTimer = 0
        harvestState = "Harvesting"
    else
        btnAutoFarm.Text = "Loop Auto Harvest [OFF]"
        btnAutoFarm.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        harvestStatusLabel.Text = "Status Harvest: IDLE"
        harvestStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    end
end)

btnPlantMode.MouseButton1Click:Connect(function()
    if plantSourceMode == "All" then
        plantSourceMode = "Whitelist"
        btnPlantMode.Text = "Mode Plant: Sesuai Whitelist"
    elseif plantSourceMode == "Whitelist" then
        plantSourceMode = "Equipped"
        btnPlantMode.Text = "Mode Plant: Sedang Dipegang Saja"
    else
        plantSourceMode = "All"
        btnPlantMode.Text = "Mode Plant: Semua Inventory"
    end
end)

btnLocationMode.MouseButton1Click:Connect(function()
    if plantLocationMode == "Player" then
        plantLocationMode = "Random"
        btnLocationMode.Text = "Lokasi Plant: Acak Sekitar Pemain"
    elseif plantLocationMode == "Random" then
        plantLocationMode = "Stacked"
        btnLocationMode.Text = "Lokasi Plant: Ditumpuk (Posisi Saat Ini)"
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            stackedPosition = player.Character.HumanoidRootPart.Position
        end
    else
        plantLocationMode = "Player"
        btnLocationMode.Text = "Lokasi Plant: Mengikuti Posisi"
    end
end)

btnAutoPlant.MouseButton1Click:Connect(function()
    isAutoPlantOn = not isAutoPlantOn
    if isAutoPlantOn then
        btnAutoPlant.Text = "Auto Plant [ON]"
        btnAutoPlant.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        btnAutoPlant.Text = "Auto Plant [OFF]"
        btnAutoPlant.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
end)

btnShovelMode.MouseButton1Click:Connect(function()
    if shovelMode == "All" then
        shovelMode = "Whitelist"
        btnShovelMode.Text = "Mode Shovel: Sesuai Whitelist"
    else
        shovelMode = "All"
        btnShovelMode.Text = "Mode Shovel: Semua Tanaman"
    end
end)

btnAutoShovel.MouseButton1Click:Connect(function()
    isAutoShovelOn = not isAutoShovelOn
    if isAutoShovelOn then
        btnAutoShovel.Text = "Auto Shovel / Remove Plant [ON]"
        btnAutoShovel.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        btnAutoShovel.Text = "Auto Shovel / Remove Plant [OFF]"
        btnAutoShovel.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
end)

btnAntiAfk.MouseButton1Click:Connect(function()
    isAntiAfkOn = not isAntiAfkOn
    if isAntiAfkOn then
        btnAntiAfk.Text = "Anti-AFK & Auto Jump [ON]"
        btnAntiAfk.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        afkTimer = 0
    else
        btnAntiAfk.Text = "Anti-AFK & Auto Jump [OFF]"
        btnAntiAfk.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
end)

local function startFly()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart
    
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodyGyro.P = 10000
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp
    
    flyUpBtn.Visible = true
    flyDownBtn.Visible = true
    
    player.Character.Humanoid.PlatformStand = true
end

local function stopFly()
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    flyUpBtn.Visible = false
    flyDownBtn.Visible = false
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.PlatformStand = false
    end
end

btnFly.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    if isFlying then
        btnFly.Text = "Toggle Fly [ON]"
        btnFly.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        startFly()
    else
        btnFly.Text = "Toggle Fly [OFF]"
        btnFly.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        stopFly()
    end
end)

RunService.RenderStepped:Connect(function()
    if isFlying and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or flyUpMobile then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or flyDownMobile then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end
        
        if bodyVelocity and bodyGyro then
            bodyVelocity.Velocity = moveDir * flySpeed
            bodyGyro.CFrame = cam.CFrame
        end
    end
end)

player.Idled:Connect(function()
    if isAntiAfkOn then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

task.spawn(function()
    while task.wait(1) do
        if isAntiAfkOn then
            afkTimer = afkTimer + 1
            if afkTimer >= (antiAfkIntervalMinutes * 60) then
                afkTimer = 0
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.Jump = true
                end
            end
        else
            afkTimer = 0
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if isAutoSellOn then
            sellTimer = sellTimer + 0.1
            if sellTimer >= sellIntervalSeconds then
                sellTimer = 0
                task.spawn(function()
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local origCFrame = char.HumanoidRootPart.CFrame
                        char.HumanoidRootPart.CFrame = CFrame.new(148, 204, 673)
                        task.wait(0.2)
                        pcall(function()
                            sellRemote:InvokeServer("SellAll")
                        end)
                        task.wait(0.2)
                        if char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = origCFrame
                        end
                    end
                end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if isAutoFarmOn then
            harvestTimer = harvestTimer + 1
            if harvestState == "Harvesting" then
                harvestStatusLabel.Text = "Status Harvest: MEMANEN (" .. (harvestDuration - harvestTimer) .. "s)"
                harvestStatusLabel.TextColor3 = Color3.fromRGB(50, 200, 50)
                if harvestTimer >= harvestDuration then
                    harvestState = "Cooldown"
                    harvestTimer = 0
                end
            elseif harvestState == "Cooldown" then
                harvestStatusLabel.Text = "Status Harvest: ISTIRAHAT (" .. (harvestCooldown - harvestTimer) .. "s)"
                harvestStatusLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
                if harvestTimer >= harvestCooldown then
                    harvestState = "Harvesting"
                    harvestTimer = 0
                end
            end
        end
    end
end)

local function getPlantData()
    local plants = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        local uuid = nil
        local pName = ""
        if obj:IsA("Model") and obj:GetAttribute("Uuid") then
            uuid = obj:GetAttribute("Uuid")
            pName = obj.Name
        elseif obj:IsA("StringValue") and obj.Name == "Uuid" then
            uuid = obj.Value
            if obj.Parent then pName = obj.Parent.Name end
        end
        if uuid then
            table.insert(plants, {uuid = uuid, name = pName})
        end
    end
    return plants
end

task.spawn(function()
    while task.wait(0.2) do
        if isAutoFarmOn and harvestState == "Harvesting" then
            local foundPlants = getPlantData()
            for _, plant in pairs(foundPlants) do
                if not isAutoFarmOn or harvestState ~= "Harvesting" then
                    break
                end
                
                task.spawn(function()
                    pcall(function() harvestRemote:FireServer({[1] = {["Uuid"] = plant.uuid}}) end)
                    for i = 1, 6 do
                        pcall(function() harvestRemote:FireServer({[1] = {["GrowthAnchorIndex"] = i, ["Uuid"] = plant.uuid}}) end)
                    end
                end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if isAutoShovelOn then
            local foundPlants = getPlantData()
            for _, plant in pairs(foundPlants) do
                local shouldRemove = false
                if shovelMode == "All" then
                    shouldRemove = true
                elseif shovelMode == "Whitelist" then
                    for wlSeed, isSel in pairs(activeSeedWhitelist) do
                        if isSel then
                            local baseName = string.gsub(wlSeed, " Seed", "")
                            if string.find(string.lower(plant.name), string.lower(baseName)) then
                                shouldRemove = true
                                break
                            end
                        end
                    end
                end
                
                if shouldRemove then
                    task.spawn(function()
                        if removeRemote then
                            pcall(function() removeRemote:FireServer(plant.uuid) end)
                            pcall(function() removeRemote:FireServer(plant.uuid, 1) end)
                            pcall(function() removeRemote:FireServer(plant.uuid, 2) end)
                            pcall(function() removeRemote:FireServer(plant.uuid, 3) end)
                            pcall(function() removeRemote:FireServer(plant.uuid, 4) end)
                        end
                    end)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if autoBuyMode == "Normal" then
            if isAutoBuyWhitelistOn then
                for seedName, isSelected in pairs(activeSeedWhitelist) do
                    if isSelected then
                        task.spawn(function()
                            pcall(function() purchaseRemote:InvokeServer("SeedShop", seedName) end)
                        end)
                    end
                end
            end
            if isAutoBuyAllOn then
                for _, seedName in pairs(allSeedsList) do
                    task.spawn(function()
                        pcall(function() purchaseRemote:InvokeServer("SeedShop", seedName) end)
                    end)
                end
            end
        end
    end
end)

local lastRestockMinute = -1
task.spawn(function()
    while task.wait(0.5) do
        if autoBuyMode == "Beta" and (isAutoBuyWhitelistOn or isAutoBuyAllOn) then
            local utc = os.date("!*t")
            if utc.min % 5 == 0 and utc.sec < 5 and utc.min ~= lastRestockMinute then
                lastRestockMinute = utc.min
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local origCFrame = char.HumanoidRootPart.CFrame
                    char.HumanoidRootPart.CFrame = CFrame.new(175, 204, 673)
                    task.wait(0.3)
                    
                    local spamEnd = tick() + 8
                    while tick() < spamEnd do
                        if isAutoBuyWhitelistOn then
                            for seedName, isSelected in pairs(activeSeedWhitelist) do
                                if isSelected then
                                    task.spawn(function() pcall(function() purchaseRemote:InvokeServer("SeedShop", seedName) end) end)
                                end
                            end
                        end
                        if isAutoBuyAllOn then
                            for _, seedName in pairs(allSeedsList) do
                                task.spawn(function() pcall(function() purchaseRemote:InvokeServer("SeedShop", seedName) end) end)
                            end
                        end
                        task.wait(0.1)
                    end
                    
                    if char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = origCFrame
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if isAutoBuyGearWhitelistOn then
            for gearName, isSelected in pairs(activeGearWhitelist) do
                if isSelected then
                    task.spawn(function()
                        pcall(function() purchaseRemote:InvokeServer("GearShop", gearName) end)
                    end)
                end
            end
        end
        if isAutoBuyAllGearOn then
            for _, gearName in pairs(allGearsList) do
                task.spawn(function()
                    pcall(function() purchaseRemote:InvokeServer("GearShop", gearName) end)
                end)
            end
        end
    end
end)

local function getTargetPos()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return Vector3.new(0,0,0) end
    local rootPos = player.Character.HumanoidRootPart.Position
    
    if plantLocationMode == "Player" then
        return rootPos
    elseif plantLocationMode == "Random" then
        return Vector3.new(rootPos.X + math.random(-15, 15), rootPos.Y, rootPos.Z + math.random(-15, 15))
    elseif plantLocationMode == "Stacked" then
        if stackedPosition then
            return stackedPosition
        else
            return rootPos
        end
    end
    return rootPos
end

local function extractBaseSeedName(itemName)
    if string.find(string.lower(itemName), "kg") then
        return nil, nil
    end
    
    for _, fullName in ipairs(allSeedsList) do
        local baseName = string.gsub(fullName, " Seed", "")
        if string.find(itemName, baseName) then
            return baseName, fullName
        end
    end
    return nil, nil
end

task.spawn(function()
    while task.wait(0.2) do
        if isAutoPlantOn then
            local char = player.Character
            if not char then continue end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then continue end
            
            local targetPos = getTargetPos()
            local currentTool = char:FindFirstChildOfClass("Tool")
            
            if currentTool then
                local extractedName, fullName = extractBaseSeedName(currentTool.Name)
                if extractedName then
                    local shouldPlant = false
                    if plantSourceMode == "Equipped" or plantSourceMode == "All" then
                        shouldPlant = true
                    elseif plantSourceMode == "Whitelist" and activeSeedWhitelist[fullName] then
                        shouldPlant = true
                    end
                    
                    if shouldPlant then
                        pcall(function()
                            plantRemote:InvokeServer(extractedName, targetPos)
                        end)
                    elseif plantSourceMode ~= "Equipped" then
                        humanoid:UnequipTools()
                    end
                elseif plantSourceMode ~= "Equipped" then
                    humanoid:UnequipTools()
                end
            else
                if plantSourceMode == "All" or plantSourceMode == "Whitelist" then
                    local bp = player.Backpack
                    if bp then
                        for _, item in pairs(bp:GetChildren()) do
                            if item:IsA("Tool") then
                                local extractedName, fullName = extractBaseSeedName(item.Name)
                                if extractedName then
                                    local shouldEquip = false
                                    if plantSourceMode == "All" then
                                        shouldEquip = true
                                    elseif plantSourceMode == "Whitelist" and activeSeedWhitelist[fullName] then
                                        shouldEquip = true
                                    end
                                    
                                    if shouldEquip then
                                        humanoid:EquipTool(item)
                                        task.wait(0.15)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
