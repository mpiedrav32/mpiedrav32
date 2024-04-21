// the cryptopals crypto challenges
// Challenges  Set 1  Challenge 6
// Break repeating-key XOR
// 2024 Marco Piedra Venegas

#include <ctype.h>
#include <limits.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIZE 4096

const uint8_t base64_alphabet[64] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

const uint8_t base64_padding = '=';

const size_t min_keysize = 2;

const size_t max_keysize = 40;

const size_t keysize_blocks = 16;

// English letter frequencies in alphabetic order
// Source: https://norvig.com/mayzner.html
const double_t english_frequency[UCHAR_MAX] = {
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0804, 0.0148, 0.0334, 0.0382, 0.1249, 0.0240, 0.0187,
    0.0505, 0.0757, 0.0016, 0.0054, 0.0407, 0.0251, 0.0723, 0.0764, 0.0214,
    0.0012, 0.0628, 0.0651, 0.0928, 0.0273, 0.0105, 0.0168, 0.0023, 0.0166,
    0.0009, 0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0804, 0.0148,
    0.0334, 0.0382, 0.1249, 0.0240, 0.0187, 0.0505, 0.0757, 0.0016, 0.0054,
    0.0407, 0.0251, 0.0723, 0.0764, 0.0214, 0.0012, 0.0628, 0.0651, 0.0928,
    0.0273, 0.0105, 0.0168, 0.0023, 0.0166, 0.0009, 0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,    0.0,
    0.0,    0.0,    0.0};

uint8_t decode_base64_character(uint8_t character) {
  uint8_t value = 0;
  if (character >= 'A' && character <= 'Z') {
    value = character - 'A';
  } else if (character >= 'a' && character <= 'z') {
    value = 26 + character - 'a';
  } else if (character >= '0' && character <= '9') {
    value = 52 + character - '0';
  } else if (character == '+') {
    value = 62;
  } else if (character == '/') {
    value = 63;
  } else if (character == '=') {
    value = 0;
  }
  return value;
}

// Encoded Base64 string:
// __ __ 23 22 21 20 19 18
// __ __ 17 16 15 14 13 12
// __ __ 11 10 09 08 07 06
// __ __ 05 04 03 02 01 00
//
// Decoded Base64 buffer:
// 23 22 21 20 19 18 17 16
// 15 14 13 12 11 10 09 08
// 07 06 05 04 03 02 01 00

size_t decode_base64_string(uint8_t buffer[], const uint8_t string[],
                            size_t string_size) {
  size_t buffer_size = 0;
  for (size_t index = 0; index < string_size; index += 4) {
    buffer[buffer_size++] = (decode_base64_character(string[index]) << 2) |
                            (decode_base64_character(string[index + 1]) >> 4);
    buffer[buffer_size++] = (decode_base64_character(string[index + 1]) << 4) |
                            (decode_base64_character(string[index + 2]) >> 2);
    buffer[buffer_size++] = (decode_base64_character(string[index + 2]) << 6) |
                            (decode_base64_character(string[index + 3]));
  }
  return buffer_size;
}

size_t get_popcount(uint8_t character) {
  size_t popcount = 0;
  for (size_t index = 0; index < 8; ++index) {
    popcount += (character >> index) & 1;
  }
  return popcount;
}

size_t get_hamming_distance(const uint8_t buffer_1[], const uint8_t buffer_2[],
                            size_t buffer_size) {
  size_t distance = 0;
  for (size_t index = 0; index < buffer_size; ++index) {
    distance += get_popcount(buffer_1[index] ^ buffer_2[index]);
  }
  return distance;
}

size_t decrypt_buffer(uint8_t output[], const uint8_t buffer[],
                      const size_t buffer_size) {
  size_t output_size = 0;
  size_t decryption_keysize = 0;
  double current_average = 0;
  double decryption_average = MAX_SIZE;
  for (size_t keysize = min_keysize; keysize <= max_keysize; ++keysize) {
    current_average = 0.0;
    for (size_t offset = 0; offset < (keysize_blocks - 1) * keysize;
         offset += keysize) {
      current_average += get_hamming_distance(
          buffer + offset, buffer + offset + keysize, keysize);
    }
    current_average /= (keysize_blocks * keysize);
    if (current_average < decryption_average) {
      decryption_average = current_average;
      decryption_keysize = keysize;
    }
  }
  printf("decryption average: %f\n", decryption_average);
  printf("decryption keysize: %d\n", decryption_keysize);
  return output_size;
}

int main() {
  size_t string_size = 0;
  size_t buffer_size = 0;
  size_t output_size = 0;
  uint8_t string[MAX_SIZE];
  uint8_t buffer[MAX_SIZE];
  uint8_t output[MAX_SIZE];
  memset(string, 0, MAX_SIZE);
  memset(buffer, 0, MAX_SIZE);
  memset(output, 0, MAX_SIZE);
  int32_t character;
  while ((character = getchar()) != EOF) {
    string[string_size++] = character;
  }
  if (string_size > 0) {
    buffer_size = decode_base64_string(buffer, string, string_size);
    if (buffer_size > 0) {
      output_size = decrypt_buffer(output, buffer, buffer_size);
      if (output_size > 0) {
        printf("%s", output);
      }
    }
  }
}
