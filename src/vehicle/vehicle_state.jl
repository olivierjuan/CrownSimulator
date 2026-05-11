"""
    VehicleState

Mutable state for a vehicle (EV) in the simulation. Implements `AbstractVehicleAgent`.

# Fields
- `id_::VehicleId` — Vehicle identifier.
- `site_id::SiteId` — Site where the vehicle is located.
- `model::VehicleModel` — Vehicle model (battery capacity, power limits, etc.).
- `soc::Energy_kWh` — Current state of charge in kWh.
- `previous_soc::Energy_kWh` — Previous state of charge in kWh.
- `power::Power_kW` — Current power in kW.
- `noise::Power_kW` — Noise added to power in kW.
- `connected::Bool` — Whether the vehicle is connected to an EVSE.
- `evse_id::Union{EvseId,Nothing}` — Identifier of the connected EVSE (if any).
"""
Base.@kwdef mutable struct VehicleState <: AbstractVehicleAgent
    id_::VehicleId
    site_id::SiteId
    model::VehicleModel
    soc::Energy_kWh
    previous_soc::Energy_kWh
    power::Power_kW
    noise::Power_kW
    connected::Bool
    evse_id::Union{EvseId,Nothing}
end

"""
    register!(v::VehicleState, context) -> Nothing

Register a vehicle state with the simulation context (fleet).

# Arguments
- `v::VehicleState` — The vehicle state to register.
- `context` — The simulation context containing vehicle fleet.
"""
function register!(v::VehicleState, context)
    push!(context.vehicles, v)
end

"""
    initialize(v::VehicleState) -> Nothing

Initialize a vehicle state before simulation starts, setting previous SoC to current SoC.

# Arguments
- `v::VehicleState` — The vehicle state to initialize.
"""
function initialize(v::VehicleState)
    v.previous_soc = v.soc
end

"""
    snapshot(v::VehicleState) -> VehicleSnapshot

Take a snapshot of the vehicle's current state for output.

# Arguments
- `v::VehicleState` — The vehicle state to snapshot.

# Returns
- A `VehicleSnapshot` with the vehicle's current data.
"""
function snapshot(v::VehicleState)
    VehicleSnapshot(
        id_=v.id_,
        capacity=v.model.capacity,
        max_soc=v.model.max_soc,
        max_ac_charge_power=v.model.max_ac_charge_power,
        max_dc_charge_power=v.model.max_dc_charge_power,
        max_charge_power_max_soc=v.model.max_charge_power_max_soc,
        soc=v.soc,
        soc_requirements=Energy_kWh[],
        min_ac_charge_power=v.model.min_ac_charge_power,
        min_dc_charge_power=v.model.min_dc_charge_power,
        model=v.model,
        power_losses=v.model.power_losses,
        soc_power_table=v.model.soc_power_table,
    )
end

