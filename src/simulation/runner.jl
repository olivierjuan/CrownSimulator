using ConcurrentSim
using Dates

"""
    SimulationState

Mutable state container for the simulation, holding all agent fleet states.

# Fields
- `config::SimulationConfig` — Configuration for this simulation run.
- `current_time::DateTime` — Current simulation time.
- `stop::Bool` — Whether the simulation has been stopped.
- `vehicles::Vector{VehicleState}` — All vehicle states.
- `evses::Vector{EvseState}` — All EVSE states.
- `site::SiteState` — Site state.
- `network::NetworkStateContainer` — Network state.
- `spot::SpotState` — Spot market state.
"""
mutable struct SimulationState
    config::SimulationConfig
    current_time::DateTime
    stop::Bool
    vehicles::Vector{VehicleState}
    evses::Vector{EvseState}
    site::SiteState
    network::NetworkStateContainer
    spot::SpotState
end

"""
    SimulationState(config::SimulationConfig) -> SimulationState

Construct a `SimulationState` from a configuration, initializing all agent states to empty.

# Arguments
- `config::SimulationConfig` — Simulation configuration.

# Returns
- A new `SimulationState` with empty fleets and zeroed state.
"""
function SimulationState(config::SimulationConfig)
    start_time = DateTime(config.start)
    SimulationState(
        config,
        start_time,
        false,
        VehicleState[],
        EvseState[],
        SiteState("", nothing, TimestampedPrice[], EvseId[]),
        NetworkStateContainer(""),
        SpotState(SpotMarketAccessId("")),
    )
end

"""
    initialize_agents!(state::SimulationState) -> Nothing

Initialize all agents in the simulation state (vehicles, EVSEs, site, network, spot).

# Arguments
- `state::SimulationState` — The simulation state containing all agent fleets.
"""
function initialize_agents!(state::SimulationState)
    for v in state.vehicles
        initialize(v)
    end
    for e in state.evses
        initialize(e)
    end
    initialize(state.site)
    initialize(state.network)
    initialize(state.spot)
end

"""
    batch_update_process(sim::Simulation, state::SimulationState) -> Nothing

A ConcurrentSim process that runs the batch update loop for all agents, advancing the
simulation time in 1-minute steps until the horizon is reached or `state.stop` is set.

# Arguments
- `sim::Simulation` — The ConcurrentSim simulation object.
- `state::SimulationState` — The simulation state to update.

# Notes
- Uses `@yield timeout(sim, Minute(1))` to advance time in 1-minute steps.
- Updates vehicle SoC, EVSE states, site, network, and spot at each step.
"""
@resumable function batch_update_process(sim::Simulation, state::SimulationState)
    step_seconds = 60.0 # 1 minute steps
    last_sim_time = now(sim)
    while !state.stop && now(sim) < last_sim_time + 3600.0 # 1 hour horizon
        @yield timeout(sim, Minute(1))
        current_sim_time = now(sim)
        delta_t = current_sim_time - last_sim_time
        last_sim_time = current_sim_time
        state.current_time += Minute(1)
        # Vectorized batch update of connected SoC and EVSE states
        batch_vehicle_soc_update!(state.vehicles, delta_t)
        for evse in state.evses
            update!(evse, delta_t, state.current_time)
        end
        update!(state.site, delta_t, state.current_time)
        update!(state.network, delta_t, state.current_time)
        update!(state.spot, delta_t, state.current_time)
    end
end

"""
    run_simulation(config::SimulationConfig) -> Nothing

Run a complete simulation from the given configuration.

# Arguments
- `config::SimulationConfig` — Configuration specifying start time, duration, algorithm, and scenario.

# Notes
- Creates a ConcurrentSim simulation, initializes all agents, and starts the batch update process.
"""
function run_simulation(config::SimulationConfig)
    sim = Simulation()
    state = SimulationState(config)
    initialize_agents!(state)
    @process batch_update_process(sim, state)
    run(sim)
end
