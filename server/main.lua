local QBCore = exports['qb-core']:GetCoreObject() -- Adjust if using a different framework

-------------------------------------------------
-- Event: Fetch Achievements
-- Retrieves a player's achievement data from the database.
-- If no record exists, one is created with default values.
-------------------------------------------------
RegisterNetEvent('qbx_achievements:fetchAchievements', function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local identifier = xPlayer.PlayerData.citizenid -- Use your unique identifier

    MySQL.Async.fetchAll('SELECT * FROM players_achievements WHERE id = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if result[1] then
            local achievements = {
                travel = (result[1].isFirstDrive == 1),
                killSpecificPed = (result[1].isKillSpecificPed == 1),
                drinkItem = (result[1].isDrinkItem == 1)
            }
            TriggerClientEvent('qbx_achievements:loadAchievements', src, achievements)
        else
            -- Create a new record with default values if none exists
            MySQL.Async.execute(
                'INSERT INTO players_achievements (id, isFirstDrive, isKillSpecificPed, isDrinkItem) VALUES (@identifier, 0, 0, 0)',
                {
                    ['@identifier'] = identifier
                }, function(rowsChanged)
                    TriggerClientEvent('qbx_achievements:loadAchievements', src, {
                        travel = false,
                        killSpecificPed = false,
                        drinkItem = false
                    })
                end)
        end
    end)
end)

-------------------------------------------------
-- Event: Update Achievement
-- Updates a specific achievement in the database.
-- Supported achievement keys: "travel", "killSpecificPed", "drinkItem"
-------------------------------------------------
RegisterNetEvent('qbx_achievements:updateAchievement', function(achievementKey, status)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local identifier = xPlayer.PlayerData.citizenid

    local column = ""
    if achievementKey == "travel" then
        column = "isFirstDrive"
    elseif achievementKey == "killSpecificPed" then
        column = "isKillSpecificPed"
    elseif achievementKey == "drinkItem" then
        column = "isDrinkItem"
    else
        return -- Unrecognized achievement key.
    end

    MySQL.Async.execute('UPDATE players_achievements SET ' .. column .. ' = @status WHERE id = @identifier', {
        ['@status'] = status and 1 or 0,
        ['@identifier'] = identifier
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print("Achievement [" .. achievementKey .. "] updated for " .. identifier)
        else
            print("Failed to update achievement [" .. achievementKey .. "] for " .. identifier)
        end
    end)
end)
