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

function base_query_load(param, outBiddingZone_Domain, periodStart, periodEnd)
    outBiddingZone_Domain = mappings.lookup_area(outBiddingZone_Domain)

    base_param = Dict{String, String}("documentType" => "A65", "periodStart" => periodStart, "periodEnd" => periodEnd, "outBiddingZone_Domain" => outBiddingZone_Domain.value)
    param = merge(param, base_param)

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
function base_query_transmission_and_network_congestion(in_Domain, out_Domain, periodStart, periodEnd, param = Dict())
    in_Domain = mappings.lookup_area(in_Domain)
    out_Domain = mappings.lookup_area(out_Domain)

    base_param = Dict{String, String}("in_Domain" => in_Domain.value, "out_Domain" => out_Domain.value, "periodStart" => periodStart, "periodEnd" => periodEnd)
    param = merge(param, base_param)

    response = base_query(param, key)
    return response
end

function query_forecasted_capacity(contract_MarketAgreementType, in_Domain, out_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A61", "contract_MarketAgreement.Type" => contract_MarketAgreementType)

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
        param["auction.Category"] = auctionCategory
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

function query_implicit_auction_net_positions_and_congestion_income(businessType, contract_MarketAgreementType, domain, periodStart, periodEnd)
    if !(businessType in argumentLimitations.ianpBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between B09 (net position) and B10 (congestion income)"))
    end

    param = Dict{String, String}("documentType" => "A25", "businessType" => businessType, "contract_MarketAgreement.Type" => contract_MarketAgreementType)
    
    response = base_query_transmission_and_network_congestion(domain, domain, periodStart, periodEnd, param)
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

function query_production_generation_units(biddingZone_Domain, implementation_DateAndOrTime, psrType = "")
    biddingZone_Domain = mappings.lookup_area(biddingZone_Domain)

    param = Dict{String, String}("documentType" => "A95", "businessType" => "B11", "biddingZone_Domain" => biddingZone_Domain.value, "implementation_DateAndOrTime" => implementation_DateAndOrTime)

    if psrType != ""
        param["psrType"] = psrType
    end

    response = base_query(param, key)
    return response
end

#################### balancing domain data ####################

function base_query_balancing1(area_Domain, periodStart, periodEnd, param = Dict())
    area_Domain = mappings.lookup_area(area_Domain)

    base_param = Dict{String, String}("area_Domain" => area_Domain.value, "periodStart" => periodStart, "periodEnd" => periodEnd)
    param = merge(param, base_param)
    
    response = base_query(param, key)
    return response
end

function base_query_balancing2(controlArea_Domain, periodStart, periodEnd, param = Dict())
    controlArea_Domain = mappings.lookup_area(controlArea_Domain)

    base_param = Dict{String, String}("controlArea_Domain" => controlArea_Domain.value, "periodStart" => periodStart, "periodEnd" => periodEnd)
    param = merge(param, base_param)
    
    response = base_query(param, key)
    return response
end

function query_current_balancing_state(area_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A86", "businessType" => "B33")

    response = base_query_balancing1(area_Domain, periodStart, periodEnd, param)
    return response
end

function query_aggregated_balancing_energy_bids(area_Domain, periodStart, periodEnd)
    param = Dict{String, String}("documentType" => "A24", "porcessType" => "A51")

    response = base_query_balancing1(area_Domain, periodStart, periodEnd, param)
    return response
end

function query_procured_balancing_capacity(area_Domain, periodStart, periodEnd, type_MarketAgreementType = "")
    param = Dict{String, String}("documentType" => "A15", "porcessType" => "A51")

    if type_MarketAgreementType != ""
        param["type_MarketAgreement.Type"] = type_MarketAgreementType
    end

    response = base_query_balancing1(area_Domain, periodStart, periodEnd, param)
    return response
end
    
function query_crossZonal_balancing_capacity(acquiring_Domain, connecting_Domain, periodStart, periodEnd)
    acquiring_Domain = mappings.lookup_area(acquiring_Domain)

    param = Dict{String, String}("documentType" => "A38", "porcessType" => "A46", "acquiring_Domain" => acquiring_Domain.value, "connecting_Domain" => connecting_Domain, "periodStart" => periodStart, "periodEnd" => periodEnd) 

    response = base_query(param, key)
    return response
end

"""
Volumes or volumes and prices
"""
function query_volumes_contracted_reserves(type_MarketAgreementType, controlArea_Domain, periodStart, periodEnd, businessType = "", psrType = "", offset::Int = 0)
    if !(businessType in argumentLimitations.balancingBusinessType)
        throw(DomainError(businessType, "Incorrect value for businessType, choose between A95 (FCR) and A96 (aFFR) and A97 (mFFR) and A98 (RR)"))
    end
    if !(offset in argumentLimitations.offset)
        throw(DomainError(offset, "Incorrect value of offset, choose a value between 0 en 4800"))
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
        throw(DomainError(offset, "Incorrect value of offset, choose a value between 0 en 4800"))
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

function query_imbalance_prices(controlArea_Domain, periodStart, periodEnd, psrType = "")
    param = Dict{String, String}("documentType" => "A85") 

    if psrType != ""
        param["psrType"] = psrType
    end

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

##########
# no constistency between entsoe documents about possible values for parameters
# ask Stephen and finish later
##########

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
        throw(DomainError(offset, "Incorrect value of offset, choose a value between 0 en 4800"))
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
        throw(DomainError(offset, "Incorrect value of offset, choose a value between 0 en 4800"))
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
        throw(DomainError(offset, "Incorrect value of offset, choose a value between 0 en 4800"))
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
        throw(DomainError(offset, "Incorrect value of offset, choose a value between 0 en 4800"))
    end

    in_Domain = mappings.lookup_area(in_Domain)
    out_Domain = mappings.lookup_are(out_Domain)

    param = Dict{String, String}("documentType" => "A78", "in_Domain" => in_Domain, "out_Domain" => out_Domain, "periodStart" => periodStart, "periodEnd" => periodEnd)
    
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

###############
# What to do with fall-backs
###############

end
