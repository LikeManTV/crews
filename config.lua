CONFIG = {
    LANGUAGE = 'en',
    COMMAND = 'crew',
    MAX_CREW_MEMBERS = 4,
    MAX_INVITE_DISTANCE = 5.0, -- false to disable distance check

    RANKS = { -- Add your own ranks here!
        [1] = { -- Order in which are ranks displayed (owner is always first and member last).
            name = 'officer', -- The name must be unique.
            label = 'Officer', -- Rank label shown in menu.
            permissions = { -- Configure permissions per rank.
                invite = true,
                kick = true,
                changeRank = false,
                changeName = false,
                changeTag = false
            }
        },
    }
}

-- Customize the notifications here.
notify = function(text, _type)
    if not _type then _type = 'inform' end

    lib.notify({
        title = 'CREWS',
        description = text,
        type = _type
    })
end