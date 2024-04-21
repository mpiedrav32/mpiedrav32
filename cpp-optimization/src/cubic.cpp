// Marco Piedra Venegas, Rodrigo Hernández.
// Cubic polynomial

#include "cubic.hpp"

#include "quadratic.hpp"

int cubic_integer(int x) {
  return quadratic_integer(x) * ((x * x * x) / (x * x) - (9 * 9) / 9);
}

double cubic_double(double x) {
  return quadratic_double(x) * ((x * x * x) / (x * x) - (9 * 9) / 9);
}