"""
    Aggregator

Mutable state for an aggregator that coordinates EV charging, FCR, and market participation.

# Fields
- `name::String` — Aggregator name.
- `network::Union{ElectricNetworkSnapshot,Nothing}` — Optional network snapshot.
- `evses_ids::Vector{EvseId}` — Identifiers of managed EVSEs.
- `vehicles_ids::Vector{VehicleId}` — Identifiers of managed vehicles.
- `bidding_service::BiddingService` — Bidding service for market participation.
- `capacity_requirements::Vector{CapacityRequirement}` — Capacity requirements.
- `known_dispatch::Union{OptimizationResponseSummary,Nothing}` — Known dispatch result.
- `next_known_dispatch::Union{OptimizationResponseSummary,Nothing}` — Next known dispatch result.
- `manageable_transactions::Vector{String}` — Transaction IDs that can be managed.
- `next_manageable_transactions::Vector{String}` — Next set of manageable transaction IDs.
- `primary_activated::Power_kW` — Activated primary power in kW.
- `primary_announced::Power_kW` — Announced primary power in kW.
- `primary_capacity::Power_kW` — Total primary capacity in kW.
- `primary_capacity_up::Power_kW` — Primary capacity up in kW.
- `primary_capacity_down::Power_kW` — Primary capacity down in kW.
- `power::Power_kW` — Current power in kW.
- `baseline::Power_kW` — Current baseline power in kW.
- `discharge::Power_kW` — Current discharge power in kW.
- `nb_communication::Int` — Number of communications.
- `active_transactions::Int` — Number of active transactions.
- `running_time::Float64` — Running time in seconds.
- `next_running_time::Float64` — Next running time in seconds.
- `enable_fast_update::Bool` — Whether fast update mode is enabled.
- `sites::Vector{SiteId}` — Identifiers of managed sites.
- `droop_controller::DroopController` — Frequency droop controller.
- `spot_id::Union{SpotMarketAccessId,Nothing}` — Spot market access identifier.
- `recovering_state::RecoveringMode` — Current recovery mode.
- `next_recovering_state::RecoveringMode` — Next recovery mode.
- `is_depleted::Bool` — Whether the aggregator is depleted.
- `next_is_depleted::Bool` — Whether the aggregator will be depleted next.
"""
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

"""
    Aggregator(bidding_service::BiddingService; name::String="Aggregator", enable_fast_update::Bool=false) -> Aggregator

Construct an `Aggregator` with default values for all fields.

# Arguments
- `bidding_service::BiddingService` — Bidding service instance.
- `name::String` — Aggregator name (default: `"Aggregator"`).
- `enable_fast_update::Bool` — Enable fast update mode (default: `false`).

# Returns
- A new `Aggregator` with zeroed/empty fields.
"""
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
