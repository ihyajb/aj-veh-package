fx_version 'cerulean'
game 'gta5'

description 'Spawns a package inside a random vehicle'
version '1.0.0'
author '@ihyajb'

shared_script '@ox_lib/init.lua'
server_scripts {'server/*.lua'}
client_scripts {'client/*.lua'}
file 'shared/config.lua'

lua54 'yes'
use_experimental_fxv2_oal 'yes'