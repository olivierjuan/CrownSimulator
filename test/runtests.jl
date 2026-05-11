using Test
using Dates
using Interpolations

using CachedCrownSim

# =============================================================================
# TimeRange tests
# =============================================================================

@testset "TimeRange intersection" begin
    p1 = TimeRange(DateTime(2021,1,1), DateTime(2021,1,2))
    p2 = TimeRange(DateTime(2021,1,1,12), DateTime(2021,1,3))
    inter = Base.intersect(p1, p2)
    @test inter.from == DateTime(2021,1,1,12)
    @test inter.to == DateTime(2021,1,2)
end

@testset "TimeRange intersection - no overlap" begin
    p1 = TimeRange(DateTime(2021,1,1), DateTime(2021,1,2))
    p2 = TimeRange(DateTime(2021,1,3), DateTime(2021,1,4))
    @test Base.intersect(p1, p2) === nothing
end

@testset "TimeRange intersection - touching edges" begin
    p1 = TimeRange(DateTime(2021,1,1), DateTime(2021,1,2))
    p2 = TimeRange(DateTime(2021,1,2), DateTime(2021,1,3))
    @test Base.intersect(p1, p2) === nothing
end

@testset "TimeRange intersection - identical" begin
    p1 = TimeRange(DateTime(2021,1,1), DateTime(2021,1,2))
    inter = Base.intersect(p1, p1)
    @test inter.from == DateTime(2021,1,1)
    @test inter.to == DateTime(2021,1,2)
end

@testset "TimeRange in - DateTime" begin
    tr = TimeRange(DateTime(2021,1,1), DateTime(2021,1,2))
    @test DateTime(2021,1,1) in tr
    @test DateTime(2021,1,1,12) in tr
    @test !(DateTime(2021,1,2) in tr)
    @test !(DateTime(2020,12,31) in tr)
end

@testset "TimeRange in - TimeRange" begin
    outer = TimeRange(DateTime(2021,1,1), DateTime(2021,1,3))
    inner = TimeRange(DateTime(2021,1,1,12), DateTime(2021,1,2))
    @test inner in outer
    @test !(outer in inner)
end

@testset "generate_timepoints" begin
    pts = generate_timepoints(DateTime(2022,1,1), DateTime(2022,1,1,3), Hour(1))
    @test length(pts) == 4
    @test pts[1] == DateTime(2022,1,1)
    @test pts[4] == DateTime(2022,1,1,3)
end

@testset "generate_timepoints - single point" begin
    pts = generate_timepoints(DateTime(2022,1,1), DateTime(2022,1,1), Hour(1))
    @test length(pts) == 1
    @test pts[1] == DateTime(2022,1,1)
end

@testset "generate_timepoints - minute interval" begin
    pts = generate_timepoints(DateTime(2022,1,1), DateTime(2022,1,1,0,5), Minute(1))
    @test length(pts) == 6
end

@testset "generate_periods" begin
    pts = [DateTime(2022,1,1), DateTime(2022,1,1,1), DateTime(2022,1,1,2)]
    periods = generate_periods(pts)
    @test length(periods) == 2
    @test periods[1].from == DateTime(2022,1,1)
    @test periods[1].to == DateTime(2022,1,1,1)
end

@testset "generate_periods - single timepoint" begin
    pts = [DateTime(2022,1,1)]
    periods = generate_periods(pts)
    @test length(periods) == 0
end

# =============================================================================
# Datapoint tests
# =============================================================================

@testset "Datapoint fields" begin
    dp = Datapoint(
        timestamp=DateTime(2022,1,1),
        start_=DateTime(2022,1,1),
        end_=DateTime(2022,1,2),
        delta_t=Hour(1),
        algorithm="test",
        warmup=false,
        version="1",
        minimize_logs=false
    )
    @test dp.algorithm == "test"
    @test dp.delta_t == Hour(1)
    @test dp.warmup == false
    @test dp.version == "1"
end

@testset "Datapoint - warmup flag" begin
    dp = Datapoint(
        timestamp=DateTime(2022,1,1),
        start_=DateTime(2022,1,1),
        end_=DateTime(2022,1,2),
        delta_t=Minute(15),
        algorithm="algo",
        warmup=true,
        version="2",
        minimize_logs=true
    )
    @test dp.warmup == true
    @test dp.minimize_logs == true
    @test dp.delta_t == Minute(15)
end

# =============================================================================
# OptimizationHorizon tests
# =============================================================================

@testset "OptimizationHorizon" begin
    oh = OptimizationHorizon(DateTime(2022,1,1), DateTime(2022,1,2), Hour(1))
    @test oh.start == DateTime(2022,1,1)
    @test oh.stop == DateTime(2022,1,2)
    @test oh.period_duration == Hour(1)
end

# =============================================================================
# PowerLosses & get_useful_power tests
# =============================================================================

@testset "Useful power" begin
    losses = PowerLosses(
        standby=0.5,
        variable=VariablePowerLosses(charging=0.05, discharging=0.05)
    )
    @test get_useful_power(losses, 10.0) ≈ 9.025
end

@testset "get_useful_power - negative power (discharging)" begin
    losses = PowerLosses(
        standby=0.5,
        variable=VariablePowerLosses(charging=0.05, discharging=0.05)
    )
    # negative power: (power - standby) / (1 - discharging_loss)
    result = get_useful_power(losses, -10.0)
    expected = (-10.0 - 0.5) / (1.0 - 0.05)
    @test result ≈ expected
end

@testset "get_useful_power - zero power" begin
    losses = PowerLosses(
        standby=0.5,
        variable=VariablePowerLosses(charging=0.05, discharging=0.05)
    )
    # power - standby = -0.5 which is not ≈ 0, so it goes to discharge path
    result = get_useful_power(losses, 0.0)
    expected = (0.0 - 0.5) / (1.0 - 0.05)
    @test result ≈ expected
end

@testset "get_useful_power - power equal to standby" begin
    losses = PowerLosses(
        standby=0.5,
        variable=VariablePowerLosses(charging=0.05, discharging=0.05)
    )
    result = get_useful_power(losses, 0.5)
    @test result ≈ 0.0
end

@testset "get_useful_power - zero losses" begin
    losses = PowerLosses(
        standby=0.0,
        variable=VariablePowerLosses(charging=0.0, discharging=0.0)
    )
    @test get_useful_power(losses, 10.0) ≈ 10.0
    @test get_useful_power(losses, -5.0) ≈ -5.0
end

# =============================================================================
# PowerLimits tests
# =============================================================================

@testset "PowerLimits - defaults" begin
    pl = PowerLimits(max_charge_power=22.0)
    @test pl.min_charge_power == 0.0
    @test pl.max_discharge_power == 0.0
    @test pl.efficiency_min_discharge_power == 0.0
    @test pl.efficiency_min_charge_power == 0.0
end

@testset "PowerLimits - cross_max_and_min_charge_power" begin
    se = PowerLimits(max_charge_power=22.0, min_charge_power=1.0)
    # EV can charge max 11kW, min 2kW
    crossed = cross_max_and_min_charge_power(se, 11.0, 2.0)
    @test crossed.max_charge_power == 11.0
    @test crossed.min_charge_power == 2.0
end

@testset "PowerLimits - cross_max_and_min_charge_power EV limits larger" begin
    se = PowerLimits(max_charge_power=22.0, min_charge_power=1.0)
    crossed = cross_max_and_min_charge_power(se, 50.0, 0.5)
    @test crossed.max_charge_power == 22.0
    @test crossed.min_charge_power == 1.0
end

@testset "PowerLimits - cross_max_and_min_charge_power EV limits smaller" begin
    se = PowerLimits(max_charge_power=22.0, min_charge_power=1.0)
    crossed = cross_max_and_min_charge_power(se, 5.0, 3.0)
    @test crossed.max_charge_power == 5.0
    @test crossed.min_charge_power == 3.0
end

@testset "PowerLimits - cross preserves discharge limits" begin
    se = PowerLimits(max_charge_power=22.0, max_discharge_power=10.0, min_charge_power=1.0)
    crossed = cross_max_and_min_charge_power(se, 11.0, 2.0)
    @test crossed.max_discharge_power == 10.0
    @test crossed.efficiency_min_discharge_power == 0.0
    @test crossed.efficiency_min_charge_power == 0.0
end

