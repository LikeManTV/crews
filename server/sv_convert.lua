local started = false
local finalCount = 0
local noOwner = 0

local function convert()
    if started then
        return warn('Data is already being converted, please wait..')
    end

    started = true
    print('Data conversion started..')

    local crewList = MySQL.query.await('SELECT * FROM crews')

    if crewList then
        local crews = {}

        for i=1, #crewList do
            local changed = false
            local crew = crewList[i]

            if crew and crew.owner then
               crews[crew.owner] = {
                    owner = crew.owner,
                    label = crew.label or 'ChangeMe',
                    tag = crew.tag or 'CREW',
                    data = json.decode(crew.data)
                }

                if not crew.label or crew.label == "" then
                    crews[crew.owner].label = 'ChangeMe'
                    changed = true
                end
                
                if not crew.tag or crew.tag == "" then
                    crews[crew.owner].tag = 'CREW'
                    changed = true
                end

                for identifier, data in pairs(crews[crew.owner].data) do
                    if type(data) == 'string' then
                        data = {Name = data}
                    end

                    if data and not data.Name then
                        local player = getPlayerFromIdentifier(identifier)
                        if player then
                            data.Name = GetPlayerName(player.source)
                            changed = true
                        end
                    end

                    if data and not data.Rank then
                        if identifier == crew.owner then
                            data.Rank = 'owner'
                        else
                            data.Rank = 'member'
                        end
                        changed = true
                    end

                    crews[crew.owner].data[identifier] = data
                end

                if changed then
                    finalCount += 1
                end
            else
                noOwner += 1
            end
        end

        print(('^7Updating ^3%s^0 crews..'):format(finalCount))
		local parameters = {}
		local count = 0

        for owner, v in pairs(crews) do
            count += 1
            parameters[count] = {
                v.owner,
                v.label,
                v.tag,
                json.encode(v.data),
                owner
            }
        end

        if parameters then
            MySQL.prepare.await('UPDATE crews SET owner = ?, label = ?, tag = ?, data = ? WHERE owner = ?', parameters)
            print(('^2Successfully converted %s crews.'):format(finalCount))
        end

        if noOwner > 0 then
            print(('^1%s don\'t have an owner!'):format(noOwner))
        end

        started = false
    else
        print('^3No crews need to be converted.')
    end
end

RegisterCommand('crews:convert', convert)