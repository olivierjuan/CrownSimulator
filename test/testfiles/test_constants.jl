using Test
using Dates

@testset "Type aliases" begin
    @test Float64 <: Energy_kWh
    @test Float64 <: Power_kW
    @test Float64 <: Power_W
    @test Float64 <: Ratio
    @test Float64 <: Frequency_Hz
    @test Float64 <: EnergyPrice_MWh
    @test Float64 <: EnergyConsumption_Wh_minute
    @test String <: VehicleId
    @test String <: EvseId
    @test String <: SiteId
    @test String <: TransactionId
    @test String <: SpotMarketAccessId
end

@testset "CurrentType enum" begin
    @test AC == AC
    @test DC == DC
    @test AC != DC
end
