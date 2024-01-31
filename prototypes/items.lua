
-- placeholders 1 - 10
local function add_placeholder_item(index)
    data:extend({{
        type = "item",
        name = "placeholder-" .. index,
        icon = "__parameterized-blueprints__/graphics/placeholder-" .. index .. ".png",
        icon_size = 32,
        subgroup = "parameters-items",
        stack_size = 1,
    }})
end

for i = 0, 9, 1 do
    add_placeholder_item(i)
end