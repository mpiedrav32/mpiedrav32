// Copyright 2022 Marco Piedra Venegas
// Root mean square using std::inner_product

#include <algorithm>
#include <cmath>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <random>
#include <vector>

void root_mean_square(const size_t &term_count) {
  // Lower and upper bound of uniform random distribution
  const double lower = 10.0;
  const double upper = 100.0;

  std::cout << std::setprecision(20);

  std::random_device device;
  std::default_random_engine engine(device());
  std::uniform_real_distribution<> distro(lower, upper);

  // Generate sequence of random terms.
  std::vector<double> sequence(term_count);
  std::generate(sequence.begin(), sequence.end(),
                [&]() { return distro(engine); });

  std::cout << "Sequence:" << std::endl;
  std::for_each(sequence.begin(), sequence.end(),
                [](const double &term) { std::cout << term << std::endl; });

  // Square terms and overwrite sequence.
  double result = std::inner_product(sequence.begin(), sequence.end(),
                                     sequence.begin(), 0.0);
  std::cout << "Square:" << std::endl << result << std::endl;

  result /= term_count;
  std::cout << "Mean:" << std::endl << result << std::endl;

  result = std::sqrt(result);
  std::cout << "Root mean square:" << std::endl << result << std::endl;
}

void print_usage() {
  std::cout << "Usage: ./rms term_count\nwhere term_count > 0" << std::endl;
}

int main(int argc, char **argv) {
  int term_count = 0;

  // Read term count from argument, if available.
  if (argc == 2) {
    term_count = std::strtol(argv[1], nullptr, 0);
    if (term_count > 0) {
      root_mean_square(term_count);
    } else {
      print_usage();
    }
  } else {
    print_usage();
  }
}
