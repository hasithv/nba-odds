using DifferentialEquations, ModelingToolkit

function parameterized_lorenz!(du,u,p,t)
    
    #variables are part of vector array u, σ, ρ, β, = p     
    #coefficients are part of vector array p
    x, y, z = u
    σ, ρ, β, = p
    
    du[1] = dx = σ*(y-x)
    du[2] = dy = x*(ρ-z) - y
    du[3] = dz = x*y - β*z

end

#Initial conditions. x=1.0, y=0.0, z=0.0
u0 = [1.0, 0.0, 0.0]#Timespan of the simulation. 100 in this case. 
tspan = (0.0, 100.0)#Coefficients of the functions. 
p = [10.0, 28.0, 8/3]#Feeding the inputs to the solver prob = ODEProblem(parameterized_lorenz!, u0, tspan, p)
prob = ODEProblem(parameterized_lorenz!, u0, tspan, p)

