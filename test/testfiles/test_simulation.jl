using Test
using Dates

@testset "SimulationConfig - defaults" begin
    config = SimulationConfig(
        start="2022-01-01",
        duration="24h",
        algorithm="test",
        scenario="test",
    )
    @test config.start == "2022-01-01"
    @test config.duration == "24h"
    @test config.algorithm == "test"
    @test config.output.datapoints.writer == "single"
end

@testset "SimulationConfig - custom output" begin
    config = SimulationConfig(
        start="2022-01-01",
        duration="24h",
        algorithm="test",
        scenario="test",
        output=OutputConfig(
            datapoints=DatapointsOutputConfig(
                writer="daily",
                filename_pattern="out_{date}.json",
                split_time="daily",
            ),
        ),
    )
    @test config.output.datapoints.writer == "daily"
    @test config.output.datapoints.split_time == "daily"
end

@testset "SimulationState - creation" begin
    config = SimulationConfig(
        start="2022-01-01",
        duration="24h",
        algorithm="test",
        scenario="test",
    )
    state = SimulationState(config)
    @test state.current_time == DateTime(2022,1,1)
    @test state.stop == false
    @test isempty(state.vehicles)
    @test isempty(state.evses)
end

@testset "NetworkStateContainer - default constructor" begin
    nsc = NetworkStateContainer("net_1")
    @test nsc.id_ == "net_1"
    @test nsc.frequency == 50.0
    @test nsc.state == NORMAL
end

@testset "NetworkStateContainer - full constructor" begin
    nsc = NetworkStateContainer("net_1", 49.9, ALERT)
    @test nsc.id_ == "net_1"
    @test nsc.frequency == 49.9
    @test nsc.state == ALERT
end

@testset "SpotState - default constructor" begin
    ss = SpotState("spot_1")
    @test ss.id_ == "spot_1"
    @test isempty(ss.day_ahead_prices)
end

@testset "SpotState - with prices" begin
    ss = SpotState("spot_1", [TimestampedPrice(DateTime(2022,1,1), 50.0)])
    @test length(ss.day_ahead_prices) == 1
end

@testset "EvseState creation" begin
    model = EvseModel(
        power_losses=PowerLosses(standby=0.5, variable=VariablePowerLosses(charging=0.05, discharging=0.05)),
        max_charge_power=22.0,
    )
    es = EvseState(
        "evse_1", "s1", model, nothing,
        0.0, 0.0, 0, 0, 0, 0,
    )
    @test es.id_ == "evse_1"
    @test es.vehicle_id === nothing
    @test es.primary_capacity == 0
end

@testset "SiteState creation" begin
    ss = SiteState("site_1", nothing, TimestampedPrice[], EvseId[])
    @test ss.id_ == "site_1"
    @test ss.delivery_point === nothing
    @test isempty(ss.evses_ids)
end
