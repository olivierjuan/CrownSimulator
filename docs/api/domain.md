# Domain API Reference

## Power & Energy Types

### VariablePowerLosses
Variable (rate-dependent) power loss coefficients for charging and discharging.

**Fields:**
- `charging::Ratio` — Fractional power loss during charging (0.0 to 1.0)
- `discharging::Ratio` — Fractional power loss during discharging (0.0 to 1.0)

### PowerLosses
Combined standby and variable power losses for an EVSE or vehicle.

**Fields:**
- `standby::Power_kW` — Constant standby power consumption in kW
- `variable::VariablePowerLosses` — Rate-dependent losses for charging and discharging

### PowerLimits
Power limits for an EVSE or vehicle, defining charge/discharge power boundaries.

**Fields:**
- `max_charge_power::Power_kW` — Maximum charge power in kW
- `min_charge_power::Power_kW` — Minimum charge power in kW (default: 0.0)
- `max_discharge_power::Power_kW` — Maximum discharge power in kW (default: 0.0)
- `efficiency_min_discharge_power::Power_kW` — Minimum discharge power for efficiency (default: 0.0)
- `efficiency_min_charge_power::Power_kW` — Minimum charge power for efficiency (default: 0.0)

### SocPowerTableItem
A single entry in a state-of-charge (SoC) power table.

**Fields:**
- `soc::Int` — State of charge percentage (0-100)
- `power::Power_kW` — Maximum power at this SoC level in kW

### SocPowerTable
A table of SoC-to-power mappings.

**Fields:**
- `items::Vector{SocPowerTableItem}` — Ordered list of SoC power table entries

**Functions:**
- `lookup_power(table, soc)` — Look up max power for a SoC percentage
- `to_dto(table; capacity)` — Convert to DTO dictionary
- `from_config(Type, cfg)` — Construct from configuration

## Time & Timestamps

### TimeRange
A time interval defined by `from` and `to` datetimes (half-open: `from <= dt < to`).

**Fields:**
- `from::DateTime` — Start of the time range (inclusive)
- `to::DateTime` — End of the time range (exclusive)

### Datapoint
Represents a single simulation timestep.

**Fields:**
- `timestamp::DateTime` — Current timestamp
- `start_::DateTime` — Start time of the step
- `end_::DateTime` — End time of the step
- `delta_t::Dates.Period` — Duration of the timestep
- `algorithm::String` — Optimization algorithm name
- `warmup::Bool` — Whether this is a warmup period
- `version::String` — Version identifier
- `minimize_logs::Bool` — Whether to suppress verbose logging

### OptimizationHorizon
Defines the time horizon for an optimization window.

**Fields:**
- `start::DateTime` — Start of the optimization horizon
- `stop::DateTime` — End of the optimization horizon
- `period_duration::Dates.Period` — Duration of each optimization period

## Prices

### TimestampedPrice
A single energy price entry with a timestamp.

**Fields:**
- `timestamp::DateTime` — Time at which the price applies
- `value::EnergyPrice_MWh` — Energy price in euros per MWh

### TimestampedPrices
Collection of timestamped energy prices.

**Fields:**
- `all::Vector{TimestampedPrice}` — All prices (sorted by timestamp)
- `current::Vector{TimestampedPrice}` — Prices applicable to the current timestep

**Functions:**
- `update!(prices, datapoint)` — Update price collections
- `drop_too_old!(prices, datapoint)` — Remove expired prices
- `update_current!(prices, datapoint)` — Refresh current prices

## Network & Frequency

### FrequencyRange
A frequency range defined by upper and lower bounds.

**Fields:**
- `up::Frequency_Hz` — Upper frequency bound in Hz
- `down::Frequency_Hz` — Lower frequency bound in Hz

### FrequencyActivationMapping
Maps a frequency value to an activation coefficient.

**Fields:**
- `frequency::Frequency_Hz` — Frequency value in Hz
- `activation::Float64` — Activation coefficient (-1.0 to 1.0)

### FrequencyActivationTable
A table of frequency-to-activation mappings for FCR.

**Fields:**
- `mappings::Vector{FrequencyActivationMapping}` — Ordered list of frequency activation mappings

**Functions:**
- `dead_zone(table)` — Compute dead zone frequency range
- `max_steady_state_deviation(table)` — Compute max steady-state deviation
- `plus(table, base_frequency)` — Shift frequency table by base frequency

### FrequencyQualityDefiningParams
Parameters defining frequency quality requirements for FCR services.

