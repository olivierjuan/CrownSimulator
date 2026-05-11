using Test
using Dates

@testset "TimestampedPrice - to_dto" begin
    price = TimestampedPrice(timestamp=DateTime(2022,1,1), value=50.0)
    dto = to_dto(price)
    @test dto["from"] == DateTime(2022,1,1)
    @test dto["price"] == 50.0
end

@testset "TimestampedPrices - constructor sorts" begin
    p1 = TimestampedPrice(timestamp=DateTime(2022,1,1,2), value=2.0)
    p2 = TimestampedPrice(timestamp=DateTime(2022,1,1), value=1.0)
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
    p1 = TimestampedPrice(timestamp=DateTime(2022,1,1,0), value=1.0)
    p2 = TimestampedPrice(timestamp=DateTime(2022,1,1,1), value=2.0)
    p3 = TimestampedPrice(timestamp=DateTime(2022,1,1,2), value=3.0)
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
    @test length(prices.current) >= 1
end

@testset "TimestampedPrices - update! no future prices" begin
    p1 = TimestampedPrice(timestamp=DateTime(2022,1,1,0), value=1.0)
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
    @test length(prices.all) >= 1
end

@testset "read_from_csv TimestampedPrices - nothing" begin
    prices = read_from_csv(TimestampedPrices, nothing)
    @test isempty(prices.all)
    @test isempty(prices.current)
end
