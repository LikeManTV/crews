fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'LikeManTV'
name 'crews'
description 'Crew System'
version '2.0.2'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/locale.lua',
    'locales/*.lua'
}

client_scripts {
    "bridge/**/**/client.lua",
    'client/cl_*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "bridge/**/**/server.lua",
    'server/sv_*.lua'
}
