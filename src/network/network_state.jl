"""
    NetworkStateContainer

Mutable state container for an electrical network in the simulation. Implements `AbstractNetworkAgent`.

# Fields
- `id::String` — Network identifier.
- `frequency::Frequency_Hz` — Current grid frequency in Hz (default: 50.0).
- `state::NetworkState` — Current network state (default: NORMAL).
"""
mutable struct NetworkStateContainer <: AbstractNetworkAgent
    id_::String
    frequency::Frequency_Hz
    state::NetworkState
end

"""
    NetworkStateContainer(id::String) -> NetworkStateContainer

Construct a `NetworkStateContainer` with default frequency (50.0 Hz) and NORMAL state.
"""
NetworkStateContainer(id::String) = NetworkStateContainer(id, 50.0, NetworkState.NORMAL)

"""
    register!(n::NetworkStateContainer, context) -> Nothing

Register a network state with the simulation context. Currently a no-op.
"""
function register!(n::NetworkStateContainer, context)
    # Network is part of the simulation state
end

"""
    initialize(n::NetworkStateContainer) -> Nothing

Initialize a network state before simulation starts. Currently a no-op.
"""
function initialize(n::NetworkStateContainer)
    # No initialization needed for network
end

"""
    update!(n::NetworkStateContainer, dt::Float64, current_time::DateTime) -> Nothing

Update a network state for the current timestep. Currently a no-op (network state is updated by external inputs).

# Arguments
- `n::NetworkStateContainer` — The network state to update.
- `dt::Float64` — Time interval in seconds.
- `current_time::DateTime` — Current simulation time.
"""
function update!(n::NetworkStateContainer, dt::Float64, current_time::DateTime)
    # Network state is updated by external inputs
end

"""
    snapshot(n::NetworkStateContainer) -> ElectricNetworkSnapshot

Take a snapshot of the network state for output.

# Arguments
- `n::NetworkStateContainer` — The network state to snapshot.

# Returns
- An `ElectricNetworkSnapshot` with the network's current data.
"""
function snapshot(n::NetworkStateContainer)
    ElectricNetworkSnapshot(
        frequency=n.frequency,
        state=n.state,
    )
end
