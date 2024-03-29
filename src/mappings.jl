"""
Module used to map area's and entso-e specific terms to their correct code. Those have to be used when creating an HTTP request
"""
module mappings

using Dates
using TimeZones

"""
Area object which consists of 4 elements: 
    name: common abbreviation used for the area ('display name')
    value: EIC-code of the area
    meaning: short description of the area
    tz: Timezone of the area
"""
struct Area
    name::String
    value::String
    meaning::String
    tz::TimeZone
end

    # List taken directly from the API Docs

DE_50HZ =       Area("DE_50HZ", "10YDE-VE-------2", "50Hertz CA, DE(50HzT) BZA",                TimeZone("Europe/Berlin"))
AL =            Area("AL", "10YAL-KESH-----5", "Albania, OST BZ / CA / MBA",                    TimeZone("Europe/Tirane"))
DE_AMPRION =    Area("DE_AMPERION", "10YDE-RWENET---I", "Amprion CA",                           TimeZone("Europe/Berlin"))
AT =            Area("AT", "10YAT-APG------L", "Austria, APG BZ / CA / MBA",                    TimeZone("Europe/Vienna"))
BY =            Area("BY", "10Y1001A1001A51S", "Belarus BZ / CA / MBA",                         TimeZone("Europe/Minsk"))
BE =            Area("BE", "10YBE----------2", "Belgium, Elia BZ / CA / MBA",                   TimeZone("Europe/Brussels"))
BA =            Area("BA", "10YBA-JPCC-----D", "Bosnia Herzegovina, NOS BiH BZ / CA / MBA",     TimeZone("Europe/Sarajevo"))
BG =            Area("BG", "10YCA-BULGARIA-R", "Bulgaria, ESO BZ / CA / MBA",                   TimeZone("Europe/Sofia"))
CZ_DE_SK =      Area("CZ_DE_SK", "10YDOM-CZ-DE-SKK", "BZ CZ+DE+SK BZ / BZA",                    TimeZone("Europe/Prague"))
HR =            Area("HR", "10YHR-HEP------M", "Croatia, HOPS BZ / CA / MBA",                   TimeZone("Europe/Zagreb"))
CWE =           Area("CWE", "10YDOM-REGION-1V", "CWE Region",                                   TimeZone("Europe/Brussels"))
CY =            Area("CY", "10YCY-1001A0003J", "Cyprus, Cyprus TSO BZ / CA / MBA",              TimeZone("Asia/Nicosia"))
CZ =            Area("CZ", "10YCZ-CEPS-----N", "Czech Republic, CEPS BZ / CA/ MBA",             TimeZone("Europe/Prague"))
DE_AT_LU =      Area("DE_AT_LU", "10Y1001A1001A63L", "DE-AT-LU BZ",                             TimeZone("Europe/Berlin"))
DE_LU =         Area("DE_LU", "10Y1001A1001A82H", "DE-LU BZ / MBA",                             TimeZone("Europe/Berlin"))
DK =            Area("DK", "10Y1001A1001A65H", "Denmark",                                       TimeZone("Europe/Copenhagen"))
DK_1 =          Area("DK_1", "10YDK-1--------W", "DK1 BZ / MBA",                                TimeZone("Europe/Copenhagen"))
DK_2 =          Area("DK_2", "10YDK-2--------M", "DK2 BZ / MBA",                                TimeZone("Europe/Copenhagen"))
DK_CA =         Area("DK_CA", "10Y1001A1001A796", "Denmark, Energinet CA",                      TimeZone("Europe/Copenhagen"))
EE =            Area("EE", "10Y1001A1001A39I", "Estonia, Elering BZ / CA / MBA",                TimeZone("Europe/Tallinn"))
FI =            Area("FI", "10YFI-1--------U", "Finland, Fingrid BZ / CA / MBA",                TimeZone("Europe/Helsinki"))
MK =            Area("MK", "10YMK-MEPSO----8", "Former Yugoslav Republic of Macedonia, MEPSO BZ / CA / MBA", TimeZone("Europe/Skopje"))
FR =            Area("FR", "10YFR-RTE------C", "France, RTE BZ / CA / MBA",                     TimeZone("Europe/Paris"))
DE =            Area("DE", "10Y1001A1001A83F", "Germany",                                       TimeZone("Europe/Berlin"))
GR =            Area("GR", "10YGR-HTSO-----Y", "Greece, IPTO BZ / CA/ MBA",                     TimeZone("Europe/Athens"))
HU =            Area("HU", "10YHU-MAVIR----U", "Hungary, MAVIR CA / BZ / MBA",                  TimeZone("Europe/Budapest"))
IS =            Area("IS", "IS",               "Iceland",                                       TimeZone("Atlantic/Reykjavik"))
IE_SEM =        Area("IE_SEM", "10Y1001A1001A59C", "Ireland (SEM) BZ / MBA",                    TimeZone("Europe/Dublin"))
IE =            Area("IE", "10YIE-1001A00010", "Ireland, EirGrid CA",                           TimeZone("Europe/Dublin"))
IT =            Area("IT", "10YIT-GRTN-----B", "Italy, IT CA / MBA",                            TimeZone("Europe/Rome"))
IT_SACO_AC =    Area("IT_SACO_AC", "10Y1001A1001A885", "Italy_Saco_AC",                         TimeZone("Europe/Rome"))
IT_CALA =       Area("IT_CALA", "10Y1001C--00096J", "IT-Calabria BZ",                           TimeZone("Europe/Rome"))
IT_SACO_DC =    Area("IT_SACO_DC", "10Y1001A1001A893", "Italy_Saco_DC",                         TimeZone("Europe/Rome"))
IT_BRNN =       Area("IT_BRNN", "10Y1001A1001A699", "IT-Brindisi BZ",                           TimeZone("Europe/Rome"))
IT_CNOR =       Area("IT_CNOR", "10Y1001A1001A70O", "IT-Centre-North BZ",                       TimeZone("Europe/Rome"))
IT_CSUD =       Area("IT_CSUD", "10Y1001A1001A71M", "IT-Centre-South BZ",                       TimeZone("Europe/Rome"))
IT_FOGN =       Area("IT_FOGN", "10Y1001A1001A72K", "IT-Foggia BZ",                             TimeZone("Europe/Rome"))
IT_GR =         Area("IT_GR", "10Y1001A1001A66F", "IT-GR BZ",                                   TimeZone("Europe/Rome"))
IT_MACRO_NORTH = Area("IT_MACRO_NORTH", "10Y1001A1001A84D", "IT-MACROZONE NORTH MBA",           TimeZone("Europe/Rome"))
IT_MACRO_SOUTH = Area("IT_MACRO_SOUTH", "10Y1001A1001A85B", "IT-MACROZONE SOUTH MBA",           TimeZone("Europe/Rome"))
IT_MALTA =      Area("IT_MALTA", "10Y1001A1001A877", "IT-Malta BZ",                             TimeZone("Europe/Rome"))
IT_NORD =       Area("IT_NORD", "10Y1001A1001A73I", "IT-North BZ",                              TimeZone("Europe/Rome"))
IT_NORD_AT =    Area("IT_NORD_AT", "10Y1001A1001A80L", "IT-North-AT BZ",                        TimeZone("Europe/Rome"))
IT_NORD_CH =    Area("IT_NORD_CH", "10Y1001A1001A68B", "IT-North-CH BZ",                        TimeZone("Europe/Rome"))
IT_NORD_FR =    Area("IT_NORD_FR", "10Y1001A1001A81J", "IT-North-FR BZ",                        TimeZone("Europe/Rome"))
IT_NORD_SI =    Area("IT_NORD_SI", "10Y1001A1001A67D", "IT-North-SI BZ",                        TimeZone("Europe/Rome"))
IT_PRGP =       Area("IT_PRGP", "10Y1001A1001A76C", "IT-Priolo BZ",                             TimeZone("Europe/Rome"))
IT_ROSN =       Area("IT_ROSN", "10Y1001A1001A77A", "IT-Rossano BZ",                            TimeZone("Europe/Rome"))
IT_SARD =       Area("IT_SARD", "10Y1001A1001A74G", "IT-Sardinia BZ",                           TimeZone("Europe/Rome"))
IT_SICI =       Area("IT_SICI", "10Y1001A1001A75E", "IT-Sicily BZ",                             TimeZone("Europe/Rome"))
IT_SUD =        Area("IT_SUD", "10Y1001A1001A788", "IT-South BZ",                               TimeZone("Europe/Rome"))
RU_KGD =        Area("RU_KGD", "10Y1001A1001A50U", "Kaliningrad BZ / CA / MBA",                 TimeZone("Europe/Kaliningrad"))
LV =            Area("LV", "10YLV-1001A00074", "Latvia, AST BZ / CA / MBA",                     TimeZone("Europe/Riga"))
LT =            Area("LT", "10YLT-1001A0008Q", "Lithuania, Litgrid BZ / CA / MBA",              TimeZone("Europe/Vilnius"))
LU =            Area("LU", "10YLU-CEGEDEL-NQ", "Luxembourg, CREOS CA",                          TimeZone("Europe/Luxembourg"))
MT =            Area("MT", "10Y1001A1001A93C", "Malta, Malta BZ / CA / MBA",                    TimeZone("Europe/Malta"))
ME =            Area("ME", "10YCS-CG-TSO---S", "Montenegro, CGES BZ / CA / MBA",                TimeZone("Europe/Podgorica"))
GB =            Area("GB", "10YGB----------A", "National Grid BZ / CA/ MBA",                    TimeZone("Europe/London"))
GB_IFA =        Area("GB_IFA", "10Y1001C--00098F", "GB(IFA) BZN",                               TimeZone("Europe/London"))
GB_IFA2 =       Area("GB_IFA2", "17Y0000009369493", "GB(IFA2) BZ",                              TimeZone("Europe/London"))
GB_ELECLINK =   Area("GB_ELECLINK", "11Y0-0000-0265-K", "GB(ElecLink) BZN",                     TimeZone("Europe/London"))
UK =            Area("UK", "10Y1001A1001A92E", "United Kingdom",                                TimeZone("Europe/London"))
NL =            Area("NL", "10YNL----------L", "Netherlands, TenneT NL BZ / CA/ MBA",           TimeZone("Europe/Amsterdam"))
NO_1 =          Area("NO_1", "10YNO-1--------2", "NO1 BZ / MBA",                                TimeZone("Europe/Oslo"))
NO_2 =          Area("NO_2", "10YNO-2--------T", "NO2 BZ / MBA",                                TimeZone("Europe/Oslo"))
NO_2_NSL =      Area("NO_2_NSL", "50Y0JVU59B4JWQCU", "NO2 NSL BZ / MBA",                        TimeZone("Europe/Oslo"))
NO_3 =          Area("NO_3", "10YNO-3--------J", "NO3 BZ / MBA",                                TimeZone("Europe/Oslo"))
NO_4 =          Area("NO_4", "10YNO-4--------9", "NO4 BZ / MBA",                                TimeZone("Europe/Oslo"))
NO_5 =          Area("NO_5", "10Y1001A1001A48H", "NO5 BZ / MBA",                                TimeZone("Europe/Oslo"))
NO =            Area("NO", "10YNO-0--------C", "Norway, Norway MBA, Stattnet CA",               TimeZone("Europe/Oslo"))
PL_CZ =         Area("PL_CZ", "10YDOM-1001A082L", "PL-CZ BZA / CA",                             TimeZone("Europe/Warsaw"))
PL =            Area("PL", "10YPL-AREA-----S", "Poland, PSE SA BZ / BZA / CA / MBA",            TimeZone("Europe/Warsaw"))
PT =            Area("PT", "10YPT-REN------W", "Portugal, REN BZ / CA / MBA",                   TimeZone("Europe/Lisbon"))
MD =            Area("MD", "10Y1001A1001A990", "Republic of Moldova, Moldelectica BZ/CA/MBA",   TimeZone("Europe/Chisinau"))
RO =            Area("RO", "10YRO-TEL------P", "Romania, Transelectrica BZ / CA/ MBA",          TimeZone("Europe/Bucharest"))
RU =            Area("RU", "10Y1001A1001A49F", "Russia BZ / CA / MBA",                          TimeZone("Europe/Moscow"))
SE_1 =          Area("SE_1", "10Y1001A1001A44P", "SE1 BZ / MBA",                                TimeZone("Europe/Stockholm"))
SE_2 =          Area("SE_2", "10Y1001A1001A45N", "SE2 BZ / MBA",                                TimeZone("Europe/Stockholm"))
SE_3 =          Area("SE_3", "10Y1001A1001A46L", "SE3 BZ / MBA",                                TimeZone("Europe/Stockholm"))
SE_4 =          Area("SE_4", "10Y1001A1001A47J", "SE4 BZ / MBA",                                TimeZone("Europe/Stockholm"))
RS =            Area("RS", "10YCS-SERBIATSOV", "Serbia, EMS BZ / CA / MBA",                     TimeZone("Europe/Belgrade"))
SK =            Area("SK", "10YSK-SEPS-----K", "Slovakia, SEPS BZ / CA / MBA",                  TimeZone("Europe/Bratislava"))
SI =            Area("SI", "10YSI-ELES-----O", "Slovenia, ELES BZ / CA / MBA",                  TimeZone("Europe/Ljubljana"))
GB_NIR =        Area("GB_NIR", "10Y1001A1001A016", "Northern Ireland, SONI CA",                 TimeZone("Europe/London"))
ES =            Area("ES", "10YES-REE------0", "Spain, REE BZ / CA / MBA",                      TimeZone("Europe/Madrid"))
SE =            Area("SE", "10YSE-1--------K", "Sweden, Sweden MBA, SvK CA",                    TimeZone("Europe/Stockholm"))
CH =            Area("CH", "10YCH-SWISSGRIDZ", "Switzerland, Swissgrid BZ / CA / MBA",          TimeZone("Europe/Zurich"))
DE_TENNET =     Area("DE_TENNET", "10YDE-EON------1", "TenneT GER CA",                          TimeZone("Europe/Berlin"))
DE_TRANSNET =   Area("DE_TRANSNET", "10YDE-ENBW-----N", "TransnetBW CA",                        TimeZone("Europe/Berlin"))
TR =            Area("TR", "10YTR-TEIAS----W", "Turkey BZ / CA / MBA",                          TimeZone("Europe/Istanbul"))
UA =            Area("UA", "10Y1001C--00003F", "Ukraine, Ukraine BZ, MBA",                      TimeZone("Europe/Kiev"))
UA_DOBTPP =     Area("UA_DOBTPP", "10Y1001A1001A869", "Ukraine-DobTPP CTA",                     TimeZone("Europe/Kiev"))
UA_BEI =        Area("UA_BEI", "10YUA-WEPS-----0", "Ukraine BEI CTA",                           TimeZone("Europe/Kiev"))
UA_IPS =        Area("UA_TPS", "10Y1001C--000182", "Ukraine IPS CTA",                           TimeZone("Europe/Kiev"))
XK =            Area("XK", "10Y1001C--00100H", "Kosovo/ XK CA / XK BZN",                        TimeZone("Europe/Rome"))
CZ_SK =         Area("CZ_SK", "10YDOM-1001A083J", "Border Area Czech Republic Slovakia",        TimeZone("Europe/Prague"))
EU_SYN =        Area("EU_SYN", "10YEU-CONT-SYNC0", "Synchronous Zone of Continental Europe",    TimeZone("Europe/Brussels"))
DE_DK1_LU =     Area("DE_DK1_LU", "10YCB-GERMANY--8", "CB Germany_Denmark_Luxemburg",           TimeZone("Europe/Copenhagen"))
ES_FR =         Area("ES_FR", "10YDOM--ES-FR--D", "Border area Spain France",                   TimeZone("Europe/Madrid"))

