import sys

def gcd_extended(a, b):
    r1, r2 = a, b
    s1, s2 = 1, 0
    t1, t2 = 0, 1

    while r2 != 0:
        q = r1 // r2
        r1, r2 = r2, r1 - q * r2
        s1, s2 = s2, s1 - q * s2
        t1, t2 = t2, t1 - q * t2

    print(f"Coefficients: {s1}, {t1}")
    print(f"GCD: {r1}")
    print(f"Quotients: {t2}, {s2}")


if __name__ == "__main__":
    gcd_extended(int(sys.argv[1]), int(sys.argv[2]))
