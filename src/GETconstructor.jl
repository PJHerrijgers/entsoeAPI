
module GETconstructor

using HTTP

URL = "https://transparency.entsoe.eu/api?"
global key = ""

function initialize_key(APIkey::String)
    global key = APIkey
    return key
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

function base_query_load(process, country_code, periodStart, periodEnd)
    base_param = Dict{String, String}("documentType" => "A65", "periodStart" => periodStart, "periodEnd" => periodEnd, "outBiddingZone_Domain" => country_code)
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
    param = Dict{String, String}("documentType" => "A70", "periodStart" => periodStart, "periodEnd" => periodEnd, "outBiddingZone_Domain" => country_code, "processType" => "A33")
    response = base_query(param, key)
    return response
end

end
