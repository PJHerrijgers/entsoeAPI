"""
Parses xml file into FORMAT
"""
module xmlParser

include("xmlMappings.jl")
using .xmlMappings
using DataFrames
using Dates
using TimeZones
using LightXML

function prepare_file(xml)
    open("data/temp.xml", "w") do f
        write(f, xml)
    end
    xdoc = parse_file("data/temp.xml")
    root = LightXML.root(xdoc)
    return root
end

function check_if_file_contains_data(root)
    reason = find_element(root, "Reason")
    if reason !== nothing
        if content(find_element(reason, "code")) == "999"
            return false, content(find_element(reason, "text"))
        end
    end
    timeSeries = find_element(root, "TimeSeries")
    if timeSeries === nothing
        return false, "No information available"
    end
    return true, true
end

function start_end_resolution(period, tz)
    timeInterval = find_element(period, "timeInterval")
            
    resolution = content(find_element(period, "resolution"))
    resolution = xmlMappings.RESOLUTION[resolution]

    start = find_element(timeInterval, "start")
    start = DateTime(content(start), dateformat"yyyy-mm-ddTHH:MMz")
    start = ZonedDateTime(start, tz, from_utc = true)
    ennd = find_element(timeInterval, "end")
    ennd = DateTime(content(ennd), dateformat"yyyy-mm-ddTHH:MMz")
    ennd = ZonedDateTime(ennd, tz, from_utc = true)

    return start, ennd, resolution
end

function base_parse_amount(df, root, tz)
    unit = ""

    for child in child_elements(root)
        if name(child) == "TimeSeries"
            unit = content(find_element(child, "quantity_Measure_Unit.name"))

            period = find_element(child, "Period")
            start, ennd, resolution = start_end_resolution(period, tz)
    
            for grandchild in child_elements(period)
                if name(grandchild) == "Point"
                    position = parse(Int, content(find_element(grandchild, "position")))
                    time = (position-1)*resolution + start
                    value = parse(Int, content(find_element(grandchild, "quantity")))
                    push!(df,(time, value))
                end
            end
        end
    end            
    return df, unit
end

function base_parse_min_max_load(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else 
        df = Dict()
        dff = DataFrame(time = ZonedDateTime[], load = Int[])
        dfff = DataFrame(time = ZonedDateTime[], load = Int[])

        unit1 = ""
        unit2 = ""

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))
    
                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)
    
                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        value = parse(Float64, content(find_element(grandchild, "quantity")))
                        if content(find_element(child, "businessType")) == "A60"
                            push!(dff,(time, value))
                            unit1 = unit
                        else
                            push!(dfff,(time, value))
                            unit2 = unit
                        end
                    end
                end
            end
        end  
        rename!(dff,"load" => "load ["*unit1*"]")
        rename!(dfff,"load" => "load ["*unit2*"]")
        df["min total load"] = dff
        df["max total load"] = dfff
        return df
    end
end

function base_parse_price(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = DataFrame(times = ZonedDateTime[], price = Float64[])
        unit = ""
        unit2 = nothing

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "currency_Unit.name"))

                if find_element(child, "price_Measure_Unit.name") !== nothing
                    unit2 = content(find_element(child, "price_Measure_Unit.name"))
                end

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        value = parse(Float64, content(find_element(grandchild, "price.amount")))
                        push!(df,(time, value))
                    end
                end
            end
        end  
        if unit2 === nothing  
            rename!(df,"price" => "price ["*unit*"]")
            return unique(df)        
        else
            rename!(df,"price" => "price ["*unit*"/"*unit2*"]")
            return df
        end
    end
end

