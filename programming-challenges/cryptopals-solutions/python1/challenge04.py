# 2024 Marco Piedra Venegas
# https://cryptopals.com/sets/1/challenges/4
#
# Detect single-character XOR
# One of the 60-character strings in this file has been encrypted by single-character XOR.
#
# Find it.
#
# (Your code from #3 should help.)

character_frequencies = {character: 0.0 for character in range(256)}

# Source: https://norvig.com/mayzner.html
letter_frequencies = {
    ord("E"): 0.1249,
    ord("T"): 0.0928,
    ord("A"): 0.0804,
    ord("O"): 0.0764,
    ord("I"): 0.0757,
    ord("N"): 0.0723,
    ord("S"): 0.0651,
    ord("R"): 0.0628,
    ord("H"): 0.0505,
    ord("L"): 0.0407,
    ord("D"): 0.0382,
    ord("C"): 0.0334,
    ord("U"): 0.0273,
    ord("M"): 0.0251,
    ord("F"): 0.0240,
    ord("P"): 0.0214,
    ord("G"): 0.0187,
    ord("W"): 0.0168,
    ord("Y"): 0.0166,
    ord("B"): 0.0148,
    ord("V"): 0.0105,
    ord("K"): 0.0054,
    ord("X"): 0.0023,
    ord("J"): 0.0016,
    ord("Q"): 0.0012,
    ord("Z"): 0.0009,
}

character_frequencies |= letter_frequencies


def xor_hex(buffer_1: bytes, buffer_2: bytes) -> bytes:
    return bytes(byte_1 ^ byte_2 for byte_1, byte_2 in zip(buffer_1, buffer_2))


def evaluate_frequencies(buffer: bytes) -> float:
    return 1 / sum(
        abs(
            buffer.upper().count(character) / len(buffer)
            - character_frequencies[character]
        )
        for character in character_frequencies.keys()
    )


def xor_decrypt(buffer: bytes) -> bytes:
    decrypted_scored = {
        decrypted: evaluate_frequencies(decrypted)
        for decrypted in [
            xor_hex(buffer.upper(), bytes([key] * len(buffer))) for key in range(256)
        ]
    }
    return max(decrypted_scored, key=lambda k: decrypted_scored[k])


def xor_decrypt_multiple(buffers: list[bytes]) -> bytes:
    decrypted_multiple_scored = {
        max_decrypted: evaluate_frequencies(max_decrypted)
        for max_decrypted in [xor_decrypt(buffer) for buffer in buffers]
    }
    return max(decrypted_multiple_scored, key=lambda k: decrypted_multiple_scored[k])


if __name__ == "__main__":
    with open("4.txt") as file:
        file_lines = file.read().split()
    input_buffers = [bytes.fromhex(line) for line in file_lines]
    print(xor_decrypt_multiple(input_buffers))
