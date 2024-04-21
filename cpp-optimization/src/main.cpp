// Marco Piedra Venegas, Rodrigo Hernández.
// Showcase of arithmetic compiler optimizations and limitations.
// Calculate quartic polynomial (x-4)(x+5)(x-9)(x-17), which expands to
// x**4 - 25 * x**3 + 107 * x**2 + 673 * x - 3060

#include <iostream>

#include "quartic.hpp"

int main() {
  const size_t sample_size = 10;
  int samples_integer[sample_size] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
  double samples_double[sample_size] = {1.1, 2.2, 3.3, 4.4, 5.5,
                                        6.6, 7.7, 8.8, 9.9, 10.01};

  // Factorized polynomial, using include

  int results_integer[sample_size] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  double results_double[sample_size] = {0.0, 0.0, 0.0, 0.0, 0.0,
                                        0.0, 0.0, 0.0, 0.0, 0.0};

  for (size_t index = 0; index < sample_size; ++index) {
    results_integer[index] = quartic_integer(samples_integer[index]);
  }

  for (size_t index = 0; index < sample_size; ++index) {
    results_double[index] = quartic_double(samples_double[index]);
  }

  std::cout << "Calculate f(x) = (x-4)(x+5)(x-9)(x-17)\n";

  std::cout << std::endl;

  std::cout << "Using integers:\n";

  for (size_t index = 0; index < sample_size; ++index) {
    std::cout << "f(" << samples_integer[index]
              << ") = " << results_integer[index] << std::endl;
  }

  std::cout << std::endl;

  std::cout << "Using doubles:\n";

  for (size_t index = 0; index < sample_size; ++index) {
    std::cout << "f(" << samples_double[index]
              << ") = " << results_double[index] << std::endl;
  }

  std::cout << std::endl;

  // Expanded polynomial

  int results_integer_expanded[sample_size] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  double results_double_expanded[sample_size] = {0.0, 0.0, 0.0, 0.0, 0.0,
                                                 0.0, 0.0, 0.0, 0.0, 0.0};

  for (size_t index = 0; index < sample_size; ++index) {
    results_integer_expanded[index] =
        quartic_integer_expanded(samples_integer[index]);
  }

  for (size_t index = 0; index < sample_size; ++index) {
    results_double_expanded[index] =
        quartic_double_expanded(samples_double[index]);
  }

  std::cout
      << "Calculate f(x) = x**4 - 25 * x**3 + 107 * x**2 + 673 * x - 3060\n";

  std::cout << std::endl;

  std::cout << "Using integers:\n";

  for (size_t index = 0; index < sample_size; ++index) {
    std::cout << "f(" << samples_integer[index]
              << ") = " << results_integer_expanded[index] << std::endl;
  }

  std::cout << std::endl;

  std::cout << "Using doubles:\n";

  for (size_t index = 0; index < sample_size; ++index) {
    std::cout << "f(" << samples_double[index]
              << ") = " << results_double_expanded[index] << std::endl;
  }
}