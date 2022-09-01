include("../src/entsoeAPI.jl")
include("../src/GETconstructor.jl")
include("../src/xmlParser.jl")
using Documenter
using .entsoeAPI
using .GETconstructor
using .xmlParser

import Pkg; Pkg.add("TimeZones")

makedocs(
    modules     = [entsoeAPI, GETconstructor, xmlParser],
    format      = Documenter.HTML(mathengine = Documenter.MathJax()),
    sitename    = "entsoeAPI",
    authors     = "Pieter-Jan Herrijgers",
    pages       = [
              "Home"    => "index.md",
              "Manual"  => [
                            "Getting Started"                         => "quickguide.md",
                            "Load"                                    => "load.md",
                            "Generation"                              => "generation.md",
                            "Transmission"                            => "transmission.md",
                            "Balancing"                               => "balancing.md",
                            "Outages"                                 => "outages.md",
                            "Congestion management"                   => "congestion.md",
                            ]
                 ]
)

deploydocs(
     repo = "github.com/PJHerrijgers/entsoeAPI.git"
)