using Interpolations

"""
    DroopControlData

Input data for droop control computation.

# Fields
- `frequency::Frequency_Hz` — Current grid frequency in Hz.
- `announced_capacity::Vector{CapacityRequirement}` — Announced capacity requirements.
- `transactions::Vector{Transaction}` — Transactions to process.
"""
Base.@kwdef struct DroopControlData
    frequency::Frequency_Hz
    announced_capacity::Vector{CapacityRequirement}
    transactions::Vector{Transaction}
end

"""
    DroopControlResponseSummary

Summary of droop control response totals.

# Fields
- `total_power::Power_kW` — Total power in kW.
- `total_baseline::Power_kW` — Total baseline power in kW.
- `total_activated::Power_kW` — Total activated power in kW.
- `total_capacity_up::Power_kW` — Total capacity up in kW.
- `total_capacity_down::Power_kW` — Total capacity down in kW.
- `total_discharge::Power_kW` — Total discharge in kW.
"""
Base.@kwdef struct DroopControlResponseSummary
    total_power::Power_kW = 0.0
    total_baseline::Power_kW = 0.0
    total_activated::Power_kW = 0.0
    total_capacity_up::Power_kW = 0.0
    total_capacity_down::Power_kW = 0.0
    total_discharge::Power_kW = 0.0
end

"""
    to_dto(summary::DroopControlResponseSummary) -> Dict{String,Any}

Convert a `DroopControlResponseSummary` to a DTO dictionary for serialization.
"""
function to_dto(summary::DroopControlResponseSummary)
    Dict{String,Any}(
        "total_power" => summary.total_power,
        "total_baseline" => summary.total_baseline,
        "total_activated" => summary.total_activated,
        "total_capacity_up" => summary.total_capacity_up,
        "total_capacity_down" => summary.total_capacity_down,
        "total_discharge" => summary.total_discharge,
    )
end

"""
    DroopControlResponse

Response from droop control computation.

# Fields
- `transactions::Vector{Transaction}` — Updated transactions.
- `summary::DroopControlResponseSummary` — Summary of the response.
"""
Base.@kwdef struct DroopControlResponse
    transactions::Vector{Transaction}
    summary::DroopControlResponseSummary
end

"""
    to_dto(resp::DroopControlResponse) -> Dict{String,Any}

Convert a `DroopControlResponse` to a DTO dictionary for serialization.
"""
function to_dto(resp::DroopControlResponse)
    Dict{String,Any}(
        "transactions" => [to_dto(tx) for tx in resp.transactions],
        "summary" => to_dto(resp.summary),
    )
end

"""
    DroopController

Droop controller for frequency containment reserve (FCR) control.

# Fields
- `interp::Interpolations.GriddedInterpolation` — Interpolation function for frequency-to-coefficient mapping.
"""
struct DroopController
    interp::Interpolations.GriddedInterpolation
end

"""
    DroopController() -> DroopController

Construct a default droop controller with standard frequency response parameters.
"""
function DroopController()
    mean_f = 50.0
    delta_fmax = 0.200
    delta_f0 = 0.00
    xs = [0.0, mean_f - delta_fmax, mean_f + delta_fmax, 100.0]
    ys = [-1.0, -1.0, 1.0, 1.0]
    interp = interpolate((xs,), ys, Gridded(Linear()))
    DroopController(interp)
end

"""
    control(controller::DroopController, data::DroopControlData) -> DroopControlResponse

Compute the droop control response for the given frequency and transactions.
Uses pre-allocated vectors for performance.

# Arguments
- `controller::DroopController` — The droop controller.
- `data::DroopControlData` — Input data with frequency and transactions.

# Returns
- A `DroopControlResponse` with updated transactions and summary.
"""
function control(controller::DroopController, data::DroopControlData)::DroopControlResponse
    coeff = controller.interp(data.frequency)
    coeff_plus = max(coeff, 0.0)
    coeff_minus = min(coeff, 0.0)
    total_power = 0.0
    total_baseline = 0.0
    total_activated = 0.0
    total_capacity_up = 0.0
    total_capacity_down = 0.0
    total_discharge = 0.0
    # Pre-allocate output vector
    out_transactions = Vector{Transaction}(undef, length(data.transactions))
    idx = 0
    for tx in data.transactions
        if tx.managed
            fcr_down = tx.transaction_fcr_summary.capacity_down
            fcr_up = tx.transaction_fcr_summary.capacity_up
            activated = (fcr_up * coeff_minus) + (fcr_down * coeff_plus)
            power = tx.baseline + activated
            new_summary = FcrSummary(
                capacity_up=tx.transaction_fcr_summary.capacity_up,
                capacity_down=tx.transaction_fcr_summary.capacity_down,
                activated=activated,
            )
            new_tx = Transaction(
                id=tx.id,
                managed=tx.managed,
                baseline=tx.baseline,
                power=power,
                ev_id=tx.ev_id,
                transaction_fcr_summary=new_summary,
                constant_loss=tx.constant_loss,
            )
            total_baseline += new_tx.baseline
            total_power += new_tx.power
            total_capacity_up += new_summary.capacity_up
            total_capacity_down += new_summary.capacity_down
            total_activated += new_summary.activated
            if new_tx.power < 0.0
                total_discharge += -new_tx.power
            end
            idx += 1
            out_transactions[idx] = new_tx
        else
            new_tx = Transaction(
                id=tx.id,
                managed=tx.managed,
                baseline=tx.constant_loss,
                power=tx.constant_loss,
                ev_id=tx.ev_id,
                transaction_fcr_summary=FcrSummary(capacity_up=0.0, capacity_down=0.0, activated=0.0),
                constant_loss=tx.constant_loss,
            )
            total_baseline += new_tx.baseline
            total_power += new_tx.power
            idx += 1
            out_transactions[idx] = new_tx
        end
    end
    # Trim vector to actual length
    resize!(out_transactions, idx)
    DroopControlResponse(
        transactions=out_transactions,
        summary=DroopControlResponseSummary(
            total_power=total_power,
            total_baseline=total_baseline,
            total_activated=total_activated,
            total_capacity_up=total_capacity_up,
            total_capacity_down=total_capacity_down,
            total_discharge=total_discharge,
        )
    )
end
