/**
 * @file eratosthenes.c
 * @author Marco Piedra Venegas (marco.piedra@ucr.ac.cr)
 * @brief Sieve of Eratosthenes. Naïve implementation.
 * https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes#Pseudocode
 * @version 0.1
 * @date 2022-05-07
 *
 * @copyright Copyright (c) 2022
 *
 */

#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int parse_arguments(int argc, char* argv[]);

int generate_sieve(size_t limit);

int main(int argc, char* argv[]) { return parse_arguments(argc, argv); }

int parse_arguments(int argc, char* argv[]) {
  int error = EXIT_SUCCESS;
  if (argc == 2) {
    char* end;
    errno = EXIT_SUCCESS;
    long limit = strtol(argv[1], &end, 0);
    if (argv[1] == end) {
      fprintf(stderr, "%s", "error: invalid input\n");
      error = EXIT_FAILURE;
    } else if (errno == ERANGE) {
      fprintf(stderr, "%s", "error: integer out of range\n");
      error = EXIT_FAILURE;
    } else if (limit < 2) {
      fprintf(stderr, "%s", "error: integer must be at least 2\n");
      error = EXIT_FAILURE;
    } else {
      error = generate_sieve(limit);
    }
  } else {
    fprintf(stderr, "%s", "usage: eratosthenes limit\n");
    error = EXIT_FAILURE;
  }
  return error;
}

int generate_sieve(size_t limit) {
  int error = EXIT_SUCCESS;
  const size_t min_prime = 2;
  const size_t sieve_size = limit + 1;
  bool* sieve = (bool*)calloc(sieve_size, sizeof(bool));
  if (sieve) {
    memset(sieve, true, sieve_size);  // Initialize sieve
    for (size_t index = min_prime; index * index <= limit; ++index) {
      if (sieve[index]) {
        for (size_t step = index * index; step <= limit; step += index) {
          sieve[step] = false;
        }
      }
    }
    for (size_t index = min_prime; index < sieve_size; ++index) {
      if (sieve[index]) {
        printf("%zu\n", index);
      }
    }
    free(sieve);
  } else {
    fprintf(stderr, "%s", "error: cannot allocate sieve\n");
    error = EXIT_FAILURE;
  }
  return error;
}
