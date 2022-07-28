module GETconstructor

include("mappings.jl")
include("argumentLimitations.jl")
using .mappings
using .argumentLimitations
using HTTP
using Markdown
using Dates

############# general functions ######################

URL = "https://transparency.entsoe.eu/api?" 
global key = ""                             # your personal key to get access to the transparency platform (go to 'my account settings' and then to 'Web Api Security Token' to generate one)

"""
    initialize_key(APIkey::String)

Initialize the global variable 'key' as 'APIkey' so that it can be used in other functions. 
Returns the value of 'key'.
"""
function initialize_key(APIkey::String)
    global key = APIkey
    return key
end

"""
    base_query(param::Dict, key::String[, url::String = URL])

Creates an HTTP GET request based on a URL extended with a security key and a dictionary with additional parameters.
Returns the received HTTP response.

# Arugments 
- `param::Dict`: Dictionary with additional parameters, the key represents the name and the value represents the value of the parameter
- `key::String`: Security key to access the transparency platform
- `url::String`: base url (=https://transparency.entsoe.eu/api?), optional
"""
function base_query(param::Dict, key::String, url::String = URL)
    length(key) > 0 ?  base_param = Dict{String, String}("securityToken" => key) : throw(DomainError("API-key not initialized! Call 'initialize_key(API-key)' to initialize."))
    param = merge(base_param, param)
    response = HTTP.get(url, query = param)
    return response
end

docStatusDict = Dict{String, String}("Intermediate" => "A01", "Final" => "A02", "Active" => "A05", "Cancelled" => "A09", "Withdrawn" => "A13", "Estimated" => "X01")
contractDict = Dict{String, String}("Daily" => "A01", "Weekly" => "A02", "Monthly" => "A03", "Yearly" => "A04", "Total" => "A05", "LT" => "A06", "Intraday" => "A07", "Hourly" => "A13")


################## load functions ########################

