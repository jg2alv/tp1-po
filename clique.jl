using JuMP
using Gurobi

mutable struct CliqueData
    n::Int
    edges::Set{Tuple{Int,Int}}
end

function readData(file)
    n = 0
    E = Set{Tuple{Int,Int}}()

    for l in eachline(file)
        q = split(l, "	")
        
        if q[1] == "n"
		n = parse(Int64, q[2])
		continue
	elseif q[1] == "e"
		u = parse(Int, q[2])
            	v = parse(Int, q[3])
            	push!(E, (u, v))
	else
		print("erro!")
		exit(1)
	end
    end

    return CliqueData(n, E)
end

model = Model(Gurobi.Optimizer)
file = open(ARGS[1], "r")
data = readData(file)
close(file)

n = data.n
E = data.edges

nonEdges = Set{Tuple{Int,Int}}()
for i in 1:n-1, j in i+1:n
    if !((i, j) in E)
        push!(nonEdges, (i, j))
    end
end

@variable(model, x[i=1:n], Bin)

@constraint(model, [ (i,j) in nonEdges ], x[i] + x[j] <= 1)

@objective(model, Max, sum(x[i] for i in 1:n))

optimize!(model)
println("TP1 2023099166 = ", objective_value(model))

