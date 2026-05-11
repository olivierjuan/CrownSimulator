mutable struct VehicleState <: AbstractVehicleAgent
    id_::VehicleId
    site_id::SiteId
    model::VehicleModel
    soc::Energy_kWh
    previous_soc::Energy_kWh
    power::Power_kW
    noise::Power_kW
    connected::Bool
    evse_id::Union{EvseId,Nothing}
end

function register!(v::VehicleState, context)
    push!(context.vehicles, v)
end

function initialize(v::VehicleState)
    v.previous_soc = v.soc
end

function snapshot(v::VehicleState)
    VehicleSnapshot(
        id_=v.id_,
        capacity=v.model.capacity,
        max_soc=v.model.max_soc,
        max_ac_charge_power=v.model.max_ac_charge_power,
        max_dc_charge_power=v.model.max_dc_charge_power,
        max_charge_power_max_soc=v.model.max_charge_power_max_soc,
        soc=v.soc,
        soc_requirements=Energy_kWh[],
        min_ac_charge_power=v.model.min_ac_charge_power,
        min_dc_charge_power=v.model.min_dc_charge_power,
        model=v.model,
        power_losses=v.model.power_losses,
        soc_power_table=v.model.soc_power_table,
    )
end
