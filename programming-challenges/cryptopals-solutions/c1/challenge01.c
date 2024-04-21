// Cryptopals 01: Convert hex to base64
// 2024 Marco Piedra Venegas

#define _DEFAULT_SOURCE
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

const char base64_alphabet[]
    = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

const char base64_padding = '=';

const size_t input_blocksize = 3;

const size_t output_blocksize = 4;

const size_t input_maxsize = 4096;

const size_t output_maxsize = 8192;

char hex_dec (char hex_digit);

size_t buffer_read (char *input_buffer);

size_t base64_encode (char *output_buffer, const char *input_buffer,
                      const size_t input_size);

void buffer_print (const char *output_buffer, const size_t output_size);

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
          size_t output_size
              = base64_encode (output_buffer, input_buffer, input_size);
          buffer_print (output_buffer, output_size);
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
  size_t buffer_index = 0;
  int c = 0;
  int d = 0;
  while ((c = getchar ()) && isxdigit (c) && (d = getchar ()) && isxdigit (d)
         && buffer_index < input_maxsize)
    {
      c = hex_dec (c);
      d = hex_dec (d);
      input_buffer[buffer_index] = (c << 4) | d;
      buffer_index++;
    }
  return buffer_index;
}

// in:   |23|22|21|20|19|18|17|16|
//       |15|14|13|12|11|10|09|08|
//       |07|06|05|04|03|02|01|00|
//
// out:        |23|22|21|20|19|18|
//             |17|16|15|14|13|12|
//             |11|10|09|08|07|06|
//             |05|04|03|02|01|00|

size_t
base64_encode (char *output_buffer, const char *input_buffer,
               const size_t input_size)
{
  size_t output_size = 0;
  if (input_size > 0)
    {
      size_t remainder = input_size % input_blocksize;
      size_t input_index = 0;
      size_t output_index = 0;
      char base64_value = 0;
      while (input_index < input_size - remainder
             && output_index < output_maxsize)
        {
          base64_value = input_buffer[input_index] >> 2;
          output_buffer[output_index] = base64_alphabet[base64_value];
          base64_value = ((input_buffer[input_index] & 0x3) << 4)
                         | (input_buffer[input_index + 1] >> 4);
          output_buffer[output_index + 1] = base64_alphabet[base64_value];
          base64_value = ((input_buffer[input_index + 1] & 0xf) << 2)
                         | (input_buffer[input_index + 2] >> 6);
          output_buffer[output_index + 2] = base64_alphabet[base64_value];
          base64_value = input_buffer[input_index + 2] & 0x3f;
          output_buffer[output_index + 3] = base64_alphabet[base64_value];
          input_index += input_blocksize;
          output_index += output_blocksize;
        }
      // Padding
      if (remainder == 1)
        {
          base64_value = input_buffer[input_index] >> 2;
          output_buffer[output_index] = base64_alphabet[base64_value];
          base64_value = (input_buffer[input_index] & 0x3) << 4;
          output_buffer[output_index + 1] = base64_alphabet[base64_value];
          output_buffer[output_index + 2] = base64_padding;
          output_buffer[output_index + 3] = base64_padding;
          output_index += output_blocksize;
        }
      else if (remainder == 2)
        {
          base64_value = input_buffer[input_index] >> 2;
          output_buffer[output_index] = base64_alphabet[base64_value];
          base64_value = ((input_buffer[input_index] & 0x3) << 4)
                         | (input_buffer[input_index + 1] >> 4);
          output_buffer[output_index + 1] = base64_alphabet[base64_value];
          base64_value = (input_buffer[input_index + 1] & 0xf) << 2;
          output_buffer[output_index + 2] = base64_alphabet[base64_value];
          output_buffer[output_index + 3] = base64_padding;
          output_index += output_blocksize;
        }
      output_size = output_index;
    }
  return output_size;
}

void
buffer_print (const char *output_buffer, const size_t output_size)
{
  for (size_t index = 0; index < output_size; ++index)
    {
      putchar (output_buffer[index]);
    }
  putchar ('\n');
}
