shared = {
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