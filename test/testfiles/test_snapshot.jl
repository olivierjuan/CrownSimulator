using Test
using Dates

@testset "VehicleSnapshot" begin
    vs = VehicleSnapshot(
        id_="v1",
        capacity=60.0,
        max_soc=55.0,
        max_ac_charge_power=11.0,
        max_dc_charge_power=50.0,
        max_charge_power_max_soc=0.5,
        soc=30.0,
        soc_requirements=Energy_kWh[],
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
        soc_requirements=Energy_kWh[],
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
        max_charge_power_max_soc=0.0, soc=30.0, soc_requirements=Energy_kWh[],
    )
    ves = VirtualEnvironmentSnapshot(
        timestamp=DateTime(2022,1,1),
        horizon=OptimizationHorizon(DateTime(2022,1,1), DateTime(2022,1,2), Hour(1)),
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
