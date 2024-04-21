// 2024 Marco Piedra Venegas
// Fixed XOR

#define _GNU_SOURCE
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

// Maximum buffer size
const size_t buffer_size = 4096;

// Read hex string from buffer. Write digits on the same buffer.
// Return hex digit count.
size_t read_hex_buffer(char* buffer, size_t count);

int main() {
  int status = EXIT_SUCCESS;
  char* first_buffer = (char*)calloc(buffer_size, sizeof(char));
  char* second_buffer = (char*)calloc(buffer_size, sizeof(char));
  if (first_buffer && second_buffer) {
    size_t first_count = getline(&first_buffer, &buffer_size, stdin);
    size_t second_count = getline(&second_buffer, &buffer_size, stdin);
    if (first_count > 0 && first_count == second_count) {
      size_t first_hex_count = read_hex_buffer(first_buffer, first_count);
      size_t second_hex_count = read_hex_buffer(second_buffer, second_count);
      if (first_hex_count > 0 && first_hex_count == second_hex_count) {
        for (size_t index = 0; index < second_count; ++index) {
          putchar(first_buffer[index] ^ second_buffer[index]);
        }
        putchar('\n');
      } else {
        fprintf(stderr, "Format error\n");
        status = EXIT_FAILURE;
      }
    } else {
      fprintf(stderr, "Input error\n");
      status = EXIT_FAILURE;
    }
  } else {
    fprintf(stderr, "Allocation error\n");
    status = EXIT_FAILURE;
  }
  if (first_buffer && second_buffer) {
    free(first_buffer);
    free(second_buffer);
  }
  return status;
}

size_t read_hex_buffer(char* buffer, size_t count) {
  for (size_t index = 0;
       index < count && buffer[index] != '\n' && buffer[index] != EOF;
       ++index) {
    buffer[index] = tolower(buffer[index]);
    if (buffer[index] >= '0' && buffer[index] <= '9') {
      buffer[index] = buffer[index] - '0';
    } else if (buffer[index] >= 'a' && buffer[index] <= 'f') {
      buffer[index] = buffer[index] - 'a' + 10;
    } else {
      return 0;
    }
  }
  return count;
}
