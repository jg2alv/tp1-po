using JuMP
using Gurobi

mutable struct ColoracaoData
    n::Int
    edges::Set{Tuple{Int,Int}}
end


function readData(file)
    n = 0
    E = Set{Tuple{Int,Int}}()

    for l in eachline(file)
        q = split(l, "	")

        if q[1] == "n"
            n = parse(Int, q[2])
        else
            u = parse(Int, q[2]); v = parse(Int, q[3])
            u == v && continue
            a, b = u < v ? (u, v) : (v, u)
            push!(E, (a, b))
        end
    end

    return ColoracaoData(n, E)
end

model = Model(Gurobi.Optimizer)
file = open(ARGS[1], "r")
data = readData(file)
close(file)

n = data.n
E = collect(data.edges)
m = n

@variable(model, x[1:n, 1:m], Bin)
@variable(model, y[1:m], Bin)

@constraint(model, [v in 1:n], sum(x[v,k] for k in 1:m) == 1)
for (u,v) in E
    @constraint(model, [k in 1:m], x[u,k] + x[v,k] <= y[k])
end

@constraint(model, [v in 1:n, k in 1:m], x[v,k] <= y[k])
@objective(model, Min, sum(y[k] for k in 1:m))

print(model)
optimize!(model)
println("TP1 2023099166 = ", objective_value(model))