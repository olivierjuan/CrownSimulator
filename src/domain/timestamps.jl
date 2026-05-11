using Dates

# Define alias types for domain clarity
const Energy_kWh = Float64
const Power_kW = Float64
const Power_W = Float64
const Ratio = Float64
const Frequency_Hz = Float64
const EnergyPrice_MWh = Float64
const EnergyConsumption_Wh_minute = Float64

# Identity types for domain IDs
const VehicleId = String
const EvseId = String
const SiteId = String
const TransactionId = String
const SpotMarketAccessId = String

# Datapoint for a single timestep in the simulation.
Base.@kwdef struct Datapoint
    timestamp::DateTime
    start_::DateTime
    end_::DateTime
    delta_t::Dates.Period
    algorithm::String
    warmup::Bool
    version::String
    minimize_logs::Bool
end

# TimeRange from start to end (a time interval).
struct TimeRange
    from::DateTime
    to::DateTime
end

Base.in(dt::DateTime, p::TimeRange) = p.from <= dt < p.to
Base.in(p1::TimeRange, p2::TimeRange) = p2.from <= p1.from && p1.to <= p2.to

function Base.intersect(p1::TimeRange, p2::TimeRange)
    from = max(p1.from, p2.from)
    to = min(p1.to, p2.to)
    from < to ? TimeRange(from, to) : nothing
end

# Generate TimeRanges from a sequence of timepoints.
function generate_periods(timepoints::Vector{DateTime})
    periods = TimeRange[]
    for i in 1:(length(timepoints)-1)
        push!(periods, TimeRange(timepoints[i], timepoints[i+1]))
    end
    return periods
end

# Generate timepoints from start to stop with a given frequency.
function generate_timepoints(start::DateTime, stop::DateTime, delta::Dates.Period)
    pts = DateTime[]
    t = start
    while t <= stop
        push!(pts, t)
        t += delta
    end
    return pts
end

# Optimization horizon defining current and future look-ahead period.
struct OptimizationHorizon
    start::DateTime
    stop::DateTime
    period_duration::Dates.Period
end
