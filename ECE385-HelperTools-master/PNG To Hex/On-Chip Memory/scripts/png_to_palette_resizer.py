from PIL import Image
from collections import Counter
from scipy.spatial import KDTree
import numpy as np
def hex_to_rgb(num):
    h = str(num)
    return int(h[0:4], 16), int(('0x' + h[4:6]), 16), int(('0x' + h[6:8]), 16)
def rgb_to_hex(num):
    h = str(num)
    return int(h[0:4], 16), int(('0x' + h[4:6]), 16), int(('0x' + h[6:8]), 16)
filename = input("What's the image name? ")
new_w, new_h = map(int, input("What's the new height x width? Like 28 28. ").split(' '))
palette_hex = ['0x000000','0xFFFFFF','0xC36633','0xC5A400','0x651C0F', '0xA51914', '0xE3D4D4', '0xCD827E', '0x976E5A', '0x604A2F', '0x7B4118', '0xB3392B', '0xFC4D66', '0x3D72A0', 
               '0x7499CD', '0xB4E3FF', '0x6F94D2', '0x4D70B1', '0x2A3032', '0xA3A8A5', '0xF9FF00', '0x52CE4F', '0x5BAA90', '0x48887E', '0xFFC7BD']
palette_rgb = [hex_to_rgb(color) for color in palette_hex]

pixel_tree = KDTree(palette_rgb)
im = Image.open("C:/Users/SplenDidShot/Desktop/UIUC_stuff/ECE385/Final project/final proj/ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_originals/" + filename+ ".png") #Can be many different formats.
im = im.convert("RGBA")
layer = Image.new('RGBA',(new_w, new_h), (0,0,0,0))
layer.paste(im, (0, 0))
im = layer
#im = im.resize((new_w, new_h),Image.ANTIALIAS) # regular resize
pix = im.load()
pix_freqs = Counter([pix[x, y] for x in range(im.size[0]) for y in range(im.size[1])])
pix_freqs_sorted = sorted(pix_freqs.items(), key=lambda x: x[1])
pix_freqs_sorted.reverse()
print(pix)
outImg = Image.new('RGB', im.size, color='white')
outFile = open("C:/Users/SplenDidShot/Desktop/UIUC_stuff/ECE385/Final project/final proj/ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/" + filename + '.txt', 'w')
i = 0
for y in range(im.size[1]):
    for x in range(im.size[0]):
        pixel = im.getpixel((x,y))
        print(pixel)
        if(pixel[3] < 200):
            outImg.putpixel((x,y), palette_rgb[0])
            outFile.write("%x\n" %(0))
            print(i)
        else:
            index = pixel_tree.query(pixel[:3])[1]
            outImg.putpixel((x,y), palette_rgb[index])
            outFile.write("%x\n" %(index))
        i += 1
outFile.close()
outImg.save("C:/Users/SplenDidShot/Desktop/UIUC_stuff/ECE385/Final project/final proj/ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_converted/" + filename + ".png" )
