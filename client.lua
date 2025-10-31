local FW = { name = 'STANDALONE', esx=nil, qb=nil }

-- ==== Framework AUTO Detection ====
CreateThread(function()
  if Config.Framework == 'QBCORE' or (Config.Framework=='AUTO' and GetResourceState('qb-core')=='started') then
    FW.name = 'QBCORE'
    FW.qb = exports['qb-core'] and exports['qb-core']:GetCoreObject()
  elseif Config.Framework == 'ESX' or (Config.Framework=='AUTO' and GetResourceState('es_extended')=='started') then
    FW.name = 'ESX'
    TriggerEvent('esx:getSharedObject', function(obj) FW.esx = obj end)
  else
    FW.name = 'STANDALONE'
  end
end)

-- === Voice System detection ===
local voiceSys = 'STANDALONE'
CreateThread(function()
    Wait(500)
    if Config.VoiceSystem == 'PMA' or (Config.VoiceSystem=='AUTO' and GetResourceState('pma-voice')=='started') then
        voiceSys = 'PMA'
        print('[RS_HUD] Voice: pma-voice')
        RegisterNetEvent('pma-voice:setTalkingMode', function(mode)
            local lvl = (mode==1 and 0.33) or (mode==3 and 1.0) or 0.66
            SendNUIMessage({action='voice', data={level=lvl}})
        end)
        RegisterNetEvent('pma-voice:talking', function(t)
            SendNUIMessage({action='voice', data={talking=t}})
        end)
        RegisterNetEvent('pma-voice:radioActive', function(r)
            SendNUIMessage({action='voice', data={radio=r}})
        end)

    elseif Config.VoiceSystem == 'SALTY' or (Config.VoiceSystem=='AUTO' and GetResourceState('saltychat')=='started') then
        voiceSys = 'SALTY'
        print('[RS_HUD] Voice: SaltyChat')
        RegisterNetEvent('SaltyChat_TalkStateChanged', function(talking)
            SendNUIMessage({action='voice', data={talking=talking}})
        end)

    elseif Config.VoiceSystem == 'TOKO' or (Config.VoiceSystem=='AUTO' and GetResourceState('tokovoip_script')=='started') then
        voiceSys = 'TOKO'
        print('[RS_HUD] Voice: TokoVOIP')
        RegisterNetEvent('TokoVoip:onPlayerSpeaking', function(talking)
            SendNUIMessage({action='voice', data={talking=talking}})
        end)

    elseif Config.VoiceSystem == 'MUMBLE' or (Config.VoiceSystem=='AUTO' and GetResourceState('mumble-voip')=='started') then
        voiceSys = 'MUMBLE'
        print('[RS_HUD] Voice: Mumble')
        RegisterNetEvent('mumble:setTalkingState', function(talking)
            SendNUIMessage({action='voice', data={talking=talking}})
        end)
    else
        print('[RS_HUD] Voice: Standalone fallback')
    end
end)


-- ==== Helpers ====
local function nui(a,d) SendNUIMessage({action=a,data=d}) end
local function clamp(x) return math.max(0.0, math.min(1.0, x or 0.0)) end

-- ==== Needs (Hunger/Drink bar) ====

-- ==== Needs (Hunger/Drink bar) ====

local needs = { hunger = 1.0, thirst = 1.0 }

CreateThread(function()
    while FW.name == 'STANDALONE' do
        Wait(500)
    end

    if FW.name == 'ESX' then
        print('[RS_HUD] Používám esx_status pro hunger/thirst.')
        RegisterNetEvent('esx_status:onTick', function(status)
            for _, st in ipairs(status) do
                if st.name == 'hunger' then
                    needs.hunger = clamp(st.percent / 100.0)
                elseif st.name == 'thirst' then
                    needs.thirst = clamp(st.percent / 100.0)
                end
            end
        end)
    elseif FW.name == 'QBCORE' then
        print('[RS_HUD] Používám QBCore metadata pro hunger/thirst.')
        CreateThread(function()
            while true do
                local pd = FW.qb.Functions.GetPlayerData() or {}
                local md = pd.metadata or {}
                needs.hunger = clamp((md.hunger or 100) / 100)
                needs.thirst = clamp((md.thirst or 100) / 100)
                Wait(1000)
            end
        end)
    else
        print('[RS_HUD] Standalone režim – hunger/thirst se neaktualizují.')
    end
end)


-- ==== Stamina ====
local staminaSkill, runTimer = 1.0, 0.0

CreateThread(function()
  while true do
    local ped = PlayerPedId()
    if IsPedRunning(ped) or IsPedSprinting(ped) then
      runTimer = runTimer + (Config.StaminaTrainRate or 0.001)
      staminaSkill = math.min(1.0 + runTimer, 2.0)
    end
    Wait(1000)
  end
end)

-- ==== Minimap ====

local mapLoaded = false

