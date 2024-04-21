from Cryptodome.Util.strxor import strxor

hex_string = "73626960647f6b206821204f21254f7d694f7624662065622127234f726927756d"

raw_bytes = bytes.fromhex(hex_string)

for character in range(0, 128):
    candidate_key = ("".join(chr(character ^ b) for b in raw_bytes))
    print(candidate_key)
    #print(strxor(bytes.fromhex(f'{character:x}' * len(raw_bytes)), raw_bytes))
