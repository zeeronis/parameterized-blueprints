local entities = {}

entities.placeholder_pattern_string = "placeholder%-[0-9]$"
entities.placeholder_item_rich_text_pattern_string = "%[item=placeholder%-[0-9]%]"

entities.check_for_placeholder_values = function (entity, info)
    -- recipe check (assemblers)
    if entity.recipe then
        if entities.check_name(entity.recipe, info) then return end
    end

    -- inserter filters
    if entity.filters then
        for _, filter in ipairs(entity.filters) do
            if entities.check_name(filter.name, info) then return end
        end
    end

    -- splitter filter
    if entity.filter then
        if entities.check_name(entity.filter, info) then return end
    end

    -- requests check (requester chests)
    if entity.request_filters then
        for _, filter in ipairs(entity.request_filters) do
            if entities.check_name(filter.name, info) then return end
        end
    end

    -- train stations
    if entity.station then
        -- iterate through all matches
        for s in string.gmatch(entity.station, entities.placeholder_item_rich_text_pattern_string) do
            info.is_parameterizable = true
            info["uses_" .. string.match(s, "[0-9]")] = true
            -- don't return - train stations can also have a control behaviour
        end
    end

    if entity.schedule then
        for index, stop in ipairs(entity.schedule) do
            for s in string.gmatch(stop.station, entities.placeholder_item_rich_text_pattern_string) do
                info.is_parameterizable = true
                info["uses_" .. string.match(s, "[0-9]")] = true
            end
            entities.find_placeholders_in_train_wait_conditions(stop.wait_conditions, info)
        end
        return
    end

    if entity.control_behavior then
        local behavior = entity.control_behavior

        -- don't return from the first two - generic implementations may have others afterwards
        -- generic wired hook
        if behavior.circuit_condition then
            entities.do_signal_check(behavior.circuit_condition, info)
        end
        -- generic logisitics hook
        if behavior.logistic_condition then
            entities.do_signal_check(behavior.logistic_condition, info)
        end

        -- decider combinator
        if behavior.decider_conditions then
            if entities.do_signal_check(behavior.decider_conditions, info) then return end
        end
        -- arithmetic combinator
        if behavior.arithmetic_conditions then
            if entities.do_signal_check(behavior.arithmetic_conditions, info) then return end
        end

        -- constant combinator
        if behavior.filters then
            for _, filter in ipairs(behavior.filters) do
                if entities.check_name(filter.signal.name, info) then return end
            end
        end

        -- train limit signal
        if behavior.trains_limit_signal then
            if entities.check_name(behavior.trains_limit_signal.name, info) then return end
        end
    end
end

entities.replace_placeholder_value = function (entity, changes)
    -- recipe check (assemblers)
    if entity.recipe then
        local name = entities.is_placeholder_name(entity.recipe)
        if name then entity.recipe = changes.recipes[name] end
    end

    -- inserter filters
    if entity.filters then
        for i, filter in ipairs(entity.filters) do
            local name = entities.is_placeholder_name(filter.name)
            if name then
                if changes.items[name] then
                    filter.name = changes.items[name]
                else
                    entity.filters[i] = nil
                end
            end
        end
    end

    -- splitter filter
    if entity.filter then
        local name = entities.is_placeholder_name(entity.filter)
        if name then
            if changes.items[name] then
                entity.filter = changes.items[name]
            else
                entity.filter = nil
            end
        end
    end

    if entity.control_behavior then
        local behavior = entity.control_behavior

        -- generic wired hook
        if behavior.circuit_condition then
            entities.replace_signals(behavior.circuit_condition, changes)
        end
        -- generic logisitics hook
        if behavior.logistic_condition then
            entities.replace_signals(behavior.logistic_condition, changes)
        end
        -- decider combinator
        if behavior.decider_conditions then
            entities.replace_signals(behavior.decider_conditions, changes)
        end
        -- arithmetic combinator
        if behavior.arithmetic_conditions then
            entities.replace_signals(behavior.arithmetic_conditions, changes)
        end
        -- constant combinator
        if behavior.filters then
            for _, filter in ipairs(behavior.filters) do
                local name = entities.is_placeholder_name(filter.signal.name)
                if name then filter.signal = changes.signals[name] end
            end
        end

        -- train limit
        if behavior.trains_limit_signal then
            local name = entities.is_placeholder_name(behavior.trains_limit_signal.name)
            if name then behavior.trains_limit_signal = changes.signals[name] end
        end
    end

    -- requests check (requester chests)
    if entity.request_filters then
        for i, filter in ipairs(entity.request_filters) do
            local name = entities.is_placeholder_name(filter.name)
            if name then
                if changes.items[name] then
                    filter.name = changes.items[name]
                else
                    entity.request_filters[i] = nil
                end
            end
        end
    end

    -- train stations
    if entity.station then
        entity.station = entities.replace_rich_text(entity.station, changes)
    end

    -- train schedule targets
    if entity.schedule then
        for index, value in ipairs(entity.schedule) do
            entity.schedule[index].station = entities.replace_rich_text(value.station, changes)
            entities.replace_placeholders_in_train_wait_conditions(value.wait_conditions, changes)
        end
    end
