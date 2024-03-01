if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports.es_extended:getSharedObject()

function getIdentifier(playerId)
    local player = ESX.GetPlayerFromId(playerId)
    return player.getIdentifier()
end

function getPlayerFromIdentifier(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end

function getAllPlayers()
    return ESX.GetExtendedPlayers()
end

function getPlayerData(player)
    local ped = GetPlayerPed(player.source)
    return {src = player.source, ped = ped, identifier = player.identifier, coords = GetEntityCoords(ped), name = player.firstName .. ' ' .. player.lastName}
end
