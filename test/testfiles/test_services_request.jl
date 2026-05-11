using Test
using Dates

@testset "SocPenalties - load and to_dto" begin
    cfg = Dict{String,Any}(
        "encouraged_min_soc_gap" => 5,
        "encouraged_max_soc_gap" => 20,
        "max_soc_gap" => 50,
    )
    sp = load(SocPenalties, cfg)
    @test sp.encouraged_min_soc_gap == 5
    @test sp.encouraged_max_soc_gap == 20
    @test sp.max_soc_gap == 50
    dto = to_dto(sp)
    @test dto["encouragedMinSocGap"] == 5
    @test dto["encouragedMaxSocGap"] == 20
    @test dto["maxSocGap"] == 50
end

@testset "InstantChargePenalties - load and to_dto" begin
    cfg = Dict{String,Any}("max_soc_gap" => 10)
    p = load(InstantChargePenalties, cfg)
    @test p.max_soc_gap == 10
    dto = to_dto(p)
    @test dto["maxSocGap"] == 10
end

@testset "ChargingRequirementsServiceParameters - load and to_dto" begin
    cfg = Dict{String,Any}(
        "weight" => 0.5,
        "soc_penalties" => Dict{String,Any}(
            "encouraged_min_soc_gap" => 5,
            "encouraged_max_soc_gap" => 20,
            "max_soc_gap" => 50,
        ),
        "instant_charge_penalties" => Dict{String,Any}("max_soc_gap" => 10),
    )
    params = load(ChargingRequirementsServiceParameters, cfg)
    @test params.weight == 0.5
    @test params.soc_penalties.encouraged_min_soc_gap == 5
    @test params.instant_charge_penalties.max_soc_gap == 10
    dto = to_dto(params)
    @test dto["weight"] == 0.5
    @test haskey(dto, "socPenalties")
    @test haskey(dto, "instantChargePenalties")
end

@testset "TariffServiceParameters - load and to_dto" begin
    cfg = Dict{String,Any}(
        "weight" => 1.0,
        "discount" => 0.9,
        "default_price" => 100.0,
    )
    params = load(TariffServiceParameters, cfg)
    @test params.weight == 1.0
    @test params.discount == 0.9
    @test params.default_price == 100.0
    dto = to_dto(params)
    @test dto["weight"] == 1.0
    @test dto["discount"] == 0.9
    @test dto["defaultPrice"] == 100.0
end

@testset "FcrServiceParameters - load" begin
    cfg = Dict{String,Any}(
        "weight" => 0.3,
        "parameters" => Dict{String,Any}(
            "base_frequency" => 50.0,
            "frequency_activation_table" => Dict{String,Any}(
                "0" => Dict{String,Any}("frequency" => 49.8, "activation" => -1.0),
                "1" => Dict{String,Any}("frequency" => 50.0, "activation" => 0.0),
                "2" => Dict{String,Any}("frequency" => 50.2, "activation" => 1.0),
            ),
            "asymmetric_response_allowed" => false,
            "minimum_duration_at_full_power" => 600,
        ),
    )
    params = load(FcrServiceParameters, cfg)
    @test params.weight == 0.3
    @test params.parameters.base_frequency == 50.0
    @test params.parameters.asymmetric_response_allowed == false
end

@testset "BaselineStabilityServiceParameters - load" begin
    cfg = Dict{String,Any}("weight" => 0.2)
    params = load(BaselineStabilityServiceParameters, cfg)
    @test params.weight == 0.2
end

@testset "Co2ServiceParameters - load and to_dto" begin
    cfg = Dict{String,Any}("weight" => 0.1)
    params = load(Co2ServiceParameters, cfg)
    @test params.weight == 0.1
    dto = to_dto(params)
    @test dto["weight"] == 0.1
end

@testset "DayAheadServiceParameters - load" begin
    cfg = Dict{String,Any}("weight" => 0.4, "discount" => 0.85)
    params = load(DayAheadServiceParameters, cfg)
    @test params.weight == 0.4
    @test params.discount == 0.85
end

