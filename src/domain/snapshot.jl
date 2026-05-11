"""
    VehicleSnapshot

An immutable snapshot of a vehicle's state at a given simulation timestep.

# Fields
- `id_::VehicleId` — Vehicle identifier.
- `capacity::Energy_kWh` — Battery capacity in kWh.
- `max_soc::Energy_kWh` — Maximum state of charge in kWh.
- `max_ac_charge_power::Power_kW` — Maximum AC charge power in kW.
- `max_dc_charge_power::Power_kW` — Maximum DC charge power in kW.
- `max_charge_power_max_soc::Energy_kWh` — Maximum charge power at max SoC in kWh.
- `soc::Energy_kWh` — Current state of charge in kWh.
- `soc_requirements::Vector{Energy_kWh}` — SoC requirements for each period.
- `min_ac_charge_power::Power_kW` — Minimum AC charge power in kW (default: 0.0).
- `min_dc_charge_power::Power_kW` — Minimum DC charge power in kW (default: 0.0).
- `model::Union{VehicleModel,Nothing}` — Optional vehicle model.
- `current_trip::Union{VehicleTrip,Nothing}` — Optional current trip.
- `next_trip::Union{VehicleTrip,Nothing}` — Optional next trip.
- `power_losses::Union{PowerLosses,Nothing}` — Optional power losses.
- `soc_power_table::Union{SocPowerTable,Nothing}` — Optional SoC power table.
- `estimated_consumption::Union{Energy_kWh,Nothing}` — Optional estimated consumption in kWh.
- `departure::Union{DateTime,Nothing}` — Optional departure time.
- `future_transactions::Vector{FutureTransactionSeed}` — Future transaction seeds.
"""
Base.@kwdef struct VehicleSnapshot
    id_::VehicleId
    capacity::Energy_kWh
    max_soc::Energy_kWh
    max_ac_charge_power::Power_kW
    max_dc_charge_power::Power_kW
    max_charge_power_max_soc::Energy_kWh
    soc::Energy_kWh
    soc_requirements::Vector{Energy_kWh}
    min_ac_charge_power::Power_kW = 0.0
    min_dc_charge_power::Power_kW = 0.0
    model::Union{VehicleModel,Nothing} = nothing
    current_trip::Union{VehicleTrip,Nothing} = nothing
    next_trip::Union{VehicleTrip,Nothing} = nothing
    power_losses::Union{PowerLosses,Nothing} = nothing
    soc_power_table::Union{SocPowerTable,Nothing} = nothing
    estimated_consumption::Union{Energy_kWh,Nothing} = nothing
    departure::Union{DateTime,Nothing} = nothing
    future_transactions::Vector{FutureTransactionSeed} = FutureTransactionSeed[]
end

"""
    TransactionSnapshot

An immutable snapshot of an active transaction between a vehicle and an EVSE.

# Fields
- `id_::TransactionId` — Transaction identifier.
- `vehicle::VehicleSnapshot` — Snapshot of the vehicle involved.
- `power_limits::PowerLimits` — Power limits for this transaction.
- `baseline::Power_kW` — Baseline power for this transaction in kW.
"""
Base.@kwdef struct TransactionSnapshot
    id_::TransactionId
    vehicle::VehicleSnapshot
    power_limits::PowerLimits
    baseline::Power_kW
end

"""
    EvseSnapshot

An immutable snapshot of an EVSE's state at a given simulation timestep.

# Fields
- `id_::EvseId` — EVSE identifier.
- `baseline::Power_kW` — Baseline power in kW.
- `power_losses::PowerLosses` — Power loss parameters.
- `supports_v2g::Bool` — Whether the EVSE supports vehicle-to-grid.
- `transaction::Union{TransactionSnapshot,Nothing}` — Optional active transaction.
- `future_transactions::Vector{TransactionSnapshot}` — Future transaction snapshots.
"""
Base.@kwdef struct EvseSnapshot
    id_::EvseId
    baseline::Power_kW
    power_losses::PowerLosses
    supports_v2g::Bool
    transaction::Union{TransactionSnapshot,Nothing} = nothing
    future_transactions::Vector{TransactionSnapshot} = TransactionSnapshot[]
end

"""
    ElectricNetworkSnapshot

An immutable snapshot of the electrical network state.

# Fields
- `frequency::Frequency_Hz` — Current grid frequency in Hz.
- `state::NetworkState` — Current network state (NORMAL, ALERT, or EMERGENCY).
"""
Base.@kwdef struct ElectricNetworkSnapshot
    frequency::Frequency_Hz
    state::NetworkState
end

"""
    SpotSnapshot

An immutable snapshot of the spot market state.

# Fields
- `day_ahead_prices::Vector{TimestampedPrice}` — Day-ahead energy prices.
"""
Base.@kwdef struct SpotSnapshot
    day_ahead_prices::Vector{TimestampedPrice}
