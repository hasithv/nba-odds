module GameFitting
    include("nba_game.jl")
    using Distributions
    using HCubature
    using .NBA_Game

    export update_game!

    function update_game!(game, play::Play)
        if length(game.plays) == 0
            push!(game.plays, play)
        else
            last_play = game.plays[end]
            if play[1] < last_play[1]
                error("Play time must be greater than the last play time")
            end
            # delta_t = play[1] - last_play[1]
            push!(game.plays, play)
        end
        
        td = time_deltas(game)
        sd = scoring_data(game)
        update_rate!(game.params, td)
        update_strengths!(game.params, sd)
    end

    function normalize_rate!(params)
        params.rate_Z *= hcubature(x -> params.rate(x[1]), [0.6], [1.4]; rtol=1e-8)[1]
    end

    function normalize_strengths!(params)
        params.strengths_Z *= hcubature(r -> params.strengths(r[1], r[2]), (0.5,0.5), (1.5,1.5), rtol=1e-8)[1] 
    end

    function update_rate!(params, time_deltas)
        time_deltas = time_deltas/30
        params.rate = (x) -> x^length(time_deltas) * exp(-x * sum(time_deltas)) * pdf(defaultRate, x) / params.rate_Z
        normalize_rate!(params)
    end

    function update_strengths!(params, scoring_data, lookback=15)
        lookback = min(lookback, length(scoring_data))
        scoring_data = scoring_data[end-lookback+1:end]

        score_probs = (x,y) -> prod(map((z) -> score_prob(z, x, y), scoring_data))
        params.strengths = (x,y) -> score_probs(x,y) * pdf(defaultStrengths, x) * pdf(defaultStrengths, y) / params.strengths_Z
        normalize_strengths!(params)
    end
end