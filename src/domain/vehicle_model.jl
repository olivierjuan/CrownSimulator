Base.@kwdef struct VehicleModel
    capacity::Energy_kWh
    min_soc::Energy_kWh
    max_soc::Energy_kWh
    max_ac_charge_power::Power_kW
    max_dc_charge_power::Power_kW
    max_charge_power_max_soc::Energy_kWh = 0.0
    min_ac_charge_power::Power_kW = 0.0
    min_dc_charge_power::Power_kW = 0.0
    power_losses::Union{PowerLosses,Nothing} = nothing
    soc_power_table::Union{SocPowerTable,Nothing} = nothing
end

function from_config(::Type{VehicleModel}, cfg::AbstractDict)::VehicleModel
    power_losses = nothing
    soc_power_table = nothing
    max_charge_power_max_soc = 0.0
    if haskey(cfg, "max_charge_power_max_soc")
        max_charge_power_max_soc = cfg["max_charge_power_max_soc"] / 100.0
    end
    if haskey(cfg, "standby_losses") && haskey(cfg, "variable_losses")
        power_losses = PowerLosses(
            standby=cfg["standby_losses"],
            variable=VariablePowerLosses(
                charging=cfg["variable_losses"]["charging"],
                discharging=cfg["variable_losses"]["discharging"],
            ),
        )
    end
    if haskey(cfg, "soc_power_table")
        soc_power_table = from_config(SocPowerTable, cfg["soc_power_table"])
    end
    VehicleModel(
        capacity=cfg["capacity"] / 1000.0,
        min_soc=cfg["min soc"] / 1000.0,
        max_soc=cfg["max soc"] / 1000.0,
        max_ac_charge_power=cfg["max_ac_charge_power"],
        max_dc_charge_power=cfg["max_dc_charge_power"],
        max_charge_power_max_soc=max_charge_power_max_soc,
        power_losses=power_losses,
        soc_power_table=soc_power_table,
    )
end
