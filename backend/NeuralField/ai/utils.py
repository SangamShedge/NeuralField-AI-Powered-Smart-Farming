import json
import os

file_path = os.path.join(
    os.path.dirname(__file__),
    "data",
    "fertilizers_data.json"
)

with open(file_path) as f:
    DATA = json.load(f)