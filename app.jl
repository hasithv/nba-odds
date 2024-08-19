include("nba_game.jl")
include("game_sim.jl")
using .NBA_Game
using .GameSim
using Distributions
using Random

using GenieFramework, StippleLatex
@genietools

function calc_time(quarter, time)
    return (quarter-1)*12*60 + (12-parse(Int, split(time, ":")[1])-1)*60 + 60 - parse(Int, split(time, ":")[2])
end

function empirical_p(game, n)
    results = zeros(n)
    lambda = rand(defaultRate, n)
    X = rand(defaultStrengths, n, 2)
    Threads.@threads for i in 1:n
        results[i] = simulate_game(game, lambda[i], X[i, 1], X[i, 2])
    end

    return sum(results) / n
end

@handlers begin
# @app GenieApp begin
    @private p = 1.0
    @out podd = 1.0
    @out qodd = 1.0
    @in start = false
    
    @in Ascore = 0
    @in Bscore = 0
    @in quarter = 1
    @in time = "12:00"

    @private running = false

    @onchange start begin
        sss = calc_time(quarter, time)
        s = Ascore - Bscore
        game = Game([(sss, s)], WalkParams())

        
        p = empirical_p(game, 1000000)

        podd = round(1/p,sigdigits=3)
        qodd = round(1/(1-p),sigdigits=3)
    end
end

meta = Dict("og:title" => "Lorenz Chaotic Attractor", "og:description" => "Real-time simulation of a dynamic system with constant UI refresh.", "og:image" => "/preview.jpg")
layout = DEFAULT_LAYOUT(meta=meta)
@page("/", "app.jl.html", layout)
