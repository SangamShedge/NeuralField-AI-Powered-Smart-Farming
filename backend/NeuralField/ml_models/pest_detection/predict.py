import os
import json
import numpy as np # type: ignore
from .model_loader import model
from .utils import preprocess_image

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LABELS_PATH = os.path.join(BASE_DIR, "model", "labels.json")

with open(LABELS_PATH, "r") as f:
    labels = json.load(f)

def predict_disease(image_path):
    img = preprocess_image(image_path)
    preds = model.predict(img)

    class_index = int(np.argmax(preds))
    confidence = float(np.max(preds))

    disease = labels[str(class_index)]

    return {
        "disease": disease,
        "confidence": round(confidence, 3)
    }