require("util")
require("__core__/lualib/util")
local entities = require("entity_placeholder_helpers")

local blueprints = {}

blueprints.placeholder_pattern_string = "placeholder%-[0-9]$"

blueprints.get_held_blueprint = function (player)
    if not player.is_cursor_blueprint() then return nil end

    -- if the held item is a blueprint (item variant) then check if it's setup before doing anything with it
    if player.cursor_stack.valid_for_read then
        if player.cursor_stack.type == "blueprint" and not player.cursor_stack.is_blueprint_setup() then
            return nil
        end
    end

    local blueprint = {
        entities = player.get_blueprint_entities(),
        tiles = {},
        is_item = player.cursor_stack.valid_for_read,
        item = nil,
    }

    -- ensure that the table exists - a blueprint with only times will return nil on get_blueprint entities
    if blueprint.entities == nil then
        blueprint.entities = {}
    end

    if blueprint.is_item then
        blueprint.item = player.cursor_stack

        -- check if it's an item first - if it's from a book then get_blueprint_tiles is invalid
        if blueprint.item.type == "blueprint" then
            blueprint.tiles = player.cursor_stack.get_blueprint_tiles()
        end
    end

    return blueprint
end

blueprints.get_parameterization_info = function (blueprint)
    local info = {
        is_parameterizable = false,
        uses_0 = false,
        uses_1 = false,
        uses_2 = false,
        uses_3 = false,
        uses_4 = false,
        uses_5 = false,
        uses_6 = false,
        uses_7 = false,
        uses_8 = false,
        uses_9 = false,
    }

    for _, entity in pairs(blueprint.entities) do
        entities.check_for_placeholder_values(entity, info)
    end

    return info
end

blueprints.modify_blueprint = function (base_blueprint, changes)
    local result = util.table.deepcopy(base_blueprint)

    if result == nil then return end

    for _, entity in pairs(result.entities) do
        entities.replace_placeholder_value(entity, changes)
    end

    return result
end

blueprints.give_player_blueprint = function (player, blueprint)

    if blueprint == nil then return end

    local temp_inventory = game.create_inventory(1)
    local blueprint_item = temp_inventory[1]
    blueprint_item.set_stack({name = "blueprint"})

    if blueprint.entities then blueprint_item.set_blueprint_entities(blueprint.entities) end
    if blueprint.tiles then blueprint_item.set_blueprint_tiles(blueprint.tiles) end

    player.add_to_clipboard(blueprint_item)
    player.activate_paste()

    temp_inventory.destroy()
end

blueprints.backfill_changes = function (changes)

    if changes == nil then return end

    for i = 0, 9, 1 do
        local name = "placeholder-" .. i
        if changes.recipes[name] == nil then
            changes.recipes[name] = nil
        end
        if changes.signals[name] == nil then
            changes.signals[name] = { type = "item", name = nil }
        end
    end
end

return blueprints
