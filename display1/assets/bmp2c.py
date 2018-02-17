import sys
from PIL import Image

img = Image.open(sys.argv[1])

data = img.load()
w, h = img.size

arr = []
for x in range(w) :
  for y in range(0, h, 8) :
    p = [data[x, y + z] for z in range(8)]
    byte = 0x00
    for r in p :
      byte = (byte >> 1) | (0x0 if r == 0 else 0x80)

    arr.append(byte)


print(", ".join(["0x%x" % (byte) for byte in arr]))
