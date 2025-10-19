local ESX, QBCore = nil, nil
local usingESX, usingQB = false, false

CreateThread(function()
    if Config.Framework == 'ESX' or (Config.Framework == 'AUTO' and GetResourceState('es_extended') == 'started') then
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        usingESX = true
        print('[RS_HUD] Framework: ESX')
    elseif Config.Framework == 'QBCORE' or (Config.Framework == 'AUTO' and GetResourceState('qb-core') == 'started') then
        QBCore = exports['qb-core']:GetCoreObject()
        usingQB = true
        print('[RS_HUD] Framework: QBCore')
    else
        print('[RS_HUD] Framework: Standalone mode')
    end
end)

if usingESX then
    ESX.RegisterServerCallback('rs_hud:getStatus', function(source, cb)
        local hunger, thirst = 1.0, 1.0
        local playerId = source
        TriggerEvent('esx_status:getStatus', playerId, 'hunger', function(st)
            if st then hunger = st.val / 1000000 end
        end)
        TriggerEvent('esx_status:getStatus', playerId, 'thirst', function(st)
            if st then thirst = st.val / 1000000 end
        end)
        Wait(100)
        cb({ hunger = hunger, thirst = thirst })
    end)
elseif usingQB then
    QBCore.Functions.CreateCallback('rs_hud:getStatus', function(source, cb)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return cb({ hunger = 1.0, thirst = 1.0 }) end
        local m = Player.PlayerData.metadata
        cb({
            hunger = (m.hunger or 100) / 100,
            thirst = (m.thirst or 100) / 100
        })
    end)
else
    RegisterNetEvent('rs_hud:getStatus', function()
        TriggerClientEvent('rs_hud:receiveStatus', source, { hunger = 1.0, thirst = 1.0 })
    end)
end
