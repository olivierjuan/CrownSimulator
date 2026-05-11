mutable struct SiteState
    id_::SiteId
    delivery_point::Union{DeliveryPoint,Nothing}
    customer_tariffs::Vector{TimestampedPrice}
    evses_ids::Vector{EvseId}
end
