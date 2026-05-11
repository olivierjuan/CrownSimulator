using CachedCrownSim
using Dates

function main()
    config = SimulationConfig(
        start = string(now() - Day(1)),
        duration = "PT1H",
        algorithm = "test",
        scenario = "default"
    )
    run_simulation(config)
end