**Fields:**
- `base_frequency::Frequency_Hz` — Base grid frequency (typically 50.0)
- `frequency_activation_table::FrequencyActivationTable` — Frequency activation table
- `asymmetric_response_allowed::Bool` — Whether asymmetric response is allowed
- `minimum_duration_at_full_power::Dates.Period` — Minimum duration at full power

## Vehicle & EVSE

### VehicleModel
Represents the physical model and capabilities of a vehicle.

**Fields:**
- `capacity::Energy_kWh` — Battery capacity in kWh
- `min_soc::Energy_kWh` — Minimum SoC in kWh
- `max_soc::Energy_kWh` — Maximum SoC in kWh
- `max_ac_charge_power::Power_kW` — Maximum AC charge power in kW
- `max_dc_charge_power::Power_kW` — Maximum DC charge power in kW
- `max_charge_power_max_soc::Energy_kWh` — Max charge power at max SoC (default: 0.0)
- `min_ac_charge_power::Power_kW` — Min AC charge power (default: 0.0)
- `min_dc_charge_power::Power_kW` — Min DC charge power (default: 0.0)
- `power_losses::Union{PowerLosses,Nothing}` — Optional power losses
- `soc_power_table::Union{SocPowerTable,Nothing}` — Optional SoC power table

### EvseModel
Represents the physical model and capabilities of an EVSE.

**Fields:**
- `power_losses::PowerLosses` — Power loss parameters
- `max_charge_power::Power_kW` — Max charge power (default: 10.0)
- `max_discharge_power::Power_kW` — Max discharge power (default: 9.2)
- `min_charge_power::Power_kW` — Min charge power (default: 0.0)
- `efficiency_min_discharge_power::Power_kW` — Min discharge power for efficiency (default: 2.0)
- `efficiency_min_charge_power::Power_kW` — Min charge power for efficiency (default: 2.0)
- `current_type::CurrentType` — AC or DC (default: AC)
- `supports_v2g::Bool` — V2G support (default: false)

### VehicleTrip
Represents a vehicle trip.

**Fields:**
- `start::DateTime` — Start time of the trip
- `destination::DateTime` — Arrival time at the destination

### FutureTransactionSeed
Represents a seed for a future transaction.

**Fields:**
- `trip::VehicleTrip` — The vehicle trip associated with this future transaction

## Delivery Point

### DeliveryPoint
Represents a physical delivery point with circuits, EVSEs, and power limits.

**Fields:**
- `id_::String` — Unique identifier
- `phases::String` — Phases on which installed
- `power_limits::CircuitPowerLimits` — Power limits
- `circuits::Vector{DeliveryPointCircuit}` — Circuits
- `other_consumptions::Vector{OtherConsumption}` — Non-EV loads
- `other_productions::Vector{OtherProduction}` — Power production sources
- `subscribed_power::Union{CircuitPowerLimits,Nothing}` — Optional subscribed power limits

### DeliveryPointCircuit
Represents a circuit within a delivery point.

**Fields:**
- `id_::String` — Unique identifier
- `phases::String` — Phases on which installed
- `installed_on_phase::String` — Phase where connected
- `circuits::Vector{DeliveryPointCircuit}` — Sub-circuits
- `evses::Vector{CircuitEvse}` — EVSEs connected
- `other_consumptions::Vector{OtherConsumption}` — Non-EV loads
- `other_productions::Vector{OtherProduction}` — Power production sources
- `power_limits::Union{CircuitPowerLimits,Nothing}` — Optional power limits

### CircuitEvse
Represents an EVSE connected to a delivery point circuit.

**Fields:**
- `evse_id::String` — Unique identifier
- `phases::String` — Phases on which installed
- `installed_on_phase::String` — Phase where connected
- `priority::Int` — Priority for load balancing (default: 0)

### CircuitPowerLimits
Power limits for a delivery point circuit.

**Fields:**
- `max_charge_power::Union{Power_kW,Nothing}` — Max charge power (may be nothing)
- `max_discharge_power::Union{Power_kW,Nothing}` — Max discharge power (may be nothing)

### OtherConsumption
Represents a non-EV electrical load.

**Fields:**
- `circuit_id::String` — Circuit identifier
- `from::DateTime` — Start time
- `to::DateTime` — End time
- `phases::String` — Phases on which installed
- `installed_on_phase::String` — Phase where connected
- `power::Power_W` — Power consumption in watts

### OtherProduction
Represents electrical production (e.g., solar PV).

**Fields:**
- `circuit_id::String` — Circuit identifier
- `from::DateTime` — Start time
- `to::DateTime` — End time
- `phases::String` — Phases on which installed
- `installed_on_phase::String` — Phase where connected
- `power::Power_W` — Power production in watts

