using Test
using Dates

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
    resp = control(controller, data)
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
    @test resp.summary.total_power ≈ 10.0
end

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
