@enum NetworkState NORMAL=0 ALERT=1 EMERGENCY=2

@enum RecoveringMode DEACTIVATED=0 ARMED=1 ACTIVATED=2 DEACTIVATING=3

Base.@kwdef struct FrequencyRange
    up::Frequency_Hz
    down::Frequency_Hz
end

function to_dto(fr::FrequencyRange)
    Dict{String,Any}(
        "up" => fr.up,
        "down" => fr.down,
    )
end

Base.@kwdef struct FrequencyActivationMapping
    frequency::Frequency_Hz
    activation::Float64
end

function load(::Type{FrequencyActivationMapping}, cfg::AbstractDict)
    FrequencyActivationMapping(
        frequency=cfg["frequency"],
        activation=cfg["activation"],
    )
end

function to_dto(m::FrequencyActivationMapping)
    Dict{String,Any}(
        "frequency" => m.frequency,
        "activation" => m.activation,
    )
end

Base.@kwdef struct FrequencyActivationTable
    mappings::Vector{FrequencyActivationMapping}
end

function load(::Type{FrequencyActivationTable}, cfg::AbstractDict)
    # Iterate over keys of cfg similarly as in list index; cfg keys like "0", "1" or array-like
    if isa(cfg, AbstractVector)
        return FrequencyActivationTable([load(FrequencyActivationMapping, cfg[i]) for i in eachindex(cfg)])
    else
        return FrequencyActivationTable([load(FrequencyActivationMapping, cfg[k]) for k in keys(cfg)])
    end
end

function dead_zone(table::FrequencyActivationTable)
    dz = [m for m in table.mappings if m.activation == 0]
    FrequencyRange(
        up=maximum([m.frequency for m in dz]),
        down=minimum([m.frequency for m in dz]),
    )
end

function max_steady_state_deviation(table::FrequencyActivationTable)
    frequencies = [m.frequency for m in table.mappings]
    FrequencyRange(up=maximum(frequencies), down=minimum(frequencies))
end

function plus(table::FrequencyActivationTable, base_frequency::Frequency_Hz)
    new_mappings = [
        FrequencyActivationMapping(
            frequency=m.frequency + base_frequency,
            activation=m.activation,
        )
        for m in table.mappings
    ]
    FrequencyActivationTable(new_mappings)
end

function to_dto(table::FrequencyActivationTable)
    [to_dto(m) for m in table.mappings]
end

Base.@kwdef struct FrequencyQualityDefiningParams
    base_frequency::Frequency_Hz
    frequency_activation_table::FrequencyActivationTable
    asymmetric_response_allowed::Bool
    minimum_duration_at_full_power::Dates.Period
end

function load(::Type{FrequencyQualityDefiningParams}, cfg::AbstractDict)
    # Julia isodate-like parsing for minimum_duration
    dur = Dates.Second(cfg["minimum_duration_at_full_power"])  # fallback using Seconds
    FrequencyQualityDefiningParams(
        base_frequency=cfg["base_frequency"],
        frequency_activation_table=load(FrequencyActivationTable, cfg["frequency_activation_table"]),
        asymmetric_response_allowed=cfg["asymmetric_response_allowed"],
        minimum_duration_at_full_power=dur,
    )
end

function to_dto(params::FrequencyQualityDefiningParams)
    Dict{String,Any}(
        "frequencyActivationTable" => to_dto(plus(params.frequency_activation_table, params.base_frequency)),
        "baseFrequency" => params.base_frequency,
        "maxFrequencyDeviation" => to_dto(max_steady_state_deviation(params.frequency_activation_table)),
        "frequencyDeadZone" => to_dto(dead_zone(params.frequency_activation_table)),
        "minimumDurationAtFullPower" => string(params.minimum_duration_at_full_power),  # simplified
    "asymmetricResponseAllowed" => params.asymmetric_response_allowed,
    )
end
