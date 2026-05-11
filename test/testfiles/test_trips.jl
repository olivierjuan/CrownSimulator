using Test
using Dates

@testset "VehicleTrip" begin
    trip = VehicleTrip(start=DateTime(2022,1,1), destination=DateTime(2022,1,2))
    @test trip.start == DateTime(2022,1,1)
    @test trip.destination == DateTime(2022,1,2)
end

@testset "FutureTransactionSeed" begin
    trip = VehicleTrip(start=DateTime(2022,1,1), destination=DateTime(2022,1,2))
    seed = FutureTransactionSeed(trip=trip)
    @test seed.trip.start == DateTime(2022,1,1)
end
