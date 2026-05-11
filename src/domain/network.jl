"""
    NetworkState

Enum for electrical network operational states.

# Values
- `NORMAL=0` — Normal operating state.
- `ALERT=1` — Alert state indicating potential issues.
- `EMERGENCY=2` — Emergency state requiring immediate response.
"""
@enum NetworkState NORMAL=0 ALERT=1 EMERGENCY=2

"""
    RecoveringMode

Enum for network recovery modes.

# Values
- `DEACTIVATED=0` — Recovery mode not active.
- `ARMED=1` — Recovery mode is armed and ready to activate.
- `ACTIVATED=2` — Recovery mode is actively engaged.
- `DEACTIVATING=3` — Recovery mode is deactivating.
"""
@enum RecoveringMode DEACTIVATED=0 ARMED=1 ACTIVATED=2 DEACTIVATING=3

"""
    FrequencyRange

A frequency range defined by upper and lower bounds.

# Fields
- `up::Frequency_Hz` — Upper frequency bound in Hz.
- `down::Frequency_Hz` — Lower frequency bound in Hz.
"""
Base.@kwdef struct FrequencyRange
    up::Frequency_Hz
    down::Frequency_Hz
end

"""
    to_dto(fr::FrequencyRange) -> Dict{String,Any}

Convert a `FrequencyRange` to a DTO dictionary.
"""
function to_dto(fr::FrequencyRange)
    Dict{String,Any}(
        "up" => fr.up,
        "down" => fr.down,
    )
end

"""
    FrequencyActivationMapping

Maps a frequency value to an activation coefficient.

# Fields
- `frequency::Frequency_Hz` — Frequency value in Hz.
- `activation::Float64` — Activation coefficient (typically -1.0 to 1.0).
"""
Base.@kwdef struct FrequencyActivationMapping
    frequency::Frequency_Hz
    activation::Float64
end

"""
    load(::Type{FrequencyActivationMapping}, cfg::AbstractDict) -> FrequencyActivationMapping

Construct a `FrequencyActivationMapping` from a configuration dictionary.
"""
function load(::Type{FrequencyActivationMapping}, cfg::AbstractDict)
    FrequencyActivationMapping(
        frequency=cfg["frequency"],
        activation=cfg["activation"],
    )
end

"""
    to_dto(m::FrequencyActivationMapping) -> Dict{String,Any}

Convert a `FrequencyActivationMapping` to a DTO dictionary.
"""
function to_dto(m::FrequencyActivationMapping)
    Dict{String,Any}(
        "frequency" => m.frequency,
        "activation" => m.activation,
    )
end

"""
    FrequencyActivationTable

A table of frequency-to-activation mappings for FCR (Frequency Containment Reserve).

# Fields
- `mappings::Vector{FrequencyActivationMapping}` — Ordered list of frequency activation mappings.
"""
Base.@kwdef struct FrequencyActivationTable
    mappings::Vector{FrequencyActivationMapping}
end

"""
    load(::Type{FrequencyActivationTable}, cfg::AbstractDict) -> FrequencyActivationTable

Construct a `FrequencyActivationTable` from a configuration dictionary or vector.
"""
function load(::Type{FrequencyActivationTable}, cfg::AbstractDict)
    # Iterate over keys of cfg similarly as in list index; cfg keys like "0", "1" or array-like
    if isa(cfg, AbstractVector)
        return FrequencyActivationTable([load(FrequencyActivationMapping, cfg[i]) for i in eachindex(cfg)])
    else
        return FrequencyActivationTable([load(FrequencyActivationMapping, cfg[k]) for k in keys(cfg)])
    end
end

"""
    dead_zone(table::FrequencyActivationTable) -> FrequencyRange

Compute the dead zone frequency range from a frequency activation table.
The dead zone is the range of frequencies where the activation coefficient is zero.
"""
function dead_zone(table::FrequencyActivationTable)
    dz = [m for m in table.mappings if m.activation == 0]
    FrequencyRange(
        up=maximum([m.frequency for m in dz]),
        down=minimum([m.frequency for m in dz]),
    )
end

"""
    max_steady_state_deviation(table::FrequencyActivationTable) -> FrequencyRange

Compute the maximum steady-state frequency deviation from the activation table.
"""
function max_steady_state_deviation(table::FrequencyActivationTable)
    frequencies = [m.frequency for m in table.mappings]
    FrequencyRange(up=maximum(frequencies), down=minimum(frequencies))
end

"""
    plus(table::FrequencyActivationTable, base_frequency::Frequency_Hz) -> FrequencyActivationTable

Shift all frequency values in the activation table by a base frequency offset.
"""
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

"""
    to_dto(table::FrequencyActivationTable) -> Vector{Dict{String,Any}}

Convert the entire frequency activation table to a vector of DTO dictionaries.
"""
function to_dto(table::FrequencyActivationTable)
    [to_dto(m) for m in table.mappings]
end

"""
    FrequencyQualityDefiningParams

Parameters defining the frequency quality requirements for FCR services.

# Fields
- `base_frequency::Frequency_Hz` — Base grid frequency in Hz (typically 50.0).
- `frequency_activation_table::FrequencyActivationTable` — Table of frequency activation mappings.
- `asymmetric_response_allowed::Bool` — Whether asymmetric frequency response is allowed.
- `minimum_duration_at_full_power::Dates.Period` — Minimum duration at full power.
"""
Base.@kwdef struct FrequencyQualityDefiningParams
    base_frequency::Frequency_Hz
    frequency_activation_table::FrequencyActivationTable
    asymmetric_response_allowed::Bool
    minimum_duration_at_full_power::Dates.Period
end

"""
    load(::Type{FrequencyQualityDefiningParams}, cfg::AbstractDict) -> FrequencyQualityDefiningParams

Construct `FrequencyQualityDefiningParams` from a configuration dictionary.
"""
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

"""
    to_dto(params::FrequencyQualityDefiningParams) -> Dict{String,Any}

Convert `FrequencyQualityDefiningParams` to a DTO dictionary for serialization.
"""
function to_dto(params::FrequencyQualityDefiningParams)
    Dict{String,Any}(
        "frequencyActivationTable" => to_dto(plus(params.frequency_activation_table, params.base_frequency)),
        "baseFrequency" => params.base_frequency,
        "maxFrequencyDeviation" => to_dto(max_steady_state_deviation(params.frequency_activation_table)),
        "frequencyDeadZone" => to_dto(dead_zone(params.frequency_activation_table)),
        "minimumDurationAtFullPower" => string(params.minimum_duration_at_full_power),
        "asymmetricResponseAllowed" => params.asymmetric_response_allowed,
    )
end
