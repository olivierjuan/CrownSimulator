using Test
using Dates

@testset "FcrSummary - defaults" begin
    fs = FcrSummary(capacity_up=10.0, capacity_down=8.0)
    @test fs.margin_up == 0.0
    @test fs.margin_down == 0.0
    @test fs.activated == 0.0
end

@testset "FcrSummary - capacity" begin
    fs = FcrSummary(capacity_up=10.0, capacity_down=8.0)
    @test capacity(fs) == 8.0
    fs2 = FcrSummary(capacity_up=5.0, capacity_down=12.0)
    @test capacity(fs2) == 5.0
end

@testset "FcrSummary - margin" begin
    fs = FcrSummary(capacity_up=10.0, capacity_down=8.0, margin_up=3.0, margin_down=2.0)
    @test margin(fs) == 2.0
    fs2 = FcrSummary(capacity_up=10.0, capacity_down=8.0, margin_up=1.0, margin_down=5.0)
    @test margin(fs2) == 1.0
end

@testset "Transaction - defaults" begin
    tx = Transaction(id="tx_1", managed=true, baseline=5.0)
    @test tx.power == 0.0
    @test tx.ev_id === nothing
    @test tx.transaction_fcr_summary === nothing
    @test tx.constant_loss === nothing
end

@testset "Transaction - with FCR summary" begin
    fs = FcrSummary(capacity_up=10.0, capacity_down=8.0, activated=2.0)
    tx = Transaction(id="tx_1", managed=true, baseline=5.0, power=7.0, ev_id="v1", transaction_fcr_summary=fs)
    @test tx.power == 7.0
    @test tx.ev_id == "v1"
    @test tx.transaction_fcr_summary.activated == 2.0
end

@testset "OptimizationRequestGenerator - next_request_id!" begin
    gen = OptimizationRequestGenerator(0, ServicesRequestParameters(
        charging_requirements=ChargingRequirementsServiceParameters(
            weight=0.5,
            soc_penalties=SocPenalties(encouraged_min_soc_gap=5, encouraged_max_soc_gap=20, max_soc_gap=50),
            instant_charge_penalties=InstantChargePenalties(max_soc_gap=10),
        ),
        tariff=TariffServiceParameters(weight=1.0, discount=0.9, default_price=100.0),
        fcr=Dict{String,FcrServiceParameters}(),
        baseline_stability=BaselineStabilityServiceParameters(weight=0.2),
        co2=Co2ServiceParameters(weight=0.1),
        day_ahead=DayAheadServiceParameters(weight=0.4, discount=0.85),
    ))
    @test next_request_id!(gen) == 1
    @test next_request_id!(gen) == 2
    @test next_request_id!(gen) == 3
end
