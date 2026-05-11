mutable struct SpotState
    id_::SpotMarketAccessId
    day_ahead_prices::Vector{TimestampedPrice}
end

SpotState(id_::SpotMarketAccessId) = SpotState(id_, TimestampedPrice[])
