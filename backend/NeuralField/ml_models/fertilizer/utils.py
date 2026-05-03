import pandas as pd # type: ignore

def get_fertilizer_choices():
    df = pd.read_csv("ml_models/fertilizer/dataset/fertilizer_data.csv")

    # clean data
    df = df.apply(lambda x: x.astype(str).str.strip().str.lower())

    return {
        "crop": sorted(df["crop"].unique().tolist()),
        "growth_stage": sorted(df["growth_stage"].unique().tolist()),
        "soil_type": sorted(df["soil_type"].unique().tolist()),
        "plant_condition": sorted(df["plant_condition"].unique().tolist()),
        "irrigation_type": sorted(df["irrigation_type"].unique().tolist()),
        "soil_moisture": sorted(df["soil_moisture"].unique().tolist())
    }