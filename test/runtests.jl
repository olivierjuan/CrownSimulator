using Test
using Dates
using Interpolations

using CachedCrownSim

@testset "CachedCrownSim Test Suite" begin

    @testset "Timestamps" begin
        include("testfiles/test_timestamps.jl")
    end

    @testset "Power" begin
        include("testfiles/test_power.jl")
    end

    @testset "Prices" begin
        include("testfiles/test_prices.jl")
    end

    @testset "Network" begin
        include("testfiles/test_network.jl")
    end

    @testset "Services Request" begin
        include("testfiles/test_services_request.jl")
    end

    @testset "EVSE Model" begin
        include("testfiles/test_evse_model.jl")
    end

    @testset "Vehicle Model" begin
        include("testfiles/test_vehicle_model.jl")
    end

    @testset "Delivery Point" begin
        include("testfiles/test_delivery_point.jl")
    end

    @testset "Agents" begin
        include("testfiles/test_agents.jl")
    end

    @testset "Optimization" begin
        include("testfiles/test_optimization.jl")
    end

    @testset "Snapshot" begin
        include("testfiles/test_snapshot.jl")
    end

    @testset "Vehicle State & SoC Update" begin
        include("testfiles/test_vehicle_state.jl")
    end

    @testset "Energy Need" begin
        include("testfiles/test_energy_need.jl")
    end

    @testset "Trips" begin
        include("testfiles/test_trips.jl")
    end

    @testset "Mobility" begin
        include("testfiles/test_mobility.jl")
    end

    @testset "Bidding Service" begin
        include("testfiles/test_bidding_service.jl")
    end

    @testset "Droop Controller" begin
        include("testfiles/test_droop_controller.jl")
    end

    @testset "Simulation" begin
        include("testfiles/test_simulation.jl")
    end

    @testset "Edge Cases" begin
        include("testfiles/test_edge_cases.jl")
    end

    @testset "Constants" begin
        include("testfiles/test_constants.jl")
    end

end
