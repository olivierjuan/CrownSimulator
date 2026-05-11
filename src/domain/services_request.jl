Base.@kwdef struct SocPenalties
    encouraged_min_soc_gap::Int
    encouraged_max_soc_gap::Int
    max_soc_gap::Int
end

function load(::Type{SocPenalties}, cfg::AbstractDict)
    SocPenalties(
        encouraged_min_soc_gap=cfg["encouraged_min_soc_gap"],
        encouraged_max_soc_gap=cfg["encouraged_max_soc_gap"],
        max_soc_gap=cfg["max_soc_gap"],
    )
end

function to_dto(p::SocPenalties)
    Dict{String,Any}(
        "encouragedMinSocGap" => p.encouraged_min_soc_gap,
        "encouragedMaxSocGap" => p.encouraged_max_soc_gap,
        "maxSocGap" => p.max_soc_gap,
    )
end

Base.@kwdef struct InstantChargePenalties
    max_soc_gap::Int
end

function load(::Type{InstantChargePenalties}, cfg::AbstractDict)
    InstantChargePenalties(max_soc_gap=cfg["max_soc_gap"])
end

function to_dto(p::InstantChargePenalties)
    Dict{String,Any}("maxSocGap" => p.max_soc_gap)
end

Base.@kwdef struct ChargingRequirementsServiceParameters
    weight::Float64
    soc_penalties::SocPenalties
    instant_charge_penalties::InstantChargePenalties
end

function load(::Type{ChargingRequirementsServiceParameters}, cfg::AbstractDict)
    ChargingRequirementsServiceParameters(
        weight=cfg["weight"],
        soc_penalties=load(SocPenalties, cfg["soc_penalties"]),
        instant_charge_penalties=load(InstantChargePenalties, cfg["instant_charge_penalties"]),
    )
end

function to_dto(params::ChargingRequirementsServiceParameters)
    Dict{String,Any}(
        "weight" => params.weight,
        "socPenalties" => to_dto(params.soc_penalties),
        "instantChargePenalties" => to_dto(params.instant_charge_penalties),
    )
end

Base.@kwdef struct TariffServiceParameters
    weight::Float64
    discount::Float64
    default_price::Float64
end

function load(::Type{TariffServiceParameters}, cfg::AbstractDict)
    TariffServiceParameters(
        weight=cfg["weight"],
        discount=cfg["discount"],
        default_price=cfg["default_price"],
    )
end

function to_dto(params::TariffServiceParameters)
    Dict{String,Any}(
        "weight" => params.weight,
        "discount" => params.discount,
        "defaultPrice" => params.default_price,
    )
end

Base.@kwdef struct FcrServiceParameters
    weight::Float64
    parameters::FrequencyQualityDefiningParams
end

function load(::Type{FcrServiceParameters}, cfg::AbstractDict)
    FcrServiceParameters(
        weight=cfg["weight"],
        parameters=load(FrequencyQualityDefiningParams, cfg["parameters"]),
    )
end

Base.@kwdef struct BaselineStabilityServiceParameters
    weight::Float64
end

function load(::Type{BaselineStabilityServiceParameters}, cfg::AbstractDict)
    BaselineStabilityServiceParameters(weight=cfg["weight"])
end

Base.@kwdef struct Co2ServiceParameters
    weight::Float64
end

function load(::Type{Co2ServiceParameters}, cfg::AbstractDict)
    Co2ServiceParameters(weight=cfg["weight"])
end

function to_dto(params::Co2ServiceParameters)
    Dict{String,Any}("weight" => params.weight)
end

Base.@kwdef struct DayAheadServiceParameters
    weight::Float64
    discount::Float64
end

function load(::Type{DayAheadServiceParameters}, cfg::AbstractDict)
    DayAheadServiceParameters(
        weight=cfg["weight"],
        discount=cfg["discount"],
    )
end

Base.@kwdef struct ServicesRequestParameters
    charging_requirements::ChargingRequirementsServiceParameters
    tariff::TariffServiceParameters
    fcr::Dict{String,FcrServiceParameters}
    baseline_stability::BaselineStabilityServiceParameters
    co2::Co2ServiceParameters
    day_ahead::DayAheadServiceParameters
end

function load(::Type{ServicesRequestParameters}, cfg::AbstractDict)
    fcr_dict = Dict(
        string(k) => load(FcrServiceParameters, cfg["fcr"][k])
        for k in keys(cfg["fcr"])
    )
    ServicesRequestParameters(
        charging_requirements=load(ChargingRequirementsServiceParameters, cfg["charging_requirements"]),
        tariff=load(TariffServiceParameters, cfg["tariff"]),
        fcr=fcr_dict,
        co2=load(Co2ServiceParameters, cfg["co2"]),
        baseline_stability=load(BaselineStabilityServiceParameters, cfg["baseline_stability"]),
        day_ahead=load(DayAheadServiceParameters, cfg["day_ahead"]),
    )
end

function is_fcr_enabled(params::ServicesRequestParameters)::Bool
    any(s -> s.weight > 0.0, values(params.fcr))
end
