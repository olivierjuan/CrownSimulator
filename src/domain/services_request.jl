"""
    SocPenalties

SoC (State of Charge) penalty parameters for charging requirements optimization.

# Fields
- `encouraged_min_soc_gap::Int` — Minimum SoC gap to encourage charging.
- `encouraged_max_soc_gap::Int` — Maximum SoC gap to encourage charging.
- `max_soc_gap::Int` — Maximum allowed SoC gap.
"""
Base.@kwdef struct SocPenalties
    encouraged_min_soc_gap::Int
    encouraged_max_soc_gap::Int
    max_soc_gap::Int
end

"""
    load(::Type{SocPenalties}, cfg::AbstractDict) -> SocPenalties

Construct `SocPenalties` from a configuration dictionary.
"""
function load(::Type{SocPenalties}, cfg::AbstractDict)
    SocPenalties(
        encouraged_min_soc_gap=cfg["encouraged_min_soc_gap"],
        encouraged_max_soc_gap=cfg["encouraged_max_soc_gap"],
        max_soc_gap=cfg["max_soc_gap"],
    )
end

"""
    to_dto(p::SocPenalties) -> Dict{String,Any}

Convert `SocPenalties` to a DTO dictionary for serialization.
"""
function to_dto(p::SocPenalties)
    Dict{String,Any}(
        "encouragedMinSocGap" => p.encouraged_min_soc_gap,
        "encouragedMaxSocGap" => p.encouraged_max_soc_gap,
        "maxSocGap" => p.max_soc_gap,
    )
end

"""
    InstantChargePenalties

Penalty parameters for instant charging service.

# Fields
- `max_soc_gap::Int` — Maximum SoC gap for instant charging.
"""
Base.@kwdef struct InstantChargePenalties
    max_soc_gap::Int
end

"""
    load(::Type{InstantChargePenalties}, cfg::AbstractDict) -> InstantChargePenalties

Construct `InstantChargePenalties` from a configuration dictionary.
"""
function load(::Type{InstantChargePenalties}, cfg::AbstractDict)
    InstantChargePenalties(max_soc_gap=cfg["max_soc_gap"])
end

"""
    to_dto(p::InstantChargePenalties) -> Dict{String,Any}

Convert `InstantChargePenalties` to a DTO dictionary.
"""
function to_dto(p::InstantChargePenalties)
    Dict{String,Any}("maxSocGap" => p.max_soc_gap)
end

"""
    ChargingRequirementsServiceParameters

Parameters for the charging requirements service in the optimization model.

# Fields
- `weight::Float64` — Optimization weight for this service.
- `soc_penalties::SocPenalties` — SoC penalty parameters.
- `instant_charge_penalties::InstantChargePenalties` — Instant charge penalty parameters.
"""
Base.@kwdef struct ChargingRequirementsServiceParameters
    weight::Float64
    soc_penalties::SocPenalties
    instant_charge_penalties::InstantChargePenalties
end

"""
    load(::Type{ChargingRequirementsServiceParameters}, cfg::AbstractDict) -> ChargingRequirementsServiceParameters

Construct `ChargingRequirementsServiceParameters` from a configuration dictionary.
"""
function load(::Type{ChargingRequirementsServiceParameters}, cfg::AbstractDict)
    ChargingRequirementsServiceParameters(
        weight=cfg["weight"],
        soc_penalties=load(SocPenalties, cfg["soc_penalties"]),
        instant_charge_penalties=load(InstantChargePenalties, cfg["instant_charge_penalties"]),
    )
end

"""
    to_dto(params::ChargingRequirementsServiceParameters) -> Dict{String,Any}

Convert `ChargingRequirementsServiceParameters` to a DTO dictionary.
"""
function to_dto(params::ChargingRequirementsServiceParameters)
    Dict{String,Any}(
        "weight" => params.weight,
        "socPenalties" => to_dto(params.soc_penalties),
        "instantChargePenalties" => to_dto(params.instant_charge_penalties),
    )
end

"""
    TariffServiceParameters

Parameters for the tariff (energy pricing) service.

# Fields
- `weight::Float64` — Optimization weight for this service.
- `discount::Float64` — Discount factor for tariff calculations.
- `default_price::Float64` — Default energy price when no market price is available.
"""
Base.@kwdef struct TariffServiceParameters
    weight::Float64
    discount::Float64
    default_price::Float64
end

"""
    load(::Type{TariffServiceParameters}, cfg::AbstractDict) -> TariffServiceParameters

Construct `TariffServiceParameters` from a configuration dictionary.
"""
function load(::Type{TariffServiceParameters}, cfg::AbstractDict)
    TariffServiceParameters(
        weight=cfg["weight"],
        discount=cfg["discount"],
        default_price=cfg["default_price"],
    )
end

"""
    to_dto(params::TariffServiceParameters) -> Dict{String,Any}

Convert `TariffServiceParameters` to a DTO dictionary.
"""
function to_dto(params::TariffServiceParameters)
    Dict{String,Any}(
        "weight" => params.weight,
        "discount" => params.discount,
        "defaultPrice" => params.default_price,
    )
end

"""
    FcrServiceParameters

Parameters for the Frequency Containment Reserve (FCR) service.

# Fields
- `weight::Float64` — Optimization weight for this service.
- `parameters::FrequencyQualityDefiningParams` — Frequency quality parameters for FCR.
"""
Base.@kwdef struct FcrServiceParameters
    weight::Float64
    parameters::FrequencyQualityDefiningParams
end

