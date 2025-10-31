local ESX, QBCore = nil, nil
local usingESX, usingQB = false, false

CreateThread(function()
    Wait(500)

    if Config.Framework == 'ESX' or (Config.Framework == 'AUTO' and GetResourceState('es_extended') == 'started') then
        print('[RS_HUD] Framework: ESX – čekám na inicializaci...')
        repeat
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Wait(250)
        until ESX ~= nil

        usingESX = true
        print('[RS_HUD] Framework: ESX načten.')

        ESX.RegisterServerCallback('rs_hud:getStatus', function(source, cb)
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then
                cb({ hunger = 1.0, thirst = 1.0 })
                return
            end

            local hunger, thirst = 1.0, 1.0
            local gotH, gotT = false, false

            TriggerEvent('esx_status:getStatus', source, 'hunger', function(st)
                if st then hunger = (st.val or 1000000) / 1000000.0 end
                gotH = true
            end)
            TriggerEvent('esx_status:getStatus', source, 'thirst', function(st)
                if st then thirst = (st.val or 1000000) / 1000000.0 end
                gotT = true
            end)

            local waited = 0
            while (not gotH or not gotT) and waited < 500 do
                Wait(50)
                waited += 50
            end

            cb({
                hunger = hunger,
                thirst = thirst
            })
        end)

    elseif Config.Framework == 'QBCORE' or (Config.Framework == 'AUTO' and GetResourceState('qb-core') == 'started') then
        QBCore = exports['qb-core']:GetCoreObject()
        usingQB = true
        print('[RS_HUD] Framework: QBCore')

        QBCore.Functions.CreateCallback('rs_hud:getStatus', function(source, cb)
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then
                cb({ hunger = 1.0, thirst = 1.0 })
                return
            end

            local m = Player.PlayerData.metadata or {}
            cb({
                hunger = (m.hunger or 100) / 100,
                thirst = (m.thirst or 100) / 100
            })
        end)

    else
        print('[RS_HUD] Framework: Standalone mode')
        RegisterNetEvent('rs_hud:getStatus', function()
            TriggerClientEvent('rs_hud:receiveStatus', source, { hunger = 1.0, thirst = 1.0 })
        end)
    end
end)

