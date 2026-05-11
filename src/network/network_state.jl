mutable struct NetworkStateContainer
    id_::String
    frequency::Frequency_Hz
    state::NetworkState
end

NetworkStateContainer(id_::String) = NetworkStateContainer(id_, 50.0, NetworkState.NORMAL)
