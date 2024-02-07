require("__core__/lualib/util")

local circuit_network_tech = data.raw["technology"]["circuit-network"]
circuit_network_tech.effects[#circuit_network_tech.effects+1] = { type="unlock-recipe", recipe="placeholder-stack-size-combinator" }