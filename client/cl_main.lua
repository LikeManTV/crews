local crew, invites = nil, nil
local identifier = nil
local crewNames, crewTags = nil, nil
local crewBlipsNear, crewBlipsLong = {}, {}
local showTags, pvp = true, false

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    TriggerServerEvent('crews:getCrew')
    identifier = ESX.PlayerData.identifier
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded',function(xPlayer, isNew, skin)
    TriggerServerEvent('crews:getCrew')
    identifier = ESX.PlayerData.identifier
end)

RegisterNetEvent('crews:setCrew', function(newCrew)
    crew = newCrew
end)

RegisterNetEvent('crews:setInvites', function(invites)
    invites = invites
end)

RegisterNetEvent('crews:setNames', function(names)
    crewNames = names
end)

RegisterNetEvent('crews:setTags', function(tags)
    crewTags = tags
end)

RegisterNetEvent('crews:removeBlip', function(id)
    if crew then
        for k,v in pairs(crew.data) do
            if k == id then
                deleteBlip(id)
            end
        end
    end
end)

local function openMemberSettings(ident, name)
    local elements = {}
    if crew and crew.data then
        if ident ~= identifier then
            table.insert(elements,{
                icon = "ranking-star",
                title = "CHANGE RANK",
                description = "Rank: Member",
                arrow = true,
                onSelect = function()
                    lib.hideContext(onExit)
                    local input = lib.inputDialog('CHANGE RANK', {
                        {
                            type = 'select',
                            label = 'Select a rank',
                            options = {
                                {value = 'owner', label = 'Owner'},
                                {value = 'officer', label = 'Officer'},
                                {value = 'member', label = 'Member'},
                            },
                            default = 'member',
                            icon = "ranking-star",
                            required = true
                        },
                    })
                    if not input then return end

                    print(input[1])
                    if input[1] == 'owner' then
                        local alert = lib.alertDialog({
                            header = 'TRANSFER OWNERSHIP',
                            content = ('Are you sure that want to transfer the crew ownership to %s?'):format(name),
                            centered = true,
                            cancel = true
                        })
                        if alert == 'confirm' then
                            lib.notify({title = 'CREW', description = ('Crew was successfuly transfered to %s!'):format(name), type = 'success'})
                        end
                    elseif input[1] == 'officer' then
                        local alert = lib.alertDialog({
                            header = 'CHANGE RANK',
                            content = ('Are you sure that want to give an officer rank to %s?'):format(name),
                            centered = true,
                            cancel = true
                        })
                        if alert == 'confirm' then
                            lib.notify({title = 'CREW', description = ('Successfuly promoted %s to Officer!'):format(name), type = 'success'})
                        end
                    end
                end
            })
            table.insert(elements,{
                icon = "hand",
                title = "KICK",
                onSelect = function()
                    lib.hideContext(onExit)
                    local alert = lib.alertDialog({
                        header = 'KICK PLAYER',
                        content = ('Are you sure that you want to kick %s?'):format(name),
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then
                        TriggerServerEvent('crews:removeFromCrew', ident)
                        lib.notify({title = 'CREW', description = 'Player was successfuly kicked!', type = 'success'})
                    end
                end,
                description = "Click to kick this player."
            })
        end

        lib.registerContext({
            id = 'crew_menu-member',
            title = ('MEMBERS > %s'):format(name),
            menu = 'crew_menu-manage',
            options = elements
        })
        lib.showContext('crew_menu-member')
    end
end

local function openPlayerManagement()
    local elements = {}
    if crew then
        for k,v in pairs(crew.data) do
            if k then
                if k ~= identifier then
                    table.insert(elements,{
                        icon = "hand",
                        title = v,
                        description = "Click to manage this player.",
                        arrow = true,
                        onSelect = function()
                            lib.hideContext(onExit)
                            openMemberSettings(k, v)
                        end
                    })
                end
            else
                table.insert(elements,{
                    icon = "face-frown",
                    title = "There is nobody to manage."
                })
            end
        end
        
        lib.registerContext({
            id = 'crew_menu-manage',
            title = 'CREW > MANAGMENT',
            menu = 'crew_menu',
            options = elements
        })
        lib.showContext('crew_menu-manage')
    end
end

local function openPlayerList()
    local elements = {}
    if crew then
        local players = GetActivePlayers()
        local player = PlayerId()

        local myCoords = GetEntityCoords(cache.ped)
        for k,v in ipairs(players) do
            if player ~= v then
                local entCoords = GetEntityCoords(GetPlayerPed(v))
                if #(myCoords - entCoords) < 5.0 then
                    table.insert(elements,{
                        icon = "plus",
                        title = GetPlayerName(v),
                        onSelect = function()
                            TriggerServerEvent('crews:addToCrew', GetPlayerServerId(v))
                            lib.hideContext(onExit)
                        end,
                        description = "Click to invite."
                    })
                end
            end
        end

        if #elements > 0 then
            lib.registerContext({
                id = 'crew_menu-list',
                title = 'CREW > INVITE',
                menu = 'crew_menu',
                options = elements
            })
            lib.showContext('crew_menu-list')
        else
            lib.notify({title = 'CREW', description = 'There are no players around!', type = 'error'})
        end
    end
end

local function openInvitesList()
    local elements = {}
    if not crew and invites then
        for k,v in pairs(invites) do
            table.insert(elements,{
                icon = "hand",
                title = v,
                onSelect = function()
                    TriggerServerEvent('crews:acceptCrew', k)
                    lib.hideContext(onExit)
                end,
                description = "Click to accept."
            })
        end

        lib.registerContext({
            id = 'crew_menu-invites',
            title = 'CREW > INVITES',
            menu = 'crew_menu',
            options = elements
        })
        lib.showContext('crew_menu-invites')
    else
        lib.notify({title = 'CREW', description = "You don't have any invites!", type = 'error'})
    end
end

local function openSettings()
    local elements = {}
    if crew then
        table.insert(elements,{
            icon = "pencil",
            title = "RENAME",
            onSelect = function()
                local input = lib.inputDialog('RENAME', {'Type here..'})
                local label = nil
                if not input then return end
                if not input[1] then label = false else label = input[1] end
                if crewNames then
                    for _, name in pairs(crewNames) do
                        if name:lower():find(input[1]:lower()..' crew') then
                            lib.notify({title = 'CREW', description = 'This name is already used..', type = 'error'})
                            return
                        end
                    end
                end

                TriggerServerEvent('crews:rename', label)
            end,
            description = "Click to change crew name."
        })
        table.insert(elements,{
            icon = "pencil",
            title = "CHANGE TAG",
            onSelect = function()
                local input = lib.inputDialog('CHANGE TAG', {'Type here (4 chars.)..'})
                if not input then return end
                local tag = string.sub(input[1], 1, 4)
                if crewTags then
                    for _, name in pairs(crewTags) do
                        if name:lower():find(tag:lower()) then
                            lib.notify({title = 'CREW', description = 'This tag is already used..', type = 'error'})
                            return
                        end
                    end
                end

                TriggerServerEvent('crews:newTag', tag:upper())
            end,
            description = "Click to change crew tag."
        })
        table.insert(elements,{
            icon = "gun",
            title = "PVP",
            disabled = true,
            description = "Click to toggle PVP for crew members."
        })

        lib.registerContext({
            id = 'crew_menu-settings',
            title = 'CREW > SETTINGS',
            menu = 'crew_menu',
            options = elements
        })
        lib.showContext('crew_menu-settings')
    end
end

local function openMemberList()
    local elements = {}
    if crew then
        for k,v in pairs(crew.data) do
            if k ~= identifier then
                table.insert(elements,{
                    icon = "user",
                    title = v,
                    description = "Rank: Member"
                })
            else
                table.insert(elements,{
                    icon = "crown",
                    title = v .. " (You)",
                    description = "Rank: Owner"
                })
            end
        end

        local function compareByWord(a, b, word)
            local wordA = a.description:match(word)
            local wordB = b.description:match(word)
        
            return (wordA or "") < (wordB or "")
        end

        table.sort(elements, function(a, b)
            return compareByWord(a, b, 'Owner')
        end)

        lib.registerContext({
            id = 'crew_menu-members',
            title = 'CREW > MEMBERS',
            menu = 'crew_menu',
            options = elements
        })
        lib.showContext('crew_menu-members')
    end
end

local function openCrewMenu()
    local elements = {}
    if crew then
        table.insert(elements,{
            title = crew.label,
            description = ('Tag: [%s]\n Members: %s'):format(crew.tag, getMemberCount()),
            onSelect = function()
                lib.hideContext(onExit)
                openMemberList()
            end,
            arrow = true
        })

        if crew.owner == identifier then
            table.insert(elements,{
                icon = "user-plus",
                title = "INVITE PLAYERS",
                onSelect = function()
                    lib.hideContext(onExit)
                    openPlayerList()
                end,
                description = "Click to invite players."
            })
            table.insert(elements,{
                icon = "users",
                title = "MANAGE PLAYERS",
                onSelect = function()
                    lib.hideContext(onExit)
                    openPlayerManagement()
                end,
                description = "Click to open player management."
            })
            table.insert(elements,{
                icon = "trash",
                title = "DELETE CREW",
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'DELETE CREW',
                        content = 'Are you sure that you want to delete this crew?',
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then
                        TriggerServerEvent('crews:deleteCrew')
                    end
                    lib.hideContext(onExit)
                end,
                description = "Click to delete crew."
            })
            table.insert(elements,{
                icon = "gear",
                title = "SETTINGS",
                onSelect = function()
                    lib.hideContext(onExit)
                    openSettings()
                end,
                description = "Click to open crew settings."
            })
        else
            table.insert(elements,{
                icon = "delete-left",
                title = "LEAVE",
                onSelect = function()
                    TriggerServerEvent('crews:leaveCrew')
                    lib.hideContext(onExit)
                end,
                description = "Click to leave the crew."
            })
        end
    else
        table.insert(elements,{
            icon = "list",
            title = "OPEN INVITES",
            onSelect = function()
                lib.hideContext(onExit)
                openInvitesList()
            end,
            description = "Click to show your invites."
        })
        table.insert(elements,{
            icon = "plus",
            title = "CREATE CREW",
            onSelect = function()
                local input = lib.inputDialog('CREATE CREW', {'Enter name..', 'Enter tag.. (4 chars.)'})
                local label = nil
                if not input then return end
                if not input[1] then label = false else label = input[1] end
                if not input[2] then return end
                local tag = string.sub(input[2], 1, 4)
                if crewNames then
                    for _, name in pairs(crewNames) do
                        if name:lower():find(input[1]:lower()..' crew') then
                            lib.notify({title = 'CREW', description = 'This name is already used..', type = 'error'})
                            return
                        end
                    end
                end
                if crewTags then
                    for _, name in pairs(crewTags) do
                        if name:lower():find(tag:lower()) then
                            lib.notify({title = 'CREW', description = 'This tag is already used..', type = 'error'})
                            return
                        end
                    end
                end

                TriggerServerEvent('crews:createCrew', label, tag:upper())
                lib.hideContext(onExit)
            end,
            description = "Click to create a crew."
        })
    end
    lib.registerContext({
        id = 'crew_menu',
        title = 'CREW MENU',
        options = elements
    })
    lib.showContext('crew_menu')
end

AddEventHandler('crews:openMenu', function()
    openCrewMenu()
end)

if Config.Command then
    RegisterCommand(Config.Command, function()
        openCrewMenu()
    end)
    RegisterKeyMapping(Config.Command, 'Open crew menu', 'keyboard', Config.OpenKey)
end

-- Blips & Tags
CreateThread(function()
    while true do
        Wait(1000)
        if crew then
            for k,v in pairs(crew.data) do
                local players = lib.callback.await('crews:blipUpdate', false)
                for index, obj in pairs(players) do
                    local blipPlayer = obj[1]
                    local playerPed = NetworkDoesEntityExistWithNetworkId(obj[2]) and NetworkGetEntityFromNetworkId(obj[2]) or nil
                    local ident = obj[3]
                    local name = obj[4]
                    local coords = obj[5]
                    if name ~= GetPlayerName(GetPlayerIndex()) then
                        if k == ident then
                            if #(coords.xyz - GetEntityCoords(cache.ped).xyz) < 100.0 then
                                if crewBlipsNear[k] == nil then
                                    if crewBlipsLong[k] then
                                        RemoveBlip(crewBlipsLong[k])
                                        crewBlipsLong[k] = nil
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
                                if crewBlipsLong[k] == nil then
                                    if crewBlipsNear[k] then
                                        RemoveBlip(crewBlipsNear[k])
                                        crewBlipsNear[k] = nil
                                    end

                                    if crewBlipsLong[k] and DoesBlipExist(crewBlipsLong[k]) then
                                        local blip = crewBlipsLong[k]
                                        SetBlipCoords(blip, coords.xyz)
                                    else
                                        local blip = AddBlipForCoord(coords.xyz)
                                        SetBlipDisplay(blip, 2)
                                        SetBlipSprite(blip, 1)
                                        SetBlipColour(blip, 2)
                                        SetBlipScale(blip, 0.7)
                                        SetBlipCategory(blip, 7)
                                        crewBlipsLong[k] = blip
                                        
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
                                DeleteTag(k)
                            end
                        end
                    end
                end
            end
        end
    end
end)
AddTextEntry("BLIP_OTHPLYR", 'CREW')

RegisterNetEvent('crews:removePlayer', function(owner, ident)
    if crew then
        if crew.owner == owner then
            deleteBlip(ident)
            deleteTag(ident)
        end
    end
end)

RegisterNetEvent('crews:playerLeft', function(owner)
    if crew then
        if crew.owner == owner then
            deleteBlips()
            deleteTags()
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        deleteBlips()
        deleteTags()
        DisplayPlayerNameTagsOnBlips(false)
    end
end)

RegisterCommand('crewTags', function()
    tags = not tags
end)

function deleteBlip(id)
    if crewBlipsNear[id] then
        RemoveBlip(crewBlipsNear[id])
        crewBlipsNear[id] = nil
    end
    if crewBlipsLong[id] then
        RemoveBlip(crewBlipsLong[id])
        crewBlipsLong[id] = nil
    end
end
function deleteBlips()
    for player, blip in pairs(crewBlipsNear) do
        RemoveBlip(blip)
        crewBlipsNear[player] = nil
    end
    for player, blip in pairs(crewBlipsLong) do
        RemoveBlip(blip)
        crewBlipsLong[player] = nil
    end
end

function deleteTag(id)
    if crewTags[id] then
        RemoveMpGamerTag(crewTags[id])
        crewTags[id] = nil
    end
end
function deleteTags()
    if crewTags then
        for player, tag in pairs(crewTags) do
            deleteTag(player)
        end
    end
end

function getMemberCount()
    if crew then
        local count = 0
        for _ in pairs(crew.data) do
            count = count + 1
        end

        return count
    end
end

exports('ownsCrew', function()
    if crew.owner == ident then
        return true
    end

    return false
end)

exports('isInCrew', function()
    if crew then
        if crew.data[ident] then
            return true
        end
    end

    return false
end)

exports('getCrew', function()
    if crew then
        return crew
    end

    return {}
end)