Areas = Set([
    DE_50HZ,
    AL,
    DE_AMPRION,
    AT,
    BY,
    BE,
    BA,
    BG,
    CZ_DE_SK,
    HR,
    CWE,
    CY,
    CZ,
    DE_AT_LU,
    DE_LU,
    DK,
    DK_1,
    DK_2,
    DK_CA,
    EE,
    FI,
    MK,
    FR,
    DE,
    GR,
    HU,
    IS,
    IE_SEM,
    IE,
    IT,
    IT_SACO_AC,
    IT_CALA,
    IT_SACO_DC,
    IT_BRNN,
    IT_CNOR,
    IT_CSUD,
    IT_FOGN,
    IT_GR,
    IT_MACRO_NORTH,
    IT_MACRO_SOUTH,
    IT_MALTA,
    IT_NORD,
    IT_NORD_AT,
    IT_NORD_CH,
    IT_NORD_FR,
    IT_NORD_SI,
    IT_PRGP,
    IT_ROSN,
    IT_SARD,
    IT_SICI,
    IT_SUD,
    RU_KGD,
    LV,
    LT,
    LU,
    MT,
    ME,
    GB,
    GB_IFA,
    GB_IFA2,
    GB_ELECLINK,
    UK,
    NL,
    NO_1,
    NO_2,
    NO_2_NSL,
    NO_3,
    NO_4,
    NO_5,
    NO,
    PL_CZ,
    PL,
    PT,
    MD,
    RO,
    RU,
    SE_1,
    SE_2,
    SE_3,
    SE_4,
    RS,
    SK,
    SI,
    GB_NIR,
    ES,
    SE,
    CH,
    DE_TENNET,
    DE_TRANSNET,
    TR,
    UA,
    UA_DOBTPP,
    UA_BEI,
    UA_IPS,
    XK,
    CZ_SK,
    EU_SYN,
    DE_DK1_LU,
    ES_FR      
])

