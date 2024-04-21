// Cryptopals 02: Fixed XOR
// 2024 Marco Piedra Venegas

#define _DEFAULT_SOURCE
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

const size_t input_maxsize = 4096;

const size_t output_maxsize = 4096;

char hex_dec (char hex_digit);

size_t buffer_read (char *input_buffer);

void buffer_xor (char *output_buffer, const char *input_buffer,
                 const size_t input_size);

void buffer_print_hex (const char *output_buffer, const size_t output_size);

int
main (void)
{
  char *input_buffer = (char *)calloc (input_maxsize, sizeof (char));
  if (input_buffer)
    {
      char *output_buffer = (char *)calloc (output_maxsize, sizeof (char));
      if (output_buffer)
        {
          size_t input_size = buffer_read (input_buffer);
          size_t output_size = buffer_read (output_buffer);
          buffer_xor (output_buffer, input_buffer, input_size);
          buffer_print_hex (output_buffer, output_size);
          free (output_buffer);
        }
      free (input_buffer);
    }
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
  int c = 0;
  int d = 0;
  while ((c = getchar ()) && isxdigit (c) && (d = getchar ()) && isxdigit (d)
         && input_index < input_maxsize)
    {
      c = hex_dec (c);
      d = hex_dec (d);
      input_buffer[input_index++] = (c << 4) | d;
    }
  return input_index;
}

void
buffer_xor (char *output_buffer, const char *input_buffer,
            const size_t input_size)
{
  for (size_t index = 0; index < input_size; ++index)
    {
      output_buffer[index] = input_buffer[index] ^ output_buffer[index];
    }
}

void
buffer_print_hex (const char *output_buffer, const size_t output_size)
{
  for (size_t index = 0; index < output_size; ++index)
    {
      printf ("%x", output_buffer[index]);
    }
  printf ("\n");
}
