if GetResourceState('ox_core') ~= 'started' then return end
CreateThread(function() lib.load('@ox_core.imports.client') end)

AddEventHandler('ox:playerLoaded', function(data)
    myIdentifier = data.charId

    TriggerServerEvent('crews:getCrew', data.charId)
    startLoop()
end)

AddEventHandler('ox:playerLogout', function()
    myIdentifier = nil
end)