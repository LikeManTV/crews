crews, invites = {}, {}
crewNames, crewTags = {}, {}
crewByIdentifier = {}
onlineIdentifiers = {}

----------------------------------------------------------------

CreateThread(function()
    MySQL.Async.fetchAll("SELECT * FROM crews", {}, function(result)		
		for k,v in ipairs(result) do
			crews[v.owner] = {data = json.decode(v.data), label = v.label, tag = v.tag, owner = v.owner}
			table.insert(crewNames, v.label)
			table.insert(crewTags, v.tag)
			for k2,v2 in pairs(crews[v.owner].data) do
				crewByIdentifier[k2] = v.owner
			end
		end
	end)
end)

-- EVENTS ------------------------------------------------------

AddEventHandler('playerDropped', function(reason)
	local source = source
	local identifier = getIdentifier(source)

	for k,v in pairs(onlineIdentifiers) do
		if v == source then
			onlineIdentifiers[k] = nil
			break
		end
	end

	TriggerClientEvent("crews:removePlayer", -1, crewByIdentifier[identifier], identifier)
end)

RegisterServerEvent('crews:getCrew', function(identifier)
    local source = source

	onlineIdentifiers[identifier] = source

	local sendCrew = nil
	if crewByIdentifier[identifier] then
		sendCrew = crews[crewByIdentifier[identifier]]
	end

	TriggerClientEvent('crews:setCrew', source, sendCrew)
	TriggerClientEvent('crews:setInvites', source, invites[identifier])
	TriggerClientEvent('crews:setNames', source, crewNames)
	TriggerClientEvent('crews:setTags', source, crewTags)
end)

RegisterServerEvent('crews:getNames', function()
	local source = source
	TriggerClientEvent('crews:setNames', source, crewNames)
end)

RegisterServerEvent('crews:getTags', function()
	local source = source
	TriggerClientEvent('crews:setTags', source, crewTags)
end)

RegisterServerEvent('crews:createCrew', function(label, tag)
	local source = source
	local identifier = getIdentifier(source)
	local name = GetPlayerName(source)

	if label then
		label = ("%s Crew"):format(label)
	else
		label = ("%s's Crew"):format(name)
	end

	if not crews[identifier] and not crewByIdentifier[identifier] then
		crews[identifier] = {
			owner = identifier,
			label = label,
			tag = tag,
			data = {
				[identifier] = name
			}
		}

		crewByIdentifier[identifier] = identifier

		TriggerClientEvent('crews:setCrew', source, crews[identifier])
        TriggerClientEvent('crews:notify', source, _L('create_success', {label}), 'success')

		MySQL.Async.execute('INSERT INTO crews (owner, label, tag, data) VALUES (@owner, @label, @tag, @data)',
		{
			['@owner'] = identifier,
			['@label'] = label,
			['@tag'] = tag,
			['@data'] = json.encode(crews[identifier].data)
		})

		TriggerClientEvent('crews:setNames', source, crewNames)
		TriggerClientEvent('crews:setTags', source, crewTags)
	end
end)

RegisterServerEvent('crews:deleteCrew', function()
	local source = source
	local identifier = getIdentifier(source)

	if crews[identifier] then
		for k, v in pairs(crews[identifier].data) do
			crewByIdentifier[k] = nil
			if onlineIdentifiers[k] then
				TriggerClientEvent('crews:setCrew', onlineIdentifiers[k], nil)
				TriggerClientEvent('crews:setNames', source, crewNames)
				TriggerClientEvent('crews:setTags', source, crewTags)
			end
		end

        TriggerClientEvent('crews:notify', source, _L('delete_success', {crews[identifier].label}), 'success')

		crews[identifier] = nil

		MySQL.Async.execute('DELETE FROM crews WHERE owner = @owner', {
			['@owner'] = identifier
		})
	end
end)

