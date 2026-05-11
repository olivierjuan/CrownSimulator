# CachedCrownSim API Reference

## Module Structure

```
CachedCrownSim
├── domain/          # Core domain types and constants
├── simulation/      # Simulation configuration and runner
├── vehicle/         # Vehicle state and updates
├── evse/            # EVSE state
├── site/            # Site state
├── spot/            # Spot market state
├── network/         # Network state
├── aggregator/      # Aggregator and droop control
├── scenarios/       # Mobility and bidding scenarios
├── optimization/    # Optimization framework
└── io/              # CSV and JSON I/O
```

## Type Aliases

### Physical Quantities
| Type | Alias | Description |
|------|-------|-------------|
| `Energy_kWh` | `Float64` | Energy in kilowatt-hours |
| `Power_kW` | `Float64` | Power in kilowatts |
| `Power_W` | `Float64` | Power in watts |
| `Ratio` | `Float64` | Dimensionless ratio (0.0 to 1.0) |
| `Frequency_Hz` | `Float64` | Frequency in hertz |
| `EnergyPrice_MWh` | `Float64` | Energy price in euros per MWh |
| `EnergyConsumption_Wh_minute` | `Float64` | Energy consumption in Wh/min |

### Identity Types
| Type | Alias | Description |
|------|-------|-------------|
| `VehicleId` | `String` | Vehicle identifier |
| `EvseId` | `String` | EVSE identifier |
| `SiteId` | `String` | Site identifier |
| `TransactionId` | `String` | Transaction identifier |
| `SpotMarketAccessId` | `String` | Spot market access identifier |

## Enums

| Enum | Values | Description |
|------|--------|-------------|
| `NetworkState` | `NORMAL=0, ALERT=1, EMERGENCY=2` | Network operational states |
| `RecoveringMode` | `DEACTIVATED=0, ARMED=1, ACTIVATED=2, DEACTIVATING=3` | Recovery modes |
| `CurrentType` | `AC, DC` | Electrical current type |

## Domain Types

### Power & Energy
| Type | Description |
|------|-------------|
| `PowerLosses` | Combined standby and variable power losses |
| `VariablePowerLosses` | Rate-dependent power loss coefficients |
| `PowerLimits` | Charge/discharge power boundaries |
| `SocPowerTableItem` | Single SoC-to-power mapping entry |
| `SocPowerTable` | Table of SoC-to-power mappings |

### Time & Timestamps
| Type | Description |
|------|-------------|
| `TimeRange` | Half-open time interval (from, to) |
| `Datapoint` | Single simulation timestep with metadata |
| `OptimizationHorizon` | Time horizon for optimization window |

### Prices
| Type | Description |
|------|-------------|
| `TimestampedPrice` | Single energy price entry |
| `TimestampedPrices` | Collection of timestamped prices |

### Network & Frequency
| Type | Description |
|------|-------------|
| `FrequencyRange` | Frequency bounds (up, down) |
| `FrequencyActivationMapping` | Frequency-to-activation coefficient mapping |
| `FrequencyActivationTable` | Table of frequency activation mappings |
| `FrequencyQualityDefiningParams` | FCR quality parameters |

### Vehicle & EVSE
| Type | Description |
|------|-------------|
| `VehicleModel` | Vehicle battery model and capabilities |
| `EvseModel` | EVSE model and capabilities |
| `VehicleTrip` | Vehicle trip with start/destination times |
| `FutureTransactionSeed` | Future transaction seed based on a trip |

### Delivery Point
| Type | Description |
|------|-------------|
| `DeliveryPoint` | Physical delivery point with circuits |
| `DeliveryPointCircuit` | Circuit within a delivery point |
| `CircuitEvse` | EVSE connected to a circuit |
| `CircuitPowerLimits` | Power limits for a circuit |
| `OtherConsumption` | Non-EV load on a circuit |
| `OtherProduction` | Power production source on a circuit |

### Optimization & FCR
| Type | Description |
|------|-------------|
| `FcrSummary` | FCR capacity summary |
| `Transaction` | Optimized transaction |
| `OptimizationResponseSummary` | Optimization response summary |
| `AbstractCapacityRequirement` | Abstract capacity requirement |

### Snapshots
| Type | Description |
|------|-------------|
| `VehicleSnapshot` | Vehicle state at a timestep |
| `TransactionSnapshot` | Active transaction snapshot |
| `EvseSnapshot` | EVSE state at a timestep |
| `ElectricNetworkSnapshot` | Network state snapshot |
| `SpotSnapshot` | Spot market snapshot |
| `SiteSnapshot` | Site state snapshot |
| `FutureTransactionSnapshot` | Future transaction snapshot |
| `VirtualEnvironmentSnapshot` | Complete simulation environment snapshot |

### Agents
| Type | Description |
|------|-------------|
| `AbstractAgent` | Abstract supertype for all agents |
| `AbstractVehicleAgent` | Abstract vehicle agent |
| `AbstractEvseAgent` | Abstract EVSE agent |
| `AbstractSiteAgent` | Abstract site agent |
| `AbstractNetworkAgent` | Abstract network agent |
| `AbstractSpotAgent` | Abstract spot market agent |

