clc; clear; close all;

% Parámetros del chirp
fs = 2000;        % frecuencia de muestreo [Hz]
T  = 1;           % duración del pulso [s]
B  = 200;         % ancho de banda [Hz]
N  = round(T*fs); % muestras
t  = (0:N-1)/fs;  % vector de tiempo

K = B/T;          % pendiente

% Chirp baseband (transmitido)
tx = exp(1j*pi*K*t.^2);

% Señal recibida (sin ruido)
rx = tx;

%% Filtro adaptado en el dominio temporal (rectangular window)
h_rect = conj(flip(tx));
y_rect = conv(rx, h_rect, 'same');

%% Filtro adaptado con ventana Kaiser
beta = 2.5;                            % parámetro de Kaiser
w_kaiser = kaiser(N, beta).';          % ventana de Kaiser
h_kaiser = conj(flip(tx)) .* w_kaiser; % filtro adaptado con ventana
y_kaiser = conv(rx, h_kaiser, 'same');

%% Normalizar salidas para comparar
y_rect = y_rect / max(abs(y_rect));
y_kaiser = y_kaiser / max(abs(y_kaiser));

%% Graficar
figure;

subplot(2,1,1);
plot(t, 20*log10(abs(y_rect)), 'b', 'LineWidth',1.5); hold on;
plot(t, 20*log10(abs(y_kaiser)), 'r--', 'LineWidth',1.5);
xlabel('Tiempo [s]'); ylabel('Magnitud [dB]');
title('Pulso comprimido con filtro adaptado');
legend('Rectangular','Kaiser (\beta=2.5)');
grid on; ylim([-60 5]);

subplot(2,1,2);
plot(t, abs(y_rect), 'b', 'LineWidth',1.5); hold on;
plot(t, abs(y_kaiser), 'r--', 'LineWidth',1.5);
xlabel('Tiempo [s]'); ylabel('Amplitud');
title('Forma temporal (zoom alrededor del pico)');
xlim([0.45 0.55]); % zoom para ver el pico en el centro
grid on;

sgtitle('Efecto de la ventana Kaiser en el filtro adaptado');
