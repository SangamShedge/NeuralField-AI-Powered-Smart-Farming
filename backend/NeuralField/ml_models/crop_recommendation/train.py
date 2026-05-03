import os
import pandas as pd # type: ignore
import joblib # type: ignore
from sklearn.ensemble import RandomForestClassifier # type: ignore
from sklearn.preprocessing import LabelEncoder # type: ignore

# ---------- PATH SETUP ----------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

data_path = os.path.join(BASE_DIR, "dataset", "crop_data.csv")
model_path = os.path.join(BASE_DIR, "model", "crop_model.pkl")
encoder_path = os.path.join(BASE_DIR, "model", "encoders.pkl")

# ---------- LOAD DATA ----------
df = pd.read_csv(data_path)

# ---------- CLEAN DATA ----------
df = df.apply(lambda x: x.astype(str).str.strip().str.lower())

# ---------- ENCODING ----------
encoders = {}

for col in df.columns:
    le = LabelEncoder()
    df[col] = le.fit_transform(df[col])
    encoders[col] = le

# Save encoders
joblib.dump(encoders, encoder_path)

# ---------- TRAIN MODEL ----------
X = df.drop("crop", axis=1)
y = df["crop"]

model = RandomForestClassifier(n_estimators=150, random_state=42)
model.fit(X, y)

# Save model
joblib.dump(model, model_path)

print("✅ Model trained and saved successfully!")