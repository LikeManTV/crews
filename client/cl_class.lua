util = {
    deleteBlip = function(identifier)
        if identifier then
            if crewBlipsNear[identifier] then
                RemoveBlip(crewBlipsNear[identifier])
                crewBlipsNear[identifier] = nil
            end
            if crewBlipsFar[identifier] then
                RemoveBlip(crewBlipsFar[identifier])
                crewBlipsFar[identifier] = nil
            end
        else
            for player, blip in pairs(crewBlipsNear) do
                RemoveBlip(blip)
                crewBlipsNear[player] = nil
            end
            for player, blip in pairs(crewBlipsFar) do
                RemoveBlip(blip)
                crewBlipsFar[player] = nil
            end
        end
    end,

    deleteTag = function(identifier)
        if identifier then
            if crewTags[identifier] then
                RemoveMpGamerTag(crewTags[identifier])
                crewTags[identifier] = nil
            end
        else
            if crewTags then
                for player, tag in pairs(crewTags) do
                    util.deleteTag(player)
                end
            end
        end
    end
}

crewMenu = {
    openMainMenu = function()
        local elements = {}
        if crew then
            table.insert(elements,{
                title = crew.label,
                description = _L('main_menu_desc', {crew.tag, getMemberCount()}),
                onSelect = function()
                    lib.hideContext(onExit)
                    crewMenu.openMemberList()
                end,
                arrow = true
            })
    
            if crew.owner == myIdentifier then
                table.insert(elements,{
                    icon = "user-plus",
                    title = _L('main_menu_invite_title'),
                    onSelect = function()
                        lib.hideContext(onExit)
                        crewMenu.openPlayerList()
                    end,
                    description = _L('main_menu_invite_desc')
                })
                table.insert(elements,{
                    icon = "users",
                    title = _L('main_menu_manage_title'),
                    onSelect = function()
                        lib.hideContext(onExit)
                        crewMenu.openPlayerManagement()
                    end,
                    description = _L('main_menu_manage_desc')
                })
                table.insert(elements,{
                    icon = "trash",
                    title = _L('main_menu_delete_title'),
                    onSelect = function()
                        local alert = lib.alertDialog({
                            header = _L('delete_confirmation_title'),
                            content = _L('delete_confirmation_desc'),
                            centered = true,
                            cancel = true
                        })
                        if alert == 'confirm' then
                            TriggerServerEvent('crews:deleteCrew')
                        end
                        lib.hideContext(onExit)
                    end,
                    description = _L('main_menu_delete_desc')
                })
                table.insert(elements,{
                    icon = "gear",
                    title = _L('main_menu_settings_title'),
                    onSelect = function()
                        lib.hideContext(onExit)
                        crewMenu.openSettings()
                    end,
                    description = _L('main_menu_settings_desc')
                })
            else
                table.insert(elements,{
                    icon = "delete-left",
                    title = _L('main_menu_leave_title'),
                    onSelect = function()
                        TriggerServerEvent('crews:leaveCrew')
                        lib.hideContext(onExit)
                    end,
                    description = _L('main_menu_leave_desc')
                })
            end
        else
            table.insert(elements,{
                icon = "list",
                title = _L('main_menu_invites_title'),
                onSelect = function()
                    lib.hideContext(onExit)
                    crewMenu.openInvitesList()
                end,
                description = _L('main_menu_invites_desc')
            })
            table.insert(elements,{
                icon = "plus",
                title = _L('main_menu_create_title'),
                onSelect = function()
                    local input = lib.inputDialog(_L('main_menu_create_title'), {'Enter name..', 'Enter tag.. (4 chars.)'})
                    local label = nil
                    if not input then return end
                    if not input[1] then label = false else label = input[1] end
                    if not input[2] then return end
                    local tag = string.sub(input[2], 1, 4)
                    if #crewNames > 0 then
                        for _, name in pairs(crewNames) do
                            if name:lower():find(input[1]:lower()..' crew') then
                                notify(_L('error_name_used'), 'error')
                                return
                            end
                        end
                    end
                    if #crewTags > 0 then
                        for _, name in pairs(crewTags) do
                            if name:lower():find(tag:lower()) then
                                notify(_L('error_tag_used'), 'error')
                                return
                            end
                        end
                    end
    
                    TriggerServerEvent('crews:createCrew', label, tag:upper())
                    lib.hideContext(onExit)
                end,
                description = _L('main_menu_create_desc')
            })
        end
        lib.registerContext({
            id = 'crew_menu',
            title = _L('main_menu_title'),
            options = elements
        })
        lib.showContext('crew_menu')
    end,

    openInvitesList = function()
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
                    description = _L('invites_btn_desc')
                })
            end

            lib.registerContext({
                id = 'crew_menu-invites',
                title = _L('invites_title'),
                menu = 'crew_menu',
                options = elements
            })
            lib.showContext('crew_menu-invites')
        else
            notify(_L('error_no_invites'), 'error')
        end
    end,

    -- TODO: Make ranks actually useful.
    openMemberList = function()
        local elements = {}
        if crew then
            for k,v in pairs(crew.data) do
                if k ~= myIdentifier then
                    table.insert(elements,{
                        icon = "user",
                        title = v,
                        description = "Rank: Member" -- WIP
                    })
                else
                    table.insert(elements,{
                        icon = "crown",
                        title = _L('member_list_owner_title', {v}),
                        description = "Rank: Owner" -- WIP
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
                title = _L('member_list_title'),
                menu = 'crew_menu',
                options = elements
            })
            lib.showContext('crew_menu-members')
        end
    end,

    openPlayerManagement = function()
        local elements = {}
        if crew then
            for k,v in pairs(crew.data) do
                if k then
                    if k ~= myIdentifier then
                        table.insert(elements,{
                            icon = "hand",
                            title = v,
                            description = _L('manage_btn_desc'),
                            arrow = true,
                            onSelect = function()
                                lib.hideContext(onExit)
                                crewMenu.openMemberSettings(k, v)
                            end
                        })
                    end
                else
                    table.insert(elements,{
                        icon = "face-frown",
                        title = _L('manage_no_players')
                    })
                end
            end
            
            lib.registerContext({
                id = 'crew_menu-manage',
                title = _L('manage_title'),
                menu = 'crew_menu',
                options = elements
            })
            lib.showContext('crew_menu-manage')
        end
    end,

    -- TODO: Make ranks actually useful.
    openMemberSettings = function(identifier, name)
        local elements = {}
        if crew and crew.data then
            if identifier ~= myIdentifier then
                -- table.insert(elements,{
                --     icon = "ranking-star",
                --     title = "CHANGE RANK",
                --     description = "Rank: Member",
                --     arrow = true,
                --     onSelect = function()
                --         lib.hideContext(onExit)
                --         local input = lib.inputDialog('CHANGE RANK', {
                --             {
                --                 type = 'select',
                --                 label = 'Select a rank',
                --                 options = {
                --                     {value = 'owner', label = 'Owner'},
                --                     {value = 'officer', label = 'Officer'},
                --                     {value = 'member', label = 'Member'},
                --                 },
                --                 default = 'member',
                --                 icon = "ranking-star",
                --                 required = true
                --             },
                --         })
                --         if not input then return end
    
                --         -- print(input[1])
                --         if input[1] == 'owner' then
                --             local alert = lib.alertDialog({
                --                 header = 'TRANSFER OWNERSHIP',
                --                 content = ('Are you sure that want to transfer the crew ownership to %s?'):format(name),
                --                 centered = true,
                --                 cancel = true
                --             })
                --             if alert == 'confirm' then
                --                 notify(('Crew was successfuly transfered to %s!'):format(name), 'success')
                --             end
                --         elseif input[1] == 'officer' then
                --             local alert = lib.alertDialog({
                --                 header = 'CHANGE RANK',
                --                 content = ('Are you sure that want to give an officer rank to %s?'):format(name),
                --                 centered = true,
                --                 cancel = true
                --             })
                --             if alert == 'confirm' then
                --                 notify(('Successfuly promoted %s to Officer!'):format(name), 'success')
                --             end
                --         end
                --     end
                -- })

                table.insert(elements,{
                    icon = "hand",
                    title = _L('member_kick_title'),
                    onSelect = function()
                        lib.hideContext(onExit)
                        local alert = lib.alertDialog({
                            header = _L('member_kick_confirmation_title'),
                            content = _L('member_kick_confirmation_desc', {name}),
                            centered = true,
                            cancel = true
                        })
                        if alert == 'confirm' then
                            TriggerServerEvent('crews:removeFromCrew', identifier)
                            notify(_L('member_kick_success'), 'success')
                        end
                    end,
                    description = _L('member_kick_desc')
                })
            end
    
            lib.registerContext({
                id = 'crew_menu-member',
                title = _L('member_title', {name}),
                menu = 'crew_menu-manage',
                options = elements
            })
            lib.showContext('crew_menu-member')
        end
    end,

    openPlayerList = function()
        local elements = {}
        if crew then
            local players = GetActivePlayers()
            local player = PlayerId()
            local myCoords = GetEntityCoords(PlayerPedId())

            for k,v in ipairs(players) do
                if player ~= v then
                    local entCoords = GetEntityCoords(GetPlayerPed(v))
                    if #(myCoords - entCoords) < CONFIG.CREW_SETTINGS.MAX_INVITE_DISTANCE then
                        table.insert(elements,{
                            icon = "plus",
                            title = GetPlayerName(v),
                            onSelect = function()
                                TriggerServerEvent('crews:addToCrew', GetPlayerServerId(v))
                                lib.hideContext(onExit)
                            end,
                            description = _L('invite_btn_desc')
                        })
                    end
                end
            end
    
            if #elements > 0 then
                lib.registerContext({
                    id = 'crew_menu-list',
                    title = _L('invite_title'),
                    menu = 'crew_menu',
                    options = elements
                })
                lib.showContext('crew_menu-list')
            else
                notify(_L('error_nobody_around'), 'error')
            end
        end
    end,

    openSettings = function()
        local elements = {}
        if crew then
            table.insert(elements,{
                icon = "pencil",
                title = _L('settings_btn_rename_title'),
                onSelect = function()
                    local input = lib.inputDialog(_L('settings_btn_rename_title'), {_L('create_name_desc')})
                    local label = nil
                    if not input then return end
                    if not input[1] then label = false else label = input[1] end
                    if #crewNames > 0 then
                        for _, name in pairs(crewNames) do
                            if name:lower():find(input[1]:lower()..' crew') then
                                notify(_L('error_name_used'), 'error')
                                return
                            end
                        end
                    end
    
                    TriggerServerEvent('crews:rename', label)
                end,
                description = _L('settings_btn_rename_desc')
            })
            table.insert(elements,{
                icon = "pencil",
                title = _L('settings_btn_tag_title'),
                onSelect = function()
                    local input = lib.inputDialog(_L('settings_btn_tag_title'), {_L('create_tag_desc')})
                    if not input then return end
                    local tag = string.sub(input[1], 1, 4)
                    if #crewTags > 0 then
                        for _, name in pairs(crewTags) do
                            if type(name) == 'string' then
                                if name:lower():find(tag:lower()) then
                                    notify(_L('error_tag_used'), 'error')
                                    return
                                end
                            end
                        end
                    end
    
                    TriggerServerEvent('crews:newTag', tag:upper())
                end,
                description = _L('settings_btn_rename_desc')
            })
            -- table.insert(elements,{
            --     icon = "gun",
            --     title = "PVP",
            --     disabled = true,
            --     description = "Click to toggle PVP for crew members."
            -- })
    
            lib.registerContext({
                id = 'crew_menu-settings',
                title = _L('settings_title'),
                menu = 'crew_menu',
                options = elements
            })
            lib.showContext('crew_menu-settings')
        end
    end,
}