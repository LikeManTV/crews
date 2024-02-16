if GetResourceState('qb-core') ~= 'started' then return end
QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local playerData = core.Functions.GetPlayer(source)
    myIdentifier = playerData.citizenid

    TriggerServerEvent('crews:getCrew', playerData.citizenid)
    startLoop()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    myIdentifier = nil
end)