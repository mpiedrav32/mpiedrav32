// Copyright 2021 Jeisson Hidalgo <jeisson.hidalgo@ucr.ac.cr> CC-BY 4.0
#include <gmp.h>  // sudo apt install libgmp-dev
#include <stdio.h>
#include <stdlib.h>

/// Test basic operations: +, -, *, div, mod
void test_operations(mpz_t num1, mpz_t num2);
/// Prints num1 operator num2 == result
void print_result(mpz_t num1, const char* operator, mpz_t num2, mpz_t result);

/// Tests arbitrary arithmetic operations
int main(void) {
  int error = EXIT_SUCCESS;

  // Create and init two arbitrary precision integers (mpz_t is a record)
  // mpz=integer, mpq=relational, mpfr=float, mpn=low_level
  mpz_t num1, num2;
  mpz_init(num1);
  mpz_init(num2);

  // Set signed and unsigned integers
  mpz_set_si(num1, -101);
  mpz_set_ui(num2, 2);

  // Test basic arithmetic operations
  test_operations(num1, num2);

  // Read two arbitrary precision numbers as strings from stdin
  char num1text[1024], num2text[1024];
  if (scanf("%1023s %1023s", num1text, num2text) == 2) {
    // Convert text to arbitrary precision integer
    error += mpz_set_str(num1, num1text, /*base*/ 10);
    error += mpz_set_str(num2, num2text, /*base*/ 10);

    // If mpz_set_str success returns 0, otherwise returns -1
    if (error == 0) {
      // Test basic arithmetic operations
      test_operations(num1, num2);
    } else {
      fprintf(stderr, "invalid number\n");
    }
  }

  // Release memory
  mpz_clear(num1);
  mpz_clear(num2);

  return error;
}

void test_operations(mpz_t num1, mpz_t num2) {
  // Store the result of arbitrary precision operations
  mpz_t result;
  mpz_init(result);

  // Test basic operations and print result to stdout:
  // a + b
  mpz_add(result, num1, num2);
  print_result(num1, "+", num2, result);
  // a - b
  mpz_sub(result, num1, num2);
  print_result(num1, "-", num2, result);
  // a * b
  mpz_mul(result, num1, num2);
  print_result(num1, "*", num2, result);
  // a div b
  mpz_div(result, num1, num2);
  print_result(num1, "/", num2, result);
  // a mod b
  mpz_mod(result, num1, num2);
  print_result(num1, "mod", num2, result);

  mpz_clear(result);
}

void print_result(mpz_t num1, const char* operator, mpz_t num2, mpz_t result) {
  mpz_out_str(stdout, /*base*/ 10, num1);
  fprintf(stdout, " %s ", operator);
  mpz_out_str(stdout, /*base*/ 10, num2);
  fprintf(stdout, " == ");
  mpz_out_str(stdout, /*base*/ 10, result);
  fprintf(stdout, "\n");
}
