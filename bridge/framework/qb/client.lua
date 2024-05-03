if GetResourceState('qb-core') ~= 'started' then return end
QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local playerData = QBCore.Functions.GetPlayerData()
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
    local playerData = QBCore.Functions.GetPlayerData()
    if playerData then
        myIdentifier = playerData.citizenid

        TriggerServerEvent('crews:getCrew', playerData.citizenid)
        startLoop()
    else
        error('Failed to retrieve player identifier.')
    end
end