function setupmap()
    if mapLoaded then return end
    mapLoaded = true

    RequestStreamedTextureDict("squaremap", false)
    while not HasStreamedTextureDictLoaded("squaremap") do
        Wait(0)
    end

    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")
    SetMinimapClipType(1)
    
    local defaultAspect = 1920 / 1080
    local resX, resY = GetActiveScreenResolution()
    local aspect = resX / resY
    local offsetX = 0.0
    if aspect > defaultAspect then
        local diff = defaultAspect - aspect
        offsetX = diff / 3.6
    end

    SetMinimapComponentPosition("minimap", "L", "B", 0.00 + offsetX, -0.020, 0.1638, 0.183)
    SetMinimapComponentPosition("minimap_mask", "L", "B", 0.00 + offsetX, 0.005, 0.128, 0.20)
    SetMinimapComponentPosition("minimap_blur", "L", "B", -0.011 + offsetX, 0.045, 0.265, 0.295)

    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetRadarBigmapEnabled(true, false)
    Wait(500)
    SetRadarBigmapEnabled(false, false)
    SetRadarZoom(1100)

    SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0)
end

RegisterCommand("fixmap", function()
    mapLoaded = false
    setupmap()
    print("[RS HUD] ✅ Minimap znovu inicializována.")
end)

-- ==== Character HUD loop ====
CreateThread(function()
  setupmap()
  TriggerEvent('pma-voice:setTalkingMode')  
  while true do
    local ped = PlayerPedId()
    local hp = clamp((GetEntityHealth(ped) - 100) / (GetEntityMaxHealth(ped) - 100))
    local armor = clamp(GetPedArmour(ped) / 100.0)
    local staminaUsed = 1.0 - (GetPlayerSprintStaminaRemaining(PlayerId()) / 100.0)
    local stamina = clamp(staminaUsed * staminaSkill)

    nui('character', {
      hp = hp,
      armor = armor,       
      hunger = needs.hunger,
      drink = needs.thirst,
      stamina = stamina
    })

    Wait(Config.TickChar or 500)
  end
end)

-- ==== Voice: range + talking (only pma-voice!!!!!!!!!) ====
local voice = { level = 0.33, talking = false, radio = false }
RegisterNetEvent('pma-voice:setTalkingMode', function(mode)
  if type(mode)=='number' then
    voice.level = (mode==1 and 0.33) or (mode==3 and 1.0) or 0.66
  elseif type(mode)=='string' then
    local m = mode:lower()
    voice.level = (m=='whisper' and 0.33) or (m=='shout' and 1.0) or 0.66
  end
  nui('voice', voice)
end)
RegisterNetEvent('pma-voice:talking', function(t) voice.talking=t; nui('voice', voice) end)
RegisterNetEvent('pma-voice:radioActive', function(r) voice.radio=r; nui('voice', voice) end)

-- ==== Vehicle + Compass ====
local dirsCZ = Config.Directions or {
  'J', 'JV', 'V', 'SV', 'S', 'SZ', 'Z', 'JZ'
}
local function dirIndexFromHeading(h)
  return (math.floor((h+22.5)/45) % 8) + 1
end

CreateThread(function()
  while true do
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
      local veh = GetVehiclePedIsIn(ped, false)
      local class = GetVehicleClass(veh)
      local vType = 'car'
      if class==14 then vType='boat' elseif class==15 then vType='heli' elseif class==16 then vType='plane' end

      local speed = math.floor(GetEntitySpeed(veh) * 3.6 + 0.5)
      local rpm = clamp(GetVehicleCurrentRpm(veh))
      local fuel = clamp((GetVehicleFuelLevel(veh) or 0)/100.0)

      local coords = GetEntityCoords(veh)
      local s1,s2 = GetStreetNameAtCoord(coords.x,coords.y,coords.z)
      local street = (GetStreetNameFromHashKey(s1) or '')
      if s2 and s2~=0 then street = street .. ' / ' .. (GetStreetNameFromHashKey(s2) or '') end

      local heading = GetEntityHeading(veh)
      local idx = dirIndexFromHeading(heading)
      local prev = dirsCZ[(idx-2)%8+1]
      local cur  = dirsCZ[idx]
      local next = dirsCZ[(idx)%8+1]

      nui('vehicle', {
        show=true, vType=vType,
        speed=speed, unit=Config.GroundSpeedUnit, rpm=rpm, fuel=fuel,
        street=street,
        compass={prev=prev, cur=cur, next=next}
      })
    else
      nui('vehicle', { show=false })
    end
    Wait(Config.TickVeh or 200)
  end
end)

-- ==== Auto-reset minimap after load/spawn ====

AddEventHandler('playerSpawned', function()
    mapLoaded = false
    Wait(1000)
    print('[RS_HUD] 🧭 PlayerSpawned – mapa se resetuje...')
    setupmap()
    Wait(1000)
    mapLoaded = false
    setupmap()
end)


--[[
if FW.name == 'ESX' and FW.esx then
  RegisterNetEvent('esx:playerLoaded', function()
      mapLoaded = false 
      Wait(1000)
      print('[RS_HUD] 🧭 ESX playerLoaded – mapa se resetuje...')
      setupmap()
  end)
end

if FW.name == 'QBCORE' and FW.qb then
  RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
      mapLoaded = false
      Wait(1000)
      print('[RS_HUD] 🧭 QBCore playerLoaded – mapa se resetuje...')
      setupmap()
  end)
end
]]