Util = {}

-- recursively search a table for the specified pattern
-- depth first search
Util.search_for_string = function (node, pattern)
    for key, value in pairs(node) do
        local result = nil
        if type(value) == "string" then
            result = string.match(value, pattern)
        elseif type(value) == "table" then
            result = Util.search_for_string(value, pattern)
        end
        if result ~= nil then return result end
    end
end

Util.search_for_string_container = function (node, pattern)
    for key, value in pairs(node) do
        local result = nil
        if type(value) == "string" then
            result = string.match(value, pattern)
            if result ~= nil then return {node, key} end
        elseif type(value) == "table" then
            result = Util.search_for_string_container(value, pattern)
            if result ~= nil then return result end
        end
    end
end