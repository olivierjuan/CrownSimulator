mutable struct NetworkStateContainer <: AbstractNetworkAgent
    id_::String
    frequency::Frequency_Hz
    state::NetworkState
end

NetworkStateContainer(id_::String) = NetworkStateContainer(id_, 50.0, NetworkState.NORMAL)

function register!(n::NetworkStateContainer, context)
    # Network is part of the simulation state
end

function initialize(n::NetworkStateContainer)
    # No initialization needed for network
end

function update!(n::NetworkStateContainer, dt::Float64, current_time::DateTime)
    # Network state is updated by external inputs
end

function snapshot(n::NetworkStateContainer)
    ElectricNetworkSnapshot(
        frequency=n.frequency,
        state=n.state,
    )
end
