module CachedCrownSim

using Dates
using ConcurrentSim
using ResumableFunctions

# Domain exports
export TimeRange, Datapoint, OptimizationHorizon
export generate_timepoints, generate_periods
export PowerLosses, VariablePowerLosses, PowerLimits, SocPowerTable, SocPowerTableItem
export get_useful_power, cross_max_and_min_charge_power
export TimestampedPrice, TimestampedPrices
export NetworkState, RecoveringMode, FrequencyRange, FrequencyActivationMapping, FrequencyActivationTable, FrequencyQualityDefiningParams
export ServicesRequestParameters, SocPenalties, InstantChargePenalties, ChargingRequirementsServiceParameters, TariffServiceParameters, FcrServiceParameters, BaselineStabilityServiceParameters, Co2ServiceParameters, DayAheadServiceParameters
export CurrentType, EvseModel
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
export SimulationConfig, OutputConfig, DatapointsOutputConfig
export SimulationState, run_simulation

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

# Core simulation infrastructure
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

# Network / spot state
include("spot/spot_state.jl")
include("network/network_state.jl")

# Optimization placeholder
include("optimization/optimizer.jl")
include("optimization/request_generator.jl")

end # module CachedCrownSim
