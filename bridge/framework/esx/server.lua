if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports.es_extended:getSharedObject()

function getIdentifier(playerId)
    local player = ESX.GetPlayerFromId(playerId)
    return tostring(player.getIdentifier())
end

function getPlayerFromIdentifier(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end

function getAllPlayers()
    return ESX.GetExtendedPlayers()
end

function getPlayerData(player)
    local playerPed = GetPlayerPed(player.source)
    local netId = NetworkGetNetworkIdFromEntity(playerPed)
    repeat Wait(0) until netId and netId ~= nil
    return {source = player.source, ped = netId, identifier = player.identifier, coords = GetEntityCoords(ped), name = GetPlayerName(player.source)}
end