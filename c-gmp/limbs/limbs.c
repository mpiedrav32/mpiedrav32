/**
 * @file limbs.c
 * @author Marco Piedra Venegas (marco.piedra@ucr.ac.cr)
 * @brief GMP multiplication using multi-limb numbers
 * @version 1.0
 * @date 2022-05-18
 *
 * @copyright Copyright (c) 2022
 *
 */

#include <gmp.h>
#include <stdint.h>
#include <stdio.h>

#define NUMBER_COUNT 3

void store_operands(mpz_t large_numbers[]);
void print_multiplication(mpz_t large_numbers[]);
void print_limbs(mpz_t large_numbers[]);

int main(void) {
  mpz_t large_numbers[NUMBER_COUNT];
  for (size_t index = 0; index < NUMBER_COUNT; ++index) {
    mpz_init(large_numbers[index]);
  }
  store_operands(large_numbers);
  mpz_t large_result;
  mpz_init(large_result);
  mpz_mul(large_result, large_numbers[0], large_numbers[1]);
  // Check results
  if (mpz_cmp(large_result, large_numbers[2]) == 0) {
    print_multiplication(large_numbers);
    print_limbs(large_numbers);
  } else {
    printf("error when multiplying large numbers\n");
  }
  mpz_clear(large_result);
  for (size_t index = 0; index < NUMBER_COUNT; ++index) {
    mpz_clear(large_numbers[index]);
  }
  return 0;
}

void store_operands(mpz_t large_numbers[]) {
  // First factor of RSA-129
  mpz_set_str(
      large_numbers[0],
      "3490529510847650949147849619903898133417764638493387843990820577", 10);
  // Second factor of RSA-129
  mpz_set_str(
      large_numbers[1],
      "32769132993266709549961988190834461413177642967992942539798288533", 10);
  // RSA-129
  mpz_set_str(
      large_numbers[2],
      "114381625757888867669235779976146612010218296721242362562561842935706935"
      "245733897830597123563958705058989075147599290026879543541",
      10);
}

void print_multiplication(mpz_t large_numbers[]) {
  printf("%d bits per limb\n\n", mp_bits_per_limb);
  mpz_out_str(stdout, 10, large_numbers[0]);
  printf("\n(%zu limbs, %zu bits)\n*\n", mpz_size(large_numbers[0]),
         mpz_sizeinbase(large_numbers[0], 2));
  mpz_out_str(stdout, 10, large_numbers[1]);
  printf("\n(%zu limbs, %zu bits)\n==\n", mpz_size(large_numbers[1]),
         mpz_sizeinbase(large_numbers[1], 2));
  mpz_out_str(stdout, 10, large_numbers[2]);
  printf("\n(%zu limbs, %zu bits)\n", mpz_size(large_numbers[2]),
         mpz_sizeinbase(large_numbers[2], 2));
  printf("\n");
}

void print_limbs(mpz_t large_numbers[]) {
  mp_size_t limb_count;
  for (size_t number_index = 0; number_index < NUMBER_COUNT; ++number_index) {
    mpz_out_str(stdout, 10, large_numbers[number_index]);
    printf("\n==\n0x");
    mpz_out_str(stdout, 16, large_numbers[number_index]);
    printf("\nlimbs:\n");
    limb_count = mpz_size(large_numbers[number_index]);
    for (mp_size_t limb_index = 0; limb_index < limb_count; ++limb_index) {
      printf("%zx%s",
             large_numbers[number_index]->_mp_d[limb_count - limb_index - 1],
             limb_index < limb_count - 1 ? " | " : "");
    }
    printf("\n\n");
  }
}
