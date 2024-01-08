CONFIG = {}

CONFIG.GENERAL = {
    LANGUAGE = 'en',
}

CONFIG.CREW_SETTINGS = {
    COMMAND = 'crew',
    ENABLE_KEYBIND = false,
    OPEN_KEY = 'F4',
    MAX_CREW_MEMBERS = 4,
    MAX_INVITE_DISTANCE = 5.0,
}

-- Customize the notifications here.
notify = function(text, type)
    lib.notify({
        title = 'CREW',
        description = text,
        type = type
    })
end