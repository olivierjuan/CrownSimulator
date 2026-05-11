@enum CurrentType AC DC

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

function power_limits(model::EvseModel)::PowerLimits
    PowerLimits(
        max_charge_power=model.max_charge_power,
        max_discharge_power=model.max_discharge_power,
        min_charge_power=model.min_charge_power,
        efficiency_min_discharge_power=model.efficiency_min_discharge_power,
        efficiency_min_charge_power=model.efficiency_min_charge_power,
    )
end
