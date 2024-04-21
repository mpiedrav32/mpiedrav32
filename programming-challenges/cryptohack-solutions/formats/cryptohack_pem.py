from Cryptodome.PublicKey import RSA

pemdata = open('privacy_enhanced_mail.pem').read()

print(RSA.importKey(pemdata).d)
