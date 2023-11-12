fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'LikeManTV'
name 'crews'
description 'Crew system'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'locale.lua',
    'locales/*.lua'
}

client_scripts {
    'client/cl_*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_*.lua'
}