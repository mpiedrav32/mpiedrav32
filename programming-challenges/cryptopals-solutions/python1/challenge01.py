# 2024 Marco Piedra Venegas
# https://cryptopals.com/sets/1/challenges/1
#
# Convert hex to base64
# The string:
#
# 49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d
# Should produce:
#
# SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t
# So go ahead and make that happen. You'll need to use this code for the rest of the exercises.
#
# Cryptopals Rule
# Always operate on raw bytes, never on encoded strings. Only use hex and base64 for pretty-printing.

import base64

input_string = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"

expected_string = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"


def convert_hex_base64(buffer: bytes) -> bytes:
    return base64.encodebytes(buffer)


if __name__ == "__main__":
    hex_bytes = bytes.fromhex(input_string)
    base64_bytes = convert_hex_base64(hex_bytes)
    output_string = base64_bytes.decode().strip()
    print(output_string)
    print("Output == Expected?", output_string == expected_string)