@testset "PowerLimits - zero power values" begin
    se = PowerLimits(max_charge_power=0.0, min_charge_power=0.0)
    crossed = cross_max_and_min_charge_power(se, 0.0, 0.0)
    @test crossed.max_charge_power == 0.0
    @test crossed.min_charge_power == 0.0
end

# =============================================================================
# SocPowerTableItem tests
# =============================================================================

@testset "SocPowerTableItem - to_dto" begin
    item = SocPowerTableItem(soc=50, power=22.0)
    dto = to_dto(item; capacity=60.0)
    @test dto["soc"] == Int(round((50 / 100.0) * (60.0 * 1000.0)))
    @test dto["maxChargePower"] == Int(round(22.0 * 1000.0))
end

@testset "SocPowerTableItem - from_config" begin
    cfg = Dict{String,Any}("soc" => 30, "power" => 11000)
    item = from_config(SocPowerTableItem, cfg)
    @test item.soc == 30
    @test item.power == 11.0
end

@testset "SocPowerTable - to_dto" begin
    table = SocPowerTable(
        items=[
            SocPowerTableItem(soc=20, power=7.0),
            SocPowerTableItem(soc=80, power=22.0),
        ]
    )
    dtos = to_dto(table; capacity=60.0)
    @test length(dtos) == 2
    @test dtos[1]["maxChargePower"] == Int(round(7.0 * 1000.0))
    @test dtos[2]["maxChargePower"] == Int(round(22.0 * 1000.0))
end

@testset "SocPowerTable - from_config" begin
    cfg = [
        Dict{String,Any}("soc" => 20, "power" => 7000),
        Dict{String,Any}("soc" => 80, "power" => 22000),
    ]
    table = from_config(SocPowerTable, cfg)
    @test length(table.items) == 2
    @test table.items[1].soc == 20
    @test table.items[1].power == 7.0
    @test table.items[2].soc == 80
    @test table.items[2].power == 22.0
end

# =============================================================================
# TimestampedPrice tests
# =============================================================================

@testset "TimestampedPrice - to_dto" begin
    price = TimestampedPrice(DateTime(2022,1,1), 50.0)
    dto = to_dto(price)
    @test dto["from"] == DateTime(2022,1,1)
    @test dto["price"] == 50.0
end

@testset "TimestampedPrices - constructor sorts" begin
    p1 = TimestampedPrice(DateTime(2022,1,1,2), 2.0)
    p2 = TimestampedPrice(DateTime(2022,1,1), 1.0)
    prices = TimestampedPrices([p1, p2])
    @test prices.all[1].value == 1.0
    @test prices.all[2].value == 2.0
    @test isempty(prices.current)
end

@testset "TimestampedPrices - empty" begin
    prices = TimestampedPrices(TimestampedPrice[])
    @test isempty(prices.all)
    @test isempty(prices.current)
end

@testset "TimestampedPrices - update!" begin
    p1 = TimestampedPrice(DateTime(2022,1,1,0), 1.0)
    p2 = TimestampedPrice(DateTime(2022,1,1,1), 2.0)
    p3 = TimestampedPrice(DateTime(2022,1,1,2), 3.0)
    prices = TimestampedPrices([p1, p2, p3])

    dp = Datapoint(
        timestamp=DateTime(2022,1,1,1),
        start_=DateTime(2022,1,1,1),
        end_=DateTime(2022,1,1,2),
        delta_t=Hour(1),
        algorithm="test",
        warmup=false,
        version="1",
        minimize_logs=false
    )

    update!(prices, dp)
    # After update, p1 is dropped and a synthetic price at start_ with p1's value is added
    # p2 should be in current
    @test length(prices.current) >= 1
end

@testset "TimestampedPrices - update! no future prices" begin
    p1 = TimestampedPrice(DateTime(2022,1,1,0), 1.0)
    prices = TimestampedPrices([p1])

    dp = Datapoint(
        timestamp=DateTime(2022,1,1,2),
        start_=DateTime(2022,1,1,2),
        end_=DateTime(2022,1,1,3),
        delta_t=Hour(1),
        algorithm="test",
        warmup=false,
        version="1",
        minimize_logs=false
    )

    update!(prices, dp)
    # Should have synthetic price at start_ with p1's value
    @test length(prices.all) >= 1
end

@testset "read_from_csv TimestampedPrices - nothing" begin
    prices = read_from_csv(TimestampedPrices, nothing)
    @test isempty(prices.all)
    @test isempty(prices.current)
end

# =============================================================================
# Network types tests
# =============================================================================

@testset "NetworkState enum" begin
    @test Int(NORMAL) == 0
    @test Int(ALERT) == 1
    @test Int(EMERGENCY) == 2
end

@testset "RecoveringMode enum" begin
    @test Int(DEACTIVATED) == 0
    @test Int(ARMED) == 1
    @test Int(ACTIVATED) == 2
    @test Int(DEACTIVATING) == 3
end

@testset "FrequencyRange - to_dto" begin
    fr = FrequencyRange(up=50.2, down=49.8)
    dto = to_dto(fr)
    @test dto["up"] == 50.2
    @test dto["down"] == 49.8
end

@testset "FrequencyActivationMapping - load and to_dto" begin
    cfg = Dict{String,Any}("frequency" => 50.1, "activation" => 0.5)
    m = load(FrequencyActivationMapping, cfg)
    @test m.frequency == 50.1
    @test m.activation == 0.5
    dto = to_dto(m)
    @test dto["frequency"] == 50.1
    @test dto["activation"] == 0.5
end

@testset "FrequencyActivationTable - load and to_dto" begin
    cfg = Dict{String,Any}(
        "0" => Dict{String,Any}("frequency" => 49.8, "activation" => -1.0),
        "1" => Dict{String,Any}("frequency" => 50.0, "activation" => 0.0),
        "2" => Dict{String,Any}("frequency" => 50.2, "activation" => 1.0),
    )
    table = load(FrequencyActivationTable, cfg)
    @test length(table.mappings) == 3
    dtos = to_dto(table)
    @test length(dtos) == 3
end

@testset "FrequencyActivationTable - dead_zone" begin
    table = FrequencyActivationTable(
        mappings=[
            FrequencyActivationMapping(frequency=49.8, activation=-1.0),
            FrequencyActivationMapping(frequency=49.9, activation=0.0),
            FrequencyActivationMapping(frequency=50.0, activation=0.0),
            FrequencyActivationMapping(frequency=50.1, activation=0.0),
            FrequencyActivationMapping(frequency=50.2, activation=1.0),
        ]
    )
    dz = dead_zone(table)
    @test dz.down == 49.9
    @test dz.up == 50.1
end

@testset "FrequencyActivationTable - max_steady_state_deviation" begin
    table = FrequencyActivationTable(
        mappings=[
            FrequencyActivationMapping(frequency=49.8, activation=-1.0),
            FrequencyActivationMapping(frequency=50.2, activation=1.0),
        ]
    )
    msd = max_steady_state_deviation(table)
    @test msd.down == 49.8
    @test msd.up == 50.2
end

@testset "FrequencyActivationTable - plus offset" begin
    table = FrequencyActivationTable(
        mappings=[
            FrequencyActivationMapping(frequency=0.0, activation=0.0),
            FrequencyActivationMapping(frequency=0.2, activation=1.0),
        ]
    )
    shifted = plus(table, 50.0)
    @test shifted.mappings[1].frequency == 50.0
    @test shifted.mappings[2].frequency == 50.2
    @test shifted.mappings[2].activation == 1.0
end

@testset "FrequencyQualityDefiningParams - load and to_dto" begin
    cfg = Dict{String,Any}(
        "base_frequency" => 50.0,
        "frequency_activation_table" => Dict{String,Any}(
            "0" => Dict{String,Any}("frequency" => 49.8, "activation" => -1.0),
            "1" => Dict{String,Any}("frequency" => 50.0, "activation" => 0.0),
            "2" => Dict{String,Any}("frequency" => 50.2, "activation" => 1.0),
        ),
        "asymmetric_response_allowed" => true,
        "minimum_duration_at_full_power" => 300,
    )
    params = load(FrequencyQualityDefiningParams, cfg)
    @test params.base_frequency == 50.0
    @test params.asymmetric_response_allowed == true
    @test params.minimum_duration_at_full_power == Second(300)
    dto = to_dto(params)
    @test haskey(dto, "baseFrequency")
    @test haskey(dto, "frequencyDeadZone")
    @test haskey(dto, "maxFrequencyDeviation")
    @test haskey(dto, "frequencyActivationTable")
    @test haskey(dto, "minimumDurationAtFullPower")
    @test haskey(dto, "asymmetricResponseAllowed")
