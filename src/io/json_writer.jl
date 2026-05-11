using JSON3

# Stream helper that writes a JSON array incrementally using JSON3 directly or via a buffered string builder.
# For high-throughput logging, writing row-by-row to an open IO buffer is better than materializing full array.

struct JsonListWriter
    io::IOStream
    first_value::Ref{Bool}

    function JsonListWriter(filename::String)
        io = open(filename, "w")
        write(io, "[\n")
        new(io, Ref(true))
    end
end

function write(writer::JsonListWriter, value)
    if !writer.first_value[]
        write(writer.io, ",\n")
    else
        writer.first_value[] = false
    end
    JSON3.write(writer.io, value)
end

function close(writer::JsonListWriter)
    write(writer.io, "\n]\n")
    close(writer.io)
end