function parse_actual_total_load(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else 
        df = DataFrame(times = ZonedDateTime[], load = Int[])
        df, unit = base_parse_amount(df, root, tz)
        rename!(df,"load" => "load ["*unit*"]")

        return df
    end
end

function parse_day_ahead_total_load(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else 
        df = DataFrame(times = ZonedDateTime[], load = Int[])
        df, unit = base_parse_amount(df, root, tz)
        rename!(df,"load" => "load ["*unit*"]")

        return df
    end
end

function parse_week_ahead_total_load(xml, tz)
    return base_parse_min_max_load(xml, tz)
end

function parse_load_monthYear_ahead(xml, tz)
    df = base_parse_min_max_load(xml, tz)
    dff = df["min total load"] 
    dfff = df["max total load"]

    weeks = []
    for i in dff[!, "time"]
        push!(weeks, Dates.week(i))
    end
    dff[!, "week"] = weeks

    weeks = []
    for i in dfff[!, "time"]
        push!(weeks, Dates.week(i))
    end
    dfff[!, "week"] = weeks

    df["min total load"] = dff
    df["max total load"] = dfff
    return df
end

function parse_month_ahead_total_load(xml, tz)
    return parse_load_monthYear_ahead(xml, tz)
end

function parse_year_ahead_total_load(xml, tz)
    return parse_load_monthYear_ahead(xml, tz)
end

function parse_year_ahead_margin(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else 
        df = DataFrame(year = Int[], margin = Int[])

        unit = ""

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))
    
                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)
    
                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        year = Dates.year(time)
                        value = parse(Float64, content(find_element(grandchild, "quantity")))
                        push!(df,(year, value))
                    end
                end
            end
        end  
        rename!(df, "margin" => "margin ["*unit*"]")
        return df
    end
end

