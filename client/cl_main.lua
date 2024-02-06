core, coreName = nil, nil
crew = nil
invites = nil
crewNames, crewTags = {}, {}
crewBlipsNear, crewBlipsFar = {}, {}

myIdentifier = nil
showTags = true
pvp = false

----------------------------------------------------------------

if GetResourceState('es_extended') == 'started' then
    core = exports["es_extended"]:getSharedObject()
    coreName = 'esx'

    CreateThread(function()
        while core.GetPlayerData().identifier == nil do
            Wait(10)
        end
    
        core.PlayerData = core.GetPlayerData()
    end)
elseif GetResourceState('qb-core') == 'started' then
    core = exports['qb-core']:GetCoreObject()
    coreName = 'qb'
else
    print('Framework is missing, script will not work..')
    return
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded',function(xPlayer, isNew, skin)
    CreateThread(function()
        while core.GetPlayerData().identifier == nil do
            Wait(10)
        end
    
        core.PlayerData = core.GetPlayerData()
    end)

    myIdentifier = core.PlayerData.identifier
    TriggerServerEvent('crews:getCrew')
    startLoop()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local playerData = core.Functions.GetPlayer(source)
    myIdentifier = playerData.citizenid
    TriggerServerEvent('crews:getCrew')
    startLoop()
end)

if type(CONFIG.CREW_SETTINGS.COMMAND) == 'string' then
    RegisterCommand(CONFIG.CREW_SETTINGS.COMMAND, function()
        crewMenu.openMainMenu()
    end)
end

if CONFIG.CREW_SETTINGS.ENABLE_KEYBIND then
    RegisterKeyMapping(CONFIG.CREW_SETTINGS.COMMAND, _L('keybind_desc'), 'keyboard', CONFIG.CREW_SETTINGS.OPEN_KEY)
end

-- EVENTS ------------------------------------------------------

--AddEventHandler('onResourceStart', function(resourceName)
--    if (GetCurrentResourceName() ~= resourceName) then
--      return
--    end
--
--    if coreName == 'esx' then
--        myIdentifier = core.PlayerData.identifier
--    elseif coreName == 'qb' then
--        local playerData = core.Functions.GetPlayer(source)
--        myIdentifier = playerData.citizenid
--    end
--    TriggerServerEvent('crews:getCrew')
--    startLoop()
--end)

RegisterNetEvent('crews:openMainMenu', function()
    crewMenu.openMainMenu()
end)

RegisterNetEvent('crews:setCrew', function(newCrew)
    crew = newCrew

    showTags = false
    util.deleteTag(k)
    showTags = true
end)

RegisterNetEvent('crews:setInvites', function(newInvites)
    invites = newInvites
end)

RegisterNetEvent('crews:setNames', function(newNames)
    crewNames = newNames
end)

RegisterNetEvent('crews:setTags', function(newTags)
    crewTags = newTags
end)

RegisterNetEvent('crews:removeBlip', function(identifier)
    if crew then
        for k,v in pairs(crew.data) do
            if k == identifier then
                util.deleteBlip(identifier)
            end
        end
    end
end)

RegisterNetEvent('crews:removePlayer', function(owner, identifier)
    if crew and crew.owner == owner then
        util.deleteBlip(identifier)
        util.deleteTag(identifier)
    end
end)

RegisterNetEvent('crews:playerLeft', function(owner)
    if crew and crew.owner == owner then
        util.deleteBlip()
        util.deleteTag()
    end
end)

RegisterNetEvent('crews:notify', function(text, type)
    notify(text, type)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        util.deleteBlip()
        util.deleteTag()
        DisplayPlayerNameTagsOnBlips(false)
    end
end)

RegisterCommand('crewTags', function()
    showTags = not showTags
    notify(_L('toggle_tags', {showTags and 'shown' or 'hidden'}), 'inform')
end)

-- Blips & Tags
function startLoop()
    CreateThread(function()
        while true do
            Wait(1000)
            if crew then
                for k,v in pairs(crew.data) do
                    local players = lib.callback.await('crews:blipUpdate', false)
                    if players then
                        for index, obj in pairs(players) do
                            local blipPlayer = obj[1]
                            local playerPed = NetworkDoesEntityExistWithNetworkId(obj[2]) and NetworkGetEntityFromNetworkId(obj[2]) or nil
                            local ident = obj[3]
                            local name = obj[4]
                            local coords = obj[5]
                            if name ~= GetPlayerName(GetPlayerIndex()) then
                                if k == ident then
                                    if #(coords.xyz - GetEntityCoords(PlayerPedId()).xyz) < 100.0 then
                                        if crewBlipsNear[k] == nil then
                                            if crewBlipsFar[k] then
                                                RemoveBlip(crewBlipsFar[k])
                                                crewBlipsFar[k] = nil
                                            end
            
                                            local blip = AddBlipForEntity(playerPed)
                                            SetBlipDisplay(blip, 2)
                                            SetBlipSprite(blip, 1)
                                            SetBlipColour(blip, 2)
                                            SetBlipScale(blip, 0.7)
                                            SetBlipCategory(blip, 7)
                                            SetBlipShowCone(blip, true)
                                            crewBlipsNear[k] = blip
                                            
                                            DisplayPlayerNameTagsOnBlips(true)
                                            BeginTextCommandSetBlipName("STRING")
                                            AddTextComponentSubstringPlayerName(name)
                                            EndTextCommandSetBlipName(blip)
                                        end
                                    else
                                        if crewBlipsFar[k] == nil then
                                            if crewBlipsNear[k] then
                                                RemoveBlip(crewBlipsNear[k])
                                                crewBlipsNear[k] = nil
                                            end
            
                                            if crewBlipsFar[k] and DoesBlipExist(crewBlipsFar[k]) then
                                                local blip = crewBlipsFar[k]
                                                SetBlipCoords(blip, coords.xyz)
                                            else
                                                local blip = AddBlipForCoord(coords.xyz)
                                                SetBlipDisplay(blip, 2)
                                                SetBlipSprite(blip, 1)
                                                SetBlipColour(blip, 2)
                                                SetBlipScale(blip, 0.7)
                                                SetBlipCategory(blip, 7)
                                                crewBlipsFar[k] = blip
                                                
                                                DisplayPlayerNameTagsOnBlips(true)
                                                BeginTextCommandSetBlipName("STRING")
                                                AddTextComponentSubstringPlayerName(name)
                                                EndTextCommandSetBlipName(blip)
                                            end
                                        end
                                    end
            
                                    if showTags then
                                        crewTags[k] = CreateFakeMpGamerTag(playerPed, '['..(crew.tag or 'nil')..'] '..name, false, false, "", 0, 0, 0, 0)
                                        SetMpGamerTagColour(crewTags[k], 0, 18)
                                        SetMpGamerTagVisibility(crewTags[k], 2, 1)
                                        SetMpGamerTagAlpha(crewTags[k], 2, 255)
                                        SetMpGamerTagHealthBarColor(crewTags[k], 129)
                                    else
                                        util.deleteTag(k)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end
AddTextEntry("BLIP_OTHPLYR", 'CREW')

-- EXPORTS ------------------------------------------------------

exports('ownsCrew', function()
    if crew and crew.owner == myIdentifier then
        return true
    end

    return false
end)

exports('isInCrew', function()
    if crew and crew.data[myIdentifier] then
        return true
    end

    return false
end)

exports('getCrew', function()
    if crew then
        return crew
    end

    return {}
end)
