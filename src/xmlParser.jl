"""
Parses xml file into FORMAT
"""
module xmlParser

include("xmlMappings.jl")
using .xmlMappings
using DataFrames
using Dates
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

function base_parse_amount(df, root)
    unit = ""

    for child in child_elements(root)
        if name(child) == "TimeSeries"
            unit = content(find_element(child, "quantity_Measure_Unit.name"))

            period = find_element(child, "Period")
            timeInterval = find_element(period, "timeInterval")
            
            resolution = content(find_element(period, "resolution"))
            resolution = xmlMappings.RESOLUTION[resolution]

            start = find_element(timeInterval, "start")
            start = DateTime(content(start), "y-m-dTH:MZ")
            ennd = find_element(timeInterval, "end")
            ennd = DateTime(content(ennd), "y-m-dTH:MZ")

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

function base_parse_price(df, root)
    unit = ""
    unit2 = nothing

    for child in child_elements(root)
        if name(child) == "TimeSeries"
            unit = content(find_element(child, "currency_Unit.name"))

            if find_element(child, "price_Measure_Unit.name") !== nothing
                unit2 = content(find_element(child, "price_Measure_Unit.name"))
            end

            period = find_element(child, "Period")
            timeInterval = find_element(period, "timeInterval")
            
            resolution = content(find_element(period, "resolution"))
            resolution = xmlMappings.RESOLUTION[resolution]

            start = find_element(timeInterval, "start")
            start = DateTime(content(start), "y-m-dTH:MZ")
            ennd = find_element(timeInterval, "end")
            ennd = DateTime(content(ennd), "y-m-dTH:MZ")

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
        return df, unit
    else
        return df, unit, unit2
    end
end

