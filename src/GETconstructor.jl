module GETconstructor

include("mappings.jl")
include("argumentLimitations.jl")
using .mappings
using .argumentLimitations
using HTTP

############# general functions ######################

URL = "https://transparency.entsoe.eu/api?"
global key = ""

function initialize_key(APIkey::String)
    global key = APIkey
    return key
end

"""
    Creates HTTP request based on a Dictionary with parameters and a security.
    Afterwards it returns the HTTP response received from the entsoe server.
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

function base_query_load(process, country_code, periodStart, periodEnd)
    country_code = mappings.lookup_area(country_code)

    base_param = Dict{String, String}("documentType" => "A65", "periodStart" => periodStart, "periodEnd" => periodEnd, "outBiddingZone_Domain" => country_code.value)
    param = merge(process, base_param)

    response = base_query(param, key)
    return response
end

function query_actual_total_load(country_code, periodStart, periodEnd)
    process = Dict{String, String}("processType" => "A16")

    response = base_query_load(process, country_code, periodStart, periodEnd)
    return response
end

function query_day_ahead_total_load(country_code, periodStart, periodEnd)
    process = Dict{String, String}("processType" => "A01")

    response = base_query_load(process, country_code, periodStart, periodEnd)
    return response
end

function query_week_ahead_total_load(country_code, periodStart, periodEnd)
    process = Dict{String, String}("processType" => "A31")

    response = base_query_load(process, country_code, periodStart, periodEnd)
    return response
end

function query_month_ahead_total_load(country_code, periodStart, periodEnd)
    process = Dict{String, String}("processType" => "A32")

    response = base_query_load(process, country_code, periodStart, periodEnd)
    return response
end

function query_year_ahead_total_load(country_code, periodStart, periodEnd)
    process = Dict{String, String}("processType" => "A33")

    response = base_query_load(process, country_code, periodStart, periodEnd)
    return response
end

function query_year_ahead_margin(country_code, periodStart, periodEnd)
    country_code = mappings.lookup_area(country_code)

    param = Dict{String, String}("documentType" => "A70", "periodStart" => periodStart, "periodEnd" => periodEnd, "outBiddingZone_Domain" => country_code.value, "processType" => "A33")
    
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
function base_query_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param = Dict())
    in_Domain = mappings.lookup_area(in_Domain)
    out_Domain = mappings.lookup_are(out_Domain)

    base_param = Dict{String, String}("in_Domain" => in_Domain.value, "out_Domain" => out_Domain.value, "periodStart" => periodStart, "periodEnd" => periodEnd)
    param = merge(param, base_param)

    response = base_query(param, key)
    return response
end

function query_forecasted_capacity(contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A61", "contract_MarketAgreement.Type" => contractDict[contract_MarketAgreementType])

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

function query_offered_capacity(auctionType, contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd, auctionCategory="", update_DateAndOrTime="", classificationSequence_AttributeInstanceComponentPosition="")
    param = Dict{String, String}("documentType" => "A31", "auction.Type" => auctionType, "contract_MarketAgreement.Type" => contract_MarketAgreementType)

    if auctionCategory != ""
        param["acution.Category"] = auctionCategory
    end
    if update_DateAndOrTime != ""
        param["update_DateAndOrTime"] = update_DateAndOrTime
    end
    if classificationSequence_AttributeInstanceComponentPosition != ""
        param["classificationSequence_AttributeInstanceComponent.Position"] = classificationSequence_AttributeInstanceComponentPosition
    end

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

function query_flowbased(processType, in_Domain, out_Domain, periodStart, periodEnd)
    if !(processType in argumentLimitations.FlowbasedProcessType)
        throw(DomainError(processType, "Incorrect value for processType, choose between A01 (day ahead) and A02 (intraday)"))
    end

    param = Dict{String, String}("documentType" => "B11", "processType" => processType)

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

function query_intraday_transfer_limits(in_Domain, out_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A93")

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

function query_explicit_allocation_information_capacity(businessType, contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd, auctionCategory = "", classificationSequence_AttributeInstanceComponentPosition = "")
    if !(businessType in argumentLimitations.eaiCapacityBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A43 (requested capacity) and B05 (capacity allocated)"))
    end

    param = Dict{String, String}("documentType" => "A25", "businessType" => businessType, "contract_MarketAgreement.Type" => contract_MarketAgreementType)
    
    if auctionCategory != ""
        param["acution.Category"] = auctionCategory
    end
    if classificationSequence_AttributeInstanceComponentPosition != ""
        param["classificationSequence_AttributeInstanceComponent.Position"] = classificationSequence_AttributeInstanceComponentPosition
    end

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

function query_explicit_allocation_information_revenue(contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A25", "businessType" => "B07", "contract_MarketAgreement.Type" => contract_MarketAgreementType)
    
    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

function query_total_capacity_nominated(in_Domain, out_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A26", "businessType" => "B08")
    
    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

function query_total_capacity_already_allocated(contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd, auctionCategory = "")
    param = Dict{String, String}("documentType" => "A26", "businessType" => "A29", "contract_MarketAgreement.Type" => contract_MarketAgreementType)
    
    if auctionCategory != ""
        param["acution.Category"] = auctionCategory
    end

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

function query_day_ahead_prices(domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A44")
    
    response = base_query_transmission_and_network_congestion(domain, domain, periodStart, periodEnd, param)
    return response
end

function query_implicit_auction_net_positions_and_congestion_income(businessType, contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd)
    if !(businessType in argumentLimitations.ianpBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between B09 (net position) and B10 (congestion income)"))
    end

    param = Dict{String, String}("documentType" => "A25", "businessType" => businessType, "contract_MarketAgreement.Type" => contract_MarketAgreementType)
    
    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

function query_total_commercial_schedules(contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd)
    if !(contract_MarketAgreementType in argumentLimitations.SchedulesContractType)
        throw(DomainError(contract_MarketAgreementType, "Incorrect value for contract_MarketAgreementType, choose between A01 (day ahead) and A05 (total)"))
    end

    param = Dict{String, String}("documentType" => "A09", "contract_MarketAgreement.Type" => contract_MarketAgreementType)
    
    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

function query_phyiscal_flows(in_Domain, out_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A26")
    
    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

function query_capacity_allocated_outside_EU(auctionType, contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd, auctionCategory = "", classificationSequence_AttributeInstanceComponentPosition = "")
    param = Dict{String, String}("documentType" => "A94", "auction.Type" => auctionType, "contract_MarketAgreement.Type" => contract_MarketAgreementType)
    
    if auctionCategory != ""
        param["acution.Category"] = auctionCategory
    end
    if classificationSequence_AttributeInstanceComponentPosition != ""
        param["classificationSequence_AttributeInstanceComponent.Position"] = classificationSequence_AttributeInstanceComponentPosition
    end

    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end


####################### network and congestion management functions ########################

function query_expansion_and_dismantling(in_Domain, out_Domain, periodStart, periodEnd, businessType = "", docStatus = "")
    if !(businessType in argumentLimitations.ExpansionBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between B01 (evolution) and B02 (dismantling)"))
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

function query_redispatching(in_Domain, out_Domain, periodStart, periodEnd, businessType = "")
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

function query_countertrading(in_Domain, out_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A91")
    
    response = base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param)
    return response
end

function query_congestion_costs(domain, periodStart, periodEnd, businessType = "")
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

function base_query_generation(in_Domain, periodStart, periodEnd, param = Dict())
    in_Domain = mappings.lookup_area(in_Domain)

    base_param = Dict{String, String}("in_Domain" => in_Domain.value, "periodStart" => periodStart, "periodEnd" => periodEnd)
    param = merge(param, base_param)

    response = base_query(param, key)
    return response
end

function query_installed_generation_capacity_aggregated(in_Domain, periodStart, periodEnd, psrType = "")
    param = Dict{String, String}("documentType" => "A68", "processType" => "A33")

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

function query_installed_generation_capacity_per_unit(in_Domain, periodStart, periodEnd, psrType = "")
    param = Dict{String, String}("documentType" => "A71", "processType" => "A33")

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

function query_day_ahead_aggregated_generation(in_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A71", "processType" => "A01")

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

function query_day_ahead_generation_forcasts_wind_solar(in_Domain, periodStart, periodEnd, psrType = "")
    param = Dict{String, String}("documentType" => "A69", "processType" => "A01")

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

function query_current_generation_forecasts_wind_solar(in_Domain, periodStart, periodEnd, psrType = "")
    param = Dict{String, String}("documentType" => "A69", "processType" => "A18")

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

function query_intraday_generation_forecasts_wind_solar(n_Domain, periodStart, periodEnd, psrType = "")
    param = Dict{String, String}("documentType" => "A69", "processType" => "A40")

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

function query_actual_generation_per_generation_unit(in_Domain, periodStart, periodEnd, psrType = "", registeredResource = "")
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

function query_aggregated_generation_per_type(in_Domain, periodStart, periodEnd, psrType = "")
    param = Dict{String, String}("documentType" => "A75", "processType" => "A16")

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

function query_aggregated_filling_rate(in_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A72", "processType" => "A16")

    response = base_query_generation(in_Domain, periodStart, periodEnd, param)
    return response
end

#################### master data ###########################
    
end
