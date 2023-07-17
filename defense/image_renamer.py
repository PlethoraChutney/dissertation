#!/usr/bin/env python
from glob import glob
import os
from PIL import Image
from pillow_heif import register_heif_opener

register_heif_opener()

indulgence_paths = "indulgence"
images = glob(os.path.join(indulgence_paths, "*", "*"))

curr_indices = {}

for im in images:
    _, name, filename = im.split(os.path.sep)
    if name not in curr_indices:
        curr_indices[name] = 0
    must_convert = False

    if name not in filename:
        ext = filename.split(os.extsep)[-1]

        if ext in ["heic", "heif"]:
            must_convert = True
            ext = "jpg"

        new_filename = os.path.join(
            indulgence_paths,
            name,
            f"{name}-{curr_indices[name] + 1:0>2}{os.path.extsep}{ext}",
        )
        while os.path.exists(new_filename):
            curr_indices[name] += 1
            new_filename = os.path.join(
                indulgence_paths,
                name,
                f"{name}-{curr_indices[name] + 1:0>2}{os.path.extsep}{ext}",
            )

        if must_convert:
            Image.open(im).convert("RGB").save(new_filename)
            os.remove(im)
        else:
            os.rename(im, new_filename)
