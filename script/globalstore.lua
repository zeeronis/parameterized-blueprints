local globalstore = {}

local create_if_not_present = function ()
    if not global.globalstore then
        global.globalstore = {}
    end
end

globalstore.set_value = function(player_index, name, value)
    create_if_not_present()
    global.globalstore[player_index .. name] = value
end

globalstore.get_value = function (player_index, name)
    create_if_not_present()
    return global.globalstore[player_index .. name]
end

globalstore.get_value_fallback = function (player_index, name, fallback)
    create_if_not_present()
    local value = global.globalstore[player_index .. name]
    if value ~= nil then
        return value
    else
        return fallback
    end
end

return globalstore