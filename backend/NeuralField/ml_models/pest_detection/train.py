import os
import json
import tensorflow as tf # type: ignore
from tensorflow.keras.preprocessing import image_dataset_from_directory # type: ignore
from tensorflow.keras.applications import MobileNetV2 # type: ignore
from tensorflow.keras import layers, models # type: ignore

# =========================
# PATHS
# =========================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATASET_DIR = os.path.join(BASE_DIR, "dataset")
MODEL_DIR = os.path.join(BASE_DIR, "model")

os.makedirs(MODEL_DIR, exist_ok=True)

# =========================
# CONFIG
# =========================
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 5   # start small

# =========================
# LOAD DATASET
# =========================
train_ds = image_dataset_from_directory(
    DATASET_DIR,
    validation_split=0.2,
    subset="training",
    seed=123,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE
)

val_ds = image_dataset_from_directory(
    DATASET_DIR,
    validation_split=0.2,
    subset="validation",
    seed=123,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE
)

class_names = train_ds.class_names
print("Classes:", class_names)

# =========================
# SAVE LABELS
# =========================
labels_path = os.path.join(MODEL_DIR, "labels.json")
with open(labels_path, "w") as f:
    json.dump({i: name for i, name in enumerate(class_names)}, f)

# =========================
# PERFORMANCE OPTIMIZATION
# =========================
AUTOTUNE = tf.data.AUTOTUNE

train_ds = train_ds.prefetch(buffer_size=AUTOTUNE)
val_ds = val_ds.prefetch(buffer_size=AUTOTUNE)

# =========================
# MODEL (MobileNetV2)
# =========================
base_model = MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights="imagenet"
)

base_model.trainable = False  # freeze base model

# =========================
# CUSTOM HEAD
# =========================
x = base_model.output
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dense(128, activation="relu")(x)
x = layers.Dropout(0.3)(x)
outputs = layers.Dense(len(class_names), activation="softmax")(x)

model = models.Model(inputs=base_model.input, outputs=outputs)

# =========================
# COMPILE
# =========================
model.compile(
    optimizer="adam",
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"]
)

model.summary()

# =========================
# TRAIN
# =========================
history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS
)

# =========================
# SAVE MODEL
# =========================
model_path = os.path.join(MODEL_DIR, "pest_model.h5")
model.save(model_path, include_optimizer=False, save_format="h5")

print(f"\n✅ Model saved at: {model_path}")
print(f"✅ Labels saved at: {labels_path}")