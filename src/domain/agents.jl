# Abstract agent interface hierarchy
"""
    AbstractAgent

Abstract supertype for all agents in the simulation.
Defines the standard lifecycle interface: register!, initialize, update!, snapshot.
"""
abstract type AbstractAgent end

"""
    AbstractVehicleAgent <: AbstractAgent

Abstract supertype for vehicle agents.
"""
abstract type AbstractVehicleAgent <: AbstractAgent end

"""
    AbstractEvseAgent <: AbstractAgent

Abstract supertype for EVSE (Electric Vehicle Supply Equipment) agents.
"""
abstract type AbstractEvseAgent <: AbstractAgent end

"""
    AbstractSiteAgent <: AbstractAgent

Abstract supertype for site agents.
"""
abstract type AbstractSiteAgent <: AbstractAgent end

"""
    AbstractNetworkAgent <: AbstractAgent

Abstract supertype for network agents.
"""
abstract type AbstractNetworkAgent <: AbstractAgent end

"""
    AbstractSpotAgent <: AbstractAgent

Abstract supertype for spot market agents.
"""
abstract type AbstractSpotAgent <: AbstractAgent end

"""
    register!(agent, context) -> Nothing

Register an agent with the simulation context (e.g., add to a fleet).
"""
function register!(agent::AbstractAgent, context)
    error("register! not implemented for $(typeof(agent))")
end

"""
    initialize(agent) -> Nothing

Initialize an agent's state before the simulation begins.
"""
function initialize(agent::AbstractAgent)
    error("initialize not implemented for $(typeof(agent))")
end

"""
    update!(agent, dt, current_time) -> Nothing

Update an agent's state for the current timestep.
"""
function update!(agent::AbstractAgent, dt::Float64, current_time::DateTime)
    error("update! not implemented for $(typeof(agent))")
end

"""
    snapshot(agent) -> Any

Take a snapshot of the agent's current state for output.
"""
function snapshot(agent::AbstractAgent)
    error("snapshot not implemented for $(typeof(agent))")
end

"""
    EvseAgentRegistration

Registration record for an EVSE agent in the simulation.

# Fields
- `id_::EvseId` — Identifier of the registered EVSE.
"""
struct EvseAgentRegistration
    id_::EvseId
end

"""
    VehicleAgentRegistration

Registration record for a vehicle agent in the simulation.

# Fields
- `id_::VehicleId` — Identifier of the registered vehicle.
"""
struct VehicleAgentRegistration
    id_::VehicleId
end

"""
    SiteAgentRegistration

Registration record for a site agent in the simulation.

# Fields
- `id_::SiteId` — Identifier of the registered site.
"""
struct SiteAgentRegistration
    id_::SiteId
end

"""
    NetworkAgentRegistration

Registration record for a network agent in the simulation.

# Fields
- `id::String` — Identifier of the registered network.
"""
struct NetworkAgentRegistration
    id_::String
end

"""
    SpotAgentRegistration

Registration record for a spot market agent in the simulation.

# Fields
- `id_::SpotMarketAccessId` — Identifier of the registered spot market access.
"""
struct SpotAgentRegistration
    id_::SpotMarketAccessId
end

"""
    EvseSetDataRequest

Request to set data on an EVSE agent. All fields are optional.

# Fields
- `baseline::Union{Power_kW,Nothing}` — Baseline power in kW.
- `power::Union{Power_kW,Nothing}` — Power setpoint in kW.
- `primary_activated::Union{Int,Nothing}` — Primary activated capacity.
- `primary_capacity::Union{Int,Nothing}` — Primary capacity.
- `primary_capacity_up::Union{Int,Nothing}` — Primary capacity up.
- `primary_capacity_down::Union{Int,Nothing}` — Primary capacity down.
"""
Base.@kwdef struct EvseSetDataRequest
    baseline::Union{Power_kW,Nothing} = nothing
    power::Union{Power_kW,Nothing} = nothing
    primary_activated::Union{Int,Nothing} = nothing
    primary_capacity::Union{Int,Nothing} = nothing
    primary_capacity_up::Union{Int,Nothing} = nothing
    primary_capacity_down::Union{Int,Nothing} = nothing
end

"""
    VehicleSetDataRequest

Request to set data on a vehicle agent. All fields are optional.

# Fields
- `power::Union{Power_kW,Nothing}` — Power setpoint in kW.
"""
Base.@kwdef struct VehicleSetDataRequest
    power::Union{Power_kW,Nothing} = nothing
end

"""
    TimestampedVehicleSoc

A timestamped state of charge measurement for a vehicle.

# Fields
- `timestamp::DateTime` — Time of the measurement.
- `value::Energy_kWh` — State of charge in kWh.
"""
struct TimestampedVehicleSoc
    timestamp::DateTime
    value::Energy_kWh
end
