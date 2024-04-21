// the cryptopals crypto challenges
// Challenges  Set 1  Challenge 3
// Single-byte XOR cipher
// 2024 Marco Piedra Venegas

#include <ctype.h>
#include <limits.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIZE 1024

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

double_t evaluate_decryption(uint8_t buffer[], const size_t buffer_size) {
  double_t score = 0.0;
  double_t buffer_frequency[UCHAR_MAX];
  for (size_t index = 0; index < UCHAR_MAX; ++index) {
    buffer_frequency[index] = 0.0;
  }
  for (size_t byte = 0; byte < UCHAR_MAX; ++byte) {
    for (size_t index = 0; index < buffer_size; ++index) {
      if (buffer[index] == byte) {
        buffer_frequency[byte]++;
      }
    }
    buffer_frequency[byte] /= buffer_size;
  }
  for (size_t byte = 0; byte < UCHAR_MAX; ++byte) {
    score += fabs(buffer_frequency[byte] - english_frequency[byte]);
  }
  return score;
}

size_t decrypt_buffer(uint8_t output[], const uint8_t buffer[],
                      const size_t buffer_size) {
  size_t output_size = 0;
  double_t current_score = 0.0;
  double_t decryption_score = MAX_SIZE;
  uint8_t current_key[MAX_SIZE];
  uint8_t decryption_key[MAX_SIZE];
  memset(current_key, 0, MAX_SIZE);
  memset(decryption_key, 0, MAX_SIZE);
  for (uint8_t key = 0; key < 127; ++key) {
    memset(current_key, key, buffer_size);
    xor_buffers(output, buffer, current_key, buffer_size, buffer_size);
    current_score = evaluate_decryption(output, buffer_size);
    if (current_score < decryption_score) {
      decryption_score = current_score;
      memcpy(decryption_key, current_key, buffer_size);
    }
  }
  output_size =
      xor_buffers(output, buffer, decryption_key, buffer_size, buffer_size);
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
      output_size = decrypt_buffer(output, buffer, buffer_size);
      if (output_size > 0) {
        printf("%s\n", output);
      }
    }
  }
}
