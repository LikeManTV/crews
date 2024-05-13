if GetResourceState('ox_core') ~= 'started' then return end
CreateThread(function() lib.load('@ox_core.imports.client') end)

AddEventHandler('ox:playerLoaded', function(data)
    if data and data.charId then
        myIdentifier = data.charId

        TriggerServerEvent('crews:getCrew', tostring(data.charId))
        startLoop()
    else
        error('Failed to retrieve player identifier.')
    end
end)

AddEventHandler('ox:playerLogout', function()
    myIdentifier = nil
end)

function playerSetup()
    repeat Wait(0) until player and player.charId
    if player and player.charId then
        myIdentifier = tostring(player.charId)

        TriggerServerEvent('crews:getCrew', tostring(player.charId))
        startLoop()
    else
        error('Failed to retrieve player identifier.')
    end
end