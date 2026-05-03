import joblib # type: ignore

model = joblib.load("ml_models/fertilizer/model/fertilizer_model.pkl")
encoders = joblib.load("ml_models/fertilizer/model/encoders.pkl")

def get_fertilizer_message(fertilizer):
    mapping = {
        "urea": "Apply Urea 20kg per acre",
        "dap": "Use DAP 15kg per acre",
        "potash": "Apply Potash for better fruiting",
        "compost": "Add compost to improve soil health",
        "organic fertilizer": "Use organic fertilizer"
    }
    return mapping.get(fertilizer, fertilizer)

def predict_fertilizer(data):
    input_data = []

    for col in [
        "crop",
        "growth_stage",
        "soil_type",
        "plant_condition",
        "irrigation_type",
        "soil_moisture"
    ]:
        value = str(data[col]).strip().lower()
        encoded = encoders[col].transform([value])[0]
        input_data.append(encoded)

    # numeric values
    input_data.append(int(data["crop_age"]))
    input_data.append(int(data["temperature"]))

    prediction = model.predict([input_data])[0]

    fertilizer = encoders["fertilizer"].inverse_transform([prediction])[0]

    return {
        "fertilizer": fertilizer.capitalize(),
        "recommendation": get_fertilizer_message(fertilizer)
    }