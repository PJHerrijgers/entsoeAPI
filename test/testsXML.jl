include("../src/xmlParser.jl")
include("../src/xmlMappings.jl")
using .xmlParser
using .xmlMappings
using DataFrames

#= 
open("data/actual_total_load.txt", "r") do f
    file = read(f)
    print(xmlParser.parse_load(file))
end

open("data/day_ahead_total_load.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_load(file)
    print(df)
end

open("data/week_ahead_total_load.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_load(file)
    print(df)
end

open("data/month_ahead_total_load.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_load(file)
    print(df)
end

open("data/year_ahead_total_load.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_load(file)
    print(df)
end

open("data/year_ahead_margin.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_load(file)
    print(df)
end

open("data/forecasted_capacity.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_transmission(file)
    print(df)
end

open("data/offered_capacity.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_transmission(file)
    print(df)
end

open("data/flowbased.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_flowbased(file)
    print(df)
end

open("data/intraday_transfer_limits.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_transmission(file)
    print(df)
end

open("data/explicit_allocation_information_capacity.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_transmission(file)
    print(df)
end
# No information found to test

open("data/explicit_allocation_information_revenue.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_price(file)
    print(df)
end

open("data/total_capacity_nominated.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_transmission(file)
    print(df)
end

open("data/total_capacity_already_allocated.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_transmission(file)
    print(df)
end

open("data/day_ahead_prices.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_price_per_unit(file)
    print(df)
end

open("data/implicit_auction_net_positions.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_transmission(file)
    print(df)
end

open("data/implicit_auction_congestion_income.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_price_per_unit(file)
    print(df)
end

open("data/total_commercial_schedules.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_transmission(file)
    print(df)
end

open("data/day_ahead_commercial_schedules.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_transmission(file)
    print(df)
end

open("data/physical_flows.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_transmission(file)
    print(df)
end

open("data/expansion_and_dismantling.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_expansion_and_dismantling(file)
    print(df)
    for i in eachcol(df)
        if isa(i, Vector{DataFrame})
            println(i)
        end
    end
end

open("data/redispatching.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_redispatching(file)
    println(df)
    for i in eachcol(df)
        if isa(i, Vector{DataFrame})
            println(i)
        end
    end
end

open("data/countertrading.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_countertrading(file)
    println(df)
    for i in eachcol(df)
        if isa(i, Vector{DataFrame})
            println(i)
        end
    end
end

open("data/congestion_costs.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_congestion_costs(file)
    println(df)
end

open("data/installed_generation_capacity_aggregated.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_installed_generation_capacity_aggregated(file)
    println(df)
end

open("data/installed_generation_capacity_per_unit.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_installed_generation_capacity_per_unit(file)
    println(df)
end

open("data/day_ahead_aggregated_generation.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_day_ahead_aggregated_generation(file)
    println(df)
end

open("data/day_ahead_generation_forecasts_wind_solar.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_generation_forecasts_wind_solar(file)
    println(df)
end

open("data/current_generation_forecasts_wind_solar.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_generation_forecasts_wind_solar(file)
    println(df)
end

open("data/intraday_generation_forecasts_wind_solar.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_generation_forecasts_wind_solar(file)
    println(df)
end
=#
open("data/aggregated_generation_per_type.txt", "r") do f
    file = read(f)
    df = xmlParser.parse_aggregated_generation_per_type(file)
    println(df)
    print(keys(df))
end