## Optimization & FCR

### FcrSummary
Summary of FCR capacity for a transaction.

**Fields:**
- `capacity_up::Power_kW` — Upward FCR capacity in kW
- `capacity_down::Power_kW` — Downward FCR capacity in kW
- `margin_up::Power_kW` — Upward margin (default: 0.0)
- `margin_down::Power_kW` — Downward margin (default: 0.0)
- `activated::Power_kW` — Activated FCR power (default: 0.0)

**Functions:**
- `capacity(summary)` — Minimum FCR capacity
- `margin(summary)` — Minimum FCR margin

### Transaction
Represents an optimized transaction between a vehicle and an EVSE.

**Fields:**
- `id::String` — Transaction identifier
- `managed::Bool` — Whether managed by optimizer
- `baseline::Power_kW` — Baseline power in kW
- `power::Power_kW` — Optimized power (default: 0.0)
- `ev_id::Union{String,Nothing}` — Optional vehicle identifier
- `transaction_fcr_summary::Union{FcrSummary,Nothing}` — Optional FCR summary
- `constant_loss::Union{Power_kW,Nothing}` — Optional constant power loss

### OptimizationResponseSummary
Summary of the optimization response.

**Fields:**
- `running_time::Float64` — Running time in seconds
- `announced_capacity::AbstractCapacityRequirement` — Announced capacity
- `transactions::Vector{Transaction}` — Optimized transactions
- `optimization_baseline::Power_kW` — Total baseline power in kW
- `optimization_power::Power_kW` — Total optimized power in kW
- `optimization_fcr_summary::FcrSummary` — Total FCR summary

## Snapshots

### VehicleSnapshot
Vehicle state at a given simulation timestep.

**Fields:**
- `id_::VehicleId` — Vehicle identifier
- `capacity::Energy_kWh` — Battery capacity
- `max_soc::Energy_kWh` — Maximum SoC
- `max_ac_charge_power::Power_kW` — Maximum AC charge power
- `max_dc_charge_power::Power_kW` — Maximum DC charge power
- `max_charge_power_max_soc::Energy_kWh` — Max charge power at max SoC
- `soc::Energy_kWh` — Current SoC
- `soc_requirements::Vector{Energy_kWh}` — SoC requirements per period
- `min_ac_charge_power::Power_kW` — Min AC charge power (default: 0.0)
- `min_dc_charge_power::Power_kW` — Min DC charge power (default: 0.0)
- `model::Union{VehicleModel,Nothing}` — Optional vehicle model
- `current_trip::Union{VehicleTrip,Nothing}` — Optional current trip
- `next_trip::Union{VehicleTrip,Nothing}` — Optional next trip
- `power_losses::Union{PowerLosses,Nothing}` — Optional power losses
- `soc_power_table::Union{SocPowerTable,Nothing}` — Optional SoC power table
- `estimated_consumption::Union{Energy_kWh,Nothing}` — Optional estimated consumption
- `departure::Union{DateTime,Nothing}` — Optional departure time
- `future_transactions::Vector{FutureTransactionSeed}` — Future transaction seeds

### TransactionSnapshot
Active transaction snapshot.

**Fields:**
- `id_::TransactionId` — Transaction identifier
- `vehicle::VehicleSnapshot` — Vehicle snapshot
- `power_limits::PowerLimits` — Power limits
- `baseline::Power_kW` — Baseline power in kW

### EvseSnapshot
EVSE state at a given simulation timestep.

**Fields:**
- `id_::EvseId` — EVSE identifier
- `baseline::Power_kW` — Baseline power in kW
- `power_losses::PowerLosses` — Power loss parameters
- `supports_v2g::Bool` — V2G support
- `transaction::Union{TransactionSnapshot,Nothing}` — Optional active transaction
- `future_transactions::Vector{TransactionSnapshot}` — Future transaction snapshots

### ElectricNetworkSnapshot
Electrical network state snapshot.

**Fields:**
- `frequency::Frequency_Hz` — Current grid frequency in Hz
- `state::NetworkState` — Current network state

### SpotSnapshot
Spot market state snapshot.

**Fields:**
- `day_ahead_prices::Vector{TimestampedPrice}` — Day-ahead energy prices

### SiteSnapshot
Site state snapshot.

**Fields:**
- `delivery_point::Union{DeliveryPoint,Nothing}` — Optional delivery point
- `customer_tariffs::Vector{TimestampedPrice}` — Customer tariff prices

### FutureTransactionSnapshot
Future transaction snapshot.

