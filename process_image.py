from PIL import Image
## Google Pillow Python for instructions on downloading this library
from math import log

def to_bin(numb):
	bin=0
	while numb:
		bin+=10**(int(log(numb)/log(2)))
		numb -= 2**int(log(numb)/log(2))
	return bin


#put path name here
img = Image.open('TempoSurfing1.png')
pmap = img.load()

pixels = []
background = pmap[0,0]
#the 3's below in the range functions correspond to downsampling the image 3x
#change at will
for i in range(0,img.size[0],3):
	pixels.append([])
	for j in range(0,img.size[1],3):
		if pmap[i,j] != background:
			pixels[-1].append(pmap[i,j])
		else:
			pixels[-1].append((0,0,0))

out = str()
for i in range(len(pixels)):
	out+='8\'b000_%(row)05d: horiz=%(width)d\'h'%{"row":to_bin(i),"width":8*len(pixels[i])}
	for j in range(len(pixels[i])):
		out+='_%(r)02x'%{'r':pixels[i][j][0]} +'%(g)02x'%{'g':pixels[i][j][1]}+'%(b)02x'%{'b':pixels[i][j][2]}
	out+=';\n'

print out