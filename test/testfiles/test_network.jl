using Test
using Dates

@testset "NetworkState enum" begin
    @test NetworkState.NORMAL == 0
    @test NetworkState.ALERT == 1
    @test NetworkState.EMERGENCY == 2
end

@testset "RecoveringMode enum" begin
    @test RecoveringMode.DEACTIVATED == 0
    @test RecoveringMode.ARMED == 1
    @test RecoveringMode.ACTIVATED == 2
    @test RecoveringMode.DEACTIVATING == 3
end

@testset "FrequencyRange - to_dto" begin
    fr = FrequencyRange(up=50.2, down=49.8)
    dto = to_dto(fr)
    @test dto["up"] == 50.2
    @test dto["down"] == 49.8
end

@testset "FrequencyActivationMapping - load and to_dto" begin
    cfg = Dict{String,Any}("frequency" => 50.1, "activation" => 0.5)
    m = load(FrequencyActivationMapping, cfg)
    @test m.frequency == 50.1
    @test m.activation == 0.5
    dto = to_dto(m)
    @test dto["frequency"] == 50.1
    @test dto["activation"] == 0.5
end

@testset "FrequencyActivationTable - load and to_dto" begin
    cfg = Dict{String,Any}(
        "0" => Dict{String,Any}("frequency" => 49.8, "activation" => -1.0),
        "1" => Dict{String,Any}("frequency" => 50.0, "activation" => 0.0),
        "2" => Dict{String,Any}("frequency" => 50.2, "activation" => 1.0),
    )
    table = load(FrequencyActivationTable, cfg)
    @test length(table.mappings) == 3
    dtos = to_dto(table)
    @test length(dtos) == 3
end

@testset "FrequencyActivationTable - dead_zone" begin
    table = FrequencyActivationTable(
        mappings=[
            FrequencyActivationMapping(frequency=49.8, activation=-1.0),
            FrequencyActivationMapping(frequency=49.9, activation=0.0),
            FrequencyActivationMapping(frequency=50.0, activation=0.0),
            FrequencyActivationMapping(frequency=50.1, activation=0.0),
            FrequencyActivationMapping(frequency=50.2, activation=1.0),
        ]
    )
    dz = dead_zone(table)
    @test dz.down == 49.9
    @test dz.up == 50.1
end

@testset "FrequencyActivationTable - max_steady_state_deviation" begin
    table = FrequencyActivationTable(
        mappings=[
            FrequencyActivationMapping(frequency=49.8, activation=-1.0),
            FrequencyActivationMapping(frequency=50.2, activation=1.0),
        ]
    )
    msd = max_steady_state_deviation(table)
    @test msd.down == 49.8
    @test msd.up == 50.2
end

@testset "FrequencyActivationTable - plus offset" begin
    table = FrequencyActivationTable(
        mappings=[
            FrequencyActivationMapping(frequency=0.0, activation=0.0),
            FrequencyActivationMapping(frequency=0.2, activation=1.0),
        ]
    )
    shifted = plus(table, 50.0)
    @test shifted.mappings[1].frequency == 50.0
    @test shifted.mappings[2].frequency == 50.2
    @test shifted.mappings[2].activation == 1.0
end

@testset "FrequencyQualityDefiningParams - load and to_dto" begin
    cfg = Dict{String,Any}(
        "base_frequency" => 50.0,
        "frequency_activation_table" => Dict{String,Any}(
            "0" => Dict{String,Any}("frequency" => 49.8, "activation" => -1.0),
            "1" => Dict{String,Any}("frequency" => 50.0, "activation" => 0.0),
            "2" => Dict{String,Any}("frequency" => 50.2, "activation" => 1.0),
        ),
        "asymmetric_response_allowed" => true,
        "minimum_duration_at_full_power" => 300,
    )
    params = load(FrequencyQualityDefiningParams, cfg)
    @test params.base_frequency == 50.0
    @test params.asymmetric_response_allowed == true
    @test params.minimum_duration_at_full_power == Second(300)
    dto = to_dto(params)
    @test haskey(dto, "baseFrequency")
    @test haskey(dto, "frequencyDeadZone")
    @test haskey(dto, "maxFrequencyDeviation")
    @test haskey(dto, "frequencyActivationTable")
    @test haskey(dto, "minimumDurationAtFullPower")
    @test haskey(dto, "asymmetricResponseAllowed")
end
