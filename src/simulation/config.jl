using Base: @kwdef

@kwdef struct DatapointsOutputConfig
    writer::String
    filename_pattern::String
    split_time::Union{String,Nothing} = nothing
end

@kwdef struct OutputConfig
    datapoints::DatapointsOutputConfig
end

@kwdef struct SimulationConfig
    start::String
    duration::String
    algorithm::String
    scenario::String
    output::OutputConfig = OutputConfig(
        datapoints=DatapointsOutputConfig(writer="single", filename_pattern="datapoints.json")
    )
end
