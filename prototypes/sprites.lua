data:extend({
    {
        type = "sprite",
        name = "parameter-placeholder",
        filename = "__parameterized-blueprints__/graphics/placeholder.png",
        priority = "extra-high",
        width = 32,
        height = 32,
    }
})

data:extend({
    {
        type = "sprite",
        name = "parameter-gui-indicator-arrow",
        filename = "__parameterized-blueprints__/graphics/gui-arrow.png",
        priority = "extra-high",
        width = 64,
        height = 64,
    }
})

local add_placeholder_sprite = function (index)
    data:extend({
        {
            type = "sprite",
            name = "parameter-placeholder-" .. index,
            filename = "__parameterized-blueprints__/graphics/placeholder-" .. index .. ".png",
            priority = "extra-high",
            width = 32,
            height = 32
        }
    })
end

for i = 0, 9, 1 do
    add_placeholder_sprite(i)
end