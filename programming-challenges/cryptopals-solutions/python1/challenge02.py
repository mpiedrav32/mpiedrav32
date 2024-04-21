# 2024 Marco Piedra Venegas
# https://cryptopals.com/sets/1/challenges/2
#
# Fixed XOR
# Write a function that takes two equal-length buffers and produces their XOR combination.
#
# If your function works properly, then when you feed it the string:
#
# 1c0111001f010100061a024b53535009181c
# ... after hex decoding, and when XOR'd against:
#
# 686974207468652062756c6c277320657965
# ... should produce:
#
# 746865206b696420646f6e277420706c6179

input_string_1 = "1c0111001f010100061a024b53535009181c"

input_string_2 = "686974207468652062756c6c277320657965"

expected_output = "746865206b696420646f6e277420706c6179"


def xor_hex(buffer_1: bytes, buffer_2: bytes) -> bytes:
    return bytes(byte_1 ^ byte_2 for byte_1, byte_2 in zip(buffer_1, buffer_2))


if __name__ == "__main__":
    hex_bytes_1 = bytes.fromhex(input_string_1)
    hex_bytes_2 = bytes.fromhex(input_string_2)
    output_string = xor_hex(hex_bytes_1, hex_bytes_2).hex()
    print(output_string)
    print("Output == Expected?", output_string == expected_output)
