clc; clear; close all;

% Parámetros del chirp
fs = 1000;         % Frecuencia de muestreo [Hz]
T  = 1;            % Duración del chirp [s]
B  = 100;          % Ancho de banda [Hz]
f0 = 0;            % Frecuencia inicial
N  = T*fs;         % Número de muestras
t  = (0:N-1)/fs;   % Eje temporal

% Señal transmitida: chirp lineal en banda base
tx = chirp(t, f0, T, B, 'linear');

% Simulamos un eco con retardo t0
t0 = 0.2;                     % retardo [s]
delay_samples = round(t0*fs); % retardo en muestras
rx = [zeros(1,delay_samples), tx(1:end-delay_samples)];

% Filtro adaptado = conjugado complejo invertido en el tiempo
h = conj(fliplr(tx));

% Salida del filtro adaptado (convolución)
y = conv(rx, h, 'same');

% --- Graficar ---
figure;

subplot(3,1,1);
plot(t, tx);
xlabel('Tiempo [s]'); ylabel('Amplitud');
title('Pulso transmitido (chirp)'); grid on;

subplot(3,1,2);
plot(t, rx);
xlabel('Tiempo [s]'); ylabel('Amplitud');
title(sprintf('Señal recibida (eco con retardo = %.2f s)',t0));
grid on;

subplot(3,1,3);
plot(t, abs(y));
xlabel('Tiempo [s]'); ylabel('|y(t)|');
title('Salida del filtro adaptado (pulso comprimido)');
grid on;
