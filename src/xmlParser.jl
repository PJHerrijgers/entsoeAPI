"""
Parses xml file into dataframe or dictionary of dataframes
"""
module xmlParser

include("xmlMappings.jl")
using .xmlMappings
using DataFrames
using Dates
using TimeZones
using LightXML

############# general functions ######################

"""
    prepare_file(xml::Vector{UInt8})

This function prepares the xml data which is not in the correct format to be parsed.
Returns xml data which can be parsed using the LightXML package.

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the module GETconstructor
"""
function prepare_file(xml::Vector{UInt8})
    open("data/temp.xml", "w") do f
        write(f, xml)
    end
    xdoc = parse_file("data/temp.xml")
    root = LightXML.root(xdoc)
    return root
end

"""
    check_if_file_contains_data(root::XMLElement)

Check if there is any usefull information in the xml data.
Returns 2 values. The first indicates if there is information or not, the second indicates what went wrong or if nothing went wrong it just indicates that there is no information available.

# Arguments
- `root::XMLElement`: The root element in the xml data, given in the format used by LightXML
"""
function check_if_file_contains_data(root::XMLElement)
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

"""
    start_end_resolution(period::XMLElement, tz::TimeZone)

Transforms the dates and times used in the XML file to the correct timezone and extracts the used time resolution in the xml data.
Returns the start and end date and time in the correct timezone and next to that also the correct time resolution.

# Arguments
- `period::XMLElement`: The 'period' xml element which contains the information about start, end and resolution
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function start_end_resolution(period::XMLElement, tz::TimeZone)
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

"""
    base_parse_amount(df::DataFrame, root::XMLElement, tz::TimeZone)

General function to parse an xml file with just times and any kind of power amounts.
Returns the data in a dataframe.

    [time, value]

# Arguments
- `df::DataFrame`: Dataframe in which the times and amounts of the xml files have to be added
- `root::XMLElement`: The root element in the xml data, given in the format used by LightXML
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function base_parse_amount(df::DataFrame, root::XMLElement, tz::TimeZone)
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

