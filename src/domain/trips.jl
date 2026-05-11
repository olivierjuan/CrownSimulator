Base.@kwdef struct VehicleTrip
    start::DateTime
    destination::DateTime
end

Base.@kwdef struct FutureTransactionSeed
    trip::VehicleTrip
end
