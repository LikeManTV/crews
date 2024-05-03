crews, invites = {}, {}
crewNames, crewTags = {}, {}
crewByIdentifier = {}
onlinePlayers = {}

----------------------------------------------------------------

CreateThread(function()
    MySQL.query('SELECT * FROM crews', {}, function(result)
        if result then
            for i=1, #result do
                local row = result[i]
                local success, decodedData = pcall(json.decode, row.data)
                if success then
                    if decodedData then
                        crews[tonumber(row.owner)] = {owner = tonumber(row.owner), label = row.label, tag = row.tag, data = decodedData}
                        crewNames[row.owner] = row.label
                        crewTags[row.owner] = row.tag
                        for k,_ in pairs(decodedData) do
                            crewByIdentifier[tonumber(k)] = tonumber(row.owner)
                        end
                    else
                        error("Decoded data is nil for JSON:", row.data)
                    end
                else
                    error("Error decoding JSON:", decodedData)
                    print("Problematic JSON string:", row.data)
                end
            end
        end
	end)
end)

----------------------------------------------------------------

local function checkCrewLimit(identifier)
	if CONFIG.MAX_CREW_MEMBERS then
		local count = 0
		for _,_ in pairs(crews[identifier].data) do
			count = count + 1
		end

        if count >= CONFIG.MAX_CREW_MEMBERS then
            return true
        end

        return false
	end
end

AddEventHandler('playerDropped', function(reason)
	local source = source
	local identifier = getIdentifier(source)

    if identifier and crewByIdentifier[identifier] then
        if onlinePlayers[identifier] then
            onlinePlayers[identifier] = nil
        end

        for k,_ in pairs(crews[crewByIdentifier[identifier]].data) do
			if onlinePlayers[tonumber(k)] then
                TriggerClientEvent('crews:removePlayer', onlinePlayers[tonumber(k)], identifier)
			end
		end
    end
end)

RegisterServerEvent('crews:getCrew', function(identifier)
    local source = source

    if identifier then
        onlinePlayers[identifier] = source

        if crewByIdentifier[identifier] then
            TriggerClientEvent('crews:setCrew', source, crews[crewByIdentifier[identifier]], invites[identifier], crewNames, crewTags)
        end
    end
end)

RegisterServerEvent('crews:createCrew', function(label, tag)
    local source = source
	local identifier = getIdentifier(source)
	local name = GetPlayerName(source)

    if identifier then
        if label then
            label = ("%s Crew"):format(label)
        else
            label = ("%s's Crew"):format(name)
        end

        if not crews[identifier] and not crewByIdentifier[identifier] then
            local newCrew = {
                owner = identifier,
                label = label,
                tag = tag,
                data = {}
            }

            newCrew.data[tostring(identifier)] = {Name = name, Rank = 'owner'}
            local success, encodedData = pcall(json.encode, newCrew.data)
            
            if success then
                if encodedData then
                    crews[identifier] = newCrew
                    crewByIdentifier[identifier] = identifier
                    crewNames[identifier] = label
                    crewTags[identifier] = tag

                    MySQL.insert('INSERT INTO `crews` (owner, label, tag, data) VALUES (?, ?, ?, ?)', {
                        identifier, label, tag, encodedData
                    }, function(id)
                        TriggerClientEvent('crews:setCrew', source, newCrew, invites[identifier], crewNames, crewTags)
                        TriggerClientEvent('crews:updateNames', -1, crewNames)
                        TriggerClientEvent('crews:updateTags', -1, crewTags)
                        TriggerClientEvent('crews:notify', source, _L('create_success', {label}), 'success')
                    end)
                else
                    error("Encoded data is nil for table:", newCrew.data)
                end
            else
                error("Error encoding table:", encodedData)
                print("Problematic table:", newCrew.data)
            end
        end
    end
end)

