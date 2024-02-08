local mod_gui = require("mod-gui")
local globalstore = require("script.globalstore")
local blueprints  = require("script.blueprints")

local gui = {}

gui.window_name = "blueprint_parameter_window_name"
gui.window_close_button_name = "blueprint_parameter_window_close_button"
gui.confirm_parameters_button_name = "confirm_parameters_button"
gui.options_content_flow_name = "options_content_flow"

gui.create_options_gui = function (player, blueprint, info)
    -- close an already open options gui
    gui.close_options_gui(player.index)

    local frame = {
        type = "frame",
        direction = "vertical",
        name = gui.window_name,
        style = mod_gui.frame_style
    }
    frame = mod_gui.get_frame_flow(player).add(frame)
    globalstore.set_value(player.index, "options_gui", frame)
    globalstore.set_value(player.index, "last_selected_blueprint", blueprint)

    local header = frame.add({
        type = "flow",
        direction = "horizontal",
    })

    local title = header.add({
        type = "label",
        caption = {"parameterized-blueprints-gui-options-title"}
    })

    local spacer = header.add({
        type = "empty-widget",
    })
    spacer.style.height = 24
    spacer.style.horizontally_stretchable = true

    if blueprint.is_item then
    local close_button = header.add({
            type = "sprite-button",
            name = gui.window_close_button_name,
            style = "frame_action_button",
            sprite = "utility/close_white",
            hovered_sprite = "utility/close_black",
            clicked_sprite = "utility/close_black",
            --tooltip = { "parameterized-blueprints.gui.close_tooltip" }
            tooltip = { "gui.close-instruction" }
        })
    end

    local content_frame = frame.add({
        type = "frame",
        direction = "vertical",
        name = "frame",
        style = "inside_shallow_frame_with_padding",
    })

    local content_flow = content_frame.add({
        type = "flow",
        direction = "vertical",
        name = gui.options_content_flow_name,
    })

    for i = 0, 9, 1 do
        local show = info["uses_" .. i]
        if show then
            gui.create_parameter_option(content_flow, i)
        end
    end

    local footer = frame.add({
        type = "flow",
        direction = "horizontal",
        style = "dialog_buttons_horizontal_flow"
    })

    local footer_spacer = footer.add({
        type = "empty-widget"
    })
    footer_spacer.style.horizontally_stretchable = true

    footer.add({
        type = "button",
        caption = {"parameterized-blueprints-gui-create-blueprint"},
        style = "confirm_button",
        name = gui.confirm_parameters_button_name
    })

    return frame
end

gui.is_options_open = function (player_index)
    local result = globalstore.get_value(player_index, "options_gui")
    if result then
        return result.valid
    end
    return false
end

gui.close_options_gui = function (player_index)
    if gui.is_options_open(player_index) then
        globalstore.get_value(player_index, "options_gui").destroy()
        globalstore.set_value(player_index, "options_gui", nil)
    end
end

gui.create_parameter_option = function (root, index)
    local flow = root.add({
        type = "flow",
        direction = "horizontal",
        name = "placeholder-" .. index
    })
    flow.style.vertical_align = "center"

    local placeholder_showcase_button = flow.add({
        type = "choose-elem-button",
        style = "slot_button_in_shallow_frame",
        elem_type = "signal",
    })
    placeholder_showcase_button.elem_value = { type = "item", name = "placeholder-" .. index }
    placeholder_showcase_button.locked = true

    local sprite = flow.add({
        type = "sprite",
        sprite = "parameter-gui-indicator-arrow",
        resize_to_sprite = false,
    })
    sprite.style.width = 16
    sprite.style.height = 16

    local select_item_button = flow.add({
        type = "choose-elem-button",
        style = "slot_button_in_shallow_frame",
        name = "target_item_button",
        elem_type = "signal",
        -- signals don't support filters
    })

    local select_recipe_button = flow.add({
        type = "choose-elem-button",
        style = "slot_button_in_shallow_frame",
        name = "target_recipe_button",
        elem_type = "recipe",
        visible = false,
    })
end

