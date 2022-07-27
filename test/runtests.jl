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

open("data/day_ahead_prices.txt", "w") do f
    write(f, GETconstructor.query_day_ahead_prices("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end

open("data/implicit_auction_net_positions.txt", "w") do f
    write(f, GETconstructor.query_implicit_auction_net_positions_and_congestion_income("B09", "A01", "10YCZ-CEPS-----N", "201512312300", "201612312300"))
end

open("data/implicit_auction_congestion_income.txt", "w") do f
    write(f, GETconstructor.query_implicit_auction_net_positions_and_congestion_income("B10", "A01", "10YDOM-1001A083J", "201601012300", "201601022300"))
end 

open("data/total_commercial_schedules.txt", "w") do f
    write(f, GETconstructor.query_total_commercial_schedules("A05", "10YCZ-CEPS-----N", "10YSK-SEPS-----K", "201512312300", "201612312300"))
end 

open("data/day_ahead_commercial_schedules.txt", "w") do f
    write(f, GETconstructor.query_total_commercial_schedules("A01", "10YCZ-CEPS-----N", "10YSK-SEPS-----K", "201512312300", "201612312300"))
end 
# example in API documentation gives wrong results

open("data/physical_flows.txt", "w") do f
    write(f, GETconstructor.query_phyiscal_flows("10YCZ-CEPS-----N", "10YSK-SEPS-----K", "201512312300", "201612312300"))
end 

open("data/capacity_allocated_outside_EU.txt", "w") do f
    write(f, GETconstructor.query_capacity_allocated_outside_EU("A02", "A01", "10YSK-SEPS-----K", "10YUA-WEPS-----0", "201601012300", "201601022300", "A04", "1"))
end 

open("data/expansion_and_dismantling.txt", "w") do f
    write(f, GETconstructor.query_expansion_and_dismantling("10YCZ-CEPS-----N", "10YSK-SEPS-----K", "201512312300", "201612312300", "B01"))
end 
# example in API documentation gives wrong results

open("data/redispatching.txt", "w") do f
    write(f, GETconstructor.query_redispatching("10YCZ-CEPS-----N", "10YSK-SEPS-----K", "201512312300", "201612312300", "A46"))
end 
# example in API documentation gives wrong results

open("data/countertrading.txt", "w") do f
    write(f, GETconstructor.query_countertrading("10YCZ-CEPS-----N", "10YSK-SEPS-----K", "201512312300", "201612312300"))
end 
# example in API documentation gives wrong results

open("data/congestion_costs.txt", "w") do f
    write(f, GETconstructor.query_congestion_costs("10YCZ-CEPS-----N", "201512312300", "201612312300", "B03"))
end 
# example in API documentation gives wrong results

open("data/installed_generation_capacity_aggregated.txt", "w") do f
    write(f, GETconstructor.query_installed_generation_capacity_aggregated("10YCZ-CEPS-----N", "201512312300", "201612312300", "B16"))
end 
# example in API documentation gives wrong results

open("data/installed_generation_capacity_per_unit.txt", "w") do f
    write(f, GETconstructor.query_installed_generation_capacity_per_unit("10YCZ-CEPS-----N", "201512312300", "201612312300", "B02"))
end 
# ERROR WITH ENTSOE WILL BE FIXED IN THEIR NEXT UPDATE (END OF AUGUST)

open("data/day_ahead_aggregated_generation.txt", "w") do f
    write(f, GETconstructor.query_day_ahead_aggregated_generation("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end 

open("data/day_ahead_generation_forercasts_wind_solar.txt", "w") do f
    write(f, GETconstructor.query_day_ahead_generation_forecasts_wind_solar("10YCZ-CEPS-----N", "201512312300", "201612312300", "B16"))
end 

open("data/current_generation_forercasts_wind_solar.txt", "w") do f
    write(f, GETconstructor.query_current_generation_forecasts_wind_solar("10YCZ-CEPS-----N", "201512312300", "201612312300", "B16"))
end 
# example in API documentation gives wrong results

open("data/intraday_generation_forercasts_wind_solar.txt", "w") do f
    write(f, GETconstructor.query_intraday_generation_forecasts_wind_solar("10YCZ-CEPS-----N", "201512312300", "201612312300", "B16"))
end 
# example in API documentation gives wrong results

open("data/actual_generation_per_generation_unit.txt", "w") do f
    write(f, GETconstructor.query_actual_generation_per_generation_unit("10YCZ-CEPS-----N", "201512312300", "201601012300", "B02"))
end 
#  NOT POSSIBLE IN THE CURRENT VERSION OF THE RESTFUL API

open("data/aggregated_generation_per_type.txt", "w") do f
    write(f, GETconstructor.query_aggregated_generation_per_type("10YCZ-CEPS-----N", "201512312300", "201612312300", "B02"))
end 

open("data/aggregated_filling_rate.txt", "w") do f
    write(f, GETconstructor.query_aggregated_filling_rate("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end 
# example in API documentation gives wrong results

open("data/production_generation_units.txt", "w") do f
    write(f, GETconstructor.query_production_generation_units("10YCZ-CEPS-----N", "2017-01-01"))
end 
# ERROR WITH ENTSOE WILL BE FIXED IN THEIR NEXT UPDATE (END OF AUGUST)

open("data/current_balancing_state.txt", "w") do f
    write(f, GETconstructor.query_current_balancing_state("10YCZ-CEPS-----N", "201912190000", "201912190010"))
end 

open("data/balancing_energy_bids.txt", "w") do f
    write(f, GETconstructor.query_balancing_energy_bids("10YCZ-CEPS-----N", "201912161300", "201912161800", "A51"))
end
# wait for answer entsoe! 

open("data/aggregated_balancing_energy_bids.txt", "w") do f
    write(f, GETconstructor.query_aggregated_balancing_energy_bids("10YCZ-CEPS-----N", "201912161300", "201912161800", "A51"))
end 

open("data/procured_balancing_capacity.txt", "w") do f
    write(f, GETconstructor.query_procured_balancing_capacity("10YCZ-CEPS-----N", "201912312300", "202001010000"))
end 
# example in API documentation gives wrong results

open("data/crossZonal_balancing_capacity.txt", "w") do f
    write(f, GETconstructor.query_crossZonal_balancing_capacity("10YAT-APG------L","10YCH-SWISSGRIDZ" , "201912160000", "201912170000"))
end 
# example in API documentation gives wrong results

open("data/volumes_and_prices_contracted_reserves.txt", "w") do f
    write(f, GETconstructor.query_volumes_and_prices_contracted_reserves("A13", "A52", "10YCZ-CEPS-----N", "201512312300", "201601012300", "A04"))
end 
# example in API documentation gives wrong results

open("data/volumes_contracted_reserves.txt", "w") do f
    write(f, GETconstructor.query_volumes_contracted_reserves("A13", "10YCZ-CEPS-----N", "201512312300", "201601012300", "A95", "A04"))
end 
# Doesn't work with type_MarketAgreementType A13 (hourly), don't know why...

open("data/prices_contracted_reserves.txt", "w") do f
    write(f, GETconstructor.query_prices_contracted_reserves("A01", "10YCZ-CEPS-----N", "201512312300", "201601012300", "A96"))
end 
# example in API documentation gives wrong results

open("data/accepted_aggregated_offers.txt", "w") do f
    write(f, GETconstructor.query_accepted_aggregated_offers("10YCZ-CEPS-----N", "201512312300", "201612312300", "A95"))
end 

open("data/activated_balancing_energy.txt", "w") do f
    write(f, GETconstructor.query_activated_balancing_energy("10YCZ-CEPS-----N", "201512312300", "201612312300", "A96"))
end 

open("data/prices_activated_balancing_energy.txt", "w") do f
    write(f, GETconstructor.query_prices_activated_balancing_energy("10YCZ-CEPS-----N", "201512312300", "201612312300", "A96"))
end 

open("data/imbalance_prices.txt", "w") do f
    write(f, GETconstructor.query_imbalance_prices("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end 
# ZIP-FILE!!!!!!!!

open("data/total_imbalance_volumes.txt", "w") do f
    write(f, GETconstructor.query_total_imbalance_volumes("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end 
# ZIP-FILE!!!!!!!!

open("data/financial_expenses.txt", "w") do f
    write(f, GETconstructor.query_financial_expenses("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end 
# ZIP-FILE!!!!!!!!

open("data/crossBorder_balancing.txt", "w") do f
    write(f, GETconstructor.query_crossBorder_balancing("10YCZ-CEPS-----N","10YSK-SEPS-----K", "201512312300", "201601010100"))
end 
# example in API documentation gives wrong results

open("data/FCR_total_capacity.txt", "w") do f
    write(f, GETconstructor.query_FCR_total_capacity("10YEU-CONT-SYNC0", "201812312300", "201912312300"))
end 
# example in API documentation gives wrong results

open("data/share_capacity_FCR.txt", "w") do f
    write(f, GETconstructor.query_share_capacity_FCR("10YDE-VE-------2", "201912312300", "202012312300"))
end 
# example in API documentation gives wrong results

open("data/contracted_reserve_capacity_FCR.txt", "w") do f
    write(f, GETconstructor.query_contracted_reserve_capacity_FCR("10YDE-RWENET---I", "201912312300", "202012312300"))
end 
# example in API documentation gives wrong results

open("data/FRR_actual_capacity.txt", "w") do f
    write(f, GETconstructor.query_FRR_actual_capacity("10YAT-APG------L", "201912312300", "202003312200"))
end 
# example in API documentation gives wrong results

open("data/RR_actual_capacity.txt", "w") do f
    write(f, GETconstructor.query_RR_actual_capacity("10YAT-APG------L", "201912312300", "202003312200"))
end 
# example in API documentation gives wrong results

open("data/sharing_of_reserves.txt", "w") do f
    write(f, GETconstructor.query_sharing_of_reserves("A56", "10YCB-GERMANY--8", "10YAT-APG------L", "201912312300", "202012312200"))
end 
# example in API documentation gives wrong results

open("data/balancing_border_capacity_limitations.txt", "w") do f
    write(f, GETconstructor.query_balancing_border_capacity_limitations())
end
# STILL NEEDS TO BE TESTED 

open("data/permanent_allocation_limitations_HVDC.txt", "w") do f
    write(f, GETconstructor.query_permanent_allocation_limitations_HVDC())
end 
# STILL NEEDS TO BE TESTED

open("data/netted_and_exchanged_volumes.txt", "w") do f
    write(f, GETconstructor.query_netted_and_exchanged_volumes())
end 
# STILL NEEDS TO BE TESTED

open("data/unavailability_consumption_units.txt", "w") do f
    write(f, GETconstructor.query_unavailability_consumption_units("10YCZ-CEPS-----N", "201512312300", "201612312300"))
end 
# example in API documentation gives wrong results

open("data/unavailability_generation_units.txt", "w") do f
    write(f, GETconstructor.query_unavailability_generation_units("10YCZ-CEPS-----N", "201512312300", "201601052300"))
end 
# ZIP-FILE!!!!!!!!!!!!

open("data/unavailability_production_units.txt", "w") do f
    write(f, GETconstructor.query_unavailability_production_units("10YCZ-CEPS-----N", "201512312300", "201601052300"))
end 
# ZIP-FILE!!!!!!!!!!!!

open("data/unavailability_offshore_grid.txt", "w") do f
    write(f, GETconstructor.query_unavailability_offshore_grid("10YDE-EON------1", "201512312300", "201612312300"))
end 
# ZIP-FILE!!!!!!!!!!!!

open("data/unavailability_transmission_infrastructure.txt", "w") do f
    write(f, GETconstructor.query_unavailability_transmission_infrastructure("10YCZ-CEPS-----N", "10YSK-SEPS-----K", "201512312300", "201601312300"))
end 
# example in API documentation geives wrong results

open("data/fallBacks.txt", "w") do f
    write(f, GETconstructor.query_fallBacks())
end 
# STILL NEEDS TO BE TESTED
=#

