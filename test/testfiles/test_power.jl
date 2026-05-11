using Test
using Dates

@testset "Useful power" begin
    losses = PowerLosses(
        standby=0.5,
        variable=VariablePowerLosses(charging=0.05, discharging=0.05)
    )
    @test get_useful_power(losses, 10.0) ≈ 9.025
end

@testset "get_useful_power - negative power (discharging)" begin
    losses = PowerLosses(
        standby=0.5,
        variable=VariablePowerLosses(charging=0.05, discharging=0.05)
    )
    result = get_useful_power(losses, -10.0)
    expected = (-10.0 - 0.5) / (1.0 - 0.05)
    @test result ≈ expected
end

@testset "get_useful_power - zero power" begin
    losses = PowerLosses(
        standby=0.5,
        variable=VariablePowerLosses(charging=0.05, discharging=0.05)
    )
    result = get_useful_power(losses, 0.0)
    expected = (0.0 - 0.5) / (1.0 - 0.05)
    @test result ≈ expected
end

@testset "get_useful_power - power equal to standby" begin
    losses = PowerLosses(
        standby=0.5,
        variable=VariablePowerLosses(charging=0.05, discharging=0.05)
    )
    result = get_useful_power(losses, 0.5)
    @test result ≈ 0.0
end

@testset "get_useful_power - zero losses" begin
    losses = PowerLosses(
        standby=0.0,
        variable=VariablePowerLosses(charging=0.0, discharging=0.0)
    )
    @test get_useful_power(losses, 10.0) ≈ 10.0
    @test get_useful_power(losses, -5.0) ≈ -5.0
end

@testset "PowerLimits - defaults" begin
    pl = PowerLimits(max_charge_power=22.0)
    @test pl.min_charge_power == 0.0
    @test pl.max_discharge_power == 0.0
    @test pl.efficiency_min_discharge_power == 0.0
    @test pl.efficiency_min_charge_power == 0.0
end

@testset "PowerLimits - cross_max_and_min_charge_power" begin
    se = PowerLimits(max_charge_power=22.0, min_charge_power=1.0)
    crossed = cross_max_and_min_charge_power(se, 11.0, 2.0)
    @test crossed.max_charge_power == 11.0
    @test crossed.min_charge_power == 2.0
end

@testset "PowerLimits - cross_max_and_min_charge_power EV limits larger" begin
    se = PowerLimits(max_charge_power=22.0, min_charge_power=1.0)
    crossed = cross_max_and_min_charge_power(se, 50.0, 0.5)
    @test crossed.max_charge_power == 22.0
    @test crossed.min_charge_power == 1.0
end

@testset "PowerLimits - cross_max_and_min_charge_power EV limits smaller" begin
    se = PowerLimits(max_charge_power=22.0, min_charge_power=1.0)
    crossed = cross_max_and_min_charge_power(se, 5.0, 3.0)
    @test crossed.max_charge_power == 5.0
    @test crossed.min_charge_power == 3.0
end

@testset "PowerLimits - cross preserves discharge limits" begin
    se = PowerLimits(max_charge_power=22.0, max_discharge_power=10.0, min_charge_power=1.0)
    crossed = cross_max_and_min_charge_power(se, 11.0, 2.0)
    @test crossed.max_discharge_power == 10.0
    @test crossed.efficiency_min_discharge_power == 0.0
    @test crossed.efficiency_min_charge_power == 0.0
end

@testset "PowerLimits - zero power values" begin
    se = PowerLimits(max_charge_power=0.0, min_charge_power=0.0)
    crossed = cross_max_and_min_charge_power(se, 0.0, 0.0)
    @test crossed.max_charge_power == 0.0
    @test crossed.min_charge_power == 0.0
end

@testset "SocPowerTableItem - to_dto" begin
    item = SocPowerTableItem(soc=50, power=22.0)
    dto = to_dto(item; capacity=60.0)
    @test dto["soc"] == Int(round((50 / 100.0) * (60.0 * 1000.0)))
    @test dto["maxChargePower"] == Int(round(22.0 * 1000.0))
end

@testset "SocPowerTableItem - from_config" begin
    cfg = Dict{String,Any}("soc" => 30, "power" => 11000)
    item = from_config(SocPowerTableItem, cfg)
    @test item.soc == 30
    @test item.power == 11.0
end

@testset "SocPowerTable - to_dto" begin
    table = SocPowerTable([
        SocPowerTableItem(soc=20, power=7.0),
        SocPowerTableItem(soc=80, power=22.0),
    ])
    dtos = to_dto(table; capacity=60.0)
    @test length(dtos) == 2
    @test dtos[1]["maxChargePower"] == Int(round(7.0 * 1000.0))
    @test dtos[2]["maxChargePower"] == Int(round(22.0 * 1000.0))
end

@testset "SocPowerTable - from_config" begin
    cfg = [
        Dict{String,Any}("soc" => 20, "power" => 7000),
        Dict{String,Any}("soc" => 80, "power" => 22000),
    ]
    table = from_config(SocPowerTable, cfg)
    @test length(table.items) == 2
    @test table.items[1].soc == 20
    @test table.items[1].power == 7.0
    @test table.items[2].soc == 80
    @test table.items[2].power == 22.0
end
