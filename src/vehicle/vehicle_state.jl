mutable struct VehicleState
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
