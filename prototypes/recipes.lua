
-- global recipe category
data:extend({
    {
        type = "recipe-category",
        name = "parameters-category",
    }
})

-- placeholders 1 - 10
local function add_recipe_placeholder(index)
    data:extend({{
        type = "recipe",
        name = "placeholder-" .. index,
        enabled = true,
        energy_required = 1,
        icon = "__parameterized-blueprints__/graphics/placeholder-" .. index .. ".png",
        icon_size = 32,
        hide_from_player_crafting = true,
        ingredients = {},
        results = {},
        subgroup = "parameters-recipes",
        category = "parameters-category"
    }})
end

for i = 0, 9, 1 do
    add_recipe_placeholder(i)
end