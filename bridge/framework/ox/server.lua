if GetResourceState('ox_core') ~= 'started' then return end
CreateThread(function() lib.load('@ox_core.imports.server') end)

function getIdentifier(playerId)
    local player = Ox.GetPlayer(playerId)
    if player and player.charId then
        return tostring(player.charId)
    end

    return nil
end

function getPlayerFromIdentifier(identifier)
    local players = Ox.GetPlayers()

    for i=1, #players do
        local player = players[i]
        if player.charId and tostring(player.charId) == identifier then
            return player
        end
    end

    return nil
end

function getAllPlayers()
    repeat Wait() until Ox
    return Ox.GetPlayers()
end

function getPlayerData(player)
    local playerPed = GetPlayerPed(player.source)
    local netId = NetworkGetNetworkIdFromEntity(playerPed)
    repeat Wait(0) until netId and netId ~= nil
    return {source = player.source, ped = netId, identifier = tostring(player.charId), coords = player.getCoords(), name = GetPlayerName(player.source)}
end