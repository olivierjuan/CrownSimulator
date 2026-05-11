mutable struct OptimizationRequestGenerator
    id::Int
    services::ServicesRequestParameters
end

function next_request_id!(gen::OptimizationRequestGenerator)::Int
    gen.id += 1
    gen.id
end

# TODO: complete request generation snapshot-to-request logic once solver DTO shape is defined.
