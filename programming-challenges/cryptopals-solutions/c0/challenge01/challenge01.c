// 2024 Marco Piedra Venegas
// Convert hex to base64

// Input regex: [a-f0-9]+
// Output regex: [A-Za-z0-9\+\/]+\={0,2}

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

// Maximum buffer size
const size_t buffer_size = 4096;

// Hex digit chunk size for base64 conversion
const size_t chunk_size = 3;

// base64 alphabet (RFC 4648)
const char base64_alphabet[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

// base64 padding character
const char base64_padding = '=';

// Read hex string. Return hex digit count.
size_t read_hex(char* hex_buffer);

// Convert hex string to base64. Return base64 digit count with padding.
size_t convert_base64(char* buffer, size_t hex_count);

int main() {
  int status = EXIT_SUCCESS;
  char* buffer = (char*)calloc(buffer_size, sizeof(char));
  if (buffer) {
    size_t hex_count = read_hex(buffer);
    if (hex_count > 0) {
      size_t base64_count = convert_base64(buffer, hex_count);
      for (size_t index = 0; index < base64_count; ++index) {
        if (buffer[index] != 0) {
          putchar(buffer[index]);
        }
      }
      putchar('\n');
    } else {
      fprintf(stderr, "Input error\n");
      status = EXIT_FAILURE;
    }
  } else {
    fprintf(stderr, "Allocation error\n");
    status = EXIT_FAILURE;
  }
  if (buffer) {
    free(buffer);
  }
  return status;
}

size_t read_hex(char* buffer) {
  size_t hex_count = 0;
  char c = 0;
  while ((c = getchar()) != EOF && c != '\n' && hex_count < buffer_size) {
    c = tolower(c);
    if (c >= '0' && c <= '9') {
      buffer[hex_count++] = c - '0';
    } else if (c >= 'a' && c <= 'f') {
      buffer[hex_count++] = c - 'a' + 10;
    } else {
      return 0;
    }
  }
  return hex_count;
}

size_t convert_base64(char* buffer, size_t hex_count) {
  size_t padding = 0;
  size_t remainder = hex_count % chunk_size;
  for (size_t index = 0; index < hex_count - remainder; index += chunk_size) {
    buffer[index] = buffer[index] << 2 | buffer[index + 1] >> 2;
    buffer[index] = base64_alphabet[buffer[index]];
    buffer[index + 1] = (buffer[index + 1] & 0x3) << 4 | buffer[index + 2];
    buffer[index + 1] = base64_alphabet[buffer[index + 1]];
    buffer[index + 2] = 0;
  }
  if (remainder == 1) {
    buffer[hex_count - remainder] = buffer[hex_count - remainder] << 2;
    buffer[hex_count - remainder] =
        base64_alphabet[buffer[hex_count - remainder]];
    buffer[hex_count - remainder + 1] = base64_padding;
  } else if (remainder == 2) {
    buffer[hex_count - remainder] = buffer[hex_count - remainder] << 2 |
                                    buffer[hex_count - remainder + 1] >> 2;
    buffer[hex_count - remainder] =
        base64_alphabet[buffer[hex_count - remainder]];
    buffer[hex_count - remainder + 1] =
        (buffer[hex_count - remainder + 1] & 0x3) << 4;
    buffer[hex_count - remainder + 1] =
        base64_alphabet[buffer[hex_count - remainder + 1]];
    buffer[hex_count - remainder + 2] = base64_padding;
    buffer[hex_count - remainder + 3] = base64_padding;
  }
  return hex_count + remainder;
}
