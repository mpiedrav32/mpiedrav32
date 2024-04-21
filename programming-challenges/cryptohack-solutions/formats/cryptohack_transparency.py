from Cryptodome.PublicKey import RSA

pemdata = open('transparency.pem').read()

print('n:', RSA.importKey(pemdata).n)

print('e:', RSA.importKey(pemdata).e)
