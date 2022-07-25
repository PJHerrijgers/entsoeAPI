include("../src/GETconstructor.jl")
include("../src/mappings.jl")
using .GETconstructor
using .mappings
using Test
using HTTP

APIkey = "6e9d0b18-9bde-41cf-938f-c8ad9b35d97d"

#= 
@testset verbose = true "GETconstructor.jl" begin
    @testset "initialize_key" begin
        @test GETconstructor.key == ""
        @test GETconstructor.initialize_key(APIkey) == APIkey
        GETconstructor.initialize_key(APIkey)
        @test GETconstructor.key == APIkey
    end
end


@testset verbose = true "mappings.jl" begin
    @testset "mapping with country code" begin
        @test mappings.lookup_area("NO") == mappings.NO
        @test mappings.lookup_area("BE") == mappings.BE
    end
    @testset "mapping with Area object" begin
        @test mappings.lookup_area(mappings.NO) == mappings.NO
        @test mappings.lookup_area(mappings.BE) == mappings.BE
    end
    @testset "mapping with direct code" begin
        @test mappings.lookup_area("10YBE----------2") == mappings.BE
        @test mappings.lookup_area("10YNO-0--------C") == mappings.NO
    end
end
=#


GETconstructor.initialize_key(APIkey)

#= 

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

open("data/forecasted_capacity.txt", "w") do f
    write(f, GETconstructor.query_forecasted_capacity("A01", "10YCZ-CEPS-----N", "10YSK-SEPS-----K", "201512312300", "201612312300"))
end

open("data/offered_capacity.txt", "w") do f
    write(f, GETconstructor.query_offered_capacity("A01", "A01", "10YSK-SEPS-----K", "10YCZ-CEPS-----N", "201601012300", "201601022300"))
end

open("data/flowbased.txt", "w") do f
    write(f, GETconstructor.query_flowbased("A01", "10YDOM-REGION-1V", "10YDOM-REGION-1V", "201512312300", "201601012300"))
end

open("data/intraday_transfer_limits.txt", "w") do f
    write(f, GETconstructor.query_intraday_transfer_limits("10YFR-RTE------C", "10YGB----------A", "201512312300", "201601312300"))
end
# example in API documentation gives wrong results

open("data/explicit_allocation_information_capacity.txt", "w") do f
    write(f, GETconstructor.query_explicit_allocation_information_capacity("B05", "A01", "10YSK-SEPS-----K", "10YCZ-CEPS-----N", "201601012300", "201601022300", "A01", "1"))
end
# example in API documentation gives wrong results

open("data/explicit_allocation_information_revenue.txt", "w") do f
    write(f, GETconstructor.query_explicit_allocation_information_revenue("A01", "10YAT-APG------L", "10YCZ-CEPS-----N", "201601012300", "201601022300"))
end
# example in API documentation gives wrong results

open("data/total_capacity_nominated.txt", "w") do f
    write(f, GETconstructor.query_total_capacity_nominated("10YCZ-CEPS-----N", "10YSK-SEPS-----K", "201512312300", "201612312300"))
end

open("data/total_capacity_already_allocated.txt", "w") do f
    write(f, GETconstructor.query_total_capacity_already_allocated("A07", "10YSK-SEPS-----K", "10YCZ-CEPS-----N", "201601012300", "201601022300"))
end
=#
open("data/day_ahead_prices.txt", "w") do f
    write(f, GETconstructor.query_day_ahead_prices("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end

open("data/implicit_auction_net_positions.txt", "w") do f
    write(f, GETconstructor.query_implicit_auction_net_positions_and_congestion_income("B09", "A01", "10YCZ-CEPS-----N", "201512312300", "201612312300"))
end

open("data/implicit_auction_congestion_income.txt", "w") do f
    write(f, GETconstructor.query_implicit_auction_net_positions_and_congestion_income("B10", "A01", "10YDOM-1001A083J", "201601012300", "201601022300"))
end 