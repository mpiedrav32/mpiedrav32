// 2024 Marco Piedra Venegas
// Detect single-character XOR

#include <ctype.h>
#include <gmp.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// English letter frequencies, in alphabetic order
// (https://norvig.com/mayzner.html)
const double english_frequencies[] = {
    0.0804, 0.0148, 0.0334, 0.0382, 0.1249, 0.0240, 0.0187, 0.0505, 0.0757,
    0.0016, 0.0054, 0.0407, 0.0251, 0.0723, 0.0764, 0.0214, 0.0012, 0.0628,
    0.0651, 0.0928, 0.0273, 0.0105, 0.0168, 0.0023, 0.0166, 0.0009};

// Number of letters in English alphabet
const size_t english_count = 'z' - 'a' + 1;

// Number base of input buffer
const int input_base = 16;

void decrypt(const char* buffer, size_t buffer_size);

void evaluate_keys(const char* buffer, char* output_buffer, char* temp_buffer,
                   size_t buffer_size);

double score_frequencies(const char* buffer, size_t buffer_size);

int main() {
  mpz_t number;
  mpz_init(number);
  while (stdin) {
    size_t buffer_size = mpz_inp_str(number, stdin, input_base) / 2;
    if (buffer_size > 0) {
      char* buffer = (char*)calloc(buffer_size, sizeof(char));
      if (buffer) {
        mpz_export(buffer, NULL, 1, buffer_size, 1, 0, number);
        decrypt(buffer, buffer_size);
        free(buffer);
      }
    }
  }
  mpz_clear(number);
}

void decrypt(const char* buffer, size_t buffer_size) {
  char* output_buffer = (char*)calloc(buffer_size, sizeof(char));
  if (output_buffer) {
    char* temp_buffer = (char*)calloc(buffer_size, sizeof(char));
    if (temp_buffer) {
      evaluate_keys(buffer, output_buffer, temp_buffer, buffer_size);
      free(temp_buffer);
    }
    free(output_buffer);
  }
}

void evaluate_keys(const char* buffer, char* output_buffer, char* temp_buffer,
                   size_t buffer_size) {
  double output_score = 10000.0;
  int output_key = 0;
  double buffer_frequencies[CHAR_MAX + 1];
  for (int temp_key = 0; temp_key <= CHAR_MAX; ++temp_key) {
    double temp_score = 0.0;
    for (int letter = 0; letter <= CHAR_MAX; ++letter) {
      buffer_frequencies[letter] = 0.0;
    }
    for (size_t buffer_index = 0; buffer_index < buffer_size; ++buffer_index) {
      temp_buffer[buffer_index] = buffer[buffer_index] ^ temp_key;
      for (int letter = 0; letter <= CHAR_MAX; ++letter) {
        if (tolower(temp_buffer[buffer_index]) == letter) {
          ++buffer_frequencies[letter];
        }
      }
    }
    for (int letter = 0; letter <= CHAR_MAX; ++letter) {
      buffer_frequencies[letter] /= buffer_size;
      if (letter >= 'a' && letter <= 'z') {
        temp_score += fabs(buffer_frequencies[letter] -
                           english_frequencies[letter - 'a']);
      } else {
        ++temp_score;
      }
    }
    printf("\n");
    if (temp_score < output_score) {
      output_score = temp_score;
      output_key = temp_key;
      memcpy(output_buffer, temp_buffer, buffer_size);
    }
  }
  printf("score: %f, key: %d, buffer: %s\n", output_score, output_key,
         output_buffer);
}
