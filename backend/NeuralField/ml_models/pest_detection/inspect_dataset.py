# inspect_dataset.py

import tensorflow as tf

train_ds = tf.keras.utils.image_dataset_from_directory(
    "dataset",
    validation_split=0.2,
    subset="training",
    seed=123,
    image_size=(224,224),
    batch_size=16
)

print(train_ds.class_names)