% --- Análisis de Tx: Chirp Continuo (Infinitos Escalones) ---
clear; clc;

% Parámetros base
f_ini = 1000;      % Hz
f_fin = 100000;    % Hz
fs    = 1000;   % Hz
T     = 1;      % s
N     = T*fs;
t     = (0:N-1)'/fs;

% 1. Frecuencia instantánea (Barrido lineal)
B = f_fin - f_ini;
f_inst = f_ini + (B/T) * t;

% 2. Señal Tx (Fase continua)
phi = 2*pi * (f_ini*t + (B/(2*T)) * t.^2);
tx  = cos(phi);

% 3. Espectro en frecuencia (FFT)
Nfft = 2048;
TX_FFT = fft(tx, Nfft);
f_axis = (0:Nfft-1)*(fs/Nfft);

% Tomamos solo las frecuencias positivas para el gráfico
f_axis_pos = f_axis(1:Nfft/2);
TX_FFT_pos = TX_FFT(1:Nfft/2);

% ===== Figura: 3 Subplots Apilados =====
figure('Name', 'Chirp Continuo: Análisis de Tx', 'Position', [150, 50, 1000, 900]);

% Gráfico 1: Frecuencia instantánea
subplot(3, 1, 1);
plot(t, f_inst, 'LineWidth', 1.5); grid on;
xlabel('Tiempo [s]'); ylabel('f_{inst} [Hz]');
title('Frecuencia instantánea');
xlim([0 T]);
ylim([0 f_fin+10]);

% Gráfico 2: Respuesta en el tiempo (Tx real)
subplot(3, 1, 2);
plot(t, tx, 'LineWidth', 1); grid on;
xlabel('Tiempo [s]'); ylabel('Amplitud');
title('Tx (real)');
xlim([0 T]);
ylim([-1.1 1.1]);

% Gráfico 3: Espectro en frecuencia
subplot(3, 1, 3);
plot(f_axis_pos, abs(TX_FFT_pos)/Nfft, 'r', 'LineWidth', 1.5); grid on;
xlabel('Frecuencia [Hz]'); ylabel('|X(f)|');
title('Espectro en frecuencia');
xlim([0 f_fin+20]);