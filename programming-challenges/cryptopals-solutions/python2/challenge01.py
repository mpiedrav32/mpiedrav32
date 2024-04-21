# the cryptopals crypto challenges
# Challenges  Set 1  Challenge 1
# Convert hex to base64
# 2024 Marco Piedra Venegas

import base64

input_string = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"

expected_string = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"

input_buffer = bytes.fromhex(input_string)

output_buffer = base64.encodebytes(input_buffer)

output_string = output_buffer.decode().strip()

print("Output == Expected?", output_string == expected_string)
