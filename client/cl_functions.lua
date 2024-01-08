function getMemberCount()
    if crew then
        local count = 0
        for _ in pairs(crew.data) do
            count = count + 1
        end

        return count
    end

    return 0
end