/**
 * @file small_integers.c
 * @author Marco Piedra Venegas (marco.piedra@ucr.ac.cr)
 * @brief GMP example using small integers.
 * @version 0.1
 * @date 2022-05-03
 *
 * @copyright Copyright (c) 2022
 *
 */

#include <gmp.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
  mpz_t small_number;
  mp_size_t limb_count;
  mpz_init(small_number);
  while (mpz_inp_str(small_number, stdin, 0)) {
    printf("number: ");
    mpz_out_str(stdout, 10, small_number);
    limb_count = mpz_size(small_number);
    printf("\nsize: %zu limbs\n", limb_count);
    for (mp_size_t limb = 0; limb < limb_count; ++limb) {
      printf("limb %3zu: %lu\n", limb, mpz_getlimbn(small_number, limb));
    }
  }
  mpz_clear(small_number);
}
