// Marco Piedra Venegas, Rodrigo Hernández.
// Quadratic polynomial

#include "quadratic.hpp"

#include "monic.hpp"

int quadratic_integer(int x) {
  return monic_integer(x) * ((-1) * (-5) + (-x) * (-1));
}

double quadratic_double(double x) {
  return monic_double(x) * ((-1) * (-5) + (-x) * (-1));
}