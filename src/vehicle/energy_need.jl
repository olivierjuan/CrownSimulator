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
