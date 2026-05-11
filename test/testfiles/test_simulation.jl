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

# --- Additional integration tests ---

@testset "SimulationState - with vehicles" begin
    config = SimulationConfig(
        start="2022-01-01",
        duration="24h",
        algorithm="test",
        scenario="test",
    )
    state = SimulationState(config)
    model = VehicleModel(
        capacity=60.0, min_soc=5.0, max_soc=55.0,
        max_ac_charge_power=11.0, max_dc_charge_power=50.0,
        power_losses=PowerLosses(standby=0.0, variable=VariablePowerLosses(charging=0.0, discharging=0.0)),
    )
    v = VehicleState(
        id_="v1", site_id="s1", model=model, soc=30.0,
        previous_soc=30.0, power=0.0, noise=0.0,
        connected=true, evse_id="evse_1",
    )
    push!(state.vehicles, v)
    @test length(state.vehicles) == 1
    @test state.vehicles[1].soc == 30.0
end

@testset "SimulationState - with EVSEs" begin
    config = SimulationConfig(
        start="2022-01-01",
        duration="24h",
        algorithm="test",
        scenario="test",
    )
    state = SimulationState(config)
    model = EvseModel(
        power_losses=PowerLosses(standby=0.0, variable=VariablePowerLosses(charging=0.0, discharging=0.0)),
        max_charge_power=22.0,
    )
    es = EvseState("evse_1", "s1", model, nothing, 0.0, 0.0, 0, 0, 0, 0)
    push!(state.evses, es)
    @test length(state.evses) == 1
    @test state.evses[1].id_ == "evse_1"
end

@testset "NetworkStateContainer - state transitions" begin
    nsc = NetworkStateContainer("net_1", 50.0, NORMAL)
    @test nsc.state == NORMAL
    nsc.state = ALERT
    @test nsc.state == ALERT
    nsc.state = EMERGENCY
    @test nsc.state == EMERGENCY
end

@testset "NetworkStateContainer - snapshot" begin
    nsc = NetworkStateContainer("net_1", 49.5, ALERT)
    snap = snapshot(nsc)
    @test snap.frequency == 49.5
    @test snap.state == ALERT
end

@testset "SpotState - update!" begin
    ss = SpotState("spot_1")
    @test isempty(ss.day_ahead_prices)
end

@testset "SimulationConfig - from different start times" begin
    config1 = SimulationConfig(start="2023-06-15", duration="12h", algorithm="test", scenario="test")
    config2 = SimulationConfig(start="2023-12-25", duration="48h", algorithm="test", scenario="test")
    @test config1.start == "2023-06-15"
    @test config2.start == "2023-12-25"
    @test config1.duration == "12h"
    @test config2.duration == "48h"
end

@testset "SimulationState - time advance" begin
    config = SimulationConfig(start="2022-01-01", duration="24h", algorithm="test", scenario="test")
    state = SimulationState(config)
    @test state.current_time == DateTime(2022,1,1)
    state.current_time += Hour(1)
    @test state.current_time == DateTime(2022,1,1,1)
end

@testset "SimulationConfig - all fields" begin
    config = SimulationConfig(
        start="2022-01-01",
        duration="24h",
        algorithm="test",
        scenario="test",
    )
    @test config.start == "2022-01-01"
    @test config.duration == "24h"
    @test config.algorithm == "test"
    @test config.scenario == "test"
end