PSRTYPE = Dict("A03"=> "Mixed",
               "A04"=> "Generation",
               "A05"=> "Load",
               "B01"=> "Biomass",
               "B02"=> "Fossil Brown coal/Lignite",
               "B03"=> "Fossil Coal-derived gas",
               "B04"=> "Fossil Gas",
               "B05"=> "Fossil Hard coal",
               "B06"=> "Fossil Oil",
               "B07"=> "Fossil Oil shale",
               "B08"=> "Fossil Peat",
               "B09"=> "Geothermal",
               "B10"=> "Hydro Pumped Storage",
               "B11"=> "Hydro Run-of-river and poundage",
               "B12"=> "Hydro Water Reservoir",
               "B13"=> "Marine",
               "B14"=> "Nuclear",
               "B15"=> "Other renewable",
               "B16"=> "Solar",
               "B17"=> "Waste",
               "B18"=> "Wind Offshore",
               "B19"=> "Wind Onshore",
               "B20"=> "Other",
               "B21"=> "AC Link",
               "B22"=> "DC Link",
               "B23"=> "Substation",
               "B24"=> "Transformer"
               )

DOCSTATUS = Dict("A01"=> "Intermediate",
                 "A02"=> "Final",
                 "A05"=> "Active",
                 "A09"=> "Cancelled",
                 "A13"=> "Withdrawn",
                 "X01"=> "Estimated"
                 )

