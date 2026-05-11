struct CapacityRequirement
    period::TimeRange
    capacity_up::Power_kW
    capacity_down::Power_kW
end

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

mutable struct BiddingService
    from_csv::Bool
    capacities::Vector{CapacityRequirement}
    default_announced::Power_kW
end

function BiddingService(default_announced::Power_kW=100.0)
    BiddingService(false, CapacityRequirement[], default_announced)
end
