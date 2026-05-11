"""
    CapacityRequirement

A capacity requirement for a specific time period, defining required up and down power.

# Fields
- `period::TimeRange` — Time range for this requirement.
- `capacity_up::Power_kW` — Required upward capacity in kW.
- `capacity_down::Power_kW` — Required downward capacity in kW.
"""
struct CapacityRequirement
    period::TimeRange
    capacity_up::Power_kW
    capacity_down::Power_kW
end

"""
    narrow(req::CapacityRequirement, start::DateTime, end_::DateTime) -> CapacityRequirement

Narrow a capacity requirement to a sub-interval, adjusting the period accordingly.

# Arguments
- `req::CapacityRequirement` — The original capacity requirement.
- `start::DateTime` — Start of the sub-interval.
- `end_::DateTime` — End of the sub-interval.

# Returns
- A new `CapacityRequirement` with the period narrowed to the intersection.
"""
function narrow(req::CapacityRequirement, start::DateTime, end_::DateTime)
    if req.period.from <= start && start <= end_ <= req.period.to
        period = TimeRange(start, end_)
    elseif req.period.from <= start && start <= req.period.to
        period = TimeRange(start, req.period.to)
    elseif req.period.from <= end_ && end_ <= req.period.to
        period = TimeRange(req.period.from, end_)
    else
        period = req.period
    end
    CapacityRequirement(period, req.capacity_up, req.capacity_down)
end

"""
    BiddingService

Mutable service for managing bidding and capacity requirements.

# Fields
- `from_csv::Bool` — Whether capacity requirements are loaded from CSV.
- `capacities::Vector{CapacityRequirement}` — List of capacity requirements.
- `default_announced::Power_kW` — Default announced power in kW.
"""
mutable struct BiddingService
    from_csv::Bool
    capacities::Vector{CapacityRequirement}
    default_announced::Power_kW
end

"""
    BiddingService(default_announced::Power_kW=100.0) -> BiddingService

Construct a default `BiddingService` with no CSV loading and an empty capacity list.

# Arguments
- `default_announced::Power_kW` — Default announced power in kW (default: 100.0).

# Returns
- A new `BiddingService` instance.
"""
function BiddingService(default_announced::Power_kW=100.0)
    BiddingService(false, CapacityRequirement[], default_announced)
end
