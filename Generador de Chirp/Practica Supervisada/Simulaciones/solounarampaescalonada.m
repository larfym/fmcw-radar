%% Rampa Escalonada Única (25 Pasos) y Simulación de Matched Filter
clc; clear; close all;

% --- Parámetros base ---
f_ini = 0;      % [Hz] Frecuencia inicial
f_fin = 100;    % [Hz] Frecuencia final
fs    = 1000;   % [Hz] Frecuencia de muestreo
T     = 1;      % [s] Duración total del chirp
N     = T*fs;   % Número total de muestras
t     = (0:N-1)/fs;

% --- Eco simulado ---
delay_time = 0.2;         % [s] Retardo del eco (distancia)
delay_samples = round(delay_time*fs);
atten = 0.7;              % Atenuación de la señal recibida

% --- Parámetros de la Rampa (CASO ÚNICO) ---
n_steps = 25;             % Número de escalones (pasos)
dwell   = T / n_steps;    % Tiempo que dura cada escalón
samples_s = round(dwell * fs); % Muestras por escalón

% --- Construcción escalonada de frecuencia (f_inst) ---
B = f_fin - f_ini;
df = B / n_steps;
f_lvls = f_ini + (0:n_steps-1)*df;

% Usar repelem para construir la rampa escalonada
f_inst = repelem(f_lvls, samples_s).';

% Ajustar la longitud al número total de muestras N
if numel(f_inst) < N
    f_inst(end+1:N) = f_lvls(end);
elseif numel(f_inst) > N
    f_inst = f_inst(1:N);
end

% ===== 1. Señal Tx (Generación del Chirp) =====
% La fase es la integral de la frecuencia instantánea
phi = 2*pi*cumsum(f_inst)/fs;
tx  = exp(1j*phi);    % Usamos señal compleja para mantener la fase

% ===== 2. Señal Rx (Retardada y Atenuada) =====
rx = zeros(1, N + delay_samples);
rx(delay_samples+1:delay_samples+N) = atten * tx;
t_rx = (0:length(rx)-1)/fs;

% ===== 3. Matched Filter (Compresión de Pulso) =====
% El filtro adaptado es la versión conjugada e invertida en el tiempo de la señal TX
h = conj(flip(tx));
y = conv(rx, h, 'same'); % Convolución para obtener la salida del filtro

% =========================================================
% ===== GRÁFICOS: Cadena de Procesamiento para 25 Pasos =====
% =========================================================

figure('Name','Rampa Escalonada: 25 Pasos');

% (1) Frecuencia instantánea (El Chirp Escalónado)
subplot(4,1,1);
stairs(t, f_inst, 'LineWidth', 1.5, 'Color', [0 0.5 0]); grid on;
xlabel('Tiempo [s]'); ylabel('f_{inst} [Hz]');
title(sprintf('1. Frecuencia Instantánea (Rampa Escalónada de %d Pasos)', n_steps));
xlim([0 T]);

% (2) Tx (parte real)
subplot(4,1,2);
plot(t, real(tx), 'b'); grid on;
xlabel('Tiempo [s]'); ylabel('Amplitud');
title('2. Señal TX generada (Parte real)');
xlim([0 T]);

% (3) Rx (retardada)
subplot(4,1,3);
plot(t_rx, real(rx), 'r'); grid on;
xlabel('Tiempo [s]'); ylabel('Amplitud');
title(sprintf('3. Señal RX: Eco retardado (%.1f s de retardo)', delay_time));
xlim([0 T+delay_time]);

% (4) Salida matched filter (Detección del objetivo)
subplot(4,1,4);
plot(t_rx, abs(y), 'k', 'LineWidth', 1.5); grid on;
xlabel('Tiempo [s]'); ylabel('Amplitud');
title('4. Salida del Matched Filter (Pico de Detección)');
xlim([0 T+delay_time]);