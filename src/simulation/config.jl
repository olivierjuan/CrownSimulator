using Base: @kwdef

"""
    DatapointsOutputConfig

Configuration for datapoints output formatting and file naming.

# Fields
- `writer::String` — Type of writer to use (e.g., `"single"` for single file output).
- `filename_pattern::String` — Pattern for output filenames.
- `split_time::Union{String,Nothing}` — Optional time-based split interval for output files.
"""
@kwdef struct DatapointsOutputConfig
    writer::String
    filename_pattern::String
    split_time::Union{String,Nothing} = nothing
end

"""
    OutputConfig

Container for all output configuration settings.

# Fields
- `datapoints::DatapointsOutputConfig` — Datapoints output configuration.
"""
@kwdef struct OutputConfig
    datapoints::DatapointsOutputConfig
end

"""
    SimulationConfig

Configuration for a simulation run, including timing, algorithm, and output settings.

# Fields
- `start::String` — Start time of the simulation (ISO 8601 format).
- `duration::String` — Duration of the simulation (e.g., `"1h"`, `"30m"`).
- `algorithm::String` — Name of the optimization algorithm to use.
- `scenario::String` — Name of the scenario to simulate.
- `output::OutputConfig` — Output configuration settings (default: single-file JSON output).
"""
@kwdef struct SimulationConfig
    start::String
    duration::String
    algorithm::String
    scenario::String
    output::OutputConfig = OutputConfig(
        datapoints=DatapointsOutputConfig(writer="single", filename_pattern="datapoints.json")
    )
end

"""
    validate_config(config::SimulationConfig) -> Nothing

Validate a SimulationConfig, raising an error if any field is invalid.

# Errors
- `start` is not a valid ISO 8601 datetime string.
- `duration` is not a valid ISO 8601 duration string.
- `algorithm` or `scenario` are empty strings.
"""
function validate_config(config::SimulationConfig)
    # Validate start is a valid datetime
    try
        DateTime(config.start)
    catch e
        error("Invalid start time: '$(config.start)'. Must be a valid ISO 8601 datetime string.")
    end

    # Validate duration is non-empty
    if isempty(config.duration)
        error("Duration cannot be empty.")
    end

    # Validate algorithm is non-empty
    if isempty(config.algorithm)
        error("Algorithm cannot be empty.")
    end

    # Validate scenario is non-empty
    if isempty(config.scenario)
        error("Scenario cannot be empty.")
    end

    nothing
end

"""
    merge_defaults(config::Dict{String,Any}) -> SimulationConfig

Create a SimulationConfig from a partial dictionary, merging with defaults.
Missing keys will use default values.

# Arguments
- `config::Dict{String,Any}` — Partial configuration dictionary with keys like `"start"`, `"duration"`, `"algorithm"`, `"scenario"`, `"output"`.

# Returns
- A fully populated `SimulationConfig`.
"""
function merge_defaults(config::Dict{String,Any})
    defaults = Dict{String,Any}(
        "start" => string(now()),
        "duration" => "PT1H",
        "algorithm" => "default",
        "scenario" => "default",
    )

    merged = Dict{String,Any}()
    for (k, v) in defaults
        merged[k] = haskey(config, k) ? config[k] : v
    end

    # Handle output config
    output_cfg = if haskey(config, "output")
        config["output"]
    else
        Dict{String,Any}(
            "datapoints" => Dict{String,Any}(
                "writer" => "single",
                "filename_pattern" => "datapoints.json",
            )
        )
    end

    output = OutputConfig(
        datapoints=DatapointsOutputConfig(
            writer=get(output_cfg["datapoints"], "writer", "single"),
            filename_pattern=get(output_cfg["datapoints"], "filename_pattern", "datapoints.json"),
            split_time=get(output_cfg["datapoints"], "split_time", nothing),
        )
    )

    SimulationConfig(
        start=merged["start"],
        duration=merged["duration"],
        algorithm=merged["algorithm"],
        scenario=merged["scenario"],
        output=output,
    )
end
