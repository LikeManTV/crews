if GetResourceState('qbx_core') ~= 'started' then return end
CreateThread(function() lib.load('@qbx_core.modules.playerdata') end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local playerData = QBX.PlayerData
    if playerData then
        myIdentifier = playerData.citizenid

        TriggerServerEvent('crews:getCrew', playerData.citizenid)
        startLoop()
    else
        error('Failed to retrieve player identifier.')
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    myIdentifier = nil
end)

function playerSetup()
    local playerData = QBX.PlayerData
    if playerData then
        myIdentifier = playerData.citizenid

        TriggerServerEvent('crews:getCrew', playerData.citizenid)
        startLoop()
    else
        error('Failed to retrieve player identifier.')
    end
end