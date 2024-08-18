import numpy as np
import pandas as pd
import os
from time import sleep

import tqdm

from nba_api.stats.endpoints import playbyplay
from nba_api.stats.endpoints import leaguegamefinder
from nba_api.stats.library.parameters import Season
from nba_api.stats.library.parameters import SeasonType

def get_games(date_from):
    gamefinder = leaguegamefinder.LeagueGameFinder(season_type_nullable=SeasonType.regular, league_id_nullable='00', date_from_nullable=date_from)  
    games_dict = gamefinder.get_normalized_dict()
    games = games_dict['LeagueGameFinderResults']
    return games


def parse_game(game_id):
    df = playbyplay.PlayByPlay(game_id).get_data_frames()[0]

    # show only made shots
    df = df[df["SCOREMARGIN"].notnull()][["GAME_ID", "EVENTMSGTYPE","PCTIMESTRING", "PERIOD", "SCORE"]]
    df = df[df["SCORE"] != df["SCORE"].shift(1)]
    df = df[df["PCTIMESTRING"] != df["PCTIMESTRING"].shift(-1)]

    # Convert PCTIMESTRING to minutes and seconds
    df['Minutes'] = df['PCTIMESTRING'].str.split(':').apply(lambda x: int(x[0]))
    df['Seconds'] = df['PCTIMESTRING'].str.split(':').apply(lambda x: int(x[1]))

    # Calculate the number of minutes since the game started
    df['Seconds_Since_Start'] = (df['PERIOD'] - 1) * 12 * 60 + (12 - df['Minutes'] - 1) * 60 + (60 - df['Seconds'])
    
    # Calculate the score difference
    df[['Score_Team1', 'Score_Team2']] = df['SCORE'].str.split(' - ', expand=True).astype(int)
    df['Score_Difference'] = df['Score_Team1'] - df['Score_Team2']

    # Drop unnecessary columns
    game_id = df.iloc[0]["GAME_ID"]
    df = df.drop(columns=['Minutes', 'Seconds', 'Score_Team1', 'Score_Team2', "EVENTMSGTYPE", "SCORE", "PCTIMESTRING", "PERIOD", "GAME_ID"])

    return df


def write_game(game):
    if os.path.isfile('game_data/' + game + '.csv'):
        # print("Game already exists")
        return None
    # print("Writing game: ", game)
    df = parse_game(game)
    df.to_csv('game_data/' + game + '.csv', index=False)


games = set([game["GAME_ID"] for game in get_games('01/01/2000')])
pbar = tqdm.tqdm(total=len(games), position=0, bar_format="{desc}: {percentage:3.0f}%|{bar}| {n_fmt}/{total_fmt}")

# print("Number of games: ", len(games))
for game in games:
    pbar.set_description_str(f"Processing game: {game}")
    try:
        write_game(game)
    except:
        # pbar.write("Error in game: " + game)
        sleep(300)
        write_game(game)
    pbar.update(1)
