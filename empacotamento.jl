using JuMP
using Gurobi

mutable struct EmpacotamentoData
    n::Int
    w::Array{Float64}
    C::Float64
end

function readData(file)
	n = 0
	w = []
	C = 20.0
	for l in eachline(file)
		q = split(l, "	")
		if q[1] == "n"
			n = parse(Int64, q[2])
			continue
		elseif q[1] == "o"
			push!(w, parse(Float64, q[3]))
		else
			print("erro!")
			exit(1)
		end
	end
	return EmpacotamentoData(n,w,C)
end

model = Model(Gurobi.Optimizer)
file = open(ARGS[1], "r")
data = readData(file)
close(file)

n = data.n
m = n
C = data.C
w = data.w

@variable(model, x[i=1:n, j=1:m], Bin)
@variable(model, y[j=1:m], Bin)

@constraint(model, [i=1:n], sum(x[i,j] for j=1:m) == 1)
@constraint(model, [j=1:m], sum(w[i]*x[i,j] for i=1:n) <= C*y[j])

@objective(model, Min, sum(y[j] for j=1:m))

optimize!(model)=
println("TP1 2023099166 = ", objective_value(model))
