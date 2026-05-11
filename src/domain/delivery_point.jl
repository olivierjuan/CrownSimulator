"""
    OtherLoad

Common abstract type for non-EVSE loads on a delivery point circuit
(consumption or production). Both `OtherConsumption` and `OtherProduction`
share identical fields and serialization logic.
"""
abstract type OtherLoad end

"""
    OtherConsumption

Represents a non-EV electrical load on a delivery point circuit, such as lighting or HVAC.

# Fields
- `circuit_id::String` — Identifier of the circuit where this load is installed.
- `from::DateTime` — Start time of the consumption schedule.
- `to::DateTime` — End time of the consumption schedule.
- `phases::String` — Phases on which the load is installed.
- `installed_on_phase::String` — Specific phase where the load is connected.
- `power::Power_W` — Power consumption in watts.
"""
Base.@kwdef struct OtherConsumption <: OtherLoad
    circuit_id::String
    from::DateTime
    to::DateTime
    phases::String
    installed_on_phase::String
    power::Power_W
end

"""
    OtherProduction

Represents electrical production on a delivery point circuit, such as solar PV or battery.

# Fields
- `circuit_id::String` — Identifier of the circuit where this production is installed.
- `from::DateTime` — Start time of the production schedule.
- `to::DateTime` — End time of the production schedule.
- `phases::String` — Phases on which the production is installed.
- `installed_on_phase::String` — Specific phase where the production is connected.
- `power::Power_W` — Power production in watts.
"""
Base.@kwdef struct OtherProduction <: OtherLoad
    circuit_id::String
    from::DateTime
    to::DateTime
    phases::String
    installed_on_phase::String
    power::Power_W
end

"""
    to_dto(ol::OtherLoad) -> Dict{String,Any}

Convert an `OtherLoad` (consumption or production) to a DTO dictionary for serialization.
"""
function to_dto(ol::OtherLoad)
    Dict{String,Any}(
        "phases" => ol.phases,
        "installedOnPhase" => ol.installed_on_phase,
        "schedule" => [
            Dict{String,Any}(
                "period" => Dict("from" => ol.from, "to" => ol.to),
                "power" => Int(round(ol.power)),
            ),
        ],
    )
end

"""
    CircuitEvse

Represents an EVSE (Electric Vehicle Supply Equipment) connected to a delivery point circuit.

# Fields
- `evse_id::String` — Unique identifier of the EVSE.
- `phases::String` — Phases on which the EVSE is installed.
- `installed_on_phase::String` — Specific phase where the EVSE is connected.
- `priority::Int` — Priority of the EVSE for load balancing (default: 0).
"""
Base.@kwdef struct CircuitEvse
    evse_id::String
    phases::String
    installed_on_phase::String
    priority::Int = 0
end

"""
    load(::Type{CircuitEvse}, dto::AbstractDict) -> CircuitEvse

Construct a `CircuitEvse` from a DTO dictionary.

# Arguments
- `dto::AbstractDict` — Dictionary with keys `"evseId"`, `"phases"`, `"installedOnPhase"`, and optionally `"priority"`.
"""
function load(::Type{CircuitEvse}, dto::AbstractDict)
    CircuitEvse(
        evse_id=dto["evseId"],
        phases=dto["phases"],
        installed_on_phase=dto["installedOnPhase"],
        priority=get(dto, "priority", 0),
    )
end

"""
    to_dto(evse::CircuitEvse) -> Dict{String,Any}

Convert a `CircuitEvse` to a DTO dictionary for serialization.
"""
function to_dto(evse::CircuitEvse)
    Dict{String,Any}(
        "evseId" => evse.evse_id,
        "phases" => evse.phases,
        "installedOnPhase" => evse.installed_on_phase,
        "priority" => evse.priority,
    )
end

