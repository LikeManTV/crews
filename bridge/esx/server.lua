if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports.es_extended:getSharedObject()

function getIdentifier(playerId)
    local player = ESX.GetPlayerFromId(playerId)
    return player.getIdentifier()
end

function getPlayerFromIdentifier(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end