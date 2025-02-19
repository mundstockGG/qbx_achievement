-- Local table to track achievement status (loaded from server)
local eventStatus = {
    travel = false,
    killSpecificPed = false,
    drinkItem = false
}

-------------------------------------------------
-- Event: Load Achievements
-- Receives achievement data from the server and updates local flags.
-------------------------------------------------
RegisterNetEvent('qbx_achievements:loadAchievements', function(data)
    eventStatus = data
    if eventStatus.travel then
        print("Achievement 'First Travel' already earned.")
    end
    if eventStatus.killSpecificPed then
        print("Achievement 'Kill Specific Ped' already earned.")
    end
    if eventStatus.drinkItem then
        print("Achievement 'Drink Item' already earned.")
    end
end)

-- Trigger server event to fetch achievements when the player spawns
AddEventHandler('playerSpawned', function()
    TriggerServerEvent('qbx_achievements:fetchAchievements')
end)

-------------------------------------------------
-- 1. FIRST TRAVEL (Driving) DETECTION
-- This thread checks every second to see if the player
-- is driving for the first time.
-------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second
        if not eventStatus.travel then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    eventStatus.travel = true
                    print("First travel detected!")
                    exports["ictrophies"]:NewTrophy("travel")
                    TriggerServerEvent('qbx_achievements:updateAchievement', "travel", true)
                end
            end
        end
    end
end)

-------------------------------------------------
-- 2. FIRST KILL OF A SPECIFIC PED DETECTION
-- Spawns a specific ped and monitors its status.
-------------------------------------------------
local specificPed = nil
Citizen.CreateThread(function()
    local model = GetHashKey("s_m_y_cop_01")  -- Example ped model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end
    -- Spawn the ped at specified coordinates (adjust as needed)
    specificPed = CreatePed(4, model, 200.0, 200.0, 30.0, 0.0, true, false)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- Check every half second
        if specificPed and DoesEntityExist(specificPed) and not eventStatus.killSpecificPed then
            if IsEntityDead(specificPed) then
                eventStatus.killSpecificPed = true
                print("First specific ped kill detected!")
                exports["ictrophies"]:NewTrophy("killSpecificPed")
                TriggerServerEvent('qbx_achievements:updateAchievement', "killSpecificPed", true)
            end
        end
    end
end)

-------------------------------------------------
-- 3. FIRST DRINK OF A SPECIFIC ITEM DETECTION
-- Listens for a custom event when the player drinks an item.
-------------------------------------------------
RegisterNetEvent('playerDrankItem', function(itemName)
    if itemName == "special_drink" and not eventStatus.drinkItem then
        eventStatus.drinkItem = true
        print("First drink of special item detected!")
        exports["ictrophies"]:NewTrophy("drinkItem")
        TriggerServerEvent('qbx_achievements:updateAchievement', "drinkItem", true)
    end
end)
