import numpy as np # type: ignore
from PIL import Image # type: ignore

IMG_SIZE = (224, 224)

def preprocess_image(image_path):
    img = Image.open(image_path).convert("RGB")
    img = img.resize(IMG_SIZE)
    img_array = np.array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    return img_array