"""
    CircuitPowerLimits

Power limits for a delivery point circuit, defining maximum charge and discharge power.

# Fields
- `max_charge_power::Union{Power_kW,Nothing}` — Maximum charge power in kW (may be `nothing` if unspecified).
- `max_discharge_power::Union{Power_kW,Nothing}` — Maximum discharge power in kW (may be `nothing` if unspecified).
"""
Base.@kwdef struct CircuitPowerLimits
    max_charge_power::Union{Power_kW,Nothing}
    max_discharge_power::Union{Power_kW,Nothing}
end

"""
    load(::Type{CircuitPowerLimits}, dto::AbstractDict) -> CircuitPowerLimits

Construct a `CircuitPowerLimits` from a DTO dictionary. Power values are converted from watts to kilowatts.

# Arguments
- `dto::AbstractDict` — Dictionary with optional keys `"maxChargePower"` and `"maxDischargePower"` (in watts).
"""
function load(::Type{CircuitPowerLimits}, dto::AbstractDict)
    max_charge_power = haskey(dto, "maxChargePower") ? dto["maxChargePower"] / 1000.0 : nothing
    max_discharge_power = haskey(dto, "maxDischargePower") ? dto["maxDischargePower"] / 1000.0 : nothing
    CircuitPowerLimits(max_charge_power=max_charge_power, max_discharge_power=max_discharge_power)
end

"""
    to_dto(limits::CircuitPowerLimits) -> Dict{String,Any}

Convert a `CircuitPowerLimits` to a DTO dictionary for serialization. Power values are converted from kilowatts to watts.
"""
function to_dto(limits::CircuitPowerLimits)
    dto = Dict{String,Any}()
    if limits.max_charge_power !== nothing
        dto["maxChargePower"] = Int(round(limits.max_charge_power * 1000.0))
    end
    if limits.max_discharge_power !== nothing
        dto["maxDischargePower"] = Int(round(limits.max_discharge_power * 1000.0))
    end
    return dto
end

"""
    DeliveryPointCircuit

Represents a circuit within a delivery point, with sub-circuits, EVSEs, and power limits.

# Fields
- `id_::String` — Unique identifier of the circuit.
- `phases::String` — Phases on which the circuit is installed.
- `installed_on_phase::String` — Specific phase where the circuit is connected.
- `circuits::Vector{DeliveryPointCircuit}` — Sub-circuits nested within this circuit.
- `evses::Vector{CircuitEvse}` — EVSEs connected to this circuit.
- `other_consumptions::Vector{OtherConsumption}` — Non-EV loads on this circuit.
- `other_productions::Vector{OtherProduction}` — Power production sources on this circuit.
- `power_limits::Union{CircuitPowerLimits,Nothing}` — Optional power limits for this circuit.
"""
Base.@kwdef struct DeliveryPointCircuit
    id_::String
    phases::String
    installed_on_phase::String
    circuits::Vector{DeliveryPointCircuit}
    evses::Vector{CircuitEvse}
    other_consumptions::Vector{OtherConsumption}
    other_productions::Vector{OtherProduction}
    power_limits::Union{CircuitPowerLimits,Nothing} = nothing
end

"""
    load(::Type{DeliveryPointCircuit}, dto::AbstractDict) -> DeliveryPointCircuit

Construct a `DeliveryPointCircuit` from a DTO dictionary, including nested circuits and EVSEs.

# Arguments
- `dto::AbstractDict` — Dictionary with keys `"id"`, `"phases"`, `"installedOnPhase"`, and optionally `"circuits"`, `"evses"`, `"powerLimits"`.
"""
function load(::Type{DeliveryPointCircuit}, dto::AbstractDict)
    power_limits = if haskey(dto, "powerLimits") && !isempty(dto["powerLimits"])
        load(CircuitPowerLimits, dto["powerLimits"])
    else
        nothing
    end
    circuits = if haskey(dto, "circuits")
        [load(DeliveryPointCircuit, circuit) for circuit in dto["circuits"]]
    else
        DeliveryPointCircuit[]
    end
    evses = if haskey(dto, "evses")
        [load(CircuitEvse, evse) for evse in dto["evses"]]
    else
        CircuitEvse[]
    end
    DeliveryPointCircuit(
        id_=dto["id"],
        phases=dto["phases"],
        installed_on_phase=dto["installedOnPhase"],
        power_limits=power_limits,
        circuits=circuits,
        evses=evses,
        other_consumptions=OtherConsumption[],
        other_productions=OtherProduction[],
    )
