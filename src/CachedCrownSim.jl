"""
    CachedCrownSim

A Julia module for simulating EV (Electric Vehicle) charging with cached crown optimisation.

This module implements a discrete-event simulation of EV charging stations using
ConcurrentSim.jl. It models vehicles, EVSEs (Electric Vehicle Supply Equipment),
sites, networks, and spot markets. The simulation includes:

- Domain types for power, energy, timestamps, vehicles, and EVSEs
- Optimisation framework with external solver support
- Frequency Containment Reserve (FCR) and droop control
- Mobility scenarios with plug-in/plug-out events
- Bidding and capacity requirement services
- CSV/JSON I/O for data exchange

The module is designed to be used as part of a larger EV charging management system.
"""
module CachedCrownSim

using Dates
using ConcurrentSim
using ResumableFunctions
using StructArrays
using Interpolations

# Type alias exports
export Energy_kWh, Power_kW, Power_W, Ratio, Frequency_Hz, EnergyPrice_MWh, EnergyConsumption_Wh_minute
export VehicleId, EvseId, SiteId, TransactionId, SpotMarketAccessId

# Domain exports
export TimeRange, Datapoint, OptimizationHorizon
export generate_timepoints, generate_periods
export PowerLosses, VariablePowerLosses, PowerLimits, SocPowerTable, SocPowerTableItem
export get_useful_power, cross_max_and_min_charge_power, lookup_power
export TimestampedPrice, TimestampedPrices
export NetworkState, NORMAL, ALERT, EMERGENCY
export RecoveringMode, DEACTIVATED, ARMED, ACTIVATED, DEACTIVATING
export FrequencyRange, FrequencyActivationMapping, FrequencyActivationTable, FrequencyQualityDefiningParams
export ServicesRequestParameters, SocPenalties, InstantChargePenalties, ChargingRequirementsServiceParameters, TariffServiceParameters, FcrServiceParameters, BaselineStabilityServiceParameters, Co2ServiceParameters, DayAheadServiceParameters
export CurrentType, AC, DC, EvseModel
export VehicleModel
export VehicleTrip, FutureTransactionSeed
export DeliveryPoint, DeliveryPointCircuit, CircuitEvse, CircuitPowerLimits, OtherConsumption, OtherProduction
export EvseAgentRegistration, VehicleAgentRegistration, SiteAgentRegistration, NetworkAgentRegistration, SpotAgentRegistration
export EvseSetDataRequest, VehicleSetDataRequest, TimestampedVehicleSoc
export FcrSummary, Transaction, OptimizationResponseSummary, AbstractCapacityRequirement
export VehicleSnapshot, TransactionSnapshot, EvseSnapshot, ElectricNetworkSnapshot, SpotSnapshot, SiteSnapshot, FutureTransactionSnapshot, VirtualEnvironmentSnapshot
export Mobility, Plugin, Plugout
export CapacityRequirement, BiddingService
export DroopControlData, DroopControlResponse, DroopControlResponseSummary, DroopController
export Aggregator
export SpotState, NetworkStateContainer
export VehicleState, EvseState, SiteState
export SimulationConfig, OutputConfig, DatapointsOutputConfig
export SimulationState, run_simulation
export validate_config, merge_defaults
export EnergyNeed, OtherLoad, OptimizationRequestGenerator
export VehicleFleet, batch_soc_update!
export PluginInterface, MobilityPlugin, OptimizationPlugin, SpotPlugin, NetworkPlugin
export PluginManager, register_plugin!, setup!, step!, teardown!, setup_all!, step_all!, teardown_all!

# Function exports
export to_dto, load, from_config, from_dto, read_from_csv
export capacity, margin, dead_zone, max_steady_state_deviation, plus
export is_fcr_enabled, narrow, has_day_ahead_prices, has_customer_tariffs
export peek_next_event, discard_next_event!
export compute_vehicle_soc_update, batch_vehicle_soc_update!
export next_request_id!, power_limits, control

# Abstract agent interface exports
export AbstractAgent, AbstractVehicleAgent, AbstractEvseAgent, AbstractSiteAgent, AbstractNetworkAgent, AbstractSpotAgent
export register!, initialize, update!, snapshot

# Domain definitions
include("domain/timestamps.jl")
include("domain/power.jl")
include("domain/prices.jl")
include("domain/network.jl")
include("domain/services_request.jl")
include("domain/evse_model.jl")
include("domain/vehicle_model.jl")
include("domain/trips.jl")
include("domain/delivery_point.jl")
include("domain/agents.jl")
include("domain/optimization.jl")
include("domain/snapshot.jl")

# IO utilities
include("io/csv_reader.jl")
include("io/json_writer.jl")
include("io/datapoints_writer.jl")
include("simulation/config.jl")

# Agent mutable fleet state
include("vehicle/vehicle_state.jl")
include("evse/evse_state.jl")
include("site/site_state.jl")

# Network / spot state (must be before runner.jl)
include("spot/spot_state.jl")
include("network/network_state.jl")

# Core simulation infrastructure
include("simulation/fleet.jl")
include("simulation/plugins.jl")
include("simulation/runner.jl")

# Vehicle and EVSE batch update logic
include("vehicle/vehicle_update.jl")

# Energy need domain
include("vehicle/energy_need.jl")

# Scenarios
include("scenarios/mobility.jl")

include("scenarios/bidding_service.jl")

# Aggregator infrastructure
include("aggregator/droop_controller.jl")
include("aggregator/aggregator.jl")

# Optimization placeholder
include("optimization/optimizer.jl")
include("optimization/request_generator.jl")

end # module CachedCrownSim
