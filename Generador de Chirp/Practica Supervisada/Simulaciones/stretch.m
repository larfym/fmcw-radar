clc; clear; close all;

% Parámetros radar
c = physconst('LightSpeed');   % Velocidad de la luz (m/s)
bandwidth = 300e6;              % Ancho de banda (Hz)
pulsewidth = 1e-3;             % Duración del pulso (s)
range_window_length = 50.0;    % Ventana de rango +/- (m)
target_range = 15.0;           % Rango del blanco (m)

% Retardo asociado al blanco
t0 = 2.0 * target_range / c;   % Tiempo de ida y vuelta (s)

% Número de muestras (ecuación típica de stretch)
number_of_samples = ceil(4 * bandwidth * range_window_length / c);

% Eje temporal centrado en 0
t = linspace(-0.5 * pulsewidth, 0.5 * pulsewidth, number_of_samples);
dt = t(2) - t(1);   % Paso temporal

% Señal después de la mezcla (batido)
so = exp(1j * 2.0 * pi * (bandwidth / pulsewidth) * t0 .* t);

% FFT de la señal (512 puntos, centrada)
Nfft = 512;
SO = fftshift(fft(so, Nfft));

% Eje de frecuencias y conversión a rango
frequencies = fftshift( (-Nfft/2:Nfft/2-1) / (Nfft*dt) );
range_window = 0.5 * frequencies * c * pulsewidth / bandwidth;

% Gráfico
figure;
plot(range_window, abs(SO)/max(abs(SO)), 'k', 'LineWidth', 1.5);
xlabel('Range (m)');
ylabel('Relative Amplitude');
title('Stretch Processor Output');
grid on;
