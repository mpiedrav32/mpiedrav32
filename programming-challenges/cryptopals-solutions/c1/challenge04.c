// Cryptopals 04: Detect single-character XOR
// 2024 Marco Piedra Venegas

#define _DEFAULT_SOURCE
#include <ctype.h>
#include <limits.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFFER_MAXSIZE 1024

#define LETTER_COUNT 26

// English letter frequency in alphabetic order
const double english_frequencies[26]
    = { 0.0804, 0.0148, 0.0334, 0.0382, 0.1249, 0.0240, 0.0187, 0.0505, 0.0757,
        0.0016, 0.0054, 0.0407, 0.0251, 0.0723, 0.0764, 0.0214, 0.0012, 0.0628,
        0.0651, 0.0928, 0.0273, 0.0105, 0.0168, 0.0023, 0.0166, 0.0009 };

char hex_dec (char hex_digit);

size_t buffer_read (char *input_buffer);

double evaluate_decryption (char *output_buffer, const size_t buffer_size);

void buffer_xor (char *output_buffer, const char *input_buffer,
                 const size_t buffer_size);

void find_key (char *output_buffer, const char *input_buffer,
               const size_t buffer_size);

int
main (void)
{
  char* input_buffer = (char*)calloc(BUFFER_MAXSIZE, sizeof(char));
  decrypt_buffer();
}

char
hex_dec (char hex_digit)
{
  char dec_number = 0;
  if (hex_digit >= '0' && hex_digit <= '9')
    {
      dec_number = hex_digit - '0';
    }
  else if (hex_digit >= 'a' && hex_digit <= 'f')
    {
      dec_number = hex_digit - 'a' + 10;
    }
  return dec_number;
}

size_t
buffer_read (char *input_buffer)
{
  size_t input_index = 0;
  size_t input_size = 0;
  while (getline (&input_buffer, NULL, stdin))
    {
      printf ("%s\n", input_buffer);
      ++input_index;
      //      input_buffer[input_index++] = strtol (hex_number, NULL, 16);
    }
  printf ("input_index: %d\n", input_index);
  return input_index;
}

double
evaluate_decryption (char *output_buffer, const size_t buffer_size)
{
  double score = 0.0;
  double frequencies[26]
      = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
  size_t frequency_index = 0;
  for (char letter = 'A'; letter <= 'Z'; ++letter)
    {
      frequency_index = letter - 'A';
      for (size_t index = 0; index < buffer_size; ++index)
        {
          if (letter == toupper (output_buffer[index]))
            {
              frequencies[frequency_index]++;
            }
        }
      frequencies[frequency_index] /= buffer_size;
      score += fabs (frequencies[frequency_index]
                     - english_frequencies[frequency_index]);
    }
  return score;
}

void
buffer_xor (char *output_buffer, const char *input_buffer,
            const size_t buffer_size)
{
  for (size_t index = 0; index < buffer_size; ++index)
    {
      output_buffer[index] = input_buffer[index] ^ output_buffer[index];
    }
}

void
find_key (char *output_buffer, const char *input_buffer,
          const size_t buffer_size)
{
  double minimum_score = 100.0;
  double current_score = 0.0;
  int decryption_key = 0;
  for (int key = 0; key <= UCHAR_MAX; ++key)
    {
      memset (output_buffer, key, buffer_size);
      buffer_xor (output_buffer, input_buffer, buffer_size);
      current_score = evaluate_decryption (output_buffer, buffer_size);
      if (current_score < minimum_score)
        {
          minimum_score = current_score;
          decryption_key = key;
        }
    }
  memset (output_buffer, decryption_key, buffer_size);
}