end

# =============================================================================
# ServicesRequestParameters tests
# =============================================================================

@testset "SocPenalties - load and to_dto" begin
    cfg = Dict{String,Any}(
        "encouraged_min_soc_gap" => 5,
        "encouraged_max_soc_gap" => 20,
        "max_soc_gap" => 50,
    )
    sp = load(SocPenalties, cfg)
    @test sp.encouraged_min_soc_gap == 5
    @test sp.encouraged_max_soc_gap == 20
    @test sp.max_soc_gap == 50
    dto = to_dto(sp)
    @test dto["encouragedMinSocGap"] == 5
    @test dto["encouragedMaxSocGap"] == 20
    @test dto["maxSocGap"] == 50
end

@testset "InstantChargePenalties - load and to_dto" begin
    cfg = Dict{String,Any}("max_soc_gap" => 10)
    p = load(InstantChargePenalties, cfg)
    @test p.max_soc_gap == 10
    dto = to_dto(p)
    @test dto["maxSocGap"] == 10
end

@testset "ChargingRequirementsServiceParameters - load and to_dto" begin
    cfg = Dict{String,Any}(
        "weight" => 0.5,
        "soc_penalties" => Dict{String,Any}(
            "encouraged_min_soc_gap" => 5,
            "encouraged_max_soc_gap" => 20,
            "max_soc_gap" => 50,
        ),
        "instant_charge_penalties" => Dict{String,Any}("max_soc_gap" => 10),
    )
    params = load(ChargingRequirementsServiceParameters, cfg)
    @test params.weight == 0.5
    @test params.soc_penalties.encouraged_min_soc_gap == 5
    @test params.instant_charge_penalties.max_soc_gap == 10
    dto = to_dto(params)
    @test dto["weight"] == 0.5
    @test haskey(dto, "socPenalties")
    @test haskey(dto, "instantChargePenalties")
end

@testset "TariffServiceParameters - load and to_dto" begin
    cfg = Dict{String,Any}(
        "weight" => 1.0,
        "discount" => 0.9,
        "default_price" => 100.0,
    )
    params = load(TariffServiceParameters, cfg)
    @test params.weight == 1.0
    @test params.discount == 0.9
    @test params.default_price == 100.0
    dto = to_dto(params)
    @test dto["weight"] == 1.0
    @test dto["discount"] == 0.9
    @test dto["defaultPrice"] == 100.0
end

@testset "FcrServiceParameters - load" begin
    cfg = Dict{String,Any}(
        "weight" => 0.3,
        "parameters" => Dict{String,Any}(
            "base_frequency" => 50.0,
            "frequency_activation_table" => Dict{String,Any}(
                "0" => Dict{String,Any}("frequency" => 49.8, "activation" => -1.0),
                "1" => Dict{String,Any}("frequency" => 50.0, "activation" => 0.0),
                "2" => Dict{String,Any}("frequency" => 50.2, "activation" => 1.0),
            ),
            "asymmetric_response_allowed" => false,
            "minimum_duration_at_full_power" => 600,
        ),
    )
    params = load(FcrServiceParameters, cfg)
    @test params.weight == 0.3
    @test params.parameters.base_frequency == 50.0
    @test params.parameters.asymmetric_response_allowed == false
end

@testset "BaselineStabilityServiceParameters - load" begin
    cfg = Dict{String,Any}("weight" => 0.2)
    params = load(BaselineStabilityServiceParameters, cfg)
    @test params.weight == 0.2
end

@testset "Co2ServiceParameters - load and to_dto" begin
    cfg = Dict{String,Any}("weight" => 0.1)
    params = load(Co2ServiceParameters, cfg)
    @test params.weight == 0.1
    dto = to_dto(params)
    @test dto["weight"] == 0.1
end

@testset "DayAheadServiceParameters - load" begin
    cfg = Dict{String,Any}("weight" => 0.4, "discount" => 0.85)
    params = load(DayAheadServiceParameters, cfg)
    @test params.weight == 0.4
    @test params.discount == 0.85
end

@testset "ServicesRequestParameters - load" begin
    cfg = Dict{String,Any}(
        "charging_requirements" => Dict{String,Any}(
            "weight" => 0.5,
            "soc_penalties" => Dict{String,Any}(
                "encouraged_min_soc_gap" => 5,
                "encouraged_max_soc_gap" => 20,
                "max_soc_gap" => 50,
            ),
            "instant_charge_penalties" => Dict{String,Any}("max_soc_gap" => 10),
        ),
        "tariff" => Dict{String,Any}(
            "weight" => 1.0,
            "discount" => 0.9,
            "default_price" => 100.0,
        ),
        "fcr" => Dict{String,Any}(
            "fcr1" => Dict{String,Any}(
                "weight" => 0.3,
                "parameters" => Dict{String,Any}(
                    "base_frequency" => 50.0,
                    "frequency_activation_table" => Dict{String,Any}(
                        "0" => Dict{String,Any}("frequency" => 49.8, "activation" => -1.0),
                        "1" => Dict{String,Any}("frequency" => 50.0, "activation" => 0.0),
                        "2" => Dict{String,Any}("frequency" => 50.2, "activation" => 1.0),
                    ),
                    "asymmetric_response_allowed" => false,
                    "minimum_duration_at_full_power" => 600,
                ),
            ),
        ),
        "baseline_stability" => Dict{String,Any}("weight" => 0.2),
        "co2" => Dict{String,Any}("weight" => 0.1),
        "day_ahead" => Dict{String,Any}("weight" => 0.4, "discount" => 0.85),
    )
    params = load(ServicesRequestParameters, cfg)
    @test params.charging_requirements.weight == 0.5
    @test params.tariff.weight == 1.0
    @test haskey(params.fcr, "fcr1")
    @test params.baseline_stability.weight == 0.2
    @test params.co2.weight == 0.1
    @test params.day_ahead.weight == 0.4
end

@testset "ServicesRequestParameters - is_fcr_enabled" begin
    freq_table_cfg = Dict{String,Any}(
        "0" => Dict{String,Any}("frequency" => 49.8, "activation" => -1.0),
        "1" => Dict{String,Any}("frequency" => 50.0, "activation" => 0.0),
        "2" => Dict{String,Any}("frequency" => 50.2, "activation" => 1.0),
    )
    fcr_cfg = Dict{String,Any}(
        "weight" => 0.3,
        "parameters" => Dict{String,Any}(
            "base_frequency" => 50.0,
            "frequency_activation_table" => freq_table_cfg,
            "asymmetric_response_allowed" => false,
            "minimum_duration_at_full_power" => 600,
        ),
    )
    params_with_fcr = ServicesRequestParameters(
        charging_requirements=ChargingRequirementsServiceParameters(
            weight=0.5,
            soc_penalties=SocPenalties(encouraged_min_soc_gap=5, encouraged_max_soc_gap=20, max_soc_gap=50),
            instant_charge_penalties=InstantChargePenalties(max_soc_gap=10),
        ),
        tariff=TariffServiceParameters(weight=1.0, discount=0.9, default_price=100.0),
        fcr=Dict{String,FcrServiceParameters}("fcr1" => load(FcrServiceParameters, fcr_cfg)),
        baseline_stability=BaselineStabilityServiceParameters(weight=0.2),
        co2=Co2ServiceParameters(weight=0.1),
        day_ahead=DayAheadServiceParameters(weight=0.4, discount=0.85),
    )
    @test is_fcr_enabled(params_with_fcr) == true

    params_no_fcr = ServicesRequestParameters(
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
    )
    @test is_fcr_enabled(params_no_fcr) == false
end

# =============================================================================
# EvseModel tests
# =============================================================================

@testset "EvseModel - from_config" begin
    cfg = Dict{String,Any}(
        "standby losses" => 500,
        "variable losses" => 5.0,
        "power limits" => Dict{String,Any}(
            "max charge power" => 22000,
            "max discharge power" => 10000,
            "min charge power" => 1000,
            "efficiency min discharge power" => 2000,
            "efficiency min charge power" => 2000,
        ),
        "current_type" => 0,
        "supports_v2g" => true,
    )
    model = from_config(EvseModel, cfg)
    @test model.max_charge_power == 22.0
    @test model.max_discharge_power == 10.0
    @test model.min_charge_power == 1.0
    @test model.efficiency_min_discharge_power == 2.0
    @test model.efficiency_min_charge_power == 2.0
    @test model.current_type == AC
    @test model.supports_v2g == true
    @test model.power_losses.standby == 0.5
