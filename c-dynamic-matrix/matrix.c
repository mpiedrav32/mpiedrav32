// 2022 Marco Piedra Venegas
// Dynamically allocated matrix

#include <stdio.h>
#include <stdlib.h>

int main() {
  const size_t row_count = 10;
  const size_t col_count = 20;
  int** matrix = (int**)calloc(row_count, sizeof(int*));
  for (size_t row = 0; row < row_count; ++row) {
    matrix[row] = (int*)calloc(col_count, sizeof(int));
  }

  for (size_t row = 0; row < row_count; ++row) {
    for (size_t col = 0; col < col_count; ++col) {
      matrix[row][col] = col_count * row + col;
    }
  }

  for (size_t row = 0; row < row_count; ++row) {
    for (size_t col = 0; col < col_count; ++col) {
      printf("%3d ", matrix[row][col]);
    }
    printf("\n");
  }

  for (size_t row = 0; row < row_count; ++row) {
    free(matrix[row]);
  }
  free(matrix);
}