"""
    base_parse_min_max_load(xml::Vector{UInt8}, tz::TimeZone)

General function to parse an xml file that contains information about the time, a minimal value and a maximal value.
Returns the data in a dictionary.

    ("min total load" => [time, load], "max total load" => [time, load])

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the module GETconstructor
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function base_parse_min_max_load(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    base_parse_price(xml::Vector{UInt8}, tz::TimeZone)

General function to parse an xml file that contains information about the time and a price.
Returns the data in a dataframe.

    [time, price]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the module GETconstructor
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function base_parse_price(xml::Vector{UInt8}, tz::TimeZone)
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

################## load functions ########################

"""
    parse_actual_total_load(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_actual_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dataframe.

    [time, load]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_actual_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_actual_total_load(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_day_ahead_total_load(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_day_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dataframe.
    
    [time, load]
    
# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_day_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_day_ahead_total_load(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_week_ahead_total_load(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_week_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dictionary.

    ("min total load" => [time, load], "max total load" => [time, load])

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_week_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_week_ahead_total_load(xml::Vector{UInt8}, tz::TimeZone)
    return base_parse_min_max_load(xml, tz)
end

"""
    parse_load_monthYear_ahead(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml files for month and year ahead load.
Returns the data in a dictionary.

    ("min total load" => [week, load], "max total load" => [week, load])

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the module GETconstructor
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_load_monthYear_ahead(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_month_ahead_total_load(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_month_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dictionary.

    ("min total load" => [week, load], "max total load" => [week, load])

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_month_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_month_ahead_total_load(xml::Vector{UInt8}, tz::TimeZone)
    return parse_load_monthYear_ahead(xml, tz)
end

"""
    parse_year_ahead_total_load(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_year_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dictionary.

    ("min total load" => [week, load], "max total load" => [week, load]) 

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_month_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_year_ahead_total_load(xml::Vector{UInt8}, tz::TimeZone)
    return parse_load_monthYear_ahead(xml, tz)
end

"""
    parse_year_ahead_margin(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_year_ahead_margin(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in dataframe.

    [year, margin]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_year_ahead_margin(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_year_ahead_margin(xml::Vector{UInt8}, tz::TimeZone)
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

################ transmission functions #######################

"""
    parse_transmission(xml::Vector{UInt8}, tz::TimeZone)

General function to parse an xml file that contains information about the time and capacity.
Returns the data in a dataframe.

    [time, capacity]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by a function that returned transmission data
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_transmission(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_forecasted_capacity(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_forecasted_capacity(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dataframe.

    [time, capacity]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_forecasted_capacity(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_forecasted_capacity(xml::Vector{UInt8}, tz::TimeZone)
    return parse_transmission(xml, tz)
end

"""
    parse_offered_capacity(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_offered_capacity(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = "", update_DateAndOrTime::DateTime = DateTime(0), classificationSequence_AttributeInstanceComponentPosition::String = ""])`.
Returns the data in a dataframe.

    [time, capacity]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_offered_capacity(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = "", update_DateAndOrTime::DateTime = DateTime(0), classificationSequence_AttributeInstanceComponentPosition::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_offered_capacity(xml::Vector{UInt8}, tz::TimeZone)
    return parse_transmission(xml, tz)
end

"""
    parse_flowbased(xml::Vector{UInt8}, tz::TimeZone)   

Parses the xml file generated by the function `GETconstructor.query_flowbased(processType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in dictionary.

    ("time" => [cb/co, RAM, domain, ..., domain])

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_flowbased(processType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_flowbased(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_intraday_transfer_limits(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_intraday_transfer_limits(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dataframe.

    [time, capacity]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_intraday_transfer_limits(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_intraday_transfer_limits(xml::Vector{UInt8}, tz::TimeZone)
    return parse_transmission(xml, tz)
end

"""
    parse_explicit_allocation_information_capacity(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_explicit_allocation_information_capacity(businessType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = ""])`.
Returns the data in a dataframe.

    [time, capacity [, price]]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_explicit_allocation_information_capacity(businessType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_explicit_allocation_information_capacity(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_explicit_allocation_information_revenue(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_explicit_allocation_information_revenue(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
Returns the data in a dataframe.

    [time, price]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_explicit_allocation_information_revenue(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_explicit_allocation_information_revenue(xml::Vector{UInt8}, tz::TimeZone)
    return base_parse_price(xml, tz)
end

"""
    parse_total_capacity_nominated(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_total_capacity_nominated(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dataframe.

    [time, capacity]

# Arguments
    - `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_total_capacity_nominated(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
    - `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_total_capacity_nominated(xml::Vector{UInt8}, tz::TimeZone)
    return parse_transmission(xml, tz)
end

"""
    parse_total_capacity_already_allocated(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_total_capacity_already_allocated(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = ""])`.
Returns the data in a dataframe.

    [time, capacity]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_total_capacity_already_allocated(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_total_capacity_already_allocated(xml::Vector{UInt8}, tz::TimeZone)
    return parse_transmission(xml, tz)
end

"""
    parse_day_ahead_prices(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_day_ahead_prices(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dataframe.

    [time, capacity]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_day_ahead_prices(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_day_ahead_prices(xml::Vector{UInt8}, tz::TimeZone)
    return base_parse_price(xml, tz)
end

"""
    parse_implicit_auction_net_positions(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_implicit_auction_net_positions_and_congestion_income(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`, in case the option 'net positions' is chosen.
Returns the data in a dataframe.

    [time, import/export, capacity]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_implicit_auction_net_positions_and_congestion_income(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_implicit_auction_net_positions(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_implicit_auction_congestion_income(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_implicit_auction_net_positions_and_congestion_income(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`, in case the option 'congestion income' is chosen.
Returns the data in a dataframe.

    [time, price]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_implicit_auction_net_positions_and_congestion_income(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_implicit_auction_congestion_income(xml::Vector{UInt8}, tz::TimeZone)
    return base_parse_price(xml, tz)
end

"""
    parse_total_commercial_schedules(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_total_commercial_schedules(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dataframe.

    [time, capacity]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_total_commercial_schedules(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_total_commercial_schedules(xml::Vector{UInt8}, tz::TimeZone)
    return parse_transmission(xml, tz)
end

# Not used I think
function parse_day_ahead_commercial_schedules(xml::Vector{UInt8}, tz::TimeZone)
    return parse_transmission(xml, tz)
end

"""
    parse_physical_flows(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_phyiscal_flows(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dataframe.

    [time, capacity]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_phyiscal_flows(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_physical_flows(xml::Vector{UInt8}, tz::TimeZone)
    return parse_transmission(xml, tz)
end

"""
    parse_capacity_allocated_outside_EU(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_capacity_allocated_outside_EU(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = ""])`.
Returns the data in a dataframe.

    [time, capacity]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_capacity_allocated_outside_EU(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_capacity_allocated_outside_EU(xml::Vector{UInt8}, tz::TimeZone)
    return parse_transmission(xml, tz)
end

####################### network and congestion management functions ########################

"""
    parse_expansion_and_dismantling(xml::Vector{UInt8}, tz::TimeZone)

Parses the xml file generated by the function `GETconstructor.query_expansion_and_dismantling(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", docStatus::String = ""])`.
Returns the data in a dataframe.

    [estimated completion date, new NTC => [start, end, new NTC], transmission assets => [code, location, type]]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_expansion_and_dismantling(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", docStatus::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_expansion_and_dismantling(xml::Vector{UInt8}, tz::TimeZone)
    root = prepare_file(xml)

    a, b = check_if_file_contains_data(root)
    if a != true
        return b
    else
        df = DataFrame("estimated completion date" => Date[], "new NTC" => DataFrame[], "transmission assets" => DataFrame[])

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

"""
    parse_redispatching(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_redispatching(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = ""])`.
Returns the data in a dataframe.

    [start, end, reason, impact => [start, end , impact], affected assets => [code, location, type]]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_redispatching(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_redispatching(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_countertrading(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_countertrading(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dataframe.

    [start, end, reason, change in cross-border exchange => [start, end, change in cross-border exchange]]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_countertrading(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_countertrading(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_congestion_costs(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_congestion_costs(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = ""])`.
Returns the data in a dataframe.

    [start, end, costs]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_congestion_costs(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_congestion_costs(xml::Vector{UInt8}, tz::TimeZone)
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

##################### generation functions #######################

"""
    parse_installed_generation_capacity_aggregated(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_installed_generation_capacity_aggregated(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])`.
Returns the data in a dataframe.

    [year, type, installed capacity]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_installed_generation_capacity_aggregated(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_installed_generation_capacity_aggregated(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_installed_generation_capacity_per_unit(xml::Vector{UInt8})

Parses xml file generated by the function `GETconstructor.query_installed_generation_capacity_per_unit(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])`.
Returns the data in a dataframe.

    [production type, code, name, installed capacity at the beginnen of the year, voltage connection level]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_installed_generation_capacity_per_unit(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_installed_generation_capacity_per_unit(xml::Vector{UInt8})
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

"""
    parse_day_ahead_aggregated_generation(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_day_ahead_aggregated_generation(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dictionary.

    ("generation" => [start, end, scheduled generation], "consumption" => [start, end, scheduled consumption])

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_day_ahead_aggregated_generation(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_day_ahead_aggregated_generation(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_generation_forecasts_wind_solar(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_day_ahead_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])`.
Returns the data in a dictionary.

    ("solar" => [start, end, solar], "wind offshore" => [start, end, wind offshore], "wind onshore" => [start, end, wind onshore])

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_day_ahead_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_generation_forecasts_wind_solar(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_day_ahead_generation_forecasts_wind_solar(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_day_ahead_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")`.
Returns the data in a dictionary.

    ("solar" => [start, end, solar], "wind offshore" => [start, end, wind offshore], "wind onshore" => [start, end, wind onshore])

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_day_ahead_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_day_ahead_generation_forecasts_wind_solar(xml::Vector{UInt8}, tz::TimeZone)
    return parse_generation_forecasts_wind_solar(xml, tz)
end

"""
    parse_current_generation_forecasts_wind_solar(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_current_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])`.
Returns the data in a dictionary.

    ("solar" => [start, end, solar], "wind offshore" => [start, end, wind offshore], "wind onshore" => [start, end, wind onshore])

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_current_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_current_generation_forecasts_wind_solar(xml::Vector{UInt8}, tz::TimeZone)
    return parse_generation_forecasts_wind_solar(xml, tz)
end

"""
    parse_intraday_generation_forecasts_wind_solar(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_intraday_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])`.
Returns the data in a dictionary.

    ("solar" => [start, end, solar], "wind offshore" => [start, end, wind offshore], "wind onshore" => [start, end, wind onshore])

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_intraday_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_intraday_generation_forecasts_wind_solar(xml::Vector{UInt8}, tz::TimeZone)
    return parse_generation_forecasts_wind_solar(xml, tz)
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_actual_generation_per_generation_unit(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

"""
    parse_aggregated_generation_per_type(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_aggregated_generation_per_type(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])`.
Returns the data in a dictionary.

    ("type" => [start, end, aggregated generation])

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_aggregated_generation_per_type(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_aggregated_generation_per_type(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_aggregated_filling_rate(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_aggregated_filling_rate(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dataframe.

    [year, week, stored energy value]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_aggregated_filling_rate(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_aggregated_filling_rate(xml::Vector{UInt8}, tz::TimeZone)
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

#################### master data ###########################

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_production_generation_units(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

#################### balancing domain data ####################

"""
    parse_current_balancing_state(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_current_balancing_state(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dataframe.

    [start, end, situation, open loop ace]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_current_balancing_state(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_current_balancing_state(xml::Vector{UInt8}, tz::TimeZone)
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

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_balancing_energy_bids(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

"""
    parse_aggregated_balancing_energy_bids(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_aggregated_balancing_energy_bids(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, processType::String)`.
Returns the data in a dataframe.

    [start, end, type of product, direction, offered, activated, unavailable]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_aggregated_balancing_energy_bids(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, processType::String)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_aggregated_balancing_energy_bids(xml::Vector{UInt8}, tz::TimeZone)
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

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_procured_balancing_capcity(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_crossZonal_balancing_capacity(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_volumes_and_prices_contracted_reserves(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

"""
    parse_volumes_contracted_reserves(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_volumes_contracted_reserves(type_MarketAgreementType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = "", offset::Int = 0])`.
Returns the data in a dataframe.

    [start, end, reserve type, source, regulation volume, direction]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_volumes_contracted_reserves(type_MarketAgreementType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = "", offset::Int = 0])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_volumes_contracted_reserves(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_prices_contracted_reserves(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_prices_contracted_reserves(type_MarketAgreementType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = "", offset::Int = 0])`.
Returns the data in a dataframe.

    [start, end, reserve type, source, regulation price, direction, price type]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_prices_contracted_reserves(type_MarketAgreementType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = "", offset::Int = 0])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_prices_contracted_reserves(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_accepted_aggregated_offers(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_accepted_aggregated_offers(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = ""])`.
Returns the data in a dataframe.

    [start, end, reserve type, source, accepted reserves, direction]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_accepted_aggregated_offers(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_accepted_aggregated_offers(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_activated_balancing_energy(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_activated_balancing_energy(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = ""])`.
Returns the data in a dataframe.

    [start, end, reserve type, source, activated energy, direction]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_activated_balancing_energy(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_activated_balancing_energy(xml::Vector{UInt8}, tz::TimeZone)
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

"""
    parse_prices_activated_balancing_energy(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_prices_activated_balancing_energy(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = ""])`.
Returns the data in a dataframe.

    [start, end, reserve type, source, price type, price, direction]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_prices_activated_balancing_energy(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = ""])`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_prices_activated_balancing_energy(xml::Vector{UInt8}, tz::TimeZone)
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

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_imbalance_prices(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

"""
    parse_total_imbalance_volumes(xml, tz)

Parses xml file generated by the function `GETconstructor.query_total_imbalance_volumes(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dataframe.

    [start, end, volume, difference, situation, status]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_total_imbalance_volumes(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
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

"""
    parse_financial_expenses(xml::Vector{UInt8}, tz::TimeZone)

Parses xml file generated by the function `GETconstructor.query_financial_expenses(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`.
Returns the data in a dataframe.

    [start, end, income, expenses, status]

# Arguments
- `xml::Vector{UInt8}`: xml data in the format as returned by the function `GETconstructor.query_financial_expenses(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)`
- `tz::TimeZone`: Timezone in which the dates and times have to be represented
"""
function parse_financial_expenses(xml::Vector{UInt8}, tz::TimeZone)
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

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_crossBorder_balancing(xml::Vector{UInt8}, tz::TimeZone)
    #=
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
    =#
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_FCR_total_capacity(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_share_capacity_FCR(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parser_contracted_reserver_capacity_FCR(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_FRR_actual_capacity(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_RR_actual_capacity(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_sharing_of_reserves(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_balancing_border_capacity_limitation(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_permanent_allocation_limitations_HVDC(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_netted_and_exchanged_volumes(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

######################### Outages data ################################

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_unavailability_consumption_units(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_unavailability_generation_units(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_unavailability_production_units(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_unavailability_offshore_grid(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_unavailability_transmission_infrastructure(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function parse_fallBacks(xml::Vector{UInt8}, tz::TimeZone)
    return DataFrame()
end

end