end

@testset "EvseModel - power_limits" begin
    model = EvseModel(
        power_losses=PowerLosses(standby=0.5, variable=VariablePowerLosses(charging=0.05, discharging=0.05)),
        max_charge_power=22.0,
        max_discharge_power=10.0,
        min_charge_power=1.0,
        efficiency_min_discharge_power=2.0,
        efficiency_min_charge_power=2.0,
    )
    pl = power_limits(model)
    @test pl.max_charge_power == 22.0
    @test pl.max_discharge_power == 10.0
    @test pl.min_charge_power == 1.0
    @test pl.efficiency_min_discharge_power == 2.0
    @test pl.efficiency_min_charge_power == 2.0
end

@testset "EvseModel - defaults" begin
    model = EvseModel(
        power_losses=PowerLosses(standby=0.0, variable=VariablePowerLosses(charging=0.0, discharging=0.0)),
    )
    @test model.max_charge_power == 10.0
    @test model.max_discharge_power == 9.2
    @test model.current_type == AC
    @test model.supports_v2g == false
end

# =============================================================================
# VehicleModel tests
# =============================================================================

@testset "VehicleModel - from_config minimal" begin
    cfg = Dict{String,Any}(
        "capacity" => 60000,
        "min soc" => 5000,
        "max soc" => 55000,
        "max_ac_charge_power" => 11.0,
        "max_dc_charge_power" => 50.0,
    )
    model = from_config(VehicleModel, cfg)
    @test model.capacity == 60.0
    @test model.min_soc == 5.0
    @test model.max_soc == 55.0
    @test model.max_ac_charge_power == 11.0
    @test model.max_dc_charge_power == 50.0
    @test model.power_losses === nothing
    @test model.soc_power_table === nothing
    @test model.max_charge_power_max_soc == 0.0
end

@testset "VehicleModel - from_config with losses" begin
    cfg = Dict{String,Any}(
        "capacity" => 60000,
        "min soc" => 5000,
        "max soc" => 55000,
        "max_ac_charge_power" => 11.0,
        "max_dc_charge_power" => 50.0,
        "standby_losses" => 0.5,
        "variable_losses" => Dict{String,Any}(
            "charging" => 0.05,
            "discharging" => 0.05,
        ),
    )
    model = from_config(VehicleModel, cfg)
    @test model.power_losses !== nothing
    @test model.power_losses.standby == 0.5
    @test model.power_losses.variable.charging == 0.05
    @test model.power_losses.variable.discharging == 0.05
end

@testset "VehicleModel - from_config with soc_power_table" begin
    cfg = Dict{String,Any}(
        "capacity" => 60000,
        "min soc" => 5000,
        "max soc" => 55000,
        "max_ac_charge_power" => 11.0,
        "max_dc_charge_power" => 50.0,
        "soc_power_table" => [
            Dict{String,Any}("soc" => 20, "power" => 7000),
            Dict{String,Any}("soc" => 80, "power" => 22000),
        ],
    )
    model = from_config(VehicleModel, cfg)
    @test model.soc_power_table !== nothing
    @test length(model.soc_power_table.items) == 2
end

@testset "VehicleModel - from_config with max_charge_power_max_soc" begin
    cfg = Dict{String,Any}(
        "capacity" => 60000,
        "min soc" => 5000,
        "max soc" => 55000,
        "max_ac_charge_power" => 11.0,
        "max_dc_charge_power" => 50.0,
        "max_charge_power_max_soc" => 50.0,
    )
    model = from_config(VehicleModel, cfg)
    @test model.max_charge_power_max_soc == 0.5
end

# =============================================================================
# DeliveryPoint tests
# =============================================================================

@testset "CircuitEvse - load and to_dto" begin
    cfg = Dict{String,Any}(
        "evseId" => "evse_1",
        "phases" => "L1",
        "installedOnPhase" => "L1",
        "priority" => 2,
    )
    evse = load(CircuitEvse, cfg)
    @test evse.evse_id == "evse_1"
    @test evse.phases == "L1"
    @test evse.installed_on_phase == "L1"
    @test evse.priority == 2
    dto = to_dto(evse)
    @test dto["evseId"] == "evse_1"
    @test dto["phases"] == "L1"
    @test dto["installedOnPhase"] == "L1"
    @test dto["priority"] == 2
end

@testset "CircuitEvse - load without priority" begin
    cfg = Dict{String,Any}(
        "evseId" => "evse_2",
        "phases" => "L2",
        "installedOnPhase" => "L2",
    )
    evse = load(CircuitEvse, cfg)
    @test evse.priority == 0
end

@testset "CircuitPowerLimits - load and to_dto" begin
    cfg = Dict{String,Any}("maxChargePower" => 22000, "maxDischargePower" => 10000)
    limits = load(CircuitPowerLimits, cfg)
    @test limits.max_charge_power == 22.0
    @test limits.max_discharge_power == 10.0
    dto = to_dto(limits)
    @test dto["maxChargePower"] == 22000
    @test dto["maxDischargePower"] == 10000
end

@testset "CircuitPowerLimits - load with missing fields" begin
    cfg = Dict{String,Any}()
    limits = load(CircuitPowerLimits, cfg)
    @test limits.max_charge_power === nothing
    @test limits.max_discharge_power === nothing
    dto = to_dto(limits)
    @test !haskey(dto, "maxChargePower")
    @test !haskey(dto, "maxDischargePower")
end

@testset "CircuitPowerLimits - load with partial fields" begin
    cfg = Dict{String,Any}("maxChargePower" => 11000)
    limits = load(CircuitPowerLimits, cfg)
    @test limits.max_charge_power == 11.0
    @test limits.max_discharge_power === nothing
end

@testset "OtherConsumption - to_dto" begin
    oc = OtherConsumption(
        circuit_id="c1",
        from=DateTime(2022,1,1),
        to=DateTime(2022,1,2),
        phases="L1",
        installed_on_phase="L1",
        power=1500.0,
    )
    dto = to_dto(oc)
    @test dto["phases"] == "L1"
    @test dto["installedOnPhase"] == "L1"
    @test length(dto["schedule"]) == 1
    @test dto["schedule"][1]["power"] == 1500
end

@testset "OtherProduction - to_dto" begin
    op = OtherProduction(
        circuit_id="c1",
        from=DateTime(2022,1,1),
        to=DateTime(2022,1,2),
        phases="L1",
        installed_on_phase="L1",
        power=3000.0,
    )
    dto = to_dto(op)
    @test dto["phases"] == "L1"
    @test dto["installedOnPhase"] == "L1"
    @test dto["schedule"][1]["power"] == 3000
end

@testset "DeliveryPointCircuit - load and to_dto" begin
    cfg = Dict{String,Any}(
        "id" => "circuit_1",
        "phases" => "L1",
        "installedOnPhase" => "L1",
        "circuits" => [],
        "evses" => [
            Dict{String,Any}(
                "evseId" => "evse_1",
                "phases" => "L1",
                "installedOnPhase" => "L1",
                "priority" => 1,
            ),
        ],
    )
    circuit = load(DeliveryPointCircuit, cfg)
    @test circuit.id_ == "circuit_1"
    @test circuit.phases == "L1"
    @test circuit.installed_on_phase == "L1"
    @test length(circuit.evses) == 1
    @test circuit.power_limits === nothing

    dto = to_dto(circuit)
    @test dto["id"] == "circuit_1"
    @test dto["phases"] == "L1"
end

@testset "DeliveryPointCircuit - load with power limits" begin
    cfg = Dict{String,Any}(
        "id" => "circuit_2",
        "phases" => "L1",
        "installedOnPhase" => "L1",
        "circuits" => [],
        "evses" => [],
        "powerLimits" => Dict{String,Any}("maxChargePower" => 22000),
    )
    circuit = load(DeliveryPointCircuit, cfg)
    @test circuit.power_limits !== nothing
    @test circuit.power_limits.max_charge_power == 22.0
end

