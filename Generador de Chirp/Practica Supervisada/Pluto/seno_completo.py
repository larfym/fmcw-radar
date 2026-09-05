import numpy as np
import matplotlib.pyplot as plt

fs = 0.5e9
Ts = 1/fs
tf = 1
nt = int(tf/Ts)
frec = 0.5e9
t = np.linspace(0, tf, nt) #crea el vector de tiempo
signal = np.sin(2*np.pi*frec*t) 
plt.figure(figsize=(8, 4))
plt.plot(t, signal, label=f'{1}·sin(2π·{frec} t)')
plt.xlabel('Tiempo (s)')
plt.ylabel('Amplitud')
plt.title('Seno en función del tiempo')
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.show()