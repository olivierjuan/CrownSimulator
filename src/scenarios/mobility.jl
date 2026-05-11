"""
    AbstractPlugin

Abstract supertype for vehicle mobility events (plugin and plugout).
"""
abstract type AbstractPlugin end

"""
    Plugin

Represents a vehicle plug-in event (vehicle arrives and connects to an EVSE).

# Fields
- `datetime::DateTime` — Time of the plug-in event.
- `time::Float64` — Duration of the plugin event in seconds.
- `soc::Union{Float64,Nothing}` — Optional state of charge at plug-in.
- `evse_id::Union{String,Nothing}` — Optional EVSE identifier where the vehicle plugs in.
"""
Base.@kwdef struct Plugin
    datetime::DateTime
    time::Float64
    soc::Union{Float64,Nothing} = nothing
    evse_id::Union{String,Nothing} = nothing
end

"""
    Plugout

Represents a vehicle plug-out event (vehicle disconnects from an EVSE).

# Fields
- `datetime::DateTime` — Time of the plug-out event.
- `time::Float64` — Duration of the plug-out event in seconds.
- `evse_id::Union{String,Nothing}` — Optional EVSE identifier from which the vehicle unplugs.
"""
Base.@kwdef struct Plugout
    datetime::DateTime
    time::Float64
    evse_id::Union{String,Nothing} = nothing
end

"""
    Mobility

Mutable container for vehicle mobility events, tracking the current position in the event list.

# Fields
- `events::Vector{Union{Plugin,Plugout}}` — List of mobility events.
- `current_index::Int` — Current index in the event list (0-based or 1-based).
"""
mutable struct Mobility
    events::Vector{Union{Plugin,Plugout}}
    current_index::Int
end

"""
    from_dto(::Type{Mobility}, dto_vector) -> Mobility

Construct a `Mobility` instance from a vector of DTO dictionaries.

# Arguments
- `dto_vector` — Vector of dictionaries with keys `"type"` (optional, default `"plugin"`), `"at"`, `"time"`, and optionally `"soc"` or `"evse_id"`.

# Returns
- A new `Mobility` instance with parsed events and `current_index` set to 1.
"""
function from_dto(::Type{Mobility}, dto_vector)
    events = Union{Plugin,Plugout}[]
    for event in dto_vector
        event_type = get(event, "type", "plugin")
        if event_type == "plugout"
            push!(events, Plugout(event["at"], event["time"], get(event, "evse_id", nothing)))
        else
            push!(events, Plugin(event["at"], event["time"], get(event, "soc", nothing), get(event, "evse_id", nothing)))
        end
    end
    Mobility(events, 1)
end

"""
    peek_next_event(mobility::Mobility) -> Union{Plugin,Plugout,Nothing}

Peek at the next mobility event without consuming it.

# Arguments
- `mobility::Mobility` — The mobility instance to peek at.

# Returns
- The next event if available, or `nothing` if all events have been consumed.
"""
function peek_next_event(mobility::Mobility)
    if mobility.current_index <= length(mobility.events)
        return mobility.events[mobility.current_index]
    end
    return nothing
end

"""
    discard_next_event!(mobility::Mobility) -> Nothing

Advance the mobility event index, effectively discarding the current event.

# Arguments
- `mobility::Mobility` — The mobility instance to update.
"""
function discard_next_event!(mobility::Mobility)
    if mobility.current_index <= length(mobility.events)
        mobility.current_index += 1
    end
end
