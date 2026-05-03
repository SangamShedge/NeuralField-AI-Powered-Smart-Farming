import joblib # type: ignore
import numpy as np # type: ignore

model = joblib.load("ml_models/crop_recommendation/model/crop_model.pkl")
encoders = joblib.load("ml_models/crop_recommendation/model/encoders.pkl")

DEFAULTS = {
    "location": "satara",
    "soil_type": "loamy",   # fallback
    "water": "medium",
    "season": "kharif",
    "previous_crop": "none",
    "goal": "profit"
}

COLUMNS = ["location", "soil_type", "water", "season", "previous_crop", "goal"]

def predict_crop(data_dict):
    input_data = []

    for col in COLUMNS:
        value = data_dict.get(col, DEFAULTS[col])
        value = str(value).strip().lower()

        if value not in encoders[col].classes_:
            value = DEFAULTS[col]  # fallback if invalid

        encoded = encoders[col].transform([value])[0]
        input_data.append(encoded)

    probs = model.predict_proba([input_data])[0]
    top_indices = np.argsort(probs)[-5:][::-1]

    crops = encoders["crop"].inverse_transform(top_indices)

    # Format output (capitalize for UI)
    crops = [crop.capitalize() for crop in crops]

    return crops