RegisterServerEvent('crews:deleteCrew', function()
	local source = source
	local identifier = getIdentifier(source)

    if identifier and crewByIdentifier[identifier] and crews[identifier] then
        for k,v in ipairs(crewNames) do
            if v == crews[identifier].label then
                table.remove(crewNames, k)
            end
        end
        for k,v in ipairs(crewTags) do
            if v == crews[identifier].tag then
                table.remove(crewTags, k)
            end
        end

        for k, _ in pairs(crews[identifier].data) do
            crewByIdentifier[tonumber(k)] = nil
            if onlinePlayers[tonumber(k)] then
                TriggerClientEvent('crews:setCrew', onlinePlayers[tonumber(k)], nil, invites[tonumber(k)], crewNames, crewTags)
            end
        end

        local success = MySQL.update.await('DELETE FROM crews WHERE owner', {identifier})
        if success then
            TriggerClientEvent('crews:notify', source, _L('delete_success', {crews[identifier].label}), 'success')
        end

        crews[identifier] = nil
    end
end)

RegisterServerEvent('crews:addToCrew', function(target)
	local source = source
	local identifier = getIdentifier(source)
    local targetIdentifier = getIdentifier(target)

    if identifier and targetIdentifier then
        if crewByIdentifier[targetIdentifier] then
            TriggerClientEvent('crews:notify', source, _L('error_player_in_crew'), 'error')
        else
            if crews[crewByIdentifier[identifier]] then
                local limit = checkCrewLimit(crewByIdentifier[identifier])

                if limit then
                    TriggerClientEvent('crews:notify', source, _L('error_limit_reached', {CONFIG.MAX_CREW_MEMBERS}), 'error')
                else
                    if not invites[targetIdentifier] then invites[targetIdentifier] = {} end
    
                    if not invites[targetIdentifier][crewByIdentifier[identifier]] then
                        invites[targetIdentifier][crewByIdentifier[identifier]] = crews[crewByIdentifier[identifier]].label
                        
                        TriggerClientEvent('crews:updateInvites', target, invites[targetIdentifier])
                        TriggerClientEvent('crews:notify', target, _L('invites_received_new'), 'inform')
                        TriggerClientEvent('crews:notify', source, _L('invite_success', {GetPlayerName(target)}), 'success')
                    else
                        TriggerClientEvent('crews:notify', source, _L('error_already_invited'), 'error')
                    end
                end
            else
                TriggerClientEvent('crews:notify', source, _L('error_no_crew'), 'error')
            end
        end
    end
end)

RegisterServerEvent('crews:joinCrew', function(crewOwner)
    local source = source
    local identifier = getIdentifier(source)

    if identifier and invites[identifier] and invites[identifier][crewOwner] and crews[crewOwner] then
        local limit = checkCrewLimit(crewOwner)

        if limit then
            TriggerClientEvent('crews:notify', source, _L('error_limit_reached', {CONFIG.MAX_CREW_MEMBERS}), 'error')
        else
            crews[crewOwner].data[identifier] = {Name = GetPlayerName(source), Rank = 'member'}
            crewByIdentifier[identifier] = crewOwner

            for k, _ in pairs(crews[crewOwner].data) do
                if onlinePlayers[tonumber(k)] then
                    TriggerClientEvent('crews:updateCrew', onlinePlayers[tonumber(k)], crews[crewOwner])
                end
            end

            invites[identifier] = nil
            TriggerClientEvent('crews:setInvites', onlinePlayers[identifier], nil)

            local success = MySQL.update.await('UPDATE crews SET data = ? WHERE owner = ?', {json.encode(crews[crewOwner].data), crewOwner})
            if success then
                TriggerClientEvent('crews:notify', source, _L('invites_success', {crews[crewOwner].label}), 'success')
            end
        end
    end
end)

RegisterServerEvent('crews:leaveCrew', function()
	local source = source
	local identifier = getIdentifier(source)

    if identifier and crewByIdentifier[identifier] and crews[crewByIdentifier[identifier]] then
		local crewOwner = crewByIdentifier[identifier]

		crews[crewOwner].data[tostring(identifier)] = nil
		crewByIdentifier[identifier] = nil
		
		TriggerClientEvent('crews:playerLeft', source, crewOwner)
		TriggerClientEvent('crews:updateCrew', source, nil)

		for k, _ in pairs(crews[crewOwner].data) do
			if onlinePlayers[tonumber(k)] then
				TriggerClientEvent('crews:updateCrew', onlinePlayers[tonumber(k)], crews[crewOwner])
                TriggerClientEvent('crews:removePlayer', onlinePlayers[tonumber(k)], identifier)
			end
		end

        local success = MySQL.update.await('UPDATE crews SET data = ? WHERE owner = ?', {json.encode(crews[crewOwner].data), crewOwner})
        if success then
            TriggerClientEvent('crews:notify', source, _L('leave_success'), 'success')
        end
    end
end)

