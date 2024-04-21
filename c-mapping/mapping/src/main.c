/**
 * @file mapping.c
 * @author Marco Piedra Venegas (marco.piedra@ucr.ac.cr)
 * @brief Mapping simulation. Main program.
 * @version 1.0.0
 * @date 2022-06-06
 *
 * @copyright Copyright (c) 2022
 *
 */

#include <stdio.h>
#include <stdlib.h>

#include "mapping.h"

int main(int argc, char* argv[]) {
  int error = 0;
  mapping_t* mapping = mapping_create();
  if (mapping) {
    error = mapping_run(mapping, argc, argv);
    mapping_destroy(mapping);
  } else {
    fprintf(stderr, "%s", "error: cannot create mapping simulation\n");
    error = EXIT_FAILURE;
  }
  return error;
}
