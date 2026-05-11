using Test
using Dates

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
