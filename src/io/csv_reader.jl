using CSV: CSV
using Dates

function read_and_parse(filename::String, parse_fn::Function)
    file = CSV.File(filename; normalizenames=true)
    [parse_fn(row) for row in file]
end
