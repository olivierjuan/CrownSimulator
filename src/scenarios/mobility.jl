abstract type AbstractPlugin end

Base.@kwdef struct Plugin
    datetime::DateTime
    time::Float64
    soc::Union{Float64,Nothing} = nothing
    evse_id::Union{String,Nothing} = nothing
end

Base.@kwdef struct Plugout
    datetime::DateTime
    time::Float64
    evse_id::Union{String,Nothing} = nothing
end

mutable struct Mobility
    events::Vector{Union{Plugin,Plugout}}
    current_index::Int
end

function from_dto(::Type{Mobility}, dto_vector)
    events = Union{Plugin,Plugout}[]
    for event in dto_vector
        push!(events, Plugin(event["at"], event["time"]))
    end
    Mobility(events, 1)
end

function peek_next_event(mobility::Mobility)
    if mobility.current_index <= length(mobility.events)
        return mobility.events[mobility.current_index]
    end
    return nothing
end

function discard_next_event!(mobility::Mobility)
    if mobility.current_index <= length(mobility.events)
        mobility.current_index += 1
    end
end
