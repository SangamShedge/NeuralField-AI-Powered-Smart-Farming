import os
import pandas as pd # type: ignore
import joblib # type: ignore
from sklearn.ensemble import RandomForestClassifier # type: ignore
from sklearn.preprocessing import LabelEncoder # type: ignore

# ---------- PATH ----------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

data_path = os.path.join(BASE_DIR, "dataset", "fertilizer_data.csv")
model_path = os.path.join(BASE_DIR, "model", "fertilizer_model.pkl")
encoder_path = os.path.join(BASE_DIR, "model", "encoders.pkl")

# ---------- LOAD ----------
df = pd.read_csv(data_path)

# ---------- CLEAN ----------
for col in df.select_dtypes(include='object').columns:
    df[col] = df[col].str.strip().str.lower()

# ---------- NUMERIC ----------
df["crop_age"] = df["crop_age"].astype(int)
df["temperature"] = df["temperature"].astype(int)

# ---------- ENCODING ----------
encoders = {}

categorical_cols = [
    "crop", "growth_stage", "soil_type",
    "plant_condition", "irrigation_type",
    "soil_moisture", "fertilizer"
]

for col in categorical_cols:
    le = LabelEncoder()
    df[col] = le.fit_transform(df[col])
    encoders[col] = le

# ---------- MODEL ----------
X = df.drop("fertilizer", axis=1)
y = df["fertilizer"]

model = RandomForestClassifier(n_estimators=120, random_state=42)
model.fit(X, y)

# ---------- SAVE ----------
joblib.dump(model, model_path)
joblib.dump(encoders, encoder_path)

print("✅ Fertilizer model trained!")