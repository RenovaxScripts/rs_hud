Config = {}

-- Framework: 'AUTO' | 'ESX' | 'QBCORE' | 'STANDALONE'
Config.Framework = 'ESX'

-- Voice system: 'AUTO' | 'PMA' | 'SALTY' | 'TOKO' | 'MUMBLE' | 'STANDALONE'
Config.VoiceSystem = 'PMA'

Config.TickVeh  = 200
Config.TickChar = 500
Config.StaminaTrainRate = 0.001
Config.GroundSpeedUnit = 'mp/h'  -- 'km/h' | 'mp/h'

-- Direction names (used in compass)
-- Czech version
Config.Directions = {
    'S', -- sever / north
    'SV', -- severovýchod / northeast
    'V', -- východ / east
    'JV', -- jihovýchod / southeast
    'J', -- jih / south
    'JZ', -- jihozápad / southwest
    'Z', -- západ / west
    'SZ' -- severozápad / northwest
}

--[[ English version
Config.Directions = {
    'N', -- sever / north
    'NE', -- severovýchod / northeast
    'E', -- východ / east
    'SE', -- jihovýchod / southeast
    'S', -- jih / south
    'SW', -- jihozápad / southwest
    'W', -- západ / west
    'NW' -- severozápad / northwest
}
]]