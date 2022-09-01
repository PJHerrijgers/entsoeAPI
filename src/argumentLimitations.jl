module argumentLimitations

using Dates

FlowbasedProcessType = Set(["A01", "A02"])
eaiCapacityBusinessType = Set(["A43", "B05"])
ianpBusinessType = Set(["B09", "B10"])
SchedulesContractType = Set(["A05", "A01"])

ExpansionBusinessType = Set(["B01", "B02", ""])
redispatchingBusinessType = Set(["A46", "A85", ""])
congestionBusinessType = Set(["A46", "B03", "B04", ""])

windSolarPsrType = Set(["B16", "B18", "B19", ""])

bidsProcessType = Set(["A51", "A47", "A46"])
volPricProcessType = Set(["A52", "A51", "A47", "A46"])
sharingProcessType = Set(["A46", "A56"])
balancingBusinessType = Set(["A95", "A96", "A97", "A98", ""])
balancingPsrType = Set(["A03", "A04", "A05", ""])

outageBusinessType = Set(["A53", "A54", ""])

offset = range(0, stop = 4800)

function check_range_limit(periodStart::DateTime, periodEnd::DateTime, Range::Period)
    if periodEnd > Range + periodStart
        throw(ArgumentError("The range between periodStart and periodEnd is too large, check documentation for maximum range."))
    end
end
end