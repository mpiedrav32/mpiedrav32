p = 29
residues = [14, 6, 11]

for x in residues:
    for a in range(p+1):
        if a**2 % p == x:
            print(a, x)
