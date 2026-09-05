%% Rampa FMCW: Rampa escalonada (1200 pasos) y cálculo de resultados
clc; clear; close all;

% --- 0. PARÁMETROS FÍSICOS ---
R = 12;                      
c = physconst('LightSpeed'); 
tau = 2 * R / c;             

% --- 1. PARÁMETROS DE RAMPA Y MUESTREO ---
T = 1e-3;                    
Fs = 100e6;                  
f_start = 1800e6; 
f_end   = 2100e6;            
BW = f_end - f_start;
Slope = BW / T;              

dt = 1/Fs;
t = (0:dt:T-dt).';           
t_len = numel(t);

% --- 2. RAMPA ESCALONADA (1200 PASOS) ---
n_steps = 1200;                                  
f_lvls = linspace(f_start, f_end, n_steps);     
t_steps = linspace(0, T, n_steps);              

% Interpolación tipo 'previous' para escalonada exacta
f_tx_step = interp1(t_steps, f_lvls, t, 'previous');  

% --- 3. CÁLCULO DE RX RETARDADA ---
delay_samples = round(tau / dt);
f_rx_step = circshift(f_tx_step, delay_samples);
f_rx_step(1:delay_samples) = f_start;

% --- 4. GENERACIÓN DE SEÑAL ANALÍTICA Y MEZCLADOR ---
Amplitud_rx = 0.8;
phase_tx_step = 2*pi*cumtrapz(t, f_tx_step);
phase_rx_step = 2*pi*cumtrapz(t, f_rx_step);

wave_tx_step = exp(1j*phase_tx_step);
wave_rx_step = Amplitud_rx * exp(1j*phase_rx_step);

signal_if_step = wave_tx_step .* conj(wave_rx_step);

% --- 5. FFT DEL BEAT ---
N_fft = 2^nextpow2(length(signal_if_step));
FFT_step = abs(fft(signal_if_step, N_fft));
FFT_step = FFT_step(1:N_fft/2);

Fs_fft = Fs / N_fft;
Freq_axis = (0:N_fft/2-1)*Fs_fft;

% --- 6. INTERPOLACIÓN CUADRÁTICA DEL PICO ---
[~, idx] = max(FFT_step);
if idx>1 && idx<numel(FFT_step)
    alpha = FFT_step(idx-1);
    beta  = FFT_step(idx);
    gamma = FFT_step(idx+1);
    delta = 0.5*(alpha - gamma)/(alpha - 2*beta + gamma);
else
    delta = 0;
end
fb_step = Freq_axis(idx) + delta*Fs_fft;    % Frecuencia de batido refinada
fb_exp  = Slope * tau; 

R_est_step = c * fb_step / (2 * Slope);

% =========================================================
% ===== GRÁFICOS =====
% =========================================================
figure('Color','w','Position',[100 100 700 400]);

stairs(t*1e3, f_tx_step/1e6, 'b', 'LineWidth', 1.4);
xlabel('Tiempo [ms]');
ylabel('Frecuencia [MHz]');
title('Rampa Escalonada TX (1200 Pasos)');
grid on;

idx_center = find(Freq_axis>=fb_step, 1);
idx_range  = max(1, idx_center-200):min(numel(Freq_axis), idx_center+200);

figure('Color','w','Position',[850 100 700 400]);
plot(Freq_axis(idx_range)/1e3, FFT_step(idx_range)/max(FFT_step(idx_range)), 'b', 'LineWidth', 1.4);
xlabel('Frecuencia de batido [kHz]');
ylabel('|FFT| normalizada');
title('Espectro de Batido - Zoom alrededor del pico');
grid on;
% --- 7. RESULTADOS EN CONSOLA ---
fprintf('\n================ RESULTADOS ================\n');
fprintf('Distancia real (R):                      %.3f m\n', R);
fprintf('Frecuencia de batido teórica:            %.2f kHz\n', fb_exp/1e3);
fprintf('Rampa ESCALONADA (1200 pasos, interpolación):\n');
fprintf('  f_b medida: %.2f kHz    ->  R_est = %.3f m    (Error = %.3f m)\n', fb_step/1e3, R_est_step, R_est_step - R);
fprintf('============================================\n');
