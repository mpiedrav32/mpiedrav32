# 2024 Marco Piedra Venegas
# https://cryptopals.com/sets/1/challenges/7

# AES in ECB mode
# The Base64-encoded content in this file has been encrypted via AES-128 in ECB mode under the key

# "YELLOW SUBMARINE".
# (case-sensitive, without the quotes; exactly 16 characters; I like "YELLOW SUBMARINE" because it's exactly 16 bytes long, and now you do too).

# Decrypt it. You know the key, after all.

# Easiest way: use OpenSSL::Cipher and give it AES-128-ECB as the cipher.

# Do this with code.
# You can obviously decrypt this using the OpenSSL command-line tool, but we're having you get ECB working in code for a reason. You'll need it a lot later on, and not just for attacking ECB.

import base64

input_key = "YELLOW SUBMARINE"

extended_key = input_key * 8

aes_rounds = 10

block_size = 16


def xor_bytes(byte_1: bytes, byte_2: bytes) -> bytes:
    return bytes(x ^ y for x in byte_1 for y in byte_2)


def break_blocks(buffer: bytes) -> list[bytes]:
    return [
        buffer[index * block_size : (index + 1) * block_size]
        for index in range(len(buffer) // block_size + 1)
    ]


def aes_decrypt_buffer(buffer: bytes) -> bytes:
    block_list = break_blocks(buffer)


if __name__ == "__main__":
    with open("7.txt") as file:
        input_string = file.read().strip()
    input_buffer = base64.decodebytes(input_string.encode())
    decrypted = aes_decrypt_buffer(input_buffer)
    print(decrypted)
