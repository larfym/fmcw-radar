clc; clear; close all;

% Parámetros del chirp
fs = 1000;         % frecuencia de muestreo [Hz]
T  = 1;            % duración del pulso [s]
B  = 100;          % ancho de banda [Hz]
N  = round(T*fs);  % muestras
t  = (0:N-1)/fs;   % vector de tiempo

% Pendiente de la FM
K = B / T;
resolucion = 0.886/(K*T);
% Señal transmitida (chirp lineal en banda base)
tx = exp(1j*pi*K*t.^2);  % chirp complejo

% --- Señal recibida (sin ruido) ---
rx_clean = tx;

% --- Matched filter: conjugado invertido en tiempo ---
h = conj(flip(tx));

% Salida del matched filter (convolución)
y_clean = conv(rx_clean, h, 'same');

% --- Señal recibida con ruido ---
SNR_dB = 2.5;                 % SNR deseada [dB]
rx_power = mean(abs(rx_clean).^2);
noise_power = rx_power / (10^(SNR_dB/10));
noise = sqrt(noise_power/2) * (randn(size(rx_clean)) + 1j*randn(size(rx_clean)));
rx_noisy = rx_clean + noise;

% Salida del matched filter con ruido
y_noisy = conv(rx_noisy, h, 'same');

% ===================== Graficar =====================
figure;

subplot(2,2,1);
plot(t, real(rx_clean));
xlabel('Tiempo [s]'); ylabel('Amplitud');
title('(a) Parte real de la señal original');
grid on;

subplot(2,2,2);
plot(t, abs(y_clean));
xlabel('Tiempo [s]'); ylabel('Amplitud');
title('(b) Señal comprimida (sin ruido)');
grid on;

subplot(2,2,3);
plot(t, 20*log10(abs(y_clean)/max(abs(y_clean))));
xlabel('Tiempo [s]'); ylabel('Magnitud [dB]');
title('(c) Señal comprimida (magnitud en dB)');
grid on; ylim([-50 5]);

subplot(2,2,4);
plot(t, unwrap(angle(y_clean)));
xlabel('Tiempo [s]'); ylabel('Fase [rad]');
title('(d) Fase de la señal comprimida');
grid on;

sgtitle('Matched filtering de un chirp FM lineal (sin ruido)');

% ===================== Con ruido =====================
figure;

subplot(2,2,1);
plot(t, real(rx_noisy));
xlabel('Tiempo [s]'); ylabel('Amplitud');
title('(a) Señal recibida con ruido');
grid on;

subplot(2,2,2);
plot(t, abs(y_noisy));
xlabel('Tiempo [s]'); ylabel('Amplitud');
title('(b) Señal comprimida con ruido');
grid on;

subplot(2,2,3);
plot(t, 20*log10(abs(y_noisy)/max(abs(y_noisy))));
xlabel('Tiempo [s]'); ylabel('Magnitud [dB]');
title('(c) Señal comprimida (magnitud en dB) con ruido');
grid on; ylim([-50 5]);

subplot(2,2,4);
plot(t, unwrap(angle(y_noisy)));
xlabel('Tiempo [s]'); ylabel('Fase [rad]');
title('(d) Fase de la señal comprimida con ruido');
grid on;

sgtitle('Matched filtering de un chirp FM lineal (con ruido, SNR ≈ 2.5 dB)');
