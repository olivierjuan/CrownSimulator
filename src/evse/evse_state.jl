mutable struct EvseState
    id_::EvseId
    site_id::SiteId
    model::EvseModel
    vehicle_id::Union{VehicleId,Nothing}
    baseline::Power_kW
    power::Power_kW
    primary_capacity::Int
    primary_activated::Int
    primary_capacity_up::Int
    primary_capacity_down::Int
end