@testset "DeliveryPoint - load and to_dto" begin
    cfg = Dict{String,Any}(
        "id" => "dp_1",
        "phases" => "L1",
        "powerLimits" => Dict{String,Any}("maxChargePower" => 44000),
        "circuits" => [
            Dict{String,Any}(
                "id" => "circuit_1",
                "phases" => "L1",
                "installedOnPhase" => "L1",
                "circuits" => [],
                "evses" => [],
            ),
        ],
    )
    dp = load(DeliveryPoint, cfg)
    @test dp.id_ == "dp_1"
    @test dp.phases == "L1"
    @test dp.power_limits.max_charge_power == 44.0
    @test length(dp.circuits) == 1
    @test dp.subscribed_power === nothing

    dto = to_dto(dp)
    @test dto["id"] == "dp_1"
    @test haskey(dto, "powerLimits")
    @test !haskey(dto, "subscribedPower")
end

@testset "DeliveryPoint - load with subscribed power" begin
    cfg = Dict{String,Any}(
        "id" => "dp_2",
        "phases" => "L3",
        "powerLimits" => Dict{String,Any}("maxChargePower" => 44000),
        "circuits" => [],
        "subscribedPower" => Dict{String,Any}("maxChargePower" => 30000),
    )
    dp = load(DeliveryPoint, cfg)
    @test dp.subscribed_power !== nothing
    @test dp.subscribed_power.max_charge_power == 30.0
    dto = to_dto(dp)
    @test haskey(dto, "subscribedPower")
end

# =============================================================================
# Agents tests
# =============================================================================

@testset "EvseAgentRegistration" begin
    reg = EvseAgentRegistration("evse_1")
    @test reg.id_ == "evse_1"
end

@testset "VehicleAgentRegistration" begin
    reg = VehicleAgentRegistration("vehicle_1")
    @test reg.id_ == "vehicle_1"
end

@testset "SiteAgentRegistration" begin
    reg = SiteAgentRegistration("site_1")
    @test reg.id_ == "site_1"
end

@testset "NetworkAgentRegistration" begin
    reg = NetworkAgentRegistration("net_1")
    @test reg.id_ == "net_1"
end

@testset "SpotAgentRegistration" begin
    reg = SpotAgentRegistration("spot_1")
    @test reg.id_ == "spot_1"
end

@testset "EvseSetDataRequest - defaults" begin
    req = EvseSetDataRequest()
    @test req.baseline === nothing
    @test req.power === nothing
    @test req.primary_activated === nothing
    @test req.primary_capacity === nothing
    @test req.primary_capacity_up === nothing
    @test req.primary_capacity_down === nothing
end

@testset "EvseSetDataRequest - with values" begin
    req = EvseSetDataRequest(baseline=10.0, power=5.0, primary_activated=1, primary_capacity=2)
    @test req.baseline == 10.0
    @test req.power == 5.0
    @test req.primary_activated == 1
    @test req.primary_capacity == 2
end

@testset "VehicleSetDataRequest - defaults" begin
    req = VehicleSetDataRequest()
    @test req.power === nothing
end

@testset "VehicleSetDataRequest - with value" begin
    req = VehicleSetDataRequest(power=15.0)
    @test req.power == 15.0
end

@testset "TimestampedVehicleSoc" begin
    tvs = TimestampedVehicleSoc(DateTime(2022,1,1), 30.0)
    @test tvs.timestamp == DateTime(2022,1,1)
    @test tvs.value == 30.0
end

# =============================================================================
# Optimization types tests
# =============================================================================

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

# =============================================================================
# Snapshot types tests
# =============================================================================

@testset "VehicleSnapshot" begin
    vs = VehicleSnapshot(
        id_="v1",
        capacity=60.0,
        max_soc=55.0,
        max_ac_charge_power=11.0,
        max_dc_charge_power=50.0,
        max_charge_power_max_soc=0.5,
        soc=30.0,
        soc_requirements=Float64[],
    )
    @test vs.id_ == "v1"
    @test vs.soc == 30.0
    @test vs.min_ac_charge_power == 0.0
    @test vs.min_dc_charge_power == 0.0
    @test vs.model === nothing
    @test vs.current_trip === nothing
end

@testset "TransactionSnapshot" begin
    vs = VehicleSnapshot(
        id_="v1",
        capacity=60.0,
        max_soc=55.0,
        max_ac_charge_power=11.0,
        max_dc_charge_power=50.0,
        max_charge_power_max_soc=0.0,
        soc=30.0,
        soc_requirements=Float64[],
    )
    ts = TransactionSnapshot(
        id_="tx_1",
        vehicle=vs,
        power_limits=PowerLimits(max_charge_power=22.0),
        baseline=5.0,
    )
    @test ts.id_ == "tx_1"
    @test ts.baseline == 5.0
    @test ts.power_limits.max_charge_power == 22.0
end

@testset "EvseSnapshot" begin
    es = EvseSnapshot(
        id_="evse_1",
        baseline=5.0,
        power_losses=PowerLosses(standby=0.5, variable=VariablePowerLosses(charging=0.05, discharging=0.05)),
        supports_v2g=false,
    )
    @test es.id_ == "evse_1"
    @test es.transaction === nothing
    @test isempty(es.future_transactions)
end

@testset "ElectricNetworkSnapshot" begin
    ens = ElectricNetworkSnapshot(frequency=50.0, state=NetworkState.NORMAL)
    @test ens.frequency == 50.0
    @test ens.state == NetworkState.NORMAL
end

@testset "SpotSnapshot" begin
    ss = SpotSnapshot(day_ahead_prices=TimestampedPrice[])
    @test has_day_ahead_prices(ss) == false
    ss2 = SpotSnapshot(
        day_ahead_prices=[TimestampedPrice(DateTime(2022,1,1), 50.0)]
    )
    @test has_day_ahead_prices(ss2) == true
end

@testset "SiteSnapshot" begin
    site = SiteSnapshot(delivery_point=nothing, customer_tariffs=TimestampedPrice[])
    @test has_customer_tariffs(site) == false
    site2 = SiteSnapshot(
        delivery_point=nothing,
        customer_tariffs=[TimestampedPrice(DateTime(2022,1,1), 0.1)],
    )
    @test has_customer_tariffs(site2) == true
end

@testset "FutureTransactionSnapshot - to_dto" begin
    ft = FutureTransactionSnapshot(
        ev_id="v1",
        model=VehicleModel(
            capacity=60.0,
            min_soc=5.0,
            max_soc=55.0,
            max_ac_charge_power=11.0,
            max_dc_charge_power=50.0,
        ),
        arrival=DateTime(2022,1,1,8),
        departure=DateTime(2022,1,1,18),
        estimated_soc=30.0,
        energy_needed=20.0,
        power_limits=PowerLimits(max_charge_power=22.0, min_charge_power=1.0),
    )
    dto = to_dto(ft)
    @test dto["vehicleId"] == "v1"
    @test dto["arrival"] == DateTime(2022,1,1,8)
    @test dto["departure"] == DateTime(2022,1,1,18)
    @test dto["estimatedSocOnArrival"] == 30.0 * 1000
    @test dto["energyNeededForNextTrip"] == 20.0 * 1000
    @test dto["powerLimits"]["maxChargePower"] == 22.0 * 1000
    @test dto["powerLimits"]["minChargePower"] == 1.0 * 1000
end

@testset "FutureTransactionSnapshot - to_dto without optional fields" begin
    ft = FutureTransactionSnapshot(
        ev_id="v1",
        model=VehicleModel(
            capacity=60.0,
            min_soc=5.0,
            max_soc=55.0,
            max_ac_charge_power=11.0,
            max_dc_charge_power=50.0,
        ),
        arrival=DateTime(2022,1,1,8),
        departure=DateTime(2022,1,1,18),
        estimated_soc=nothing,
        energy_needed=nothing,
        power_limits=PowerLimits(max_charge_power=22.0),
    )
    dto = to_dto(ft)
    @test !haskey(dto, "estimatedSocOnArrival")
    @test !haskey(dto, "energyNeededForNextTrip")
end

@testset "VirtualEnvironmentSnapshot" begin
    vs = VehicleSnapshot(
        id_="v1", capacity=60.0, max_soc=55.0,
        max_ac_charge_power=11.0, max_dc_charge_power=50.0,
        max_charge_power_max_soc=0.0, soc=30.0, soc_requirements=Float64[],
    )
    ves = VirtualEnvironmentSnapshot(
        timestamp=DateTime(2022,1,1),
        horizon=OptimizationHorizon(start=DateTime(2022,1,1), stop=DateTime(2022,1,2), period_duration=Hour(1)),
        sites=SiteSnapshot[],
        evses=EvseSnapshot[],
        vehicles=[vs],
        recovering_state=RecoveringMode.DEACTIVATED,
    )
    @test ves.timestamp == DateTime(2022,1,1)
    @test ves.recovering_state == RecoveringMode.DEACTIVATED
    @test ves.announced_capacity === nothing
    @test ves.network === nothing
    @test ves.spot === nothing
    @test ves.previous_optimization_response === nothing
