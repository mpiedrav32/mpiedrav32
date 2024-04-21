// 2022 Marco Piedra Venegas
// Reads a signed 64-bit integer and checks range.

#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
  int error = EXIT_SUCCESS;
  int64_t value = 0;
  while (scanf("%" SCNd64, &value) == 1) {
    if (value > INT64_MIN && value < INT64_MAX) {
      printf("original input = %" PRId64 "\n", value);
      value = labs(value);
      printf("absolute value of input = %" PRId64 "\n", value);
    } else {
      fprintf(stderr, "%s", "error: input out of range\n");
      error = EXIT_FAILURE;
    }
  }
  return error;
}
