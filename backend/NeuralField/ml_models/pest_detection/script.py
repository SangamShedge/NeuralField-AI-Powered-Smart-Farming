import tensorflow as tf

model = tf.keras.models.load_model("model/pest_model.h5")

print(model.summary())