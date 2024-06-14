if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports.es_extended:getSharedObject()

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
    if xPlayer then
        ESX.PlayerData = xPlayer
        ESX.PlayerLoaded = true
        myIdentifier = ESX.PlayerData.identifier
        
        TriggerServerEvent('crews:getCrew', ESX.PlayerData.identifier)
        startLoop()
    else
        error('Failed to retrieve player identifier.')
    end
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function(xPlayer, isNew)
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
    myIdentifier = nil
end)

function playerSetup()
    ESX.PlayerData = ESX.GetPlayerData()
    if ESX.PlayerData then
        myIdentifier = ESX.PlayerData.identifier

        TriggerServerEvent('crews:getCrew', ESX.PlayerData.identifier)
        startLoop()
    else
        error('Failed to retrieve player identifier.')
    end
end