mutable struct SiteState <: AbstractSiteAgent
    id_::SiteId
    delivery_point::Union{DeliveryPoint,Nothing}
    customer_tariffs::Vector{TimestampedPrice}
    evses_ids::Vector{EvseId}
end

function register!(s::SiteState, context)
    # Site is part of the simulation state
end

function initialize(s::SiteState)
    # No initialization needed for sites
end

function update!(s::SiteState, dt::Float64, current_time::DateTime)
    # Site state is updated by aggregator
end

function snapshot(s::SiteState)
    SiteSnapshot(
        delivery_point=s.delivery_point,
        customer_tariffs=s.customer_tariffs,
    )
end
