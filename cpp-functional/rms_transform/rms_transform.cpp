// Copyright 2022 Marco Piedra Venegas
// Root mean square using std::transform and std::accumulate

#include <cmath>
#include <functional>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <stdexcept>
#include <utility>
#include <vector>

void root_mean_square(const size_t &term_count) {
  // Lambdas (anonymous functions). Applied using iterators instead of loops.
  auto print_term = [](const int &term) { std::cout << term << " "; };
  auto square_term = [](const int &term) { return term * term; };

  // Generate integer sequence.
  std::vector<int> sequence(term_count);
  std::iota(sequence.begin(), sequence.end(), 1);

  std::cout << std::setprecision(std::numeric_limits<long double>::digits10 +
                                 1);

  std::cout << "Terms: ";
  std::for_each(sequence.begin(), sequence.end(), print_term);
  std::cout << std::endl;

  // Square terms and overwrite sequence.
  std::transform(sequence.begin(), sequence.end(), sequence.begin(),
                 square_term);

  std::cout << "Squared terms: ";
  std::for_each(sequence.begin(), sequence.end(), print_term);
  std::cout << std::endl;

  // Add squared terms
  double sum_squares = std::accumulate(sequence.begin(), sequence.end(), 0);
  double mean = sum_squares / term_count;
  double result = std::sqrt(mean);

  std::cout << "Root mean square: " << result << std::endl;
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
