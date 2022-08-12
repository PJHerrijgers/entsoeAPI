module xmlMappings

using Dates

RESOLUTION = Dict{String, Dates.Period}("P1Y" => Year(1),
                                        "P1M" => Month(1),
                                        "P7D" => Day(7),
                                        "P1D" => Day(1),
                                        "PT60M" => Minute(60),
                                        "PT30M" => Minute(30),
                                        "PT15M" => Minute(15),
                                        "PT1M" => Minute(1),
                                        "PT4S" => Second(4),
                                        "PT1S" => Second(1)
                                        )

FLOWDIRECTION = Dict{String, String}("A01" => "Up",
                                     "A02" => "Down",
                                     "A03" => "symmetric"
                                     )

PRICETYPE = Dict{String, String}("A04" => "Excess balance",
                                 "A05" => "Insufficient balance",
                                 "A06" => "Average bid price",
                                 "A07" => "Single marginal bid price",
                                 "A08" => "Cross border marginal price")

end