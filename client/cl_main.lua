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
                            repeat Wait(0) until DoesEntityExist(playerPed)
                            if identifier == targetIdentifier then
                                if targetIdentifier ~= myIdentifier then
                                    if #(GetEntityCoords(cache.ped) - coords) < 100.0 then
                                        if crewBlipsNear[identifier] == nil then
                                            if crewBlipsFar[identifier] then
                                                RemoveBlip(crewBlipsFar[identifier])
                                                crewBlipsFar[identifier] = nil
                                            end
            
                                            local blip = AddBlipForEntity(playerPed)
                                            SetBlipDisplay(blip, 2)
                                            SetBlipSprite(blip, 1)
                                            SetBlipColour(blip, 2)
                                            SetBlipScale(blip, 0.7)
                                            SetBlipCategory(blip, 7)
                                            SetBlipShowCone(blip, true)
                                            crewBlipsNear[identifier] = blip
                                            
                                            DisplayPlayerNameTagsOnBlips(true)
                                            AddTextEntry(('CREW_BLIP_%s'):format(blipPlayer), name)
                                            BeginTextCommandSetBlipName(('CREW_BLIP_%s'):format(blipPlayer))
                                            EndTextCommandSetBlipName(blip)
                                        end
                                    else
                                        if crewBlipsFar[identifier] == nil then
                                            if crewBlipsNear[identifier] then
                                                RemoveBlip(crewBlipsNear[identifier])
                                                crewBlipsNear[identifier] = nil
                                            end
            
                                            if crewBlipsFar[identifier] and DoesBlipExist(crewBlipsFar[identifier]) then
                                                local blip = crewBlipsFar[identifier]
                                                SetBlipCoords(blip, coords.xyz)
                                            else
                                                local blip = AddBlipForCoord(coords.xyz)
                                                SetBlipDisplay(blip, 2)
                                                SetBlipSprite(blip, 1)
                                                SetBlipColour(blip, 2)
                                                SetBlipScale(blip, 0.7)
                                                SetBlipCategory(blip, 7)
                                                crewBlipsFar[identifier] = blip
                                                
                                                DisplayPlayerNameTagsOnBlips(true)
                                                AddTextEntry(('CREW_BLIP_%s'):format(blipPlayer), name)
                                                BeginTextCommandSetBlipName(('CREW_BLIP_%s'):format(blipPlayer))
                                                EndTextCommandSetBlipName(blip)
                                            end
                                        end
                                    end
            
                                    if settings.showTags then
                                        local currentTag = CreateFakeMpGamerTag(playerPed, ('[%s] %s'):format((crew and crew.tag or 'nil'), name), false, false, "", 0, 0, 0, 0)
                                        SetMpGamerTagColour(currentTag, 0, 18)
                                        SetMpGamerTagVisibility(currentTag, 2, 1)
                                        SetMpGamerTagAlpha(currentTag, 2, 255)
                                        SetMpGamerTagHealthBarColor(currentTag, 129)
                                        currentTags[identifier] = currentTag
                                    else
                                        utils.deleteTag(identifier)
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
        return crew.data[myIdentifier].Rank
    end

    return nil
end)