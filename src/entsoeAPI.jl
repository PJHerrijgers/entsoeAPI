"""
Module that handles queries to retrieve data from the ENTSO-E transparancy platform.
This data is returned in xml format and then parsed.
The parsed data is saved in a Dataframe/dictionary of dataframes.
"""
module entsoeAPI

include("GETconstructor.jl")
include("xmlParser.jl")
include("mappings.jl")
using .GETconstructor
using .xmlParser
using DataFrames
using Dates
using TimeZones

################## key set-up ########################

"""
    initialize_key(APIkey::String)

Initialize the global variable 'key' as 'APIkey' in the GETconstructor.jl file, so that it can be used in other functions. 
Returns the value of 'key'.

# Arguments
- `APIkey::String: Your personal security token to access the transparancy platform`
"""
function initialize_key(APIkey::String)
    key = GETconstructor.initialize_key(APIkey)
    return key
end

################## load functions ########################

"""
    actual_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for actual total load data (article 6.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/load-domain/Data-view%20Total%20Load%20-%20Day%20Ahead%20-%20Actual.html). 
Parses the received HTTP response and returns the data in a dataframe.

    [time, load]

Minimum time interval in query response is one MTU period!

# Arguments
- `outBiddingZone_Domain::Union{mappings.Area, String}`: Area for which the load data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function actual_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_actual_total_load(outBiddingZone_Domain, periodStart, periodEnd)
    df = xmlParser.parse_actual_total_load(xml, tz)
    return df
end

"""
    day_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the day ahaed total load forecast (article 6.1 B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/load-domain/Data-view%20Total%20Load%20-%20Day%20Ahead%20-%20Actual.html). 
Parses the received HTTP response and returns the data in a dataframe.

    [time, load]

Minimum time interval in query response is one day!

# Arguments
- `outBiddingZone_Domain::Union{mappings.Area, String}`: Area for which the load data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function day_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_day_ahead_total_load(outBiddingZone_Domain, periodStart, periodEnd)
    df = xmlParser.parse_day_ahead_total_load(xml, tz) 
    return df
end

"""
    week_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the week ahaed total load forecast (article 6.1 C: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/load-domain/Data-view%20Total%20Load%20Forecast%20-%20Week%20Ahead.html). 
Parses the received HTTP response and returns the data in a dictionary.

    ("min total load" => [time, load], "max total load" => [time, load])

Minimum time interval in query response is one week!

# Arguments
- `outBiddingZone_Domain::Union{mappings.Area, String}`: Area for which the load data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function week_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_week_ahead_total_load(outBiddingZone_Domain, periodStart, periodEnd)
    df = xmlParser.parse_week_ahead_total_load(xml, tz)
    return df
end

"""
    month_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the month ahaed total load forecast (article 6.1 D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/load-domain/Data-view%20Total%20Load%20Forecast%20-%20Month%20Ahead.html). 
Parses the received HTTP response and returns the data in a dictionary.

    ("min total load" => [week, load], "max total load" => [week, load])

Minimum time interval in query response is one month!

# Arguments
- `outBiddingZone_Domain::Union{mappings.Area, String}`: Area for which the load data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function month_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_month_ahead_total_load(outBiddingZone_Domain, periodStart, periodEnd)
    df = xmlParser.parse_month_ahead_total_load(xml, tz)
    return df
end

