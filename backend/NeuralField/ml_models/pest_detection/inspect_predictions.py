import os
import json
import numpy as np
import tensorflow as tf

from utils import preprocess_image

model = tf.keras.models.load_model("model/pest_model.h5")

with open("model/labels.json") as f:
    labels = json.load(f)

folders = [
    "Pepper_Bell_Bacterial_spot",
    "Pepper_Bell_Healthy",
    "Potato_Early_blight",
    "Potato_Late_blight",
    "Tomato_Early_blight",
    "Tomato_Healthy",
    "Tomato_Late_blight",
    "Unknown"
]

print("\nResults:\n")

for folder in folders:
    path = os.path.join("dataset", folder)

    image_name = os.listdir(path)[0]
    image_path = os.path.join(path, image_name)

    img = preprocess_image(image_path)

    pred = model.predict(img, verbose=0)[0]

    prediction = labels[str(np.argmax(pred))]
    confidence = float(np.max(pred))

    print(
        f"{folder:30} -> {prediction:30} ({confidence:.4f})"
    )