RegisterServerEvent('crews:addToCrew', function(id)
	local source = source
	local target = id
	local identifier = getIdentifier(source)
    local yidentifier = getIdentifier(target)

	if crewByIdentifier[yidentifier] then
        TriggerClientEvent('crews:notify', source, _L('error_player_in_crew'), 'error')
	else
		if crews[identifier] then
			local limit = false
			if CONFIG.CREW_SETTINGS.MAX_CREW_MEMBERS then
				local count = 0
				for k,v in pairs(crews[identifier].data) do
					count = count + 1
					if count >= CONFIG.CREW_SETTINGS.MAX_CREW_MEMBERS then
						limit = true
						break
					end
				end
			end

			if limit then
                TriggerClientEvent('crews:notify', source, _L('error_limit_reached', {CONFIG.CREW_SETTINGS.MAX_CREW_MEMBERS}), 'error')
			else
				if not invites[yidentifier] then invites[yidentifier] = {} end

				if not invites[yidentifier][identifier] then
					invites[yidentifier][identifier] = crews[identifier].label
					
					TriggerClientEvent('crews:setInvites', target, invites[yidentifier])
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
end)

RegisterServerEvent('crews:acceptCrew', function(ident)
	local source = source
	local identifier = getIdentifier(source)

	if invites[identifier] and invites[identifier][ident] and crews[ident] then

		local limit = false
		if CONFIG.CREW_SETTINGS.MAX_CREW_MEMBERS then
			local count = 0
			for k,v in pairs(crews[ident].data) do
				count = count + 1
				if count >= CONFIG.CREW_SETTINGS.MAX_CREW_MEMBERS then
					limit = true
					break
				end
			end
		end

		if limit then
            TriggerClientEvent('crews:notify', source, _L('error_limit_reached', {CONFIG.CREW_SETTINGS.MAX_CREW_MEMBERS}), 'error')
		else
			crews[ident].data[identifier] = GetPlayerName(source)
			crewByIdentifier[identifier] = ident
			
			for k, v in pairs(crews[ident].data) do
				if onlineIdentifiers[k] then
					TriggerClientEvent('crews:setCrew', onlineIdentifiers[k], crews[ident])
				end
			end

			invites[identifier] = nil

			TriggerClientEvent('crews:setInvites', onlineIdentifiers[identifier], nil)
            TriggerClientEvent('crews:notify', source, _L('invites_success', {crews[ident].label}), 'success')
			
			MySQL.Async.execute('UPDATE crews SET data = @data WHERE owner = @owner', {
				['@data'] = json.encode(crews[ident].data),
				['@owner'] = ident
			})
		end
	end
end)

RegisterServerEvent('crews:leaveCrew', function()
	local source = source
	local identifier = getIdentifier(source)

	if crewByIdentifier[identifier] and crews[crewByIdentifier[identifier]] then
		local ident = crewByIdentifier[identifier]

		crews[ident].data[identifier] = nil
		crewByIdentifier[identifier] = nil
		
		TriggerClientEvent('crews:removePlayer', -1, ident, identifier)
		TriggerClientEvent('crews:playerLeft', source, ident)
		TriggerClientEvent('crews:setCrew', source, nil)

		for k, v in pairs(crews[ident].data) do
			if onlineIdentifiers[k] then
				TriggerClientEvent('crews:setCrew', onlineIdentifiers[k], crews[ident])
			end
		end

		MySQL.Async.execute('UPDATE crews SET data = @data WHERE owner = @owner', {
			['@data'] = json.encode(crews[ident].data),
			['@owner'] = ident
		})
	end
end)

RegisterServerEvent('crews:removeFromCrew', function(yidentifier)
	local source = source
	local identifier = getIdentifier(source)
    local target = getPlayerFromIdentifier(yidentifier)
	if target == nil then return end

	if crews[identifier] and yidentifier ~= identifier then
		crews[identifier].data[yidentifier] = nil
		crewByIdentifier[yidentifier] = nil

		TriggerClientEvent('crews:removePlayer', -1, identifier, yidentifier)
		if target then
			TriggerClientEvent('crews:playerLeft', target.source, identifier)
		end

		if onlineIdentifiers[yidentifier] then
			TriggerClientEvent('crews:setCrew', onlineIdentifiers[yidentifier], nil)
		end

		for k, v in pairs(crews[identifier].data) do
			if onlineIdentifiers[k] then
				TriggerClientEvent('crews:setCrew', onlineIdentifiers[k], crews[identifier])
			end
		end

		if onlineIdentifiers[yidentifier] then
            TriggerClientEvent('crews:notify', target.source, _L('player_kicked'), 'inform')
		end

		MySQL.Async.execute('UPDATE crews SET data = @data WHERE owner = @owner', {
			['@data'] = json.encode(crews[identifier].data),
			['@owner'] = identifier
		})
	end
end)

