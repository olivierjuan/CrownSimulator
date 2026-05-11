using Dates
using TimeZones

"""
    AbstractDatapointsWriter

Abstract supertype for all datapoints writers.
"""
abstract type AbstractDatapointsWriter end

"""
    SingleFileDatapointsWriter{T}

A single-file writer for simulation datapoints, writing to a JSON array file.
Supports warmup period filtering (skips datapoints before warmup_end and after end_time).

# Fields
- `filename_pattern::String` — Pattern for output filenames (may contain `{key}` placeholders).
- `warmup_end::DateTime` — End of the warmup period (datapoints before this time are skipped).
- `end_time::DateTime` — End of the simulation (datapoints after this time are skipped).
- `writer::Union{JsonListWriter,Nothing}` — The underlying JSON writer (created lazily on first write).
"""
struct SingleFileDatapointsWriter{T} <: AbstractDatapointsWriter
    filename_pattern::String
    warmup_end::DateTime
    end_time::DateTime
    writer::Union{JsonListWriter,Nothing}
    # Additional constructor to dynamically create at first write based on timestamps
end

"""
    write_datapoint!(writer::SingleFileDatapointsWriter, timestamp::DateTime, datapoint::Dict) -> Nothing

Write a datapoint to the writer, filtering out datapoints outside the warmup/simulation time range.

# Arguments
- `writer::SingleFileDatapointsWriter` — The writer to write to.
- `timestamp::DateTime` — The timestamp of the datapoint.
- `datapoint::Dict` — The datapoint dictionary to write.

# Notes
- Datapoints before `warmup_end` or after `end_time` are silently ignored.
- The underlying JSON writer is lazily created on first write.
"""
function write_datapoint!(writer::SingleFileDatapointsWriter, timestamp::DateTime, datapoint::Dict)
    if timestamp < writer.warmup_end || timestamp >= writer.end_time
        return
    end
    if writer.writer === nothing
        filename = replace(writer.filename_pattern, r"\{(?<key>\w+)\}" => "{:?PLACEHOLDER}")
        writer = JsonListWriter(filename)
    end
    write(writer, datapoint)
end

"""
    close_writer!(writer::SingleFileDatapointsWriter) -> Nothing

Close the datapoints writer, finalizing the JSON array.

# Arguments
- `writer::SingleFileDatapointsWriter` — The writer to close.
"""
function close_writer!(writer::SingleFileDatapointsWriter)
    if writer.writer !== nothing
        close(writer.writer)
    end
end

# TODO: daily writer split and filename_pattern formatting should follow later requirements.