end

entities.is_placeholder_name = function (name)
    return string.match(name, entities.placeholder_pattern_string)
end

entities.check_name = function (name, info)
    if entities.is_placeholder_name(name) then
        info.is_parameterizable = true
        info["uses_" .. string.match(name, "[0-9]")] = true
        return true
    end
    return false
end

entities.do_signal_check = function (condition, info)
    local found_any = false
    if condition.first_signal and condition.first_signal.name then
        if entities.check_name(condition.first_signal.name, info) then found_any = true end
    end
    if condition.second_signal and condition.second_signal.name then
        if entities.check_name(condition.second_signal.name, info) then found_any = true end
    end
    if condition.output_signal and condition.output_signal.name then
        if entities.check_name(condition.output_signal.name, info) then found_any = true end
    end
    return found_any
end

entities.replace_signals = function (condition, changes)
    if condition.first_signal and condition.first_signal.name then
        local name = entities.is_placeholder_name(condition.first_signal.name)
        if name then condition.first_signal = changes.signals[name] end
    end
    if condition.second_signal and condition.second_signal.name then
        local name = entities.is_placeholder_name(condition.second_signal.name)
        if name then condition.second_signal = changes.signals[name] end
    end
    if condition.output_signal and condition.output_signal.name then
        local name = entities.is_placeholder_name(condition.output_signal.name)
        if name then condition.output_signal = changes.signals[name] end
    end
end 

entities.replace_rich_text = function (in_string, changes)
    local result = in_string
    for s in string.gmatch(in_string, entities.placeholder_item_rich_text_pattern_string) do
        local number_found = string.match(s, "[0-9]")
        result = string.gsub(result, "%[item=placeholder%-" .. number_found .. "%]", entities.get_rich_text_for_signal(changes.signals["placeholder-" .. number_found]))
    end
    return result
end

entities.get_rich_text_for_signal = function (signal)
    if signal then
        if signal.type and signal.name then
            return "[" .. signal.type .. "=" .. signal.name .. "]"
        end
    end
    return ""
end

entities.find_placeholders_in_train_wait_conditions = function(wait_conditions, info)
    if wait_conditions == nil then return end

    for _, value in ipairs(wait_conditions) do
        if value.condition then -- value.condition is present only on relevant entries
            entities.do_signal_check(value.condition, info)
        end
    end
end

entities.replace_placeholders_in_train_wait_conditions = function (wait_conditions, changes)
    if wait_conditions == nil then return end

    for _, value in ipairs(wait_conditions) do
        if value.condition then -- value.condition is present only on relevant entries
            entities.replace_signals(value.condition, changes)

            -- I think it's fine to leave it like this
            -- may be better to remove it even
            -- the condition will never be true if first is fluid and second is item or the other way around
            -- but we need it to handle having at least one set correctly
            if value.condition.first_signal then
                if value.condition.first_signal.type == "fluid" and value.type == "item_count" then
                    value.type = "fluid_count"
                elseif value.condition.first_signal.type == "item" and value.type == "fluid_count" then
                    value.type = "item_count"
                end
            end
            if value.condition.second_signal then
                if value.condition.second_signal.type == "fluid" and value.type == "item_count" then
                    value.type = "fluid_count"
                elseif value.condition.second_signal.type == "item" and value.type == "fluid_count" then
                    value.type = "item_count"
                end
            end
        end
    end
end

return entities