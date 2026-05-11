using Interpolations

Base.@kwdef struct DroopControlData
    frequency::Frequency_Hz
    announced_capacity::Vector{CapacityRequirement}
    transactions::Vector{Transaction}
end

Base.@kwdef struct DroopControlResponseSummary
    total_power::Power_kW = 0.0
    total_baseline::Power_kW = 0.0
    total_activated::Power_kW = 0.0
    total_capacity_up::Power_kW = 0.0
    total_capacity_down::Power_kW = 0.0
    total_discharge::Power_kW = 0.0
end

Base.@kwdef struct DroopControlResponse
    transactions::Vector{Transaction}
    summary::DroopControlResponseSummary
end

struct DroopController
    interp::Interpolations.GriddedInterpolation
end

function DroopController()
    mean_f = 50.0
    delta_fmax = 0.200
    delta_f0 = 0.00
    xs = [0.0, mean_f - delta_fmax, mean_f - delta_f0, mean_f + delta_f0, mean_f + delta_fmax, Inf]
    ys = [-1.0, -1.0, 0.0, 0.0, 1.0, 1.0]
    interp = interpolate(xs, ys, GriddedLinear(BC()))
    DroopController(interp)
end

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
    out_transactions = Transaction[]
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
            push!(out_transactions, new_tx)
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
            push!(out_transactions, new_tx)
        end
    end
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
