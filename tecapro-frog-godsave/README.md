# FROG and GodSave

FROG and GodSave are encryption algorithms from the late 1990s, developed by Costa Rican software company TecApro International.

Source code obtained from:
- https://sources.ru/pascal/crypt/frog.zip
- https://sources.ru/pascal/crypt/godsave.zip

This is an independent effort in software conservation and the academic study of cryptography.

## FROG

Authors: Dianelos Georgoudis, Damian Leroux, and Billy Simón Chaves

FROG was submitted to the Advanced Encryption Standard process, initiated by NIST.

David Wagner, Niels Ferguson, and Bruce Schneier published a [cryptanalysis of FROG](https://www.schneier.com/wp-content/uploads/2016/02/paper-frog.pdf).

From https://sources.ru/pascal/crypt/frog.htm

> FROG is a new cipher with an unorthodox structure. Any symmetrical cipher's job is to conceal the plaintext's information through a computational process of confusion and diffusion. The basic idea behind the design of FROG is to conceal the definition of most of this process in a secret internal key. The actual encryption algorithm operates as an interpreter that regards the secret internal key as a program and executes it as if it were a series of primitive instructions.

## GodSave

Author: Dianelos Georgoudis

GodSave was mentioned in the context of the [Second AES Conference](https://cryptome.org/jya/aes2-day2.htm).

From https://sources.ru/pascal/crypt/godsave.htm

> The GodSave encryption algorithm does not employ a single encryption function, but rather it employs a very large family of different encryption functions and it chooses one of them every time it encrypts a new block of plaintext. The choice of which encryption function is applied depends both on the key and on the plaintext.
