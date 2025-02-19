fx_version 'cerulean'
game 'gta5'

ox_lib 'locale'

author 'mundstock'
description 'Achievements Handler integrated with ictrophies'
version '1.0.0'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'