gui.handle_select_signal_button_changed = function (event)
    if event.element.name ~= "target_item_button" and event.element.name ~= "target_recipe_button" then
        return
    end

    -- only allow target_item_button to continue
    if event.element.name ~= "target_item_button" then
        gui.confirm_selection_if_all_are_set(event.player_index)
        return
    end

    if event.element.elem_value and string.match(event.element.elem_value.name, blueprints.placeholder_pattern_string) then
        event.element.elem_value = nil
        game.players[event.player_index].print("placeholder items are not valid here (these cannot be hidden from the ui)")
        return
    end

    local signal_button = event.element
    local recipe_button = event.element.parent["target_recipe_button"]
    if signal_button.elem_value then
        if signal_button.elem_value.type == "item" then
            gui.set_recipe_filters(signal_button.elem_value, recipe_button, "item")
        elseif signal_button.elem_value.type == "fluid" then
            gui.set_recipe_filters(signal_button.elem_value, recipe_button, "fluid")
        else
            recipe_button.visible = false
        end
    else
        recipe_button.visible = false
    end

    gui.confirm_selection_if_all_are_set(event.player_index)
end

gui.set_recipe_filters = function (signal, recipe_button, type)
    local recipes = game.get_filtered_recipe_prototypes{
        { filter = "hidden", invert = true, mode = "and" },
        { filter = "has-product-" .. type, elem_filters = {
            { filter = "name", name = signal.name }
        }, mode = "and" }
    }

    if #recipes == 0 then
        recipe_button.elem_value = nil
        recipe_button.visible = false
    elseif #recipes == 1 then
        local recipe = nil
        for key, _ in pairs(recipes) do
            recipe = key
            break
        end
        recipe_button.elem_value = recipe
        recipe_button.visible = false
    else
        recipe_button.elem_value = nil
        recipe_button.elem_filters = {
            { filter = "hidden", invert = true, mode = "and" },
            { filter = "subgroup", subgroup = "parameters-recipes" , invert = "true" , mode = "and" },
            { filter = "has-product-" .. type, elem_filters = {
                { filter = "name", name = signal.name }
            }, mode = "and" }
        }
        recipe_button.visible = true
    end
end

gui.get_changes_from_ui = function (player_index)
    if not gui.is_options_open(player_index) then return nil end

    local changes = {
        recipes = {},
        signals = {},
        items = {},
        fluids = {},
    }

    local entry_frame = globalstore.get_value(player_index, "options_gui")["frame"][gui.options_content_flow_name]
    for index, entry in ipairs(entry_frame.children) do
        -- don't check for visiblity - will need to grab value stored here even if it's not visible
        local recipe_button = entry["target_recipe_button"]
        local item_button = entry["target_item_button"]
        if recipe_button.elem_value then
            changes.recipes[entry.name] = recipe_button.elem_value
        end
        changes.signals[entry.name] = item_button.elem_value
        if item_button.elem_value then
            if item_button.elem_value.type == "item" then
                changes.items[entry.name] = item_button.elem_value.name
            end
            if item_button.elem_value.type == "fluid" then
                changes.fluids[entry.name] = item_button.elem_value.name
            end
        end
    end

    return changes
end

gui.confirm_selection = function(player_index)
    local player = game.players[player_index]
    local changes = gui.get_changes_from_ui(player_index)
    blueprints.backfill_changes(changes)
    local base_blueprint = globalstore.get_value(player_index, "last_selected_blueprint")
    local modified_blueprint = blueprints.modify_blueprint(base_blueprint, changes)
    blueprints.give_player_blueprint(player, modified_blueprint)
    gui.close_options_gui(player_index)
end

gui.confirm_selection_if_all_are_set = function (player_index)
    -- check settings to see if we should continue
    if not settings.player["parameterized-blueprints-use-quick-blueprint-confirm"] then
        return
    end
    
    -- check if all are set, if so then confirm blueprint
    local content_flow = globalstore.get_value(player_index, "options_gui")["frame"][gui.options_content_flow_name]
    for _, entry in ipairs(content_flow.children) do
        -- don't check for visiblity - will need to grab value stored here even if it's not visible
        local recipe_button = entry["target_recipe_button"]
        local item_button = entry["target_item_button"]

        -- if any elements are not set then don't do it
        if item_button.elem_value == nil then
            return
        end

        -- skip to next if the recipe button is not visible
        if not recipe_button.visible then
            goto continue
        end

        -- if the recipe button is visible but not set then don't do it
        if recipe_button.elem_value == nil then
            return
        end

        ::continue::
    end

    -- if all checks pass then confirm the selection
    game.players[player_index].print("blueprint confirmed!")
    gui.confirm_selection(player_index)
end


return gui