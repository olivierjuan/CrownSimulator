using JSON3

# Stream helper that writes a JSON array incrementally using JSON3 directly or via a buffered string builder.
# For high-throughput logging, writing row-by-row to an open IO buffer is better than materializing full array.

"""
    JsonListWriter

Incremental JSON array writer that streams values to a file. Each call to `write`
appends a comma-separated JSON value, and `close` finalizes the array.

# Fields
- `io::IOStream` — Output stream for writing.
- `first_value::Ref{Bool}` — Tracks whether the first value has been written (for comma handling).
"""
struct JsonListWriter
    io::IOStream
    first_value::Ref{Bool}

    """
        JsonListWriter(filename::String) -> JsonListWriter

    Construct a `JsonListWriter` that writes to the given file, initializing with `[`.

    # Arguments
    - `filename::String` — Path to the output file.
    """
    function JsonListWriter(filename::String)
        io = open(filename, "w")
        write(io, "[\n")
        new(io, Ref(true))
    end
end

"""
    write(writer::JsonListWriter, value) -> Nothing

Write a JSON-serializable value to the writer, adding a comma if needed.

# Arguments
- `writer::JsonListWriter` — The writer to write to.
- `value` — The value to serialize and write.
"""
function write(writer::JsonListWriter, value)
    if !writer.first_value[]
        write(writer.io, ",\n")
    else
        writer.first_value[] = false
    end
    JSON3.write(writer.io, value)
end

"""
    close(writer::JsonListWriter) -> Nothing

Close the writer, finalizing the JSON array with `]`.

# Arguments
- `writer::JsonListWriter` — The writer to close.
"""
function close(writer::JsonListWriter)
    write(writer.io, "\n]\n")
    close(writer.io)
end
