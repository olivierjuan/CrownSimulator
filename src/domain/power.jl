Base.@kwdef struct VariablePowerLosses
    charging::Ratio
    discharging::Ratio
end

Base.@kwdef struct PowerLosses
    standby::Power_kW
    variable::VariablePowerLosses
end

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

Base.@kwdef struct PowerLimits
    max_charge_power::Power_kW
    min_charge_power::Power_kW = 0.0
    max_discharge_power::Power_kW = 0.0
    efficiency_min_discharge_power::Power_kW = 0.0
    efficiency_min_charge_power::Power_kW = 0.0
end

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

Base.@kwdef struct SocPowerTableItem
    soc::Int
    power::Power_kW
end

function to_dto(item::SocPowerTableItem; capacity::Power_kW)::Dict{String,Int}
    Dict{String,Int}(
        "soc" => Int(round((item.soc / 100.0) * (capacity * 1000.0))),
        "maxChargePower" => Int(round(item.power * 1000.0)),
    )
end

function from_config(::Type{SocPowerTableItem}, cfg::AbstractDict)::SocPowerTableItem
    SocPowerTableItem(
        soc=cfg["soc"],
        power=cfg["power"] / 1000.0,
    )
end

Base.@kwdef struct SocPowerTable
    items::Vector{SocPowerTableItem}
end

function to_dto(table::SocPowerTable; capacity::Power_kW)::Vector{Dict{String,Int}}
    [to_dto(item; capacity=capacity) for item in table.items]
end

function from_config(::Type{SocPowerTable}, cfg::Vector{<:AbstractDict})::SocPowerTable
    SocPowerTable(
        items=[from_config(SocPowerTableItem, item) for item in cfg],
    )
end
