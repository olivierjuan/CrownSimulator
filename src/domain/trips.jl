"""
    VehicleTrip

Represents a vehicle trip with start and destination times.

# Fields
- `start::DateTime` — Start time of the trip.
- `destination::DateTime` — Arrival time at the destination.
"""
Base.@kwdef struct VehicleTrip
    start::DateTime
    destination::DateTime
end

"""
    FutureTransactionSeed

Represents a seed for a future transaction, based on a vehicle trip.

# Fields
- `trip::VehicleTrip` — The vehicle trip associated with this future transaction.
"""
Base.@kwdef struct FutureTransactionSeed
    trip::VehicleTrip
end

"""
    to_dto(trip::VehicleTrip) -> Dict{String,Any}

Convert a `VehicleTrip` to a DTO dictionary for serialization.
"""
function to_dto(trip::VehicleTrip)
    Dict{String,Any}(
        "start" => string(trip.start),
        "destination" => string(trip.destination),
    )
end

"""
    to_dto(seed::FutureTransactionSeed) -> Dict{String,Any}

Convert a `FutureTransactionSeed` to a DTO dictionary for serialization.
"""
function to_dto(seed::FutureTransactionSeed)
    Dict{String,Any}("trip" => to_dto(seed.trip))
end
