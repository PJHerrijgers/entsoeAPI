using HTTP

URL = "https://transparency.entsoe.eu/api"

function test(key)
    response = HTTP.request("GET", URL*"?securityToken="*key*"&documentType=A65&processType=A16&outBiddingZone_Domain=10YCZ-CEPS-----N&periodStart=201512312300&periodEnd=201612312300")
    return response
end

print(test("6e9d0b18-9bde-41cf-938f-c8ad9b35d97d"))

