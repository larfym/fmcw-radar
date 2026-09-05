clc; clear; close all;

% ===== Parámetros base =====
f_ini = 0;          % Hz
f_fin = 100;      % Hz (300 MHz)
fs    = 1000;        % Hz, frecuencia de muestreo (1 GHz para resolución)
T     = 1;       % s, duración del chirp (1 ms)
N     = round(T*fs);
t     = (0:N-1)/fs;

% ===== Eco simulado =====
delay_time = 200e-9;                  % retardo [s] (ej. 200 ns)
delay_samples = round(delay_time*fs);
atten = 0.7;                          % atenuación

% ===== Chirp en 1200 pasos =====
n_steps = 1200;
dwell     = T / n_steps;
samples_s = round(dwell * fs);

% Construcción escalonada de frecuencia
B = f_fin - f_ini;
df = B / n_steps;
f_lvls = f_ini + (0:n_steps-1)*df;

f_inst = repelem(f_lvls, samples_s).';
if numel(f_inst) < N
    f_inst(end+1:N) = f_lvls(end);
elseif numel(f_inst) > N
    f_inst = f_inst(1:N);
end

% ===== Señal Tx =====
phi = 2*pi*cumsum(f_inst)/fs;
tx   = exp(1j*phi);   % señal compleja


figure('Name',sprintf('%d pasos',n_steps));

% (1) Frecuencia instantánea
subplot(2,1,1);
stairs(t, f_inst, 'LineWidth', 1.3); grid on;
xlabel('Tiempo [s]'); ylabel('f_{inst} [Hz]');
title(sprintf('%d pasos: frecuencia instantánea', n_steps));
xlim([0 T]);

% (2) Tx (parte real)
subplot(2,1,2);
plot(t, real(tx)); grid on;
xlabel('Tiempo [s]'); ylabel('Amplitud');
title(sprintf('%d pasos: Tx (real)', n_steps));
xlim([0 T]);