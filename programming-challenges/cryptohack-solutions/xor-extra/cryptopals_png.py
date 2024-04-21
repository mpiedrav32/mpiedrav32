from Cryptodome.Util.strxor import strxor
from PIL import Image

lemur = Image.open('lemur.png').tobytes()

flag = Image.open('flag.png').tobytes()

result = strxor(lemur, flag)

lemurflag = Image.new(result, size=lemur.size())

lemurflag.save("lemurflag.png")





