crewMenu = {
    openMainMenu = function()
        local elements = {}
        if crew then
            table.insert(elements, {
                title = crew.label,
                description = _L('main_menu_desc', {crew.tag, utils.getMemberCount()}),
                arrow = true,
                onSelect = function()
                    lib.hideContext(onExit)
                    crewMenu.openMemberList()
                end
            })

            if utils.hasPermission(crew.data[myIdentifier].Rank, 'invite') then
                table.insert(elements, {
                    icon = "user-plus",
                    title = _L('main_menu_invite_title'),
                    description = _L('main_menu_invite_desc'),
                    onSelect = function()
                        lib.hideContext(onExit)
                        crewMenu.openPlayerList()
                    end
                })
            end

            if utils.hasPermission(crew.data[myIdentifier].Rank, 'kick') or utils.hasPermission(crew.data[myIdentifier].Rank, 'changeRank') then
                table.insert(elements, {
                    icon = "users",
                    title = _L('main_menu_manage_title'),
                    description = _L('main_menu_manage_desc'),
                    onSelect = function()
                        lib.hideContext(onExit)
                        crewMenu.openPlayerManagement()
                    end
                })
            end
            if utils.hasPermission(crew.data[myIdentifier].Rank, 'changeName') or utils.hasPermission(crew.data[myIdentifier].Rank, 'changeTag') then
                table.insert(elements, {
                    icon = "gear",
                    title = _L('main_menu_settings_title'),
                    description = _L('main_menu_settings_desc'),
                    onSelect = function()
                        lib.hideContext(onExit)
                        crewMenu.openSettings()
                    end
                })
            end

            if crew.owner == myIdentifier then
                table.insert(elements, {
                    icon = "trash",
                    title = _L('main_menu_delete_title'),
                    description = _L('main_menu_delete_desc'),
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
                    end
                })
            end

            if crew.owner ~= myIdentifier then
                table.insert(elements, {
                    icon = "delete-left",
                    title = _L('main_menu_leave_title'),
                    description = _L('main_menu_leave_desc'),
                    onSelect = function()
                        local alert = lib.alertDialog({
                            header = _L('leave_confirmation_title'),
                            content = _L('leave_confirmation_desc'),
                            centered = true,
                            cancel = true
                        })
                        if alert == 'confirm' then
                            TriggerServerEvent('crews:leaveCrew')
                        end
                        lib.hideContext(onExit)
                    end
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
                    local input = lib.inputDialog(_L('main_menu_create_title'), {_L('create_name_desc'), _L('create_tag_desc')})
                    local label = nil
                    if not input then return end
                    if not input[1] then label = false else label = input[1] end
                    if not input[2] then return end
                    local tag = string.sub(input[2], 1, 4)
                    if #crewNames > 0 then
                        for _, name in pairs(crewNames) do
                            if name:lower():find(input[1]:lower()..' crew') then
                                return notify(_L('error_name_used'), 'error')
                            end
                        end
                    end
                    if #crewTags > 0 then
                        for _, name in pairs(crewTags) do
                            if name:lower():find(tag:lower()) then
                                return notify(_L('error_tag_used'), 'error')
                            end
                        end
                    end

                    if #tag < 4 then
                        return notify(_L('error_tag_invalid'), 'error')
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
                        TriggerServerEvent('crews:joinCrew', k)
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

    openMemberList = function()
        local elements = {}
        if crew then
            for k,v in pairs(crew.data) do
                local rankIndex = utils.getRankIndex(crew.data[k].Rank)
                if crew.data[k].Rank == 'owner' then
                    table.insert(elements, {
                        index = 0,
                        icon = "crown",
                        title = v.Name,
                        description = _L('member_rank_desc', {_L('member_rank_owner')})
                    })
                elseif rankIndex and CONFIG.RANKS[rankIndex] then
                    table.insert(elements, {
                        index = rankIndex,
                        icon = "user",
                        title = v.Name,
                        description = _L('member_rank_desc', {CONFIG.RANKS[rankIndex].label})
                    })
                else
                    table.insert(elements, {
                        index = 999,
                        icon = "user",
                        title = v.Name,
                        description = _L('member_rank_desc', {_L('member_rank_member')})
                    })
                end
            end
    
            local function compareByWord(a, b)
                local numberA = a.index == 0
                local numberB = b.index == 0

                return numberA and a.index > b.index or numberB and b.index > a.index
            end
    
            table.sort(elements, function(a, b)
                return compareByWord(a, b)
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
                if k and k ~= myIdentifier then
                    local memberRank = utils.getRankIndex(v.Rank)
                    local myRank = utils.getRankIndex(crew.data[myIdentifier].Rank)
                    if memberRank > myRank then
                        local rankLabel = utils.getRankLabel(v.Rank)
                        table.insert(elements, {
                            icon = "hand",
                            title = v.Name,
                            description = _L('member_rank_desc', {rankLabel}) .. '\n' .. _L('manage_btn_desc'),
                            arrow = true,
                            onSelect = function()
                                lib.hideContext(onExit)
                                crewMenu.openMemberSettings(k, v)
                            end
                        })
                    end
                end
            end

            if #elements <= 0 then
                table.insert(elements,{
                    icon = "face-frown",
                    title = _L('manage_no_players')
                })
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

    openMemberSettings = function(identifier, data)
        local myRank = crew.data[myIdentifier]
        local elements = {}
        if crew and crew.data then
            if identifier ~= myIdentifier then
                local ranks = {}

                for i=1, #CONFIG.RANKS do
                    local rankData = CONFIG.RANKS[i]

                    if rankData.name ~= data.Rank then
                        ranks[#ranks+1] = {
                            value = rankData.name, label = rankData.label,
                        }
                    end
                end

                if data.Rank ~= 'member' then
                    ranks[#ranks+1] = {
                        value = 'member', label = _L('member_rank_member'),
                    }
                end

                local rankLabel = utils.getRankLabel(data.Rank)
                if utils.hasPermission(myRank.Rank, 'changeRank') then
                    table.insert(elements, {
                        icon = "ranking-star",
                        title = _L('member_rank_title'),
                        description = _L('member_rank_desc', {rankLabel}),
                        arrow = true,
                        onSelect = function()
                            lib.hideContext(onExit)
                            local input = lib.inputDialog(_L('member_rank_title'), {
                                {
                                    type = 'select',
                                    label = _L('member_rank_input_title'),
                                    options = ranks,
                                    default = 'member',
                                    icon = "ranking-star",
                                    required = true
                                },
                            })
                            if not input then return end
        
                            local rankIndex = utils.getRankIndex(input[1])
                            local rankData = nil

                            if rankIndex == 0 then
                                rankData = {
                                    name = 'owner',
                                    label = _L('member_rank_owner')
                                }
                            elseif CONFIG.RANKS[rankIndex] then
                                rankData = CONFIG.RANKS[rankIndex]
                            else
                                rankData = {
                                    name = 'member',
                                    label = _L('member_rank_member')
                                }
                            end

                            local alert = lib.alertDialog({
                                header = _L('member_rank_confirmation_title'),
                                content = _L('member_rank_confirmation_desc', {data.Name, rankData.label}),
                                centered = true,
                                cancel = true
                            })
                            if alert == 'confirm' then
                                TriggerServerEvent('crews:changeRank', identifier, rankData)
                                notify(_L('member_rank_success', {data.Name, rankData.label}), 'success')
                            end
                        end
                    })
                end

                if utils.hasPermission(myRank.Rank, 'kick') then
                    table.insert(elements, {
                        icon = "hand",
                        title = _L('member_kick_title'),
                        description = _L('member_kick_desc'),
                        onSelect = function()
                            lib.hideContext(onExit)
                            local alert = lib.alertDialog({
                                header = _L('member_kick_confirmation_title'),
                                content = _L('member_kick_confirmation_desc', {data.Name}),
                                centered = true,
                                cancel = true
                            })
                            if alert == 'confirm' then
                                TriggerServerEvent('crews:removeFromCrew', identifier)
                                notify(_L('member_kick_success'), 'success')
                            end
                        end
                    })
                end

                if myRank.Rank == 'owner' then
                    table.insert(elements, {
                        icon = "crown",
                        title = _L('member_crew_transfer_title'),
                        description = _L('member_crew_transfer_desc'),
                        onSelect = function()
                            local alert = lib.alertDialog({
                                header = _L('member_crew_transfer_title'),
                                content = _L('member_crew_transfer_confirmation_desc', {data.Name}),
                                centered = true,
                                cancel = true
                            })
                            if alert == 'confirm' then
                                TriggerServerEvent('crews:transferOwnership', identifier)
                                notify(_L('member_crew_transfer_success', {data.Name}), 'success')
                            end
                        end
                    })
                end
            end
    
            lib.registerContext({
                id = 'crew_menu-member',
                title = _L('member_title', {data.Name}),
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
            local coords = GetEntityCoords(cache.ped)

            if players then
                for k,v in ipairs(players) do
                    if cache.playerId ~= v then
                        local targetCoords = GetEntityCoords(GetPlayerPed(v))
                        if CONFIG.MAX_INVITE_DISTANCE and #(coords - targetCoords) > CONFIG.MAX_INVITE_DISTANCE then
                            return notify(_L('error_nobody_around'), 'error')
                        end

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
            end
        end
    end,

    openSettings = function()
        local elements = {}
        if crew and crew.data then
            for k,v in pairs(crew.data) do
                if utils.hasPermission(v.Rank, 'changeName') then
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
                                        return notify(_L('error_name_used'), 'error')
                                    end
                                end
                            end
            
                            TriggerServerEvent('crews:renameCrew', label)
                        end,
                        description = _L('settings_btn_rename_desc')
                    })
                end

                if utils.hasPermission(v.Rank, 'changeTag') then
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
                                            return notify(_L('error_tag_used'), 'error')
                                        end
                                    end
                                end
                            end

                            if #tag < 4 then
                                return notify(_L('error_tag_invalid'), 'error')
                            end
            
                            TriggerServerEvent('crews:newTag', tag:upper())
                        end,
                        description = _L('settings_btn_rename_desc')
                    })
                end
                
                -- table.insert(elements,{
                --     icon = "gun",
                --     title = "PVP",
                --     disabled = true,
                --     description = "Click to toggle PVP for crew members."
                -- })
            end
                
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

utils = {
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
            for _, blip in pairs(crewBlipsNear) do
                RemoveBlip(blip)
            end
            for _, blip in pairs(crewBlipsFar) do
                RemoveBlip(blip)
            end
            table.clear(crewBlipsNear)
            table.clear(crewBlipsFar)
        end
    end,

    deleteTag = function(identifier)
        if identifier then
            if currentTags[identifier] then
                RemoveMpGamerTag(currentTags[identifier])
                currentTags[identifier] = nil
            end
        else
            if currentTags then
                for _, tag in pairs(currentTags) do
                    RemoveMpGamerTag(tag)
                end
                table.clear(currentTags)
            end
        end
    end,

    getMemberCount = function()
        if crew then
            local count = 0
            for _,_ in pairs(crew.data) do
                count = count + 1
            end

            return count
        end

        return false
    end,

    getRankIndex = function(rank)
        for i=1, #CONFIG.RANKS do
            local data = CONFIG.RANKS[i]

            if data.name == rank then
                return i
            elseif rank == 'owner' then
                return 0
            elseif rank == 'member' then
                return 999
            end
        end

        return false
    end,

    getRankLabel = function(rank)
        for i=1, #CONFIG.RANKS do
            local data = CONFIG.RANKS[i]

            if data.name == rank and data.label then
                return data.label
            elseif rank == 'owner' then
                return _L('member_rank_owner')
            elseif rank == 'member' then
                return _L('member_rank_member')
            end
        end

        return error(('Couldn\'t retrieve rank label for rank id:'):format(rank))
    end,

    hasPermission = function(rank, permission)
        for i=1, #CONFIG.RANKS do
            local data = CONFIG.RANKS[i]

            if data.name == rank then
                for k,v in pairs(data.permissions) do
                    if k == permission then
                        return v
                    end
                end
            elseif rank == 'owner' then
                return true
            elseif rank == 'member' then
                return false
            end
        end

        return false
    end,
}