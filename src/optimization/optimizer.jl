# Placeholder optimizer interface that will wrap the user-provided solver.

"""
    AbstractOptimizer

Abstract supertype for all optimizer implementations.
Defines the interface for optimization solvers.
"""
abstract type AbstractOptimizer end

"""
    ExternalOptimizer

Optimizer that wraps a user-provided solve function.

# Fields
- `solve_fn::Function` — The user-provided solve function.
"""
struct ExternalOptimizer <: AbstractOptimizer
    solve_fn::Function
end

# Later: dispatch solve(opt::ExternalOptimizer, request) -> OptimizationResult
