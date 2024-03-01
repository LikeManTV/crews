if GetResourceState('qb-core') ~= 'started' then return end
QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local playerData = QBCore.Functions.GetPlayerData()
    myIdentifier = playerData.citizenid

    TriggerServerEvent('crews:getCrew', playerData.citizenid)
    startLoop()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    myIdentifier = nil
end)
