# Placeholder optimizer interface that will wrap the user-provided solver.

abstract type AbstractOptimizer end

struct ExternalOptimizer <: AbstractOptimizer
    solve_fn::Function
end

# Later: dispatch solve(opt::ExternalOptimizer, request) -> OptimizationResult
