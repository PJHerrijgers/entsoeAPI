using entsoeAPI
using Test

#= @testset "entsoeAPI.jl" begin

end =#

API-key = "6e9d0b18-9bde-41cf-938f-c8ad9b35d97d"
data = entsoeAPI.test(API-key)
print(data)