for _, value in pairs(data.raw["assembling-machine"]) do
    if value.crafting_categories then
        value.crafting_categories[#value.crafting_categories+1] = "parameters-category"
    end
end

for _, value in pairs(data.raw["module"]) do
    if value.name:find("productivity%-module") then
        for i = 0, 9, 1 do
            value.limitation[#value.limitation+1] = "placeholder-" .. i
        end
      end
end