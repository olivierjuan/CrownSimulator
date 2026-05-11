using StructArrays

"""
    VehicleFleet

A collection of vehicles managed as a StructArray for efficient vectorized operations.
Provides O(1) lookup by ID and cache-friendly iteration.

# Fields
- `vehicles::StructArray{VehicleState}` — StructArray of vehicle states.
- `index::Dict{VehicleId,Int}` — Fast lookup from vehicle ID to index.
"""
struct VehicleFleet
    vehicles::StructArray{VehicleState}
    index::Dict{VehicleId,Int}
end

"""
    VehicleFleet() -> VehicleFleet

Construct an empty VehicleFleet.
"""
function VehicleFleet()
    VehicleFleet(
        StructArray{VehicleState}(undef, 0),
        Dict{VehicleId,Int}(),
    )
end

"""
    VehicleFleet(vehicles::Vector{VehicleState}) -> VehicleFleet

Construct a VehicleFleet from a vector of VehicleState, building the index.
"""
function VehicleFleet(vehicles::Vector{VehicleState})
    sa = StructArray(vehicles)
    idx = Dict{VehicleId,Int}()
    for i in eachindex(sa)
        idx[sa[i].id_] = i
    end
    VehicleFleet(sa, idx)
end

"""
    Base.length(fleet::VehicleFleet) -> Int

Number of vehicles in the fleet.
"""
Base.length(fleet::VehicleFleet) = length(fleet.vehicles)

"""
    Base.getindex(fleet::VehicleFleet, id::VehicleId) -> VehicleState

Look up a vehicle by its ID in O(1) time.
"""
function Base.getindex(fleet::VehicleFleet, id::VehicleId)
    idx = fleet.index[id]
    return fleet.vehicles[idx]
end

"""
    Base.getindex(fleet::VehicleFleet, i::Int) -> VehicleState

Look up a vehicle by its index.
"""
function Base.getindex(fleet::VehicleFleet, i::Int)
    return fleet.vehicles[i]
end

"""
    Base.iterate(fleet::VehicleFleet, state=1)

Iterate over vehicles in the fleet.
"""
function Base.iterate(fleet::VehicleFleet, state=1)
    if state > length(fleet)
        return nothing
    end
    return (fleet.vehicles[state], state + 1)
end

"""
    Base.sizehint!(fleet::VehicleFleet, n::Int) -> VehicleFleet

Pre-allocate space for `n` vehicles in the fleet.
"""
function Base.sizehint!(fleet::VehicleFleet, n::Int)
    # Create a new StructArray with pre-allocated space
    new_vehicles = StructArray{VehicleState}(undef, n)
    for i in eachindex(fleet.vehicles)
        new_vehicles[i] = fleet.vehicles[i]
    end
    return VehicleFleet(new_vehicles, fleet.index)
end

"""
    push!(fleet::VehicleFleet, vehicle::VehicleState) -> VehicleFleet

Add a vehicle to the fleet. Returns the updated fleet.
"""
function Base.push!(fleet::VehicleFleet, vehicle::VehicleState)
    new_vehicles = StructArray(vcat(fleet.vehicles, [vehicle]))
    new_index = Dict{VehicleId,Int}()
    for i in eachindex(new_vehicles)
        new_index[new_vehicles[i].id_] = i
    end
    return VehicleFleet(new_vehicles, new_index)
end

"""
    batch_soc_update!(fleet::VehicleFleet, delta_t::Float64) -> Nothing

Batch update SoC for all connected vehicles in the fleet.
Uses StructArray for cache-friendly iteration.

# Arguments
- `fleet::VehicleFleet` — The fleet of vehicles to update.
- `delta_t::Float64` — Time interval in seconds.
"""
function batch_soc_update!(fleet::VehicleFleet, delta_t::Float64)
    for i in eachindex(fleet.vehicles)
        v = fleet.vehicles[i]
        if v.connected
            v.previous_soc = v.soc
            v.soc = compute_vehicle_soc_update(v, v.power, v.noise, delta_t)
        end
    end
end
