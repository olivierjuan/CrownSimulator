using Test
using Dates

using CachedCrownSim

@testset "TimeRange intersection" begin
    p1 = TimeRange(DateTime(2021,1,1), DateTime(2021,1,2))
    p2 = TimeRange(DateTime(2021,1,1,12), DateTime(2021,1,3))
    inter = Base.intersect(p1, p2)
    @test inter.from == DateTime(2021,1,1,12)
    @test inter.to == DateTime(2021,1,2)
end

@testset "Useful power" begin
    losses = PowerLosses(
        standby=0.5,
        variable=VariablePowerLosses(charging=0.05, discharging=0.05)
    )
    @test get_useful_power(losses, 10.0) ≈ 9.025
end

@testset "Datapoint fields" begin
    dp = Datapoint(
        timestamp=DateTime(2022,1,1),
        start_=DateTime(2022,1,1),
        end_=DateTime(2022,1,2),
        delta_t=Hour(1),
        algorithm="test",
        warmup=false,
        version="1",
        minimize_logs=false
    )
    @test dp.algorithm == "test"
    @test dp.delta_t == Hour(1)
end

@testset "generate_timepoints" begin
    pts = generate_timepoints(DateTime(2022,1,1), DateTime(2022,1,1,3), Hour(1))
    @test length(pts) == 4
    @test pts[1] == DateTime(2022,1,1)
    @test pts[4] == DateTime(2022,1,1,3)
end

@testset "generate_periods" begin
    pts = [DateTime(2022,1,1), DateTime(2022,1,1,1), DateTime(2022,1,1,2)]
    periods = generate_periods(pts)
    @test length(periods) == 2
    @test periods[1].from == DateTime(2022,1,1)
    @test periods[1].to == DateTime(2022,1,1,1)
end
