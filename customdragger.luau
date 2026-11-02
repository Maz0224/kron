--@name Semi Hard Drag
--@author Maz
--@version 1.4
--@description Adjustable player model density
--@url https://raw.githubusercontent.com/Maz0224/kron/refs/heads/main/customdragger.luau

local Tab, Hub = ...

Tab:NewSection("Physics")

local originalProperties = {}
local currentIntensity = nil

local function getDensity(value)
    return 0.5 - ((value - 1) * (0.49 / 24))
end

local function applyModel(v)
    local main = v:FindFirstChild("Main")
    if not main then return end

    if not originalProperties[main] then
        originalProperties[main] = {
            custom = main.CustomPhysicalProperties
        }
    end

    local p = main.CurrentPhysicalProperties
    local density = getDensity(currentIntensity)

    main.CustomPhysicalProperties = PhysicalProperties.new(
        density,
        p.Friction,
        p.Elasticity,
        p.FrictionWeight,
        p.ElasticityWeight
    )
end

local function applyAll()
    for _, v in ipairs(workspace.PlayerModels:GetChildren()) do
        applyModel(v)
    end
end

local function resetDensity()
    for main, data in pairs(originalProperties) do
        if main.Parent then
            main.CustomPhysicalProperties = data.custom
        end
    end

    table.clear(originalProperties)
    currentIntensity = nil
end

Tab:NewSlider("Intensity", 1, 1, 25, false, function(value)
    currentIntensity = value
    applyAll()
end)

Tab:NewButton("Reapply Density", function()
    if currentIntensity then
        applyAll()
        Hub:Notify("Semi Hard Drag", "Reapplyed mass!", 3)
    end
end)

Tab:NewButton("Reset Density", function()
    resetDensity()
    Hub:Notify("Semi Hard Drag", "Density restored!", 3)
end)

Tab:Connect(workspace.PlayerModels.ChildAdded, function(model)
    task.wait(0.2)

    if currentIntensity then
        applyModel(model)
    end
end)

Tab:OnUnload(function()
    resetDensity()
end)
