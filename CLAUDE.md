# CLAUDE.md - CachedCrownSim

## Project Overview

Julia reimplementation of an EV charging simulator (Python -> Julia). Uses ConcurrentSim.jl for discrete event simulation with vectorized batch updates for massive fleet performance.

## Current Status

- **32 source files** across domain, simulation, vehicle, evse, site, aggregator, network, spot, optimization, and IO modules
- **ConcurrentSim.jl** event-driven simulation runner with vectorized batch update processes
- **Domain model types** matching Python implementation: power limits, vehicle models, energy needs, mobility events, etc.
- **Aggregator and droop controller** infrastructure
- **IO utilities** for CSV reading and JSON writing
- **Main entry point** and test suite
- **11 passing tests** across 5 test sets
- All dependencies installed and package precompiles successfully

## Project Structure

```
CachedCrownSim.jl
├── src/
│   ├── CachedCrownSim.jl        # Module entry
│   ├── domain/                   # Domain types and structs
│   │   ├── timestamps.jl         # TimeRange, Datapoint, OptimizationHorizon
│   │   ├── power.jl              # PowerLosses, VariablePowerLosses, PowerLimits, SocPowerTable
│   │   ├── prices.jl             # TimestampedPrice, TimestampedPrices
│   │   ├── network.jl            # NetworkState, RecoveringMode, FrequencyActivationMapping
│   │   ├── services_request.jl   # ServicesRequestParameters and subtypes
│   │   ├── evse_model.jl         # EvseModel, CurrentType
│   │   ├── vehicle_model.jl      # VehicleModel
│   │   ├── trips.jl              # VehicleTrip, FutureTransactionSeed
│   │   ├── delivery_point.jl     # DeliveryPoint, DeliveryPointCircuit, CircuitEvse
│   │   ├── agents.jl             # Agent registrations, set data requests
│   │   ├── optimization.jl       # FcrSummary, Transaction, OptimizationResponseSummary
│   │   └── snapshot.jl           # Snapshot types for all agents
│   ├── simulation/               # Simulation infrastructure
│   │   ├── runner.jl             # ConcurrentSim runner, batch update process
│   │   └── config.jl             # SimulationConfig, OutputConfig
│   ├── vehicle/                  # Vehicle agent
│   │   ├── vehicle_state.jl      # VehicleState mutable struct
│   │   ├── vehicle_update.jl     # Vectorized SoC update
│   │   └── energy_need.jl        # EnergyNeed
│   ├── evse/                     # EVSE agent
│   │   └── evse_state.jl         # EvseState mutable struct
│   ├── site/                     # Site agent
│   │   └── site_state.jl         # SiteState mutable struct
│   ├── aggregator/               # Aggregator and droop control
│   │   ├── aggregator.jl         # Aggregator struct
│   │   └── droop_controller.jl   # DroopController, DroopControlResponse
│   ├── network/                  # Network agent
│   │   └── network_state.jl      # NetworkStateContainer
│   ├── spot/                     # Spot agent
│   │   └── spot_state.jl         # SpotState
│   ├── scenarios/                # Mobility and bidding
│   │   ├── mobility.jl           # Mobility, Plugin, Plugout
│   │   └── bidding_service.jl    # CapacityRequirement, BiddingService
│   ├── optimization/             # Optimizer interface
│   │   ├── optimizer.jl          # AbstractOptimizer, ExternalOptimizer
│   │   └── request_generator.jl  # OptimizationRequestGenerator
│   ├── io/                       # IO utilities
│   │   ├── csv_reader.jl         # CSV reading
│   │   ├── json_writer.jl        # JSON writing
│   │   └── datapoints_writer.jl  # DatapointsWriter
│   └── main.jl                   # Entry point
└── test/
    └── runtests.jl               # Test suite
```

## Agent Tasks for Code Improvement

### Agent 1: Code Coverage and Testing

**Objective:** Increase test coverage from current basic tests to comprehensive suite.

**Tasks:**
1. **Add unit tests for all domain types:**
   - Test all PowerLimits methods (cross_max_and_min_charge_power)
   - Test SocPowerTableItem.to_dto and from_config
   - Test all service request parameter loading and to_dto
   - Test EvseModel.from_config and power_limits method
   - Test VehicleModel.from_config
   - Test DeliveryPoint, DeliveryPointCircuit, CircuitEvse loading and serialization
   - Test TimeRange (intersection, in, generate_periods, generate_timepoints)
   - Test TimestampedPrice and TimestampedPrices

2. **Add integration tests:**
   - Test ConcurrentSim runner with mock agents
   - Test batch_vehicle_soc_update! with multiple vehicles
   - Test DroopController with various frequency inputs
   - Test mobility event generation and application
   - Test Aggregator registration and basic operations

3. **Add edge case tests:**
   - Test empty collections, nil values, boundary conditions
   - Test time calculations near boundaries
   - Test power limits with zero/negative values
   - Test SoC update with extreme power values

4. **Create test data fixtures:**
   - Create sample configuration files
   - Create sample CSV files for mobility and pricing data
   - Create sample JSON outputs

**Output:** Complete test suite with >80% code coverage.

---

### Agent 2: Architecture and Modularity

**Objective:** Improve code organization, reduce dependencies, enhance modularity.

**Tasks:**
1. **Review and refactor module structure:**
   - Separate domain types from agent logic
   - Create clear interface boundaries between modules
   - Implement dependency injection patterns
   - Create abstract types for agent interfaces

