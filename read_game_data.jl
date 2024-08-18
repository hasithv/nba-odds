module GameData
    using CSV
    using DataFrames

    export read_game_data

    function read_game_data(game_id::String, GameClass)
        data = CSV.read("game_data/$(game_id)", DataFrame)
        plays::Vector{Tuple{AbstractFloat, Int}} = []

        for i in 1:nrow(data)
            if i == 1
                push!(plays, (data[i, "Seconds_Since_Start"], data[i, "Score_Difference"]))
            else
                score_delta = data[i, "Score_Difference"] - data[i-1, "Score_Difference"]
                push!(plays, (data[i, "Seconds_Since_Start"], score_delta))
            end
        end
        
        return GameClass(plays)
    end


end