end

# =============================================================================
# VehicleState & SoC update tests
# =============================================================================

@testset "VehicleState creation" begin
    model = VehicleModel(
        capacity=60.0,
        min_soc=5.0,
        max_soc=55.0,
        max_ac_charge_power=11.0,
        max_dc_charge_power=50.0,
        power_losses=PowerLosses(
            standby=0.5,
            variable=VariablePowerLosses(charging=0.05, discharging=0.05),
        ),
    )
    vs = VehicleState(
        id_="v1", site_id="s1", model=model, soc=30.0,
        previous_soc=30.0, power=0.0, noise=0.0,
        connected=true, evse_id="evse_1",
    )
    @test vs.id_ == "v1"
    @test vs.soc == 30.0
    @test vs.connected == true
end

@testset "compute_vehicle_soc_update - charging" begin
    model = VehicleModel(
        capacity=60.0,
        min_soc=5.0,
        max_soc=55.0,
        max_ac_charge_power=11.0,
        max_dc_charge_power=50.0,
        power_losses=PowerLosses(
            standby=0.0,
            variable=VariablePowerLosses(charging=0.0, discharging=0.0),
        ),
    )
    vs = VehicleState(
        id_="v1", site_id="s1", model=model, soc=30.0,
        previous_soc=30.0, power=0.0, noise=0.0,
        connected=true, evse_id="evse_1",
    )
    # 11kW for 3600s = 1 hour = 11 kWh added
    new_soc = compute_vehicle_soc_update(vs, 11.0, 0.0, 3600.0)
    @test new_soc ≈ 41.0
end

@testset "compute_vehicle_soc_update - discharging" begin
    model = VehicleModel(
        capacity=60.0,
        min_soc=5.0,
        max_soc=55.0,
        max_ac_charge_power=11.0,
        max_dc_charge_power=50.0,
        power_losses=PowerLosses(
            standby=0.0,
            variable=VariablePowerLosses(charging=0.0, discharging=0.0),
        ),
    )
    vs = VehicleState(
        id_="v1", site_id="s1", model=model, soc=30.0,
        previous_soc=30.0, power=0.0, noise=0.0,
        connected=true, evse_id="evse_1",
    )
    # -5kW for 3600s = 5 kWh removed
    new_soc = compute_vehicle_soc_update(vs, -5.0, 0.0, 3600.0)
    @test new_soc ≈ 25.0
end

@testset "compute_vehicle_soc_update - clamp to capacity" begin
    model = VehicleModel(
        capacity=60.0,
        min_soc=5.0,
        max_soc=55.0,
        max_ac_charge_power=11.0,
        max_dc_charge_power=50.0,
        power_losses=PowerLosses(
            standby=0.0,
            variable=VariablePowerLosses(charging=0.0, discharging=0.0),
        ),
    )
    vs = VehicleState(
        id_="v1", site_id="s1", model=model, soc=55.0,
        previous_soc=55.0, power=0.0, noise=0.0,
        connected=true, evse_id="evse_1",
    )
    # 11kW for 3600s = 11 kWh, but cap is 60, so new_soc = min(66, 60) = 60
    new_soc = compute_vehicle_soc_update(vs, 11.0, 0.0, 3600.0)
    @test new_soc ≈ 60.0
end

@testset "compute_vehicle_soc_update - clamp to zero" begin
    model = VehicleModel(
        capacity=60.0,
        min_soc=5.0,
        max_soc=55.0,
        max_ac_charge_power=11.0,
        max_dc_charge_power=50.0,
        power_losses=PowerLosses(
            standby=0.0,
            variable=VariablePowerLosses(charging=0.0, discharging=0.0),
        ),
    )
    vs = VehicleState(
        id_="v1", site_id="s1", model=model, soc=2.0,
        previous_soc=2.0, power=0.0, noise=0.0,
        connected=true, evse_id="evse_1",
    )
    # -5kW for 3600s = 5 kWh removed, but clamp to 0
    new_soc = compute_vehicle_soc_update(vs, -5.0, 0.0, 3600.0)
    @test new_soc ≈ 0.0
end

@testset "compute_vehicle_soc_update - with noise" begin
    model = VehicleModel(
        capacity=60.0,
        min_soc=5.0,
        max_soc=55.0,
        max_ac_charge_power=11.0,
        max_dc_charge_power=50.0,
        power_losses=PowerLosses(
            standby=0.0,
            variable=VariablePowerLosses(charging=0.0, discharging=0.0),
        ),
    )
    vs = VehicleState(
        id_="v1", site_id="s1", model=model, soc=30.0,
        previous_soc=30.0, power=0.0, noise=0.0,
        connected=true, evse_id="evse_1",
    )
    new_soc = compute_vehicle_soc_update(vs, 10.0, 1.0, 3600.0)
    @test new_soc ≈ 41.0
end

@testset "batch_vehicle_soc_update! - connected vehicle" begin
    model = VehicleModel(
        capacity=60.0,
        min_soc=5.0,
        max_soc=55.0,
        max_ac_charge_power=11.0,
        max_dc_charge_power=50.0,
        power_losses=PowerLosses(
            standby=0.0,
            variable=VariablePowerLosses(charging=0.0, discharging=0.0),
        ),
    )
    v1 = VehicleState(
        id_="v1", site_id="s1", model=model, soc=30.0,
        previous_soc=30.0, power=10.0, noise=0.0,
        connected=true, evse_id="evse_1",
    )
    v2 = VehicleState(
        id_="v2", site_id="s1", model=model, soc=20.0,
        previous_soc=20.0, power=5.0, noise=0.0,
        connected=false, evse_id=nothing,
    )
    vehicles = [v1, v2]
    batch_vehicle_soc_update!(vehicles, 3600.0)
    @test v1.soc ≈ 40.0
    @test v2.soc == 20.0  # not connected, no update
end

@testset "batch_vehicle_soc_update! - empty vehicles" begin
    vehicles = VehicleState[]
    batch_vehicle_soc_update!(vehicles, 3600.0)
    @test isempty(vehicles)
end

# =============================================================================
# EnergyNeed tests
# =============================================================================

@testset "EnergyNeed" begin
    en = EnergyNeed(period=TimeRange(DateTime(2022,1,1), DateTime(2022,1,2)), value=15.0)
    @test en.value == 15.0
    @test en.period.from == DateTime(2022,1,1)
end

# =============================================================================
# VehicleTrip tests
# =============================================================================

@testset "VehicleTrip" begin
    trip = VehicleTrip(start=DateTime(2022,1,1), destination=DateTime(2022,1,2))
    @test trip.start == DateTime(2022,1,1)
    @test trip.destination == DateTime(2022,1,2)
end

@testset "FutureTransactionSeed" begin
    trip = VehicleTrip(start=DateTime(2022,1,1), destination=DateTime(2022,1,2))
    seed = FutureTransactionSeed(trip=trip)
    @test seed.trip.start == DateTime(2022,1,1)
end

# =============================================================================
# Mobility / Plugin / Plugout tests
# =============================================================================

@testset "Plugin" begin
    p = Plugin(datetime=DateTime(2022,1,1), time=0.5, soc=0.3, evse_id="evse_1")
    @test p.datetime == DateTime(2022,1,1)
    @test p.time == 0.5
    @test p.soc == 0.3
    @test p.evse_id == "evse_1"
end

@testset "Plugin - defaults" begin
    p = Plugin(datetime=DateTime(2022,1,1), time=0.5)
    @test p.soc === nothing
    @test p.evse_id === nothing
end

@testset "Plugout" begin
    po = Plugout(datetime=DateTime(2022,1,1,12), time=1.0, evse_id="evse_2")
    @test po.datetime == DateTime(2022,1,1,12)
    @test po.time == 1.0
    @test po.evse_id == "evse_2"
end

