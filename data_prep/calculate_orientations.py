import pandas as pd
import math

path = '../results/lavated_gravity_vectors.csv'
df = pd.read_csv(path)

# Add two new columns for pitch and roll
def calcPitch(row):
	z = row['z']
	x = -math.fabs(row['x']) #Allow for the fact that the device may have been in landscape left/right
	pitch = math.atan2(-z, x) * 180.0 / math.pi
	return pitch - 90.0 # we'll define the pitch as the angle down from the horizon

def calcRoll(row):
	z = row['z']
	y = row['y']
	roll = math.atan2(z, y) * 180.0 / math.pi
	return roll + 90.0  # we'll define the roll as the angle around the z axis

df['pitch'] = df.apply( calcPitch, axis=1 )
df['roll'] = df.apply( calcRoll, axis=1 )

print( 'Min/Max pitch angle:', df.min(axis=0)['pitch'], df.max(axis=0)['pitch'])
print( 'Min/Max roll angle:', df.min(axis=0)['roll'], df.max(axis=0)['roll'])

banked_left_only = df.loc[df['label'] == 'banked-left']
banked_right_only = df.loc[df['label'] == 'banked-right']
grass_only = df.loc[df['label'] == 'grass']
flat_even_only = df.loc[df['label'] == 'flat-even']
sloped_down_only = df.loc[df['label'] == 'sloped-down']
sloped_up_only = df.loc[df['label'] == 'sloped-up']

print( 'Min/Max grass pitch angle:', grass_only.min(axis=0)['pitch'], grass_only.max(axis=0)['pitch'])
print( 'Min/Max grass flat_even angle:', flat_even_only.min(axis=0)['pitch'], flat_even_only.max(axis=0)['pitch'])
print( 'Min/Max sloped-down pitch angle:', sloped_down_only.min(axis=0)['pitch'], sloped_down_only.max(axis=0)['pitch'])
print( 'Min/Max sloped-up pitch angle:', sloped_up_only.min(axis=0)['pitch'], sloped_up_only.max(axis=0)['pitch'])

#Get all of the labels
labels = df['label'].unique()

# Get stats for the pitch
pitch_stats = pd.DataFrame(columns=['min', 'max', 'mean', 'std'])
for label in labels:
	labels_rows = df.loc[df['label'] == label]['pitch']
	pitch_stats.at[label, 'min']  = labels_rows.min(axis=0)
	pitch_stats.at[label, 'max']  = labels_rows.max(axis=0)
	pitch_stats.at[label, 'mean'] = labels_rows.mean(axis=0)
	pitch_stats.at[label, 'std']  = labels_rows.std(axis=0)

print(pitch_stats)

# Get stats for the roll
roll_stats = pd.DataFrame(columns=['min', 'max', 'mean', 'std'])
for label in labels:
	labels_rows = df.loc[df['label'] == label]['roll']
	roll_stats.at[label, 'min']  = labels_rows.min(axis=0)
	roll_stats.at[label, 'max']  = labels_rows.max(axis=0)
	roll_stats.at[label, 'mean'] = labels_rows.mean(axis=0)
	roll_stats.at[label, 'std']  = labels_rows.std(axis=0)

print(roll_stats)
