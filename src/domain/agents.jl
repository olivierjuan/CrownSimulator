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
