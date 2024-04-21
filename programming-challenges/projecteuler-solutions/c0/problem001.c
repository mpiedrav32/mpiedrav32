// Project Euler 001: Multiples of $3$ or $5$
// 2024 Marco Piedra Venegas

#define _DEFAULT_SOURCE
#include <stdio.h>

const int limit = 1000;

int
main (void)
{
  int sum = 0;
  for (int index = 1; index < limit; ++index)
    {
      if (index % 3 == 0 || index % 5 == 0)
        {
          sum += index;
        }
    }
  printf ("%d\n", sum);
}
