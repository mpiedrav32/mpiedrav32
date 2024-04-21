// Cryptopals 01: Convert hex to base64
// 2024 Marco Piedra Venegas

#include <stdio.h>
#include <stdlib.h>

const size_t max_size = 1024;

const char base64_alphabet[64] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

const char base64_padding = '=';

int is_hex(char character);

char get_hex_value(char character);

size_t read_hex_buffer(char *input_buffer);

size_t write_base64_buffer(char *output_buffer, const char *input_buffer,
                           const size_t input_size);

void print_buffer(const char *output_buffer, const size_t output_size);

int main() {
  char *input_buffer = (char *)calloc(max_size, sizeof(char));
  if (input_buffer) {
    char *output_buffer = (char *)calloc(max_size, sizeof(char));
    if (output_buffer) {
      size_t input_size = read_hex_buffer(input_buffer);
      // size_t output_size =
      //     write_base64_buffer(output_buffer, input_buffer, input_size);
      // print_buffer(output_buffer, output_size);
      free(output_buffer);
    }
    free(input_buffer);
  }
}

int is_hex(char character) {
  int status = 0;
  if ((character >= '0' && character <= '9') ||
      (character >= 'a' && character <= 'f') ||
      (character >= 'A' && character <= 'F')) {
    status = 1;
  }
  return status;
}

char get_hex_value(char character) {
  char value = 0;
  if (character >= '0' && character <= '9') {
    value = character - '0';
  } else if (character >= 'a' && character <= 'f') {
    value = 10 + character - 'a';
  } else if (character >= 'A' && character <= 'F') {
    value = 10 + character - 'A';
  }
  return value;
}

size_t read_hex_buffer(char *input_buffer) {
  size_t input_index = 0;
  unsigned int nibble[2] = {0, 0};
  nibble[0] = getchar();
  nibble[1] = getchar();
  while (is_hex(nibble[0]) && is_hex(nibble[1])) {
    input_buffer[input_index] = get_hex_value(nibble[0]) << 4;
    printf("%x", input_buffer[input_index]);
    input_buffer[input_index] |= get_hex_value(nibble[1]);
    printf("%x", input_buffer[input_index]);
    nibble[0] = getchar();
    nibble[1] = getchar();
    input_index++;
  }
  return input_index;
}

size_t write_base64_buffer(char *output_buffer, const char *input_buffer,
                           const size_t input_size) {
  size_t output_index = 0;
  size_t input_index = 0;
  size_t input_remainder = input_size % 3;
  while (input_index < input_size - 3 - input_remainder &&
         output_index < max_size - 4) {
    output_buffer[output_index] =
        base64_alphabet[input_buffer[input_index] >> 2];
    output_buffer[output_index + 1] =
        base64_alphabet[(input_buffer[input_index] & 0x3) << 4 |
                        (input_buffer[input_index + 1] >> 4)];
    output_buffer[output_index + 2] =
        base64_alphabet[(input_buffer[input_index + 1] & 0xf) << 2 |
                        (input_buffer[input_index + 2] >> 6)];
    output_buffer[output_index + 3] =
        base64_alphabet[input_buffer[input_index + 2] & 0x3f];
    input_index += 3;
    output_index += 4;
  }
  if (output_index < max_size - 4) {
    if (input_remainder == 1) {
      output_buffer[output_index] =
          base64_alphabet[input_buffer[input_index] >> 2];
      output_buffer[output_index + 1] =
          base64_alphabet[(input_buffer[input_index] & 0x3) << 4];
      output_buffer[output_index + 2] = base64_padding;
      output_buffer[output_index + 3] = base64_padding;
      output_index += 4;
    } else if (input_remainder == 2) {
      output_buffer[output_index] =
          base64_alphabet[input_buffer[input_index] >> 2];
      output_buffer[output_index + 1] =
          base64_alphabet[(input_buffer[input_index] & 0x3) << 4 |
                          (input_buffer[input_index + 1] >> 4)];
      output_buffer[output_index + 2] =
          base64_alphabet[(input_buffer[input_index + 1] & 0xf) << 2];
      output_buffer[output_index + 3] = base64_padding;
      output_index += 4;
    }
  }
  return output_index;
}

void print_buffer(const char *output_buffer, const size_t output_size) {
  for (size_t index = 0; index < output_size; ++index) {
    putchar(output_buffer[index]);
  }
  putchar('\n');
}
