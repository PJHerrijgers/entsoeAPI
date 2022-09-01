using Documenter, entsoeAPI

makedocs(
    modules     = [entsoeAPI],
    format      = Documenter.HTML(mathengine = Documenter.MathJax()),
    sitename    = "entsoeAPI.jl",
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
     repo = "github.com/PJHerrijgers/entsoeAPI.git",
     devbranch = "main"
)