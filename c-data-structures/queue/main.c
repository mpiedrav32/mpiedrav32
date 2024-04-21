/**
 * @file main.c
 * @author Marco Piedra Venegas (marco.piedra@ucr.ac.cr)
 * @brief Example program of thread-safe FIFO queue.
 * @version 1.0.0
 * @date 2022-07-28
 *
 * @copyright Copyright (c) 2022
 *
 */

#include "stdio.h"
#include "stdlib.h"
#include "queue.h"
#include "node.h"

int main(int argc, char* argv[]) {
  int error = EXIT_SUCCESS;
  if(argc == 2) {
    int value = 0;
    if(sscanf(argv[1], "%d", value) == 1 && value > 0) {

    } else {
    fprintf(stderr, "%s", "error: invalid argument\n");
    error = EXIT_FAILURE;
    }
  } else {
    fprintf(stderr, "%s", "error: missing argument\n");
    error = EXIT_FAILURE;
  }
  return error;
}
