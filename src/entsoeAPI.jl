using HTTP
using Markdown
using LightXML
using DataFrames
using Dates
using CSV

URL = "https://transparency.entsoe.eu/api"

struct Client
    key::String
    URLkey::String
    Client(key) = new(key, URL*"?securityToken="*key)
end

"""
    Returns the HTTP response of the request for the actual total load data in outBiddingZone_Domain from periodStart till periodEnd
"""
function query_actual_total_load(key, docType, procType, outBiddingZone_Domain, periodStart, periodEnd)
    return HTTP.request("GET", Client(key).URLkey*"&documentType="*docType*"&processType="*procType*"&outBiddingZone_Domain="*outBiddingZone_Domain*"&periodStart="*periodStart*"&periodEnd="*periodEnd)
end

function total_load_to_dataFrame(xml)
    xdoc = parse_file(xml)
    xroot = root(xdoc)
    df = DataFrame(times = DateTime[], load = Int[])
    for child in child_elements(xroot)
        if name(child) == "TimeSeries"  
            Period = LightXML.find_element(child, "Period")
            TimeInterval = LightXML.find_element(Period, "timeInterval")
            Resolution = LightXML.find_element(Period, "resolution")
            # print(content(Resolution))
            Resolution = content(Resolution)
            ResolutionNumber = Resolution[3:end-1]
            ResolutionUnit = string(Resolution[end])
            print("number:"*ResolutionNumber)
            println("unit"*ResolutionUnit)
            if cmp(ResolutionUnit,"M") == 0
                period = Minute(ResolutionNumber)
                print(period)
            elseif cmp(ResolutionUnit,"H") == 0
                period = Hour(ResolutionNumber)
            end
            start = LightXML.find_element(TimeInterval, "start")
            start = DateTime(content(start), "y-m-dTH:MZ")
            # print(start)
            ennd = LightXML.find_element(TimeInterval, "end")
            ennd = DateTime(content(ennd), "y-m-dTH:MZ")
            # print(ennd)

            for grandchild in child_elements(Period)
                if name(grandchild) == "Point"
                    position = parse(Int,content(find_element(grandchild,"position")))
                    time = (position-1)*period + start
                    value = parse(Int,content(find_element(grandchild,"quantity")))
                    push!(df,(time, value))
                end
            end
        end
    end
    return df
end

#### Test function ####
data = HTTP.body(query_actual_total_load("6e9d0b18-9bde-41cf-938f-c8ad9b35d97d", "A65", "A16", "10YCZ-CEPS-----N", "201512312300", "201612312300"))
open("data/test.xml", "w") do f 
    write(f, data)
end
d = total_load_to_dataFrame("data/test.xml")
print(d)
CSV.write("C:\\Users\\P-J\\.julia\\dev\\entsoeAPI\\data\\test.csv", d) 