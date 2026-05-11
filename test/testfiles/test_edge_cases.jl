using Test
using Dates

@testset "PowerLimits - negative power values" begin
    se = PowerLimits(max_charge_power=-1.0, min_charge_power=-5.0)
    @test_throws ArgumentError cross_max_and_min_charge_power(se, -2.0, -3.0)
end

@testset "PowerLimits - equal values" begin
    se = PowerLimits(max_charge_power=10.0, min_charge_power=5.0)
    crossed = cross_max_and_min_charge_power(se, 10.0, 5.0)
    @test crossed.max_charge_power == 10.0
    @test crossed.min_charge_power == 5.0
end

@testset "SocPowerTableItem - zero values" begin
    item = SocPowerTableItem(soc=0, power=0.0)
    dto = to_dto(item; capacity=60.0)
    @test dto["soc"] == 0
    @test dto["maxChargePower"] == 0
end

@testset "SocPowerTableItem - max values" begin
    item = SocPowerTableItem(soc=100, power=250.0)
    dto = to_dto(item; capacity=60.0)
    @test dto["soc"] == 60000
    @test dto["maxChargePower"] == 250000
end

@testset "SocPowerTable - empty" begin
    table = SocPowerTable(SocPowerTableItem[])
    dtos = to_dto(table; capacity=60.0)
    @test isempty(dtos)
end

@testset "FrequencyActivationTable - empty" begin
    table = FrequencyActivationTable(mappings=FrequencyActivationMapping[])
    dtos = to_dto(table)
    @test isempty(dtos)
end

@testset "TimeRange - zero-length" begin
    tr = TimeRange(DateTime(2022,1,1), DateTime(2022,1,1))
    @test (DateTime(2022,1,1) in tr) === false
end

@testset "TimeRange - very short range" begin
    tr = TimeRange(DateTime(2022,1,1,0,0,0), DateTime(2022,1,1,0,0,1))
    @test DateTime(2022,1,1,0,0,0) in tr
    @test !(DateTime(2022,1,1,0,0,1) in tr)
end

@testset "generate_timepoints - zero duration" begin
    pts = generate_timepoints(DateTime(2022,1,1), DateTime(2022,1,1), Hour(1))
    @test length(pts) == 1
end

@testset "generate_periods - empty vector" begin
    periods = generate_periods(DateTime[])
    @test isempty(periods)
end

@testset "TimestampedPrices - drop_too_old empty" begin
    prices = TimestampedPrices(TimestampedPrice[])
    dp = Datapoint(
        timestamp=DateTime(2022,1,1),
        start_=DateTime(2022,1,1),
        end_=DateTime(2022,1,2),
        delta_t=Hour(1),
        algorithm="test",
        warmup=false,
        version="1",
        minimize_logs=false,
    )
    update!(prices, dp)
    @test isempty(prices.all)
end
