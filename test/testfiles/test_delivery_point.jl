using Test
using Dates

@testset "CircuitEvse - load and to_dto" begin
    cfg = Dict{String,Any}(
        "evseId" => "evse_1",
        "phases" => "L1",
        "installedOnPhase" => "L1",
        "priority" => 2,
    )
    evse = load(CircuitEvse, cfg)
    @test evse.evse_id == "evse_1"
    @test evse.phases == "L1"
    @test evse.installed_on_phase == "L1"
    @test evse.priority == 2
    dto = to_dto(evse)
    @test dto["evseId"] == "evse_1"
    @test dto["phases"] == "L1"
    @test dto["installedOnPhase"] == "L1"
    @test dto["priority"] == 2
end

@testset "CircuitEvse - load without priority" begin
    cfg = Dict{String,Any}(
        "evseId" => "evse_2",
        "phases" => "L2",
        "installedOnPhase" => "L2",
    )
    evse = load(CircuitEvse, cfg)
    @test evse.priority == 0
end

@testset "CircuitPowerLimits - load and to_dto" begin
    cfg = Dict{String,Any}("maxChargePower" => 22000, "maxDischargePower" => 10000)
    limits = load(CircuitPowerLimits, cfg)
    @test limits.max_charge_power == 22.0
    @test limits.max_discharge_power == 10.0
    dto = to_dto(limits)
    @test dto["maxChargePower"] == 22000
    @test dto["maxDischargePower"] == 10000
end

@testset "CircuitPowerLimits - load with missing fields" begin
    cfg = Dict{String,Any}()
    limits = load(CircuitPowerLimits, cfg)
    @test limits.max_charge_power === nothing
    @test limits.max_discharge_power === nothing
    dto = to_dto(limits)
    @test !haskey(dto, "maxChargePower")
    @test !haskey(dto, "maxDischargePower")
end

@testset "CircuitPowerLimits - load with partial fields" begin
    cfg = Dict{String,Any}("maxChargePower" => 11000)
    limits = load(CircuitPowerLimits, cfg)
    @test limits.max_charge_power == 11.0
    @test limits.max_discharge_power === nothing
end

@testset "OtherConsumption - to_dto" begin
    oc = OtherConsumption(
        circuit_id="c1",
        from=DateTime(2022,1,1),
        to=DateTime(2022,1,2),
        phases="L1",
        installed_on_phase="L1",
        power=1500.0,
    )
    dto = to_dto(oc)
    @test dto["phases"] == "L1"
    @test dto["installedOnPhase"] == "L1"
    @test length(dto["schedule"]) == 1
    @test dto["schedule"][1]["power"] == 1500
end

@testset "OtherProduction - to_dto" begin
    op = OtherProduction(
        circuit_id="c1",
        from=DateTime(2022,1,1),
        to=DateTime(2022,1,2),
        phases="L1",
        installed_on_phase="L1",
        power=3000.0,
    )
    dto = to_dto(op)
    @test dto["phases"] == "L1"
    @test dto["installedOnPhase"] == "L1"
    @test dto["schedule"][1]["power"] == 3000
end

@testset "DeliveryPointCircuit - load and to_dto" begin
    cfg = Dict{String,Any}(
        "id" => "circuit_1",
        "phases" => "L1",
        "installedOnPhase" => "L1",
        "circuits" => [],
        "evses" => [
            Dict{String,Any}(
                "evseId" => "evse_1",
                "phases" => "L1",
                "installedOnPhase" => "L1",
                "priority" => 1,
            ),
        ],
    )
    circuit = load(DeliveryPointCircuit, cfg)
    @test circuit.id_ == "circuit_1"
    @test circuit.phases == "L1"
    @test circuit.installed_on_phase == "L1"
    @test length(circuit.evses) == 1
    @test circuit.power_limits === nothing

    dto = to_dto(circuit)
    @test dto["id"] == "circuit_1"
    @test dto["phases"] == "L1"
end

@testset "DeliveryPointCircuit - load with power limits" begin
    cfg = Dict{String,Any}(
        "id" => "circuit_2",
        "phases" => "L1",
        "installedOnPhase" => "L1",
        "circuits" => [],
        "evses" => [],
        "powerLimits" => Dict{String,Any}("maxChargePower" => 22000),
    )
    circuit = load(DeliveryPointCircuit, cfg)
    @test circuit.power_limits !== nothing
    @test circuit.power_limits.max_charge_power == 22.0
end

@testset "DeliveryPoint - load and to_dto" begin
    cfg = Dict{String,Any}(
        "id" => "dp_1",
        "phases" => "L1",
        "powerLimits" => Dict{String,Any}("maxChargePower" => 44000),
        "circuits" => [
            Dict{String,Any}(
                "id" => "circuit_1",
                "phases" => "L1",
                "installedOnPhase" => "L1",
                "circuits" => [],
                "evses" => [],
            ),
        ],
    )
    dp = load(DeliveryPoint, cfg)
    @test dp.id_ == "dp_1"
    @test dp.phases == "L1"
    @test dp.power_limits.max_charge_power == 44.0
    @test length(dp.circuits) == 1
    @test dp.subscribed_power === nothing

    dto = to_dto(dp)
    @test dto["id"] == "dp_1"
    @test haskey(dto, "powerLimits")
    @test !haskey(dto, "subscribedPower")
end

@testset "DeliveryPoint - load with subscribed power" begin
    cfg = Dict{String,Any}(
        "id" => "dp_2",
        "phases" => "L3",
        "powerLimits" => Dict{String,Any}("maxChargePower" => 44000),
        "circuits" => [],
        "subscribedPower" => Dict{String,Any}("maxChargePower" => 30000),
    )
    dp = load(DeliveryPoint, cfg)
    @test dp.subscribed_power !== nothing
    @test dp.subscribed_power.max_charge_power == 30.0
    dto = to_dto(dp)
    @test haskey(dto, "subscribedPower")
end
