using Documenter

push!(LOAD_PATH, "../src/")
include("../src/pals.jl")

makedocs(
    sitename = "pals.jl",
    authors = "Alex He",
    format = Documenter.HTMLWriter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",  # Use pretty URLs on CI
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
    ],
)

deploydocs(
    repo = "https://github.com/pals-project/pals-julia",
)