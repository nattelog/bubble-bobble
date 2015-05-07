from PIL import Image

im = Image.open("fiende2.png")
def convertToBin(integer):
	 return '{message:{fill}{align}{width}}'.format(message=bin(integer)[2:], fill = '0', align = '>', width = 3)
def convertToBinBlue(integer):
	 return '{message:{fill}{align}{width}}'.format(message=bin(integer)[2:], fill = '0', align = '>', width = 2)
	


pix = im.load()
res = ""
tmp = 0
tmp2 = 0
tmp3 = 0
size = 16
for y in range(size):
	res += '"'
	for x in range(size):
		tmp = pix[x,y][0] 	
		tmp = tmp//32	
		tmp2 = pix[x,y][1]
		tmp2 = tmp2//32
		tmp3 = pix[x,y][2]
		tmp3 = tmp3//64

		res += str(convertToBin(tmp))
		res += str(convertToBin(tmp2))
		res += str(convertToBinBlue(tmp3))  

	res += '"' 
	res += ","
	res += "\n"
		
print (res)



 

