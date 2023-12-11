local crews, invites = {}, {}
local crewNames, crewTags = {}, {}
local crewByIdentifier = {}
local onlineIdentifiers = {}

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

RegisterNetEvent('esx:playerDropped', function(playerId, reason)
	for k,v in pairs(onlineIdentifiers) do
		if v == playerId then
			onlineIdentifiers[k] = nil
			break
		end
	end
		
	local xPlayer = ESX.GetPlayerFromId(playerId)
	local identifier = xPlayer.identifier
	TriggerClientEvent("crews:removePlayer", -1, crewByIdentifier[identifier], identifier)
end)

RegisterNetEvent('crews:getCrew', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier

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

RegisterNetEvent('crews:getNames', function()
	local source = source
	TriggerClientEvent('crews:setNames', source, crewNames)
end)

RegisterNetEvent('crews:getTags', function()
	local source = source
	TriggerClientEvent('crews:setTags', source, crewTags)
end)

RegisterNetEvent('crews:createCrew', function(label, tag)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	local name = GetPlayerName(source)

	if label then
		label = ("%s Crew"):format(label)
	else
		label = ("%s's Crew"):format(name)
	end

	if not crews[identifier] and not crewByIdentifier[identifier] then
		crews[identifier] = {
			label = label,
			tag = tag,
			data = {
				[identifier] = name
			},
			owner = identifier
		}

		crewByIdentifier[identifier] = identifier

		TriggerClientEvent('crews:setCrew', source, crews[identifier])
		lib.notify(source,{title = 'CREW', description = ('Successfuly created: %s'):format(label), type = 'success'})

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

RegisterNetEvent('crews:deleteCrew', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier

	if crews[identifier] then
		for k, v in pairs(crews[identifier].data) do
			crewByIdentifier[k] = nil
			if onlineIdentifiers[k] then
				TriggerClientEvent('crews:setCrew', onlineIdentifiers[k], nil)
				TriggerClientEvent('crews:setNames', source, crewNames)
				TriggerClientEvent('crews:setTags', source, crewTags)
			end
		end

		lib.notify(source,{title = 'CREW', description = ('Successfuly deleted: %s'):format(crews[identifier].label), type = 'error'})

		crews[identifier] = nil

		MySQL.Async.execute('DELETE FROM crews WHERE owner = @owner', {
			['@owner'] = identifier
		})
	end
end)

RegisterNetEvent('crews:addToCrew', function(id)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier

	local target = id 
	local xTarget = ESX.GetPlayerFromId(target)
	local yidentifier = xTarget.identifier

	if crewByIdentifier[yidentifier] then
		lib.notify(source,{title = 'CREW', description = 'This player is already a part of another crew.', type = 'error'})
	else
		if crews[identifier] then
			local limit = false
			if Config.MaxCrewMembers then
				local count = 0
				for k,v in pairs(crews[identifier].data) do
					count = count + 1
					if count >= Config.MaxCrewMembers then
						limit = true
						break
					end
				end
			end

			if limit then
				lib.notify(source,{title = 'CREW', description = ('You have reached the player limit! (%s)'):format(Config.MaxCrewMembers), type = 'error'})
			else
				if not invites[yidentifier] then invites[yidentifier] = {} end

				if not invites[yidentifier][identifier] then
					invites[yidentifier][identifier] = crews[identifier].label
					
					TriggerClientEvent('crews:setInvites', id, invites[yidentifier])

					lib.notify(xTarget.source,{title = 'CREW', description = 'You have received a crew invite!', type = 'inform'})
					lib.notify(source,{title = 'CREW', description = ('You invited: %s into the crew!'):format(GetPlayerName(target)), type = 'success'})
				else
					lib.notify(source,{title = 'CREW', description = 'You have already invited this player.', type = 'error'})
				end
			end
		else
			lib.notify(source,{title = 'CREW', description = "You don't have a crew!", type = 'error'})
		end
	end
end)

RegisterNetEvent('crews:acceptCrew', function(ident)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier

	if invites[identifier] and invites[identifier][ident] and crews[ident] then

		local limit = false
		if Config.MaxCrewMembers then
			local count = 0
			for k,v in pairs(crews[ident].data) do
				count = count + 1
				if count >= Config.MaxCrewMembers then
					limit = true
					break
				end
			end
		end

		if limit then
			lib.notify(source,{title = 'CREW', description = ('This crew has reached the player limit. (%s)'):format(Config.MaxCrewMembers), type = 'error'})
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

			lib.notify(source,{title = 'CREW', description = ('You have joined: %s'):format(crews[ident].label), type = 'success'})
			
			MySQL.Async.execute('UPDATE crews SET data = @data WHERE owner = @owner', {
				['@data'] = json.encode(crews[ident].data),
				['@owner'] = ident
			})
		end
	end
end)

RegisterNetEvent('crews:leaveCrew', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier

	if crewByIdentifier[identifier] and crews[crewByIdentifier[identifier]] then
		local ident = crewByIdentifier[identifier]

		crews[ident].data[identifier] = nil
		crewByIdentifier[identifier] = nil
		
		TriggerClientEvent('crews:removePlayer', -1, ident, xPlayer.identifier)
		TriggerClientEvent('crews:playerLeft', xPlayer.source, ident)
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

RegisterNetEvent('crews:removeFromCrew', function(yidentifier)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	local target = ESX.GetPlayerFromIdentifier(yidentifier)

	if crews[identifier] and yidentifier ~= identifier then
		crews[identifier].data[yidentifier] = nil
		crewByIdentifier[yidentifier] = nil

		TriggerClientEvent('crews:removePlayer', -1, identifier, yidentifier)
		TriggerClientEvent('crews:playerLeft', target.source, identifier)

		if onlineIdentifiers[yidentifier] then
			TriggerClientEvent('crews:setCrew', onlineIdentifiers[yidentifier], nil)
		end

		for k, v in pairs(crews[identifier].data) do
			if onlineIdentifiers[k] then
				TriggerClientEvent('crews:setCrew', onlineIdentifiers[k], crews[identifier])
			end
		end

		if onlineIdentifiers[yidentifier] then
			lib.notify(target.source,{title = 'CREW', description = 'You have been kicked from your crew!', type = 'inform'})
		end

		MySQL.Async.execute('UPDATE crews SET data = @data WHERE owner = @owner', {
			['@data'] = json.encode(crews[identifier].data),
			['@owner'] = identifier
		})
	end
end)

RegisterNetEvent('crews:rename', function(newName)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier

	if newName then
		crews[identifier].label = newName..' Crew'
		lib.notify(source,{title = 'CREW', description = ('Your crew was renamed to: %s Crew'):format(newName), type = 'success'})
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

RegisterNetEvent('crews:newTag', function(newTag)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier

	crews[identifier].tag = newTag
	lib.notify(source,{title = 'CREW', description = ('Your crew tag was changed to: %s'):format(newTag), type = 'success'})

	MySQL.Async.execute('UPDATE crews SET tag = @tag WHERE owner = @owner', {
		['@tag'] = newTag,
		['@owner'] = identifier
	})

	TriggerClientEvent('crews:setCrew', source, crews[identifier])
	TriggerClientEvent('crews:setTags', source, crewTags)
end)

lib.callback.register('crews:blipUpdate', function(source)
	local blips = {}
    local players = GetPlayers()
    for index, player in ipairs(players) do
		local ped = GetPlayerPed(player)
		local xPlayer = ESX.GetPlayerFromId(player)
		local identifier = xPlayer.identifier
		local coords = GetEntityCoords(ped)
		local name = GetPlayerName(player)

		blips[player] = {player, NetworkGetNetworkIdFromEntity(ped), identifier, name, vector3(coords.x, coords.y, coords.z)}
	end
	
	return blips
end)

exports('ownsCrew', function(identifier)
	if crews[crewByIdentifier[identifier]] then
        return true
    end

    return false
end)

exports('isInCrew', function(owner, identifier)
	for k,v in pairs(crews) do
		if v.data[identifier] then
			return true
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
