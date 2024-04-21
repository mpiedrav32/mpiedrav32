from Cryptodome.PublicKey import RSA

sshdata = open('bruce_rsa.pub').read()

print(RSA.importKey(sshdata).n)
