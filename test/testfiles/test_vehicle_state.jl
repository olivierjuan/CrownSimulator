using Test
using Dates

function _make_test_model()
    VehicleModel(
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
end

function _make_test_vehicle(model=nothing; soc=30.0, connected=true, power=0.0, noise=0.0)
    m = model === nothing ? _make_test_model() : model
    VehicleState(
        id_="v1", site_id="s1", model=m, soc=soc,
        previous_soc=soc, power=power, noise=noise,
        connected=connected, evse_id=connected ? "evse_1" : nothing,
    )
end

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
    vs = _make_test_vehicle(model)
    @test vs.id_ == "v1"
    @test vs.soc == 30.0
    @test vs.connected == true
end

@testset "compute_vehicle_soc_update - charging" begin
    vs = _make_test_vehicle()
    # 11kW for 3600s = 1 hour = 11 kWh added
    new_soc = compute_vehicle_soc_update(vs, 11.0, 0.0, 3600.0)
    @test new_soc ≈ 41.0
end

@testset "compute_vehicle_soc_update - discharging" begin
    vs = _make_test_vehicle()
    # -5kW for 3600s = 5 kWh removed
    new_soc = compute_vehicle_soc_update(vs, -5.0, 0.0, 3600.0)
    @test new_soc ≈ 25.0
end

@testset "compute_vehicle_soc_update - clamp to capacity" begin
    vs = _make_test_vehicle(soc=55.0)
    new_soc = compute_vehicle_soc_update(vs, 11.0, 0.0, 3600.0)
    @test new_soc ≈ 60.0
end

@testset "compute_vehicle_soc_update - clamp to zero" begin
    vs = _make_test_vehicle(soc=2.0)
    new_soc = compute_vehicle_soc_update(vs, -5.0, 0.0, 3600.0)
    @test new_soc ≈ 0.0
end

@testset "compute_vehicle_soc_update - with noise" begin
    vs = _make_test_vehicle()
    new_soc = compute_vehicle_soc_update(vs, 10.0, 1.0, 3600.0)
    @test new_soc ≈ 41.0
end

@testset "batch_vehicle_soc_update! - connected vehicle" begin
    model = _make_test_model()
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

# --- Additional edge case tests ---

@testset "compute_vehicle_soc_update - zero power" begin
    vs = _make_test_vehicle()
    new_soc = compute_vehicle_soc_update(vs, 0.0, 0.0, 3600.0)
    @test new_soc ≈ 30.0
end

@testset "compute_vehicle_soc_update - zero delta_t" begin
    vs = _make_test_vehicle()
    new_soc = compute_vehicle_soc_update(vs, 11.0, 0.0, 0.0)
    @test new_soc ≈ 30.0
end

@testset "compute_vehicle_soc_update - negative delta_t throws" begin
    vs = _make_test_vehicle()
    @test_throws ArgumentError compute_vehicle_soc_update(vs, 11.0, 0.0, -1.0)
end

@testset "compute_vehicle_soc_update - with power losses" begin
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
    vs = _make_test_vehicle(model)
    new_soc = compute_vehicle_soc_update(vs, 11.0, 0.0, 3600.0)
    # useful power = (11.0 - 0.5) * (1 - 0.05) = 10.5 * 0.95 = 9.975
    @test new_soc ≈ 39.975
end

@testset "compute_vehicle_soc_update - discharging with losses" begin
    model = VehicleModel(
        capacity=60.0,
        min_soc=5.0,
        max_soc=55.0,
        max_ac_charge_power=11.0,
        max_dc_charge_power=50.0,
        power_losses=PowerLosses(
            standby=0.0,
            variable=VariablePowerLosses(charging=0.0, discharging=0.05),
        ),
    )
    vs = _make_test_vehicle(model, soc=50.0)
    new_soc = compute_vehicle_soc_update(vs, -10.0, 0.0, 3600.0)
    # useful power = -10.0 / (1 - 0.05) = -10.526...
    @test new_soc ≈ 50.0 - 10.0 / 0.95
end

@testset "batch_vehicle_soc_update! - mixed connected/disconnected" begin
    model = _make_test_model()
    v1 = VehicleState(id_="v1", site_id="s1", model=model, soc=30.0,
        previous_soc=30.0, power=10.0, noise=0.0,
        connected=true, evse_id="evse_1")
    v2 = VehicleState(id_="v2", site_id="s1", model=model, soc=20.0,
        previous_soc=20.0, power=5.0, noise=0.0,
        connected=false, evse_id=nothing)
    v3 = VehicleState(id_="v3", site_id="s1", model=model, soc=50.0,
        previous_soc=50.0, power=8.0, noise=0.0,
        connected=true, evse_id="evse_2")
    vehicles = [v1, v2, v3]
    batch_vehicle_soc_update!(vehicles, 3600.0)
    @test v1.soc ≈ 40.0
    @test v2.soc == 20.0
    @test v3.soc ≈ 58.0
end

@testset "batch_vehicle_soc_update! - large batch" begin
    model = _make_test_model()
    vehicles = [VehicleState(
        id_="v$i", site_id="s1", model=model, soc=10.0,
        previous_soc=10.0, power=5.0, noise=0.0,
        connected=true, evse_id="evse_1",
    ) for i in 1:100]
    batch_vehicle_soc_update!(vehicles, 3600.0)
    for v in vehicles
        @test v.soc ≈ 15.0
    end
end