RegisterServerEvent('crews:removeFromCrew', function(targetIdentifier)
	local source = source
	local identifier = getIdentifier(source)
    local target = getPlayerFromIdentifier(targetIdentifier)

    if identifier and targetIdentifier and target then
        if crewByIdentifier[identifier] and crews[crewByIdentifier[identifier]] and targetIdentifier ~= identifier then
            crews[crewByIdentifier[identifier]].data[tostring(targetIdentifier)] = nil
            crewByIdentifier[targetIdentifier] = nil
    
            TriggerClientEvent('crews:playerLeft', target.source, identifier)
    
            if onlinePlayers[targetIdentifier] then
                TriggerClientEvent('crews:updateCrew', onlinePlayers[targetIdentifier], nil)
                TriggerClientEvent('crews:notify', target.source, _L('player_kicked'), 'inform')
            end
    
            for k, _ in pairs(crews[crewByIdentifier[identifier]].data) do
                if onlinePlayers[tonumber(k)] then
                    TriggerClientEvent('crews:updateCrew', onlinePlayers[tonumber(k)], crews[crewByIdentifier[identifier]])
                    TriggerClientEvent('crews:removePlayer', onlinePlayers[tonumber(k)], targetIdentifier)
                end
            end

            local success = MySQL.update.await('UPDATE crews SET data = ? WHERE owner = ?', {json.encode(crews[identifier].data), crewByIdentifier[identifier]})
            if success then
                TriggerClientEvent('crews:notify', target.source, _L('player_kicked'), 'inform')
            end
        end
    end
end)

RegisterServerEvent('crews:changeRank', function(targetIdentifier, rankData)
    local source = source
    local identifier = getIdentifier(source)
    local target = getPlayerFromIdentifier(targetIdentifier)

    if targetIdentifier and crewByIdentifier[identifier] and crews[crewByIdentifier[identifier]] then
        crews[crewByIdentifier[identifier]].data[tostring(targetIdentifier)].Rank = rankData.name

        for k, _ in pairs(crews[crewByIdentifier[identifier]].data) do
            if onlinePlayers[tonumber(k)] then
                TriggerClientEvent('crews:updateCrew', onlinePlayers[tonumber(k)], crews[identifier])
            end
        end

        local success = MySQL.update.await('UPDATE crews SET data = ? WHERE owner = ?', {json.encode(crews[crewByIdentifier[identifier]].data), crewByIdentifier[identifier]})
        if success then
            TriggerClientEvent('crews:notify', target.source, _L('player_rank_changed', {rankData.label}), 'inform')
        end
    else
        print('Changing rank failed.')
    end
end)

RegisterServerEvent('crews:transferOwnership', function(targetIdentifier)
    local source = source
    local identifier = getIdentifier(source)
    local target = getPlayerFromIdentifier(targetIdentifier)

    if targetIdentifier then
        if crews[identifier] and crewByIdentifier[targetIdentifier] then
            local currentCrew = crews[identifier]
            currentCrew.owner = targetIdentifier
            currentCrew.data[tostring(targetIdentifier)].Rank = 'owner'
            currentCrew.data[tostring(identifier)].Rank = 'member'
            crews[identifier] = nil
            crews[targetIdentifier] = currentCrew

            for k, _ in pairs(currentCrew.data) do
                if onlinePlayers[tonumber(k)] then
                    TriggerClientEvent('crews:updateCrew', onlinePlayers[tonumber(k)], currentCrew)
                end
            end

            local success = MySQL.update.await('UPDATE crews SET owner = ?, data = ? WHERE owner = ?', {targetIdentifier, json.encode(currentCrew.data), identifier})
            if success then
                TriggerClientEvent('crews:notify', target.source, _L('player_crew_transfered'), 'inform')
            end
        end
    end
end)

