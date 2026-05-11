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

# --- Additional edge case tests ---

@testset "PowerLimits - cross_max with vehicle max lower than EVSE" begin
    evse_limits = PowerLimits(max_charge_power=22.0, min_charge_power=1.0)
    crossed = cross_max_and_min_charge_power(evse_limits, 11.0, 0.0)
    @test crossed.max_charge_power == 11.0
    @test crossed.min_charge_power == 1.0
end

@testset "PowerLimits - cross_max with vehicle max higher than EVSE" begin
    evse_limits = PowerLimits(max_charge_power=11.0, min_charge_power=1.0)
    crossed = cross_max_and_min_charge_power(evse_limits, 22.0, 0.0)
    @test crossed.max_charge_power == 11.0
    @test crossed.min_charge_power == 1.0
end

@testset "PowerLimits - cross_max with vehicle min higher than EVSE" begin
    evse_limits = PowerLimits(max_charge_power=22.0, min_charge_power=1.0)
    crossed = cross_max_and_min_charge_power(evse_limits, 22.0, 5.0)
    @test crossed.max_charge_power == 22.0
    @test crossed.min_charge_power == 5.0
end

@testset "PowerLimits - cross_max with vehicle min and max within EVSE" begin
    evse_limits = PowerLimits(max_charge_power=22.0, min_charge_power=1.0)
    crossed = cross_max_and_min_charge_power(evse_limits, 16.0, 5.0)
    @test crossed.max_charge_power == 16.0
    @test crossed.min_charge_power == 5.0
end

@testset "PowerLimits - cross_max with zero vehicle power" begin
    evse_limits = PowerLimits(max_charge_power=22.0, min_charge_power=1.0)
    crossed = cross_max_and_min_charge_power(evse_limits, 0.0, 0.0)
    @test crossed.max_charge_power == 0.0
    @test crossed.min_charge_power == 1.0
end

@testset "get_useful_power - NaN throws" begin
    losses = PowerLosses(standby=0.0, variable=VariablePowerLosses(charging=0.0, discharging=0.0))
    @test_throws ArgumentError get_useful_power(losses, NaN)
end

@testset "get_useful_power - Inf throws" begin
    losses = PowerLosses(standby=0.0, variable=VariablePowerLosses(charging=0.0, discharging=0.0))
    @test_throws ArgumentError get_useful_power(losses, Inf)
end

@testset "get_useful_power - negative charging loss throws" begin
    losses = PowerLosses(standby=0.0, variable=VariablePowerLosses(charging=-0.1, discharging=0.0))
    @test_throws ArgumentError get_useful_power(losses, 10.0)
end

@testset "get_useful_power - charging loss >= 1 throws" begin
    losses = PowerLosses(standby=0.0, variable=VariablePowerLosses(charging=1.0, discharging=0.0))
    @test_throws ArgumentError get_useful_power(losses, 10.0)
end

@testset "get_useful_power - negative discharging loss throws" begin
    losses = PowerLosses(standby=0.0, variable=VariablePowerLosses(charging=0.0, discharging=-0.1))
    @test_throws ArgumentError get_useful_power(losses, 10.0)
end

@testset "get_useful_power - discharging loss >= 1 throws" begin
    losses = PowerLosses(standby=0.0, variable=VariablePowerLosses(charging=0.0, discharging=1.0))
    @test_throws ArgumentError get_useful_power(losses, 10.0)
end

@testset "get_useful_power - zero power with no standby" begin
    losses = PowerLosses(standby=0.0, variable=VariablePowerLosses(charging=0.05, discharging=0.05))
    @test get_useful_power(losses, 0.0) == 0.0
end

@testset "get_useful_power - with standby" begin
    losses = PowerLosses(standby=0.5, variable=VariablePowerLosses(charging=0.05, discharging=0.05))
    @test get_useful_power(losses, 10.0) ≈ 9.025
end

@testset "get_useful_power - negative power" begin
    losses = PowerLosses(standby=0.0, variable=VariablePowerLosses(charging=0.0, discharging=0.05))
    @test get_useful_power(losses, -10.0) ≈ -10.0 / (1.0 - 0.05)
