crew, invites = nil, nil
crewNames, crewTags = {}, {}
crewBlipsNear, crewBlipsFar, currentTags = {}, {}, {}

myIdentifier = nil

settings = {
    showTags = true
}

----------------------------------------------------------------

if CONFIG.COMMAND then
    RegisterCommand(CONFIG.COMMAND, function()
        crewMenu.openMainMenu()
    end)
else
    error('Your CONFIG.COMMAND is not configured properly.')
end

----------------------------------------------------------------

RegisterNetEvent('crews:setCrew', function(crewData, newInvites, names, tags)
    crew = crewData
    invites = newInvites
    crewNames = names
    crewTags = tags
end)

RegisterNetEvent('crews:updateCrew', function(data)
    crew = data
end)

RegisterNetEvent('crews:updateInvites', function(data)
    invites = data
end)

RegisterNetEvent('crews:updateNames', function(data)
    crewNames = data
end)

RegisterNetEvent('crews:updateTags', function(data)
    crewTags = data
end)

RegisterNetEvent('crews:removePlayer', function(identifier)
    if crew then
        utils.deleteBlip(identifier)
        utils.deleteTag(identifier)
    end
end)

RegisterNetEvent('crews:playerLeft', function(owner)
    if crew and crew.owner == owner then
        utils.deleteBlip()
        utils.deleteTag()
    end
end)

RegisterNetEvent('crews:notify', function(text, _type)
    notify(text, _type)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    playerSetup()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    utils.deleteBlip()
    utils.deleteTag()
    DisplayPlayerNameTagsOnBlips(false)
end)

----------------------------------------------------------------

RegisterCommand('crewTags', function()
    settings.showTags = not settings.showTags
    notify(_L('toggle_tags', {settings.showTags and _L('tags_enabled') or _L('tags_disabled')}), 'inform')
end)

function startLoop()
    CreateThread(function()
        while myIdentifier ~= nil do
            Wait(1000)
            if crew then
                for identifier,_ in pairs(crew.data) do
                    local players = lib.callback.await('crews:blipUpdate', false)
                    if players then
                        for _, obj in pairs(players) do
                            local blipPlayer = obj.source
                            local playerPed = NetworkDoesEntityExistWithNetworkId(obj.ped) and NetworkGetEntityFromNetworkId(obj.ped) or nil
                            local targetIdentifier, name, coords = obj.identifier, obj.name, obj.coords
                            if not DoesEntityExist(playerPed) then goto continue end
                            if identifier == targetIdentifier then
                                if targetIdentifier ~= myIdentifier then
                                    if CONFIG.ENABLE_BLIPS then
                                        if #(GetEntityCoords(cache.ped) - coords) < 100.0 then
                                            if crewBlipsNear[identifier] == nil then
                                                if crewBlipsFar[identifier] then
                                                    RemoveBlip(crewBlipsFar[identifier])
                                                    crewBlipsFar[identifier] = nil
                                                end
                
                                                local crewBlip = AddBlipForEntity(playerPed)
                                                utils.setBlip(crewBlip)
                                                SetBlipShowCone(crewBlip, true)
                                                crewBlipsNear[identifier] = crewBlip
                                                
                                                local blipId = ('CREW_BLIP_%s'):format(blipPlayer)
                                                DisplayPlayerNameTagsOnBlips(true)
                                                AddTextEntry(blipId, name)
                                                BeginTextCommandSetBlipName(blipId)
                                                EndTextCommandSetBlipName(crewBlip)
                                            end
                                        else
                                            if crewBlipsFar[targetIdentifier] then
                                                if DoesBlipExist(crewBlipsFar[targetIdentifier]) then
                                                    local crewBlip = crewBlipsFar[targetIdentifier]
                                                    SetBlipCoords(crewBlip, coords.xyz)
                                                end
                                            else
                                                if crewBlipsNear[targetIdentifier] then
                                                    RemoveBlip(crewBlipsNear[targetIdentifier])
                                                    crewBlipsNear[targetIdentifier] = nil
                                                end
                
                                                local crewBlip = AddBlipForCoord(coords.xyz)
                                                utils.setBlip(crewBlip)
                                                crewBlipsFar[targetIdentifier] = crewBlip
                                                
                                                DisplayPlayerNameTagsOnBlips(true)
                                                AddTextEntry(('CREW_BLIP_%s'):format(blipPlayer), name)
                                                BeginTextCommandSetBlipName(('CREW_BLIP_%s'):format(blipPlayer))
                                                EndTextCommandSetBlipName(crewBlip)
                                            end
                                        end
                                    end
            
                                    if CONFIG.ENABLE_TAGS then
                                        if settings.showTags then
                                            local currentTag = nil

                                            if CONFIG.MAX_TAG_DISTANCE then
                                                if #(GetEntityCoords(cache.ped) - coords) < CONFIG.MAX_TAG_DISTANCE then
                                                    currentTag = utils.createTag(playerPed, name)
                                                else
                                                    utils.deleteTag(identifier)
                                                end
                                            else
                                                currentTag = utils.createTag(playerPed, name)
                                            end
                                            currentTags[identifier] = currentTag
                                        else
                                            utils.deleteTag(identifier)
                                        end
                                    end
                                end
                            end
                            ::continue::
                        end
                    end
                end
            else
                utils.deleteTag()
                utils.deleteBlip()
            end
        end
    end)
end

AddTextEntry("BLIP_OTHPLYR", 'CREW')

----------------------------------------------------------------

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

exports('getCrewOwner', function()
    if crew and crew.owner then
        return crew.owner
    end

    return nil
end)

exports('getCrewName', function()
    if crew and crew.label then
        return crew.label
    end

    return nil
end)

exports('getCrewTag', function()
    if crew and crew.tag then
        return crew.tag
    end

    return nil
end)

exports('getPlayerRank', function()
    if crew and crew.data[myIdentifier] then
        return shared.getRankLabel(crew.data[myIdentifier].Rank)
    end

    return nil
end)