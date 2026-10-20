using JuMP
using Gurobi

mutable struct LotsizingData
    n::Int
    c::Vector{Float64}
    d::Vector{Float64}
    s::Vector{Float64}
    p::Vector{Float64}
    S0::Float64
    B0::Float64
end

function readData(file)
    n = 0
    c = Float64[]
    d = Float64[]
    s = Float64[]
    p = Float64[]
    S0 = 0.0
    B0 = 0.0

    lineNo = 0
    for l in eachline(file)
        q = split(l, "	")

        if q[1] == "n"
            n = parse(Int, q[2])
            c = fill(0.0, n)
            d = fill(0.0, n)
            s = fill(0.0, n)
            p = fill(0.0, n)
        else
            id = q[1]
            per = parse(Int, q[2])
            val = parse(Float64, q[3])

            if id == "c"
                c[per] = val
            elseif id == "d"
                d[per] = val
            elseif id == "s"
                s[per] = val
            elseif id == "p"
                p[per] = val
            end
        end
    end

    return LotsizingData(n, c, d, s, p, S0, B0)
end

model = Model(Gurobi.Optimizer)
file = open(ARGS[1], "r")
data = readData(file)
close(file)

n, c, d, s, p = data.n, data.c, data.d, data.s, data.p
S0, B0 = data.S0, data.B0

@variable(model, x[1:n] >= 0)
@variable(model, S[1:n] >= 0)
@variable(model, B[1:n] >= 0)

@constraint(model, S[1] - B[1] == (S0 - B0) + x[1] - d[1])
@constraint(model, [i in 2:n], S[i] - B[i] == S[i-1] - B[i-1] + x[i] - d[i])
@constraint(model, S[n] == 0)
@constraint(model, B[n] == 0)

@objective(model, Min,
    sum(c[i]*x[i] for i in 1:n) +
    (n >= 2 ? sum(s[i]*S[i] for i in 1:n-1) : 0.0) +
    sum(p[i]*B[i] for i in 1:n)
)

optimize!(model)
println("TP1 2023099166 = ", round(objective_value(model), digits=6))