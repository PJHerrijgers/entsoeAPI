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


