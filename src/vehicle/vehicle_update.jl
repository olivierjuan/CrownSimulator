"""
    compute_vehicle_soc_update(vehicle::VehicleState, power::Power_kW, noise::Power_kW, delta_t::Float64) -> Energy_kWh

Compute the new state of charge for a vehicle after a power application over a time interval.

# Arguments
- `vehicle::VehicleState` — The vehicle state.
- `power::Power_kW` — Power applied to the vehicle in kW.
- `noise::Power_kW` — Noise added to power in kW.
- `delta_t::Float64` — Time interval in seconds.

# Returns
- The new state of charge in kWh.

# Examples
```julia
vehicle = VehicleState(
    id_="v1", site_id="s1",
    model=VehicleModel(capacity=100.0, min_soc=0.0, max_soc=100.0, max_ac_charge_power=11.0, max_dc_charge_power=50.0),
    soc=50.0, previous_soc=50.0, power=0.0, noise=0.0, connected=true, evse_id="e1"
)
compute_vehicle_soc_update(vehicle, 10.0, 0.0, 3600.0)  # ~60.0
```
"""
function compute_vehicle_soc_update(
    vehicle::VehicleState,
    power::Power_kW,
    noise::Power_kW,
    delta_t::Float64 # seconds
)::Energy_kWh
    if delta_t < 0.0
        throw(ArgumentError("delta_t must be non-negative, got $delta_t"))
    end
    if vehicle.model.power_losses === nothing
        throw(ArgumentError("Vehicle model must have power_losses defined"))
    end
    power_with_noise = power + noise
    power_useful = get_useful_power(vehicle.model.power_losses, power_with_noise)
    delta_soc = power_useful * (delta_t / 3600.0)
    new_soc = max(min(vehicle.soc + delta_soc, vehicle.model.capacity), 0.0)
    new_soc
end

"""
    update!(v::VehicleState, dt::Float64, current_time::DateTime) -> Nothing

Update a vehicle's state of charge for the current timestep, if connected.

# Arguments
- `v::VehicleState` — The vehicle state to update.
- `dt::Float64` — Time interval in seconds.
- `current_time::DateTime` — Current simulation time.
"""
function update!(v::VehicleState, dt::Float64, current_time::DateTime)
    if v.connected
        v.previous_soc = v.soc
        v.soc = compute_vehicle_soc_update(v, v.power, v.noise, dt)
    end
end

"""
    batch_vehicle_soc_update!(vehicles::Vector{VehicleState}, delta_t::Float64) -> Nothing

Batch update the state of charge for all connected vehicles.

# Arguments
- `vehicles::Vector{VehicleState}` — Vector of vehicle states to update.
- `delta_t::Float64` — Time interval in seconds.

# Notes
- Only vehicles with `connected == true` are updated.
- Each vehicle's `previous_soc` is set to its current `soc` before updating.
"""
function batch_vehicle_soc_update!(vehicles::Vector{VehicleState}, delta_t::Float64)
    for i in eachindex(vehicles)
        v = vehicles[i]
        if v.connected
            v.previous_soc = v.soc
            v.soc = compute_vehicle_soc_update(v, v.power, v.noise, delta_t)
        end
    end
end
