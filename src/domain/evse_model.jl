"""
    CurrentType

Enum for electrical current type of an EVSE.

# Values
- `AC` — Alternating current.
- `DC` — Direct current.
"""
@enum CurrentType AC DC

"""
    EvseModel

Represents the physical model and capabilities of an EVSE (Electric Vehicle Supply Equipment).

# Fields
- `power_losses::PowerLosses` — Power loss parameters for the EVSE.
- `max_charge_power::Power_kW` — Maximum charge power in kW (default: 10.0).
- `max_discharge_power::Power_kW` — Maximum discharge power in kW (default: 9.2).
- `min_charge_power::Power_kW` — Minimum charge power in kW (default: 0.0).
- `efficiency_min_discharge_power::Power_kW` — Minimum discharge power for efficiency in kW (default: 2.0).
- `efficiency_min_charge_power::Power_kW` — Minimum charge power for efficiency in kW (default: 2.0).
- `current_type::CurrentType` — AC or DC (default: AC).
- `supports_v2g::Bool` — Whether the EVSE supports vehicle-to-grid (default: false).
"""
Base.@kwdef struct EvseModel
    power_losses::PowerLosses
    max_charge_power::Power_kW = 10.0
    max_discharge_power::Power_kW = 9.2
    min_charge_power::Power_kW = 0.0
    efficiency_min_discharge_power::Power_kW = 2.0
    efficiency_min_charge_power::Power_kW = 2.0
    current_type::CurrentType = AC
    supports_v2g::Bool = false
end

"""
    from_config(::Type{EvseModel}, config::AbstractDict) -> EvseModel

Construct an `EvseModel` from a configuration dictionary.

# Arguments
- `config::AbstractDict` — Dictionary with keys `"standby losses"`, `"variable losses"`, `"power limits"`, `"current_type"`, `"supports_v2g"`.

# Returns
- A new `EvseModel` instance.
"""
function from_config(::Type{EvseModel}, config::AbstractDict)::EvseModel
    power_losses = PowerLosses(
        standby=config["standby losses"] / 1000.0,
        variable=VariablePowerLosses(
            charging=(100.0 - config["variable losses"]) / 100.0,
            discharging=(100.0 - config["variable losses"]) / 100.0,
        ),
    )
    EvseModel(
        power_losses=power_losses,
        max_charge_power=config["power limits"]["max charge power"] / 1000.0,
        max_discharge_power=config["power limits"]["max discharge power"] / 1000.0,
        min_charge_power=config["power limits"]["min charge power"] / 1000.0,
        efficiency_min_discharge_power=config["power limits"]["efficiency min discharge power"] / 1000.0,
        efficiency_min_charge_power=config["power limits"]["efficiency min charge power"] / 1000.0,
        current_type=CurrentType(config["current_type"]),
        supports_v2g=config["supports_v2g"],
    )
end

"""
    to_dto(model::EvseModel) -> Dict{String,Any}

Convert an `EvseModel` to a DTO dictionary for serialization.

# Returns
- A dictionary with power loss parameters, power limits, current type, and V2G support flag.
"""
function to_dto(model::EvseModel)
    Dict{String,Any}(
        "standbyLosses" => Int(round(model.power_losses.standby * 1000.0)),
        "variableLosses" => Int(round((1.0 - model.power_losses.variable.charging) * 100.0)),
        "powerLimits" => Dict{String,Any}(
            "maxChargePower" => Int(round(model.max_charge_power * 1000.0)),
            "maxDischargePower" => Int(round(model.max_discharge_power * 1000.0)),
            "minChargePower" => Int(round(model.min_charge_power * 1000.0)),
            "efficiencyMinDischargePower" => Int(round(model.efficiency_min_discharge_power * 1000.0)),
            "efficiencyMinChargePower" => Int(round(model.efficiency_min_charge_power * 1000.0)),
        ),
        "currentType" => string(model.current_type),
        "supportsV2g" => model.supports_v2g,
    )
end

"""
    power_limits(model::EvseModel) -> PowerLimits

Extract power limits from an `EvseModel` into a `PowerLimits` struct.

# Arguments
- `model::EvseModel` — The EVSE model to extract limits from.

# Returns
- A `PowerLimits` instance with charge/discharge limits from the model.
"""
function power_limits(model::EvseModel)::PowerLimits
    PowerLimits(
        max_charge_power=model.max_charge_power,
        max_discharge_power=model.max_discharge_power,
        min_charge_power=model.min_charge_power,
        efficiency_min_discharge_power=model.efficiency_min_discharge_power,
        efficiency_min_charge_power=model.efficiency_min_charge_power,
    )
end
