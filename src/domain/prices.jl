"""
    TimestampedPrice

A single energy price entry with a timestamp.

# Fields
- `timestamp::DateTime` — Time at which the price applies.
- `value::EnergyPrice_MWh` — Energy price in euros per MWh.
"""
struct TimestampedPrice
    timestamp::DateTime
    value::EnergyPrice_MWh
end

"""
    to_dto(price::TimestampedPrice) -> Dict{String,Any}

Convert a `TimestampedPrice` to a DTO dictionary for serialization.
"""
function to_dto(price::TimestampedPrice)
    Dict{String,Any}(
        "from" => price.timestamp,
        "price" => price.value,
    )
end

"""
    TimestampedPrices

Collection of timestamped energy prices, split into all prices and current prices.

# Fields
- `all::Vector{TimestampedPrice}` — All prices (sorted by timestamp).
- `current::Vector{TimestampedPrice}` — Prices applicable to the current timestep.
"""
mutable struct TimestampedPrices
    all::Vector{TimestampedPrice}
    current::Vector{TimestampedPrice}
end

"""
    TimestampedPrices(prices::Vector{TimestampedPrice}) -> TimestampedPrices

Construct a `TimestampedPrices` from an unsorted vector of prices. Sorts by timestamp.
"""
function TimestampedPrices(prices::Vector{TimestampedPrice})
    TimestampedPrices(sort(prices, by=p -> p.timestamp), TimestampedPrice[])
end

"""
    read_from_csv(::Type{TimestampedPrices}, file::Union{String,Nothing}) -> TimestampedPrices

Read timestamped prices from a CSV file. Not yet implemented.
"""
function read_from_csv(::Type{TimestampedPrices}, file::Union{String,Nothing})
    if file === nothing
        return TimestampedPrices(TimestampedPrice[])
    end
    # TODO: replace csv reader when implementing IO utilities
    error("CSV reading not yet implemented for TimestampedPrices")
end

"""
    update!(prices::TimestampedPrices, datapoint::Datapoint) -> Nothing

Update the price collections by dropping expired prices and refreshing current prices.
"""
function update!(prices::TimestampedPrices, datapoint::Datapoint)
    drop_too_old!(prices, datapoint)
    update_current!(prices, datapoint)
end

"""
    drop_too_old!(prices::TimestampedPrices, datapoint::Datapoint) -> Nothing

Remove prices whose timestamps are before the current datapoint's start.
"""
function drop_too_old!(prices::TimestampedPrices, datapoint::Datapoint)
    all = prices.all
    first_future_index = findfirst(p -> p.timestamp > datapoint.start_, all)
    future_prices = if first_future_index !== nothing
        all[first_future_index:end]
    else
        TimestampedPrice[]
    end
    current_price = TimestampedPrice[]
    if first_future_index === nothing && !isempty(all) && last(all).timestamp <= datapoint.start_
        push!(current_price, TimestampedPrice(datapoint.start_, last(all).value))
    elseif first_future_index !== nothing && first_future_index > 1
        push!(current_price, TimestampedPrice(datapoint.start_, all[first_future_index - 1].value))
    end
    prices.all = vcat(current_price, future_prices)
end

"""
    update_current!(prices::TimestampedPrices, datapoint::Datapoint) -> Nothing

Update the current prices to those applicable within the current timestep.
"""
function update_current!(prices::TimestampedPrices, datapoint::Datapoint)
    prices.current = filter(p -> p.timestamp < datapoint.end_, prices.all)
end
