using Test
using Dates

@testset "BiddingService - defaults" begin
    bs = BiddingService()
    @test bs.default_announced == 100.0
    @test isempty(bs.capacities)
    @test bs.from_csv == false
end

@testset "BiddingService - with value" begin
    bs = BiddingService(50.0)
    @test bs.default_announced == 50.0
end

@testset "CapacityRequirement - narrow" begin
    cr = CapacityRequirement(
        TimeRange(DateTime(2022,1,1,0), DateTime(2022,1,1,12)),
        10.0,
        8.0,
    )
    narrowed = narrow(cr, DateTime(2022,1,1,6), DateTime(2022,1,1,10))
    @test narrowed.period.from == DateTime(2022,1,1,6)
    @test narrowed.period.to == DateTime(2022,1,1,10)
    @test narrowed.capacity_up == 10.0
    @test narrowed.capacity_down == 8.0
end

@testset "CapacityRequirement - narrow partial overlap" begin
    cr = CapacityRequirement(
        TimeRange(DateTime(2022,1,1,0), DateTime(2022,1,1,12)),
        10.0,
        8.0,
    )
    narrowed = narrow(cr, DateTime(2022,1,1,6), DateTime(2022,1,1,18))
    @test narrowed.period.from == DateTime(2022,1,1,6)
    @test narrowed.period.to == DateTime(2022,1,1,12)
end

@testset "CapacityRequirement - narrow full overlap" begin
    cr = CapacityRequirement(
        TimeRange(DateTime(2022,1,1,0), DateTime(2022,1,1,12)),
        10.0,
        8.0,
    )
    narrowed = narrow(cr, DateTime(2022,1,1,0), DateTime(2022,1,1,12))
    @test narrowed.period.from == DateTime(2022,1,1,0)
    @test narrowed.period.to == DateTime(2022,1,1,12)
end
