using ConcurrentSim
using Dates

mutable struct SimulationState
    config::SimulationConfig
    current_time::DateTime
    stop::Bool
    vehicles::Vector{VehicleState}
    evses::Vector{EvseState}
    site::SiteState
end

function SimulationState(config::SimulationConfig)
    start_time = DateTime(config.start)
    SimulationState(config, start_time, false, VehicleState[], EvseState[], SiteState("", nothing, [], []))
end

@resumable function batch_update_process(sim::Simulation, state::SimulationState)
    end_time = now(sim) + Hour(1) # placeholder horizon
    while !state.stop && now(sim) < end_time
        @yield timeout(sim, Minute(1))
        state.current_time += Minute(1)
        # TODO: vectorized batch update of connected SoC and EVSE states
        println("Tick at $(state.current_time)")
    end
end

function run_simulation(config::SimulationConfig)
    sim = Simulation()
    state = SimulationState(config)
    @process batch_update_process(sim, state)
    run(sim)
end
