"""
    PluginInterface

Abstract type for all simulation plugins. Plugins can hook into the simulation lifecycle
to provide custom behavior for mobility, optimization, data sources, or post-processing.

# Lifecycle Methods
- `setup!(plugin, simulation)` — Called when the simulation starts.
- `step!(plugin, simulation, timestep)` — Called at each simulation timestep.
- `teardown!(plugin, simulation)` — Called when the simulation ends.
"""
abstract type PluginInterface end

"""
    MobilityPlugin <: PluginInterface

Plugin interface for mobility scenarios. Handles vehicle plug-in/plug-out events.

# Fields
- `name::String` — Plugin name.
"""
mutable struct MobilityPlugin <: PluginInterface
    name::String
end

"""
    OptimizationPlugin <: PluginInterface

Plugin interface for optimization algorithms. Provides the optimization solver interface.

# Fields
- `name::String` — Plugin name.
"""
mutable struct OptimizationPlugin <: PluginInterface
    name::String
end

"""
    SpotPlugin <: PluginInterface

Plugin interface for spot market pricing. Provides day-ahead and real-time pricing.

# Fields
- `name::String` — Plugin name.
"""
mutable struct SpotPlugin <: PluginInterface
    name::String
end

"""
    NetworkPlugin <: PluginInterface

Plugin interface for network state and frequency control.

# Fields
- `name::String` — Plugin name.
"""
mutable struct NetworkPlugin <: PluginInterface
    name::String
end

"""
    setup!(plugin::PluginInterface, simulation) -> Nothing

Called when the simulation starts. Initialize the plugin.
"""
function setup!(plugin::PluginInterface, simulation)
    # Default implementation: no-op
end

"""
    step!(plugin::PluginInterface, simulation, timestep::Float64) -> Nothing

Called at each simulation timestep. Update the plugin state.
"""
function step!(plugin::PluginInterface, simulation, timestep::Float64)
    # Default implementation: no-op
end

"""
    teardown!(plugin::PluginInterface, simulation) -> Nothing

Called when the simulation ends. Clean up the plugin.
"""
function teardown!(plugin::PluginInterface, simulation)
    # Default implementation: no-op
end

"""
    PluginManager

Manages a collection of plugins. Provides lifecycle management for all plugins.

# Fields
- `plugins::Vector{PluginInterface}` — List of registered plugins.
"""
mutable struct PluginManager
    plugins::Vector{PluginInterface}
end

"""
    PluginManager() -> PluginManager

Construct an empty PluginManager.
"""
function PluginManager()
    PluginManager(PluginInterface[])
end

"""
    register_plugin!(manager::PluginManager, plugin::PluginInterface) -> Nothing

Register a plugin with the manager.
"""
function register_plugin!(manager::PluginManager, plugin::PluginInterface)
    push!(manager.plugins, plugin)
end

"""
    setup_all!(manager::PluginManager, simulation) -> Nothing

Set up all registered plugins.
"""
function setup_all!(manager::PluginManager, simulation)
    for plugin in manager.plugins
        setup!(plugin, simulation)
    end
end

"""
    step_all!(manager::PluginManager, simulation, timestep::Float64) -> Nothing

Step all registered plugins for the current timestep.
"""
function step_all!(manager::PluginManager, simulation, timestep::Float64)
    for plugin in manager.plugins
        step!(plugin, simulation, timestep)
    end
end

"""
    teardown_all!(manager::PluginManager, simulation) -> Nothing

Tear down all registered plugins.
"""
function teardown_all!(manager::PluginManager, simulation)
    for plugin in manager.plugins
        teardown!(plugin, simulation)
    end
end
