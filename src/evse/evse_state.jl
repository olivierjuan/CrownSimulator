mutable struct EvseState <: AbstractEvseAgent
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

function register!(e::EvseState, context)
    push!(context.evses, e)
end

function initialize(e::EvseState)
    # No initialization needed for EVSEs
end

function update!(e::EvseState, dt::Float64, current_time::DateTime)
    # EVSE state is updated by the vehicle connection/disconnection events
end

function snapshot(e::EvseState)
    EvseSnapshot(
        id_=e.id_,
        baseline=e.baseline,
        power_losses=e.model.power_losses,
        supports_v2g=e.model.supports_v2g,
    )
end