end

@testset "SocPowerTable - lookup_power exact match" begin
    table = SocPowerTable([
        SocPowerTableItem(soc=20, power=7.0),
        SocPowerTableItem(soc=80, power=22.0),
    ])
    @test lookup_power(table, 80) == 22.0
end

@testset "SocPowerTable - lookup_power nearest lower" begin
    table = SocPowerTable([
        SocPowerTableItem(soc=20, power=7.0),
        SocPowerTableItem(soc=80, power=22.0),
    ])
    @test lookup_power(table, 50) == 7.0
end

@testset "SocPowerTable - lookup_power below all" begin
    table = SocPowerTable([
        SocPowerTableItem(soc=20, power=7.0),
        SocPowerTableItem(soc=80, power=22.0),
    ])
    @test lookup_power(table, 10) == 0.0
end

@testset "TimeRange - intersection overlapping" begin
    tr1 = TimeRange(DateTime(2022,1,1), DateTime(2022,1,3))
    tr2 = TimeRange(DateTime(2022,1,2), DateTime(2022,1,4))
    inter = intersect(tr1, tr2)
    @test inter !== nothing
    @test inter.from == DateTime(2022,1,2)
    @test inter.to == DateTime(2022,1,3)
end

@testset "TimeRange - intersection no overlap" begin
    tr1 = TimeRange(DateTime(2022,1,1), DateTime(2022,1,2))
    tr2 = TimeRange(DateTime(2022,1,3), DateTime(2022,1,4))
    inter = intersect(tr1, tr2)
    @test inter === nothing
end

@testset "TimeRange - intersection touching" begin
    tr1 = TimeRange(DateTime(2022,1,1), DateTime(2022,1,2))
    tr2 = TimeRange(DateTime(2022,1,2), DateTime(2022,1,3))
    inter = intersect(tr1, tr2)
    @test inter === nothing
end

@testset "TimeRange - containment" begin
    tr1 = TimeRange(DateTime(2022,1,1,6), DateTime(2022,1,1,10))
    tr2 = TimeRange(DateTime(2022,1,1), DateTime(2022,1,2))
    @test tr1 in tr2
    @test !(tr2 in tr1)
end

@testset "generate_timepoints - multiple periods" begin
    pts = generate_timepoints(DateTime(2022,1,1), DateTime(2022,1,1,4), Hour(1))
    @test length(pts) == 5
    @test pts[1] == DateTime(2022,1,1)
    @test pts[5] == DateTime(2022,1,1,4)
end

@testset "generate_periods - single period" begin
    pts = [DateTime(2022,1,1), DateTime(2022,1,1,1)]
    periods = generate_periods(pts)
    @test length(periods) == 1
    @test periods[1].from == DateTime(2022,1,1)
    @test periods[1].to == DateTime(2022,1,1,1)
end

@testset "FrequencyActivationTable - single mapping" begin
    table = FrequencyActivationTable(mappings=[FrequencyActivationMapping(frequency=50.0, activation=0.0)])
    dz = dead_zone(table)
    @test dz.up == 50.0
    @test dz.down == 50.0
end

@testset "NetworkStateContainer - emergency state" begin
    nsc = NetworkStateContainer("net_1", 48.5, EMERGENCY)
    @test nsc.state == EMERGENCY
    @test nsc.frequency == 48.5
end

@testset "EvseState - with vehicle" begin
    model = EvseModel(
        power_losses=PowerLosses(standby=0.5, variable=VariablePowerLosses(charging=0.05, discharging=0.05)),
        max_charge_power=22.0,
    )
    es = EvseState("evse_1", "s1", model, "v1", 5.0, 11.0, 1, 1, 1, 1)
    @test es.vehicle_id == "v1"
    @test es.baseline == 5.0
    @test es.power == 11.0
end

@testset "SiteState - with delivery point" begin
    ss = SiteState("site_1", nothing, TimestampedPrice[], EvseId[])
    @test ss.id_ == "site_1"
    @test ss.delivery_point === nothing
end
