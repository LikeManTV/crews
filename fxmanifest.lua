fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'LikeManTV'
name 'crews'
description 'Crew System for FiveM'
version '2.0.3'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/sh_*.lua',
    'locales/*.lua'
}

client_scripts {
    "bridge/**/**/**/client.lua",
    'client/cl_class.lua',
    'client/cl_main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "bridge/**/**/**/server.lua",
    'server/sv_*.lua'
}