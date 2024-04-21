// Project Euler 002: Even Fibonacci Numbers
// 2024 Marco Piedra Venegas

#define _DEFAULT_SOURCE
#include <stdio.h>

const int limit = 4000000;

int fibonacci (const int n);

int
main (void)
{
  int fibonacci_value = 0;
  int index = 0;
  int sum = 0;
  while (fibonacci_value < limit)
    {
      fibonacci_value = fibonacci (index++);
      if (fibonacci_value % 2 == 0)
        {
          sum += fibonacci_value;
        }
    }
  printf ("%d\n", sum);
}

int
fibonacci (const int n)
{
  int a = 0, b = 1, c = 0, index = 0;
  while (index++ <= n)
    {
      c = a + b;
      a = b;
      b = c;
    }
  return c;
}
