lib.callback.register('trucker:getPlayerLevel', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil
    end
    local identifier = xPlayer.identifier
    local result = MySQL.query.await('SELECT level FROM player_stats WHERE identifier = ?', {identifier})
    if result and result[1] then
        return result[1].level
    else
        return nil
    end
end)


lib.callback.register('trucker:getPlayerStats', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local identifier = xPlayer.identifier
        local result = MySQL.query.await('SELECT * FROM player_stats WHERE identifier = ?', {identifier})
        
        if result and result[1] then
            local currentLevel = result[1].level
            local currentExperience = result[1].experience
            local nextLevel = currentLevel + 1
            local nextLevelExpQuery = MySQL.query.await('SELECT requiredExp FROM trucker_levels WHERE level = ?', {nextLevel})
            
            local nextLevelExp = nextLevelExpQuery[1] and nextLevelExpQuery[1].requiredExp or 'Max Level'
            
            return {
                level = currentLevel,
                experience = currentExperience,
                nextLevelExp = nextLevelExp,
                totalEarnings = result[1].totalEarnings,
                kilometers = result[1].kilometers,
                completedMissions = result[1].completedMissions
            }
        else
            return nil
        end
    end
end)



lib.callback.register('trucker:getPlayerMissions', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil
    end

    local identifier = xPlayer.identifier
    local result = MySQL.query.await('SELECT level FROM player_stats WHERE identifier = ?', {identifier})

    if not result[1] then
        MySQL.query.await('INSERT INTO player_stats (identifier, level, experience, totalEarnings, kilometers, completedMissions) VALUES (?, ?, ?, ?, ?, ?)', 
        {identifier, 1, 0, 0, 0, 0}) 
        result = MySQL.query.await('SELECT level FROM player_stats WHERE identifier = ?', {identifier})
    end

    local playerLevel = result[1].level
    local maxLevel = Config.Levels[#Config.Levels].level 

    if playerLevel > maxLevel then
        print("The player is above maximum level..")
        return nil
    end

    local availableMissions = {}
    for level, levelData in pairs(Config.MissionsLevels) do
        if level <= playerLevel then
            for _, mission in ipairs(levelData.missions) do
                table.insert(availableMissions, mission)
            end
        end
    end

    if #availableMissions > 0 then
        return { level = playerLevel, missions = availableMissions }
    else
        return nil 
    end
end)




RegisterServerEvent('trucker:completeMission')
AddEventHandler('trucker:completeMission', function(exp, earnings, kilometers)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local identifier = xPlayer.identifier
        exp = exp or 150 
        MySQL.query('SELECT level, experience FROM player_stats WHERE identifier = ?', {identifier}, function(result)
            if result[1] then
                local currentLevel = result[1].level
                local currentExperience = result[1].experience
                local newExperience = currentExperience + exp
                local nextLevel = currentLevel + 1
                local requiredExp = Config.Levels[nextLevel] and Config.Levels[nextLevel].requiredExp
                if requiredExp and newExperience >= requiredExp then
                    currentLevel = currentLevel + 1
                    newExperience = newExperience - requiredExp
                    local nextRequiredExp = Config.Levels[currentLevel + 1] and Config.Levels[currentLevel + 1].requiredExp
                    if not nextRequiredExp then
                        newExperience = 'Max Level'
                    end
                end
                MySQL.update('UPDATE player_stats SET level = ?, experience = ?, totalEarnings = totalEarnings + ?, kilometers = kilometers + ?, completedMissions = completedMissions + 1 WHERE identifier = ?', 
                {currentLevel, newExperience, earnings, kilometers, identifier}, function(affectedRows)
                    if affectedRows > 0 then
                        xPlayer.addMoney(earnings)
                    else
                        print("Error while updating player statistics. For player: " .. identifier)
                    end
                end)
            else
                MySQL.insert('INSERT INTO player_stats (identifier, level, experience, totalEarnings, kilometers, completedMissions) VALUES (?, ?, ?, ?, ?, ?)', 
                {identifier, 1, exp, earnings, kilometers, 1}, function(affectedRows)
                    if affectedRows > 0 then
                        xPlayer.addMoney(earnings)
                    else
                        print("Error while creating new table for: " .. identifier)
                    end
                end)
            end
        end)
    end
end)

RegisterServerEvent('truckerjob:updatePlayerData')
AddEventHandler('truckerjob:updatePlayerData', function(data)
    local identifier = data.identifier
    local level = data.level
    local experience = data.experience
    local totalEarnings = data.totalEarnings
    local kilometers = data.kilometers
    local completedMissions = data.completedMissions

    MySQL.Async.execute('UPDATE player_stats SET level = ?, experience = ?, totalEarnings = ?, kilometers = ?, completedMissions = ? WHERE identifier = ?', {
        level, experience, totalEarnings, kilometers, completedMissions, identifier
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print("Player data updated successfully for: " .. identifier)
        else
            print("Failed to update player data for: " .. identifier)
        end
    end)
end)



lib.callback.register('trucker:getAllPlayerData', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer and xPlayer.getGroup() == 'admin' then
        local playersData = MySQL.query.await('SELECT * FROM player_stats')
        
        if playersData then
            return playersData
        else
            return {}
        end
    else
        return { error = 'Unauthorized access' }
    end
end)


function UpdateLevelData()
    for _, levelData in ipairs(Config.Levels) do
        local result = MySQL.query.await('SELECT * FROM trucker_levels WHERE level = ?', {levelData.level})
        if result[1] then
            MySQL.update('UPDATE trucker_levels SET requiredExp = ? WHERE level = ?', {levelData.requiredExp, levelData.level})
            print("Level updated: " .. levelData.level .. " with required xp: " .. levelData.requiredExp)
        else
            MySQL.update('INSERT INTO trucker_levels (level, requiredExp) VALUES (?, ?)', {levelData.level, levelData.requiredExp})
            print("Add new level: " .. levelData.level .. " with required xp: " .. levelData.requiredExp)
        end
    end
end


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        UpdateLevelData()
    end
end)
