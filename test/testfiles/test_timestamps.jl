using Test
using Dates

@testset "TimeRange intersection" begin
    p1 = TimeRange(DateTime(2021,1,1), DateTime(2021,1,2))
    p2 = TimeRange(DateTime(2021,1,1,12), DateTime(2021,1,3))
    inter = Base.intersect(p1, p2)
    @test inter.from == DateTime(2021,1,1,12)
    @test inter.to == DateTime(2021,1,2)
end

@testset "TimeRange intersection - no overlap" begin
    p1 = TimeRange(DateTime(2021,1,1), DateTime(2021,1,2))
    p2 = TimeRange(DateTime(2021,1,3), DateTime(2021,1,4))
    @test Base.intersect(p1, p2) === nothing
end

@testset "TimeRange intersection - touching edges" begin
    p1 = TimeRange(DateTime(2021,1,1), DateTime(2021,1,2))
    p2 = TimeRange(DateTime(2021,1,2), DateTime(2021,1,3))
    @test Base.intersect(p1, p2) === nothing
end

@testset "TimeRange intersection - identical" begin
    p1 = TimeRange(DateTime(2021,1,1), DateTime(2021,1,2))
    inter = Base.intersect(p1, p1)
    @test inter.from == DateTime(2021,1,1)
    @test inter.to == DateTime(2021,1,2)
end

@testset "TimeRange in - DateTime" begin
    tr = TimeRange(DateTime(2021,1,1), DateTime(2021,1,2))
    @test DateTime(2021,1,1) in tr
    @test DateTime(2021,1,1,12) in tr
    @test !(DateTime(2021,1,2) in tr)
    @test !(DateTime(2020,12,31) in tr)
end

@testset "TimeRange in - TimeRange" begin
    outer = TimeRange(DateTime(2021,1,1), DateTime(2021,1,3))
    inner = TimeRange(DateTime(2021,1,1,12), DateTime(2021,1,2))
    @test inner in outer
    @test !(outer in inner)
end

@testset "generate_timepoints" begin
    pts = generate_timepoints(DateTime(2022,1,1), DateTime(2022,1,1,3), Hour(1))
    @test length(pts) == 4
    @test pts[1] == DateTime(2022,1,1)
    @test pts[4] == DateTime(2022,1,1,3)
end

@testset "generate_timepoints - single point" begin
    pts = generate_timepoints(DateTime(2022,1,1), DateTime(2022,1,1), Hour(1))
    @test length(pts) == 1
    @test pts[1] == DateTime(2022,1,1)
end

@testset "generate_timepoints - minute interval" begin
    pts = generate_timepoints(DateTime(2022,1,1), DateTime(2022,1,1,0,5), Minute(1))
    @test length(pts) == 6
end

@testset "generate_periods" begin
    pts = [DateTime(2022,1,1), DateTime(2022,1,1,1), DateTime(2022,1,1,2)]
    periods = generate_periods(pts)
    @test length(periods) == 2
    @test periods[1].from == DateTime(2022,1,1)
    @test periods[1].to == DateTime(2022,1,1,1)
end

@testset "generate_periods - single timepoint" begin
    pts = [DateTime(2022,1,1)]
    periods = generate_periods(pts)
    @test length(periods) == 0
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
    @test dp.warmup == false
    @test dp.version == "1"
end

@testset "Datapoint - warmup flag" begin
    dp = Datapoint(
        timestamp=DateTime(2022,1,1),
        start_=DateTime(2022,1,1),
        end_=DateTime(2022,1,2),
        delta_t=Minute(15),
        algorithm="algo",
        warmup=true,
        version="2",
        minimize_logs=true
    )
    @test dp.warmup == true
    @test dp.minimize_logs == true
    @test dp.delta_t == Minute(15)
end

@testset "OptimizationHorizon" begin
    oh = OptimizationHorizon(DateTime(2022,1,1), DateTime(2022,1,2), Hour(1))
    @test oh.start == DateTime(2022,1,1)
    @test oh.stop == DateTime(2022,1,2)
    @test oh.period_duration == Hour(1)
end
