% --- Comparación: Chirp Lineal Ideal vs Rampa ADF4350 con Retardo ---
clc; clear; close all;

% --- Parámetros Generales ---
freq_start_MHz = 100;
freq_end_MHz   = 200;
num_steps      = 100;
pattern_time_us = [0, 20, 40, 60, 75, 90, 110];
pattern_freq_rel_MHz = [0, 40, 20, 10, 5, 0];
pattern_dur_us = pattern_time_us(end);
total_time_us = num_steps * pattern_dur_us; % 11 ms

% --- Parámetros del Retardo (Objetivo) ---
c = 3e8;         % velocidad de la luz
R = 150;         % distancia del objetivo [m]
tau = 2 * R / c; % retardo temporal [s]

%% --- 1) CHIRP LINEAL IDEAL ---
dt = 1e-8; % paso temporal
t_s = 0:dt:(total_time_us * 1e-6);
f_tx_ideal_MHz = freq_start_MHz + ...
    (freq_end_MHz - freq_start_MHz) * (t_s / (total_time_us * 1e-6));

% Retardo simulado
delay_samples = round(tau / dt);
f_rx_ideal_MHz = [zeros(1, delay_samples), f_tx_ideal_MHz(1:end-delay_samples)];

% --- Graficar Chirp Ideal ---
figure('Position', [100, 100, 1200, 500]);
plot(t_s*1e6, f_tx_ideal_MHz, 'b', 'LineWidth', 2, 'DisplayName', 'Chirp Ideal (Tx)');
hold on;
plot(t_s*1e6, f_rx_ideal_MHz, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Chirp Retardado (Rx)');
hold off;
title(sprintf('Chirp Lineal Ideal con Retardo (R = %.0f m, \\tau = %.2f ns)', R, tau*1e9));
xlabel('Tiempo [\\mus]');
ylabel('Frecuencia [MHz]');
legend('Location', 'northwest');
grid on;
axis([0 200 total_time_us/total_time_us*freq_start_MHz-10 freq_end_MHz+10]);

%% --- 2) RAMPA ADF4350 CON RETARDO ---
dt2 = 1e-7;
t2_s = 0:dt2:(total_time_us * 1e-6);
f_comb_MHz = zeros(size(t2_s));
current_time_us = 0;
freq_step = (freq_end_MHz - freq_start_MHz) / num_steps;

for i = 1:num_steps
    base_freq = freq_start_MHz + (i-1)*freq_step;
    for j = 1:(length(pattern_freq_rel_MHz)-1)
        t_start = current_time_us + pattern_time_us(j);
        t_end   = current_time_us + pattern_time_us(j+1);
        f_val = base_freq + pattern_freq_rel_MHz(j);
        idx = (t2_s*1e6 >= t_start) & (t2_s*1e6 < t_end);
        f_comb_MHz(idx) = f_val;
    end
    current_time_us = current_time_us + pattern_dur_us;
end

% Retardo
delay_samples2 = round(tau / dt2);
f_comb_delay_MHz = [zeros(1, delay_samples2), f_comb_MHz(1:end-delay_samples2)];

% --- Graficar Rampa ADF4350 ---
figure('Position', [100, 100, 1200, 500]);
stairs(t2_s*1e6, f_comb_MHz, 'b', 'LineWidth', 1.5, 'DisplayName', 'Rampa ADF4350 (Tx)');
hold on;
stairs(t2_s*1e6, f_comb_delay_MHz, 'r--', 'LineWidth', 1.2, 'DisplayName', 'Rampa Retardada (Rx)');
hold off;
title(sprintf('Rampa ADF4350 con Retardo (R = %.0f m, \\tau = %.2f ns)', R, tau*1e9));
xlabel('Tiempo [\\mus]');
ylabel('Frecuencia [MHz]');
legend('Location', 'northwest');
grid on;
axis([0 200 freq_start_MHz-10 freq_end_MHz+50]);
