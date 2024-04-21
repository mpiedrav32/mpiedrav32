// 2022 Marco Piedra Venegas
// Polynomial evaluation using function object

#include <iostream>
#include <vector>

template <typename T>
class Polynomial {
 private:
  std::vector<T> coefficients;

 protected:
  T power(T value, size_t exponent) {
    T result = 1;
    for (size_t degree = exponent; degree > 0; --degree) {
      result *= value;
    }
    return result;
  }

 public:
  Polynomial(std::vector<T>& coefs) : coefficients(coefs){};
  T operator()(T value) {
    T result = 0;
    for (size_t index = 0; index < coefficients.size(); ++index) {
      result +=
          coefficients[index] * power(value, coefficients.size() - 1 - index);
    }
    return result;
  }
};

int main() {
  size_t degree = 0;
  std::cout << "Degree of polynomial: ";
  std::cin >> degree;

  double coef = 0;
  std::vector<double> coefficients;
  std::cout << "Coefficients of polynomial (from highest to lowest):"
            << std::endl;
  for (size_t index = 0; index <= degree; ++index) {
    std::cout << "c_" << degree - index << ": ";
    std::cin >> coef;
    coefficients.push_back(coef);
  }

  double value = 0;
  std::cout << "Number to evaluate in polynomial: ";
  std::cin >> value;

  Polynomial<double> poly(coefficients);
  for (size_t index = 0; index < coefficients.size() - 1; ++index) {
    std::cout << coefficients[index] << " * " << value << "^"
              << coefficients.size() - 1 - index << " + ";
  }
  std::cout << coefficients[coefficients.size() - 1] << " = " << poly(value)
            << std::endl;
}
