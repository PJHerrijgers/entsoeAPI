include("../src/xmlParser.jl")
include("../src/xmlMappings.jl")
using .xmlParser
using .xmlMappings
using DataFrames

#= 
open("data/actual_total_load.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_actual_total_load(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/day_ahead_total_load.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_day_ahead_total_load(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/week_ahead_total_load.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_week_ahead_total_load(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/month_ahead_total_load.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_load_monthYear_ahead(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/year_ahead_total_load.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_load_monthYear_ahead(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/year_ahead_margin.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_year_ahead_margin(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/forecasted_capacity.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_forecasted_capacity(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/offered_capacity.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_offered_capacity(file, TimeZone("Europe/Bratislava"))
    print(df)
end

open("data/flowbased.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_flowbased(file, TimeZone("Europe/Brussels"))
    print(df)
end

open("data/intraday_transfer_limits.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_intraday_transfer_limits(file, TimeZone("Europe/Paris"))
    print(df)
end

open("data/explicit_allocation_information_capacity.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_explicit_allocation_information_capacity(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/explicit_allocation_information_revenue.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_explicit_allocation_information_revenue(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/total_capacity_nominated.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_total_capacity_nominated(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/total_capacity_already_allocated.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_total_capacity_already_allocated(file, TimeZone("Europe/Budapest"))
    print(df)
end

open("data/day_ahead_prices.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_day_ahead_prices(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/implicit_auction_net_positions.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_implicit_auction_net_positions(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/implicit_auction_congestion_income.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_implicit_auction_congestion_income(file, TimeZone("Europe/Madrid"))
    print(df)
end

open("data/total_commercial_schedules.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_total_commercial_schedules(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/day_ahead_commercial_schedules.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_day_ahead_commercial_schedules(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/physical_flows.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_physical_flows(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/capacity_allocated_outside_EU.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_capacity_allocated_outside_EU(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/expansion_and_dismantling.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_expansion_and_dismantling(file, TimeZone("Europe/Budapest"))
    print(df)
    for i in eachcol(df)
        if isa(i, Vector{DataFrame})
            println(i)
        end
    end
end

open("data/redispatching.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_redispatching(file, TimeZone("Europe/Amsterdam"))
    println(df)
    for i in eachcol(df)
        if isa(i, Vector{DataFrame})
            println(i)
        end
    end
end

open("data/countertrading.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_countertrading(file, TimeZone("Europe/Madrid"))
    println(df)
    for i in eachcol(df)
        if isa(i, Vector{DataFrame})
            println(i)
        end
    end
end

open("data/congestion_costs.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_congestion_costs(file, TimeZone("Europe/Berlin"))
    println(df)
end

open("data/installed_generation_capacity_aggregated.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_installed_generation_capacity_aggregated(file, TimeZone("Europe/Prague"))
    println(df)
end

open("data/installed_generation_capacity_per_unit.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_installed_generation_capacity_per_unit(file)
    println(df)
end

open("data/day_ahead_aggregated_generation.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_day_ahead_aggregated_generation(file, TimeZone("Europe/Prague"))
    println(df)
end

open("data/day_ahead_generation_forecasts_wind_solar.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_day_ahead_generation_forecasts_wind_solar(file, TimeZone("Europe/Brussels"))
    println(df)
end

open("data/current_generation_forecasts_wind_solar.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_current_generation_forecasts_wind_solar(file, TimeZone("Europe/Brussels"))
    println(df)
end

open("data/intraday_generation_forecasts_wind_solar.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_intraday_generation_forecasts_wind_solar(file, TimeZone("Europe/Brussels"))
    println(df)
end

open("data/actual_generation_per_generation_unit.txt", "r") do F
    file = read(f)
    df = xmlParser.parse_actual_generation_per_generation_unit(file, TimeZone())
    print(df)
end
# STILL NEEDS TO BE TESTED

open("data/aggregated_generation_per_type.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_aggregated_generation_per_type(file, TimeZone("Europe/Prague"))
    println(df)
    print(keys(df))
end

open("data/aggregated_filling_rate.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_aggregated_filling_rate(file, TimeZone("Europe/Lisbon"))
    println(df)
end

open("data/production_generation_units.txt", "r") do F
    file = read(f)
    df = xmlParser.parse_production_generation_units(file, TimeZone())
    print(df)
end
# STILL NEEDS TO BE TESTED

open("data/current_balancing_state.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_current_balancing_state(file, TimeZone("Europe/Brussels"))
    println(df)
end

open("data/balancing_energy_bids.txt", "r") do f 
    file = read(f)
    df = xmlParser.parse_balancing_energy_bids(file, TimeZone())
    print(df)
end

open("data/aggregated_balancing_energy_bids.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_aggregated_balancing_energy_bids(file, TimeZone("Europe/Prague"))
    println(df)
end

open("data/procured_balancing_capacity.txt", "r") do f 
    file = read(f)
    df = xmlParser.parse_procured_balancing_capacity(file, TimeZone())
    println(df)
end
# STILL NEEDS TO BE TESTED (SITE CRASHES OFTEN)

open("data/crossZonal_balancing_capacity.txt", "r") do f 
    file = read(f)
    df = xmlParser.parse_crossZonal_balancing_capacity(file, TimeZone())
    print(df)
end
# STILL NEEDS TO BE TESTED 

open("data/volumes_and_prices_contracted_reserves.txt", "r") do f 
    file = read(f)
    df = xmlParser.parse_volumes_and_prices_contracted_reserves(file, TimeZone())
    print(df)
end
# STILL NEEDS TO BE TESTED

open("data/volumes_contracted_reserves.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_volumes_contracted_reserves(file, TimeZone("Europe/Amsterdam"))
    println(df)
end

open("data/prices_contracted_reserves.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_prices_contracted_reserves(file, TimeZone("Europe/Prague"))
    println(df)
end

open("data/accepted_aggregated_offers.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_accepted_aggregated_offers(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/activated_balancing_energy.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_activated_balancing_energy(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/prices_activated_balancing_energy.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_prices_activated_balancing_energy(file, TimeZone("Europe/Warsaw"))
    print(df)
end

open("data/imbalance_prices.txt", "r") do f 
    file = read(f)
    df = xmlParser.parse_imbalance_prices(file, TimeZone())
    print(df)
end
# STILL NEEDS TO BE TESTED
# NOT ENOUGH DATA SO CAN'T BE TESTED

open("data/total_imbalance_volumes.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_total_imbalance_volumes(file, TimeZone("Europe/Prague"))
    print(df)
end
# PROBLEM WITH FILE, CAN'T BE READ 

open("data/financial_expenses.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_financial_expenses(file, TimeZone("Europe/Prague"))
    print(df)
end

open("data/crossBorder_balancing.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_crossBorder_balancing(file, TimeZone("Europe/Prague"))
    print(df)
end
# STILL NEEDS TO BE TESTED

open("data/FCR_total_capacity.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_FCR_total_capacity(file, TimeZone("Europe/Brussels"))
    print(df)
end 
# STILL NEEDS TO BE TESTED

open("data/share_capacity_FCR.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_share_capacity_FCR(file, TimeZone("Europe/Berlin"))
    print(df)
end 
# STILL NEEDS TO BE TESTED

open("data/contracted_reserve_capacity_FCR.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_contracted_reserve_capacity_FCR(file, TimeZone("Europe/Berlin"))
    print(df)
end 
# STILL NEEDS TO BE TESTED

open("data/FRR_actual_capacity.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_FRR_actual_capacity(file, TimeZone("Europe/Vienna"))
    print(df)
end 
# STILL NEEDS TO BE TESTED

open("data/RR_actual_capacity.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_RR_actual_capacity(file, TimeZone("Europe/Vienna"))
    print(df)
end 
# STILL NEEDS TO BE TESTED

open("data/sharing_of_reserves.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_sharing_of_reserves(file, TimeZone("Europe/Berlin"))
    print(df)
end 
# STILL NEEDS TO BE TESTED

open("data/unavailability_consumption_units.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_unavailability_consumption_units(file, TimeZone("Europe/Prague"))
    print(df)
end 
# STILL NEEDS TO BE TESTED

open("data/unavailability_generation_units.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_unavailability_generation_units(file, TimeZone("Europe/Prague"))
    print(df)
end 
# STILL NEEDS TO BE TESTED

open("data/unavailability_production_units.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_unavailability_production_units(file, TimeZone("Europe/Prague"))
    print(df)
end 
# STILL NEEDS TO BE TESTED

open("data/unavailability_offshore_grid.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_unavailability_offshore_grid(file, TimeZone("Europe/Berlin"))
    print(df)
end 
# STILL NEEDS TO BE TESTED

open("data/unavailability_transmission_infrastructure.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_unavailability_transmission_infrastructure(file, TimeZone("Europe/Prague"))
    print(df)
end 
# STILL NEEDS TO BE TESTED

open("data/balancing_border_capacity_limitations.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_balancing_border_capacity_limitation(file, TimeZone())
    print(df)
end
# STILL NEEDS TO BE TESTED 

open("data/permanent_allocation_limitations_HVDC.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_permanent_allocation_limitations_HVDC(file, TimeZone())
    print(df)
end 
# STILL NEEDS TO BE TESTED

open("data/netted_and_exchanged_volumes.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_netted_and_exchanged_volumes(file, TimeZone())
    print(df)
end 
# STILL NEEDS TO BE TESTED

open("data/fallBacks.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_fallBacks(file, TimeZone())
    print(df)
end 
# STILL NEEDS TO BE TESTED
=#
