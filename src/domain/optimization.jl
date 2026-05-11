Base.@kwdef struct FcrSummary
    capacity_up::Power_kW
    capacity_down::Power_kW
    margin_up::Power_kW = 0.0
    margin_down::Power_kW = 0.0
    activated::Power_kW = 0.0
end

function capacity(summary::FcrSummary)::Power_kW
    min(summary.capacity_up, summary.capacity_down)
end

function margin(summary::FcrSummary)::Power_kW
    min(summary.margin_up, summary.margin_down)
end

Base.@kwdef struct Transaction
    id::String
    managed::Bool
    baseline::Power_kW
    power::Power_kW = 0.0
    ev_id::Union{String,Nothing} = nothing
    transaction_fcr_summary::Union{FcrSummary,Nothing} = nothing
    constant_loss::Union{Power_kW,Nothing} = nothing
end

# OptimizationResponseSummary depends on CapacityRequirement which is part of scenarios; placeholder type to break circular definition
abstract type AbstractCapacityRequirement end

Base.@kwdef struct OptimizationResponseSummary
    running_time::Float64
    announced_capacity::AbstractCapacityRequirement
    transactions::Vector{Transaction}
    optimization_baseline::Power_kW
    optimization_power::Power_kW
    optimization_fcr_summary::FcrSummary
end
