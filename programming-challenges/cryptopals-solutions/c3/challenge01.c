// the cryptopals crypto challenges
// Challenges  Set 1  Challenge 1
// Convert hex to base64
// 2024 Marco Piedra Venegas

#include <ctype.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIZE 1024

const uint8_t base64_alphabet[64] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

const uint8_t base64_padding = '=';

size_t read_hexstring(uint8_t buffer[], const uint8_t string[],
                      const size_t string_size);

size_t read_base64(uint8_t output[], const uint8_t buffer[],
                   const size_t buffer_size);

uint8_t convert_hexdigit(uint8_t hexdigit) {
  uint8_t number = 0;
  if (hexdigit >= '0' && hexdigit <= '9') {
    number = hexdigit - '0';
  } else if (hexdigit >= 'a' && hexdigit <= 'f') {
    number = 10 + hexdigit - 'a';
  } else if (hexdigit >= 'A' && hexdigit <= 'F') {
    number = 10 + hexdigit - 'A';
  }
  return number;
}

size_t read_hexstring(uint8_t buffer[], const uint8_t string[],
                      const size_t string_size) {
  size_t buffer_size = 0;
  for (size_t index = 0; index < string_size - 1; index += 2) {
    if (isxdigit(string[index]) && isxdigit(string[index + 1])) {
      buffer[buffer_size++] = (convert_hexdigit(string[index]) << 4) |
                              convert_hexdigit(string[index + 1]);
    }
  }
  return buffer_size;
}

size_t read_base64(uint8_t output[], const uint8_t buffer[],
                   const size_t buffer_size) {
  size_t output_size = 0;
  size_t remainder = buffer_size % 3;
  size_t limit = buffer_size - remainder;
  for (size_t index = 0; index < limit; index += 3) {
    output[output_size++] = base64_alphabet[buffer[index] >> 2];
    output[output_size++] = base64_alphabet[((buffer[index] & 0x3) << 4) |
                                            (buffer[index + 1] >> 4)];
    output[output_size++] = base64_alphabet[((buffer[index + 1] & 0xf) << 2) |
                                            (buffer[index + 2] >> 6)];
    output[output_size++] = base64_alphabet[buffer[index + 2] & 0x3f];
  }
  if (remainder == 1) {
    output[output_size++] = base64_alphabet[buffer[limit] >> 2];
    output[output_size++] = base64_alphabet[(buffer[limit] & 0x3) << 4];
    output[output_size++] = base64_padding;
    output[output_size++] = base64_padding;
  } else if (remainder == 2) {
    output[output_size++] = base64_alphabet[buffer[limit] >> 2];
    output[output_size++] = base64_alphabet[((buffer[limit] & 0x3) << 4) |
                                            (buffer[limit + 1] >> 4)];
    output[output_size++] = base64_alphabet[(buffer[limit + 1] & 0xf) << 2];
    output[output_size++] = base64_padding;
  }
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
  scanf("%s", string);
  string_size = strlen(string);
  if (string_size > 0) {
    buffer_size = read_hexstring(buffer, string, string_size);
    if (buffer_size > 0) {
      output_size = read_base64(output, buffer, buffer_size);
      if (output_size > 0) {
        printf("%s\n", output);
      }
    }
  }
}
