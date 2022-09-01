# Load functions

```@contents
```

This file describes the usage of all the functions under the load tab in the ENTSOE-E transparancy platform.

## User functions

```@docs
actual_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
day_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
week_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
month_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
year_ahead_total_load(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
year_ahead_margin(outBiddingZone_Domain::Union{mappings.Area, String}, periodStart::DateTime, periodEnd::DateTime)
```