BSNTYPE = Dict("A25"=> "General capacity information",
               "A29"=> "Already allocated capacity (AAC)",
               "A43"=> "Requested capacity (without price)",
               "A46"=> "System Operator redispatching",
               "A53"=> "Planned maintenance",
               "A54"=> "Unplanned outage",
               "A85"=> "Internal redispatch",
               "A95"=> "Frequency containment reserve",
               "A96"=> "Automatic frequency restoration reserve",
               "A97"=> "Manual frequency restoration reserve",
               "A98"=> "Replacement reserve",
               "B01"=> "Interconnector network evolution",
               "B02"=> "Interconnector network dismantling",
               "B03"=> "Counter trade",
               "B04"=> "Congestion costs",
               "B05"=> "Capacity allocated (including price)",
               "B07"=> "Auction revenue",
               "B08"=> "Total nominated capacity",
               "B09"=> "Net position",
               "B10"=> "Congestion income",
               "B11"=> "Production unit",
               "B33"=> "Area control error",
               "B95"=> "Procured capacity",
               "C22"=> "Shared balancing reserve capacity",
               "C23"=> "Share of reserve capacity",
               "C24"=> "Actual reserve capacity"
               )

MARKETAGREEMENTTYPE = Dict("A01"=> "Daily",
                       "A02"=> "Weekly",
                       "A03"=> "Monthly",
                       "A04"=> "Yearly",
                       "A05"=> "Total",
                       "A06"=> "Long term",
                       "A07"=> "Intraday",
                       "A13"=> "Hourly"   # Type_MarketAgreement.Type only!!!!!!!!!!!!!!!!!!!!
                       )

