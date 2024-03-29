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
    local ped = GetPlayerPed(player.PlayerData.source)
    return {src = playerData.source, ped = ped, identifier = playerData.citizenid, coords = GetEntityCoords(ped), name = player.charinfo.firstname .. ' ' .. player.charinfo.lastname}
end
