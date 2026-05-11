using Test
using Dates

@testset "VehicleModel - from_config minimal" begin
    cfg = Dict{String,Any}(
        "capacity" => 60000,
        "min soc" => 5000,
        "max soc" => 55000,
        "max_ac_charge_power" => 11.0,
        "max_dc_charge_power" => 50.0,
    )
    model = from_config(VehicleModel, cfg)
    @test model.capacity == 60.0
    @test model.min_soc == 5.0
    @test model.max_soc == 55.0
    @test model.max_ac_charge_power == 11.0
    @test model.max_dc_charge_power == 50.0
    @test model.power_losses === nothing
    @test model.soc_power_table === nothing
    @test model.max_charge_power_max_soc == 0.0
end

@testset "VehicleModel - from_config with losses" begin
    cfg = Dict{String,Any}(
        "capacity" => 60000,
        "min soc" => 5000,
        "max soc" => 55000,
        "max_ac_charge_power" => 11.0,
        "max_dc_charge_power" => 50.0,
        "standby_losses" => 0.5,
        "variable_losses" => Dict{String,Any}(
            "charging" => 0.05,
            "discharging" => 0.05,
        ),
    )
    model = from_config(VehicleModel, cfg)
    @test model.power_losses !== nothing
    @test model.power_losses.standby == 0.5
    @test model.power_losses.variable.charging == 0.05
    @test model.power_losses.variable.discharging == 0.05
end

@testset "VehicleModel - from_config with soc_power_table" begin
    cfg = Dict{String,Any}(
        "capacity" => 60000,
        "min soc" => 5000,
        "max soc" => 55000,
        "max_ac_charge_power" => 11.0,
        "max_dc_charge_power" => 50.0,
        "soc_power_table" => [
            Dict{String,Any}("soc" => 20, "power" => 7000),
            Dict{String,Any}("soc" => 80, "power" => 22000),
        ],
    )
    model = from_config(VehicleModel, cfg)
    @test model.soc_power_table !== nothing
    @test length(model.soc_power_table.items) == 2
end

@testset "VehicleModel - from_config with max_charge_power_max_soc" begin
    cfg = Dict{String,Any}(
        "capacity" => 60000,
        "min soc" => 5000,
        "max soc" => 55000,
        "max_ac_charge_power" => 11.0,
        "max_dc_charge_power" => 50.0,
        "max_charge_power_max_soc" => 50.0,
    )
    model = from_config(VehicleModel, cfg)
    @test model.max_charge_power_max_soc == 0.5
end