**Fields:**
- `ev_id::VehicleId` — Vehicle identifier
- `model::VehicleModel` — Vehicle model
- `arrival::DateTime` — Expected arrival time
- `departure::DateTime` — Expected departure time
- `estimated_soc::Union{Energy_kWh,Nothing}` — Estimated SoC on arrival
- `energy_needed::Union{Energy_kWh,Nothing}` — Estimated energy needed for next trip
- `power_limits::PowerLimits` — Power limits

### VirtualEnvironmentSnapshot
Complete simulation environment snapshot.

**Fields:**
- `timestamp::DateTime` — Current timestamp
- `horizon::OptimizationHorizon` — Optimization time horizon
- `sites::Vector{SiteSnapshot}` — Site snapshots
- `evses::Vector{EvseSnapshot}` — EVSE snapshots
- `vehicles::Vector{VehicleSnapshot}` — Vehicle snapshots
- `recovering_state::RecoveringMode` — Current recovery mode
- `announced_capacity::Union{AbstractCapacityRequirement,Nothing}` — Optional announced capacity
- `network::Union{ElectricNetworkSnapshot,Nothing}` — Optional network snapshot
- `spot::Union{SpotSnapshot,Nothing}` — Optional spot market snapshot
- `previous_optimization_response::Union{OptimizationResponseSummary,Nothing}` — Optional previous optimization response

## Agents

### Agent Registration Types
- `EvseAgentRegistration` — EVSE registration record
- `VehicleAgentRegistration` — Vehicle registration record
- `SiteAgentRegistration` — Site registration record
- `NetworkAgentRegistration` — Network registration record
- `SpotAgentRegistration` — Spot market registration record

### Agent Data Request Types
- `EvseSetDataRequest` — EVSE data request (baseline, power, primary capacity)
- `VehicleSetDataRequest` — Vehicle data request (power)
- `TimestampedVehicleSoc` — Timestamped vehicle SoC

## Scenarios

### Mobility
Mutable container for vehicle mobility events.

**Fields:**
- `events::Vector{Union{Plugin,Plugout}}` — List of mobility events
- `current_index::Int` — Current index in the event list

**Functions:**
- `from_dto(::Type{Mobility}, dto_vector)` — Construct from DTO
- `peek_next_event(mobility)` — Peek at next event
- `discard_next_event!(mobility)` — Advance event index

### Plugin
Vehicle plug-in event.

**Fields:**
- `datetime::DateTime` — Time of the event
- `time::Float64` — Duration in seconds
- `soc::Union{Float64,Nothing}` — Optional SoC at plug-in
- `evse_id::Union{String,Nothing}` — Optional EVSE identifier

### Plugout
Vehicle plug-out event.

**Fields:**
- `datetime::DateTime` — Time of the event
- `time::Float64` — Duration in seconds
- `evse_id::Union{String,Nothing}` — Optional EVSE identifier

### CapacityRequirement
Capacity requirement for a specific time period.

**Fields:**
- `period::TimeRange` — Time range for this requirement
- `capacity_up::Power_kW` — Required upward capacity in kW
- `capacity_down::Power_kW` — Required downward capacity in kW

**Functions:**
- `narrow(req, start, end_)` — Narrow to a sub-interval

### BiddingService
Mutable service for managing bidding and capacity requirements.

**Fields:**
- `from_csv::Bool` — Whether loaded from CSV
- `capacities::Vector{CapacityRequirement}` — Capacity requirements
- `default_announced::Power_kW` — Default announced power in kW

## Optimization

### AbstractOptimizer
Abstract supertype for all optimizer implementations.

### ExternalOptimizer
Optimizer that wraps a user-provided solve function.

**Fields:**
- `solve_fn::Function` — The user-provided solve function

### OptimizationRequestGenerator
Generator for optimization requests.

**Fields:**
- `id::Int` — Current request ID counter
- `services::ServicesRequestParameters` — Service parameters

**Functions:**
- `next_request_id!(gen)` — Increment and return next request ID

## Droop Control

### DroopControlData
Input data for droop control computation.

**Fields:**
- `frequency::Frequency_Hz` — Current grid frequency in Hz
- `announced_capacity::Vector{CapacityRequirement}` — Announced capacity requirements
- `transactions::Vector{Transaction}` — Transactions to process

### DroopControlResponseSummary
Summary of droop control response totals.

**Fields:**
- `total_power::Power_kW` — Total power in kW
- `total_baseline::Power_kW` — Total baseline power in kW
- `total_activated::Power_kW` — Total activated power in kW
- `total_capacity_up::Power_kW` — Total capacity up in kW
- `total_capacity_down::Power_kW` — Total capacity down in kW
- `total_discharge::Power_kW` — Total discharge in kW

