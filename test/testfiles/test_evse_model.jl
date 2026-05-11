using Test
using Dates

@testset "EvseModel - from_config" begin
    cfg = Dict{String,Any}(
        "standby losses" => 500,
        "variable losses" => 5.0,
        "power limits" => Dict{String,Any}(
            "max charge power" => 22000,
            "max discharge power" => 10000,
            "min charge power" => 1000,
            "efficiency min discharge power" => 2000,
            "efficiency min charge power" => 2000,
        ),
        "current_type" => 0,
        "supports_v2g" => true,
    )
    model = from_config(EvseModel, cfg)
    @test model.max_charge_power == 22.0
    @test model.max_discharge_power == 10.0
    @test model.min_charge_power == 1.0
    @test model.efficiency_min_discharge_power == 2.0
    @test model.efficiency_min_charge_power == 2.0
    @test model.current_type == AC
    @test model.supports_v2g == true
    @test model.power_losses.standby == 0.5
end

@testset "EvseModel - power_limits" begin
    model = EvseModel(
        power_losses=PowerLosses(standby=0.5, variable=VariablePowerLosses(charging=0.05, discharging=0.05)),
        max_charge_power=22.0,
        max_discharge_power=10.0,
        min_charge_power=1.0,
        efficiency_min_discharge_power=2.0,
        efficiency_min_charge_power=2.0,
    )
    pl = power_limits(model)
    @test pl.max_charge_power == 22.0
    @test pl.max_discharge_power == 10.0
    @test pl.min_charge_power == 1.0
    @test pl.efficiency_min_discharge_power == 2.0
    @test pl.efficiency_min_charge_power == 2.0
end

@testset "EvseModel - defaults" begin
    model = EvseModel(
        power_losses=PowerLosses(standby=0.0, variable=VariablePowerLosses(charging=0.0, discharging=0.0)),
    )
    @test model.max_charge_power == 10.0
    @test model.max_discharge_power == 9.2
    @test model.current_type == AC
    @test model.supports_v2g == false
end
