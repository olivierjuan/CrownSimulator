using CSV: CSV
using Dates

"""
    read_and_parse(filename::String, parse_fn::Function) -> Vector

Read a CSV file and parse each row using the provided parse function.

# Arguments
- `filename::String` — Path to the CSV file.
- `parse_fn::Function` — Function to parse each row (takes a CSV row and returns a parsed value).

# Returns
- A vector of parsed values, one per row.

# Examples
```julia
data = read_and_parse("prices.csv", row -> TimestampedPrice(row.time, row.price))
```
"""
function read_and_parse(filename::String, parse_fn::Function)
    file = CSV.File(filename; normalizenames=true)
    [parse_fn(row) for row in file]
end
