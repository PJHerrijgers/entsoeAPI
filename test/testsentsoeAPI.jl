include("../src/entsoeAPI.jl")
include("../src/mappings.jl")
include("../src/argumentLimitations.jl")
using .entsoeAPI
using .mappings
using .argumentLimitations
using Test
using HTTP
using Dates
using TimeZones

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
    @testset "DateTimeTranslator" begin
        @test mappings.DateTimeTranslator(ZonedDateTime(2000,1,1,0,0,0,0, tz"UTC")) == "200001010000"
        @test mappings.DateTimeTranslator(ZonedDateTime(2000,1,1,0,0,0, tz"UTC")) == "200001010000"
        @test mappings.DateTimeTranslator(ZonedDateTime(2000,1,1,0,0, tz"UTC")) == "200001010000"
        @test mappings.DateTimeTranslator(ZonedDateTime(2000,1,1,0, tz"UTC")) == "200001010000"
        @test mappings.DateTimeTranslator(ZonedDateTime(2000,1,1, tz"UTC")) == "200001010000"

        @test mappings.DateTimeTranslator(ZonedDateTime(2017,12,25,23,45, tz"UTC")) == "201712252345"
    end
end
=#


entsoeAPI.initialize_key(APIkey)


println(entsoeAPI.actual_total_load("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))

println(entsoeAPI.day_ahead_total_load("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))

println(entsoeAPI.week_ahead_total_load("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))

println(entsoeAPI.month_ahead_total_load("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))

println(entsoeAPI.year_ahead_total_load("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))

println(entsoeAPI.year_ahead_margin("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))

println(entsoeAPI.forecasted_capacity("A01", "10YCZ-CEPS-----N", "10YSK-SEPS-----K", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))

println(entsoeAPI.offered_capacity("A01", "A01", "10YSK-SEPS-----K", "10YCZ-CEPS-----N", DateTime(2016,01,01,23,00), DateTime(2016,01,02,23,00)))

println(entsoeAPI.flowbased("A01", "10YDOM-REGION-1V", DateTime(2015,12,31,23,00), DateTime(2016,01,01,23,00)))

println(entsoeAPI.intraday_transfer_limits("10YFR-RTE------C", "10YGB----------A", DateTime(2015,12,31,23,00), DateTime(2016,01,31,23,00)))
# example in API documentation gives wrong results

println(entsoeAPI.explicit_allocation_information_capacity("B05", "A01", "10YCZ-CEPS-----N", "PL", DateTime(2016,01,01,23,00), DateTime(2016,01,02,23,00), "A01", "1"))
# example in API documentation gives wrong results

println(entsoeAPI.explicit_allocation_information_revenue("A01", "10YCZ-CEPS-----N", "10YAT-APG------L", DateTime(2016,01,01,23,00), DateTime(2016,01,02,23,00)))
# example in API documentation gives wrong results

println(entsoeAPI.total_capacity_nominated("10YCZ-CEPS-----N", "10YSK-SEPS-----K", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))

println(entsoeAPI.total_capacity_already_allocated("A07", "HU", "AT", DateTime(2016,01,01,23,00), DateTime(2016,01,02,23,00)))

println(entsoeAPI.day_ahead_prices("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))

println(entsoeAPI.implicit_auction_net_positions("B09", "A01", "10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))

println(entsoeAPI.implicit_auction_congestion_income("B10", "A01", "ES_FR", DateTime(2016,01,01,23,00), DateTime(2016,01,02,23,00)))

println(entsoeAPI.total_commercial_schedules("A05", "10YCZ-CEPS-----N", "10YSK-SEPS-----K", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))

println(entsoeAPI.total_commercial_schedules("A01", "10YCZ-CEPS-----N", "PL", DateTime(2020,12,31,23,00), DateTime(2021,12,31,23,00)))
# example in API documentation gives wrong results

println(entsoeAPI.phyiscal_flows("10YCZ-CEPS-----N", "PL", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))

println(entsoeAPI.capacity_allocated_outside_EU("A02", "A01", "10YUA-WEPS-----0", "10YSK-SEPS-----K", DateTime(2016,01,01,23,00), DateTime(2016,01,02,23,00), "A04", "1"))

println(entsoeAPI.expansion_and_dismantling("10YHU-MAVIR----U", "10YRO-TEL------P", DateTime(2020,12,31,23,00), DateTime(2021,12,31,23,00), "B01"))
# example in API documentation gives wrong results

println(entsoeAPI.redispatching("NL", "BE", DateTime(2016,12,30,23,00), DateTime(2017,12,30,23,00), "A46"))
# example in API documentation gives wrong results

println(entsoeAPI.countertrading("ES", "FR", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))
# example in API documentation gives wrong results

println(entsoeAPI.congestion_costs("10YDE-VE-------2", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00), "B03"))
# example in API documentation gives wrong results

println(entsoeAPI.installed_generation_capacity_aggregated("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))
# example in API documentation gives wrong results

#=
println(entsoeAPI.installed_generation_capacity_per_unit("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00), "B02"))
# ERROR WITH ENTSOE WILL BE FIXED IN THEIR NEXT UPDATE (END OF AUGUST)
=#

println(entsoeAPI.day_ahead_aggregated_generation("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,01,01,23,00)))

println(entsoeAPI.day_ahead_generation_forecasts_wind_solar("BE", DateTime(2015,12,31,23,00), DateTime(2016,01,01,23,00)))

println(entsoeAPI.current_generation_forecasts_wind_solar("BE", DateTime(2020,12,31,23,00), DateTime(2021,01,01,23,00)))
# example in API documentation gives wrong results

println(entsoeAPI.intraday_generation_forecasts_wind_solar("BE", DateTime(2020,12,31,23,00), DateTime(2021,01,01,23,00)))
# example in API documentation gives wrong results

#=
println(entsoeAPI.actual_generation_per_generation_unit("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,01,01,23,00), "B02"))
#  NOT POSSIBLE IN THE CURRENT VERSION OF THE RESTFUL API
=#

println(entsoeAPI.aggregated_generation_per_type("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,01,01,23,00)))

println(entsoeAPI.aggregated_filling_rate("PT", DateTime(2020,12,31,23,00), DateTime(2021,12,31,23,00)))
# example in API documentation gives wrong results

#=
println(entsoeAPI.production_generation_units("10YCZ-CEPS-----N", DateTime(2017,01,01)))
# ERROR WITH ENTSOE WILL BE FIXED IN THEIR NEXT UPDATE (END OF AUGUST)
=#

println(entsoeAPI.current_balancing_state("BE", DateTime(2021,01,01,00,00), DateTime(2021,01,01,01,00)))

#=
println(entsoeAPI.balancing_energy_bids("10YCZ-CEPS-----N", DateTime(2019,12,16,13,00), DateTime(2019,12,16,18,00), "A51"))
# NOT POSSIBLE WITH API!
=# 

println(entsoeAPI.aggregated_balancing_energy_bids("SI", DateTime(2020,12,16,13,00), DateTime(2020,12,16,18,00), "A51"))

#=
println(entsoeAPI.procured_balancing_capacity("10YCZ-CEPS-----N", DateTime(2019,12,31,23,00), DateTime(2020,01,01,00,00)))

println(entsoeAPI.crossZonal_balancing_capacity("10YAT-APG------L","10YCH-SWISSGRIDZ" , DateTime(2019,12,16,00,00), DateTime(2019,12,17,00,00)))
# THERE EXISTS NO DATA FOR THIS ONE IT SEEMS?

println(entsoeAPI.volumes_and_prices_contracted_reserves("A13", "A52", "10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,01,01,23,00), "A04"))
# THERE EXISTS NO DATA FOR THIS ONE IT SEEMS?
# FOUND FOR SLOVENIA 
=#

println(entsoeAPI.volumes_contracted_reserves("A01", "NL", DateTime(2019,12,31,23,00), DateTime(2020,02,29,23,00)))
# Doesn't work with type_MarketAgreementType A13 (hourly), don't know why...

println(entsoeAPI.prices_contracted_reserves("A01", "10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,01,01,23,00), "A96"))
# example in API documentation gives wrong results

println(entsoeAPI.accepted_aggregated_offers("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00), "A96"))

println(entsoeAPI.activated_balancing_energy("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00), "A96"))

println(entsoeAPI.prices_activated_balancing_energy("PL", DateTime(2015,12,31,23,00), DateTime(2016,01,01,23,00)))

#=
println(entsoeAPI.imbalance_prices("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))
# ZIP-FILE!!!!!!!!
=#
#=
println(entsoeAPI.total_imbalance_volumes("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))
# ZIP-FILE!!!!!!!! 
# Doesn't work yet due to multiple xml files
=#

println(entsoeAPI.financial_expenses("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))
# ZIP-FILE!!!!!!!!



#=
println(entsoeAPI.crossBorder_balancing("HR","BA", DateTime(2020,11,30,23,00), DateTime(2020,12,01,23,00)))
# example in API documentation gives wrong results

println(entsoeAPI.FCR_total_capacity("10YEU-CONT-SYNC0", DateTime(2018,12,31,23,00), DateTime(2019,12,31,23,00)))
# example in API documentation gives wrong results

println(entsoeAPI.share_capacity_FCR("10YDE-VE-------2", DateTime(2019,12,31,23,00), DateTime(2020,12,31,23,00)))
# example in API documentation gives wrong results

println(entsoeAPI.contracted_reserve_capacity_FCR("10YDE-RWENET---I", DateTime(2019,12,31,23,00), DateTime(2020,12,31,23,00)))
# example in API documentation gives wrong results

println(entsoeAPI.FRR_actual_capacity("10YAT-APG------L", DateTime(2019,12,31,23,00), DateTime(2020,03,31,22,00)))
# example in API documentation gives wrong results

println(entsoeAPI.RR_actual_capacity("10YAT-APG------L", DateTime(2019,12,31,23,00), DateTime(2020,03,31,22,00)))
# example in API documentation gives wrong results

println(entsoeAPI.sharing_of_reserves("A56", "10YCB-GERMANY--8", "10YAT-APG------L", DateTime(2019,12,31,23,00), DateTime(2020,12,31,22,00)))
# example in API documentation gives wrong results

println(entsoeAPI.unavailability_consumption_units("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))
# example in API documentation gives wrong results

println(entsoeAPI.unavailability_generation_units("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,01,05,23,00)))
# ZIP-FILE!!!!!!!!!!!!

println(entsoeAPI.unavailability_production_units("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,01,05,23,00)))
# ZIP-FILE!!!!!!!!!!!!

println(entsoeAPI.unavailability_offshore_grid("10YDE-EON------1", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00)))
# ZIP-FILE!!!!!!!!!!!!

println(entsoeAPI.unavailability_transmission_infrastructure("10YCZ-CEPS-----N", "10YSK-SEPS-----K", DateTime(2015,12,31,23,00), DateTime(2016,01,31,23,00)))
# example in API documentation geives wrong results

println(entsoeAPI.balancing_border_capacity_limitations())
# STILL NEEDS TO BE TESTED 

println(entsoeAPI.permanent_allocation_limitations_HVDC())
# STILL NEEDS TO BE TESTED

println(entsoeAPI.netted_and_exchanged_volumes())
# STILL NEEDS TO BE TESTED

println(entsoeAPI.fallBacks())
# STILL NEEDS TO BE TESTED
=#
