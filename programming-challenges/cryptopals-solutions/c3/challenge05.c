// the cryptopals crypto challenges
// Challenges  Set 1  Challenge 4
// Implement repeating-key XOR
// 2024 Marco Piedra Venegas

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIZE 1024

const size_t key_size = 3;

const uint8_t key[3] = "ICE";

size_t xor_buffer(uint8_t output[], const uint8_t buffer[],
                  size_t buffer_size) {
  size_t output_size = 0;
  for (size_t index = 0; index < buffer_size; ++index) {
    output[output_size++] = buffer[index] ^ key[index % key_size];
  }
  return output_size;
}

int main() {
  size_t buffer_size = 0;
  size_t output_size = 0;
  uint8_t buffer[MAX_SIZE];
  uint8_t output[MAX_SIZE];
  memset(buffer, 0, MAX_SIZE);
  memset(output, 0, MAX_SIZE);
  int32_t character = 0;
  while ((character = getchar()) != EOF) {
    buffer[buffer_size++] = character;
  }
  if (buffer_size > 0) {
    output_size = xor_buffer(output, buffer, buffer_size);
    if (output_size > 0) {
      for (size_t index = 0; index < output_size; ++index) {
        printf("%02x", output[index]);
      }
    }
    printf("\n");
  }
}
