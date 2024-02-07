require("__core__/lualib/util")

local combinator_entity = util.table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
combinator_entity.name = "placeholder-stack-size-combinator"
combinator_entity.minable.result = "placeholder-stack-size-combinator"
data:extend({combinator_entity})