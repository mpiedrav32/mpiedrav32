// the cryptopals crypto challenges
// Challenges  Set 1  Challenge 2
// Fixed XOR
// 2024 Marco Piedra Venegas

#include <ctype.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIZE 1024

size_t read_hexstring(uint8_t buffer[], const uint8_t string[],
                      const size_t string_size);

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

size_t xor_buffers(uint8_t output[], const uint8_t buffer_1[],
                   const uint8_t buffer_2[], const size_t buffer_size_1,
                   const size_t buffer_size_2) {
  size_t output_size = 0;
  if (buffer_size_1 == buffer_size_2) {
    for (size_t index = 0; index < buffer_size_1; ++index) {
      output[output_size++] = buffer_1[index] ^ buffer_2[index];
    }
  }
  return output_size;
}

int main() {
  size_t string_size_1 = 0;
  size_t string_size_2 = 0;
  size_t buffer_size_1 = 0;
  size_t buffer_size_2 = 0;
  size_t output_size = 0;
  uint8_t string_1[MAX_SIZE];
  uint8_t string_2[MAX_SIZE];
  uint8_t buffer_1[MAX_SIZE];
  uint8_t buffer_2[MAX_SIZE];
  uint8_t output[MAX_SIZE];
  memset(string_1, 0, MAX_SIZE);
  memset(string_2, 0, MAX_SIZE);
  memset(buffer_1, 0, MAX_SIZE);
  memset(buffer_2, 0, MAX_SIZE);
  memset(output, 0, MAX_SIZE);
  scanf("%s", string_1);
  scanf("%s", string_2);
  string_size_1 = strlen(string_1);
  string_size_2 = strlen(string_2);
  if (string_size_1 > 0 && string_size_2 > 0) {
    buffer_size_1 = read_hexstring(buffer_1, string_1, string_size_1);
    buffer_size_2 = read_hexstring(buffer_2, string_2, string_size_2);
    output_size =
        xor_buffers(output, buffer_1, buffer_2, buffer_size_1, buffer_size_2);
    if (output_size > 0) {
      for (size_t index = 0; index < output_size; ++index) {
        printf("%x", output[index]);
      }
      printf("\n");
    }
  }
}
