"""
    OptimizationRequestGenerator

Generator for optimization requests, tracking request IDs and service parameters.

# Fields
- `id::Int` — Current request ID counter.
- `services::ServicesRequestParameters` — Service parameters for the optimization.
"""
mutable struct OptimizationRequestGenerator
    id::Int
    services::ServicesRequestParameters
end

"""
    next_request_id!(gen::OptimizationRequestGenerator) -> Int

Increment and return the next request ID.

# Arguments
- `gen::OptimizationRequestGenerator` — The request generator to update.

# Returns
- The new request ID.
"""
function next_request_id!(gen::OptimizationRequestGenerator)::Int
    gen.id += 1
    gen.id
end

# NOTE: request generation snapshot-to-request logic is pending solver DTO definition.
