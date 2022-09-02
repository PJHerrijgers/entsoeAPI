using Documenter, entsoeAPI

makedocs(
    modules     = [entsoeAPI],
    format      = Documenter.HTML(mathengine = Documenter.MathJax()),
    sitename    = "entsoeAPI.jl",
    authors     = "Pieter-Jan Herrijgers",
    pages       = [
              "Table of contents"    => "index.md",
              "Manual"  => [
                            "Getting Started"                         => "quickguide.md",
                            "Load"                                    => "load.md",
                            "Transmission"                            => "transmission.md",
                            "Congestion management"                   => "congestion.md",
                            "Generation"                              => "generation.md",
                            "Balancing"                               => "balancing.md",
                            "Outages"                                 => "outages.md",
                            ],
               "Further development" => "further.md"
                 ]
)

deploydocs(
     repo = "github.com/PJHerrijgers/entsoeAPI.git",
     devbranch = "main"
)