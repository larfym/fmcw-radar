import numpy as np
import matplotlib.pyplot as plt

# Parámetros
c = 3e8*0.66
fc = 2e9
T = 1e-3
Fs = 8e6 # Reducir Fs para manejar el cálculo, 8e9 es innecesario para un chirp de 1ms
dt = 1/Fs
Bw = 25e6 
slope = Bw/T

R = 10 
tau = 2*R/c 

# Cálculo Teórico de la Frecuencia de Batido (f_b)
f_b_teorica = slope * tau
print(f"Frecuencia de Batido Teórica (f_b): {f_b_teorica / 1e6:.2f} MHz")

# 1. Definición del vector de tiempo original
t = np.arange(0, T, dt)

# 2. Señal transmitida (analítica)
y = np.exp(1j * 2*np.pi*(fc*t + (Bw/(2*T))*t**2))

# 3. Señal de batido (CORRECCIÓN CLAVE)
# En lugar de desplazar el tiempo (t-tau), restamos la fase de la señal recibida.
# La señal recibida en el tiempo 't' es la señal transmitida en el tiempo 't-tau'.
# La fase de la señal recibida es: phi_rx(t) = 2*pi * (fc*(t-tau) + (Bw/(2*T))*(t-tau)**2)

# y_b = y(t) * y_rx(t)^*
# y_b = exp(j*phi_tx(t)) * exp(-j*phi_rx(t)) = exp(j*(phi_tx(t) - phi_rx(t)))
# La diferencia de fase (phi_tx - phi_rx) simplifica a:
# Delta_phi = 2*pi * (fc*tau + (Bw/T)*tau*t - (Bw/(2*T))*tau**2)

# La parte de la frecuencia de batido constante es: f_b = (Bw/T) * tau
y_b = np.exp(1j * 2*np.pi * (fc*tau + slope*tau*t - (slope*tau**2)/2))

# FFT
N = len(y_b)
sp = np.fft.fftshift(np.fft.fft(y_b))
freq = np.fft.fftshift(np.fft.fftfreq(N, 1/Fs))
mask = freq >= 0

# Gráficos
figure, axis = plt.subplots(2, 1, figsize=(8, 6))

# Gráfico 1: Parte real de la señal de batido
axis[0].plot(t*1e3, np.real(y_b))
axis[0].set_title(f"Señal de Batido (f_b = {f_b_teorica/1e6:.2f} MHz)")
axis[0].set_xlabel("Tiempo (ms)")
axis[0].set_ylabel("Amplitud")

# Gráfico 2: Espectro de la señal de batido
axis[1].plot(freq[mask]/1e6, np.abs(sp[mask]))
axis[1].set_xlim(0, 10)
axis[1].set_title("Espectro de la señal de batido (FFT) [MHz]")
axis[1].set_xlabel("Frecuencia (MHz)")
axis[1].set_ylabel("Magnitud |FFT|")

plt.tight_layout()
plt.show()