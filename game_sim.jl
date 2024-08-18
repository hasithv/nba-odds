module GameSim
    include("nba_game.jl")
    include("game_fit.jl")
    using Distributions
    using Random
    using .NBA_Game
    using .GameFitting

    export simulate_game

    function simulate_game(game, lambda, Xa, Xb)
        if length(game.plays) == 0
            t = 0
            s = 0
            r = 0
        else
            t = game.plays[end][1]
            s = net_score(game)
            r = sign(game.plays[end][2])
        end

        while t < 2880
            t += rand(Exponential(1/lambda)) * 30
            if rand() < score_prob((1, r, s), Xa, Xb)
                s += random_play()
                r = 1
            else
                s -= random_play()
                r = -1
            end
        end

        return (sign(s)+1)/2
    end

    function random_play()
        x = rand()
        # This is wrong
        if x < .087
            return 1
        elseif x < .7386+0.087
            return 2
        elseif x < .7386+0.087+0.1728
            return 3
        elseif x < .7386+0.087+0.1728+0.0014
            return 4
        elseif x < .7386+0.087+0.1728+0.0014+0.00023
            return 5
        elseif x < .7386+0.087+0.1728+0.0014+0.00023+0.000012
            return 6
        end
    end
end