### DroopControlResponse
Response from droop control computation.

**Fields:**
- `transactions::Vector{Transaction}` — Updated transactions
- `summary::DroopControlResponseSummary` — Summary of the response

### DroopController
Droop controller for FCR control.

**Fields:**
- `interp::Interpolations.GriddedInterpolation` — Interpolation function

**Functions:**
- `DroopController()` — Construct default controller
- `control(controller, data)` — Compute droop control response

## Simulation

### SimulationConfig
Configuration for a simulation run.

**Fields:**
- `start::String` — Start time (ISO 8601)
- `duration::String` — Duration (e.g., "PT1H")
- `algorithm::String` — Optimization algorithm name
- `scenario::String` — Scenario name
- `output::OutputConfig` — Output configuration

### OutputConfig
Container for output configuration.

**Fields:**
- `datapoints::DatapointsOutputConfig` — Datapoints output config

### DatapointsOutputConfig
Configuration for datapoints output.

**Fields:**
- `writer::String` — Writer type (e.g., "single")
- `filename_pattern::String` — Filename pattern
- `split_time::Union{String,Nothing}` — Optional time split

### SimulationState
Mutable state container for the simulation.

**Fields:**
- `config::SimulationConfig` — Configuration
- `current_time::DateTime` — Current simulation time
- `stop::Bool` — Whether stopped
- `vehicles::Vector{VehicleState}` — Vehicle states
- `evses::Vector{EvseState}` — EVSE states
- `site::SiteState` — Site state
- `network::NetworkStateContainer` — Network state
- `spot::SpotState` — Spot market state

### EnergyNeed
Represents an energy need during a time period.

**Fields:**
- `period::TimeRange` — Time range
- `value::Float64` — Amount of energy needed (kWh)

## I/O

### JsonListWriter
Incremental JSON array writer.

**Fields:**
- `io::IOStream` — Output stream
- `first_value::Ref{Bool}` — First value flag

**Functions:**
- `JsonListWriter(filename)` — Construct writer
- `write(writer, value)` — Write a value
- `close(writer)` — Close and finalize

### SingleFileDatapointsWriter
Single-file writer for simulation datapoints.

**Fields:**
- `filename_pattern::String` — Filename pattern
- `warmup_end::DateTime` — End of warmup period
- `end_time::DateTime` — End of simulation
- `writer::Union{JsonListWriter,Nothing}` — Underlying JSON writer

**Functions:**
- `write_datapoint!(writer, timestamp, datapoint)` — Write a datapoint
- `close_writer!(writer)` — Close the writer

## Key Functions

### Power Functions
- `get_useful_power(losses, power)` — Compute effective power after losses
- `cross_max_and_min_charge_power(self, ev_max, ev_min)` — Intersect EVSE and vehicle power limits
- `lookup_power(table, soc)` — Look up max power for a SoC percentage

### Simulation Functions
- `run_simulation(config)` — Run a complete simulation
- `initialize_agents!(state)` — Initialize all agents
- `batch_vehicle_soc_update!(vehicles, delta_t)` — Batch update vehicle SoC
- `compute_vehicle_soc_update(vehicle, power, noise, delta_t)` — Compute vehicle SoC update

### Agent Lifecycle Functions
- `register!(agent, context)` — Register an agent with the simulation
- `initialize(agent)` — Initialize an agent before simulation
- `update!(agent, dt, current_time)` — Update an agent for a timestep
- `snapshot(agent)` — Take a snapshot of agent state

### Droop Control Functions
- `control(controller, data)` — Compute droop control response

### Optimization Functions
- `next_request_id!(gen)` — Get next request ID
- `power_limits(model)` — Extract power limits from model

### Network Functions
- `dead_zone(table)` — Compute dead zone from activation table
- `max_steady_state_deviation(table)` — Compute max steady-state deviation
- `plus(table, base_frequency)` — Shift frequency table by base frequency

### Mobility Functions
- `peek_next_event(mobility)` — Peek at next mobility event
- `discard_next_event!(mobility)` — Advance mobility event index

### Config Functions
- `validate_config(config)` — Validate simulation config
- `merge_defaults(config)` — Merge config with defaults

### I/O Functions
- `read_and_parse(filename, parse_fn)` — Read and parse CSV file
- `write_datapoint!(writer, timestamp, datapoint)` — Write a datapoint to file
- `close_writer!(writer)` — Close datapoints writer

### DTO Conversion Functions
- `to_dto(obj)` — Convert to DTO dictionary
- `load(Type, dto)` — Construct from DTO dictionary
- `from_config(Type, cfg)` — Construct from config dictionary