@testset "ServicesRequestParameters - load" begin
    cfg = Dict{String,Any}(
        "charging_requirements" => Dict{String,Any}(
            "weight" => 0.5,
            "soc_penalties" => Dict{String,Any}(
                "encouraged_min_soc_gap" => 5,
                "encouraged_max_soc_gap" => 20,
                "max_soc_gap" => 50,
            ),
            "instant_charge_penalties" => Dict{String,Any}("max_soc_gap" => 10),
        ),
        "tariff" => Dict{String,Any}(
            "weight" => 1.0,
            "discount" => 0.9,
            "default_price" => 100.0,
        ),
        "fcr" => Dict{String,Any}(
            "fcr1" => Dict{String,Any}(
                "weight" => 0.3,
                "parameters" => Dict{String,Any}(
                    "base_frequency" => 50.0,
                    "frequency_activation_table" => Dict{String,Any}(
                        "0" => Dict{String,Any}("frequency" => 49.8, "activation" => -1.0),
                        "1" => Dict{String,Any}("frequency" => 50.0, "activation" => 0.0),
                        "2" => Dict{String,Any}("frequency" => 50.2, "activation" => 1.0),
                    ),
                    "asymmetric_response_allowed" => false,
                    "minimum_duration_at_full_power" => 600,
                ),
            ),
        ),
        "baseline_stability" => Dict{String,Any}("weight" => 0.2),
        "co2" => Dict{String,Any}("weight" => 0.1),
        "day_ahead" => Dict{String,Any}("weight" => 0.4, "discount" => 0.85),
    )
    params = load(ServicesRequestParameters, cfg)
    @test params.charging_requirements.weight == 0.5
    @test params.tariff.weight == 1.0
    @test haskey(params.fcr, "fcr1")
    @test params.baseline_stability.weight == 0.2
    @test params.co2.weight == 0.1
    @test params.day_ahead.weight == 0.4
end

@testset "ServicesRequestParameters - is_fcr_enabled" begin
    freq_table_cfg = Dict{String,Any}(
        "0" => Dict{String,Any}("frequency" => 49.8, "activation" => -1.0),
        "1" => Dict{String,Any}("frequency" => 50.0, "activation" => 0.0),
        "2" => Dict{String,Any}("frequency" => 50.2, "activation" => 1.0),
    )
    fcr_cfg = Dict{String,Any}(
        "weight" => 0.3,
        "parameters" => Dict{String,Any}(
            "base_frequency" => 50.0,
            "frequency_activation_table" => freq_table_cfg,
            "asymmetric_response_allowed" => false,
            "minimum_duration_at_full_power" => 600,
        ),
    )
    params_with_fcr = ServicesRequestParameters(
        charging_requirements=ChargingRequirementsServiceParameters(
            weight=0.5,
            soc_penalties=SocPenalties(encouraged_min_soc_gap=5, encouraged_max_soc_gap=20, max_soc_gap=50),
            instant_charge_penalties=InstantChargePenalties(max_soc_gap=10),
        ),
        tariff=TariffServiceParameters(weight=1.0, discount=0.9, default_price=100.0),
        fcr=Dict{String,FcrServiceParameters}("fcr1" => load(FcrServiceParameters, fcr_cfg)),
        baseline_stability=BaselineStabilityServiceParameters(weight=0.2),
        co2=Co2ServiceParameters(weight=0.1),
        day_ahead=DayAheadServiceParameters(weight=0.4, discount=0.85),
    )
    @test is_fcr_enabled(params_with_fcr) == true

    params_no_fcr = ServicesRequestParameters(
        charging_requirements=ChargingRequirementsServiceParameters(
            weight=0.5,
            soc_penalties=SocPenalties(encouraged_min_soc_gap=5, encouraged_max_soc_gap=20, max_soc_gap=50),
            instant_charge_penalties=InstantChargePenalties(max_soc_gap=10),
        ),
        tariff=TariffServiceParameters(weight=1.0, discount=0.9, default_price=100.0),
        fcr=Dict{String,FcrServiceParameters}(),
        baseline_stability=BaselineStabilityServiceParameters(weight=0.2),
        co2=Co2ServiceParameters(weight=0.1),
        day_ahead=DayAheadServiceParameters(weight=0.4, discount=0.85),
    )
    @test is_fcr_enabled(params_no_fcr) == false
end
