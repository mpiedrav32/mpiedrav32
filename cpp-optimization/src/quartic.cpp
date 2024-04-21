// Marco Piedra Venegas, Rodrigo Hernández.
// Quartic polynomial

#include "quartic.hpp"

#include <cmath>

#include "cubic.hpp"

int quartic_integer(int x) {
  return cubic_integer(x) * ((x - 20) + ((6 - 2) - 1));
}

double quartic_double(double x) {
  return cubic_double(x) * ((x - 20) + ((6 - 2) - 1));
}

int quartic_integer_expanded(int x) {
  return x * x * x * x - 25 * x * x * x + 107 * x * x + 673 * x - 3060;
}

double quartic_double_expanded(double x) {
  return x * x * x * x - 25 * x * x * x + 107 * x * x + 673 * x - 3060;
}