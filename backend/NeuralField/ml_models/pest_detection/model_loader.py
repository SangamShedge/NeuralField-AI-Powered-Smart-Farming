import os
import tensorflow as tf # type: ignore

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "model", "pest_model.h5")

model = tf.keras.models.load_model(MODEL_PATH)