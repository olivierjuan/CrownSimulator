"""
    SpotState

Mutable state for a spot market in the simulation. Implements `AbstractSpotAgent`.

# Fields
- `id_::SpotMarketAccessId` — Spot market access identifier.
- `day_ahead_prices::Vector{TimestampedPrice}` — Day-ahead energy prices.
"""
mutable struct SpotState <: AbstractSpotAgent
    id_::SpotMarketAccessId
    day_ahead_prices::Vector{TimestampedPrice}
end

"""
    SpotState(id_::SpotMarketAccessId) -> SpotState

Construct a `SpotState` with an empty day-ahead price list.
"""
SpotState(id_::SpotMarketAccessId) = SpotState(id_, TimestampedPrice[])

"""
    register!(s::SpotState, context) -> Nothing

Register a spot state with the simulation context. Currently a no-op.
"""
function register!(s::SpotState, context)
    # Spot is part of the simulation state
end

"""
    initialize(s::SpotState) -> Nothing

Initialize a spot state before simulation starts. Currently a no-op.
"""
function initialize(s::SpotState)
    # No initialization needed for spot
end

"""
    update!(s::SpotState, dt::Float64, current_time::DateTime) -> Nothing

Update a spot state for the current timestep. Currently a no-op (spot state is updated by external inputs).

# Arguments
- `s::SpotState` — The spot state to update.
- `dt::Float64` — Time interval in seconds.
- `current_time::DateTime` — Current simulation time.
"""
function update!(s::SpotState, dt::Float64, current_time::DateTime)
    # Spot state is updated by external inputs
end

"""
    snapshot(s::SpotState) -> SpotSnapshot

Take a snapshot of the spot state for output.

# Arguments
- `s::SpotState` — The spot state to snapshot.

# Returns
- A `SpotSnapshot` with the spot's current data.
"""
function snapshot(s::SpotState)
    SpotSnapshot(
        day_ahead_prices=s.day_ahead_prices,
    )
end
