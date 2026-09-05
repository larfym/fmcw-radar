clc; clear; close all;

% Parámetros base
f_ini = 0;          % Hz
f_fin = 300;     % Hz
fs    = f_fin*10;   % Hz
T     = 1;          % s
N     = T*fs;
t     = (0:N-1)/fs;

% Eco simulado
delay_time = 0.2;                  % retardo [s]
delay_samples = round(delay_time*fs);
atten = 0.7;                        % atenuación

% ===== Caso único: 100 pasos =====
n_steps = 100;                     % número de pasos de la rampa
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
tx   = exp(1j*phi);   % usamos complejo

% ===== Señal Rx (retardada y atenuada) =====
rx = zeros(1, N + delay_samples);
rx(delay_samples+1:delay_samples+N) = atten * tx; 
t_rx = (0:length(rx)-1)/fs;

% ===== Matched Filter =====
h = conj(flip(tx));
y = conv(rx, h, 'same');

% ===== Graficar =====

% (1) Frecuencia instantánea
figure('Name','100 pasos');
subplot(4,1,1);
stairs(t, f_inst, 'LineWidth', 1.3); grid on;
xlabel('Tiempo [s]'); ylabel('f_{inst} [Hz]');
title('100 pasos: frecuencia instantánea');
xlim([0 T]);

% (2) Tx (parte real)
subplot(4,1,2);
plot(t, real(tx)); grid on;
xlabel('Tiempo [s]'); ylabel('Amplitud');
title('100 pasos: Tx (real)');
xlim([0 T]);

% (3) Rx
subplot(4,1,3);
plot(t_rx, real(rx)); grid on;
xlabel('Tiempo [s]'); ylabel('Amplitud');
title('100 pasos: Rx (retardado)');
xlim([0 T+delay_time]);

% (4) Salida matched filter
subplot(4,1,4);
plot(t_rx, abs(y)); grid on;
xlabel('Tiempo [s]'); ylabel('Amplitud');
title('100 pasos: salida del matched filter');
xlim([0 T+delay_time]);
