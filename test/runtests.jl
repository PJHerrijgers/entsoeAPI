include("../src/GETconstructor.jl")
using .GETconstructor
using Test
using HTTP

APIkey = "6e9d0b18-9bde-41cf-938f-c8ad9b35d97d"

@testset verbose = true "GETconstructor.jl" begin
    @testset "initialize_key" begin
        @test GETconstructor.key == ""
        @test GETconstructor.initialize_key(APIkey) == APIkey
        GETconstructor.initialize_key(APIkey)
        @test GETconstructor.key == APIkey
    end
end

GETconstructor.initialize_key(APIkey)

open("data/load_actual_test.txt", "w") do f
    write(f, GETconstructor.query_actual_total_load("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end

open("data/load_day_ahead_test.txt", "w") do f
    write(f, GETconstructor.query_day_ahead_total_load("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end

open("data/load_week_ahead_test.txt", "w") do f
    write(f, GETconstructor.query_week_ahead_total_load("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end

open("data/load_month_ahead_test.txt", "w") do f
    write(f, GETconstructor.query_month_ahead_total_load("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end

open("data/load_year_ahead_test.txt", "w") do f
    write(f, GETconstructor.query_year_ahead_total_load("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end

open("data/margin_year_ahead_test.txt", "w") do f
    write(f, GETconstructor.query_year_ahead_margin("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end
