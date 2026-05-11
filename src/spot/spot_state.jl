mutable struct SpotState <: AbstractSpotAgent
    id_::SpotMarketAccessId
    day_ahead_prices::Vector{TimestampedPrice}
end

SpotState(id_::SpotMarketAccessId) = SpotState(id_, TimestampedPrice[])

function register!(s::SpotState, context)
    # Spot is part of the simulation state
end

function initialize(s::SpotState)
    # No initialization needed for spot
end

function update!(s::SpotState, dt::Float64, current_time::DateTime)
    # Spot state is updated by external inputs
end

function snapshot(s::SpotState)
    SpotSnapshot(
        day_ahead_prices=s.day_ahead_prices,
    )
end
