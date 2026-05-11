"""
    VariablePowerLosses

Variable (rate-dependent) power loss coefficients for charging and discharging.

# Fields
- `charging::Ratio` — Fractional power loss during charging (0.0 to 1.0).
- `discharging::Ratio` — Fractional power loss during discharging (0.0 to 1.0).
"""
Base.@kwdef struct VariablePowerLosses
    charging::Ratio
    discharging::Ratio
end

"""
    PowerLosses

Combined standby and variable power losses for an EVSE or vehicle.

# Fields
- `standby::Power_kW` — Constant standby power consumption in kW.
- `variable::VariablePowerLosses` — Rate-dependent losses for charging and discharging.
"""
Base.@kwdef struct PowerLosses
    standby::Power_kW
    variable::VariablePowerLosses
end

"""
    get_useful_power(losses::PowerLosses, power::Power_kW) -> Power_kW

Compute the effective power after accounting for standby and variable losses.

For positive power (charging), the variable charging loss is subtracted.
For negative power (discharging), the variable discharging loss is applied.

# Arguments
- `losses::PowerLosses` — Power loss parameters.
- `power::Power_kW` — Raw power in kW.

# Returns
- The useful power after losses in kW.

# Examples
```julia
losses = PowerLosses(standby=0.5, variable=VariablePowerLosses(charging=0.05, discharging=0.05))
get_useful_power(losses, 10.0)  # 9.025
```
"""
function get_useful_power(losses::PowerLosses, power::Power_kW)::Power_kW
    power -= losses.standby
    if isapprox(power, 0.0; atol=1e-9)
        power = 0.0
    elseif power > 0.0
        power *= 1.0 - losses.variable.charging
    elseif power < 0.0
        power /= 1.0 - losses.variable.discharging
    end
    return power
end

"""
    PowerLimits

Power limits for an EVSE or vehicle, defining charge/discharge power boundaries.

# Fields
- `max_charge_power::Power_kW` — Maximum charge power in kW.
- `min_charge_power::Power_kW` — Minimum charge power in kW (default: 0.0).
- `max_discharge_power::Power_kW` — Maximum discharge power in kW (default: 0.0).
- `efficiency_min_discharge_power::Power_kW` — Minimum discharge power for efficiency (default: 0.0).
- `efficiency_min_charge_power::Power_kW` — Minimum charge power for efficiency (default: 0.0).
"""
Base.@kwdef struct PowerLimits
    max_charge_power::Power_kW
    min_charge_power::Power_kW = 0.0
    max_discharge_power::Power_kW = 0.0
    efficiency_min_discharge_power::Power_kW = 0.0
    efficiency_min_charge_power::Power_kW = 0.0
end

"""
    cross_max_and_min_charge_power(self::PowerLimits, ev_power_max::Power_kW, ev_power_min::Power_kW) -> PowerLimits

Compute the intersection of an EVSE's power limits with a vehicle's charge power limits.

Returns a new `PowerLimits` with `max_charge_power` capped to `ev_power_max` and `min_charge_power` raised to `ev_power_min`.

# Arguments
- `self::PowerLimits` — The EVSE's power limits.
- `ev_power_max::Power_kW` — The vehicle's maximum charge power.
- `ev_power_min::Power_kW` — The vehicle's minimum charge power.

# Returns
- A new `PowerLimits` with the crossed charge limits.
"""
function cross_max_and_min_charge_power(
    self::PowerLimits,
    ev_power_max::Power_kW,
    ev_power_min::Power_kW,
)::PowerLimits
    crossed_max = ev_power_max < self.max_charge_power ? ev_power_max : self.max_charge_power
    crossed_min = ev_power_min > self.min_charge_power ? ev_power_min : self.min_charge_power
    PowerLimits(
        max_charge_power=crossed_max,
        max_discharge_power=self.max_discharge_power,
        min_charge_power=crossed_min,
        efficiency_min_discharge_power=self.efficiency_min_discharge_power,
        efficiency_min_charge_power=self.efficiency_min_charge_power,
    )
end

"""
    SocPowerTableItem

A single entry in a state-of-charge (SoC) power table, mapping SoC percentage to power limit.

# Fields
- `soc::Int` — State of charge percentage (0-100).
- `power::Power_kW` — Maximum power at this SoC level in kW.
"""
Base.@kwdef struct SocPowerTableItem
    soc::Int
    power::Power_kW
end

"""
    to_dto(item::SocPowerTableItem; capacity::Power_kW) -> Dict{String,Int}

Convert a `SocPowerTableItem` to a DTO dictionary with energy in Wh.

# Arguments
- `item::SocPowerTableItem` — The table item to convert.
- `capacity::Power_kW` — Vehicle battery capacity in kW (used to convert SoC percentage to energy).
"""
function to_dto(item::SocPowerTableItem; capacity::Power_kW)::Dict{String,Int}
    Dict{String,Int}(
        "soc" => Int(round((item.soc / 100.0) * (capacity * 1000.0))),
        "maxChargePower" => Int(round(item.power * 1000.0)),
    )
end

"""
    from_config(::Type{SocPowerTableItem}, cfg::AbstractDict) -> SocPowerTableItem

Construct a `SocPowerTableItem` from a configuration dictionary.

# Arguments
- `cfg::AbstractDict` — Dictionary with keys `"soc"` and `"power"` (power in W, converted to kW).
"""
function from_config(::Type{SocPowerTableItem}, cfg::AbstractDict)::SocPowerTableItem
    SocPowerTableItem(
        soc=cfg["soc"],
        power=cfg["power"] / 1000.0,
    )
end

"""
    SocPowerTable

A table of SoC-to-power mappings, used to determine maximum charging power at a given SoC level.

# Fields
- `items::Vector{SocPowerTableItem}` — Ordered list of SoC power table entries.
"""
Base.@kwdef struct SocPowerTable
    items::Vector{SocPowerTableItem}
end

"""
    to_dto(table::SocPowerTable; capacity::Power_kW) -> Vector{Dict{String,Int}}

Convert the entire SoC power table to a vector of DTO dictionaries.
"""
function to_dto(table::SocPowerTable; capacity::Power_kW)::Vector{Dict{String,Int}}
    [to_dto(item; capacity=capacity) for item in table.items]
end

"""
    from_config(::Type{SocPowerTable}, cfg::Vector{<:AbstractDict}) -> SocPowerTable

Construct a `SocPowerTable` from a vector of configuration dictionaries.
"""
function from_config(::Type{SocPowerTable}, cfg::Vector{<:AbstractDict})::SocPowerTable
    SocPowerTable(
        items=[from_config(SocPowerTableItem, item) for item in cfg],
    )
end
