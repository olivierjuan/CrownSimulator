# CachedCrownSim

A Julia module for simulating EV (Electric Vehicle) charging with cached crown optimisation.

## Overview

CachedCrownSim implements a discrete-event simulation of EV charging stations using ConcurrentSim.jl. It models vehicles, EVSEs (Electric Vehicle Supply Equipment), sites, networks, and spot markets.

## Features

- **Domain Types**: Power, energy, timestamps, vehicles, EVSEs, and networks
- **Optimisation Framework**: External solver support with abstract optimizer interface
- **Frequency Containment Reserve (FCR)**: Droop control and frequency-based activation
- **Mobility Scenarios**: Plug-in/plug-out events with vehicle SoC tracking
- **Bidding Services**: Capacity requirements and day-ahead market participation
- **I/O**: CSV and JSON data exchange

## Installation

```julia
using Pkg
Pkg.add("CachedCrownSim")
```

## Quick Start

```julia
using CachedCrownSim

# Create a simulation configuration
config = SimulationConfig(
    start="2022-01-01T00:00:00",
    duration="PT1H",
    algorithm="test",
    scenario="default",
)

# Run the simulation
run_simulation(config)
```

## Project Structure

```
CachedCrownSim/
├── src/
│   ├── CachedCrownSim.jl    # Module definition and exports
│   ├── domain/              # Core domain types
│   ├── simulation/          # Simulation runner and config
│   ├── vehicle/             # Vehicle state and updates
│   ├── evse/                # EVSE state
│   ├── site/                # Site state
│   ├── spot/                # Spot market state
│   ├── network/             # Network state
│   ├── aggregator/          # Aggregator and droop control
│   ├── scenarios/           # Mobility and bidding scenarios
│   ├── optimization/        # Optimization framework
│   └── io/                  # CSV and JSON I/O
├── test/
│   └── runtests.jl          # Test suite
├── docs/
│   └── api/                 # API reference
└── Project.toml             # Julia project file
```

## Key Types

### Physical Quantities
- `Energy_kWh`, `Power_kW`, `Power_W`, `Ratio`, `Frequency_Hz`, `EnergyPrice_MWh`

### Identity Types
- `VehicleId`, `EvseId`, `SiteId`, `TransactionId`, `SpotMarketAccessId`

### Core Domain
- `PowerLimits`, `PowerLosses`, `SocPowerTable`, `VehicleModel`, `EvseModel`
- `TimeRange`, `Datapoint`, `OptimizationHorizon`
- `TimestampedPrice`, `TimestampedPrices`

### Simulation
- `SimulationConfig`, `SimulationState`, `run_simulation`
- `VehicleState`, `EvseState`, `SiteState`, `NetworkStateContainer`, `SpotState`
- `Aggregator`, `DroopController`

## API Reference

See `docs/api/index.md` for the complete API reference.

## License

See LICENSE file.