@testset "Mobility - from_dto" begin
    dto = [
        Dict{String,Any}("type" => "plugin", "at" => DateTime(2022,1,1), "time" => 0.5, "soc" => 0.3, "evse_id" => "evse_1"),
        Dict{String,Any}("type" => "plugout", "at" => DateTime(2022,1,1,6), "time" => 1.0, "evse_id" => "evse_1"),
    ]
    mob = from_dto(Mobility, dto)
    @test length(mob.events) == 2
    @test mob.current_index == 1
    @test mob.events[1] isa Plugin
    @test mob.events[2] isa Plugout
end

@testset "Mobility - from_dto default type" begin
    dto = [
        Dict{String,Any}("at" => DateTime(2022,1,1), "time" => 0.5),
    ]
    mob = from_dto(Mobility, dto)
    @test length(mob.events) == 1
    @test mob.events[1] isa Plugin
end

@testset "Mobility - peek and discard" begin
    dto = [
        Dict{String,Any}("type" => "plugin", "at" => DateTime(2022,1,1), "time" => 0.5),
        Dict{String,Any}("type" => "plugout", "at" => DateTime(2022,1,1,6), "time" => 1.0),
    ]
    mob = from_dto(Mobility, dto)
    @test peek_next_event(mob) !== nothing
    discard_next_event!(mob)
    @test mob.current_index == 2
    @test peek_next_event(mob) !== nothing
    discard_next_event!(mob)
    @test peek_next_event(mob) === nothing
end

# =============================================================================
# BiddingService tests
# =============================================================================

@testset "BiddingService - defaults" begin
    bs = BiddingService()
    @test bs.default_announced == 100.0
    @test isempty(bs.capacities)
    @test bs.from_csv == false
end

@testset "BiddingService - with value" begin
    bs = BiddingService(50.0)
    @test bs.default_announced == 50.0
end

@testset "CapacityRequirement - narrow" begin
    cr = CapacityRequirement(
        period=TimeRange(DateTime(2022,1,1,0), DateTime(2022,1,1,12)),
        capacity_up=10.0,
        capacity_down=8.0,
    )
    narrowed = narrow(cr, DateTime(2022,1,1,6), DateTime(2022,1,1,10))
    @test narrowed.period.from == DateTime(2022,1,1,6)
    @test narrowed.period.to == DateTime(2022,1,1,10)
    @test narrowed.capacity_up == 10.0
    @test narrowed.capacity_down == 8.0
end

@testset "CapacityRequirement - narrow partial overlap" begin
    cr = CapacityRequirement(
        period=TimeRange(DateTime(2022,1,1,0), DateTime(2022,1,1,12)),
        capacity_up=10.0,
        capacity_down=8.0,
    )
    narrowed = narrow(cr, DateTime(2022,1,1,6), DateTime(2022,1,1,18))
    @test narrowed.period.from == DateTime(2022,1,1,6)
    @test narrowed.period.to == DateTime(2022,1,1,12)
end

@testset "CapacityRequirement - narrow full overlap" begin
    cr = CapacityRequirement(
        period=TimeRange(DateTime(2022,1,1,0), DateTime(2022,1,1,12)),
        capacity_up=10.0,
        capacity_down=8.0,
    )
    narrowed = narrow(cr, DateTime(2022,1,1,0), DateTime(2022,1,1,12))
    @test narrowed.period.from == DateTime(2022,1,1,0)
    @test narrowed.period.to == DateTime(2022,1,1,12)
end

# =============================================================================
# DroopController tests
# =============================================================================

@testset "DroopController - construction" begin
    controller = DroopController()
    @test controller.interp !== nothing
end

@testset "DroopController - frequency at 50.0 (dead zone)" begin
    controller = DroopController()
    data = DroopControlData(
        frequency=50.0,
        announced_capacity=CapacityRequirement[],
        transactions=Transaction[],
    )
    resp = controller |> (c -> control(c, data))
    @test resp.summary.total_power == 0.0
    @test resp.summary.total_baseline == 0.0
    @test resp.summary.total_activated == 0.0
end

@testset "DroopController - high frequency" begin
    controller = DroopController()
    fcr = FcrSummary(capacity_up=10.0, capacity_down=10.0)
    tx = Transaction(id="tx_1", managed=true, baseline=5.0, power=5.0, transaction_fcr_summary=fcr)
    data = DroopControlData(
        frequency=50.2,
        announced_capacity=CapacityRequirement[],
        transactions=[tx],
    )
    resp = control(controller, data)
    # at 50.2 Hz, activation = 1.0, so activated = fcr_up * 0 + fcr_down * 1.0 = 10.0
    # power = baseline + activated = 5.0 + 10.0 = 15.0
    @test resp.summary.total_power == 15.0
    @test resp.summary.total_baseline == 5.0
    @test resp.summary.total_activated == 10.0
end

@testset "DroopController - low frequency" begin
    controller = DroopController()
    fcr = FcrSummary(capacity_up=10.0, capacity_down=10.0)
    tx = Transaction(id="tx_1", managed=true, baseline=5.0, power=5.0, transaction_fcr_summary=fcr)
    data = DroopControlData(
        frequency=49.8,
        announced_capacity=CapacityRequirement[],
        transactions=[tx],
    )
    resp = control(controller, data)
    # at 49.8 Hz, activation = -1.0, so activated = fcr_up * (-1.0) + fcr_down * 0 = -10.0
    # power = baseline + activated = 5.0 - 10.0 = -5.0
    @test resp.summary.total_power == -5.0
    @test resp.summary.total_baseline == 5.0
    @test resp.summary.total_activated == -10.0
    @test resp.summary.total_discharge == 5.0
end

@testset "DroopController - unmanaged transaction" begin
    controller = DroopController()
    tx = Transaction(id="tx_1", managed=false, baseline=5.0, power=5.0, constant_loss=3.0)
    data = DroopControlData(
        frequency=50.2,
        announced_capacity=CapacityRequirement[],
        transactions=[tx],
    )
    resp = control(controller, data)
    # unmanaged tx: baseline = constant_loss, power = constant_loss
    @test resp.summary.total_power == 3.0
    @test resp.summary.total_baseline == 3.0
end

@testset "DroopController - mixed transactions" begin
    controller = DroopController()
    fcr = FcrSummary(capacity_up=10.0, capacity_down=10.0)
    tx_managed = Transaction(id="tx_1", managed=true, baseline=5.0, power=5.0, transaction_fcr_summary=fcr)
    tx_unmanaged = Transaction(id="tx_2", managed=false, baseline=5.0, power=5.0, constant_loss=3.0)
    data = DroopControlData(
        frequency=50.2,
        announced_capacity=CapacityRequirement[],
        transactions=[tx_managed, tx_unmanaged],
    )
    resp = control(controller, data)
    @test resp.summary.total_power == 15.0 + 3.0
    @test resp.summary.total_baseline == 5.0 + 3.0
end

@testset "DroopController - empty transactions" begin
    controller = DroopController()
    data = DroopControlData(
        frequency=50.2,
        announced_capacity=CapacityRequirement[],
        transactions=Transaction[],
    )
    resp = control(controller, data)
    @test resp.summary.total_power == 0.0
    @test resp.summary.total_baseline == 0.0
end

# =============================================================================
# SimulationConfig tests
# =============================================================================

@testset "SimulationConfig - defaults" begin
    config = SimulationConfig(
        start="2022-01-01",
        duration="24h",
        algorithm="test",
        scenario="test",
    )
    @test config.start == "2022-01-01"
    @test config.duration == "24h"
    @test config.algorithm == "test"
    @test config.output.datapoints.writer == "single"
end

@testset "SimulationConfig - custom output" begin
    config = SimulationConfig(
        start="2022-01-01",
        duration="24h",
        algorithm="test",
        scenario="test",
        output=OutputConfig(
            datapoints=DatapointsOutputConfig(
                writer="daily",
                filename_pattern="out_{date}.json",
                split_time="daily",
            ),
        ),
    )
    @test config.output.datapoints.writer == "daily"
    @test config.output.datapoints.split_time == "daily"
end

@testset "SimulationState - creation" begin
    config = SimulationConfig(
        start="2022-01-01",
        duration="24h",
        algorithm="test",
        scenario="test",
    )
    state = SimulationState(config)
    @test state.current_time == DateTime(2022,1,1)
    @test state.stop == false
    @test isempty(state.vehicles)
    @test isempty(state.evses)
end

# =============================================================================
# NetworkStateContainer tests
# =============================================================================

@testset "NetworkStateContainer - default constructor" begin
    nsc = NetworkStateContainer("net_1")
    @test nsc.id_ == "net_1"
    @test nsc.frequency == 50.0
    @test nsc.state == NetworkState.NORMAL
