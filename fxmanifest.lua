fx_version 'bodacious'
lua54 'yes'
game 'gta5'
version '1.2'

shared_script {'@ox_lib/init.lua', '@es_extended/imports.lua'}
server_scripts {
	'@oxmysql/lib/MySQL.lua', 
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua',
	'client/nui.lua'
}

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
     'locales/en.json'
}

ui_page 'nui/index.html' 
