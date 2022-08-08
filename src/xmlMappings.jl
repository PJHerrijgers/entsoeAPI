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

end