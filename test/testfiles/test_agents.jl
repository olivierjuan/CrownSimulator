using Test
using Dates

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
    tvs = TimestampedVehicleSoc(timestamp=DateTime(2022,1,1), value=30.0)
    @test tvs.timestamp == DateTime(2022,1,1)
    @test tvs.value == 30.0
end
