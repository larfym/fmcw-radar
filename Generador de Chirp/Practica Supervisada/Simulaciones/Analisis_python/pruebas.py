import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import windows

# ===================== PARÁMETROS =====================
c = 3e8 * 0.99        # [m/s] velocidad efectiva
fc = 2e9              # [Hz]
T = 35e-6              # [s] duración del chirp
Fs = 50e6             # [Hz] frecuencia de muestreo
dt = 1 / Fs
t = np.arange(0, T, dt)

# Blanco (objetivo)
R = 14                # [m]
v = 0                 # [m/s]
tau = 2 * R / c       # [s]
fd = 2 * v * fc / c   # [Hz]
Bw = 25e6             # [Hz]
slope = Bw / T        # [Hz/s]

# ===================== CHIRP TX =====================
s_tx = np.exp(1j * 2*np.pi*(fc*t + (slope/2)*t**2))

# ===================== RX (eco retardado fraccional) =====================
tau_samples = tau / dt
n = np.arange(len(t))
# desplazamiento fraccional en frecuencia (implementa retardo continuo)
s_rx = np.exp(1j * 2*np.pi*(fc*(t - tau) + (slope/2)*(t - tau)**2))

# incluir Doppler (v ≠ 0 si querés probar)
s_rx *= np.exp(1j * 2*np.pi * fd * t)

# ===================== MEZCLA (beat signal) =====================
s_mix = s_tx * np.conj(s_rx)

# ===================== FFT =====================
w = windows.hann(len(s_mix))
Nfft = 2 ** int(np.ceil(np.log2(len(s_mix))))
B = np.fft.fft(s_mix * w, Nfft)
f = np.fft.fftfreq(Nfft, dt)
fpos = f[:Nfft // 2]
Bpos = np.abs(B[:Nfft // 2])

# ===================== FRECUENCIA DE BATIDO =====================
fb_exp = slope * tau + fd
dR = c / (2 * Bw)

# ===================== GRÁFICOS =====================
plt.figure("Señal de batido (dominio del tiempo)")
plt.plot(t * 1e6, np.real(s_mix))
plt.title("Señal mezclada (batido)")
plt.xlabel("Tiempo [µs]")
plt.ylabel("Amplitud")
plt.grid(True)

plt.figure("FFT de la señal de batido")
plt.plot(fpos / 1e3, Bpos / np.max(Bpos))
plt.axvline(fb_exp / 1e3, color='gray', linestyle='--',
             label=f"f_b esperada = {fb_exp/1e3:.2f} kHz")
             
plt.title("FFT de la señal de batido")
plt.xlabel("Frecuencia [kHz]")
plt.ylabel("|B| normalizado")
plt.xlim(0, 10 / 1)  # mostrar hasta 20 kHz
plt.legend()
plt.grid(True)
plt.show()

# ===================== SALIDA =====================
print(f"Distancia real: {R:.2f} m")
print(f"Retardo temporal: {tau*1e9:.2f} ns")
print(f"Frecuencia de batido esperada: {fb_exp/1e3:.2f} kHz")
print(f"Resolución teórica: dR = {dR:.3f} m")
