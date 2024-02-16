if GetResourceState('ox_core') ~= 'started' then return end
CreateThread(function() lib.load('@ox_core.imports.server') end)

function getIdentifier(playerId)
    local player = Ox.GetPlayer(playerId)
    if player then
        return player.charId
    end

    return nil
end

function getPlayerFromIdentifier(identifier)
    local players = Ox.GetPlayers()

    for i=1, #players do
        local player = players[i]
        if player.charId and player.charId == identifier then
            return player
        end
    end

    return nil
end

function getAllPlayers()
    return Ox.GetPlayers()
end

function getPlayerData(player)
    return {ped = GetPlayerPed(player.source), identifier = player.charId, coords = player.getCoords(), name = player.name}
end