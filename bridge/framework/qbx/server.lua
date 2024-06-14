if GetResourceState('qbx_core') ~= 'started' then return end

function getIdentifier(playerId)
    local player = exports.qbx_core:GetPlayer(playerId)
    return tostring(player.PlayerData.citizenid)
end

function getPlayerFromIdentifier(identifier)
    local player = exports.qbx_core:GetPlayerByCitizenId(identifier)
    return player.PlayerData
end

function getAllPlayers()
    return exports.qbx_core:GetQBPlayers()
end

function getPlayerData(player)
    local playerData = player.PlayerData
    local playerPed = GetPlayerPed(player.PlayerData.source)
    local netId = NetworkGetNetworkIdFromEntity(playerPed)
    repeat Wait(0) until netId and netId ~= nil
    return {source = playerData.source, ped = netId, identifier = tostring(playerData.citizenid), coords = GetEntityCoords(playerPed), name = GetPlayerName(playerData.source)}
end