% Andrés Agustín Cesana - simulación chirp radar
clc; close all; clear;

% --- Parámetros ---
f1 = 2e9;        % Frecuencia inicial
f2 = 2.3e9;      % Frecuencia final
fs = 100000;     % Frecuencia de muestreo
tiempo = 1e-3;    % duración del chirp
t = 0:1/fs:tiempo;  % Base de tiempo
B = f2 - f1;        % Ancho de banda
K = B/tiempo;       % Pendiente Hz/s
c = 0.66*3e8;            % velocidad de la luz

% --- Señal transmitida (Tx) ---
tx = chirp(t,f1,tiempo,f2);

% --- Simular rebote (Rx) ---
delay_time = 0.005;                  % retardo del eco [s]
delay_samples = round(delay_time*fs);  
atten = 0.6;                        % atenuación del eco
rx = zeros(size(tx));
rx(delay_samples+1:end) = atten * tx(1:end-delay_samples);

% --- Señal beat (mezcla Tx * Rx) ---
beat = tx .* rx;

% --- FFT del beat ---
N = length(beat);
BEAT_FFT = fft(beat, N);
BEAT_FFT = fftshift(BEAT_FFT);
f = (-N/2:N/2-1)*(fs/N);

% Extraer solo espectro positivo
mid = floor(N/2); 
f_pos = f(mid+1:end);
BEAT_pos = abs(BEAT_FFT(mid+1:end))/N;

% Buscar pico
[~, idx] = max(BEAT_pos);
fb = f_pos(idx);   % frecuencia del beat

% --- Calcular distancia ---
tau_est = fb / K;        % retardo estimado
R_est = c * tau_est / 2; % distancia en metros

% --- Mostrar resultados ---
fprintf('Frecuencia de beat estimada: %.2f Hz\n', fb);
fprintf('Retardo estimado: %.6f s\n', tau_est);
fprintf('Distancia estimada: %.2f m\n', R_est);

% --- Graficar ---
figure;

subplot(3,1,1);
plot(t, tx, 'b'); grid on;
title('Tx - Chirp transmitido');
xlabel('Tiempo [s]'); ylabel('Amplitud');
xlim([0 tiempo]);

subplot(3,1,2);
plot(t, rx, 'r'); grid on;
title('Rx - Chirp recibido (eco)');
xlabel('Tiempo [s]'); ylabel('Amplitud');
xlim([0 tiempo]);


subplot(3,1,3);
plot(f_pos, BEAT_pos, 'k'); grid on;
title('FFT de la señal beat (Tx .* Rx)');
xlabel('Frecuencia [Hz]'); ylabel('|X(f)|');
xlim([0 100]);
