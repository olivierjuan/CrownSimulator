using Test
using Dates

@testset "EnergyNeed" begin
    en = EnergyNeed(period=TimeRange(DateTime(2022,1,1), DateTime(2022,1,2)), value=15.0)
    @test en.value == 15.0
    @test en.period.from == DateTime(2022,1,1)
end
