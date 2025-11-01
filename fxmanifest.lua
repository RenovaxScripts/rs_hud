fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Renovax Scripts | NoBody.exe'
description '[FREE] Hud + Car hud'
version '1.0.0'

ui_page 'html/index.html'

client_scripts {
  'config.lua',
  'client.lua'
}

server_scripts {
    'config.lua',
    'server.lua'
}

files {
  'html/index.html',
  'html/style.css',
  'html/app.js',
  'html/icons/*.svg',

  -- minimap stream
  'stream/minimap.gfx',
  'stream/circlemap.ytd',
  'stream/squaremap.ytd',

}

data_file 'DLC_ITYP_REQUEST' 'stream/circlemap.ytd'
data_file 'DLC_ITYP_REQUEST' 'stream/squaremap.ytd'

