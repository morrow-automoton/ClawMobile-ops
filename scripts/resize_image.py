#!/usr/bin/env python3
import sys
from pathlib import Path
from PIL import Image

if len(sys.argv) < 3:
    sys.stderr.write("Usage: resize_image.py <input> <output> [max_width]")
    sys.exit(1)

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
max_width = int(sys.argv[3]) if len(sys.argv) > 3 else 1080

img = Image.open(src)
width, height = img.size
if width > max_width:
    ratio = max_width / float(width)
    size = (max_width, int(height * ratio))
    img = img.resize(size, Image.LANCZOS)
img.save(dst)