function parse_transmission(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = DataFrame(times = ZonedDateTime[], capacity = Int[])
        df, unit = base_parse_amount(df, root, tz)
        rename!(df,"capacity" => "capacity ["*unit*"]")

        return df
    end
end

function parse_forecasted_capacity(xml, tz)
    return parse_transmission(xml, tz)
end

function parse_offered_capacity(xml, tz)
    return parse_transmission(xml, tz)
end

function parse_flowbased(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = Dict{ZonedDateTime, DataFrame}()
        unitRAM = ""
        unitpTDF = ""

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        domains = Dict()
                        cbco = []
                        RAM = []
                        for grandgrandchild in child_elements(grandchild)
                            if name(grandgrandchild) == "Constraint_TimeSeries"
                                push!(cbco, content(find_element(grandgrandchild, "mRID")))
                                unitRAM = content(find_element(grandgrandchild, "quantity_Measurement_Unit.name"))
                                unitpTDF = content(find_element(grandgrandchild, "pTDF_Measurement_Unit.name"))
                                resource = find_element(grandgrandchild, "Monitored_RegisteredResource")
                                push!(RAM, content(find_element(resource, "flowBasedStudy_Domain.flowBasedMargin_Quantity.quantity")))
                                for grandgrandgrandchild in child_elements(resource)
                                    if name(grandgrandgrandchild) == "PTDF_Domain"
                                        if !haskey(domains, content(find_element(grandgrandgrandchild, "mRID")))
                                            domains[content(find_element(grandgrandgrandchild, "mRID"))] = [content(find_element(grandgrandgrandchild, "pTDF_Quantity.quantity"))]
                                        else
                                            push!(domains[content(find_element(grandgrandgrandchild, "mRID"))], content(find_element(grandgrandgrandchild, "pTDF_Quantity.quantity")))
                                        end
                                    end
                                end
                            end
                        end
                        frame = DataFrame("cb/co" => cbco, "RAM ["*unitRAM*"]" => RAM)
                        k = keys(domains)
                        for key in k
                            frame[!, key*" ["*unitpTDF*"]"] = domains[key]
                        end
                        df[time] = frame
                    end
                end
            end
        end
        return df
    end
end

function parse_intraday_transfer_limits(xml, tz)
    return parse_transmission(xml, tz)
end

function parse_explicit_allocation_information_capacity(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""
        unit2 = nothing

        df = DataFrame(time = ZonedDateTime[], capacity = Int[], price = Float64[]) 
        dff = DataFrame(time = ZonedDateTime[], capacity = Int[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "currency_Unit.name"))
                
                if find_element(child, "price_Measure_Unit.name") !== nothing
                    unit2 = content(find_element(child, "price_Measure_Unit.name"))
                end    

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        value = parse(Int, content(find_element(grandchild, "quantity")))
                        if unit2 !== nothing
                            price = parse(Float64, content(find_element(grandchild, "price.amount")))
                            push!(df,(time, value, price))
                        else
                            push!(dff, (time, value))
                        end
                    end
                end
            end
        end  
        if unit2 !== nothing
            rename!(df, "capacity" => "capacity ["*unit*"]", "price" => "price["*unit*"/"*unit2*"]")
            sort!(df)
            return df
        else
            rename!(dff, "capacity" => "capacity ["*unit*"]")
            sort!(dff)
            return dff
        end
    end
end

function parse_explicit_allocation_information_revenue(xml, tz)
    return base_parse_price(xml, tz)
end

function parse_total_capacity_nominated(xml, tz)
    return parse_transmission(xml, tz)
end

function parse_total_capacity_already_allocated(xml, tz)
    return parse_transmission(xml, tz)
end

function parse_day_ahead_prices(xml, tz)
    return base_parse_price(xml, tz)
end

function parse_implicit_auction_net_positions(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""

        df = DataFrame("time" => ZonedDateTime[], "import/export" => String[] , "capacity" => Int[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        value = parse(Int, content(find_element(grandchild, "quantity")))
                        if content(find_element(child, "in_Domain.mRID")) == "REGION_CODE-----"
                            push!(df,(time, "export", value))
                        else 
                            push!(df, (time, "import", value))
                        end
                    end
                end
            end
        end
        rename!(df, "capacity" => "capacity ["*unit*"]")
        return df 
    end
end

function parse_implicit_auction_congestion_income(xml, tz)
    return base_parse_price(xml, tz)
end

function parse_total_commercial_schedules(xml, tz)
    return parse_transmission(xml, tz)
end

function parse_day_ahead_commercial_schedules(xml, tz)
    return parse_transmission(xml, tz)
end

function parse_physical_flows(xml, tz)
    return parse_transmission(xml, tz)
end

function parse_capacity_allocated_outside_EU(xml, tz)
    return parse_transmission(xml, tz)
end

function parse_expansion_and_dismantling(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = DataFrame("estimated completion date" => Date[], "new NTC" => DataFrame[], "Transmission assets" => DataFrame[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))
                completion = content(find_element(child, "end_DateAndOrTime.date"))
                completion = Date(completion, "yyyy-mm-dd")

                dff = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "new NTC ["*unit*"]" => Int[])
                dfff = DataFrame("code" => String[], "location" => String[], "type" => String[])

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution
                        value = parse(Int, content(find_element(grandchild, "quantity")))
                        push!(dff,(time, endtime, value))
                    end
                end
                for grandchild in child_elements(child)
                    if name(grandchild) == "Asset_RegisteredResource"
                        mRID = content(find_element(grandchild, "mRID"))
                        type = content(find_element(grandchild, "pSRType.psrType"))
                        location = content(find_element(grandchild, "location.name"))
                        push!(dfff, (mRID, location, type))
                    end
                end
                push!(df, (completion, dff, dfff))
            end
        end
        return df
    end
end

function parse_redispatching(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "reason" => String[], "impact" => DataFrame[], "affected assets" => DataFrame[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                start = ""
                ennd = ""

                unit = content(find_element(child, "quantity_Measure_Unit.name"))
                dff = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "impact ["*unit*"]" => Int[])
                dfff = DataFrame("code" => String[], "location" => String[], "type" => String[])

                reason = find_element(child, "Reason")
                reason_code = content(find_element(reason, "code"))

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution
                        value = parse(Int, content(find_element(grandchild, "quantity")))
                        push!(dff, (time, endtime, value))
                    end
                end

                for grandchild in child_elements(child)
                    if name(grandchild) == "Asset_RegisteredResource"
                        mRID = content(find_element(grandchild, "mRID"))
                        type = content(find_element(grandchild, "pSRType.psrType"))
                        location = content(find_element(grandchild, "location.name"))
                        push!(dfff, (mRID, location, type))
                    end
                end
                push!(df, (start, ennd, reason_code, dff, dfff))
            end
        end
        return df
    end
end

function parse_countertrading(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "reason" => String[], "change in cross-border exchange" => DataFrame[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                start = ""
                ennd = ""

                unit = content(find_element(child, "quantity_Measure_Unit.name"))
                dff = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "change in cross-border exchange ["*unit*"]" => Int[])

                reason = find_element(child, "Reason")
                if reason !== nothing
                    reason_code = content(find_element(reason, "code"))
                else 
                    reason_code = "N/A"
                end

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution
                        value = parse(Int, content(find_element(grandchild, "quantity")))
                        push!(dff, (time, endtime, value))
                    end
                end
                push!(df, (start, ennd, reason_code, dff))
            end
        end
        sort!(df)
        return df
    end
end

function parse_congestion_costs(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""
        df = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "costs" => Float64[])
        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "currency_Unit.name"))

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        if find_element(grandchild, "congestionCost_Price.amount") === nothing
                            value = "-"
                        else
                            value = parse(Float64, content(find_element(grandchild, "congestionCost_Price.amount")))
                        end
                        push!(df,(start, ennd,  value))
                    end
                end
            end
        end  
        rename!(df, "costs" => "costs ["*unit*"]")
        return df
    end
end

function parse_installed_generation_capacity_aggregated(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""
        df = DataFrame("year" => Int[], "type" => String[], "installed capacity" => Int[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))

                mktPSRtype = find_element(child, "MktPSRType")
                type = content(find_element(mktPSRtype, "psrType"))

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        value = parse(Int, content(find_element(grandchild, "quantity")))
                        push!(df,(year(time), type, value))
                    end
                end
            end
        end            
        rename!(df, "installed capacity" => "installed capacity ["*unit*"]")
        return df
    end
end

function parse_installed_generation_capacity_per_unit(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit_capacity = ""
        df = DataFrame("production type" => String[], "code" => String[], "name" => String[], "cap" => Float64[], "voltage connection level [kV]" => Int64[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit_capacity = content(find_element(child, "quantity_Measure_Unit.name"))
                code = content(find_element(child, "registeredResource.mRID"))
                Name = content(find_element(child, "registeredResource.name"))

                mktPSRtype = find_element(child, "MktPSRType")
                type = content(find_element(mktPSRtype, "psrType"))
                voltage = parse(Int, content(find_element(mktPSRtype, "voltage_PowerSystemResources.highVoltageLimit")))

                period = find_element(child, "Period")
                point = find_element(period, "Point")
                value = parse(Float64, content(find_element(point, "quantity")))

                push!(df, (type, code, Name, value, voltage))
            end
        end
        rename!(df, "cap" => "installed capacity at the beginning of the year ["*unit_capacity*"]")
        return df
    end
end

function parse_day_ahead_aggregated_generation(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unitgen = ""
        unitcon = ""
        df = Dict()
        dff = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "scheduled generation" => Int[])
        dfff = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "scheduled consumption" => Int[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                mRID = parse(Int, content(find_element(child, "mRID")))
                if !iseven(mRID)
                    unitgen = content(find_element(child, "quantity_Measure_Unit.name"))

                    period = find_element(child, "Period")
                    start, ennd, resolution = start_end_resolution(period, tz)

                    for grandchild in child_elements(period)
                        if name(grandchild) == "Point"
                            position = parse(Int, content(find_element(grandchild, "position")))
                            time = (position-1)*resolution + start
                            endtime = time + resolution
                            value = parse(Int, content(find_element(grandchild, "quantity")))
                            push!(dff,(time, endtime, value))
                        end
                    end
                else
                    unitcon = content(find_element(child, "quantity_Measure_Unit.name"))

                    period = find_element(child, "Period")
                    start, ennd, resolution = start_end_resolution(period, tz)

                    for grandchild in child_elements(period)
                        if name(grandchild) == "Point"
                            position = parse(Int, content(find_element(grandchild, "position")))
                            time = (position-1)*resolution + start
                            endtime = time + resolution
                            value = parse(Int, content(find_element(grandchild, "quantity")))
                            push!(dfff,(time, endtime, value))
                        end
                    end
                end
            end
        end
        rename!(dff, "scheduled generation" => "scheduled generation ["*unitgen*"]")
        rename!(dfff, "scheduled consumption" => "scheduled consumption ["*unitcon*"]")
        df["generation"] = dff
        df["consumption"] = dfff
        return df
    end
end

function parse_generation_forecasts_wind_solar(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit_solar = ""
        unit_offshore = "" 
        unit_onshore = ""

        df = Dict()
        dff = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "solar" => Int[])
        dfff = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "wind offshore" => Int[]) 
        dffff = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "wind onshore" => Int[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                psrType = find_element(child, "MktPSRType")
                type = content(find_element(psrType, "psrType"))
                if type == "B16"
                    unit_solar = content(find_element(child, "quantity_Measure_Unit.name"))

                    period = find_element(child, "Period")
                    start, ennd, resolution = start_end_resolution(period, tz)

                    for grandchild in child_elements(period)
                        if name(grandchild) == "Point"
                            position = parse(Int, content(find_element(grandchild, "position")))
                            time = (position-1)*resolution + start
                            endtime = time + resolution
                            value = parse(Int, content(find_element(grandchild, "quantity")))
                            push!(dff,(time, endtime, value))
                        end
                    end
                elseif type == "B18"
                    unit_offshore = content(find_element(child, "quantity_Measure_Unit.name"))

                    period = find_element(child, "Period")
                    start, ennd, resolution = start_end_resolution(period, tz)

                    for grandchild in child_elements(period)
                        if name(grandchild) == "Point"
                            position = parse(Int, content(find_element(grandchild, "position")))
                            time = (position-1)*resolution + start
                            endtime = time + resolution
                            value = parse(Int, content(find_element(grandchild, "quantity")))
                            push!(dfff,(time, endtime, value))
                        end
                    end
                elseif type == "B19"
                    unit_onshore = content(find_element(child, "quantity_Measure_Unit.name"))

                    period = find_element(child, "Period")
                    start, ennd, resolution = start_end_resolution(period, tz)

                    for grandchild in child_elements(period)
                        if name(grandchild) == "Point"
                            position = parse(Int, content(find_element(grandchild, "position")))
                            time = (position-1)*resolution + start
                            endtime = time + resolution
                            value = parse(Int, content(find_element(grandchild, "quantity")))
                            push!(dffff,(time, endtime, value))
                        end
                    end
                end
            end
        end
        rename!(dff, "solar" => "solar ["*unit_solar*"]")
        rename!(dfff, "wind offshore" => "wind offshore ["*unit_offshore*"]")
        rename!(dffff, "wind onshore" => "wind onshore ["*unit_onshore*"]")
        df["solar"] = dff
        df["wind offshore"] = dfff
        df["wind onshore"] = dffff
        return df
    end
end

function parse_day_ahead_generation_forecasts_wind_solar(xml, tz)
    return parse_generation_forecasts_wind_solar(xml, tz)
end

function parse_current_generation_forecasts_wind_solar(xml, tz)
    return parse_generation_forecasts_wind_solar(xml, tz)
end

function parse_day_intraday_generation_forecasts_wind_solar(xml, tz)
    return parse_generation_forecasts_wind_solar(xml, tz)
end

function parse_aggregated_generation_per_type(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""

        df = Dict()

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                dff = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "aggregated generation" => Int[])

                psrType = find_element(child, "MktPSRType")
                type = content(find_element(psrType, "psrType"))

                if type == "B10" 
                    if find_element(child, "inBiddingZone_Domain.mRID") === nothing
                        type = "B10 generation"
                    else
                        type = "B10 consumption"
                    end
                end

                if !(type in keys(df))
                    unit = content(find_element(child, "quantity_Measure_Unit.name"))

                    period = find_element(child, "Period")
                    start, ennd, resolution = start_end_resolution(period, tz)

                    for grandchild in child_elements(period)
                        if name(grandchild) == "Point"
                            position = parse(Int, content(find_element(grandchild, "position")))
                            time = (position-1)*resolution + start
                            endtime = time + resolution
                            value = parse(Int, content(find_element(grandchild, "quantity")))
                            push!(dff,(time, endtime, value))
                        end
                    end
                    rename!(dff, "aggregated generation" => "aggregated generation ["*unit*"]")
                    df[type] = dff
                else
                    dff = df[type]

                    period = find_element(child, "Period")
                    start, ennd, resolution = start_end_resolution(period, tz)

                    for grandchild in child_elements(period)
                        if name(grandchild) == "Point"
                            position = parse(Int, content(find_element(grandchild, "position")))
                            time = (position-1)*resolution + start
                            endtime = time + resolution
                            value = parse(Int, content(find_element(grandchild, "quantity")))
                            push!(dff,(time, endtime, value))
                        end
                    end
                    sort!(dff)
                    df[type] = dff
                end
            end
        end
        return df
    end
end

function parse_aggregated_filling_rate(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""

        df = DataFrame("year" => Int[], "week" => Int[], "stored energy value" => Int[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        week = Dates.week(start)
                        year = Dates.year(start)
                        value = parse(Int, content(find_element(grandchild, "quantity")))
                        push!(df,(year, week, value))
                    end
                end
            end
        end
        rename!(df, "stored energy value" => "stored energy value ["*unit*"]")
        return df
    end
end

function parse_current_balancing_state(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""

        df = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "situation" => String[], "open loop ace" => Float64[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))

                situation = ""
                if content(find_element(child, "flowDirection.direction")) == "A01"
                    situation = "surplus"
                else
                    situation = "deficit"
                end

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution
                        value = parse(Float64, content(find_element(grandchild, "quantity")))
                        push!(df,(time, endtime, situation, value))
                    end
                end
            end
        end
        rename!(df, "open loop ace" => "open loop ace ["*unit*"]")
        return df
    end
end

function parse_aggregated_balancing_energy_bids(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""

        df = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "type of product" => String[], "direction" => String[], "offered" => Int[], "activated" => Int[], "unavailable" => Int[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))

                direction = ""
                if content(find_element(child, "flowDirection.direction")) == "A01"
                    direction = "up"
                else
                    direction = "down"
                end

                type = ""
                if find_element(child, "standard_MarketProduct.marketProductType") !== nothing
                    type = "standard"
                elseif find_element(child, "original_MarketProduct.marketProductType") !== nothing
                    if content(find_element(child, "original_MarketProduct.marketProductType")) == "A04"
                        type = "local"
                    elseif content(find_element(child, "original_MarketProduct.marketProductType")) == "A02"
                        type = "specific"
                    end
                end

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution

                        offered = 0
                        activated = 0
                        unavailable = 0

                        if find_element(grandchild, "quantity") !== nothing
                            offered = parse(Float64, content(find_element(grandchild, "quantity")))
                        end
                        if find_element(grandchild, "secondaryQuantity") !== nothing
                            activated = parse(Float64, content(find_element(grandchild, "secondaryQuantity")))
                        end
                        if find_element(grandchild, "tertiaryQuantity") !== nothing
                            unavailable = parse(Float64, content(find_element(grandchild, "tertiaryQuantity")))
                        end
                        push!(df,(time, endtime, type, direction, offered, activated, unavailable))
                    end
                end
            end
        end
        sort!(df)
        rename!(df, "offered" => "offered ["*unit*"]", "activated" => "activated ["*unit*"]", "unavailable" => "unavailable ["*unit*"]")
        return df
    end
end

function parse_volumes_contracted_reserves(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""

        df = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "reserve type" => String[], "source" => String[], "regulation volume" => Int[], "direction" => String[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))

                direction = ""
                if content(find_element(child, "flowDirection.direction")) == "A01"
                    direction = "up"
                elseif content(find_element(child, "flowDirection.direction")) == "A02"
                    direction = "down"
                elseif content(find_element(child, "flowDirection.direction")) == "A03"
                    direction = "symmetric"
                end

                type = content(find_element(child, "businessType"))
                source = content(find_element(child, "mktPSRType.psrType"))

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution
                        value = parse(Int, content(find_element(grandchild, "quantity")))

                        push!(df,(time, endtime, type, source, value, direction))
                    end
                end
            end
        end
        sort!(df)
        rename!(df, "regulation volume" => "regulation volume ["*unit*"]")
        return df
    end
end

function parse_prices_contracted_reserves(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""
        unit_price = ""

        df = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "reserve type" => String[], "source" => String[], "regulation price" => Float64[], "direction" => String[], "price type" => String[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))
                unit_price = content(find_element(child, "currency_Unit.name"))

                direction = ""
                if content(find_element(child, "flowDirection.direction")) == "A01"
                    direction = "up"
                elseif content(find_element(child, "flowDirection.direction")) == "A02"
                    direction = "down"
                elseif content(find_element(child, "flowDirection.direction")) == "A03"
                    direction = "symmetric"
                end

                type = content(find_element(child, "businessType"))
                source = content(find_element(child, "mktPSRType.psrType"))

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution
                        price = parse(Float64, content(find_element(grandchild, "procurement_Price.amount")))
                        category = content(find_element(grandchild, "imbalance_Price.category"))

                        push!(df,(time, endtime, type, source, price, direction, category))
                    end
                end
            end
        end
        sort!(df)
        rename!(df, "regulation price" => "regulation price ["*unit_price*"/"*unit*"]")
        return df
    end
end

function parse_accepted_aggregated_offers(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""

        df = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "reserve type" => String[], "source" => String[], "accepted reserves" => Int[], "direction" => String[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))

                direction = ""
                if content(find_element(child, "flowDirection.direction")) == "A01"
                    direction = "up"
                elseif content(find_element(child, "flowDirection.direction")) == "A02"
                    direction = "down"
                elseif content(find_element(child, "flowDirection.direction")) == "A03"
                    direction = "symmetric"
                end

                type = content(find_element(child, "businessType"))
                source = content(find_element(child, "mktPSRType.psrType"))

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution
                        value = parse(Int, content(find_element(grandchild, "quantity")))

                        push!(df,(time, endtime, type, source, value, direction))
                    end
                end
            end
        end
        sort!(df)
        rename!(df, "accepted reserves" => "accepted reserves ["*unit*"]")
        return df
    end
end

function parse_activated_balancing_energy(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""

        df = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "reserve type" => String[], "source" => String[], "activated energy" => Int[], "direction" => String[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))

                direction = ""
                if content(find_element(child, "flowDirection.direction")) == "A01"
                    direction = "up"
                elseif content(find_element(child, "flowDirection.direction")) == "A02"
                    direction = "down"
                elseif content(find_element(child, "flowDirection.direction")) == "A03"
                    direction = "symmetric"
                end

                type = content(find_element(child, "businessType"))
                source = content(find_element(child, "mktPSRType.psrType"))

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution
                        value = parse(Int, content(find_element(grandchild, "quantity")))

                        push!(df,(time, endtime, type, source, value, direction))
                    end
                end
            end
        end
        sort!(df)
        rename!(df, "activated energy" => "activated energy ["*unit*"]")
        return df
    end
end

function parse_prices_activated_balancing_energy(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""
        unit_price = ""

        df = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "reserve type" => String[], "source" => String[], "price type" => String[], "price" => Float64[], "direction" => String[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "price_Measure_Unit.name"))
                unit_price = content(find_element(child, "currency_Unit.name"))

                direction = ""
                if content(find_element(child, "flowDirection.direction")) == "A01"
                    direction = "up"
                elseif content(find_element(child, "flowDirection.direction")) == "A02"
                    direction = "down"
                elseif content(find_element(child, "flowDirection.direction")) == "A03"
                    direction = "symmetric"
                end

                reserveType = content(find_element(child, "businessType"))
                source = content(find_element(child, "mktPSRType.psrType"))

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution
                        price = parse(Float64, content(find_element(grandchild, "activation_Price.amount")))
                        category = content(find_element(grandchild, "imbalance_Price.category"))

                        push!(df,(time, endtime, reserveType, source, category, price, direction))
                    end
                end
            end
        end
        sort!(df)
        rename!(df, "price" => "price ["*unit_price*"/"*unit*"]")
        return df
    end
end

function parse_total_imbalance_volumes(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""

        df = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "volume" => Int[], "difference" => Int[], "situation" => String[], "status" => String[])

        status = content(find_element(root, "docStatus"))

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))

                situation = ""
                if content(find_element(child, "flowDirection.direction")) == "A01"
                    situation = "surplus"
                elseif content(find_element(child, "flowDirection.direction")) == "A02"
                    situation = "deficit"
                end

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution

                        volume = 0
                        if find_element(grandchild, "quantity") !== nothing
                            volume = parse(Int, content(find_element(grandchild, "quantity")))
                        end
                        difference = 0
                        if find_element(grandchild, "secondaryQuantity") !== nothing
                            difference = parse(Int, content(find_element(grandchild, "secondaryQuantity")))
                        end

                        push!(df,(time, endtime, volume, difference, situation, status))
                    end
                end
            end
        end
        sort!(df)
        rename!(df, "volume" => "volume ["*unit*"]", "difference" => "difference ["*unit*"]")
        return df
    end
end

function parse_financial_expenses(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""

        df = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "income" => Float64[], "expenses" => Float64[], "status" => String[])

        status = content(find_element(root, "docStatus"))

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "currency_Unit.name"))

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution

                        income = 0
                        expenses = 0

                        for grandgrandchild in child_elements(grandchild)
                            if name(grandgrandchild) == "Financial_Price"
                                if content(find_element(grandgrandchild, "direction")) == "A02"
                                    income = parse(Float64, content(find_element(grandgrandchild, "amount")))
                                elseif content(find_element(grandgrandchild, "direction")) == "A01"
                                    expenses = parse(Float64, content(find_element(grandgrandchild, "amount")))
                                end
                            end
                        end 
                        push!(df,(time, endtime, income, expenses, status))
                    end
                end
            end
        end
        sort!(df)
        rename!(df, "income" => "income ["*unit*"]", "expenses" => "expenses ["*unit*"]")
        return df
    end
end

function parse_crossBorder_balancing(xml, tz)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""
        unit_price = ""

        df = Dict()

        up_aggregated_offers = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "aggregated offers" => Int[])
        up_activated_offers = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "aggregated offers" => Int[])
        up_min_price = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "min price" => Float64[])
        up_max_price = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "max price" => Float64[])

        down_aggregated_offers = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "aggregated offers" => Int[])
        down_activated_offers = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "activated offers" => Int[])
        down_min_price = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "min price" => Float64[])
        down_max_price = DataFrame("start" => ZonedDateTime[], "end" => ZonedDateTime[], "max price" => Float64[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "currency_Unit.name"))

                period = find_element(child, "Period")
                start, ennd, resolution = start_end_resolution(period, tz)

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution

                        income = 0
                        expenses = 0

                        for grandgrandchild in child_elements(grandchild)
                            if name(grandgrandchild) == "Financial_Price"
                                if content(find_element(grandgrandchild, "direction")) == "A02"
                                    income = parse(Float64, content(find_element(grandgrandchild, "amount")))
                                elseif content(find_element(grandgrandchild, "direction")) == "A01"
                                    expenses = parse(Float64, content(find_element(grandgrandchild, "amount")))
                                end
                            end
                        end 
                        push!(df,(time, endtime, income, expenses, status))
                    end
                end
            end
        end
        sort!(df)
        rename!(df, "income" => "income ["*unit*"]", "expenses" => "expenses ["*unit*"]")
        return df
    end
end

end

