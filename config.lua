Config = {}

Config.TruckerLocations = {
    { 
        coords = vector3(1196.9119, -3253.1448, 7.0952),
        radius = 3.0,
    }
}

Config.TruckSpawnPoints = {
    easy = vector3(1199.8711, -3242.1006, 5.9143),
    medium = vector3(1199.8711, -3242.1006, 5.9143),
    hard = vector3(1199.8711, -3242.1006, 5.9143)
}

Config.Trucks = {
    easy = "bf400",
    medium = "bf400",
    hard = "bf400"
}

Config.DeliveryDestinations = {
    easy = {
        vector3(431.2121, -1014.5395, 28.8458),
        vector3(-710.7066, -122.8735, 37.5943),
    },
    medium = {
        vector3(431.2121, -1014.5395, 28.8458),
        vector3(-710.7066, -122.8735, 37.5943),
    },
    hard = {
        vector3(431.2121, -1014.5395, 28.8458),
        vector3(-710.7066, -122.8735, 37.5943),
    }
}

Config.MissionsLevels = {
    [1] = {
        name = "Level 1",
        missions = {
            {
                name = "Route 1",
                description = "Easy route description",
                difficulty = 'easy',
                reward = {exp = {min = 1, max = 3}, cash = {min = 25, max = 50}},
                truckModel = "bf400",
                pedModel = "s_m_m_security_01"
            },
            {
                name = "Route 2",
                description = "Easy route description",
                difficulty = 'easy',
                reward = {exp = {min = 1, max = 3}, cash = {min = 25, max = 50}},
                truckModel = "bf400",
                pedModel = "s_m_m_security_01"
            },
        }
    },
    [2] = { 
        name = "Level 2",
        missions = {
            {
                name = "Medium route 1",
                description = "Medium route description",
                difficulty = 'medium',
                reward = {exp = {min = 2, max = 6}, cash = {min = 35, max = 75}},
                truckModel = "bf400",
                pedModel = "s_m_m_trucker_01"
            },
            {
                name = "Medium route 2",
                description = "Medium route description",
                difficulty = 'medium',
                reward = {exp = {min = 2, max = 6}, cash = {min = 35, max = 75}},
                truckModel = "bf400",
                pedModel = "s_m_m_trucker_01"
            },
        }
    },
    [3] = { 
        name = "Level 3",
        missions = {
            {
                name = "Hard route",
                description = "Hard route description",
                difficulty = 'hard',
                reward = {exp = {min = 5, max = 10}, cash = {min = 75, max = 125}},
                truckModel = "bf400",
                pedModel = "s_m_m_armoured_01"
            },
            {
                name = "Hard route",
                description = "Hard route description",
                difficulty = 'hard',
                reward = {exp = {min = 5, max = 10}, cash = {min = 75, max = 125}},
                truckModel = "bf400",
                pedModel = "s_m_m_armoured_01"
            },
        }
    }
}


Config.Levels = {
    {level = 1, requiredExp = 0}, -- default
    {level = 2, requiredExp = 200},
    {level = 3, requiredExp = 300},
}
