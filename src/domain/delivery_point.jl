Base.@kwdef struct OtherConsumption
    circuit_id::String
    from::DateTime
    to::DateTime
    phases::String
    installed_on_phase::String
    power::Power_W
end

function to_dto(oc::OtherConsumption)
    Dict{String,Any}(
        "phases" => oc.phases,
        "installedOnPhase" => oc.installed_on_phase,
        "schedule" => [
            Dict{String,Any}(
                "period" => Dict("from" => oc.from, "to" => oc.to),
                "power" => Int(round(oc.power)),
            ),
        ],
    )
end

Base.@kwdef struct OtherProduction
    circuit_id::String
    from::DateTime
    to::DateTime
    phases::String
    installed_on_phase::String
    power::Power_W
end

function to_dto(op::OtherProduction)
    Dict{String,Any}(
        "phases" => op.phases,
        "installedOnPhase" => op.installed_on_phase,
        "schedule" => [
            Dict{String,Any}(
                "period" => Dict("from" => op.from, "to" => op.to),
                "power" => Int(round(op.power)),
            ),
        ],
    )
end

Base.@kwdef struct CircuitEvse
    evse_id::String
    phases::String
    installed_on_phase::String
    priority::Int = 0
end

function load(::Type{CircuitEvse}, dto::AbstractDict)
    CircuitEvse(
        evse_id=dto["evseId"],
        phases=dto["phases"],
        installed_on_phase=dto["installedOnPhase"],
        priority=get(dto, "priority", 0),
    )
end

function to_dto(evse::CircuitEvse)
    Dict{String,Any}(
        "evseId" => evse.evse_id,
        "phases" => evse.phases,
        "installedOnPhase" => evse.installed_on_phase,
        "priority" => evse.priority,
    )
end

Base.@kwdef struct CircuitPowerLimits
    max_charge_power::Union{Power_kW,Nothing}
    max_discharge_power::Union{Power_kW,Nothing}
end

function load(::Type{CircuitPowerLimits}, dto::AbstractDict)
    max_charge_power = haskey(dto, "maxChargePower") ? dto["maxChargePower"] / 1000.0 : nothing
    max_discharge_power = haskey(dto, "maxDischargePower") ? dto["maxDischargePower"] / 1000.0 : nothing
    CircuitPowerLimits(max_charge_power=max_charge_power, max_discharge_power=max_discharge_power)
end

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

Base.@kwdef struct DeliveryPoint
    id_::String
    phases::String
    power_limits::CircuitPowerLimits
    circuits::Vector{DeliveryPointCircuit}
    other_consumptions::Vector{OtherConsumption}
    other_productions::Vector{OtherProduction}
    subscribed_power::Union{CircuitPowerLimits,Nothing} = nothing
end

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
