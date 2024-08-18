using Revise
includet("nba_game.jl")
includet("read_game_data.jl")
includet("game_fit.jl")
includet("game_sim.jl")
using .NBA_Game
using .GameData
using .GameFitting
using .GameSim

using Distributions

using CSV
using DataFrames
using CairoMakie
using WGLMakie
using BenchmarkTools

#=
# Load the data
# g = read_game_data("0021100429.csv", Game)
nba_csv = CSV.read("game_data/0021100429.csv", DataFrame)

rrange = 0:.01:1.8
srange = 0.5:.01:1.5
game = Game()

# make a plot of the rate function as a subplot
# f = Figure(size = (800, 600))
# r = f[1, 1] = Axis(f, xlabel = "Rate", ylabel = "Density")
# lines!(r, rrange, game.params.rate.(rrange), label="Rate Density")

# make a 3d plot of the strengths function as a subplot
# s = f[1, 2] = Axis3(f, xlabel = "Strength A", ylabel = "Strength B")
# surface!(s, srange, srange, [game.params.strengths.(s1, s2) for s1 in srange, s2 in srange], colormap = :viridis, alpha = 0.2)

for i in 1:1
    if i == 1
        play = tuple(nba_csv[i,:]...)
    else
        play = tuple(nba_csv[i,:][1], nba_csv[i,:][2] - nba_csv[i-1,:][2])
    end
    update_game!(game, play)
    # plot!(xrange, game.params.rate.(xrange), label="Update $i")
    # vline!([30/time_deltas(game)[end]], label="Play $i")
end

# lines!(r, rrange, game.params.rate.(rrange), label="Final Rate Density")
# surface!(s, srange, srange, [game.params.strengths.(s1, s2) for s1 in srange, s2 in srange], colormap = :inferno, alpha = 0.5)
# display(f)
=#

# Importance sampling
function sample_params(game, n)
    r = rand(defaultRate, n)
    wr = game.params.rate.(r) ./ pdf(defaultRate, r)

    s = rand(defaultStrengths, n, 2)
    ws = game.params.strengths.(s[:,1], s[:,2]) ./ (pdf(defaultStrengths, s[:,1]) .* pdf(defaultStrengths, s[:,2]))
    w = wr .* ws

    return r, s, w
end

function sample_games(game, n, k=100)
    results = zeros(n)
    for i in 1:n
        r, s, w = sample_params(game, k)
        sample_results = zeros(k)
        Threads.@threads for j in 1:k
            X = s[j, 1]
            Y = s[j, 2]
            sample_results[j] = simulate_game(game, r[j], X, Y) * w[j]
        end
        results[i] = sum(sample_results) / k
    end
    return sum(results)/n
end

function main()
    nba_csv = CSV.read("game_data/0021100429.csv", DataFrame)
    game = Game()
    
    for i in 1:50
        if i == 1
            play = tuple(nba_csv[i,:]...)
        else
            play = tuple(nba_csv[i,:][1], nba_csv[i,:][2] - nba_csv[i-1,:][2])
        end
        update_game!(game, play)
    end


    p = sample_games(game, 100, 10000)
    q = 1-p

    println("A odds: ", 1/p)
    println("B odds: ", 1/q)
end
