import os

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import tensorflow as tf # type: ignore

tf.get_logger().setLevel("ERROR")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "model", "pest_model.h5")

model = tf.keras.models.load_model(MODEL_PATH)

print("Loading:", MODEL_PATH)
print("Model output shape:", model.output_shape)