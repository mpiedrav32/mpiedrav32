// 2022 Marco Piedra Venegas
// XOR cipher
// Sources:
// - Handbook of Applied Cryptography
// (Menezes, van Oorschot, and Vanstone; CRC; 1997)
// https://doi.org/10.1201/9780429466335
// - Introduction to Modern Cryptography
// (Katz and Lindell; CRC; 2021)
// https://doi.org/10.1201/9781351133036

#include <algorithm>
#include <functional>
#include <iostream>

int main() {
  std::string plaintext{"audacious"}, ciphertext(9, '-');
  std::string right_key{"untenable"}, right_decrypted(9, '-');
  std::string wrong_key{"treasures"}, wrong_decrypted(9, '-');

  std::cout << "plaintext = " << plaintext << std::endl;
  std::cout << "right_key = " << right_key << std::endl;

  // Encrypt plaintext with right_key, store in ciphertext
  std::transform(plaintext.begin(), plaintext.end(), right_key.begin(),
                 ciphertext.begin(), std::bit_xor<>());

  // Decrypt ciphertext with right_key, store in right_decrypted
  std::transform(ciphertext.begin(), ciphertext.end(), right_key.begin(),
                 right_decrypted.begin(), std::bit_xor<>());

  std::cout << "right_decrypted = " << right_decrypted << std::endl;

  std::cout << "wrong_key = " << wrong_key << std::endl;

  // Decrypt ciphertext with wrong_key, store in wrong_decrypted
  std::transform(ciphertext.begin(), ciphertext.end(), wrong_key.begin(),
                 wrong_decrypted.begin(), std::bit_xor<>());

  std::cout << "wrong_decrypted = " << wrong_decrypted << std::endl;
}
