using Dates
using TimeZones

abstract type AbstractDatapointsWriter end

struct SingleFileDatapointsWriter{T} <: AbstractDatapointsWriter
    filename_pattern::String
    warmup_end::DateTime
    end_time::DateTime
    writer::Union{JsonListWriter,Nothing}
    # Additional constructor to dynamically create at first write based on timestamps
end

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

function close_writer!(writer::SingleFileDatapointsWriter)
    if writer.writer !== nothing
        close(writer.writer)
    end
end

# TODO: daily writer split and filename_pattern formatting should follow later requirements.
