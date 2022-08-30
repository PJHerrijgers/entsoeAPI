# entsoeAPI
Julia API to retreive data from the ENTSO-E transparancy platform using the ENTSOE-E API.
Documentation for the ENTSO-E can be found on https://transparency.entsoe.eu/content/static_content/Static%20content/web%20api/Guide.html

## Prerequisites
1. Download and install the Julia API for the ENTSO-E transparency platform first using [the following link](https://github.com/Electa-Git/etsoe-julia-api)
2. Create an account in the [ENTSO-E transparency platform](https://transparency.entsoe.eu/)
3. Request an API key by sending an email to transparency@entsoe.eu with “Restful API access” in the subject line. In the email body state your registered email address. You will receive an email when you have been provided with the API key. The key is then visible in your ENTSO-E account under “Web API Security Token”.

## Usage
`entsoeAPI.jl` is the main file which contains the following functions:
```julia
function initialize_key(APIkey::String)

function actual_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function day_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function week_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function month_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function year_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function year_ahead_margin(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

function forecasted_capacity(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function offered_capacity(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "", update_DateAndOrTime::DateTime = DateTime(0), classificationSequence_AttributeInstanceComponentPosition::String = "")
function flowbased(processType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function intraday_transfer_limits(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function explicit_allocation_information_capacity(businessType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = "")
function explicit_allocation_information_revenue(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function total_capacity_nominated(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function total_capacity_already_allocated(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "")
function day_ahead_prices(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function implicit_auction_net_positions(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function implicit_auction_congestion_income(businessType::String, contract_MarketAgreementType::String, domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function total_commercial_schedules(contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function phyiscal_flows(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function capacity_allocated_outside_EU(auctionType::String, contract_MarketAgreementType::String, in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, auctionCategory::String = "", classificationSequence_AttributeInstanceComponentPosition::String = "")

function expansion_and_dismantling(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", docStatus::String = "")
function redispatching(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "")
function countertrading(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function congestion_costs(domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "")

function installed_generation_capacity_aggregated(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
function installed_generation_capacity_per_unit(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
function day_ahead_aggregated_generation(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function day_ahead_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
function current_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
function intraday_generation_forecasts_wind_solar(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
function actual_generation_per_generation_unit(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "", registeredResource::String = "")
function aggregated_generation_per_type(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "")
function aggregated_filling_rate(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)

function production_generation_units(biddingZone_Domain::Union{mappings.Area, String}, implementation_DateAndOrTime::DateTime, psrType::String = "")

function current_balancing_state(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function balancing_energy_bids(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, processType::String)
function aggregated_balancing_energy_bids(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, processType::String)
function procured_balancing_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, type_MarketAgreementType::String = "")
function crossZonal_balancing_capacity(acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function volumes_and_prices_contracted_reserves(type_MarketAgreementType::String, processType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "", offset::Int = 0)
function volumes_contracted_reserves(type_MarketAgreementType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", psrType::String = "", offset::Int = 0)
function prices_contracted_reserves(type_MarketAgreementType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", psrType::String = "", offset::Int = 0)
function accepted_aggregated_offers(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", psrType::String = "")
function activated_balancing_energy(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", psrType::String = "")
function prices_activated_balancing_energy(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", psrType::String = "")
function imbalance_prices(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function total_imbalance_volumes(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function financial_expenses(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function crossBorder_balancing(acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function FCR_total_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function share_capacity_FCR(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function contracted_reserve_capacity_FCR(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function FRR_actual_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function RR_actual_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function query_sharing_of_reserves(processType::String, acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function balancing_border_capacity_limitations()
function permanent_allocation_limitations_HVDC()
function netted_and_exchanged_volumes()

function unavailability_consumption_units(biddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "")
function unavailability_generation_units(biddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", docStatus::String = "", periodStartUpdate::DateTime = DateTime(0), periodEndUpdate::DateTime = DateTime(0), registeredResource::String = "", mRID::String = "", offset::Int = 0)
function unavailability_production_units(biddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", docStatus::String = "", periodStartUpdate::DateTime = DateTime(0), periodEndUpdate::DateTime = DateTime(0), registeredResource::String = "", mRID::String = "", offset::Int = 0)
function unavailability_offshore_grid(biddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, docStatus::String = "", periodStartUpdate::DateTime = DateTime(0), periodEndUpdate::DateTime = DateTime(0), mRID::String = "", offset::Int = 0)
function unavailability_transmission_infrastructure(in_Domain::Union{mappings.Area, String}, out_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, businessType::String = "", docStatus::String = "", periodStartUpdate::DateTime = DateTime(0), periodEndUpdate::DateTime = DateTime(0), mRID::String = "", offset::Int = 0)
function fallBacks()
```

The `initialize_key(APIkey::String)` function saves your personal security token in the `GETconstructor.jl` file. In this way it is possbile to use the API without entering the security token everytime.

All the other functions retreive a specific set of data from the transparancy platform. This happens in 2 steps: 
1. A HTTP-request is formed with the functions in the `GETconstructor.jl` file. This request is sent to the ENTSO-E API which returns the requested data in XML format.
2. The XML data is parsed with the functions in the `XMLparser.jl` file. The return format is not exactly the same for each function. But it's always a combination of dataframes and dicitionaries (The exact format can be found in the documentation per function).

## Arguments
### Domains
Domains can be entered in the following formats:
1. Area object as defined in `mappings.jl`
2. EIC-code ad defined on https://www.entsoe.eu/data/energy-identification-codes-eic/eic-approved-codes/
3. Display name as defined on https://www.entsoe.eu/data/energy-identification-codes-eic/eic-approved-codes/

Important to know is that the list in `mappings.jl` isn't complete and that the domains are always evolving as well. If you want to add a missing domain to `mappings.jl` you have to do this as follows:
```julia
display_name = Area("display name", "EIC-code", "description", TimeZone)
```
Example for Belgium:
```julia
BE = Area("BE", "10YBE----------2", "Belgium, Elia BZ / CA / MBA", TimeZone("Europe/Brussels"))
```

### Dates and Times
Dates and TImes need to be entered as a `DateTime()` object. The correct timezone is choosen automatically based on the entered domain. More information on the `DateTime()`object and the `Dates` packages can be found on https://docs.julialang.org/en/v1/stdlib/Dates/

## Example
Hereafter an example will be discussed to clarify how to use the API.
We want to get the actual load data from the Czech Republic between 31/12/2015 23:00 and 31/12/2016 23:00. First we have to initialize our personal security token:
```julia
APIkey = "YOUR_PERSONAL_TOKEN"
entsoeAPI.initialize_key(APIkey)
```

When the token is initialized, we can try to retreive the actual data. This is done in the following way:
```julia
entsoeAPI.actual_total_load("10YCZ-CEPS-----N", DateTime(2015,12,31,23,00), DateTime(2016,12,31,23,00))
```