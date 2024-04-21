// Copyright 2022 Marco Piedra Venegas
// Jagged array using both static and dynamic memory

#include <stdio.h>
#include <stdlib.h>

int main(void) {
  size_t sizes[3] = {7, 11, 13};

  char* jagged[3];
  jagged[0] = (char*)malloc(sizeof(char) * sizes[0]);
  jagged[1] = (char*)malloc(sizeof(char) * sizes[1]);
  jagged[2] = (char*)malloc(sizeof(char) * sizes[2]);

  for (size_t row = 0; row < 3; ++row) {
    for (size_t col = 0; col < sizes[row]; ++col) {
      jagged[row][col] = 'a' + col;
    }
  }

  for (size_t row = 0; row < 3; ++row) {
    for (size_t col = 0; col < sizes[row]; ++col) {
      printf("%c", jagged[row][col]);
    }
    printf("\n");
  }

  for (size_t row = 0; row < 3; ++row) {
    free(jagged[row]);
  }

  int n = 10;
  int* ptr = (int*)malloc(n * sizeof(int));
  ptr[0] = 90;
  free(ptr);
}