"""
    base_query_load(param::Dict, outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Covers the parameters which are the same for all the load queries: outBiddingZone_Domain, periodStart and periodEnd are added to the param dictionary.
Returns the received HTTP response.

# Arugments
- `param::Dict`: Dictionary with load query specific parameters, the key represents the name and the value represents the value of the parameter
- `outBiddingZone_Domain::Union{mappings.Area, String}`: Area for which the load data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
"""
function base_query_load(param::Dict, outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    outBiddingZone_Domain = mappings.lookup_area(outBiddingZone_Domain)
    periodStart = mappings.DateTimeTranslator(periodStart)
    periodEnd = mappings.DateTimeTranslator(periodEnd)

    base_param = Dict{String, String}("documentType" => "A65", "periodStart" => periodStart, "periodEnd" => periodEnd, "outBiddingZone_Domain" => outBiddingZone_Domain.value)
    param = merge(param, base_param)

    response = base_query(param, key)
    return response
end

"""
    query_actual_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for actual total load data (article 6.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/load-domain/Data-view%20Total%20Load%20-%20Day%20Ahead%20-%20Actual.html). 
Returns the received HTTP response.
Minimum time interval in query response is one MTU period!

# Arguments
- `outBiddingZone_Domain::Union{mappings.Area, String}`: Area for which the load data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_actual_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    process = Dict{String, String}("processType" => "A16")

    response = base_query_load(process, outBiddingZone_Domain, periodStart, periodEnd)
    return response
end

"""
    query_day_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the day ahaed total load forecast (article 6.1 B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/load-domain/Data-view%20Total%20Load%20-%20Day%20Ahead%20-%20Actual.html). 
Returns the received HTTP response.
Minimum time interval in query response is one day!

# Arguments
- `outBiddingZone_Domain::Union{mappings.Area, String}`: Area for which the load data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_day_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    process = Dict{String, String}("processType" => "A01")

    response = base_query_load(process, outBiddingZone_Domain, periodStart, periodEnd)
    return response
end

"""
    query_week_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the week ahaed total load forecast (article 6.1 C: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/load-domain/Data-view%20Total%20Load%20Forecast%20-%20Week%20Ahead.html). 
Returns the received HTTP response.
Minimum time interval in query response is one week!

# Arguments
- `outBiddingZone_Domain::Union{mappings.Area, String}`: Area for which the load data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_week_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    process = Dict{String, String}("processType" => "A31")

    response = base_query_load(process, outBiddingZone_Domain, periodStart, periodEnd)
    return response
end

"""
    query_month_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the month ahaed total load forecast (article 6.1 D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/load-domain/Data-view%20Total%20Load%20Forecast%20-%20Month%20Ahead.html). 
Returns the received HTTP response.
Minimum time interval in query response is one month!

# Arguments
- `outBiddingZone_Domain::Union{mappings.Area, String}`: Area for which the load data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_month_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    process = Dict{String, String}("processType" => "A32")

    response = base_query_load(process, outBiddingZone_Domain, periodStart, periodEnd)
    return response
end

"""
    query_year_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the month ahaed total load forecast (article 6.1 E: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/load-domain/Data-view%20Total%20Load%20Forecast%20-%20Year%20Ahead.html). 
Returns the received HTTP response.
Minimum time interval in query response is one year!

# Arguments
- `outBiddingZone_Domain::Union{mappings.Area, String}`: Area for which the load data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_year_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    process = Dict{String, String}("processType" => "A33")

    response = base_query_load(process, outBiddingZone_Domain, periodStart, periodEnd)
    return response
end

"""
    query_year_ahead_margin(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the year ahead forecast margin (article 8.1: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/load-domain/Data-view%20Forecast%20Margin%20-%20Year%20Ahead.html). 
Returns the received HTTP response.
Minimum time interval in query response is one year!

# Arguments
- `outBiddingZone_Domain::Union{mappings.Area, String}`: Area for which the load data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_year_ahead_margin(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    outBiddingZone_Domain = mappings.lookup_area(outBiddingZone_Domain)

    param = Dict{String, String}("documentType" => "A70", "periodStart" => periodStart, "periodEnd" => periodEnd, "outBiddingZone_Domain" => outBiddingZone_Domain.value, "processType" => "A33")
    
    response = base_query(param, key)
    return response
end

#########################################################
# Use when something would go wrong with creation HTTP request using the query option of HTTP.get()

#= function create_HTTP_command(url::String, param::Dict)
    for key in keys(param)
        print(key)
        println(param[key])
        url = url*"&"*key*"="*param[key]
    end
    return url
end =#

#= function base_query(param::Dict, key::String, url::String = URL)
    length(key) > 0 ?  url = url*"securityToken="*key : throw(DomainError("API-key not initialized! Call 'initialize_key(API-key)' to initialize."))
    #print(param)
    #print(url)

    url = create_HTTP_command(url, param)
    print(url)

    response = HTTP.get(url)
    return response
end =#

###############################################################

################ transmission functions #######################

"""
    base_query_transmission_and_network_congestion(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, param::Dict)

Covers the parameters which are the same for all the transmission and network congestion queries: in_Domain, out_Domain, periodStart and periodEnd are added to the param dictionary.
Returns the received HTTP response.

# Arugments
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `param::Dict`: Dictionary with load query specific parameters, the key represents the name and the value represents the value of the parameter
"""
function base_query_transmission_and_network_congestion(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, param::Dict)
    in_Domain = mappings.lookup_area(in_Domain)
    out_Domain = mappings.lookup_area(out_Domain)
    periodStart = mappings.DateTimeTranslator(periodStart)
    periodEnd = mappings.DateTimeTranslator(periodEnd)

    base_param = Dict{String, String}("in_Domain" => in_Domain.value, "out_Domain" => out_Domain.value, "periodStart" => periodStart, "periodEnd" => periodEnd)
    param = merge(param, base_param)

    response = base_query(param, key)
    return response
end

"""
    query_forecasted_capacity(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the forecasted capacity over a certain border (article 11.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Forecasted%20Transfer%20Capacities%20-%20Day%20Ahead.html).
Returns the received HTTP response.
Minimum time interval in query response ranges from day to year, depending on selected Contract_MarketAgreementType!

# Arguments
- `contract_MarketAgreementType::String`:The specification of the kind of the agreement, e.g. long term, daily contract. Used to distinguish between day ahead, week ahead, month ahead and year ahead forecasts.
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_forecasted_capacity(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    if !(contract_MarketAgreementType in keys(mappings.MARKETAGREEMENTTYPE)) || contract_MarketAgreementType == "A13"
        throw(DomainError(contract_MarketAgreementType, "Incorrect value for contract_MarketAgreementType, check mappings.MARKETAGREEMENTTYPE for the possible values."))
    end
    
    param = Dict{String, String}("documentType" => "A61", "contract_MarketAgreement.Type" => contract_MarketAgreementType)

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_offered_capacity(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = "", update_DateAndOrTime::DateTime = DateTime(0), classificationSequence_AttributeInstanceComponentPosition::String = ""])

Constructs the HTTP request for the data of the offered capacity over a certain border (article 11.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission/Data-view%20Explicit%20Allocations%20-%20Intraday.html).
Returns the received HTTP response.
Minimum time interval in query response ranges from day to year, depending on selected Contract_MarketAgreementType!

# Arguments
- `auctionType::String`: The kind of the auction (e.g. implicit, explicit ...)
- `contract_MarketAgreementType::String`: The specification of the kind of the agreement, e.g. long term, daily contract. Used to distinguish between day ahead, week ahead, month ahead and year ahead forecasts.
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `auctionCategory::String = ""`: The product category of an auction
- `update_DateAndOrTime::DateTime = ""`: The date and time of the update of the document
- `classificationSequence_AttributeInstanceComponentPosition::String = ""`: A sequential value representing a relative sequence number. A classification sequence is only provided in the case where there are several auctions in the same category and contract type.

! 100 document limit applies !
"""
function query_offered_capacity(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "", update_DateAndOrTime::DateTime = DateTime(0), classificationSequence_AttributeInstanceComponentPosition::String = "")
    if !(auctionType in keys(mappings.AUCTIONTYPE))
        throw(DomainError(auctionType, "Incorrect value for auctionType, check mappings.AUCTIONTYPE for the possible values."))
    end
    if !(contract_MarketAgreementType in keys(mappings.MARKETAGREEMENTTYPE)) || contract_MarketAgreementType == "A13"
        throw(DomainError(contract_MarketAgreementType, "Incorrect value for contract_MarketAgreementType, check mappings.MARKETAGREEMENTTYPE for the possible values."))
    end
    if !(auctionCategory in keys(mappings.AUCTIONCATEGORY)) && auctionCategory != ""
        throw(DomainError(auctionCategory, "Incorrect value for auctionCategory, check mappings.AUCTIONCATEGORY for the possible values."))
    end

    param = Dict{String, String}("documentType" => "A31", "auction.Type" => auctionType, "contract_MarketAgreement.Type" => contract_MarketAgreementType)

    if auctionCategory != ""
        param["acution.Category"] = auctionCategory
    end
    if update_DateAndOrTime != DateTime(0)
        update_DateAndOrTime = mappings.DateTimeTranslator(update_DateAndOrTime, 1)
        param["update_DateAndOrTime"] = update_DateAndOrTime
    end
    if classificationSequence_AttributeInstanceComponentPosition != ""
        param["classificationSequence_AttributeInstanceComponent.Position"] = classificationSequence_AttributeInstanceComponentPosition
    end

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_flowbased(processType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the flow-based parameters of a certain area (article 11.1 B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Day%20Ahead%20Flow%20Based%20Allocations.html).
Returns the received HTTP response.
Minimum time interval in query response is one day for day-ahead allocations!

# Arguments
- `processType::String`: The kind of the auction (e.g. implicit, explicit ...)
- `domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! 100 document limit applies !
"""
function query_flowbased(processType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    if !(processType in argumentLimitations.FlowbasedProcessType)
        throw(DomainError(processType, "Incorrect value for processType, choose between A01 (day ahead) and A02 (intraday)"))
    end

    param = Dict{String, String}("documentType" => "B11", "processType" => processType)

    response = base_query_transmission_and_network_congestion(domain, domain, periodStart, periodEnd, param)
    return response
end

"""
    query_intraday_transfer_limits(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the intraday transfer limits over a certain border (article 11.3: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Cross%20Border%20Capacity%20of%20DC%20Links%20-%20Intraday%20Transfer%20Limits.html).
Returns the received HTTP response.
Minimum time interval in query response ranges from part of day up to one day!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_intraday_transfer_limits(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))
    
    param = Dict{String, String}("documentType" => "A93")

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_explicit_allocation_information_capacity(businessType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = ""])

Constructs the HTTP request for the data of the capacity explicitly allocated to the market over a certain border and its revenue (article 12.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission/Data-view%20Explicit%20Allocations%20-%20Day%20ahead.html).
Returns the received HTTP response.
Minimum time interval in query response ranges from part of day to year, depending on selected Contract_MarketAgreementType!

# Arguments
- `businessType::String`: The identification of the nature of the data
- `contract_MarketAgreementType::String`: The specification of the kind of the agreement, e.g. long term, daily contract. Used to distinguish between day ahead, week ahead, month ahead and year ahead forecasts.
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `auctionCategory::String = ""`: The product category of an auction
- `classificationSequence_AttributeInstanceComponentPosition::String = ""`: A sequential value representing a relative sequence number. A classification sequence is only provided in the case where there are several auctions in the same category and contract type.

! 100 document limit applies !
"""
function query_explicit_allocation_information_capacity(businessType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = "")
    if !(businessType in argumentLimitations.eaiCapacityBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A43 (requested capacity) and B05 (capacity allocated)"))
    end
    if !(contract_MarketAgreementType in keys(mappings.MARKETAGREEMENTTYPE)) || contract_MarketAgreementType == "A13"
        throw(DomainError(contract_MarketAgreementType, "Incorrect value for contract_MarketAgreementType, check mappings.MARKETAGREEMENTTYPE for the possible values."))
    end
    if !(auctionCategory in keys(mappings.AUCTIONCATEGORY)) && auctionCategory != ""
        throw(DomainError(auctionCategory, "Incorrect value for auctionCategory, check mappings.AUCTIONCATEGORY for the possible values."))
    end

    param = Dict{String, String}("documentType" => "A25", "businessType" => businessType, "contract_MarketAgreement.Type" => contract_MarketAgreementType)
    
    if auctionCategory != ""
        param["auction.Category"] = auctionCategory
    end
    if classificationSequence_AttributeInstanceComponentPosition != ""
        param["classificationSequence_AttributeInstanceComponent.Position"] = classificationSequence_AttributeInstanceComponentPosition
    end

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_explicit_allocation_information_revenue(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the revenue of the capacity explicitly allocated to the market over a certain border (article 12.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Explicit%20Allocations%20Revenue.html).
Returns the received HTTP response.
Minimum time interval in query response ranges from part of day to year, depending on selected Contract_MarketAgreementType!

# Arguments
- `contract_MarketAgreementType::String`: The specification of the kind of the agreement, e.g. long term, daily contract. Used to distinguish between day ahead, week ahead, month ahead and year ahead forecasts.
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! 100 document limit applies !
"""
function query_explicit_allocation_information_revenue(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    if !(contract_MarketAgreementType in keys(mappings.MARKETAGREEMENTTYPE)) || contract_MarketAgreementType == "A13"
        throw(DomainError(contract_MarketAgreementType, "Incorrect value for contract_MarketAgreementType, check mappings.MARKETAGREEMENTTYPE for the possible values."))
    end
    
    param = Dict{String, String}("documentType" => "A25", "businessType" => "B07", "contract_MarketAgreement.Type" => contract_MarketAgreementType)
    
    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_total_capacity_nominated(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the total nominated capacity over a certain border (article 12.1 B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Total%20Nominated%20Capacity.html).
Returns the received HTTP response.
Minimum time interval in query response is one day!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_total_capacity_nominated(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    param = Dict{String, String}("documentType" => "A26", "businessType" => "B08")
    
    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_total_capacity_already_allocated(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = ""])

Constructs the HTTP request for the data of the total capacity already allocated over a certain border (article 12.1 C: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission/Data-view%20Explicit%20Allocations%20-%20AAC.html).
Returns the received HTTP response.
Minimum time interval in query response ranges from part of day to year, depending on selected Contract_MarketAgreement.Type!

# Arguments
- `contract_MarketAgreementType::String`: The specification of the kind of the agreement, e.g. long term, daily contract. Used to distinguish between day ahead, week ahead, month ahead and year ahead forecasts.
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `auctionCategory::String = ""`: The product category of an auction

! 100 documents limit applies !
"""
function query_total_capacity_already_allocated(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "")
    if !(contract_MarketAgreementType in keys(mappings.MARKETAGREEMENTTYPE)) || contract_MarketAgreementType == "A13"
        throw(DomainError(contract_MarketAgreementType, "Incorrect value for contract_MarketAgreementType, check mappings.MARKETAGREEMENTTYPE for the possible values."))
    end
    if !(auctionCategory in keys(mappings.AUCTIONCATEGORY)) && auctionCategory != ""
        throw(DomainError(auctionCategory, "Incorrect value for auctionCategory, check mappings.AUCTIONCATEGORY for the possible values."))
    end
    
    param = Dict{String, String}("documentType" => "A26", "businessType" => "A29", "contract_MarketAgreement.Type" => contract_MarketAgreementType)
    
    if auctionCategory != ""
        param["acution.Category"] = auctionCategory
    end

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_day_ahead_prices(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the day ahead prices in a certain area (article 12.1 D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Day-ahead%20prices.html).
Returns the received HTTP response.
Minimum time interval in query response is one day!

# Arguments
- `domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_day_ahead_prices(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    param = Dict{String, String}("documentType" => "A44")
    
    response = base_query_transmission_and_network_congestion(domain, domain, periodStart, periodEnd, param)
    return response
end

"""
    query_implicit_auction_net_positions_and_congestion_income(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the net positions and congestion income of implictly allocated capacity over a certain border (article 12.1 E: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Intraday%20Flow%20Based%20Implicit%20Allocations%20-%20Congestion%20Income.html).
Returns the received HTTP response.
Minimum time interval in query response is one day!

# Arguments
- `businessType::String`: The identification of the nature of the data.
- `contract_MarketAgreementType::String`: The specification of the kind of the agreement, e.g. long term, daily contract. Used to distinguish between day ahead, week ahead, month ahead and year ahead forecasts.
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_implicit_auction_net_positions_and_congestion_income(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))
    
    if !(businessType in argumentLimitations.ianpBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between B09 (net position) and B10 (congestion income)"))
    end
    if !(contract_MarketAgreementType in keys(mappings.MARKETAGREEMENTTYPE)) || contract_MarketAgreementType == "A13"
        throw(DomainError(contract_MarketAgreementType, "Incorrect value for contract_MarketAgreementType, check mappings.MARKETAGREEMENTTYPE for the possible values."))
    end

    param = Dict{String, String}("documentType" => "A25", "businessType" => businessType, "contract_MarketAgreement.Type" => contract_MarketAgreementType)
    
    response = base_query_transmission_and_network_congestion(domain, domain, periodStart, periodEnd, param)
    return response
end

"""
    query_total_commercial_schedules(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the total or day ahead commercial schedules over a certain border (article 12.1 F: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Scheduled%20Commercial%20Exchanges%20-%20Day%20Ahead.html).
Returns the received HTTP response.
Minimum time interval in query response is one day!

# Arguments
- `contract_MarketAgreementType::String`: The specification of the kind of the agreement, e.g. long term, daily contract. Used to distinguish between day ahead, week ahead, month ahead and year ahead forecasts.
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_total_commercial_schedules(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    if !(contract_MarketAgreementType in argumentLimitations.SchedulesContractType)
        throw(DomainError(contract_MarketAgreementType, "Incorrect value for contract_MarketAgreementType, choose between A01 (day ahead) and A05 (total)"))
    end

    param = Dict{String, String}("documentType" => "A09", "contract_MarketAgreement.Type" => contract_MarketAgreementType)
    
    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_phyiscal_flows(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the physical flows over a certain border (article 12.1 G: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Cross%20Border%20Physical%20Flows.html).
Returns the received HTTP response.
Minimum time interval in query response is MTU period!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_phyiscal_flows(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))
    
    param = Dict{String, String}("documentType" => "A11")
    
    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_capacity_allocated_outside_EU(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = ""])

Constructs the HTTP request for the data of the capacity allocated outside the EU over a certain border (article 12.1 H: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission/Data-view%20Transfer%20Capacities%20Allocated%20with%20Third%20Countries.html).
Returns the received HTTP response.
Minimum time interval in query response ranges from part of day to year, depending on selected Contract_MarketAgreementType!

# Arguments
- `auctionType::String`: The kind of the auction (e.g. implicit, explicit ...)
- `contract_MarketAgreementType::String`: The specification of the kind of the agreement, e.g. long term, daily contract. Used to distinguish between day ahead, week ahead, month ahead and year ahead forecasts.
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `auctionCategory::String = ""`: The product category of an auction
- `classificationSequence_AttributeInstanceComponentPosition::String = ""`: A sequential value representing a relative sequence number. A classification sequence is only provided in the case where there are several auctions in the same category and contract type.

! 100 document limit applies !
"""
function query_capacity_allocated_outside_EU(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = "")
    if !(auctionType in keys(mappings.AUCTIONTYPE))
        throw(DomainError(auctionType, "Incorrect value for auctionType, check mappings.AUCTIONTYPE for the possible values."))
    end
    if !(contract_MarketAgreementType in keys(mappings.MARKETAGREEMENTTYPE)) || contract_MarketAgreementType == "A13"
        throw(DomainError(contract_MarketAgreementType, "Incorrect value for contract_MarketAgreementType, check mappings.MARKETAGREEMENTTYPE for the possible values."))
    end
    if !(auctionCategory in keys(mappings.AUCTIONCATEGORY)) && auctionCategory != ""
        throw(DomainError(auctionCategory, "Incorrect value for auctionCategory, check mappings.AUCTIONCATEGORY for the possible values."))
    end
    
    param = Dict{String, String}("documentType" => "A94", "auction.Type" => auctionType, "contract_MarketAgreement.Type" => contract_MarketAgreementType)
    
    if auctionCategory != ""
        param["auction.Category"] = auctionCategory
    end
    if classificationSequence_AttributeInstanceComponentPosition != ""
        param["classificationSequence_AttributeInstanceComponent.Position"] = classificationSequence_AttributeInstanceComponentPosition
    end

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end


####################### network and congestion management functions ########################

"""
    query_expansion_and_dismantling(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", docStatus::String = ""])

Constructs the HTTP request for the data about expansion and dismantling projects over a certain border (article 9.1: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission/Data-view%20Expansion%20and%20dismantling%20projects.html).
Returns the received HTTP response.
Time interval in query response depends on duration of matching projects!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data
- `docStatus::String = ""`: Identification of the condition or position of the document with regard to its standing

! 100 document limit applies !
"""
function query_expansion_and_dismantling(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", docStatus::String = "")
    if !(businessType in argumentLimitations.ExpansionBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between B01 (evolution) and B02 (dismantling)"))
    end
    if !(docStatus in mappings.DOCSTATUS) && docStatus != ""
        throw(DomainError(docStatus, "Incorrect value for docStatus, check mappings.DOCSTATUS for the possible values."))
    end

    param = Dict{String, String}("documentType" => "A90")

    if businessType != ""
        param["businessType"] = businessType
    end
    if docStatus != ""
        param["docStatus"] = docStatusDict[docStatus]
    end

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_redispatching(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = ""])

Constructs the HTTP request for the data about redispatching over a certain border (article 13.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/congestion-management/Data-view%20Redispatching.html).
Returns the received HTTP response.
Time interval in query response depends on duration of matching redispatches!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data

! 100 document limit applies !
"""
function query_redispatching(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "")
    if !(businessType in argumentLimitations.redispatchingBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A46 (system operator redispatching) and A85 (internal requirements)"))
    end

    param = Dict{String, String}("documentType" => "A63")

    if businessType != ""
        param["businessType"] = businessType
    end

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_countertrading(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about countertrading over a certain border (article 13.1 B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/congestion-management/Data-view%20Countertrading.html).
Returns the received HTTP response.
Time interval in query response depends on duration of matching counter trades!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data

! 100 document limit applies !
"""
function query_countertrading(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    param = Dict{String, String}("documentType" => "A91")
    
    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_congestion_costs(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = ""])

Constructs the HTTP request for the data about the congestion management costs over a certain border (article 13.1 C: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/congestion-management/Data-view%20Costs.html).
Returns the received HTTP response.
Minimum time interval in query response is one month!

# Arguments
- `domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data

! 100 document limit applies !
"""
function query_congestion_costs(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "")
    if !(businessType in argumentLimitations.congestionBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A46 (system operator redispatching) and B03 (countertrade) and B04 (congestion costs)"))
    end

    param = Dict{String, String}("documentType" => "A92")

    if businessType != ""
        param["businessType"] = businessType
    end

    response = base_query_transmission_and_network_congestion(domain, domain, periodStart, periodEnd, param)
    return response
end

##################### generation functions #######################

"""
    base_query_generation(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::Datetime, param::Dict)

Covers the parameters which are the same for all the generation queries: in_Domain, periodStart and periodEnd are added to the param dictionary.
Returns the received HTTP response.

# Arugments
- `in_Domain::Union{mappings.Area, String}`: Area for which the generation data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `param::Dict`: Dictionary with load query specific parameters, the key represents the name and the value represents the value of the parameter
"""
function base_query_generation(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::Datetime, param::Dict)
    in_Domain = mappings.lookup_area(in_Domain)

    base_param = Dict{String, String}("in_Domain" => in_Domain.value, "periodStart" => periodStart, "periodEnd" => periodEnd)
    param = merge(param, base_param)

    response = base_query(param, key)
    return response
end

"""
    query_installed_generation_capacity_aggregated(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about the aggregated installed generation capacity in a certain area (article 14.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Installed%20Capacity%20per%20Production%20Type.html).
Returns the received HTTP response.
Minimum time interval in query response is one year!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.

! One year range limit applies !
"""
function query_installed_generation_capacity_aggregated(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    if !(psrType in mappings.PSRTYPE) && psrType != ""
        throw(DomainError(psrType, "Incorrect value for psrType, check mappings.PSRTYPE for the possible values."))
    end
    
    param = Dict{String, String}("documentType" => "A68", "processType" => "A33")

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_installed_generation_capacity_per_unit(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about the installed generation capacity per unit in a certain area (article 14.1 B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Installed%20Capacity%20per%20Production%20Unit.html).
Returns the received HTTP response.
Minimum time interval in query response is one year!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.

! One year range limit applies !
"""
function query_installed_generation_capacity_per_unit(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    if !(psrType in mappings.PSRTYPE) && psrType != ""
        throw(DomainError(psrType, "Incorrect value for psrType, check mappings.PSRTYPE for the possible values."))
    end
    
    param = Dict{String, String}("documentType" => "A71", "processType" => "A33")

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_day_ahead_aggregated_generation(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the day ahead forecast of aggregated generation in a certain area (article 14.1 C: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Generation%20Forecast%20-%20Day%20Ahead.html).
Returns the received HTTP response.
Minimum time interval in query response is one day!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_day_ahead_aggregated_generation(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    param = Dict{String, String}("documentType" => "A71", "processType" => "A01")

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_day_ahead_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about the day ahead forecast of wind and solar generation in a certain area (article 14.1 D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Generation%20Forecasts%20-%20Day%20Ahead%20for%20Wind%20and%20Solar.html).
Returns the received HTTP response.
Minimum time interval in query response is one day!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.

! One year range limit applies !
"""
function query_day_ahead_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    if !(psrType in mappings.PSRTYPE) && psrType != ""
        throw(DomainError(psrType, "Incorrect value for psrType, check mappings.PSRTYPE for the possible values."))
    end
    
    param = Dict{String, String}("documentType" => "A69", "processType" => "A01")

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_current_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about the current forecast of wind and solar generation in a certain area (article 14.1 D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Generation%20Forecast%20-%20Day%20Ahead.html).
Returns the received HTTP response.
Minimum time interval in query response is one day!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.

! One year range limit applies !
"""
function query_current_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    if !(psrType in mappings.PSRTYPE) && psrType != ""
        throw(DomainError(psrType, "Incorrect value for psrType, check mappings.PSRTYPE for the possible values."))
    end
    
    param = Dict{String, String}("documentType" => "A69", "processType" => "A18")

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_intraday_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::Datetime, periodEnd::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about the intraday forecast of wind and solar generation in a certain area (article 14.1 D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Generation%20Forecast%20-%20Day%20Ahead.html).
Returns the received HTTP response.
Minimum time interval in query response is one MTU period!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.

! One year range limit applies !
"""
function query_intraday_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::Datetime, periodEnd::DateTime, psrType::String = "")
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(year(1)))

    if !(psrType in mappings.PSRTYPE) && psrType != ""
        throw(DomainError(psrType, "Incorrect value for psrType, check mappings.PSRTYPE for the possible values."))
    end
    
    param = Dict{String, String}("documentType" => "A69", "processType" => "A40")

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end


"""
    query_actual_generation_per_generation_unit(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = "", registeredResource::String = ""])

Constructs the HTTP request for the data about the actual generation per generation unit in a certain area (article 16.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Actual%20Generation%20per%20Generation%20Unit.html).
Returns the received HTTP response.
Minimum time interval in query response is one MTU period!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.
- `registeredResource = ""`: The unique identification of a resource

! One day range limit applies !
"""
function query_actual_generation_per_generation_unit(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "", registeredResource::String = "")
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(Day(1)))

    if !(psrType in mappings.PSRTYPE) && psrType != ""
        throw(DomainError(psrType, "Incorrect value for psrType, check mappings.PSRTYPE for the possible values."))
    end
    
    param = Dict{String, String}("documentType" => "A73", "processType" => "A16")

    if psrType != ""
        param["psrType"] = psrType
    end

    if registeredResource != ""
        param["registeredResource"] = registeredResource
    end

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response   
end

"""
    query_aggregated_generation_per_type(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about the actual aggregated generation per plant type in a certain area (article 16.1 B&C: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Actual%20Generation%20per%20Production%20Unit.html).
Returns the received HTTP response.
Minimum time interval in query response is one MTU period!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.

! One year range limit applies !
"""
function query_aggregated_generation_per_type(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(Year(1)))

    if !(psrType in mappings.PSRTYPE) && psrType != ""
        throw(DomainError(psrType, "Incorrect value for psrType, check mappings.PSRTYPE for the possible values."))
    end
    
    param = Dict{String, String}("documentType" => "A75", "processType" => "A16")

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

"""
    query_aggregated_filling_rate(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the aggregated filling rate of water reservoirs and hydro storage plants in a certain area (article 16.1 D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Water%20Reservoirs%20and%20Hydro%20Storage%20Plants.html).
Returns the received HTTP response.
Minimum time inteval in query response is one week!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function query_aggregated_filling_rate(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    argumentLimitations.check_range_limit(periodStart, periodEnd, Period(Year(1)))

    param = Dict{String, String}("documentType" => "A72", "processType" => "A16")

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

#################### master data ###########################

"""
query_aggregated_generation_per_type(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about existing generation and production units on a certain day in a certain area.
Returns the received HTTP response.
Response contains commissioned production units for given day!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One day range limit applies !
"""
function query_production_generation_units(biddingZone_Domain::Union{mappings.Area, String}, implementation_DateAndOrTime::DateTime, psrType::String = "")
    implementation_DateAndOrTime = mappings.DateTimeTranslator(implementation_DateAndOrTime, 2)
    biddingZone_Domain = mappings.lookup_area(biddingZone_Domain)

    param = Dict{String, String}("documentType" => "A95", "businessType" => "B11", "biddingZone_Domain" => biddingZone_Domain.value, "implementation_DateAndOrTime" => implementation_DateAndOrTime)

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query(param, key)
    return response
end

#################### balancing domain data ####################

"""
    base_query_balancing1(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, param::Dict)

Covers the parameters which are the same for some of the balancing queries: area_Domain, periodStart and periodEnd are added to the param dictionary.
Returns the received HTTP response.
Use when area_Domain is needed in the request!

# Arugments
- `area_Domain::Union{mappings.Area, String}`: Area for which the balancing data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `param::Dict`: Dictionary with balancing query specific parameters, the key represents the name and the value represents the value of the parameter
"""
function base_query_balancing1(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, param::Dict)
    periodStart = mappings.DateTimeTranslator(periodStart)
    periodEnd = mappings.DateTimeTranslator(periodEnd)
    area_Domain = mappings.lookup_area(area_Domain)

    base_param = Dict{String, String}("area_Domain" => area_Domain.value, "periodStart" => periodStart, "periodEnd" => periodEnd)
    param = merge(param, base_param)
    
    response = base_query(param, key)
    return response
end

"""
    base_query_balancing2(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, param::Dict)

Covers the parameters which are the same for some of the balancing queries: controlArea_Domain, periodStart and periodEnd are added to the param dictionary.
Returns the received HTTP response.
Use when controlArea_Domain is needed in the request!

# Arugments
- `controlArea_Domain::Union{mappings.Area, String}`: Area for which the balancing data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `param::Dict`: Dictionary with balancing query specific parameters, the key represents the name and the value represents the value of the parameter
"""
function base_query_balancing2(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, param::Dict)
    periodStart = mappings.DateTimeTranslator(periodStart)
    periodEnd = mappings.DateTimeTranslator(periodEnd)
    controlArea_Domain = mappings.lookup_area(controlArea_Domain)

    base_param = Dict{String, String}("controlArea_Domain" => controlArea_Domain.value, "periodStart" => periodStart, "periodEnd" => periodEnd)
    param = merge(param, base_param)
    
    response = base_query(param, key)
    return response
end

"""
    base_query_balancing3(acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, param::Dict)

Covers the parameters which are the same for some of the balancing queries: acquiring_Domain, connectingDomain, periodStart and periodEnd are added to the param dictionary.
Returns the received HTTP response.
Use when acquiring_Domain and connecting_Domain are needed in the request!

# Arugments
- `acquiring_Domain::Union{mappings.Area, String}`: 
- `connecting_Domain_Domain::Union{mappings.Area, String}`: 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `param::Dict`: Dictionary with balancing query specific parameters, the key represents the name and the value represents the value of the parameter
"""
function base_query_balancing3(acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, param::Dict)
    periodStart = mappings.DateTimeTranslator(periodStart)
    periodEnd = mappings.DateTimeTranslator(periodEnd)
    acquiring_Domain = mappings.lookup_area(acquiring_Domain)
    connecting_Domain = mappings.lookup_area(connecting_Domain)

    base_param = Dict{String, String}("acquiring_Domain" => acquiring_Domain.value, "connecting_Domain" => connecting_Domain.value, "periodStart" => periodStart, "periodEnd" => periodEnd)
    param = merge(param, base_param)
    
    response = base_query(param, key)
    return response
end



function query_current_balancing_state(area_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A86", "businessType" => "B33")

    response = base_query_balancing1(area_Domain, periodStart, periodEnd, param)
    return response
end

function query_balancing_energy_bids(area_Domain, periodStart, periodEnd, processType)
    if !(processType in argumentLimitations.bidsProcessType)
        throw(DomainError(processType, "Incorrect value for processType, choose between A51 (aFFR), A47 (mFRR), A46 (RR)"))
    end

    param = Dict{String, String}("documentType" => "A37", "processType" => processType)

    response = base_query_balancing1(area_Domain, periodStart, periodEnd, param)
    return response
end

function query_aggregated_balancing_energy_bids(area_Domain, periodStart, periodEnd, processType)
    if !(processType in argumentLimitations.bidsProcessType)
        throw(DomainError(processType, "Incorrect value for processType, choose between A51 (aFFR), A47 (mFRR), A46 (RR)"))
    end

    param = Dict{String, String}("documentType" => "A24", "processType" => processType)

    response = base_query_balancing1(area_Domain, periodStart, periodEnd, param)
    return response
end

function query_procured_balancing_capacity(area_Domain, periodStart, periodEnd, type_MarketAgreementType = "")
    param = Dict{String, String}("documentType" => "A15", "processType" => "A51")

    if type_MarketAgreementType != ""
        param["type_MarketAgreement.Type"] = type_MarketAgreementType
    end

    response = base_query_balancing1(area_Domain, periodStart, periodEnd, param)
    return response
end
    
function query_crossZonal_balancing_capacity(acquiring_Domain, connecting_Domain, periodStart, periodEnd)
    acquiring_Domain = mappings.lookup_area(acquiring_Domain)

    param = Dict{String, String}("documentType" => "A38", "processType" => "A46", "acquiring_Domain" => acquiring_Domain.value, "connecting_Domain" => connecting_Domain, "periodStart" => periodStart, "periodEnd" => periodEnd) 

    response = base_query(param, key)
    return response
end

function query_volumes_and_prices_contracted_reserves(type_MarketAgreementType, processType, controlArea_Domain, periodStart, periodEnd, psrType = "", offset::Int = 0)
    if !(offset in argumentLimitations.offset)
        throw(DomainError(offset, "Incorrect value for offset, choose a value between 0 en 4800"))
    end
    if !(processType in argumentLimitations.volPricProcessType)
        throw(DomainError(processType, "Incorrect value for processType, choose between A52 (FCR), A51 (aFFR), A47 (mFRR), A46 (RR)"))
    end
    if !(psrType in argumentLimitations.balancingPsrType)
        throw(DomainError(psrType, "Incorrect value for psrType, choose between A03 (resource object), A04 (generation), A05 (load)"))
    end

    
    param = Dict{String, String}("documentType" => "A81", "type_MarketAgreement.Type" => type_MarketAgreementType, "businessType" => "B95", "processType" => processType) 

    if psrType != ""
        param["psrType"] = psrType
    end
    if offset != 0
        param["offset"] = string(offset)
    end

    response = base_query_balancing2(controlArea_Domain, periodStart, periodEnd, param)
    return response
end

function query_volumes_contracted_reserves(type_MarketAgreementType, controlArea_Domain, periodStart, periodEnd, businessType = "", psrType = "", offset::Int = 0)
    if !(businessType in argumentLimitations.balancingBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A95 (FCR) and A96 (aFFR) and A97 (mFFR) and A98 (RR)"))
    end
    if !(offset in argumentLimitations.offset)
        throw(DomainError(offset, "Incorrect value for offset, choose a value between 0 en 4800"))
    end
    if !(psrType in argumentLimitations.balancingPsrType)
        throw(DomainError(psrType, "Incorrect value for psrType, choose between A03 (resource object), A04 (generation), A05 (load)"))
    end
    
    param = Dict{String, String}("documentType" => "A81", "type_MarketAgreement.Type" => type_MarketAgreementType) 

    if businessType != ""
        param["businessType"] = businessType
    end
    if psrType != ""
        param["psrType"] = psrType
    end
    if offset != 0
        param["offset"] = string(offset)
    end

    response = base_query_balancing2(controlArea_Domain, periodStart, periodEnd, param)
    return response
end

function query_prices_contracted_reserves(type_MarketAgreementType, controlArea_Domain, periodStart, periodEnd, businessType = "", psrType = "", offset::Int = 0)
    if !(businessType in argumentLimitations.balancingBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A95 (FCR) and A96 (aFFR) and A97 (mFFR) and A98 (RR)"))
    end
    if !(offset in argumentLimitations.offset)
        throw(DomainError(offset, "Incorrect value for offset, choose a value between 0 en 4800"))
    end
    if !(psrType in argumentLimitations.balancingPsrType)
        throw(DomainError(psrType, "Incorrect value for psrType, choose between A03 (resource object), A04 (generation), A05 (load)"))
    end
    
    param = Dict{String, String}("documentType" => "A89", "type_MarketAgreement.Type" => type_MarketAgreementType) 

    if businessType != ""
        param["businessType"] = businessType
    end
    if psrType != ""
        param["psrType"] = psrType
    end
    if offset != 0
        param["offset"] = string(offset)
    end

    response = base_query_balancing2(controlArea_Domain, periodStart, periodEnd, param)
    return response
end

function query_accepted_aggregated_offers(controlArea_Domain, periodStart, periodEnd, businessType = "", psrType = "")
    if !(businessType in argumentLimitations.balancingBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A95 (FCR) and A96 (aFFR) and A97 (mFFR) and A98 (RR)"))
    end
    
    param = Dict{String, String}("documentType" => "A82") 

    if businessType != ""
        param["businessType"] = businessType
    end
    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_balancing2(controlArea_Domain, periodStart, periodEnd, param)
    return response
end

function query_activated_balancing_energy(controlArea_Domain, periodStart, periodEnd, businessType = "", psrType = "")
    if !(businessType in argumentLimitations.balancingBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A95 (FCR) and A96 (aFFR) and A97 (mFFR) and A98 (RR)"))
    end
    
    param = Dict{String, String}("documentType" => "A83") 

    if businessType != ""
        param["businessType"] = businessType
    end
    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_balancing2(controlArea_Domain, periodStart, periodEnd, param)
    return response
end

function query_prices_activated_balancing_energy(controlArea_Domain, periodStart, periodEnd, businessType = "", psrType = "")
    if !(businessType in argumentLimitations.balancingBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A95 (FCR) and A96 (aFFR) and A97 (mFFR) and A98 (RR)"))
    end
    
    param = Dict{String, String}("documentType" => "A84") 

    if businessType != ""
        param["businessType"] = businessType
    end
    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_balancing2(controlArea_Domain, periodStart, periodEnd, param)
    return response
end

function query_imbalance_prices(controlArea_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A85") 

    response = base_query_balancing2(controlArea_Domain, periodStart, periodEnd, param)
    return response
end

function query_total_imbalance_volumes(controlArea_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A86") 

    response = base_query_balancing2(controlArea_Domain, periodStart, periodEnd, param)
    return response
end

function query_financial_expenses(controlArea_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A87") 

    response = base_query_balancing2(controlArea_Domain, periodStart, periodEnd, param)
    return response
end

function query_crossBorder_balancing(acquiring_Domain, connecting_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A88", "acquiring_Domain" => acquiring_Domain, "connecting_Domain" => connecting_Domain, "periodStart" => periodStart, "periodEnd" => periodEnd) 

    response = base_query(param, key)
    return response
end

function query_FCR_total_capacity(area_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A26", "businessType" => "A25") 

    response = base_query_balancing1(area_Domain, periodStart, periodEnd, param)
    return response
end

function query_share_capacity_FCR(area_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A26", "businessType" => "C23") 

    response = base_query_balancing1(area_Domain, periodStart, periodEnd, param)
    return response
end

function query_contracted_reserve_capacity_FCR(area_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A26", "businessType" => "B95") 

    response = base_query_balancing1(area_Domain, periodStart, periodEnd, param)
    return response
end

function query_FRR_actual_capacity(area_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A26", "processType" => "A56", "businessType" => "C24") 

    response = base_query_balancing1(area_Domain, periodStart, periodEnd, param)
    return response
end

function query_RR_actual_capacity(area_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A26", "processType" => "A46", "businessType" => "C24") 

    response = base_query_balancing1(area_Domain, periodStart, periodEnd, param)
    return response
end

function query_sharing_of_reserves(processType, acquiring_Domain, connecting_Domain, periodStart, periodEnd)
    if !(processType in argumentLimitations.sharingProcessType)
        throw(DomainError(processType, "Incorrect value for processType, choose between A46 (RR) and A56 (FFR)"))
    end

    param = Dict{String, String}("documentType" => "A26", "processType" => processType, "businessType" => "C22") 

    response = base_query_balancing3(acquiring_Domain, connecting_Domain, periodStart, periodEnd, param)
    return response
end

function query_balancing_border_capacity_limitations()
    # NOT IMPLEMENTED YET, CAUSE BAD DOCUMENTATION
end

function query_permanent_allocation_limitations_HVDC()
    # NOT IMPLEMENTED YET, CAUSE BAD DOCUMENTATION
end

function query_netted_and_exchanged_volumes()
    # NOT IMPLEMENTED YET, CAUSE BAD DOCUMENTATION
end


######################### Outages data ################################

function base_query_outages(biddingZone_Domain, periodStart, periodEnd, param = Dict())
    biddingZone_Domain = mappings.lookup_area(biddingZone_Domain)

    base_param = Dict{String, String}("biddingZone_Domain" => biddingZone_Domain.value, "periodStart" => periodStart, "periodEnd" => periodEnd)
    param = merge(param, base_param)
    
    response = base_query(param, key)
    return response
end

function query_unavailability_consumption_units(biddingZone_Domain, periodStart, periodEnd, businessType = "")
    if !(businessType in argumentLimitations.outageBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A53 (planned maintenance) and A54 (forced unavailability)"))
    end

    param = Dict{String, String}("documentType" => "A76") 

    if businessType != ""
        param["businessType"] = businessType
    end

    response = base_query_outages(biddingZone_Domain, periodStart, periodEnd, param)
    return response
end

function query_unavailability_generation_units(biddingZone_Domain, periodStart, periodEnd, businessType = "", docStatus ="", periodStartUpdate ="", periodEndUpdate = "", registeredResource = "", mRID = "", offset::Int = 0)
    if !(businessType in argumentLimitations.outageBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A53 (planned maintenance) and A54 (forced unavailability)"))
    end
    if !(offset in argumentLimitations.offset)
        throw(DomainError(offset, "Incorrect value for offset, choose a value between 0 en 4800"))
    end

    param = Dict{String, String}("documentType" => "A80") 

    if businessType != ""
        param["businessType"] = businessType
    end
    if docStatus != ""
        param["docStatus"] = docStatus
    end
    if periodStartUpdate != ""
        param["periodStartUpdate"] = periodStartUpdate
    end
    if periodEndUpdate != ""
        param["periodEndUpdate"] = periodEndUpdate
    end
    if registeredResource != ""
        param["registeredResource"] = registeredResource
    end
    if mRID != ""
        param["mRID"] = mRID
    end
    if offset != 0
        param["offset"] = string(offset)
    end

    response = base_query_outages(biddingZone_Domain, periodStart, periodEnd, param)
    return response
end

function query_unavailability_production_units(biddingZone_Domain, periodStart, periodEnd, businessType = "", docStatus = "", periodStartUpdate = "", periodEndUpdate = "", registeredResource = "", mRID = "", offset::Int = 0)
    if !(businessType in argumentLimitations.outageBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A53 (planned maintenance) and A54 (forced unavailability)"))
    end
    if !(offset in argumentLimitations.offset)
        throw(DomainError(offset, "Incorrect value for offset, choose a value between 0 en 4800"))
    end

    param = Dict{String, String}("documentType" => "A77") 

    if businessType != ""
        param["businessType"] = businessType
    end
    if docStatus != ""
        param["docStatus"] = docStatus
    end
    if periodStartUpdate != ""
        param["periodStartUpdate"] = periodStartUpdate
    end
    if periodEndUpdate != ""
        param["periodEndUpdate"] = periodEndUpdate
    end
    if registeredResource != ""
        param["registeredResource"] = registeredResource
    end
    if mRID != ""
        param["mRID"] = mRID
    end
    if offset != 0
        param["offset"] = string(offset)
    end

    response = base_query_outages(biddingZone_Domain, periodStart, periodEnd, param)
    return response
end

function query_unavailability_offshore_grid(biddingZone_Domain, periodStart, periodEnd, docStatus = "", periodStartUpdate = "", periodEndUpdate = "", mRID = "", offset::Int = 0)
    if !(offset in argumentLimitations.offset)
        throw(DomainError(offset, "Incorrect value for offset, choose a value between 0 en 4800"))
    end
    
    param = Dict{String, String}("documentType" => "A79") 

    if docStatus != ""
        param["docStatus"] = docStatus
    end
    if periodStartUpdate != ""
        param["periodStartUpdate"] = periodStartUpdate
    end
    if periodEndUpdate != ""
        param["periodEndUpdate"] = periodEndUpdate
    end
    if mRID != ""
        param["mRID"] = mRID
    end
    if offset != 0
        param["offset"] = string(offset)
    end

    response = base_query_outages(biddingZone_Domain, periodStart, periodEnd, param)
    return response
end

function query_unavailability_transmission_infrastructure(in_Domain, out_Domain, periodStart, periodEnd, businessType = "", docStatus = "", periodStartUpdate = "", periodEndUpdate = "", mRID = "", offset::Int = 0)
    if !(businessType in argumentLimitations.outageBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A53 (planned maintenance) and A54 (forced unavailability)"))
    end
    
    if !(offset in argumentLimitations.offset)
        throw(DomainError(offset, "Incorrect value for offset, choose a value between 0 en 4800"))
    end

    in_Domain = mappings.lookup_area(in_Domain)
    out_Domain = mappings.lookup_area(out_Domain)

    param = Dict{String, String}("documentType" => "A78", "in_Domain" => in_Domain.value, "out_Domain" => out_Domain.value, "periodStart" => periodStart, "periodEnd" => periodEnd)
    
    if businessType != ""
        param["businessType"] = businessType
    end
    if docStatus != ""
        param["docStatus"] = docStatus
    end
    if periodStartUpdate != ""
        param["periodStartUpdate"] = periodStartUpdate
    end
    if periodEndUpdate != ""
        param["periodEndUpdate"] = periodEndUpdate
    end
    if mRID != ""
        param["mRID"] = mRID
    end
    if offset != 0
        param["offset"] = string(offset)
    end

    response = base_query(param, key)
    return response
end

function query_fallBacks()
    # NOT IMPLEMENTED YET, CAUSE BAD DOCUMENTATION
end

end
