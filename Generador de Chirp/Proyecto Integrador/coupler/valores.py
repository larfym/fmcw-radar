s11a = -0.021 -1j*0.067
s21a = -0.726 -1j*0.666
s11b = 0.119 -1j*0.059
s21a = 0.138 -1j*0.974
Stotal = (s21a*s11a*s11b)/(1-s11a*s11b)+s11a
print(Stotal)
