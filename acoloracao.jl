using JuMP
using Gurobi

mutable struct AColoracaoData
    n::Int
    adj::Vector{Vector{Int}}
end

function readData(file)
    n = 0
    E = []
    adj = Vector{Vector{Int}}()

    for l in eachline(file)
        q = split(l, "	")

        if q[1] == "n"
            n = parse(Int, q[2])
            adj = [Int[] for _ in 1:n]
        else
            u = parse(Int, q[2])
            v = parse(Int, q[3])
            u == v && continue
            push!(adj[u], v)
            push!(adj[v], u)
        end
    end

    return AColoracaoData(n, adj)
end

model = Model(Gurobi.Optimizer)
file = open(ARGS[1], "r")
data = readData(file)
close(file)

n = data.n
m = n

@variable(model, x[1:m], Bin)
@variable(model, y[1:n, 1:m], Bin)
@variable(model, z[1:n, 1:n, 1:n, 1:n], Bin)

@constraint(model, [v in 1:n], sum(y[v, c] for c in 1:m) == 1)
@constraint(model, [v in 1:n, u in data.adj[v], c in 1:m], y[v, c] + y[u, c] <= 1)
@constraint(model, [c in 1:m, v in 1:n], y[v, c] <= x[c])

for a in 1:n, b in 1:n
    if a != b
        @constraint(model, x[a] + x[b] - 1 <= sum(z[a, b, v, u] for v in 1:n, u in data.adj[v]))

        for v in 1:n, u in data.adj[v]
            @constraint(model, z[a, b, v, u] <= y[v, a])
            @constraint(model, z[a, b, v, u] <= y[u, b])
            @constraint(model, z[a, b, v, u] >= y[v, a] + y[u, b] - 1)
        end
    end
end

@objective(model, Max, sum(x))

optimize!(model)
println("TP1 2023099166 = ", objective_value(model))