function parse_load(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else 
        df = DataFrame(times = DateTime[], load = Int[])
        df, unit = base_parse_amount(df, root)
        rename!(df,"load" => "load ["*unit*"]")

        return df
    end
end

function parse_transmission(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = DataFrame(times = DateTime[], capacity = Int[])
        df, unit = base_parse_amount(df, root)
        rename!(df,"capacity" => "capacity ["*unit*"]")

        return df
    end
end

function parse_flowbased(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = Dict{DateTime, DataFrame}()
        unitRAM = ""
        unitpTDF = ""

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                period = find_element(child, "Period")
                timeInterval = find_element(period, "timeInterval")

                resolution = content(find_element(period, "resolution"))
                resolution = xmlMappings.RESOLUTION[resolution]

                start = find_element(timeInterval, "start")
                start = DateTime(content(start), "y-m-dTH:MZ")
                ennd = find_element(timeInterval, "end")
                ennd = DateTime(content(ennd), "y-m-dTH:MZ")

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


function parse_price(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = DataFrame(times = DateTime[], price = Float64[])
        df, unit = base_parse_price(df, root)
        rename!(df,"price" => "price ["*unit*"]")
        return df
    end
end

function parse_price_per_unit(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = DataFrame(times = DateTime[], price = Float64[])
        df, unit, unit2 = base_parse_price(df, root)
        rename!(df,"price" => "price ["*unit*"/"*unit2*"]")

        return df
    end
end

function parse_expansion_and_dismantling(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = DataFrame("estimated completion date" => DateTime[], "new NTC" => DataFrame[], "Transmission assets" => DataFrame[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))
                completion = content(find_element(child, "end_DateAndOrTime.date"))
                completion = DateTime(completion, "yyyy-mm-dd")

                dff = DataFrame("start" => DateTime[], "end" => DateTime[], "new NTC ["*unit*"]" => Int[])
                dfff = DataFrame("code" => String[], "location" => String[], "type" => String[])

                period = find_element(child, "Period")
                timeInterval = find_element(period, "timeInterval")
                
                resolution = content(find_element(period, "resolution"))
                resolution = xmlMappings.RESOLUTION[resolution]

                start = find_element(timeInterval, "start")
                start = DateTime(content(start), "y-m-dTH:MZ")
                ennd = find_element(timeInterval, "end")
                ennd = DateTime(content(ennd), "y-m-dTH:MZ")

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

function parse_redispatching(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = DataFrame("start" => DateTime[], "end" => DateTime[], "reason" => String[], "impact" => DataFrame[], "affected assets" => DataFrame[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                start = ""
                ennd = ""

                unit = content(find_element(child, "quantity_Measure_Unit.name"))
                dff = DataFrame("start" => DateTime[], "end" => DateTime[], "impact ["*unit*"]" => Int[])
                dfff = DataFrame("code" => String[], "location" => String[], "type" => String[])

                reason = find_element(child, "Reason")
                reason_code = content(find_element(reason, "code"))

                period = find_element(child, "Period")
                timeInterval = find_element(period, "timeInterval")
                
                resolution = content(find_element(period, "resolution"))
                resolution = xmlMappings.RESOLUTION[resolution]

                start = find_element(timeInterval, "start")
                start = DateTime(content(start), "y-m-dTH:MZ")
                ennd = find_element(timeInterval, "end")
                ennd = DateTime(content(ennd), "y-m-dTH:MZ")

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

function parse_countertrading(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = DataFrame("start" => DateTime[], "end" => DateTime[], "reason" => String[], "change in cross-border exchange" => DataFrame[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                start = ""
                ennd = ""

                unit = content(find_element(child, "quantity_Measure_Unit.name"))
                dff = DataFrame("start" => DateTime[], "end" => DateTime[], "change in cross-border exchange ["*unit*"]" => Int[])

                reason = find_element(child, "Reason")
                if reason !== nothing
                    reason_code = content(find_element(reason, "code"))
                else 
                    reason_code = "N/A"
                end

                period = find_element(child, "Period")
                timeInterval = find_element(period, "timeInterval")
                
                resolution = content(find_element(period, "resolution"))
                resolution = xmlMappings.RESOLUTION[resolution]

                start = find_element(timeInterval, "start")
                start = DateTime(content(start), "y-m-dTH:MZ")
                ennd = find_element(timeInterval, "end")
                ennd = DateTime(content(ennd), "y-m-dTH:MZ")

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
        return df
    end
end

function parse_congestion_costs(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""
        df = DataFrame("start" => DateTime[], "end" => DateTime[], "costs" => Float64[])
        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "currency_Unit.name"))

                period = find_element(child, "Period")
                timeInterval = find_element(period, "timeInterval")
            
                resolution = content(find_element(period, "resolution"))
                resolution = xmlMappings.RESOLUTION[resolution]

                start = find_element(timeInterval, "start")
                start = DateTime(content(start), "y-m-dTH:MZ")
                ennd = find_element(timeInterval, "end")
                ennd = DateTime(content(ennd), "y-m-dTH:MZ")

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

function parse_installed_generation_capacity_aggregated(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""
        df = DataFrame("Year" => DateTime[], "end" => DateTime[], "installed capacity" => Int[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                unit = content(find_element(child, "quantity_Measure_Unit.name"))

                period = find_element(child, "Period")
                timeInterval = find_element(period, "timeInterval")
                
                resolution = content(find_element(period, "resolution"))
                resolution = xmlMappings.RESOLUTION[resolution]

                start = find_element(timeInterval, "start")
                start = DateTime(content(start), "y-m-dTH:MZ")
                ennd = find_element(timeInterval, "end")
                ennd = DateTime(content(ennd), "y-m-dTH:MZ")

                for grandchild in child_elements(period)
                    if name(grandchild) == "Point"
                        position = parse(Int, content(find_element(grandchild, "position")))
                        time = (position-1)*resolution + start
                        endtime = time + resolution
                        value = parse(Int, content(find_element(grandchild, "quantity")))
                        push!(df,(time, endtime, value))
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

function parse_day_ahead_aggregated_generation(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unitgen = ""
        unitcon = ""
        df = Dict()
        dff = DataFrame("start" => DateTime[], "end" => DateTime[], "scheduled generation" => Int[])
        dfff = DataFrame("start" => DateTime[], "end" => DateTime[], "scheduled consumption" => Int[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                mRID = parse(Int, content(find_element(child, "mRID")))
                if !iseven(mRID)
                    unitgen = content(find_element(child, "quantity_Measure_Unit.name"))

                    period = find_element(child, "Period")
                    timeInterval = find_element(period, "timeInterval")
                    
                    resolution = content(find_element(period, "resolution"))
                    resolution = xmlMappings.RESOLUTION[resolution]

                    start = find_element(timeInterval, "start")
                    start = DateTime(content(start), "y-m-dTH:MZ")
                    ennd = find_element(timeInterval, "end")
                    ennd = DateTime(content(ennd), "y-m-dTH:MZ")

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
                    timeInterval = find_element(period, "timeInterval")
                    
                    resolution = content(find_element(period, "resolution"))
                    resolution = xmlMappings.RESOLUTION[resolution]

                    start = find_element(timeInterval, "start")
                    start = DateTime(content(start), "y-m-dTH:MZ")
                    ennd = find_element(timeInterval, "end")
                    ennd = DateTime(content(ennd), "y-m-dTH:MZ")

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

function parse_generation_forecasts_wind_solar(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit_solar = ""
        unit_offshore = "" 
        unit_onshore = ""

        df = Dict()
        dff = DataFrame("start" => DateTime[], "end" => DateTime[], "solar" => Int[])
        dfff = DataFrame("start" => DateTime[], "end" => DateTime[], "wind offshore" => Int[]) 
        dffff = DataFrame("start" => DateTime[], "end" => DateTime[], "wind onshore" => Int[])

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                psrType = find_element(child, "MktPSRType")
                type = content(find_element(psrType, "psrType"))
                if type == "B16"
                    unit_solar = content(find_element(child, "quantity_Measure_Unit.name"))

                    period = find_element(child, "Period")
                    timeInterval = find_element(period, "timeInterval")
                    
                    resolution = content(find_element(period, "resolution"))
                    resolution = xmlMappings.RESOLUTION[resolution]

                    start = find_element(timeInterval, "start")
                    start = DateTime(content(start), "y-m-dTH:MZ")
                    ennd = find_element(timeInterval, "end")
                    ennd = DateTime(content(ennd), "y-m-dTH:MZ")

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
                    timeInterval = find_element(period, "timeInterval")
                    
                    resolution = content(find_element(period, "resolution"))
                    resolution = xmlMappings.RESOLUTION[resolution]

                    start = find_element(timeInterval, "start")
                    start = DateTime(content(start), "y-m-dTH:MZ")
                    ennd = find_element(timeInterval, "end")
                    ennd = DateTime(content(ennd), "y-m-dTH:MZ")

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
                    timeInterval = find_element(period, "timeInterval")
                    
                    resolution = content(find_element(period, "resolution"))
                    resolution = xmlMappings.RESOLUTION[resolution]

                    start = find_element(timeInterval, "start")
                    start = DateTime(content(start), "y-m-dTH:MZ")
                    ennd = find_element(timeInterval, "end")
                    ennd = DateTime(content(ennd), "y-m-dTH:MZ")

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

function parse_aggregated_generation_per_type(xml)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        unit = ""

        df = Dict()

        for child in child_elements(root)
            if name(child) == "TimeSeries"
                dff = DataFrame("start" => DateTime[], "end" => DateTime[], "aggregated generation" => Int[])

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
                    timeInterval = find_element(period, "timeInterval")
                    
                    resolution = content(find_element(period, "resolution"))
                    resolution = xmlMappings.RESOLUTION[resolution]

                    start = find_element(timeInterval, "start")
                    start = DateTime(content(start), "y-m-dTH:MZ")
                    ennd = find_element(timeInterval, "end")
                    ennd = DateTime(content(ennd), "y-m-dTH:MZ")

                    for grandchild in child_elements(period)
                        if name(grandchild) == "Point"
                            position = parse(Int, content(find_element(grandchild, "position")))
                            time = (position-1)*resolution + start
                            endtime = time + resolution
                            value = parse(Int, content(find_element(grandchild, "quantity")))
                            push!(dff,(time, endtime, value))
                        end
                    end
                    df[type] = dff
                else
                    dff = df[type]
                    period = find_element(child, "Period")
                    timeInterval = find_element(period, "timeInterval")
                    
                    resolution = content(find_element(period, "resolution"))
                    resolution = xmlMappings.RESOLUTION[resolution]

                    start = find_element(timeInterval, "start")
                    start = DateTime(content(start), "y-m-dTH:MZ")
                    ennd = find_element(timeInterval, "end")
                    ennd = DateTime(content(ennd), "y-m-dTH:MZ")

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

end