RegisterServerEvent('crews:renameCrew', function(newName)
	local source = source
	local identifier = getIdentifier(source)

    if identifier and crewByIdentifier[identifier] and crews[crewByIdentifier[identifier]] then
        if newName then
            local formattedName = newName..' Crew'
            crews[crewByIdentifier[identifier]].label = formattedName
            crewNames[crewByIdentifier[identifier]] = formattedName
        else
            local formattedName = GetPlayerName(source)..' Crew'
            crews[crewByIdentifier[identifier]].label = formattedName
            crewNames[crewByIdentifier[identifier]] = formattedName
        end

        for k, _ in pairs(crews[crewByIdentifier[identifier]].data) do
            if onlinePlayers[tonumber(k)] then
                TriggerClientEvent('crews:updateCrew', onlinePlayers[tonumber(k)], crews[crewByIdentifier[identifier]])
            end
        end
        
        local success = MySQL.update.await('UPDATE crews SET label = ? WHERE owner = ?', {newName..' Crew', crewByIdentifier[identifier]})
        if success then
            TriggerClientEvent('crews:notify', source, _L('rename_success', {newName}), 'success')
        end
        
        TriggerClientEvent('crews:updateNames', -1, crewNames)
    else
        print('Crew renaming failed.')
    end
end)

RegisterServerEvent('crews:newTag', function(newTag)
	local source = source
	local identifier = getIdentifier(source)

    if identifier and crewByIdentifier[identifier] and crews[crewByIdentifier[identifier]] then
        crews[crewByIdentifier[identifier]].tag = newTag
        crewTags[crewByIdentifier[identifier]] = newTag

        for k, _ in pairs(crews[crewByIdentifier[identifier]].data) do
            if onlinePlayers[tonumber(k)] then
                TriggerClientEvent('crews:updateCrew', onlinePlayers[tonumber(k)], crews[crewByIdentifier[identifier]])
            end
        end

        local success = MySQL.update.await('UPDATE crews SET tag = ? WHERE owner = ?', {newTag, crewByIdentifier[identifier]})
        if success then
            TriggerClientEvent('crews:notify', source, _L('tag_success', {newTag}), 'success')
        end

        TriggerClientEvent('crews:updateTags', -1, crewTags)
    else
        print('Crew tag changing failed.')
    end
end)

lib.callback.register('crews:blipUpdate', function(source)
	local blips = {}
	local players = getAllPlayers()

	for i=1, #players do
		local data = getPlayerData(players[i])
		blips[data.source] = data
	end
	
	return blips
end)

----------------------------------------------------------------

exports('getCrew', function(identifier)
    if identifier then
        local crewOwner = crewByIdentifier[identifier]
        if crewOwner and crews[crewOwner] then
		    return crews[crewOwner]
        end
	end

	return false
end)

exports('ownsCrew', function(identifier)
    if identifier then
        local crewOwner = crewByIdentifier[identifier]
        if crewOwner and crews[crewOwner] then
            return true
        end
    end

    return false
end)

exports('isInCrew', function(identifier)
    if identifier and crewByIdentifier[identifier] then
        return true
    end

    return false
end)

exports('isInPlayersCrew', function(owner, player)
    if owner and player then
        if crewByIdentifier[player] == owner then
            return true
        end
    end

    return false
end)

exports('getCrewOwner', function(identifier)
    if identifier then
        local crewOwner = crewByIdentifier[identifier]
        if crewOwner and crews[crewOwner] then
            return crewOwner
        end
    end

    return false
end)

exports('getCrewName', function(identifier)
    if identifier and crewOwner then
        local crewOwner = crewByIdentifier[identifier]
        if crewOwner and crews[crewOwner] then
            return crews[crewOwner].label
        end
    end

    return false
end)

exports('getCrewTag', function(identifier)
    if identifier then
        local crewOwner = crewByIdentifier[identifier]
        if crewOwner and crews[crewOwner] then
            return crews[crewOwner].tag
        end
    end

    return false
end)

exports('getCrewMembers', function(identifier)
    local list = {}
    if identifier then
        local crewOwner = crewByIdentifier[identifier]
        if crewOwner and crews[crewOwner] then
            for target, _ in pairs(crews[crewOwner].data) do
                local player = getPlayerFromIdentifier(target)
                if player and player ~= nil then
                    table.insert(list, player.source)
                end
            end

            return list
        end
    end

    return 0
end)