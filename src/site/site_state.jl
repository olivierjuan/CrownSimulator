"""
    SiteState

Mutable state for a site in the simulation. Implements `AbstractSiteAgent`.

# Fields
- `id_::SiteId` — Site identifier.
- `delivery_point::Union{DeliveryPoint,Nothing}` — Optional delivery point for this site.
- `customer_tariffs::Vector{TimestampedPrice}` — Customer tariff prices.
- `evses_ids::Vector{EvseId}` — Identifiers of EVSEs at this site.
"""
mutable struct SiteState <: AbstractSiteAgent
    id_::SiteId
    delivery_point::Union{DeliveryPoint,Nothing}
    customer_tariffs::Vector{TimestampedPrice}
    evses_ids::Vector{EvseId}
end

"""
    register!(s::SiteState, context) -> Nothing

Register a site state with the simulation context. Currently a no-op.

# Arguments
- `s::SiteState` — The site state to register.
- `context` — The simulation context.
"""
function register!(s::SiteState, context)
    # Site is part of the simulation state
end

"""
    initialize(s::SiteState) -> Nothing

Initialize a site state before simulation starts. Currently a no-op.
"""
function initialize(s::SiteState)
    # No initialization needed for sites
end

"""
    update!(s::SiteState, dt::Float64, current_time::DateTime) -> Nothing

Update a site state for the current timestep. Currently a no-op (site state is updated by aggregator).

# Arguments
- `s::SiteState` — The site state to update.
- `dt::Float64` — Time interval in seconds.
- `current_time::DateTime` — Current simulation time.
"""
function update!(s::SiteState, dt::Float64, current_time::DateTime)
    # Site state is updated by aggregator
end

"""
    snapshot(s::SiteState) -> SiteSnapshot

Take a snapshot of the site's current state for output.

# Arguments
- `s::SiteState` — The site state to snapshot.

# Returns
- A `SiteSnapshot` with the site's current data.
"""
function snapshot(s::SiteState)
    SiteSnapshot(
        delivery_point=s.delivery_point,
        customer_tariffs=s.customer_tariffs,
    )
end