AUCTIONTYPE = Dict("A01"=> "Implicit",
                   "A02"=> "Explicit"
                   )

AUCTIONCATEGORY = Dict("A01"=> "Base",
                        "A02"=> "Peak",
                        "A03"=> "Off peak",
                        "A04"=> "Hourly"
                        )

DOCUMENTTYPE = Dict("A09"=> "Finalised schedule",
                "A11"=> "Aggregated energy data report",
                "A15"=> "Acquiring system operator reserve schedule",
                "A24"=> "Bid document",
                "A25"=> "Allocation result document",
                "A26"=> "Capacity document",
                "A31"=> "Agreed capacity",
                "A38"=> "Reserve allocation result document",
                "A44"=> "Price Document",
                "A61"=> "Estimated Net Transfer Capacity",
                "A63"=> "Redispatch notice",
                "A65"=> "System total load",
                "A68"=> "Installed generation per type",
                "A69"=> "Wind and solar forecast",
                "A70"=> "Load forecast margin",
                "A71"=> "Generation forecast",
                "A72"=> "Reservoir filling information",
                "A73"=> "Actual generation",
                "A74"=> "Wind and solar generation",
                "A75"=> "Actual generation per type",
                "A76"=> "Load unavailability",
                "A77"=> "Production unavailability",
                "A78"=> "Transmission unavailability",
                "A79"=> "Offshore grid infrastructure unavailability",
                "A80"=> "Generation unavailability",
                "A81"=> "Contracted reserves",
                "A82"=> "Accepted offers",
                "A83"=> "Activated balancing quantities",
                "A84"=> "Activated balancing prices",
                "A85"=> "Imbalance prices",
                "A86"=> "Imbalance volume",
                "A87"=> "Financial situation",
                "A88"=> "Cross border balancing",
                "A89"=> "Contracted reserve prices",
                "A90"=> "Interconnection network expansion",
                "A91"=> "Counter trade notice",
                "A92"=> "Congestion costs",
                "A93"=> "DC link capacity",
                "A94"=> "Non EU allocations",
                "A95"=> "Configuration document",
                "B11"=> "Flow-based allocations"
                )

