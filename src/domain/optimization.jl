"""
    FcrSummary

Summary of Frequency Containment Reserve (FCR) capacity for a transaction.

# Fields
- `capacity_up::Power_kW` — Upward FCR capacity in kW.
- `capacity_down::Power_kW` — Downward FCR capacity in kW.
- `margin_up::Power_kW` — Upward margin in kW (default: 0.0).
- `margin_down::Power_kW` — Downward margin in kW (default: 0.0).
- `activated::Power_kW` — Activated FCR power in kW (default: 0.0).
"""
Base.@kwdef struct FcrSummary
    capacity_up::Power_kW
    capacity_down::Power_kW
    margin_up::Power_kW = 0.0
    margin_down::Power_kW = 0.0
    activated::Power_kW = 0.0
end

"""
    capacity(summary::FcrSummary) -> Power_kW

Compute the minimum FCR capacity (the lesser of up and down) for a transaction.
"""
function capacity(summary::FcrSummary)::Power_kW
    min(summary.capacity_up, summary.capacity_down)
end

"""
    margin(summary::FcrSummary) -> Power_kW

Compute the minimum FCR margin (the lesser of up and down) for a transaction.
"""
function margin(summary::FcrSummary)::Power_kW
    min(summary.margin_up, summary.margin_down)
end

"""
    Transaction

Represents an optimized transaction between a vehicle and an EVSE.

# Fields
- `id::String` — Transaction identifier.
- `managed::Bool` — Whether this transaction is managed by the optimizer.
- `baseline::Power_kW` — Baseline power in kW.
- `power::Power_kW` — Optimized power in kW (default: 0.0).
- `ev_id::Union{String,Nothing}` — Optional vehicle identifier.
- `transaction_fcr_summary::Union{FcrSummary,Nothing}` — Optional FCR summary.
- `constant_loss::Union{Power_kW,Nothing}` — Optional constant power loss in kW.
"""
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
"""
    AbstractCapacityRequirement

Abstract supertype for capacity requirements. Used to break circular definitions between
optimization and scenario modules.
"""
abstract type AbstractCapacityRequirement end

"""
    OptimizationResponseSummary

Summary of the optimization response, including running time, capacity, transactions, and FCR data.

# Fields
- `running_time::Float64` — Optimization running time in seconds.
- `announced_capacity::AbstractCapacityRequirement` — Announced capacity requirement.
- `transactions::Vector{Transaction}` — Optimized transactions.
- `optimization_baseline::Power_kW` — Total baseline power in kW.
- `optimization_power::Power_kW` — Total optimized power in kW.
- `optimization_fcr_summary::FcrSummary` — Total FCR summary.
"""
Base.@kwdef struct OptimizationResponseSummary
    running_time::Float64
    announced_capacity::AbstractCapacityRequirement
    transactions::Vector{Transaction}
    optimization_baseline::Power_kW
    optimization_power::Power_kW
    optimization_fcr_summary::FcrSummary
end
