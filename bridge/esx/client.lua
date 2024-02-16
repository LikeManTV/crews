if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports.es_extended:getSharedObject()

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true

    myIdentifier = xPlayer.identifier
    TriggerServerEvent('crews:getCrew', xPlayer.identifier)
    startLoop()
end)

RegisterNetEvent('esx:playerLogout')
AddEventHandler('esx:playerLogout', function(xPlayer, isNew)
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}

    myIdentifier = nil
end)