PROCESSTYPE = Dict(
    "A01"=> "Day ahead",
    "A02"=> "Intra day incremental",
    "A16"=> "Realised",
    "A18"=> "Intraday total",
    "A31"=> "Week ahead",
    "A32"=> "Month ahead",
    "A33"=> "Year ahead",
    "A39"=> "Synchronisation process",
    "A40"=> "Intraday process",
    "A46"=> "Replacement reserve",
    "A47"=> "Manual frequency restoration reserve",
    "A51"=> "Automatic frequency restoration reserve",
    "A52"=> "Frequency containment reserve",
    "A56"=> "Frequency restoration reserve"
    )

# neighbouring bidding zones that have cross_border flows
NEIGHBOURS = Dict(
    "BE"=> ["NL", "DE_AT_LU", "FR", "GB", "DE_LU"],
    "NL"=> ["BE", "DE_AT_LU", "DE_LU", "GB", "NO_2", "DK_1"],
    "DE_AT_LU"=> ["BE", "CH", "CZ", "DK_1", "DK_2", "FR", "IT_NORD", "IT_NORD_AT", "NL", "PL", "SE_4", "SI"],
    "FR"=> ["BE", "CH", "DE_AT_LU", "DE_LU", "ES", "GB", "IT_NORD", "IT_NORD_FR"],
    "CH"=> ["AT", "DE_AT_LU", "DE_LU", "FR", "IT_NORD", "IT_NORD_CH"],
    "AT"=> ["CH", "CZ", "DE_LU", "HU", "IT_NORD", "SI"],
    "CZ"=> ["AT", "DE_AT_LU", "DE_LU", "PL", "SK"],
    "GB"=> ["BE", "FR", "IE_SEM", "NL"],
    "NO_2"=> ["DE_LU", "DK_1", "NL", "NO_1", "NO_5"],
    "HU"=> ["AT", "HR", "RO", "RS", "SK", "UA"],
    "IT_NORD"=> ["CH", "DE_AT_LU", "FR", "SI", "AT", "IT_CNOR"],
    "ES"=> ["FR", "PT"],
    "SI"=> ["AT", "DE_AT_LU", "HR", "IT_NORD"],
    "RS"=> ["AL", "BA", "BG", "HR", "HU", "ME", "MK", "RO"],
    "PL"=> ["CZ", "DE_AT_LU", "DE_LU", "LT", "SE_4", "SK", "UA"],
    "ME"=> ["AL", "BA", "RS"],
    "DK_1"=> ["DE_AT_LU", "DE_LU", "DK_2", "NO_2", "SE_3", "NL"],
    "RO"=> ["BG", "HU", "RS", "UA"],
    "LT"=> ["BY", "LV", "PL", "RU_KGD", "SE_4"],
    "BG"=> ["GR", "MK", "RO", "RS", "TR"],
    "SE_3"=> ["DK_1", "FI", "NO_1", "SE_2", "SE_4"],
    "LV"=> ["EE", "LT", "RU"],
    "IE_SEM"=> ["GB"],
    "BA"=> ["HR", "ME", "RS"],
    "NO_1"=> ["NO_2", "NO_3", "NO_5", "SE_3"],
    "SE_4"=> ["DE_AT_LU", "DE_LU", "DK_2", "LT", "PL"],
    "NO_5"=> ["NO_1", "NO_2", "NO_3"],
    "SK"=> ["CZ", "HU", "PL", "UA"],
    "EE"=> ["FI", "LV", "RU"],
    "DK_2"=> ["DE_AT_LU", "DE_LU", "DK_1", "SE_4"],
    "FI"=> ["EE", "NO_4", "RU", "SE_1", "SE_3"],
    "NO_4"=> ["SE_2", "FI", "NO_3", "SE_1"],
    "SE_1"=> ["FI", "NO_4", "SE_2"],
    "SE_2"=> ["NO_3", "NO_4", "SE_1", "SE_3"],
    "DE_LU"=> ["AT", "BE", "CH", "CZ", "DK_1", "DK_2", "FR", "NO_2", "NL", "PL", "SE_4"],
    "MK"=> ["BG", "GR", "RS"],
    "PT"=> ["ES"],
    "GR"=> ["AL", "BG", "IT_BRNN", "IT_GR", "MK", "TR"],
    "NO_3"=> ["NO_1", "NO_4", "NO_5", "SE_2"],
    "IT"=> ["AT", "FR", "GR", "MT", "ME", "SI", "CH"],
    "IT_BRNN"=> ["GR", "IT_SUD"],
    "IT_SUD"=> ["IT_BRNN", "IT_CSUD", "IT_FOGN", "IT_ROSN", "IT_CALA"],
    "IT_FOGN"=> ["IT_SUD"],
    "IT_ROSN"=> ["IT_SICI", "IT_SUD"],
    "IT_CSUD"=> ["IT_CNOR", "IT_SARD", "IT_SUD"],
    "IT_CNOR"=> ["IT_NORD", "IT_CSUD", "IT_SARD"],
    "IT_SARD"=> ["IT_CNOR", "IT_CSUD"],
    "IT_SICI"=> ["IT_CALA", "IT_ROSN", "MT"],
    "IT_CALA"=> ["IT_SICI", "IT_SUD"],
    "MT"=> ["IT_SICI"],
    "HR"=> ["BA", "HU", "RS", "SI"]
    )

