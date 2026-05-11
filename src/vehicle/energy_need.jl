"""
    EnergyNeed

Represents an energy need for a vehicle during a specific time period.

# Fields
- `period::TimeRange` — Time range during which the energy is needed.
- `value::Float64` — Amount of energy needed (in kWh).
"""
Base.@kwdef struct EnergyNeed
    period::TimeRange
    value::Float64
end

"""
    to_dto(need::EnergyNeed) -> Dict{String,Any}

Convert an `EnergyNeed` to a DTO dictionary for serialization.
"""
function to_dto(need::EnergyNeed)
    Dict{String,Any}(
        "start" => string(need.period.from),
        "stop" => string(need.period.to),
        "value" => need.value,
    )
end
