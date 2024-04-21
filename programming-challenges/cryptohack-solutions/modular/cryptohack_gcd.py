import sys


def gcd_recursive(a, b):
    if b == 0:
        return a
    else:
        return gcd(b, a % b)


def gcd_original(a, b):
    while a != b:
        if a > b:
            a = a - b
        else:
            b = b - a
    return a


if __name__ == "__main__":
    print(gcd_original(int(sys.argv[1]), int(sys.argv[2])))
