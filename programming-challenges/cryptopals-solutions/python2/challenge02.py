# the cryptopals crypto challenges
# Challenges  Set 1  Challenge 2
# Fixed XOR
# 2024 Marco Piedra Venegas

input_string_1 = "1c0111001f010100061a024b53535009181c"

input_string_2 = "686974207468652062756c6c277320657965"

expected_string = "746865206b696420646f6e277420706c6179"

input_buffer_1 = bytes.fromhex("1c0111001f010100061a024b53535009181c")

input_buffer_2 = bytes.fromhex("686974207468652062756c6c277320657965")

output_buffer = bytes(x ^ y for x, y in zip(input_buffer_1, input_buffer_2))

output_string = output_buffer.hex()

print("Output == Expected?", output_string == expected_string)
