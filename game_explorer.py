import nba_api
from nba_api.stats.endpoints import playbyplay
from nba_api.stats.endpoints import leaguegamefinder
from nba_api.stats.library.parameters import Season
from nba_api.stats.library.parameters import SeasonType
import pandas as pd

# read play by play data for game 0021100429
df = playbyplay.PlayByPlay("0021100429").get_data_frames()[0]
# only keep rows where the score margin exists
df = df[df["SCORE"].notnull()]
# Remove rows where the score margin is the same as the previous row and keep the first row
df = df[df["SCORE"] != df["SCORE"].shift(1)]
# if the pct time string is the same as the next row, remove the row
df = df[df["PCTIMESTRING"] != df["PCTIMESTRING"].shift(-1)]

# Convert PCTIMESTRING to minutes and seconds
df['Minutes'] = df['PCTIMESTRING'].str.split(':').apply(lambda x: int(x[0]))
df['Seconds'] = df['PCTIMESTRING'].str.split(':').apply(lambda x: int(x[1]))

# Calculate the number of minutes since the game started
df['Seconds_Since_Start'] = (df['PERIOD'] - 1) * 12 * 60 + (12 - df['Minutes'] - 1) * 60 + (60 - df['Seconds'])

# remove unnecessary columns
df = df[["GAME_ID", "EVENTMSGTYPE","PCTIMESTRING", "PERIOD", "SCORE", "Seconds_Since_Start"]]


# show all rows
pd.set_option('display.max_rows', None)
print(df)