# 2024 Marco Piedra Venegas
# https://cryptopals.com/sets/1/challenges/6

# # Possible keysizes: 29

# Break repeating-key XOR
# It is officially on, now.
# This challenge isn't conceptually hard, but it involves actual error-prone coding. The other challenges in this set are there to bring you up to speed. This one is there to qualify you. If you can do this one, you're probably just fine up to Set 6.

# There's a file here. It's been base64'd after being encrypted with repeating-key XOR.

# Decrypt it.

# Here's how:

# Let KEYSIZE be the guessed length of the key; try values from 2 to (say) 40.
# Write a function to compute the edit distance/Hamming distance between two strings. The Hamming distance is just the number of differing bits. The distance between:
# this is a test
# and
# wokka wokka!!!
# is 37. Make sure your code agrees before you proceed.
# For each KEYSIZE, take the first KEYSIZE worth of bytes, and the second KEYSIZE worth of bytes, and find the edit distance between them. Normalize this result by dividing by KEYSIZE.
# The KEYSIZE with the smallest normalized edit distance is probably the key. You could proceed perhaps with the smallest 2-3 KEYSIZE values. Or take 4 KEYSIZE blocks instead of 2 and average the distances.
# Now that you probably know the KEYSIZE: break the ciphertext into blocks of KEYSIZE length.
# Now transpose the blocks: make a block that is the first byte of every block, and a block that is the second byte of every block, and so on.
# Solve each block as if it was single-character XOR. You already have code to do this.
# For each block, the single-byte XOR key that produces the best looking histogram is the repeating-key XOR key byte for that block. Put them together and you have the key.
# This code is going to turn out to be surprisingly useful later on. Breaking repeating-key XOR ("Vigenere") statistically is obviously an academic exercise, a "Crypto 101" thing. But more people "know how" to break it than can actually break it, and a similar technique breaks something much more important.

# No, that's not a mistake.
# We get more tech support questions for this challenge than any of the other ones. We promise, there aren't any blatant errors in this text. In particular: the "wokka wokka!!!" edit distance really is 37.

import base64

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


def hamming_distance(buffer_1: bytes, buffer_2: bytes) -> int:
    return sum(
        [
            int(xored).bit_count()
            for xored in bytes(
                byte_1 ^ byte_2 for byte_1, byte_2 in zip(buffer_1, buffer_2)
            )
        ]
    )


def average_hamming_distance(buffer: bytes, keysize: int, block_count: int) -> float:
    return sum(
        hamming_distance(
            buffer[index * keysize : (index + 1) * keysize],
            buffer[(index + 1) * keysize : (index + 2) * keysize],
        )
        for index in range(block_count - 1)
    ) / (keysize * block_count)


def search_keysize(buffer: bytes) -> int:
    keysize_scores = {
        keysize: average_hamming_distance(buffer, keysize, 16)
        for keysize in range(2, 41)
    }
    return min(keysize_scores, key=lambda k: keysize_scores[k])


def break_blocks(buffer: bytes, keysize: int) -> list[bytes]:
    return [
        buffer[index * keysize : (index + 1) * keysize]
        for index in range(len(buffer) // keysize + 1)
    ]


def transpose_blocks(block_list: list[bytes], keysize: int) -> list[bytes]:
    return [
        bytes(block[index] for block in block_list if index < len(block))
        for index in range(keysize)
    ]


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


def xor_decrypt_block(buffer: bytes) -> int:
    key_score = {
        key: evaluate_frequencies(decrypted)
        for key in range(256)
        for decrypted in [
            xor_hex(buffer.upper(), bytes([key] * len(buffer)))
        ]
    }
    return max(key_score, key=lambda k: key_score[k])


def search_key(buffer: bytes) -> bytes:
    keysize = search_keysize(buffer)
    block_list = break_blocks(buffer, keysize)
    transposed_list = transpose_blocks(block_list, keysize)
    return bytes(xor_decrypt_block(block) for block in transposed_list)


def xor_repeating(buffer: bytes, key: bytes) -> bytes:
    extended_key = key * len(buffer)
    return bytes(byte_1 ^ byte_2 for byte_1, byte_2 in zip(buffer, extended_key))


def test_hamming_distance():
    print(hamming_distance("this is a test".encode(), "wokka wokka!!!".encode()) == 37)


if __name__ == "__main__":
    with open("6.txt") as file:
        input_string = file.read().strip()
    input_buffer = base64.decodebytes(input_string.encode())
    key = search_key(input_buffer)
    print("Key:", key)
    decrypted_buffer = xor_repeating(input_buffer, key)
    print(decrypted_buffer)
