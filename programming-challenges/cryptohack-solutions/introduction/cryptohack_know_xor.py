ciphertext = "0e0b213f26041e480b26217f27342e175d0e070a3c5b103e2526217f27342e175d0e077e263451150104"

raw_bytes = bytes.fromhex(ciphertext)

candidate_key = bytes("myXORkeymyXORkeymyXORkeymyXORkeymyXORkeymyXORkey", encoding="utf8")

print("".join(chr(b ^ k) for b, k in zip(raw_bytes, candidate_key) ) )