2. **Implement proper agent lifecycle:**
   - Create AgentAbstractType with standard interface
   - Implement register!, initialize, update!, snapshot methods
   - Create agent factory pattern
   - Implement agent lifecycle management

3. **Improve configuration system:**
   - Create proper config validation
   - Implement config merging with defaults
   - Create config serialization/deserialization
   - Implement config environment variables

4. **Create plugin architecture:**
   - Define plugin interface
   - Implement plugin loading and management
   - Create plugin examples (mobility, optimization)

5. **Implement proper state management:**
   - Create state machine for agents
   - Implement state persistence and recovery
   - Create state change notifications

**Output:** Clean, modular architecture with clear separation of concerns.

---

### Agent 3: Code Quality and Best Practices

**Objective:** Improve code quality, readability, and maintainability.

**Tasks:**
1. **Code review and refactoring:**
   - Remove duplicate code and logic
   - Simplify complex methods
   - Improve naming conventions
   - Add proper error handling
   - Implement input validation

2. **Performance optimization:**
   - Profile and optimize hot paths
   - Implement proper memory management
   - Use appropriate data structures
   - Implement vectorized operations where possible
   - Add caching for repeated computations

3. **Implement proper logging:**
   - Create structured logging system
   - Implement log levels and filtering
   - Add performance logging
   - Create log output formats

4. **Add documentation:**
   - Add docstrings to all public functions
   - Create module documentation
   - Add examples and usage guides
   - Create API documentation

5. **Implement error handling:**
   - Create custom error types
   - Implement error recovery strategies
   - Add error reporting and monitoring
   - Create error boundaries

**Output:** Clean, well-documented, maintainable code with proper error handling.

---

### Agent 4: Evolution and Extensibility

**Objective:** Make the codebase easy to extend and evolve.

**Tasks:**
1. **Create extension points:**
   - Define plugin interfaces
   - Create hook system for agent events
   - Implement configuration for feature flags
   - Create API for custom algorithms

2. **Implement proper versioning:**
   - Add semantic versioning
   - Create migration scripts
   - Implement backward compatibility
   - Create deprecation warnings

3. **Create extension examples:**
   - Implement example custom agent
   - Create example plugin
   - Implement example optimization algorithm
   - Create example mobility pattern

4. **Improve testing infrastructure:**
   - Create test utilities
   - Implement test fixtures
   - Create test generators
   - Implement performance testing

5. **Create documentation system:**
   - Implement doc generation
   - Create API documentation
   - Create user guides
   - Create developer guides

**Output:** Extensible, maintainable codebase with clear extension points.

---

### Agent 5: Performance and Scalability

**Objective:** Optimize for massive fleet performance.

**Tasks:**
1. **Profile current implementation:**
   - Identify performance bottlenecks
   - Profile memory usage
   - Identify optimization opportunities
   - Create performance baseline

2. **Optimize critical paths:**
   - Optimize SoC update calculations
   - Optimize power limit calculations
   - Optimize snapshot generation
   - Optimize event handling

3. **Implement parallel processing:**
   - Implement multi-threading for independent agents
   - Create batch processing for similar operations
   - Implement lazy evaluation
   - Create caching strategies

4. **Implement efficient data structures:**
   - Use StructArrays for vectorized operations
   - Implement proper memory layout
   - Create efficient lookup tables
   - Implement data compression

5. **Create performance monitoring:**
   - Implement performance metrics
   - Create performance dashboards
   - Implement performance alerts
   - Create performance benchmarks

**Output:** High-performance code capable of handling 100k+ agents.

---

## Implementation Guidelines

### Code Style
- Use `Base.@kwdef` for all structs
- Prefer immutable structs for value types
- Use mutable structs for stateful types
- Follow Julia naming conventions (snake_case for functions, CamelCase for types)
- Add docstrings to all public functions
- Use proper error handling and input validation

### Testing
- Use `Test` standard library
- Create comprehensive test coverage
- Use property-based testing where appropriate
- Implement test fixtures and generators
- Run tests on every change

### Documentation
- Add docstrings to all public functions
- Create module documentation
- Create API documentation
- Create examples and usage guides
- Update documentation with code changes

### Performance
- Profile before optimizing
- Use appropriate data structures
- Implement vectorized operations
- Use proper memory management
- Create performance benchmarks

### Modularity
- Separate concerns
- Define clear interfaces
- Implement dependency injection
- Create plugin architecture
- Use proper abstraction layers

## Commands to Run

```bash
# Run tests
julia --project=/home/D01856/fast-simulator/CachedCrownSim -e 'include("test/runtests.jl")'

# Run specific test
julia --project=/home/D01856/fast-simulator/CachedCrownSim -e 'include("test/runtests.jl")'

# Run benchmarks
julia --project=/home/D01856/fast-simulator/CachedCrownSim -e 'include("test/benchmark.jl")'

# Build documentation
julia --project=/home/D01856/fast-simulator/CachedCrownSim -e 'using Pkg; Pkg.build()'
```

## Environment

- Julia 1.12+
- ConcurrentSim.jl 1.5.1+
- CSV.jl 0.10.16+
- DataFrames.jl 1.8.2+
- Interpolations.jl 0.16.2+
- JSON3.jl 1.14.3+
- ResumableFunctions.jl 1.0.6+
- TimeZones.jl 1.22.2+

## Notes

- This is a Julia reimplementation of a Python EV charging simulator
- Use ConcurrentSim.jl for discrete event simulation
- Focus on massive fleet performance (100k+ agents)
- Use vectorized batch updates for SoC tracking
- The ConvexSolver will be provided later by user
