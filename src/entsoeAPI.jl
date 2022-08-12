module entsoeAPI

include("GETconstructor.jl")
include("xmlParser.jl")
using .GETconstructor
using .xmlParser
using DataFrames
using Dates

function actual_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_actual_total_load(outBiddingZone_Domain, periodStart, periodEnd)
    df = xmlParser.parse_actual_total_load(xml, tz)
    return df
end

function day_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_day_ahead_total_load(outBiddingZone_Domain, periodStart, periodEnd)
    df = xmlParser.parse_day_ahead_total_load(xml, tz) 
    return df
end

function week_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_week_ahead_total_load(outBiddingZone_Domain, periodStart, periodEnd)
    df = xmlParser.parse_week_ahead_total_load(xml, tz)
    return df
end

function month_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_month_ahead_total_load(outBiddingZone_Domain, periodStart, periodEnd)
    df = xmlParser.parse_month_ahead_total_load(xml, tz)
    return df
end

function year_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_year_ahead_total_load(outBiddingZone_Domain, periodStart, periodEnd)
    df = xmlParser.parse_year_ahead_total_load(xml, tz)
    return df
end

function year_ahead_margin(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_year_ahead_margin(outBiddingZone_Domain, periodStart, periodEnd)
    df = xmlParser.parse_year_ahead_margin(xml, tz)
    return df
end

function forecasted_capacity(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_forecasted_capacity(contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_forecasted_capacity(xml, tz)
    return df
end

function offered_capacity(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "", update_DateAndOrTime::DateTime = DateTime(0), classificationSequence_AttributeInstanceComponentPosition::String = "")
    xml, tz = GETconstructor.query_offered_capacity(auctionType, contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd, auctionCategory, update_DateAndOrTime, classificationSequence_AttributeInstanceComponentPosition)
    df = xmlParser.parse_offered_capacity(xml, tz)
    return df
end

function flowbased(processType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_flowbased(processType, domain, periodStart, periodEnd)
    df = xmlParser.parse_flowbased(xml, tz)
    return df
end

function intraday_transfer_limits(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_intraday_transfer_limits(in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_intraday_transfer_limits(xml, tz)
    return df
end

function explicit_allocation_information_capacity(businessType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = "")
    xml, tz = GETconstructor.query_exlplicit_allocation_information_capacity(businessType, contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd, auctionCategory, classificationSequence_AttributeInstanceComponentPosition)
    df = xmlParser.parse_explicit_allocation_information_capacity(xml, tz)
    return df
end

function explicit_allocation_information_revenue(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_explicit_allocation_information_revenue(contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_explicit_allocation_information_revenue(xml, tz)
    return df
end

function total_capacity_nominated(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_total_capacity_nominated(in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_total_capacity_nominated(xml, tz)
    return df
end

function total_capacity_already_allocated(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "")
    xml, tz = GETconstructor.query_total_capaciyt_already_allocated(contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd, auctionCategory)
    df = xmlParser.parse_total_capacity_already_allocated(xml, tz)
    return df
end

function day_ahead_prices(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_day_ahead_prices(domain, periodStart, periodEnd)
    df = xmlParser.parse_day_ahead_prices(xml, tz)
    return df
end

function implicit_auction_net_positions(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_implicit_auction_net_positions_and_congestion_income(businessType, contract_MarketAgreementType, domain, periodStart, periodEnd)
    df = xmlParser.parse_implicit_auction_net_positions(xml, tz)
    return df
end

function implicit_auction_congestion_income(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_implicit_auction_net_positions_and_congestion_income(businessType, contract_MarketAgreementType, domain, periodStart, periodEnd)
    df = xmlParser.parse_implicit_auction_congestion_income(xml, tz)
    return df
end

function total_commercial_schedules(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_total_commercial_schedules(contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_total_commercial_schedules(xml, tz)
    return df
end

function phyiscal_flows(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_phyiscal_flows(in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_total_commercial_schedules(xml, tz)
    return df
end

function capacity_allocated_outside_EU(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = "")
    xml, tz = GETconstructor.query_capacity_allocated_outside_EU(auctionType, contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd, auctionCategory, classificationSequence_AttributeInstanceComponentPosition)
    df = xmlParser.parse_capacity_allocated_outside_EU(xml, tz)
    return df
end

function expansion_and_dismantling(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", docStatus::String = "")
    xml, tz = GETconstructor.query_expansion_and_dismantling(in_Domain, out_Domain, periodStart, periodEnd, businessType, docStatus)
    df = xmlParser.parse_expansion_and_dismantling(xml, tz)
    return df
end

function redispatching(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "")
    xml, tz = GETconstructor.query_redispatching(in_Domain, out_Domain, periodStart, periodEnd, businessType)
    df = xmlParser.parse_redispatching(xml, tz)
    return df
end

function countertrading(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
    xml, tz = GETconstructor.query_countertrading(in_Domain, out_Domain, periodStart, periodEnd)
    df = xmlParser.parse_countertrading(xml, tz)
    return df
end

function congestion_costs(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "")
    xml, tz = GETconstructor(domain, periodStart, periodEnd, businessType)
    df = xmlParser.parse_congestion_costs(xml, tz)
    return df
end








