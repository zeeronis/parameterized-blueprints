local gui = require("script.gui")
local blueprints = require("script.blueprints")
local globalstore = require("script.globalstore")

script.on_event(defines.events.on_gui_click, function (event)
    if event.element.name == gui.window_close_button_name then
        gui.close_options_gui(event.player_index)
        return
    end

    if event.element.name == gui.confirm_parameters_button_name then
        gui.confirm_selection(event.player_index)
    end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function (event)
    local player = game.players[event.player_index]
    
    local blueprint = blueprints.get_held_blueprint(player)

    if blueprint == nil then
        -- close the options ui if the last selected blueprint is *not* an item, item blueprints should have the ui stay open and be closed manually
        if not globalstore.get_value_fallback(event.player_index, "last_selected_blueprint", {}).is_item then
            gui.close_options_gui(player.index)
        end
        return
    end

    local info = blueprints.get_parameterization_info(blueprint)

    if info.is_parameterizable then
        gui.create_options_gui(player, blueprint, info)
    else
        gui.close_options_gui(player.index)
    end
end)

script.on_event(defines.events.on_gui_elem_changed, gui.handle_select_signal_button_changed)

script.on_event("parameterized-blueprints-confirm-shortcut", function(event)
    gui.confirm_selection(event.player_index)
end)