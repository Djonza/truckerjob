window.addEventListener('message', function(event) {
    if (event.data.type === 'open') {
        document.body.style.display = 'flex';
        var elements = document.getElementsByClassName("menu-container");
        for (var i = 0; i < elements.length; i++) {
            elements[i].style.display = 'flex';
        }
        loadDashboardAuto();
    }

    if (event.data.type === 'close') {
        document.body.style.display = 'none';
    }
});

function loadMissions(missions) {
    if (!missions || missions.length === 0) {
        console.log("No missions available.");
        return;
    }

    const missionsList = document.getElementById('missionsList');
    missionsList.innerHTML = '';

    let missionsArray = Array.isArray(missions) ? missions : missions.missions;

    if (!Array.isArray(missionsArray)) {
        console.error("Missions data is not an array or properly formatted:", missions);
        return;
    }

    const sortedMissions = missionsArray.sort((a, b) => {
        const difficultyOrder = { 'easy': 1, 'medium': 2, 'hard': 3 };
        return difficultyOrder[a.difficulty] - difficultyOrder[b.difficulty];
    });

    sortedMissions.forEach((mission, index) => {
        const missionElement = document.createElement('div');
        missionElement.className = 'mission';
        missionElement.innerHTML = `<strong>${mission.name}</strong><p>${mission.description}</p>`;
        
        missionElement.addEventListener('click', function() {
            fetch(`http://${GetParentResourceName()}/selectMission`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ missionIndex: index })
            });
        });

        missionsList.appendChild(missionElement);
    });
}


window.addEventListener('message', function(event) {
    if (event.data.type === 'showMissions') {
        loadMissions(event.data.missions);
    }
});


function loadDashboardAuto() {
    const dashboardItem = document.getElementById('dashboard');
    if (dashboardItem) {
        document.querySelectorAll('.sidebar ul li').forEach(function(li) {
            li.classList.remove('active');
        });
        dashboardItem.classList.add('active');

        const header = document.querySelector('.menu h1');
        header.textContent = 'Dashboard';

        fetch(`http://${GetParentResourceName()}/getPlayerDashboard`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        }).then(response => response.json()).then(data => {
            loadDashboard(data);
        });
    }
}


function loadDashboard(playerData) {
    const missionsList = document.getElementById('missionsList');
    missionsList.innerHTML = '';
    const dashboardContent = `
        <div class="dashboard-container">
            <div class="dashboard-item">
                <h2>Player</h2>
                <p>${playerData.level}</p>
            </div>
            <div class="dashboard-item">
                <h2>Experience</h2>
                <p>${playerData.experience} XP</p>
            </div>
            <div class="dashboard-item">
                <h2>Next Level XP</h2>
                <p>${playerData.nextLevelExp}</p>
            </div>
            <div class="dashboard-item">
                <h2>Total earnings</h2>
                <p>${playerData.totalEarnings}$</p>
            </div>
            <div class="dashboard-item">
                <h2>Kilometers traveled</h2>
                <p>${playerData.kilometers} km</p>
            </div>
            <div class="dashboard-item">
                <h2>Missions completed</h2>
                <p>${playerData.completedMissions}</p>
            </div>
        </div>
    `;
    missionsList.innerHTML = dashboardContent;
}


window.addEventListener('message', function(event) {
    if (event.data.type === 'showDashboard') {
        loadDashboard(event.data.playerData);
    }
});


document.querySelectorAll('.sidebar ul li').forEach(function(item) {
    item.addEventListener('click', function() {
        document.querySelectorAll('.sidebar ul li').forEach(function(li) {
            li.classList.remove('active');
        });
        item.classList.add('active');

        const section = item.id;
        const header = document.querySelector('.menu h1');
        const contentContainer = document.getElementById('missionsList');

        contentContainer.classList.remove('content-animation');

        setTimeout(() => {
            if (section === 'dashboard') {
                header.textContent = 'Dashboard';
                fetch(`http://${GetParentResourceName()}/getPlayerDashboard`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    }
                }).then(response => response.json()).then(data => {
                    loadDashboard(data);
                    contentContainer.classList.add('content-animation');
                });
            } else if (section === 'missions') {
                header.textContent = 'Select Mission';
                fetch(`http://${GetParentResourceName()}/getMissions`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    }
                }).then(response => response.json()).then(data => {
                    loadMissions(data.missions);
                    contentContainer.classList.add('content-animation');
                });
            } else if (section === 'admin') {
                header.textContent = 'Admin Settings';
                fetch(`http://${GetParentResourceName()}/getAdminData`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    }
                }).then(response => response.json()).then(data => {
                    loadAdminData(data.playersData);
                    contentContainer.classList.add('content-animation');
                });
            }
        }, 100);
    });
});


function loadAdminData(playersData) {
    const missionsList = document.getElementById('missionsList');
    missionsList.innerHTML = ''; 

    if (!playersData || playersData.length === 0) {
        missionsList.innerHTML = '<p class="no-data-message">No player data available.</p>';
        return;
    }

    const adminContent = `
        <div class="admin-container">
            ${playersData.map(player => `
                <div class="admin-item">
                  <p>Level: ${player.identifier}</p>
                    <p>Level: ${player.level}</p>
                    <p>Experience: ${player.experience} XP</p>
                    <p>Total Earnings: ${player.totalEarnings} $</p>
                    <p>Kilometers Traveled: ${player.kilometers} km</p>
                    <p>Missions Completed: ${player.completedMissions}</p>
                    <button class="edit-button" data-id="${player.identifier}">Edit Player</button>
                </div>
            `).join('')}
        </div>
    `;

    missionsList.innerHTML = adminContent;

    document.querySelectorAll('.edit-button').forEach(button => {
        button.addEventListener('click', function() {
            const playerId = this.getAttribute('data-id');
            const player = playersData.find(p => p.identifier === playerId);
            if (player) {
                openEditModal(player);
            }
        });
    });
}

document.querySelector('.close-button').addEventListener('click', function() {
    document.getElementById('editModal').style.display = 'none';
});

function openEditModal(player) {
    const modal = document.getElementById('editModal');
    const form = document.getElementById('editPlayerForm');

    form.playerLevel.value = player.level;
    form.playerExperience.value = player.experience;
    form.playerEarnings.value = player.totalEarnings;
    form.playerKilometers.value = player.kilometers;
    form.playerMissions.value = player.completedMissions;
    form.playerIdentifier.value = player.identifier;

    modal.style.display = 'flex';
}

// Zatvaranje modalnog prozora
document.querySelector('.close-button').addEventListener('click', function() {
    document.getElementById('editModal').style.display = 'none';
});

window.addEventListener('click', function(event) {
    const modal = document.getElementById('editModal');
    if (event.target === modal) {
        modal.style.display = 'none';
    }
});

document.getElementById('editPlayerForm').addEventListener('submit', function(e) {
    e.preventDefault(); 
    const playerData = {
        identifier: e.target.playerIdentifier.value,
        level: e.target.playerLevel.value,
        experience: e.target.playerExperience.value,
        totalEarnings: e.target.playerEarnings.value,
        kilometers: e.target.playerKilometers.value,
        completedMissions: e.target.playerMissions.value
    };
    fetch(`http://${GetParentResourceName()}/updatePlayer', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(playerData)
    }).then(response => response.json()).then(data => {
        console.log('Player updated:', data);
        document.getElementById('editModal').style.display = 'none';
    }).catch(error => {
        console.error('Error updating player:', error);
    });
});


document.getElementById('close').addEventListener('click', function() {
    fetch(`http://${GetParentResourceName()}/closeMenu`, {
        method: 'POST'
    });
});
