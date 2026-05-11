using Dates

# Define alias types for domain clarity
"""
    Energy_kWh

Type alias for energy values in kilowatt-hours (Float64).
"""
const Energy_kWh = Float64

"""
    Power_kW

Type alias for power values in kilowatts (Float64).
"""
const Power_kW = Float64

"""
    Power_W

Type alias for power values in watts (Float64).
"""
const Power_W = Float64

"""
    Ratio

Type alias for dimensionless ratio values (Float64).
"""
const Ratio = Float64

"""
    Frequency_Hz

Type alias for frequency values in hertz (Float64).
"""
const Frequency_Hz = Float64

"""
    EnergyPrice_MWh

Type alias for energy price values in euros per megawatt-hour (Float64).
"""
const EnergyPrice_MWh = Float64

"""
    EnergyConsumption_Wh_minute

Type alias for energy consumption values in watt-hours per minute (Float64).
"""
const EnergyConsumption_Wh_minute = Float64

# Identity types for domain IDs
"""
    VehicleId

Type alias for vehicle identifiers (String).
"""
const VehicleId = String

"""
    EvseId

Type alias for EVSE identifiers (String).
"""
const EvseId = String

"""
    SiteId

Type alias for site identifiers (String).
"""
const SiteId = String

"""
    TransactionId

Type alias for transaction identifiers (String).
"""
const TransactionId = String

"""
    SpotMarketAccessId

Type alias for spot market access identifiers (String).
"""
const SpotMarketAccessId = String

"""
    Datapoint

Represents a single simulation timestep with associated metadata.

# Fields
- `timestamp::DateTime` — Current timestamp of the datapoint.
- `start_::DateTime` — Start time of the simulation step.
- `end_::DateTime` — End time of the simulation step.
- `delta_t::Dates.Period` — Duration of the timestep.
- `algorithm::String` — Name of the optimization algorithm in use.
- `warmup::Bool` — Whether this timestep is part of a warmup period.
- `version::String` — Version identifier for the simulation run.
- `minimize_logs::Bool` — Whether to suppress verbose logging.

# Examples
```julia
dp = Datapoint(
    timestamp=DateTime(2022,1,1),
    start_=DateTime(2022,1,1),
    end_=DateTime(2022,1,2),
    delta_t=Hour(1),
    algorithm="test",
    warmup=false,
    version="1",
    minimize_logs=false
)
```
"""
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

"""
    TimeRange

A time interval defined by `from` and `to` datetimes. The interval is half-open: `from <= dt < to`.

# Fields
- `from::DateTime` — Start of the time range (inclusive).
- `to::DateTime` — End of the time range (exclusive).

# Examples
```julia
tr = TimeRange(DateTime(2022,1,1), DateTime(2022,1,2))
DateTime(2022,1,1) in tr  # true
DateTime(2022,1,2) in tr  # false
```
"""
struct TimeRange
    from::DateTime
    to::DateTime
end

"""
    Base.in(dt::DateTime, p::TimeRange) -> Bool

Check whether a `DateTime` falls within a `TimeRange` (half-open: `from <= dt < to`).
"""
Base.in(dt::DateTime, p::TimeRange) = p.from <= dt < p.to

"""
    Base.in(p1::TimeRange, p2::TimeRange) -> Bool

Check whether a `TimeRange` is fully contained within another `TimeRange`.
"""
Base.in(p1::TimeRange, p2::TimeRange) = p2.from <= p1.from && p1.to <= p2.to

"""
    Base.intersect(p1::TimeRange, p2::TimeRange) -> Union{TimeRange,Nothing}

Compute the intersection of two time ranges. Returns `nothing` if they do not overlap.
"""
function Base.intersect(p1::TimeRange, p2::TimeRange)
    from = max(p1.from, p2.from)
    to = min(p1.to, p2.to)
    from < to ? TimeRange(from, to) : nothing
end

"""
    generate_periods(timepoints::Vector{DateTime}) -> Vector{TimeRange}

Generate consecutive time periods from a sequence of timepoints.
Each period is a `TimeRange` from `timepoints[i]` to `timepoints[i+1]`.

# Returns
- A vector of `TimeRange` objects, one fewer than the number of timepoints.

# Examples
```julia
pts = [DateTime(2022,1,1), DateTime(2022,1,1,1), DateTime(2022,1,1,2)]
periods = generate_periods(pts)  # 2 TimeRange objects
```
"""
function generate_periods(timepoints::Vector{DateTime})
    periods = TimeRange[]
    for i in 1:(length(timepoints)-1)
        push!(periods, TimeRange(timepoints[i], timepoints[i+1]))
    end
    return periods
end

"""
    generate_timepoints(start::DateTime, stop::DateTime, delta::Dates.Period) -> Vector{DateTime}

Generate evenly-spaced timepoints from `start` to `stop` with interval `delta`.
The last point may be at or before `stop`.

# Returns
- A vector of `DateTime` values spaced by `delta`.

# Examples
```julia
pts = generate_timepoints(DateTime(2022,1,1), DateTime(2022,1,1,3), Hour(1))
length(pts)  # 4
```
"""
function generate_timepoints(start::DateTime, stop::DateTime, delta::Dates.Period)
    pts = DateTime[]
    t = start
    while t <= stop
        push!(pts, t)
        t += delta
    end
    return pts
end

"""
    OptimizationHorizon

Defines the time horizon for an optimization window, including start, stop, and period duration.

# Fields
- `start::DateTime` — Start of the optimization horizon.
- `stop::DateTime` — End of the optimization horizon.
- `period_duration::Dates.Period` — Duration of each optimization period.
"""
struct OptimizationHorizon
    start::DateTime
    stop::DateTime
    period_duration::Dates.Period
end
