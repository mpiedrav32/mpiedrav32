# https://projecteuler.net/problem=2

import sys


def fib(n):
    a, b = 1, 2
    while a <= n:
        a, b = b, a+b
    return a


if __name__ == "__main__":
    print(sum([fib(x) for x in range(int(sys.argv[1])) if x % 2 == 0]))
