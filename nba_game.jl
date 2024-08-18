module NBA_Game
    using Distributions

    export Game, Play, add_play!, time_data, score_data, WalkParams
    export time_deltas, net_score, scoring_data, score_prob
    export defaultRate, defaultStrengths

    Play = Tuple{Real, Int}

    const defaultRate = truncated(Normal(1.005,.1);lower=0.6, upper=1.4)
    const defaultStrengths = truncated(Normal(1, sqrt(.0083)); lower=0.5, upper=1.5)

    @kwdef mutable struct WalkParams
        rate_Z = 1.0
        strengths_Z = 1.0

        rate::Function = (x) -> pdf(defaultRate, x) / rate_Z
        strengths::Function = (x,y) -> pdf(defaultStrengths, x) * pdf(defaultStrengths, y) / strengths_Z
    end

    function score_prob(data, X, Y)
        s, r, delta = data
        if s == 1
            return clamp(X/(X+Y) - .152*r - .0022*delta, 0, 1)
        else
            return clamp(Y/(X+Y) + .152*r + .0022*delta, 0, 1)
        end
    end

    @kwdef mutable struct Game
        plays::Vector{Play} = []
        params::WalkParams = WalkParams()
    end

    Game(plays::Vector{Play}) = Game(plays, WalkParams())

    function time_data(game::Game)
        return [play[1] for play in game.plays]
    end
    
    function time_deltas(game)
        return [game.plays[1][1]; [game.plays[i][1] - game.plays[i-1][1] for i in 2:length(game.plays)]]
    end

    function net_score(game)
        return sum([play[2] for play in game.plays])
    end

    function scoring_data(game)
        data = [(0,0,0) for i in 1:length(game.plays)]
        for i in 1:length(game.plays)
            if i == 1
                data[i] = (sign(game.plays[i][2]), 0, 0)
            else
                data[i] = (sign(game.plays[i][2]), sign(game.plays[i-1][2]), sum([play[2] for play in game.plays[1:i-1]]))
            end
        end
        return data
    end
end