end

"""
    to_dto(circuit::DeliveryPointCircuit) -> Dict{String,Any}

Convert a `DeliveryPointCircuit` to a DTO dictionary for serialization, including nested circuits and EVSEs.
"""
function to_dto(circuit::DeliveryPointCircuit)
    Dict{String,Any}(
        "id" => circuit.id_,
        "phases" => circuit.phases,
        "installedOnPhase" => circuit.installed_on_phase,
        "powerLimits" => circuit.power_limits !== nothing ? to_dto(circuit.power_limits) : Dict{String,Any}(),
        "circuits" => [to_dto(c) for c in circuit.circuits],
        "evses" => [to_dto(e) for e in circuit.evses],
        "otherConsumptions" => [to_dto(oc) for oc in circuit.other_consumptions],
        "otherProductions" => [to_dto(op) for op in circuit.other_productions],
    )
end

"""
    DeliveryPoint

Represents a physical delivery point (e.g., a site) with circuits, EVSEs, and power limits.

# Fields
- `id_::String` — Unique identifier of the delivery point.
- `phases::String` — Phases on which the delivery point is installed.
- `power_limits::CircuitPowerLimits` — Power limits for this delivery point.
- `circuits::Vector{DeliveryPointCircuit}` — Circuits within this delivery point.
- `other_consumptions::Vector{OtherConsumption}` — Non-EV loads on this delivery point.
- `other_productions::Vector{OtherProduction}` — Power production sources on this delivery point.
- `subscribed_power::Union{CircuitPowerLimits,Nothing}` — Optional subscribed power limits.
"""
Base.@kwdef struct DeliveryPoint
    id_::String
    phases::String
    power_limits::CircuitPowerLimits
    circuits::Vector{DeliveryPointCircuit}
    other_consumptions::Vector{OtherConsumption}
    other_productions::Vector{OtherProduction}
    subscribed_power::Union{CircuitPowerLimits,Nothing} = nothing
end

"""
    load(::Type{DeliveryPoint}, dto::AbstractDict) -> DeliveryPoint

Construct a `DeliveryPoint` from a DTO dictionary, including nested circuits and power limits.

# Arguments
- `dto::AbstractDict` — Dictionary with keys `"id"`, `"phases"`, `"powerLimits"`, `"circuits"`, and optionally `"subscribedPower"`.
"""
function load(::Type{DeliveryPoint}, dto::AbstractDict)
    subscribed_power = haskey(dto, "subscribedPower") ? load(CircuitPowerLimits, dto["subscribedPower"]) : nothing
    DeliveryPoint(
        id_=dto["id"],
        phases=dto["phases"],
        power_limits=load(CircuitPowerLimits, dto["powerLimits"]),
        subscribed_power=subscribed_power,
        circuits=[load(DeliveryPointCircuit, c) for c in dto["circuits"]],
        other_consumptions=OtherConsumption[],
        other_productions=OtherProduction[],
    )
end

"""
    to_dto(dp::DeliveryPoint) -> Dict{String,Any}

Convert a `DeliveryPoint` to a DTO dictionary for serialization, including circuits and power limits.
"""
function to_dto(dp::DeliveryPoint)
    dto = Dict{String,Any}(
        "id" => dp.id_,
        "phases" => dp.phases,
        "powerLimits" => to_dto(dp.power_limits),
        "circuits" => [to_dto(c) for c in dp.circuits],
        "otherConsumptions" => [to_dto(oc) for oc in dp.other_consumptions],
        "otherProductions" => [to_dto(op) for op in dp.other_productions],
    )
    if dp.subscribed_power !== nothing
        dto["subscribedPower"] = to_dto(dp.subscribed_power)
    end
    return dto
end