"""
    load(::Type{FcrServiceParameters}, cfg::AbstractDict) -> FcrServiceParameters

Construct `FcrServiceParameters` from a configuration dictionary.
"""
function load(::Type{FcrServiceParameters}, cfg::AbstractDict)
    FcrServiceParameters(
        weight=cfg["weight"],
        parameters=load(FrequencyQualityDefiningParams, cfg["parameters"]),
    )
end

"""
    BaselineStabilityServiceParameters

Parameters for the baseline stability service.

# Fields
- `weight::Float64` — Optimization weight for this service.
"""
Base.@kwdef struct BaselineStabilityServiceParameters
    weight::Float64
end

"""
    load(::Type{BaselineStabilityServiceParameters}, cfg::AbstractDict) -> BaselineStabilityServiceParameters

Construct `BaselineStabilityServiceParameters` from a configuration dictionary.
"""
function load(::Type{BaselineStabilityServiceParameters}, cfg::AbstractDict)
    BaselineStabilityServiceParameters(weight=cfg["weight"])
end

"""
    Co2ServiceParameters

Parameters for the CO2 reduction service.

# Fields
- `weight::Float64` — Optimization weight for this service.
"""
Base.@kwdef struct Co2ServiceParameters
    weight::Float64
end

"""
    load(::Type{Co2ServiceParameters}, cfg::AbstractDict) -> Co2ServiceParameters

Construct `Co2ServiceParameters` from a configuration dictionary.
"""
function load(::Type{Co2ServiceParameters}, cfg::AbstractDict)
    Co2ServiceParameters(weight=cfg["weight"])
end

"""
    to_dto(params::Co2ServiceParameters) -> Dict{String,Any}

Convert `Co2ServiceParameters` to a DTO dictionary.
"""
function to_dto(params::Co2ServiceParameters)
    Dict{String,Any}("weight" => params.weight)
end

"""
    DayAheadServiceParameters

Parameters for the day-ahead market service.

# Fields
- `weight::Float64` — Optimization weight for this service.
- `discount::Float64` — Discount factor for day-ahead pricing.
"""
Base.@kwdef struct DayAheadServiceParameters
    weight::Float64
    discount::Float64
end

"""
    load(::Type{DayAheadServiceParameters}, cfg::AbstractDict) -> DayAheadServiceParameters

Construct `DayAheadServiceParameters` from a configuration dictionary.
"""
function load(::Type{DayAheadServiceParameters}, cfg::AbstractDict)
    DayAheadServiceParameters(
        weight=cfg["weight"],
        discount=cfg["discount"],
    )
end

"""
    ServicesRequestParameters

Aggregated parameters for all services requested in the optimization.

# Fields
- `charging_requirements::ChargingRequirementsServiceParameters` — Charging requirements service parameters.
- `tariff::TariffServiceParameters` — Tariff service parameters.
- `fcr::Dict{String,FcrServiceParameters}` — FCR service parameters keyed by service name.
- `baseline_stability::BaselineStabilityServiceParameters` — Baseline stability service parameters.
- `co2::Co2ServiceParameters` — CO2 service parameters.
- `day_ahead::DayAheadServiceParameters` — Day-ahead market service parameters.
"""
Base.@kwdef struct ServicesRequestParameters
    charging_requirements::ChargingRequirementsServiceParameters
    tariff::TariffServiceParameters
    fcr::Dict{String,FcrServiceParameters}
    baseline_stability::BaselineStabilityServiceParameters
    co2::Co2ServiceParameters
    day_ahead::DayAheadServiceParameters
end

"""
    load(::Type{ServicesRequestParameters}, cfg::AbstractDict) -> ServicesRequestParameters

Construct `ServicesRequestParameters` from a configuration dictionary.
"""
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

"""
    to_dto(params::FcrServiceParameters) -> Dict{String,Any}

Convert `FcrServiceParameters` to a DTO dictionary for serialization.
"""
function to_dto(params::FcrServiceParameters)
    Dict{String,Any}(
        "weight" => params.weight,
        "parameters" => to_dto(params.parameters),
    )
end

"""
    to_dto(params::BaselineStabilityServiceParameters) -> Dict{String,Any}

Convert `BaselineStabilityServiceParameters` to a DTO dictionary for serialization.
"""
function to_dto(params::BaselineStabilityServiceParameters)
    Dict{String,Any}("weight" => params.weight)
end

"""
    to_dto(params::DayAheadServiceParameters) -> Dict{String,Any}

Convert `DayAheadServiceParameters` to a DTO dictionary for serialization.
"""
function to_dto(params::DayAheadServiceParameters)
    Dict{String,Any}(
        "weight" => params.weight,
        "discount" => params.discount,
    )
end

"""
    to_dto(params::ServicesRequestParameters) -> Dict{String,Any}

Convert `ServicesRequestParameters` to a DTO dictionary for serialization.
"""
function to_dto(params::ServicesRequestParameters)
    Dict{String,Any}(
        "chargingRequirements" => to_dto(params.charging_requirements),
        "tariff" => to_dto(params.tariff),
        "fcr" => Dict(k => to_dto(v) for (k, v) in params.fcr),
        "baselineStability" => to_dto(params.baseline_stability),
        "co2" => to_dto(params.co2),
        "dayAhead" => to_dto(params.day_ahead),
    )
end

"""
    is_fcr_enabled(params::ServicesRequestParameters) -> Bool

Check whether any FCR (Frequency Containment Reserve) service is enabled.
"""
function is_fcr_enabled(params::ServicesRequestParameters)::Bool
    any(s -> s.weight > 0.0, values(params.fcr))
end
