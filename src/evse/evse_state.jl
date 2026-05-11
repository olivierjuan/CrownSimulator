"""
    EvseState

Mutable state for an EVSE (Electric Vehicle Supply Equipment) in the simulation. Implements `AbstractEvseAgent`.

# Fields
- `id_::EvseId` — EVSE identifier.
- `site_id::SiteId` — Site where the EVSE is located.
- `model::EvseModel` — EVSE model (power limits, current type, V2G support, etc.).
- `vehicle_id::Union{VehicleId,Nothing}` — Identifier of the connected vehicle (if any).
- `baseline::Power_kW` — Baseline power in kW.
- `power::Power_kW` — Current power in kW.
- `primary_capacity::Int` — Primary capacity.
- `primary_activated::Int` — Primary activated capacity.
- `primary_capacity_up::Int` — Primary capacity up.
- `primary_capacity_down::Int` — Primary capacity down.
"""
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

"""
    register!(e::EvseState, context) -> Nothing

Register an EVSE state with the simulation context (fleet).

# Arguments
- `e::EvseState` — The EVSE state to register.
- `context` — The simulation context containing EVSE fleet.
"""
function register!(e::EvseState, context)
    push!(context.evses, e)
end

"""
    initialize(e::EvseState) -> Nothing

Initialize an EVSE state before simulation starts. Currently a no-op.
"""
function initialize(e::EvseState)
    # No initialization needed for EVSEs
end

"""
    update!(e::EvseState, dt::Float64, current_time::DateTime) -> Nothing

Update an EVSE state for the current timestep. Currently a no-op (EVSE state is updated
via vehicle connection/disconnection events).

# Arguments
- `e::EvseState` — The EVSE state to update.
- `dt::Float64` — Time interval in seconds.
- `current_time::DateTime` — Current simulation time.
"""
function update!(e::EvseState, dt::Float64, current_time::DateTime)
    # EVSE state is updated by the vehicle connection/disconnection events
end

"""
    snapshot(e::EvseState) -> EvseSnapshot

Take a snapshot of the EVSE's current state for output.

# Arguments
- `e::EvseState` — The EVSE state to snapshot.

# Returns
- An `EvseSnapshot` with the EVSE's current data.
"""
function snapshot(e::EvseState)
    EvseSnapshot(
        id_=e.id_,
        baseline=e.baseline,
        power_losses=e.model.power_losses,
        supports_v2g=e.model.supports_v2g,
    )
end
