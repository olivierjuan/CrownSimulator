struct TimestampedPrice
    timestamp::DateTime
    value::EnergyPrice_MWh
end

function to_dto(price::TimestampedPrice)
    Dict{String,Any}(
        "from" => price.timestamp,
        "price" => price.value,
    )
end

struct TimestampedPrices
    all::Vector{TimestampedPrice}
    current::Vector{TimestampedPrice}
end

function TimestampedPrices(prices::Vector{TimestampedPrice})
    TimestampedPrices(sort(prices, by=p -> p.timestamp), TimestampedPrice[])
end

function read_from_csv(::Type{TimestampedPrices}, file::Union{String,Nothing})
    if file === nothing
        return TimestampedPrices(TimestampedPrice[])
    end
    # TODO: replace csv reader when implementing IO utilities
    throw(MethodError("CSV reading not yet implemented"))
end

function update!(prices::TimestampedPrices, datapoint::Datapoint)
    drop_too_old!(prices, datapoint)
    update_current!(prices, datapoint)
end

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

function update_current!(prices::TimestampedPrices, datapoint::Datapoint)
    prices.current = filter(p -> p.timestamp < datapoint.end_, prices.all)
end
