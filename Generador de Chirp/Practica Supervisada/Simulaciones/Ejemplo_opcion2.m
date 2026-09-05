clc; clear; close all;

% Parámetros del chirp
fs = 200;          % Frecuencia de muestreo [Hz]
T  = 1;            % Duración del chirp [s]
B  = 100;          % Ancho de banda [Hz]
N  = round(T*fs);  % Número de muestras
t  = (0:N-1)/fs;   % Vector de tiempo

K = B/T;           % Pendiente de FM

% Replica ponderada con ventana Kaiser (beta=2.5)
beta = 2.5;
w_kaiser = kaiser(N, beta).';          % ventana Kaiser
h_prime = w_kaiser .* exp(1j*pi*K*t.^2);  % réplica ponderada

% Opción 2: matched filter en frecuencia
Nfft = 2048;                             % longitud FFT
H2 = conj(fft(h_prime, Nfft));           % Filtro adaptado en frecuencia

% Graficar resultados
f = (-Nfft/2:Nfft/2-1)*(fs/Nfft);        % eje de frecuencias

figure;
subplot(2,1,1);
plot(f, 20*log10(abs(fftshift(H2))/max(abs(H2))));
xlabel('Frecuencia [Hz]'); ylabel('Magnitud [dB]');
title('Respuesta en frecuencia del filtro adaptado (Kaiser, \beta=2.5)');
grid on; ylim([-80 5]);

subplot(2,1,2);
plot(f, unwrap(angle(fftshift(H2))));
xlabel('Frecuencia [Hz]'); ylabel('Fase [rad]');
title('Fase del filtro adaptado');
grid on;
