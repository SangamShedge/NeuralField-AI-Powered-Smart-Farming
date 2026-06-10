import os
import json
# from PIL import Image # type: ignore
import numpy as np # type: ignore
import tensorflow as tf # type: ignore
from utils import preprocess_image

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

MODEL_PATH = os.path.join(
    BASE_DIR,
    "model",
    "pest_model.h5"
)

LABELS_PATH = os.path.join(
    BASE_DIR,
    "model",
    "labels.json"
)

model = tf.keras.models.load_model(MODEL_PATH)

with open(LABELS_PATH, "r") as f:
    labels = json.load(f)

# IMAGE_PATH = r"dataset\Pepper_Bell_Bacterial_spot\0a0dbf1f-1131-496f-b337-169ec6693e6f___NREC_B.Spot 9241.JPG"
IMAGE_PATH = r"dataset\Unknown\bike_065.bmp"

img = preprocess_image(IMAGE_PATH)

print("Shape:", img.shape)
print("Min:", np.min(img))
print("Max:", np.max(img))
print("Mean:", np.mean(img))

img = preprocess_image(IMAGE_PATH)

preds = model.predict(img, verbose=0)[0]

print("\nPredictions:\n")

for idx, prob in enumerate(preds):
    print(
        labels[str(idx)],
        "=",
        round(float(prob), 5)
    )

print(
    "\nPrediction:",
    labels[str(np.argmax(preds))]
)

print(
    "Confidence:",
    round(float(np.max(preds)), 5)
)

print("Labels:")
print(labels)
print("Output shape:", model.output_shape)