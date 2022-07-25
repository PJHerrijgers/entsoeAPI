module argumentLimitations

FlowbasedProcessType = Set(["A01", "A02"])
eaiCapacityBusinessType = Set(["A43", "B05"])
ianpBusinessType = Set(["B09", "B10"])
SchedulesContractType = Set(["A05", "A01"])

ExpansionBusinessType = Set(["B01", "B02", ""])
redispatchingBusinessType = Set(["A46", "A85", ""])
congestionBusinessType = Set(["A46", "B03", "B04", ""])

balancingBusinessType = Set(["A95", "A96", "A97", "A98", ""])

outageBusinessType = Set(["A53", "A54", ""])

offset = range(0, 4800)
end