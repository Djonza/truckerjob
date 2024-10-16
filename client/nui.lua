local isMenuOpen = false
local totalMissions = 0
local levelIndex = nil
local missionIndex = nil

RegisterNUICallback('selectMission', function(data, cb)
    local selectedMissionIndex = data.missionIndex + 1
    lib.callback('trucker:getPlayerLevel', nil, function(playerLevel)
        if not playerLevel then
            print("Error: No available level for this player!.")
            cb('error')
            return
        end
        local totalMissions = 0
        local levelIndex, missionIndex
        for level, levelData in ipairs(Config.MissionsLevels) do
            local numMissions = #levelData.missions
            if selectedMissionIndex <= totalMissions + numMissions then
                levelIndex = level
                missionIndex = selectedMissionIndex - totalMissions
                break
            end
            totalMissions = totalMissions + numMissions
        end
        if not levelIndex or not missionIndex then
            print("Error: No missions for this index.")
            cb('error')
            return
        end
        local missions = Config.MissionsLevels[levelIndex].missions
        local selectedMission = missions[missionIndex]
        StartMission(missionIndex, selectedMission, levelIndex)
        cb('ok')

        isMenuOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({ type = 'close' })
    end)
end)



RegisterNUICallback('getMissions', function(_, cb)
    lib.callback('trucker:getPlayerMissions', nil, function(missions)
        if missions then
            SendNUIMessage({
                type = 'showMissions',
                missions = missions
            })
            SetNuiFocus(true, true)
        else
            print("Error: No available missions!")
        end
    end)
    cb('ok')
end)

function openDashboard()
    lib.callback('trucker:getPlayerStats', source, function(playerData)
        if playerData then
            SendNUIMessage({
                type = 'showDashboard',
                playerData = playerData
            })
        else
            print("Error: No available stats for this player.")
        end
    end)
end


RegisterNUICallback('getPlayerDashboard', function(_, cb)
    openDashboard()
    cb('ok')
end)

RegisterNUICallback('getAdminData', function(_, cb)
    lib.callback('trucker:getAllPlayerData', source, function(playersData)
        if playersData and #playersData > 0 then
            cb({ playersData = playersData })
        else
            cb({ playersData = {} })
        end
    end)
end)



RegisterNUICallback('updatePlayer', function(data, cb)
    TriggerServerEvent('truckerjob:updatePlayerData', data)
    cb('ok')  
end)

RegisterNUICallback('closeMenu', function(_, cb)
    SendNUIMessage({
        type = 'close',
    })
    SetNuiFocus(false, false)
    cb('ok')
    isMenuOpen = false
end)