"""
    lookup_area(s::Union{Area, AbstractString})

Turns the entered area in a correct Area object. Areas can be entered as Area object already or with their IEC-code or 'display name'.
If one of those last 2 options is used a lookup has to be done to find the matching Area object.
Returns the correct Area object.

# Arguments
- `s::Union{Area, AbstractString}`: area as Area object, IEC-code, 'display name'
"""
function lookup_area(s::Union{Area, AbstractString})
    if isa(s, Area)
        # If it already is an Area object, we're happy
        area = s
    else  # It is a string
        try
            # If it is a "country code" string, we do a lookup
            area = [area for area in Areas if area.name == s][1]
        catch 
            try
                # It is not, it may be a direct code
                area = [area for area in Areas if area.value == s][1]
            catch e
                throw(DomainError(s, "Invalid region: check for typo or add the region yourself in mappings.jl"))
            end
        end
    end
    return area
end

"""
    DateTimeTranslator(dateTime::ZonedDateTime, standard::Int = 0)

Transforms a date and/or time into the correct format that has to be used in the GET request used in the ENTSO-E API.
Returns the date and/or time in the requested format.

# Arguments
- `dateTime::ZonedDateTime`: dateTime object with the date and/or time that has to be transformed
- `standard::Int = 0`: variable to indicate the format that is needed
"""
function DateTimeTranslator(dateTime::ZonedDateTime, standard::Int = 0)
    dateTime = DateTime(dateTime, UTC)
    if standard == 0
        dateTimeString = Dates.format(dateTime,"yyyymmddHHMM")
    elseif standard== 1
        dateTimeString = Dates.format(dateTime, "yyyymmddHHMMSSsss")
    elseif standard == 2
        dateTimeString = Dates.format(dateTime, "yyyy-mm-dd")
    end
    return dateTimeString
end


end
