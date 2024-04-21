/**
 * @file arith_perf.c
 * @author Marco Piedra Venegas (marco.piedra@ucr.ac.cr)
 * @brief Performance of GMP arithmetic using small integers.
 * @version 0.1
 * @date 2022-05-03
 *
 * @copyright Copyright (c) 2022
 *
 */
#define _DEFAULT_SOURCE

#include <execinfo.h>
#include <gmp.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define SUM_LIMIT 1e6

double get_duration(struct timespec stop_time, struct timespec start_time);
void test_mpz_perf(void);
void test_int64_perf(void);

int main(void) {
  test_mpz_perf();
  test_int64_perf();
}

void test_mpz_perf(void) {
  struct timespec start, stop;
  mpz_t sum_mp, term_mp;
  mpz_init(sum_mp);
  mpz_init(term_mp);
  double duration = 0.0;
  clock_gettime(CLOCK_MONOTONIC, &start);
  for (size_t index = 0; index < SUM_LIMIT; ++index) {
    mpz_set_ui(term_mp, index);
    mpz_add(sum_mp, sum_mp, term_mp);
  }
  clock_gettime(CLOCK_MONOTONIC, &stop);
  duration = get_duration(stop, start);
  printf("Sum using GMP:   %fs\n", duration);
  mpz_clear(term_mp);
  mpz_clear(sum_mp);
}

void test_int64_perf(void) {
  struct timespec start, stop;
  int64_t sum = 0;
  double duration = 0.0;
  clock_gettime(CLOCK_MONOTONIC, &start);
  for (size_t index = 0; index < SUM_LIMIT; ++index) {
    sum += index;
  }
  clock_gettime(CLOCK_MONOTONIC, &stop);
  duration = get_duration(stop, start);
  printf("Sum using int64: %fs\n", duration);
}

// https://jeisson.ecci.ucr.ac.cr/concurrente/2021b/ejemplos/pthreads/hello_iw_shr/src/hello_iw_shr.c
double get_duration(struct timespec stop_time, struct timespec start_time) {
  return (stop_time.tv_sec + 1e-9 * stop_time.tv_nsec) -
         (start_time.tv_sec + 1e-9 * start_time.tv_nsec);
}