end

@testset "NetworkStateContainer - full constructor" begin
    nsc = NetworkStateContainer("net_1", 49.9, NetworkState.ALERT)
    @test nsc.id_ == "net_1"
    @test nsc.frequency == 49.9
    @test nsc.state == NetworkState.ALERT
end

# =============================================================================
# SpotState tests
# =============================================================================

@testset "SpotState - default constructor" begin
    ss = SpotState("spot_1")
    @test ss.id == "spot_1"
    @test isempty(ss.day_ahead_prices)
end

@testset "SpotState - with prices" begin
    ss = SpotState("spot_1", [TimestampedPrice(DateTime(2022,1,1), 50.0)])
    @test length(ss.day_ahead_prices) == 1
end

# =============================================================================
# EvseState tests
# =============================================================================

@testset "EvseState creation" begin
    model = EvseModel(
        power_losses=PowerLosses(standby=0.5, variable=VariablePowerLosses(charging=0.05, discharging=0.05)),
        max_charge_power=22.0,
    )
    es = EvseState(
        id_="evse_1", site_id="s1", model=model, vehicle_id=nothing,
        baseline=0.0, power=0.0, primary_capacity=0, primary_activated=0,
        primary_capacity_up=0, primary_capacity_down=0,
    )
    @test es.id_ == "evse_1"
    @test es.vehicle_id === nothing
    @test es.primary_capacity == 0
end

# =============================================================================
# SiteState tests
# =============================================================================

@testset "SiteState creation" begin
    ss = SiteState(id_="site_1", delivery_point=nothing, customer_tariffs=TimestampedPrice[], evses_ids=EvseId[])
    @test ss.id_ == "site_1"
    @test ss.delivery_point === nothing
    @test isempty(ss.evses_ids)
end

# =============================================================================
# Edge case tests
# =============================================================================

@testset "PowerLimits - negative power values" begin
    se = PowerLimits(max_charge_power=-1.0, min_charge_power=-5.0)
    crossed = cross_max_and_min_charge_power(se, -2.0, -3.0)
    # ev_power_max (-2.0) < self.max_charge_power (-1.0) -> -2.0
    @test crossed.max_charge_power == -2.0
    # ev_power_min (-3.0) > self.min_charge_power (-5.0) -> -3.0
    @test crossed.min_charge_power == -3.0
end

@testset "PowerLimits - equal values" begin
    se = PowerLimits(max_charge_power=10.0, min_charge_power=5.0)
    crossed = cross_max_and_min_charge_power(se, 10.0, 5.0)
    @test crossed.max_charge_power == 10.0
    @test crossed.min_charge_power == 5.0
end

@testset "SocPowerTableItem - zero values" begin
    item = SocPowerTableItem(soc=0, power=0.0)
    dto = to_dto(item; capacity=60.0)
    @test dto["soc"] == 0
    @test dto["maxChargePower"] == 0
end

@testset "SocPowerTableItem - max values" begin
    item = SocPowerTableItem(soc=100, power=250.0)
    dto = to_dto(item; capacity=60.0)
    @test dto["soc"] == 60000
    @test dto["maxChargePower"] == 250000
end

@testset "SocPowerTable - empty" begin
    table = SocPowerTable(items=SocPowerTableItem[])
    dtos = to_dto(table; capacity=60.0)
    @test isempty(dtos)
end

@testset "FrequencyActivationTable - empty" begin
    table = FrequencyActivationTable(mappings=FrequencyActivationMapping[])
    dtos = to_dto(table)
    @test isempty(dtos)
end

@testset "TimeRange - zero-length" begin
    tr = TimeRange(DateTime(2022,1,1), DateTime(2022,1,1))
    @test DateTime(2022,1,1) in tr === false
end

@testset "TimeRange - very short range" begin
    tr = TimeRange(DateTime(2022,1,1,0,0,0), DateTime(2022,1,1,0,0,1))
    @test DateTime(2022,1,1,0,0,0) in tr
    @test !(DateTime(2022,1,1,0,0,1) in tr)
end

@testset "generate_timepoints - zero duration" begin
    pts = generate_timepoints(DateTime(2022,1,1), DateTime(2022,1,1), Hour(1))
    @test length(pts) == 1
end

@testset "generate_periods - empty vector" begin
    periods = generate_periods(DateTime[])
    @test isempty(periods)
end

@testset "TimestampedPrices - drop_too_old empty" begin
    prices = TimestampedPrices(TimestampedPrice[])
    dp = Datapoint(
        timestamp=DateTime(2022,1,1),
        start_=DateTime(2022,1,1),
        end_=DateTime(2022,1,2),
        delta_t=Hour(1),
        algorithm="test",
        warmup=false,
        version="1",
        minimize_logs=false,
    )
    update!(prices, dp)
    @test isempty(prices.all)
end

@testset "DroopController - frequency exactly at boundary" begin
    controller = DroopController()
    fcr = FcrSummary(capacity_up=10.0, capacity_down=10.0)
    tx = Transaction(id="tx_1", managed=true, baseline=5.0, power=5.0, transaction_fcr_summary=fcr)
    data = DroopControlData(
        frequency=50.0,
        announced_capacity=CapacityRequirement[],
        transactions=[tx],
    )
    resp = control(controller, data)
    # at 50.0, activation = 0.0
    @test resp.summary.total_activated == 0.0
    @test resp.summary.total_power == 5.0
end

@testset "DroopController - intermediate frequency" begin
    controller = DroopController()
    fcr = FcrSummary(capacity_up=10.0, capacity_down=10.0)
    tx = Transaction(id="tx_1", managed=true, baseline=5.0, power=5.0, transaction_fcr_summary=fcr)
    data = DroopControlData(
        frequency=50.1,
        announced_capacity=CapacityRequirement[],
        transactions=[tx],
    )
    resp = control(controller, data)
    # at 50.1, activation = 0.5 (linear interpolation between 50.0 and 50.2)
    # power = 5.0 + (10.0 * 0.0 + 10.0 * 0.5) = 5.0 + 5.0 = 10.0
    @test resp.summary.total_power ≈ 10.0
end

# =============================================================================
# OptimizationRequestGenerator tests
# =============================================================================

@testset "OptimizationRequestGenerator - next_request_id!" begin
    gen = OptimizationRequestGenerator(id=0, services=ServicesRequestParameters(
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

# =============================================================================
# Transaction - discharge tracking in DroopController
# =============================================================================

@testset "DroopController - discharge tracking" begin
    controller = DroopController()
    fcr = FcrSummary(capacity_up=10.0, capacity_down=10.0)
    tx = Transaction(id="tx_1", managed=true, baseline=0.0, power=0.0, transaction_fcr_summary=fcr)
    data = DroopControlData(
        frequency=49.8,
        announced_capacity=CapacityRequirement[],
        transactions=[tx],
    )
    resp = control(controller, data)
    # at 49.8 Hz, activation = -1.0, power = 0.0 + (-10.0) = -10.0
    # discharge = abs(-10.0) = 10.0
    @test resp.summary.total_discharge == 10.0
    @test resp.summary.total_capacity_up == 10.0
    @test resp.summary.total_capacity_down == 10.0
end

@testset "DroopController - no discharge when positive power" begin
    controller = DroopController()
    fcr = FcrSummary(capacity_up=10.0, capacity_down=10.0)
    tx = Transaction(id="tx_1", managed=true, baseline=5.0, power=5.0, transaction_fcr_summary=fcr)
    data = DroopControlData(
        frequency=50.2,
        announced_capacity=CapacityRequirement[],
        transactions=[tx],
    )
    resp = control(controller, data)
    @test resp.summary.total_discharge == 0.0
end

# =============================================================================
# Constants tests
# =============================================================================

@testset "Type aliases" begin
    @test Float64 <: Energy_kWh
    @test Float64 <: Power_kW
    @test Float64 <: Power_W
    @test Float64 <: Ratio
    @test Float64 <: Frequency_Hz
    @test Float64 <: EnergyPrice_MWh
    @test Float64 <: EnergyConsumption_Wh_minute
    @test String <: VehicleId
    @test String <: EvseId
    @test String <: SiteId
    @test String <: TransactionId
    @test String <: SpotMarketAccessId
end

@testset "CurrentType enum" begin
    @test AC == AC
    @test DC == DC
    @test AC != DC
end
