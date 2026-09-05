%% Rampa FMCW: Comparación entre rampa ideal y rampa no lineal (ZX95-2536C+)
clc; clear; close all;

% --- 0. PARÁMETROS FÍSICOS ---
R = 10;                   % [m]
c = physconst('LightSpeed'); % [m/s]
tau = 2 * R / c;          % [s] retardo del eco (~66.7 ns)

% --- 1. PARÁMETROS DE RAMPA ---
T  = 1e-3;                % [s]
Fs = 4e9;                 % [Hz]
V_start = 0.5; V_end = 4.5;
f_start = 2315e6; f_end = 2560e6;
BW = f_end - f_start;
Slope = BW / T;

dt = 1/Fs;
t  = 0:dt:T-dt;
t_len = numel(t);

% --- 2. CURVA DE SINTONÍA (NO LINEALIDAD DEL VCO) ---
V_data = [0.5, 1.5, 2.5, 3.5, 4.5];
F_data = [2315, 2390, 2455, 2510, 2560]*1e6;
P = polyfit(V_data, F_data, 3);
f_vco = @(V) polyval(P, V);

% --- 3. RAMPA TX/RX NO LINEAL ---
V_tune_lin = linspace(V_start, V_end, t_len);
f_tx_nl = f_vco(V_tune_lin);                     % frecuencia TX no lineal
f_rx_nl = interp1(t, f_tx_nl, t - tau, 'linear', f_tx_nl(1));  % RX retardada

% --- 4. RAMPA TX/RX IDEAL LINEAL ---
f_tx_lin = f_start + Slope * t;                 % TX ideal
f_rx_lin = interp1(t, f_tx_lin, t - tau, 'linear', f_tx_lin(1));  % RX ideal retardada

% --- 5. SEÑALES TX Y RX ---
phase_tx_nl = 2*pi*cumtrapz(t, f_tx_nl);
phase_rx_nl = 2*pi*cumtrapz(t, f_rx_nl);
wave_tx_nl = cos(phase_tx_nl);
wave_rx_nl = 0.8 * cos(phase_rx_nl);

phase_tx_lin = 2*pi*cumtrapz(t, f_tx_lin);
phase_rx_lin = 2*pi*cumtrapz(t, f_rx_lin);
wave_tx_lin = cos(phase_tx_lin);
wave_rx_lin = 0.8 * cos(phase_rx_lin);

% --- 6. MEZCLADOR Y FFT DEL BEAT ---
signal_if_nl = wave_tx_nl .* wave_rx_nl;  % beat no lineal
signal_if_lin = wave_tx_lin .* wave_rx_lin; % beat lineal

N_fft = 2^nextpow2(length(signal_if_lin));
FFT_nl = abs(fft(signal_if_nl, N_fft));
FFT_lin = abs(fft(signal_if_lin, N_fft));

FFT_nl = FFT_nl(1:N_fft/2);
FFT_lin = FFT_lin(1:N_fft/2);
Freq_axis = (0:N_fft/2-1)*(Fs/N_fft);    % [Hz]

% --- 7. FRECUENCIAS DE BATIDO (fb) ---
[~, loc_lin] = max(FFT_lin);
[~, loc_nl]  = max(FFT_nl);

fb_lin = Freq_axis(loc_lin);   % frecuencia de batido (lineal)
fb_nl  = Freq_axis(loc_nl);    % frecuencia de batido (no lineal)
fb_exp = Slope * tau;          % esperada (ideal)
% --- 8. DISTANCIAS ESTIMADAS ---
R_est_lin = c * fb_lin / (2 * Slope);   % rango estimado (ideal)
R_est_nl  = c * fb_nl  / (2 * Slope);   % rango estimado (no lineal)

% --- 9. GRÁFICO 1: COMPARACIÓN DE RAMPAS ---
figure('Color','w','Position',[100 100 700 400]);
plot(t*1e3, f_tx_lin/1e6, 'r', 'LineWidth', 1.4, 'DisplayName','Rampa ideal lineal');
hold on;
plot(t*1e3, f_tx_nl/1e6, 'b', 'LineWidth', 1.4, 'DisplayName','Rampa real (no lineal)');
xlabel('Tiempo [ms]');
ylabel('Frecuencia [MHz]');
title('Comparación de Rampas TX: Ideal vs ZX95-2536C+ (No lineal)');
legend('Location','northwest');
grid on;

% --- 10. GRÁFICO 2: ESPECTROS DE BEAT COMPARADOS ---
figure('Color','w','Position',[850 100 700 400]);
plot(Freq_axis/1e3, FFT_lin/max(FFT_lin), 'r', 'LineWidth', 1.4, 'DisplayName','Rampa ideal lineal');
hold on;
plot(Freq_axis/1e3, FFT_nl/max(FFT_nl), 'b', 'LineWidth', 1.4, 'DisplayName','Rampa real (no lineal)');
xlabel('Frecuencia de batido [kHz]');
ylabel('|FFT| normalizada');
title('Comparación de Espectros del Beat: Ideal vs No Lineal');
xlim([0, fb_exp/1e3*10]);
legend('Location','northeast');
grid on;

% --- 11. RESULTADOS EN CONSOLA ---
fprintf('\n================ RESULTADOS ================\n');
fprintf('Distancia real:           %.3f m\n', R);
fprintf('Frecuencia de batido ideal esperada: %.2f kHz\n', fb_exp/1e3);
fprintf('--------------------------------------------\n');
fprintf('Rampa IDEAL:\n');
fprintf('  f_b medida: %.2f kHz   →  R_est = %.3f m   (Error = %.3f m)\n', fb_lin/1e3, R_est_lin, R_est_lin - R);
fprintf('--------------------------------------------\n');
fprintf('Rampa NO LINEAL (ZX95):\n');
fprintf('  f_b medida: %.2f kHz   →  R_est = %.3f m   (Error = %.3f m)\n', fb_nl/1e3, R_est_nl, R_est_nl - R);
fprintf('============================================\n');
