local jobStarted = false
local spawnedTruck = nil 
local delivered = false
local currentDifficulty = nil
local firmBlip = nil
local missionPed = nil

lib.locale()


function TruckerJobBlip()
    local firmBlip = AddBlipForCoord(Config.TruckerLocations[1].coords) 

    SetBlipSprite(firmBlip, 478) 
    SetBlipColour(firmBlip, 3) 
    SetBlipScale(firmBlip, 1.0) 
    SetBlipAsShortRange(firmBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Vratite se u firmu")
    EndTextCommandSetBlipName(firmBlip)
end

local function setupTruckerJob()
    for _, location in ipairs(Config.TruckerLocations) do
        exports.ox_target:addSphereZone({
            coords = location.coords,
            radius = location.radius,
            options = {
                {
                    name = 'trucker_job_start',
                    label = locale('start_job'),
                    icon = 'fas fa-hammer',
                    canInteract = function()
                        if not jobStarted then
                            return true
                        else
                            return false
                        end
                    end,
                    onSelect = function()
                        lib.callback('trucker:getPlayerMissions', nil, function(data)
                            if data then
                                local playerLevel = data.level
                                local availableMissions = data.missions
                                SendNUIMessage({
                                    type = 'open',
                                    missions = availableMissions
                                })
                                SetNuiFocus(true, true)
                            else
                                print("Error: No available stats for this player!")
                            end
                        end)
                    end
                },
                {
                    name = 'finish_job',
                    label = locale('end_job'),
                    icon = 'fas fa-check-circle',
                    canInteract = function()
                        if spawnedTruck and delivered then
                            local playerCoords = GetEntityCoords(PlayerPedId())
                            local truckCoords = GetEntityCoords(spawnedTruck)
                            local distance = #(playerCoords - truckCoords)
                            return jobStarted and distance <= 20.0
                        else
                            return false
                        end
                    end,
                    onSelect = function()
                        firmBlip = AddBlipForCoord(Config.TruckerLocations[1].coords)
                        FinishJob(firmBlip, currentDifficulty, selectedMission, mission)
                    end
                }
            }
        })
    end
end

function CreateMissionDestination(coords)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 477) 
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 5)

    exports.ox_target:addSphereZone({
        coords = coords,
        radius = 2.0,
        options = {
            {
                name = 'deliver_goods',
                label = locale('deliver'),
                icon = 'fa-solid fa-box',
                canInteract = function()
                    if spawnedTruck and not delivered then
                        local playerCoords = GetEntityCoords(PlayerPedId())
                        local truckCoords = GetEntityCoords(spawnedTruck)
                        local distance = #(playerCoords - truckCoords)
                        return jobStarted and distance <= 20.0 
                    else
                        return false
                    end
                end,
                onSelect = function()
                    RemoveBlip(blip)
                    if lib.progressCircle({
                        duration = 2000,
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                        },
                    }) then
                        lib.notify({
                            title = locale('title'),
                            description = locale("delivered"),
                            type = 'success'
                        })
                        delivered = true    
                        if missionPed ~= nil then
                            DeleteEntity(missionPed)
                            missionPed = nil
                            print("Ped deleted after delivered.")
                        end
                        local firmCoords = Config.TruckerLocations[1].coords
                        SetNewWaypoint(firmCoords.x, firmCoords.y)
                        lib.notify({
                            title = locale('title'),
                            description = locale("return_back"),
                            type = 'info'
                        })                    
                    end
                end
            }
        }
    })
end


function StartMission(level, mission)
    if not level or not mission then
        print("Error: level or mission didn't went throught for function StartMission.")
        return
    end
    local truckModel = mission.truckModel
    if not truckModel then
        print("Error: Vehicle model is not defined for this mission.")
        return
    end
    local spawnCoords = Config.TruckSpawnPoints[mission.difficulty]
    local heading = 90.0
    if ESX.Game.IsSpawnPointClear(spawnCoords, 5.0) then
        ESX.Game.SpawnVehicle(truckModel, spawnCoords, heading, function(vehicle)
            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
            spawnedTruck = vehicle
            jobStarted = true
            currentDifficulty = mission.difficulty
            selectedMission = mission 
            lib.notify({
                title = locale('title'),
                description = locale('vehicle_ready'),
                type = 'success'
            })
            local missionCoords = GetRandomDestination(mission.difficulty)
            if missionCoords then
                CreateMissionDestination(missionCoords)
                SpawnMissionPed(missionCoords, mission)
            else
                lib.notify({
                    title = locale('title'),
                    description = locale('no_destination'),
                    type = 'error'
                })
            end
        end)
    else
        lib.notify({
            title = locale('title'),
            description = locale('no_space'),
            type = 'error'
        })
        return
    end
end
    
function FinishJob(firmBlip, currentDifficulty, mission)
    if not mission then
        print("Error: Missions didn't go throught for function FinishJob.")
        return
    end
    if spawnedTruck then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local truckCoords = GetEntityCoords(spawnedTruck) 
        local distance = #(playerCoords - truckCoords)

        local expReward = math.random(mission.reward.exp.min, mission.reward.exp.max)
        local cashReward = math.random(mission.reward.cash.min, mission.reward.cash.max)
        local kilometersTraveled = math.random(10, 100) 
        if distance <= 20.0 then
            DeleteEntity(spawnedTruck) 
            lib.notify({
                title = locale('title'),
                description = locale('mission_completed'),
                type = 'success'
            })
            RemoveBlip(firmBlip)

            lib.notify({
                title = locale('title'),
                description = ('Earned: $%d\nExperience: %d XP\nKilometers traveled: %d km'):format(cashReward, expReward, kilometersTraveled),
                type = 'info'
            })
            TriggerServerEvent('trucker:completeMission', expReward, cashReward, kilometersTraveled)
        else
            lib.notify({
                title = locale('title'),
                description = locale('vehicle_not_near'),
                type = 'error'
            })
        end
    else
        lib.notify({
            title = locale('title'),
            description = locale('no_vehicle_to_be_deleted'),
            type = 'error'
        })
    end

    delivered = false
    jobStarted = false
    spawnedTruck = nil
    currentDifficulty = nil
end




function SpawnMissionPed(coords, mission)
    local pedModel = GetHashKey(mission.pedModel)
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(500)
    end
    missionPed = CreatePed(4, pedModel, coords.x, coords.y, coords.z, 0.0, false, true)
    SetEntityInvincible(missionPed, true)
    SetBlockingOfNonTemporaryEvents(missionPed, true)
    SetPedDiesWhenInjured(missionPed, false)
    SetEntityAsMissionEntity(missionPed, true, true)
    FreezeEntityPosition(missionPed, true)
    SetPedCanRagdoll(missionPed, false)
    SetPedCanBeTargetted(missionPed, false)
    SetModelAsNoLongerNeeded(pedModel)
end





function GetRandomDestination(difficulty)
    local possibleDestinations = Config.DeliveryDestinations[difficulty]
    if possibleDestinations then
        local randomIndex = math.random(1, #possibleDestinations)
        return possibleDestinations[randomIndex]
    else
        print("No destination for this mission and level!")
        return nil
    end
end


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        setupTruckerJob()
        TruckerJobBlip()
    end
end)


