for _, value in pairs(data.raw["assembling-machine"]) do
    if value.crafting_categories then
        value.crafting_categories[#value.crafting_categories+1] = "parameters-category"
    end
end