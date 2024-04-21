# the cryptopals crypto challenges
# Challenges  Set 1  Challenge 4
# Detect single-character XOR
# 2024 Marco Piedra Venegas

english_distribution = {character: 0.0 for character in range(256)}

english_distribution |= {
    ord("e"): 0.1249,
    ord("t"): 0.0928,
    ord("a"): 0.0804,
    ord("o"): 0.0764,
    ord("i"): 0.0757,
    ord("n"): 0.0723,
    ord("s"): 0.0651,
    ord("r"): 0.0628,
    ord("h"): 0.0505,
    ord("l"): 0.0407,
    ord("d"): 0.0382,
    ord("c"): 0.0334,
    ord("u"): 0.0273,
    ord("m"): 0.0251,
    ord("f"): 0.0240,
    ord("p"): 0.0214,
    ord("g"): 0.0187,
    ord("w"): 0.0168,
    ord("y"): 0.0166,
    ord("b"): 0.0148,
    ord("v"): 0.0105,
    ord("k"): 0.0054,
    ord("x"): 0.0023,
    ord("j"): 0.0016,
    ord("q"): 0.0012,
    ord("z"): 0.0009,
}

with open("4.txt", "r") as file:
    input_strings = [line for line in file.readlines()]

input_buffers = [bytes.fromhex(line) for line in input_strings]

decryptions = {
    key: bytes(x ^ y for x, y in zip(buffer, [key] * len(buffer)))
    for key in range(256)
    for buffer in input_buffers
}

decryption_scores = {
    key: sum(
        [
            abs(
                decryptions[key].lower().count(character) / len(buffer)
                - english_distribution[character]
            )
            for character in range(256)
        ]
    )
    for key in range(256)
    for buffer in input_buffers
}

decryption_key = min(decryption_scores, key=lambda k: decryption_scores[k])

output_buffer = decryptions[decryption_key]

# output_string = output_buffer.decode().strip()

print("key:", decryption_key)

print("plaintext:", output_buffer)
