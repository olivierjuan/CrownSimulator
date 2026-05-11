mutable struct Aggregator
    name::String
    network::Union{ElectricNetworkSnapshot,Nothing}
    evses_ids::Vector{EvseId}
    vehicles_ids::Vector{VehicleId}
    bidding_service::BiddingService
    capacity_requirements::Vector{CapacityRequirement}
    known_dispatch::Union{OptimizationResponseSummary,Nothing}
    next_known_dispatch::Union{OptimizationResponseSummary,Nothing}
    manageable_transactions::Vector{String}
    next_manageable_transactions::Vector{String}
    primary_activated::Power_kW
    primary_announced::Power_kW
    primary_capacity::Power_kW
    primary_capacity_up::Power_kW
    primary_capacity_down::Power_kW
    power::Power_kW
    baseline::Power_kW
    discharge::Power_kW
    nb_communication::Int
    active_transactions::Int
    running_time::Float64
    next_running_time::Float64
    enable_fast_update::Bool
    sites::Vector{SiteId}
    droop_controller::DroopController
    spot_id::Union{SpotMarketAccessId,Nothing}
    recovering_state::RecoveringMode
    next_recovering_state::RecoveringMode
    is_depleted::Bool
    next_is_depleted::Bool
end

function Aggregator(bidding_service::BiddingService; name="Aggregator", enable_fast_update=false)
    Aggregator(
        name,
        nothing,
        EvseId[],
        VehicleId[],
        bidding_service,
        CapacityRequirement[],
        nothing,
        nothing,
        String[],
        String[],
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        0, 0,
        0.0, 0.0,
        enable_fast_update,
        SiteId[],
        DroopController(),
        nothing,
        RecoveringMode.DEACTIVATED,
        RecoveringMode.DEACTIVATED,
        false,
        false
    )
end
