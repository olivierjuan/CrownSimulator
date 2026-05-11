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

struct EvseAgentRegistration
    id_::EvseId
end

struct VehicleAgentRegistration
    id_::VehicleId
end

struct SiteAgentRegistration
    id_::SiteId
end

struct NetworkAgentRegistration
    id_::String
end

struct SpotAgentRegistration
    id_::SpotMarketAccessId
end

Base.@kwdef struct EvseSetDataRequest
    baseline::Union{Power_kW,Nothing} = nothing
    power::Union{Power_kW,Nothing} = nothing
    primary_activated::Union{Int,Nothing} = nothing
    primary_capacity::Union{Int,Nothing} = nothing
    primary_capacity_up::Union{Int,Nothing} = nothing
    primary_capacity_down::Union{Int,Nothing} = nothing
end

Base.@kwdef struct VehicleSetDataRequest
    power::Union{Power_kW,Nothing} = nothing
end

struct TimestampedVehicleSoc
    timestamp::DateTime
    value::Energy_kWh
end
