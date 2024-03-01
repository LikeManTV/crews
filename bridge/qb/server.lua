if GetResourceState('qb-core') ~= 'started' then return end
QBCore = exports['qb-core']:GetCoreObject()

function getIdentifier(playerId)
    local player = QBCore.Functions.GetPlayer(playerId)
    return player.PlayerData.citizenid
end

function getPlayerFromIdentifier(identifier)
    local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
    return player.PlayerData
end

function getAllPlayers()
    return QBCore.Functions.GetQBPlayers()
end

function getPlayerData(player)
    return {ped = GetPlayerPed(player.PlayerData.source), identifier = player.PlayerData.citizenid, coords = player.getCoords(), name = player.PlayerData.firstname .. ' ' .. player.PlayerData.lastname}
end
