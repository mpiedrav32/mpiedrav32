# https://projecteuler.net/problem=1

import sys

if __name__ == "__main__":
    print(sum([x for x in range(int(sys.argv[1])) if x % 3 == 0 or x % 5 == 0]))
