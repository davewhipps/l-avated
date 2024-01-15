import glob
import os
import pandas as pd


path = '../lavated_raw'
file_paths = os.path.join(path, '**/*.TXT')

all_files = glob.glob(file_paths)

dfs = list()

COLUMNS = ["x", "y", "z", "uuid", "class"]
all_data = pd.DataFrame(columns=COLUMNS)

for f in all_files:
    df = pd.read_csv(f, header=None)
    df.insert(3, COLUMNS[3], '')
    df.insert(4, COLUMNS[4], '')
    df.columns = COLUMNS;
    uuid = f.split("_")[-2]
    df.at[0, 'uuid'] = uuid
    label = f.split("/")[-2]
    df.at[0, 'label'] = label
    all_data = pd.concat([all_data, df], ignore_index=True)

all_data.to_csv(os.path.join(path, 'lavated_gravity_vectors.csv'))