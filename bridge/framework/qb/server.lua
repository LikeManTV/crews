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
    local playerData = player.PlayerData
    local playerPed = GetPlayerPed(player.PlayerData.source)
    local netId = NetworkGetNetworkIdFromEntity(playerPed)
    repeat Wait(0) until netId and netId ~= nil
    return {source = playerData.source, ped = netId, identifier = playerData.citizenid, coords = GetEntityCoords(ped), name = GetPlayerName(playerData.source)}
end