end

"""
    has_day_ahead_prices(spot::SpotSnapshot) -> Bool

Check whether the spot snapshot contains any day-ahead prices.
"""
has_day_ahead_prices(spot::SpotSnapshot) = !isempty(spot.day_ahead_prices)

"""
    SiteSnapshot

An immutable snapshot of a site's state at a given simulation timestep.

# Fields
- `delivery_point::Union{DeliveryPoint,Nothing}` — Optional delivery point for this site.
- `customer_tariffs::Vector{TimestampedPrice}` — Customer tariff prices.
"""
Base.@kwdef struct SiteSnapshot
    delivery_point::Union{DeliveryPoint,Nothing}
    customer_tariffs::Vector{TimestampedPrice}
end

"""
    has_customer_tariffs(site::SiteSnapshot) -> Bool

Check whether the site snapshot contains any customer tariffs.
"""
has_customer_tariffs(site::SiteSnapshot) = !isempty(site.customer_tariffs)

"""
    FutureTransactionSnapshot

An immutable snapshot of a future transaction between a vehicle and an EVSE.

# Fields
- `ev_id::VehicleId` — Vehicle identifier.
- `model::VehicleModel` — Vehicle model.
- `arrival::DateTime` — Expected arrival time.
- `departure::DateTime` — Expected departure time.
- `estimated_soc::Union{Energy_kWh,Nothing}` — Estimated SoC on arrival in kWh.
- `energy_needed::Union{Energy_kWh,Nothing}` — Estimated energy needed for next trip in kWh.
- `power_limits::PowerLimits` — Power limits for this transaction.
"""
Base.@kwdef struct FutureTransactionSnapshot
    ev_id::VehicleId
    model::VehicleModel
    arrival::DateTime
    departure::DateTime
    estimated_soc::Union{Energy_kWh,Nothing}
    energy_needed::Union{Energy_kWh,Nothing}
    power_limits::PowerLimits
end

"""
    to_dto(ft::FutureTransactionSnapshot) -> Dict{String,Any}

Convert a `FutureTransactionSnapshot` to a DTO dictionary for serialization.

# Returns
- A dictionary with vehicle ID, arrival/departure times, power limits, and optional SoC/energy fields.
"""
function to_dto(ft::FutureTransactionSnapshot)
    dto = Dict{String,Any}(
        "vehicleId" => ft.ev_id,
        "arrival" => ft.arrival,
        "departure" => ft.departure,
        "powerLimits" => Dict{String,Any}(
            "minChargePower" => ft.power_limits.min_charge_power * 1000,
            "maxChargePower" => ft.power_limits.max_charge_power * 1000,
            "maxDischargePower" => ft.power_limits.max_discharge_power * 1000,
            "efficiencyMinDischargePower" => ft.power_limits.efficiency_min_discharge_power * 1000,
            "efficiencyMinChargePower" => ft.power_limits.efficiency_min_charge_power * 1000,
        ),
    )
    if ft.estimated_soc !== nothing
        dto["estimatedSocOnArrival"] = ft.estimated_soc * 1000
    end
    if ft.energy_needed !== nothing
        dto["energyNeededForNextTrip"] = ft.energy_needed * 1000
    end
    dto
end

"""
    VirtualEnvironmentSnapshot

An immutable snapshot of the entire simulation environment at a given timestep.
Aggregates all domain snapshots into a single structure for the optimization solver.

# Fields
- `timestamp::DateTime` — Current timestamp.
- `horizon::OptimizationHorizon` — Optimization time horizon.
- `sites::Vector{SiteSnapshot}` — Site snapshots.
- `evses::Vector{EvseSnapshot}` — EVSE snapshots.
- `vehicles::Vector{VehicleSnapshot}` — Vehicle snapshots.
- `recovering_state::RecoveringMode` — Current network recovery mode.
- `announced_capacity::Union{AbstractCapacityRequirement,Nothing}` — Optional announced capacity requirement.
- `network::Union{ElectricNetworkSnapshot,Nothing}` — Optional network snapshot.
- `spot::Union{SpotSnapshot,Nothing}` — Optional spot market snapshot.
- `previous_optimization_response::Union{OptimizationResponseSummary,Nothing}` — Optional previous optimization response.
"""
Base.@kwdef struct VirtualEnvironmentSnapshot
    timestamp::DateTime
    horizon::OptimizationHorizon
    sites::Vector{SiteSnapshot}
    evses::Vector{EvseSnapshot}
    vehicles::Vector{VehicleSnapshot}
    recovering_state::RecoveringMode
    announced_capacity::Union{AbstractCapacityRequirement,Nothing} = nothing
    network::Union{ElectricNetworkSnapshot,Nothing} = nothing
    spot::Union{SpotSnapshot,Nothing} = nothing
    previous_optimization_response::Union{OptimizationResponseSummary,Nothing} = nothing
end
