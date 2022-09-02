using Documenter, entsoeAPI

makedocs(
    modules     = [entsoeAPI],
    format      = Documenter.HTML(mathengine = Documenter.MathJax()),
    sitename    = "entsoeAPI.jl",
    authors     = "Pieter-Jan Herrijgers",
    pages       = [
              "Table of contents"    => "0. Index.md",
              "Manual"  => [
                            "1. Getting Started"                         => "quickguide.md",
                            "2. Load"                                    => "load.md",
                            "3. Transmission"                            => "transmission.md",
                            "4. Congestion management"                   => "congestion.md",
                            "5. Generation"                              => "generation.md",
                            "6. Balancing"                               => "balancing.md",
                            "7. Outages"                                 => "outages.md",
                            ],
               "Further development" => "further.md"
                 ]
)

deploydocs(
     repo = "github.com/PJHerrijgers/entsoeAPI.git",
     devbranch = "main"
)