"""
    year_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the year ahaed total load forecast (article 6.1 E: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/load-domain/Data-view%20Total%20Load%20Forecast%20-%20Year%20Ahead.html). 
Parses the received HTTP response and returns the data in a dictionary.

    ("min total load" => [week, load], "max total load" => [week, load])

Minimum time interval in query response is one year!

# Arguments
- `outBiddingZone_Domain::Union{mappings.Area, String}`: Area for which the load data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function year_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_year_ahead_total_load(outBiddingZone_Domain, periodStart, periodEnd)
    df = xmlParser.parse_year_ahead_total_load(xml, tz)
    return df
end

"""
    year_ahead_margin(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the year ahead forecast margin (article 8.1: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/load-domain/Data-view%20Forecast%20Margin%20-%20Year%20Ahead.html). 
Parses the received HTTP response and returns the data in a dataframe.

    [year, margin]

Minimum time interval in query response is one year!

# Arguments
- `outBiddingZone_Domain::Union{mappings.Area, String}`: Area for which the load data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function year_ahead_margin(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_year_ahead_margin(outBiddingZone_Domain, periodStart, periodEnd)
    df = xmlParser.parse_year_ahead_margin(xml, tz)
    return df
end

################ transmission functions #######################

"""
    forecasted_capacity(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the forecasted capacity over a certain border (article 11.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Forecasted%20Transfer%20Capacities%20-%20Day%20Ahead.html).
Parses the received HTTP response and returns the data in a dataframe.

    [time, capacity]

Minimum time interval in query response ranges from day to year, depending on selected Contract_MarketAgreementType!

# Arguments
- `contract_MarketAgreementType::String`:The specification of the kind of the agreement, e.g. long term, daily contract. Used to distinguish between day ahead, week ahead, month ahead and year ahead forecasts.
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function forecasted_capacity(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_forecasted_capacity(contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_forecasted_capacity(xml, tz)
    return df
end

"""
    offered_capacity(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = "", update_DateAndOrTime::DateTime = DateTime(0), classificationSequence_AttributeInstanceComponentPosition::String = ""])

Constructs the HTTP request for the data of the offered capacity over a certain border (article 11.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission/Data-view%20Explicit%20Allocations%20-%20Intraday.html).
Parses the received HTTP response and returns the data in a dataframe.

    [time, capacity]

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
function offered_capacity(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "", update_DateAndOrTime::DateTime = DateTime(0), classificationSequence_AttributeInstanceComponentPosition::String = "")
    xml, tz = GETconstructor.query_offered_capacity(auctionType, contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd, auctionCategory, update_DateAndOrTime, classificationSequence_AttributeInstanceComponentPosition)
    df = xmlParser.parse_offered_capacity(xml, tz)
    return df
end

"""
    flowbased(processType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the flow-based parameters of a certain area (article 11.1 B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Day%20Ahead%20Flow%20Based%20Allocations.html).
Parses the received HTTP response and returns the data in a dictionary.

    ("time" => [cb/co, RAM, domain, ..., domain])

Minimum time interval in query response is one day for day-ahead allocations!

# Arguments
- `processType::String`: The kind of the auction (e.g. implicit, explicit ...)
- `domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! 100 document limit applies !
"""
function flowbased(processType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_flowbased(processType, domain, periodStart, periodEnd)
    df = xmlParser.parse_flowbased(xml, tz)
    return df
end

"""
    intraday_transfer_limits(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the intraday transfer limits over a certain border (article 11.3: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Cross%20Border%20Capacity%20of%20DC%20Links%20-%20Intraday%20Transfer%20Limits.html).
Parses the received HTTP response and returns the data in a dataframe.

    [time, capacity]

Minimum time interval in query response ranges from part of day up to one day!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function intraday_transfer_limits(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_intraday_transfer_limits(in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_intraday_transfer_limits(xml, tz)
    return df
end

"""
    explicit_allocation_information_capacity(businessType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = ""])

Constructs the HTTP request for the data of the capacity explicitly allocated to the market over a certain border and its revenue (article 12.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission/Data-view%20Explicit%20Allocations%20-%20Day%20ahead.html).
Parses the received HTTP response and returns the data in a dataframe.

    [time, capacity [, price]]

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
function explicit_allocation_information_capacity(businessType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = "")
    xml, tz = GETconstructor.query_explicit_allocation_information_capacity(businessType, contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd, auctionCategory, classificationSequence_AttributeInstanceComponentPosition)
    df = xmlParser.parse_explicit_allocation_information_capacity(xml, tz)
    return df
end

"""
    explicit_allocation_information_revenue(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the revenue of the capacity explicitly allocated to the market over a certain border (article 12.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Explicit%20Allocations%20Revenue.html).
Parses the received HTTP response and returns the data in a dataframe.

    [time, price]

Minimum time interval in query response ranges from part of day to year, depending on selected Contract_MarketAgreementType!

# Arguments
- `contract_MarketAgreementType::String`: The specification of the kind of the agreement, e.g. long term, daily contract. Used to distinguish between day ahead, week ahead, month ahead and year ahead forecasts.
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! 100 document limit applies !
"""
function explicit_allocation_information_revenue(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_explicit_allocation_information_revenue(contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_explicit_allocation_information_revenue(xml, tz)
    return df
end

"""
    total_capacity_nominated(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the total nominated capacity over a certain border (article 12.1 B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Total%20Nominated%20Capacity.html).
Parses the received HTTP response and returns the data in a dataframe.

    [time, capacity]

Minimum time interval in query response is one day!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function total_capacity_nominated(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_total_capacity_nominated(in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_total_capacity_nominated(xml, tz)
    return df
end

"""
    total_capacity_already_allocated(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = ""])

Constructs the HTTP request for the data of the total capacity already allocated over a certain border (article 12.1 C: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission/Data-view%20Explicit%20Allocations%20-%20AAC.html).
Parses the received HTTP response and returns the data in a dataframe.

    [time, capacity]

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
function total_capacity_already_allocated(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "")
    xml, tz = GETconstructor.query_total_capacity_already_allocated(contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd, auctionCategory)
    df = xmlParser.parse_total_capacity_already_allocated(xml, tz)
    return df
end

"""
    day_ahead_prices(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the day ahead prices in a certain area (article 12.1 D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Day-ahead%20prices.html).
Parses the received HTTP response and returns the data in a dataframe.

    [time, price]

Minimum time interval in query response is one day!

# Arguments
- `domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function day_ahead_prices(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_day_ahead_prices(domain, periodStart, periodEnd)
    df = xmlParser.parse_day_ahead_prices(xml, tz)
    return df
end

"""
    implicit_auction_net_positions(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the net positions and congestion income of implictly allocated capacity over a certain border (article 12.1 E: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Intraday%20Flow%20Based%20Implicit%20Allocations%20-%20Congestion%20Income.html).
Parses the received HTTP response and returns the data in a dataframe.

    [time, import/export, capacity]

Minimum time interval in query response is one day!

# Arguments
- `businessType::String`: The identification of the nature of the data.
- `contract_MarketAgreementType::String`: The specification of the kind of the agreement, e.g. long term, daily contract. Used to distinguish between day ahead, week ahead, month ahead and year ahead forecasts.
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
! 100 documents limit applies !
"""
function implicit_auction_net_positions(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_implicit_auction_net_positions_and_congestion_income(businessType, contract_MarketAgreementType, domain, periodStart, periodEnd)
    df = xmlParser.parse_implicit_auction_net_positions(xml, tz)
    return df
end

"""
    implicit_auction_congestion_income(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the net positions and congestion income of implictly allocated capacity over a certain border (article 12.1 E: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Intraday%20Flow%20Based%20Implicit%20Allocations%20-%20Congestion%20Income.html).
Parses the received HTTP response and returns the data in a dataframe.

    [time, price]

Minimum time interval in query response is one day!

# Arguments
- `businessType::String`: The identification of the nature of the data.
- `contract_MarketAgreementType::String`: The specification of the kind of the agreement, e.g. long term, daily contract. Used to distinguish between day ahead, week ahead, month ahead and year ahead forecasts.
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
! 100 documents limit applies !
"""
function implicit_auction_congestion_income(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_implicit_auction_net_positions_and_congestion_income(businessType, contract_MarketAgreementType, domain, periodStart, periodEnd)
    df = xmlParser.parse_implicit_auction_congestion_income(xml, tz)
    return df
end

"""
    total_commercial_schedules(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the total or day ahead commercial schedules over a certain border (article 12.1 F: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Scheduled%20Commercial%20Exchanges%20-%20Day%20Ahead.html).
Parses the received HTTP response and returns the data in a dataframe.

    [time, capacity]

Minimum time interval in query response is one day!

# Arguments
- `contract_MarketAgreementType::String`: The specification of the kind of the agreement, e.g. long term, daily contract. Used to distinguish between day ahead, week ahead, month ahead and year ahead forecasts.
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function total_commercial_schedules(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_total_commercial_schedules(contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_total_commercial_schedules(xml, tz)
    return df
end

"""
    phyiscal_flows(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data of the physical flows over a certain border (article 12.1 G: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission-domain/Data-view%20Cross%20Border%20Physical%20Flows.html).
Parses the received HTTP response and returns the data in a dataframe.

    [time, capacity]

Minimum time interval in query response is MTU period!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function physical_flows(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_physical_flows(in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_physical_flows(xml, tz)
    return df
end

"""
    capacity_allocated_outside_EU(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = ""])

Constructs the HTTP request for the data of the capacity allocated outside the EU over a certain border (article 12.1 H: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission/Data-view%20Transfer%20Capacities%20Allocated%20with%20Third%20Countries.html).
Parses the received HTTP response and returns the data in a dataframe.

    [time, capacity]

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
function capacity_allocated_outside_EU(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = "")
    xml, tz = GETconstructor.query_capacity_allocated_outside_EU(auctionType, contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd, auctionCategory, classificationSequence_AttributeInstanceComponentPosition)
    df = xmlParser.parse_capacity_allocated_outside_EU(xml, tz)
    return df
end

####################### network and congestion management functions ########################

"""
    expansion_and_dismantling(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", docStatus::String = ""])

Constructs the HTTP request for the data about expansion and dismantling projects over a certain border (article 9.1: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/transmission/Data-view%20Expansion%20and%20dismantling%20projects.html).
Parses the received HTTP response and returns the data in a dataframe.

    [estimated completion date, new NTC => [start, end, new NTC], transmission assets => [code, location, type]]

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
function expansion_and_dismantling(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", docStatus::String = "")
    xml, tz = GETconstructor.query_expansion_and_dismantling(in_Domain, out_Domain, periodStart, periodEnd, businessType, docStatus)
    df = xmlParser.parse_expansion_and_dismantling(xml, tz)
    return df
end

"""
    redispatching(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = ""])

Constructs the HTTP request for the data about redispatching over a certain border (article 13.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/congestion-management/Data-view%20Redispatching.html).
Parses the received HTTP response and returns the data in a dataframe.

    [start, end, reason, impact => [start, end, impact], affected assets => [code, location, type]]

Time interval in query response depends on duration of matching redispatches!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data

! 100 document limit applies !
"""
function redispatching(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "")
    xml, tz = GETconstructor.query_redispatching(in_Domain, out_Domain, periodStart, periodEnd, businessType)
    df = xmlParser.parse_redispatching(xml, tz)
    return df
end

"""
    countertrading(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about countertrading over a certain border (article 13.1 B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/congestion-management/Data-view%20Countertrading.html).
Parses the received HTTP response and returns the data in a dataframe.

    [start, end, reason, change in cross-border exchange => [start, end, change in cross-border exchange]]

Time interval in query response depends on duration of matching counter trades!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data

! 100 document limit applies !
"""
function countertrading(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_countertrading(in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_countertrading(xml, tz)
    return df
end

"""
    congestion_costs(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = ""])

Constructs the HTTP request for the data about the congestion management costs over a certain border (article 13.1 C: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/congestion-management/Data-view%20Costs.html).
Parses the received HTTP response and returns the data in a dataframe.

    [start, end, costs]

Minimum time interval in query response is one month!

# Arguments
- `domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data

! 100 document limit applies !
"""
function congestion_costs(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "")
    xml, tz = GETconstructor.query_congestion_costs(domain, periodStart, periodEnd, businessType)
    df = xmlParser.parse_congestion_costs(xml, tz)
    return df
end

##################### generation functions #######################

"""
    installed_generation_capacity_aggregated(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about the aggregated installed generation capacity in a certain area (article 14.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Installed%20Capacity%20per%20Production%20Type.html).
Parses the received HTTP response and returns the data in a dataframe.

    [year, type, installed capacity]

Minimum time interval in query response is one year!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.

! One year range limit applies !
"""
function installed_generation_capacity_aggregated(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
    xml, tz = GETconstructor.query_installed_generation_capacity_aggregated(in_Domain, periodStart, periodEnd, psrType)
    df = xmlParser.parse_installed_generation_capacity_aggregated(xml, tz)
    return df
end

"""
    installed_generation_capacity_per_unit(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about the installed generation capacity per unit in a certain area (article 14.1 B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Installed%20Capacity%20per%20Production%20Unit.html).
Parses the received HTTP response and returns the data in a dataframe.

    [production type, code, name, installed capacity at the beginning of the year, voltage connection level]

Minimum time interval in query response is one year!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset. If not used all resources are included.

! One year range limit applies !
"""
function installed_generation_capacity_per_unit(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
    xml, tz = GETconstructor.query_installed_generation_capacity_per_unit(in_Domain, periodStart, periodEnd, psrType)
    df = xmlParser.parse_installed_generation_capacity_per_unit(xml)
    return df
end

"""
    day_ahead_aggregated_generation(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the day ahead forecast of aggregated generation in a certain area (article 14.1 C: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Generation%20Forecast%20-%20Day%20Ahead.html).
Parses the received HTTP response and returns the data in a dictionary.

    ("generation" => [start, end, scheduled generation], "consumption" => [start, end, scheduled consumption])

Minimum time interval in query response is one day!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function day_ahead_aggregated_generation(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_day_ahead_aggregated_generation(in_Domain, periodStart, periodEnd)
    df = xmlParser.parse_day_ahead_aggregated_generation(xml, tz)
    return df
end

"""
    day_ahead_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about the day ahead forecast of wind and solar generation in a certain area (article 14.1 D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Generation%20Forecasts%20-%20Day%20Ahead%20for%20Wind%20and%20Solar.html).
Parses the received HTTP response and returns the data in a dictionary.

    ("solar" => [start, end, solar], "wind offshore" => [start, end, wind offshore], "wind onshore" => [start, end, wind onshore])

Minimum time interval in query response is one day!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset. If not used all resources are included.

! One year range limit applies !
"""
function day_ahead_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
    xml, tz = GETconstructor.query_day_ahead_generation_forecasts_wind_solar(in_Domain, periodStart, periodEnd, psrType)
    df = xmlParser.parse_day_ahead_generation_forecasts_wind_solar(xml, tz)
    return df
end

"""
    current_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about the current forecast of wind and solar generation in a certain area (article 14.1 D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Generation%20Forecast%20-%20Day%20Ahead.html).
Parses the received HTTP response and returns the data in a dictionary.

    ("solar" => [start, end, solar], "wind offshore" => [start, end, wind offshore], "wind onshore" => [start, end, wind onshore])

Minimum time interval in query response is one day!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset. If not used all resources are included.

! One year range limit applies !
"""
function current_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
    xml, tz = GETconstructor.query_current_generation_forecasts_wind_solar(in_Domain, periodStart, periodEnd, psrType)
    df = xmlParser.parse_current_generation_forecasts_wind_solar(xml, tz)
    return df
end

"""
    intraday_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about the intraday forecast of wind and solar generation in a certain area (article 14.1 D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Generation%20Forecast%20-%20Day%20Ahead.html).
Parses the received HTTP response and returns the data in a dictionary.

    ("solar" => [start, end, solar], "wind offshore" => [start, end, wind offshore], "wind onshore" => [start, end, wind onshore])

Minimum time interval in query response is one MTU period!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset. If not used all resources are included.

! One year range limit applies !
"""
function intraday_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
    xml, tz = GETconstructor.query_intraday_generation_forecasts_wind_solar(in_Domain, periodStart, periodEnd, psrType)
    df = xmlParser.parse_intraday_generation_forecasts_wind_solar(xml, tz)
    return df
end

"""
    actual_generation_per_generation_unit(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = "", registeredResource::String = ""])

Constructs the HTTP request for the data about the actual generation per generation unit in a certain area (article 16.1 A: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Actual%20Generation%20per%20Generation%20Unit.html).
Parses the received HTTP response and returns the data in a dictionary.

    NOT IMPLEMENTED YET

Minimum time interval in query response is one MTU period!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset. If not used all resources are included.
- `registeredResource = ""`: The unique identification of a resource

! One day range limit applies !
"""
function actual_generation_per_generation_unit(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "", registeredResource::String = "")
    xml, tz = GETconstructor.query_actual_generation_per_generation_unit(in_Domain, periodStart, periodEnd, psrType, registeredResource)
    df = xmlParser.parse_actual_generation_per_generation_unit(xml, tz)
    return df
end

"""
    aggregated_generation_per_type(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about the actual aggregated generation per plant type in a certain area (article 16.1 B&C: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Actual%20Generation%20per%20Production%20Unit.html).
Parses the received HTTP response and returns the data in a dictionary.

    ("type" => [start, end, aggregated generation])

Minimum time interval in query response is one MTU period!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset. If not used all resources are included.

! One year range limit applies !
"""
function aggregated_generation_per_type(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
    xml, tz = GETconstructor.query_aggregated_generation_per_type(in_Domain, periodStart, periodEnd, psrType)
    df = xmlParser.parse_aggregated_generation_per_type(xml, tz)
    return df
end

"""
    aggregated_filling_rate(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the aggregated filling rate of water reservoirs and hydro storage plants in a certain area (article 16.1 D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/generation/Data-view%20Water%20Reservoirs%20and%20Hydro%20Storage%20Plants.html).
Parses the received HTTP response and returns the data in a dictionary.

    [year, week, stored energy value]

Minimum time inteval in query response is one week!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function aggregated_filling_rate(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_aggregated_filling_rate(in_Domain, periodStart, periodEnd)
    df = xmlParser.parse_aggregated_filling_rate(xml, tz)
    return df
end

#################### master data ###########################

"""
    production_generation_units(biddingZone_Domain::Union{mappings.Area, String}, implementation_DateAndOrTime::DateTime[, psrType::String = ""])

Constructs the HTTP request for the data about existing generation and production units on a certain day in a certain area.
Parses the received HTTP response and returns the data in a dictionary.

    NOT IMPLEMENTED YET

Response contains commissioned production units for given day!

# Arguments
- `biddingZone_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `implementation_DateAndOrTime::DateTime`: Date for which the data is needed
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset. If not used all resources are included.

! One day range limit applies !
"""
function production_generation_units(biddingZone_Domain::Union{mappings.Area, String}, implementation_DateAndOrTime::DateTime, psrType::String = "")
    xml, tz = GETconstructor.query_production_generation_units(biddingZone_Domain, implementation_DateAndOrTime, psrType)
    df = xmlParser.parse_production_generation_units(xml, tz)
    return df
end

#################### balancing domain data ####################

"""
    current_balancing_state(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the current balancing state in a certain area (article GL EB 12.3 A).
Parses the received HTTP response and returns the data in a dataframe.

    [start, end, situation, open loop ace]

# Arguments
- `area_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! 100 day range limit applies !
"""
function current_balancing_state(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_current_balancing_state(area_Domain, periodStart, periodEnd)
    df = xmlParser.parse_current_balancing_state(xml, tz)
    return df
end

"""
    balancing_energy_bids(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, processType::String)

Constructs the HTTP request for the data about the balancing energy bids in a certain area (article GL EB 12.3 B-D).
Parses the received HTTP response and returns the data in a dataframe.

    NOT IMPLEMENTED YET

# Arguments
- `processType::String`: identifies the type of processing to be carried out on the information
- `area_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! 1 day range limit applies !
"""
function balancing_energy_bids(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, processType::String)
    xml, tz = GETconstructor.query_balancing_energy_bids(area_Domain, periodStart, periodEnd, processType)
    df = xmlParser.parse_balancing_energy_bids(xml, tz)
    return df
end

"""
    aggregated_balancing_energy_bids(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, processType::String)

Constructs the HTTP request for the data about the aggregated balancing energy bids in a certain area (article GL EB 12.3 E: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/balancing/Data-view%20Aggregated%20Bids.html).
Parses the received HTTP response and returns the data in a dataframe.

    [start, end, type of product, direction, offered, activated, unavailable]

# Arguments
- `area_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `processType::String`:  identifies the type of processing to be carried out on the information

! One year range limit applies !
"""
function aggregated_balancing_energy_bids(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, processType::String)
    xml, tz = GETconstructor.query_aggregated_balancing_energy_bids(area_Domain, periodStart, periodEnd, processType)
    df = xmlParser.parse_aggregated_balancing_energy_bids(xml, tz)
    return df
end

"""
    procured_balancing_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, type_MarketAgreementType::String = ""])

Constructs the HTTP request for the data about the produced balancing capacity in a certain area (article GL EB 12.3 F: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/balancing/Data-view%20Procured%20Capacity.html).
Parses the received HTTP response and returns the data in a dataframe.

    NOT IMPLEMENTED YET

# Arguments
- `area_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `type_MarketAgreementType::String = ""`: Indicates the time horizon for which balancing capacity was procured

! 100 document limit applies !
"""
function procured_balancing_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, type_MarketAgreementType::String = "")
    xml, tz = GETconstructor.query_procured_balancing_capacity(area_Domain, periodStart, periodEnd, type_MarketAgreementType)
    df = xmlParser.parse_procured_balancing_capacity(xml, tz)
    return df
end

"""
    crossZonal_balancing_capacity(acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the use of the allocated cross-zonal balancing capacity over a certain border (article GL EB 12.3 H&I: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/balancing/Data-view%20Use%20of%20allocated%20cross-zonal%20balancing%20capacity.html).
Parses the received HTTP response and returns the data in a dataframe.

    NOT IMPLEMENTED YET

# Arguments
- `acquiring_Domain::Union{mappings.Area, String}`: 
- `connecting_Domain::Union{mappings.Area, String}`: 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `type_MarketAgreementType::String = ""`: Indicates the time horizon for which balancing capacity was procured
"""
function crossZonal_balancing_capacity(acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_crossZonal_balancing_capacity(acquiring_Domain, connecting_Domain, periodStart, periodEnd)
    df = xmlParser.parse_crossZonal_balancing_capacity(xml, tz)
    return df
end

"""
    volumes_and_prices_contracted_reserves(type_MarketAgreementType::String, processType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, psrType::String = "", offset::Int = 0])

Constructs the HTTP request for the data about the prices and the volumes of the contracted reserves in a certain area (article 17.1 B&C).
Parses the received HTTP response and returns the data in a dataframe.

    NOT IMPLEMENTED YET

Minimum time interval in query response ranges from part of day to year, depending on selected Type_MarketAgreement.Type!

# Arguments
- `type_MarketAgreementType::String`: Indicates the time horizon for which balancing capacity was procured
- `processType::String`:  identifies the type of processing to be carried out on the information
- `controlArea_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.
- `offset::Int = 0`: allows downloading more than 100 documents. The offset ∈ [0,4800] so that paging is restricted to query for 4900 documents max., offset=n returns files in sequence between n+1 and n+100

! 100 document limit applies !
"""
function volumes_and_prices_contracted_reserves(type_MarketAgreementType::String, processType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "", offset::Int = 0)
    xml, tz = GETconstructor.query_volumes_and_prices_contracted_reserves(type_MarketAgreementType, processType, controlArea_Domain, periodStart, periodEnd, psrType, offset)
    df = xmlParser.parse_volumes_and_prices_contracted_reserves(xml, tz)
    return df
end

"""
    volumes_contracted_reserves(type_MarketAgreementType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = "", offset::Int = 0])

Constructs the HTTP request for the data about the volumes of the contracted reserves in a certain area (article 17.1 B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/balancing/Data-view%20Volumes%20of%20Contracted%20Balancing%20Reserves.html).
Parses the received HTTP response and returns the data in a dataframe.

    [start, end, reserve type, regulation volume, direction]

Minimum time interval in query response ranges from part of day to year, depending on selected Type_MarketAgreement.Type!

# Arguments
- `type_MarketAgreementType::String`: Indicates the time horizon for which balancing capacity was procured
- `controlArea_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.
- `offset::Int = 0`: allows downloading more than 100 documents. The offset ∈ [0,4800] so that paging is restricted to query for 4900 documents max., offset=n returns files in sequence between n+1 and n+100

! 100 document limit applies !
! Doesn't work for hourly data due to some unclear reason... !
"""
function volumes_contracted_reserves(type_MarketAgreementType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", psrType::String = "", offset::Int = 0)
    xml, tz = GETconstructor.query_volumes_contracted_reserves(type_MarketAgreementType, controlArea_Domain, periodStart, periodEnd, businessType, psrType, offset)
    df = xmlParser.parse_volumes_contracted_reserves(xml, tz)
    return df
end

"""
    prices_contracted_reserves(type_MarketAgreementType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = "", offset::Int = 0])

Constructs the HTTP request for the data about the prices of the contracted reserves in a certain area (article 17.1 C: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/balancing/Data-view%20Price%20of%20Reserved%20Balancing%20Reserves.html).
Parses the received HTTP response and returns the data in a dataframe.

    [start, end, reserve type, regulation price, direction, price type]

Minimum time interval in query response ranges from part of day to year, depending on selected Type_MarketAgreement.Type!

# Arguments
- `type_MarketAgreementType::String`: Indicates the time horizon for which balancing capacity was procured
- `controlArea_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.
- `offset::Int = 0`: allows downloading more than 100 documents. The offset ∈ [0,4800] so that paging is restricted to query for 4900 documents max., offset=n returns files in sequence between n+1 and n+100

! 100 document limit applies !
"""
function prices_contracted_reserves(type_MarketAgreementType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", psrType::String = "", offset::Int = 0)
    xml, tz = GETconstructor.query_prices_contracted_reserves(type_MarketAgreementType, controlArea_Domain, periodStart, periodEnd, businessType, psrType, offset)
    df = xmlParser.parse_prices_contracted_reserves(xml, tz)
    return df
end

"""
    accepted_aggregated_offers(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = ""])

Constructs the HTTP request for the data about the accepted aggregated offers in a certain area (article 17.1 D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/balancing/Data-view%20Accepted%20Offers%20and%20Activated%20Balancing%20Reserves.html).
Parses the received HTTP response and returns the data in a dataframe.

    [start, end, reserve type, source, activated reserves, direction]

Minimum time interval in query response is one BTU period!

# Arguments
- `controlArea_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.

! One year range limit applies !
"""
function accepted_aggregated_offers(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", psrType::String = "")
    xml, tz = GETconstructor.query_accepted_aggregated_offers(controlArea_Domain, periodStart, periodEnd, businessType, psrType)
    df = xmlParser.parse_accepted_aggregated_offers(xml, tz)
    return df
end

"""
    activated_balancing_energy(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = ""])

Constructs the HTTP request for the data about the activated balancing energy in a certain area (article 17.1 E: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/balancing/Data-view%20Accepted%20Offers%20and%20Activated%20Balancing%20Reserves.html).
Parses the received HTTP response and returns the data in a dataframe.

    [start, end, reserve type, source, activated energy, direction]

Minimum time interval in query response is one BTU period!

# Arguments
- `controlArea_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.

! One year range limit applies !
"""
function activated_balancing_energy(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", psrType::String = "")
    xml, tz = GETconstructor.query_activated_balancing_energy(controlArea_Domain, periodStart, periodEnd, businessType, psrType)
    df = xmlParser.parse_activated_balancing_energy(xml, tz)
    return df
end

"""
    prices_activated_balancing_energy(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", psrType::String = ""])

Constructs the HTTP request for the data about the prices of the activated balancing energy in a certain area (article 17.1 F: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/balancing/Data-view%20Accepted%20Offers%20and%20Activated%20Balancing%20Reserves.html).
Parses the received HTTP response and returns the data in a dataframe.

    [start, end, reserve type, source, price type, price, direction]

Minimum time interval in query response is one BTU period!

# Arguments
- `controlArea_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data
- `psrType::String = ""`: The coded type of a power system resource. The classification for the asset.

! One year range limit applies !
"""
function prices_activated_balancing_energy(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", psrType::String = "")
    xml, tz = GETconstructor.query_prices_activated_balancing_energy(controlArea_Domain, periodStart, periodEnd, businessType, psrType)
    df = xmlParser.parse_prices_activated_balancing_energy(xml, tz)
    return df
end

"""
    imbalance_prices(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the imbalance prices in a certain area (article 17.1 G: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/balancing/Data-view%20Imbalance.html).
Parses the received HTTP response and returns the data in a dataframe.

    NOT IMPLEMENTED YET

Minimum time interval in query response is one BTU period!

# Arguments
- `controlArea_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function imbalance_prices(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_imbalance_prices(controlArea_Domain, periodStart, periodEnd)
    df = xmlParser.parse_imbalance_prices(xml, tz)
    return df
end

"""
    total_imbalance_volumes(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the imbalance volumes in a certain area (article 17.1 H: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/balancing/Data-view%20Imbalance.html).
Parses the received HTTP response and returns the data in a dataframe.

    [start, end, volume, difference, situation, status]

Minimum time interval in query response is one BTU period!

# Arguments
- `controlArea_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function total_imbalance_volumes(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_total_imbalance_volumes(controlArea_Domain, periodStart, periodEnd)
    df = xmlParser.parse_total_imbalance_volumes(xml, tz)
    return df
end

"""
    financial_expenses(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the financial expenses and income for balancing in a certain area (article 17.1 I: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/balancing/Data-view%20Financial%20Expenses%20and%20Income.html).
Parses the received HTTP response and returns the data in a dataframe.

    [start, end, income, expenses, status]

Minimum time interval in query response is one month!

# Arguments
- `controlArea_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function financial_expenses(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_financial_expenses(controlArea_Domain, periodStart, periodEnd)
    df = xmlParser.parse_financial_expenses(xml, tz)
    return df
end

"""
    crossBorder_balancing(acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the cross-border balancing over a certain border (article 17.1 J: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/balancing/Data-view%20Cross-Border%20Balancing.html).
Parses the received HTTP response and returns the data in a dataframe.

    NOT YET IMPLEMENTED

Minimum time interval in query response is one BTU period!

# Arguments
- `acquiring_Domain::Union{mappings.Area, String}`: 
- `connecting_Domain::Union{mappings.Area, String}`: 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function crossBorder_balancing(acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_crossBorder_balancing(acquiring_Domain, connecting_Domain, periodStart, periodEnd)
    df = xmlParser.parse_crossBorder_balancing(xml, tz)
    return df
end

"""
    FCR_total_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the FCR total capacity in a certain area (article SO GL 187.2).
Parses the received HTTP response and returns the data in a dataframe.

    NOT YET IMPLEMENTED

# Arguments
- `area_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function FCR_total_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_FCR_total_capacity(area_Domain, periodStart, periodEnd)
    df = xmlParser.parse_FCR_total_capacity(xml, tz)
    return df
end

"""
    share_capacity_FCR(area_Domain::Union{mappings.Area, String}, periodStart::Datetime, periodEnd::DateTime)

Constructs the HTTP request for the data about the share of FCR capacity in a certain area (article SO GL 187.2).
Parses the received HTTP response and returns the data in a dataframe.

    NOT YET IMPLEMENTED

# Arguments
- `area_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function share_capacity_FCR(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_share_capacity_FCR(area_Domain, periodStart, periodEnd)
    df = xmlParser.parse_share_capacity_FCR(xml, tz)
    return df
end

"""
    contracted_reserve_capacity_FCR(area_Domain::Union{mappings.Area}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the share of contracted reserve FCR capacity in a certain area (article SO GL 187.2).
Parses the received HTTP response and returns the data in a dataframe.

    NOT YET IMPLEMENTED

# Arguments
- `area_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function contracted_reserve_capacity_FCR(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_contracted_reserve_capacity_FCR(area_Domain, periodStart, periodEnd)
    df = xmlParser.parse_contracted_reserve_capacity_FCR(xml, tz)
    return df
end

"""
    FRR_actual_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the actual FRR capacity in a certain area (article SO GL 188.4).
Parses the received HTTP response and returns the data in a dataframe.

    NOT YET IMPLEMENTED

# Arguments
- `area_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One quarter range limit applies !
"""
function FRR_actual_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_FRR_actual_capacity(area_Domain, periodStart, periodEnd)
    df = xmlParser.parse_FRR_actual_capacity(xml, tz)
    return df
end

"""
    RR_actual_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the actual RR capacity in a certain area (article SO GL 189.3).
Parses the received HTTP response and returns the data in a dataframe.

    NOT YET IMPLEMENTED

# Arguments
- `area_Domain::Union{mappings.Area, String}`: The area for which the data is needed, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One quarter range limit applies !
"""
function RR_actual_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_RR_actual_capacity(area_Domain, periodStart, periodEnd)
    df = xmlParser.parse_RR_actual_capacity(xml, tz)
    return df
end

"""
    sharing_of_reserves(processType::String, acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

Constructs the HTTP request for the data about the sharing of RR and FRR over a certain border (article SO GL 190.1).
Parses the received HTTP response and returns the data in a dataframe.

    NOT YET IMPLEMENTED

# Arguments
- `processType::String`:  identifies the type of processing to be carried out on the information
- `acquiring_Domain::Union{mappings.Area, String}`: 
- `connecting_Domain::Union{mappings.Area, String}`: 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 

! One year range limit applies !
"""
function sharing_of_reserves(processType::String, acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_sharing_of_reserves(processType, acquiring_Domain, connecting_Domain, periodStart, periodEnd)
    df = xmlParser.parse_sharing_of_reserves(xml, tz)
    return df
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function balancing_border_capacity_limitations()
    xml, tz = GETconstructor.query_balancing_border_capacity_limitations()
    df = xmlParser.parse_balancing_border_capacity_limitation(xml, tz)
    return df
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function permanent_allocation_limitations_HVDC()
    xml, tz = GETconstructor.query_permanent_allocation_limitations_HVDC()
    df = xmlParser.parse_permanent_allocation_limitations_HVDC(xml, tz)
    return df
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function netted_and_exchanged_volumes()
    xml, tz = GETconstructor.query_netted_and_exchanged_volumes()
    df = xmlParser.parse_netted_and_exchanged_volumes(xml, tz)
    return df
end

######################### Outages data ################################

"""
    unavailability_consumption_units(biddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = ""])

Constructs the HTTP request for the data about the unavailability of consumption units in a certain area (article 7.1 A&B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/outage-domain/Data-view%20Aggregated%20Unavailability%20of%20Consumption%20Units.html).
Parses the received HTTP response and returns the data in a dataframe.

    NOT YET IMPLEMENTED

Minimum time interval in query response is one MTU period!

# Arguments
- `biddingZone_Domain::Union{mappings.Area, String}`: Area for which the outages data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data

! One year range limit applies !
"""
function unavailability_consumption_units(biddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "")
    xml, tz = GETconstructor.query_unavailability_consumption_units(biddingZone_Domain, periodStart, periodEnd, businessType)
    df = xmlParser.parse_unavailability_consumption_units(xml, tz)
    return df
end

"""
    unavailability_generation_units(biddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", docStatus::String = "", periodStartUpdate::DateTime = DateTime(0), periodEndUpdate::DateTime = DateTime(0), registeredResource::String = "", mRID::String = "", offset::Int = 0])

Constructs the HTTP request for the data about the unavailability of generation units in a certain area (article 15.1 A&B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/outage-domain/Data-view%20Unavailability%20of%20Production%20and%20Generation%20Units.html).
Parses the received HTTP response and returns the data in a dataframe.

    NOT YET IMPLEMENTED

Minimum time interval in query response depends on duration of matching outages!

# Arguments
- `biddingZone_Domain::Union{mappings.Area, String}`: Area for which the outages data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data
- `docStatus::String = ""`: Identification of the condition or position of the document with regard to its standing
- `periodStartUpdate::DateTime = DatetTime(0)`:
- `periodEndUpdate::DateTime = DateTime(0)`: 
- `registeredResource::String = ""`: The unique identification of a resource
- `mrRID::String = ""`: Unique identification of the document being exchanged within a business process flow
- `offset::Int = 0`: allows downloading more than 200 documents. The offset ∈ [0,4800] so that paging is restricted to query for 4900 documents max., offset=n returns files in sequence between n+1 and n+200

! One year range limit applies !
! 200 documents limit applies !
"""
function unavailability_generation_units(biddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", docStatus::String = "", periodStartUpdate::DateTime = DateTime(0), periodEndUpdate::DateTime = DateTime(0), registeredResource::String = "", mRID::String = "", offset::Int = 0)
    xml, tz = GETconstructor.query_unavailability_generation_units(biddingZone_Domain, periodStart, periodEnd, businessType, docStatus, periodStartUpdate, periodEndUpdate, registeredResource, mRID, offset)
    df = xmlParser.parse_unavailability_generation_units(xml, tz)
    return df
end

"""
    unavailability_production_units(biddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", docStatus::String = "", periodStartUpdate::DateTime = DateTime(0), periodEndUpdate::DateTime = DateTime(0), registeredResource::String = "", mRID::String = "", offset::Int = 0])

Constructs the HTTP request for the data about the unavailability of production units in a certain area (article 15.1 C&D: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/outage-domain/Data-view%20Unavailability%20of%20Production%20and%20Generation%20Units.html).
Parses the received HTTP response and returns the data in a dataframe.

    NOT YET IMPLEMENTED

Minimum time interval in query response depends on duration of matching outages!

# Arguments
- `biddingZone_Domain::Union{mappings.Area, String}`: Area for which the outages data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data
- `docStatus::String = ""`: Identification of the condition or position of the document with regard to its standing
- `periodStartUpdate::DateTime = DatetTime(0)`:
- `periodEndUpdate::DateTime = DateTime(0)`: 
- `registeredResource::String = ""`: The unique identification of a resource
- `mrRID::String = ""`: Unique identification of the document being exchanged within a business process flow
- `offset::Int = 0`: allows downloading more than 200 documents. The offset ∈ [0,4800] so that paging is restricted to query for 4900 documents max., offset=n returns files in sequence between n+1 and n+200

! One year range limit applies !
! 200 documents limit applies !
"""
function unavailability_production_units(biddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", docStatus::String = "", periodStartUpdate::DateTime = DateTime(0), periodEndUpdate::DateTime = DateTime(0), registeredResource::String = "", mRID::String = "", offset::Int = 0)
    xml, tz = GETconstructor.query_unavailability_production_units(biddingZone_Domain, periodStart, periodEnd, businessType, docStatus, periodStartUpdate, periodEndUpdate, registeredResource, mRID, offset)
    df = xmlParser.parse_unavailability_production_units(xml, tz)
    return df
end

"""
    unavailability_offshore_grid(biddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, docStatus::String = "", periodStartUpdate::DateTime = DateTime(0), periodEndUpdate::DateTime = DateTime(0), mRID::String = "", offset::Int = 0])

Constructs the HTTP request for the data about the unavailability of the offshore grid infrastructure in a certain area (article 10.1 C: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/outage-domain/Data-view%20Unavailability%20of%20off-shore%20grid.html).
Parses the received HTTP response and returns the data in a dataframe.

    NOT YET IMPLEMENTED

Minimum time interval in query response depends on duration of matching outages!

# Arguments
- `biddingZone_Domain::Union{mappings.Area, String}`: Area for which the outages data is needed, can be represented as an Area object or a string with country code or direct code 
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `docStatus::String = ""`: Identification of the condition or position of the document with regard to its standing
- `periodStartUpdate::DateTime = DatetTime(0)`:
- `periodEndUpdate::DateTime = DateTime(0)`: 
- `registeredResource::String = ""`: The unique identification of a resource
- `mrRID::String = ""`: Unique identification of the document being exchanged within a business process flow
- `offset::Int = 0`: allows downloading more than 200 documents. The offset ∈ [0,4800] so that paging is restricted to query for 4900 documents max., offset=n returns files in sequence between n+1 and n+200

! One year range limit applies !
! 200 documents limit applies !
"""
function unavailability_offshore_grid(biddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, docStatus::String = "", periodStartUpdate::DateTime = DateTime(0), periodEndUpdate::DateTime = DateTime(0), mRID::String = "", offset::Int = 0)
    xml, tz = GETconstructor.query_unavailability_offshore_grid(biddingZone_Domain, periodStart, periodEnd, docStatus, periodStartUpdate, periodEndUpdate, mRID, offset)
    df = xmlParser.parse_unavailability_offshore_grid(xml, tz)
    return df
end

"""
    unavailability_transmission_infrastructure(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime[, businessType::String = "", docStatus::String = "", periodStartUpdate::DateTime = DateTime(0), periodEndUpdate::DateTime = DateTime(0), mRID::String = "", offset::Int = 0])

Constructs the HTTP request for the data about the unavailability of the transmission infrastructure in a certain area (article 10.1 A&B: https://transparency.entsoe.eu/content/static_content/Static%20content/knowledge%20base/data-views/outage-domain/Data-view%20Unavailability%20in%20Transmission%20Grid.html).
Parses the received HTTP response and returns the data in a dataframe.

    NOT YET IMPLEMENTED

Minimum time interval in query response depends on duration of matching outages!

# Arguments
- `in_Domain::Union{mappings.Area, String}`: The area where energy is going, can be represented as an Area object or a string with country code or direct code 
- `out_Domain::Union{mappings.Area, String}`: The area where energy is coming from, can be represented as an Area object or a string with country code or direct code
- `periodStart::DateTime`: Start date and time of the needed data
- `periodEnd::DateTime`: End date and time of the needed data 
- `businessType::String = ""`: The identification of the nature of the data
- `docStatus::String = ""`: Identification of the condition or position of the document with regard to its standing
- `periodStartUpdate::DateTime = DatetTime(0)`: 
- `periodEndUpdate::DateTime = DateTime(0)`: 
- `registeredResource::String = ""`: The unique identification of a resource
- `mrRID::String = ""`: Unique identification of the document being exchanged within a business process flow
- `offset::Int = 0`: allows downloading more than 200 documents. The offset ∈ [0,4800] so that paging is restricted to query for 4900 documents max., offset=n returns files in sequence between n+1 and n+200

! One year range limit applies !
! 200 documents limit applies !
"""
function unavailability_transmission_infrastructure(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", docStatus::String = "", periodStartUpdate::DateTime = DateTime(0), periodEndUpdate::DateTime = DateTime(0), mRID::String = "", offset::Int = 0)
    xml, tz = GETconstructor.query_unavailability_transmission_infrastructure(in_Domain, out_Domain, periodStart, periodEnd, businessType, docStatus, periodStartUpdate, periodEndUpdate, mRID, offset)
    df = xmlParser.parse_unavailability_transmission_infrastructure(xml, tz)
    return df
end

############ STILL NEEDS TO BE IMPLEMENTED ################

function fallBacks()
    xml, tz = GETconstructor.query_fallBacks()
    df = xmlParser.parse_fallBacks(xml, tz)
    return df
end

end



















