Language = {}

function _L(name, args)
    if name then 
        local str = Language[CONFIG.GENERAL.LANGUAGE][name]
        if str then
            if args then
                return string.format(str, table.unpack(args))
            else
                return str
            end
        else    
            return "ERR_TRANSLATE_"..name.."_404"
        end
    else
        return "ERR_TRANSLATE_404"
    end
end