### Agents (Mutable State)
| Type | Description |
|------|-------------|
| `VehicleState` | Mutable vehicle state |
| `EvseState` | Mutable EVSE state |
| `SiteState` | Mutable site state |
| `NetworkStateContainer` | Mutable network state |
| `SpotState` | Mutable spot market state |
| `Aggregator` | Mutable aggregator state |

### Agents (Registration)
| Type | Description |
|------|-------------|
| `EvseAgentRegistration` | EVSE registration record |
| `VehicleAgentRegistration` | Vehicle registration record |
| `SiteAgentRegistration` | Site registration record |
| `NetworkAgentRegistration` | Network registration record |
| `SpotAgentRegistration` | Spot market registration record |
| `EvseSetDataRequest` | EVSE data request |
| `VehicleSetDataRequest` | Vehicle data request |
| `TimestampedVehicleSoc` | Timestamped vehicle SoC |

### Scenarios
| Type | Description |
|------|-------------|
| `Mobility` | Vehicle mobility events container |
| `Plugin` | Vehicle plug-in event |
| `Plugout` | Vehicle plug-out event |
| `CapacityRequirement` | Capacity requirement for a period |
| `BiddingService` | Bidding and capacity management |

### Optimization
| Type | Description |
|------|-------------|
| `AbstractOptimizer` | Abstract optimizer |
| `ExternalOptimizer` | User-provided solver wrapper |
| `OptimizationRequestGenerator` | Optimization request generator |

### Droop Control
| Type | Description |
|------|-------------|
| `DroopControlData` | Input data for droop control |
| `DroopControlResponseSummary` | Summary of droop control response |
| `DroopControlResponse` | Response from droop control |
| `DroopController` | Frequency droop controller |

### Simulation
| Type | Description |
|------|-------------|
| `SimulationConfig` | Simulation configuration |
| `OutputConfig` | Output configuration |
| `DatapointsOutputConfig` | Datapoints output configuration |
| `SimulationState` | Mutable simulation state |
| `EnergyNeed` | Energy need during a time period |

## Key Functions

### Power
| Function | Description |
|----------|-------------|
| `get_useful_power(losses, power)` | Compute effective power after losses |
| `cross_max_and_min_charge_power(self, ev_max, ev_min)` | Intersect EVSE and vehicle power limits |
| `lookup_power(table, soc)` | Look up max power for a SoC percentage |
| `capacity(summary)` | Minimum FCR capacity |
| `margin(summary)` | Minimum FCR margin |

### Simulation
| Function | Description |
|----------|-------------|
| `run_simulation(config)` | Run a complete simulation |
| `initialize_agents!(state)` | Initialize all agents |
| `batch_vehicle_soc_update!(vehicles, delta_t)` | Batch update vehicle SoC |
| `compute_vehicle_soc_update(vehicle, power, noise, delta_t)` | Compute vehicle SoC update |

### Agent Lifecycle
| Function | Description |
|----------|-------------|
| `register!(agent, context)` | Register an agent with the simulation |
| `initialize(agent)` | Initialize an agent before simulation |
| `update!(agent, dt, current_time)` | Update an agent for a timestep |
| `snapshot(agent)` | Take a snapshot of agent state |

### Droop Control
| Function | Description |
|----------|-------------|
| `control(controller, data)` | Compute droop control response |

### Optimization
| Function | Description |
|----------|-------------|
| `next_request_id!(gen)` | Get next request ID |
| `power_limits(model)` | Extract power limits from model |

### Network
| Function | Description |
|----------|-------------|
| `dead_zone(table)` | Compute dead zone from activation table |
| `max_steady_state_deviation(table)` | Compute max steady-state deviation |
| `plus(table, base_frequency)` | Shift frequency table by base frequency |

### Mobility
| Function | Description |
|----------|-------------|
| `peek_next_event(mobility)` | Peek at next mobility event |
| `discard_next_event!(mobility)` | Advance mobility event index |

### Config
| Function | Description |
|----------|-------------|
| `validate_config(config)` | Validate simulation config |
| `merge_defaults(config)` | Merge config with defaults |

### I/O
| Function | Description |
|----------|-------------|
| `read_and_parse(filename, parse_fn)` | Read and parse CSV file |
| `write_datapoint!(writer, timestamp, datapoint)` | Write a datapoint to file |
| `close_writer!(writer)` | Close datapoints writer |

### DTO Conversion
| Function | Description |
|----------|-------------|
| `to_dto(obj)` | Convert to DTO dictionary |
| `load(Type, dto)` | Construct from DTO dictionary |
| `from_config(Type, cfg)` | Construct from config dictionary |

## Usage

```julia
using CachedCrownSim

# Create a simulation config
config = SimulationConfig(
    start="2022-01-01T00:00:00",
    duration="PT1H",
    algorithm="test",
    scenario="default",
)

# Run the simulation
run_simulation(config)
```
