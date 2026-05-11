function compute_vehicle_soc_update(
    vehicle::VehicleState,
    power::Power_kW,
    noise::Power_kW,
    delta_t::Float64 # seconds
)::Energy_kWh
    power_with_noise = power + noise
    power_useful = get_useful_power(vehicle.model.power_losses, power_with_noise)
    delta_soc = power_useful * (delta_t / 3600.0)
    new_soc = max(min(vehicle.soc + delta_soc, vehicle.model.capacity), 0.0)
    new_soc
end

function batch_vehicle_soc_update!(vehicles::Vector{VehicleState}, delta_t::Float64)
    for i in eachindex(vehicles)
        v = vehicles[i]
        if v.connected
            v.previous_soc = v.soc
            v.soc = compute_vehicle_soc_update(v, v.power, v.noise, delta_t)
        end
    end
end