RegisterServerEvent('crews:rename', function(newName)
	local source = source
	local identifier = getIdentifier(source)

	if newName then
		crews[identifier].label = newName..' Crew'
        TriggerClientEvent('crews:notify', source, _L('rename_success', {newName}), 'success')
	else
		crews[identifier].label = GetPlayerName(source)..' Crew'
	end

	MySQL.Async.execute('UPDATE crews SET label = @label WHERE owner = @owner', {
		['@label'] = newName..' Crew',
		['@owner'] = identifier
	})

	TriggerClientEvent('crews:setCrew', source, crews[identifier])
	TriggerClientEvent('crews:setNames', source, crewNames)
end)

RegisterServerEvent('crews:newTag', function(newTag)
	local source = source
	local identifier = getIdentifier(source)

	crews[identifier].tag = newTag
    TriggerClientEvent('crews:notify', source, _L('tag_success', {newTag}), 'success')

	MySQL.Async.execute('UPDATE crews SET tag = @tag WHERE owner = @owner', {
		['@tag'] = newTag,
		['@owner'] = identifier
	})

	TriggerClientEvent('crews:setCrew', source, crews[identifier])
	TriggerClientEvent('crews:setTags', source, crewTags)
end)

lib.callback.register('crews:blipUpdate', function(source)
	local blips = {}
	local players = getAllPlayers()

	for i=1, #players do
		local data = getPlayerData(players[i])
		blips[players[i].source] = data
	end
	
	return blips
end)

-- EXPORTS ------------------------------------------------------

exports('getCrew', function(identifier)
	if crews[crewByIdentifier[identifier]] then
		return crews[crewByIdentifier[identifier]]
	end

	return false
end)

exports('ownsCrew', function(netId)
    local identifier = getIdentifier(netId)

    if crews[crewByIdentifier[identifier]] then
        return true
    end

    return false
end)

exports('ownsCrew2', function(identifier)
    if crews[crewByIdentifier[identifier]] then
        return true
    end

    return false
end)

exports('isInCrew', function(netId)
	local identifier = getIdentifier(netId)
		
	for k,v in pairs(crews) do
		if v.data[identifier] then
			return true
		end
	end

    return false
end)

exports('isInCrew2', function(identifier)
	for k,v in pairs(crews) do
		if v.data[identifier] then
			return true
		end
	end

    return false
end)

exports('isInPlayersCrew', function(owner, player)
	for k,v in pairs(crews) do
		if k == owner then
			if v.data[player] then
				return true
			end
		end
	end
	return false
end)

exports('getCrewName', function(netId)
	for k,v in pairs(crews) do
		for _, name in pairs(v.data) do
			if name == GetPlayerName(netId) then
				return v.label
			end
		end
	end

    return false
end)

exports('getCrewTag', function(netId)
	for k,v in pairs(crews) do
		for _, name in pairs(v.data) do
			if name == GetPlayerName(netId) then
				return v.tag
			end
		end
	end

    return false
end)

exports('getCrewOwner', function(identifier)
	for k,v in pairs(crews) do
		if v.data[identifier] then
			return k
		end
	end

    return false
end)

exports('getCrewMembers', function(netId)
    local list = {}

    local identifier = getIdentifier(netId)
    for k,v in pairs(crews) do
        if v.data[identifier] then
            for target, _ in pairs(v.data) do
                local player = getPlayerFromIdentifier(target)
				if player and player ~= nil then
                	table.insert(list, player.source)
				end
            end
            return list
        end
    end

    return nil
end)
