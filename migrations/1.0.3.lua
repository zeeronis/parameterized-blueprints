for index, force in pairs(game.forces) do
    local technologies = force.technologies
    local recipes = force.recipes

    recipes["placeholder-stack-size-combinator"].enabled = technologies["circuit-network"].researched
  end