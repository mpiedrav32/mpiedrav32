// Project Euler 003: Largest Prime Factor
// 2024 Marco Piedra Venegas

#define _DEFAULT_SOURCE
#include <gmp.h>
#include <stdio.h>

int
main (void)
{
  mpz_t input_number;
  mpz_init_set_ui (input_number, 600851475143);
  mpz_t output_number;
  mpz_init_set_ui (output_number, 0);
  while (mpz_cmp (output_number, input_number) < 0)
    {
      mpz_nextprime (output_number, output_number);
      if (mpz_divisible_p (input_number, output_number) != 0)
        {
          mpz_out_str (stdout, 10, output_number);
          printf ("\n");
        }
    }
  mpz_clear (output_number);
  mpz_clear (input_number);
}
