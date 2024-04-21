from Cryptodome.PublicKey import RSA

derdata = open('2048b-rsa-example-cert.der', 'br').read()

print(RSA.importKey(derdata).n)
