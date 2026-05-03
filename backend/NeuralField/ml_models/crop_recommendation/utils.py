import pandas as pd # type: ignore

def get_choices():
    df = pd.read_csv("ml_models/crop_recommendation/dataset/crop_data.csv")
    df = df.apply(lambda x: x.astype(str).str.strip().str.lower())

    return {
        col: sorted(df[col].unique().tolist())
        for col in df.columns if col != "crop"
    }

    # return {
    #     "location": sorted(df["location"].unique()),
    #     "soil_type": sorted(df["soil_type"].unique()),
    #     "water": sorted(df["water"].unique()),
    #     "season": sorted(df["season"].unique()),
    #     "previous_crop": sorted(df["previous_crop"].unique()),
    #     "goal": sorted(df["goal"].unique())
    # }