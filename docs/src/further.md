# Further development

This document describes shortly what still has to be completed to obtain full funcionality. It shows as well how this has to be done to be compatible with the existing code.

## entoseAPI.jl

Almost all functions are already written, for some functions it is still necessary to complete the documentation and the arguments after the corresponding functions in `GETconstructor.jl` and `xmlParser.jl` are completed. This has to be done in the following way: the arguments for the functions in `entsoeAPI.jl` are the same as for the corresponding functions in `GETconstructor.jl`. The documentation has to contain the following things: header of the function, description of what the function does, description of the return format and description of the arguments. Please follow the julia documentation rules (same lay-out as docuemntation already written).

### documentation missing

```julia
function actual_generation_per_generation_unit(in_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "", registeredResource::String = "")
function production_generation_units(biddingZone_Domain::Union{mappings.Area, String}, implementation_DateAndOrTime::DateTime, psrType::String = "")
function balancing_energy_bids(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, processType::String)
function procured_balancing_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, type_MarketAgreementType::String = "")
function crossZonal_balancing_capacity(acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function volumes_and_prices_contracted_reserves(type_MarketAgreementType::String, processType::String, controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime, psrType::String = "", offset::Int = 0)
function imbalance_prices(controlArea_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function crossBorder_balancing(acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function FCR_total_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function share_capacity_FCR(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function contracted_reserve_capacity_FCR(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function FRR_actual_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function RR_actual_capacity(area_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
function sharing_of_reserves(processType::String, acquiring_Domain::Union{mappings.Area, String}, connecting_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
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

### arguments missing

```julia
function balancing_border_capacity_limitations()
function permanent_allocation_limitations_HVDC()
function netted_and_exchanged_volumes()
function fallBacks()
```

## GETconstructor.jl

Almost all functions are already written, some still need to be completed because the documentation provided by ENTSO-E was unclear or their API had some errors. So these can be completed as soon as those errors are fixed and the documentation is updated. The arguments that are needed to build the request for the ENTSO-E API can be found [here](https://transparency.entsoe.eu/content/static_content/Static%20content/web%20api/Guide.html). The documentation should contain following elements: header of the function, description of what the function does, description what is returned, important restrictions and description of the arguments. Please follow the julia documentation rules (same lay-out as docuemntation already written).

### Incomplete functions

```julia
function query_balancing_border_capacity_limitations()
function query_permanent_allocation_limitations_HVDC()
function query_netted_and_exchanged_volumes()
function query_fallBacks()
```

## xmlParser.jl

There are still some functions to be written. The implementation is very case-dependent. You have to look at the output of the corresponding function in `GETconstructor.jl`. From the xml data returned by that function you have to decide which is the best way to parse it. For the documentation it is important to specify following things: header of the function, description of what the function does, description of the return format and description of the arguments. Please follow the julia documentation rules (same lay-out as docuemntation already written).

### Incomplete functions

```julia
function parse_actual_generation_per_generation_unit(xml::Vector{UInt8}, tz::TimeZone)
function parse_production_generation_units(xml::Vector{UInt8}, tz::TimeZone)
function parse_balancing_energy_bids(xml::Vector{UInt8}, tz::TimeZone)
function parse_procured_balancing_capacity(xml::Vector{UInt8}, tz::TimeZone)
function parse_crossZonal_balancing_capacity(xml::Vector{UInt8}, tz::TimeZone)
function parse_volumes_and_prices_contracted_reserves(xml::Vector{UInt8}, tz::TimeZone)
function parse_imbalance_prices(xml::Vector{UInt8}, tz::TimeZone)
function parse_crossBorder_balancing(xml::Vector{UInt8}, tz::TimeZone)
function parse_FCR_total_capacity(xml::Vector{UInt8}, tz::TimeZone)
function parse_share_capacity_FCR(xml::Vector{UInt8}, tz::TimeZone)
function parser_contracted_reserve_capacity_FCR(xml::Vector{UInt8}, tz::TimeZone)
function parse_FRR_actual_capacity(xml::Vector{UInt8}, tz::TimeZone)
function parse_RR_actual_capacity(xml::Vector{UInt8}, tz::TimeZone)
function parse_sharing_of_reserves(xml::Vector{UInt8}, tz::TimeZone)
function parse_balancing_border_capacity_limitations(xml::Vector{UInt8}, tz::TimeZone)
function parse_permanent_allocation_limitations_HVDC(xml::Vector{UInt8}, tz::TimeZone)
function parse_netted_and_exchanged_volumes(xml::Vector{UInt8}, tz::TimeZone)
function parse_unavailability_consumption_units(xml::Vector{UInt8}, tz::TimeZone)
function parse_unavailability_generation_units(xml::Vector{UInt8}, tz::TimeZone)
function parse_unavailability_production_units(xml::Vector{UInt8}, tz::TimeZone)
function parse_unavailability_offshore_grid(xml::Vector{UInt8}, tz::TimeZone)
function parse_unavailability_transmission_infrastructure(xml::Vector{UInt8}, tz::TimeZone)
function parse_fallBacks(xml::Vector{UInt8}, tz::TimeZone)

```