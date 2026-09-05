% --- Comparación chirp escalonado con distinto número de escalones + espectrograma ---
clear; clc;

% Parámetros base
f_ini = 0;      % Hz
f_fin = 100;    % Hz
fs    = 1000;   % Hz
T     = 1;      % s
N     = T*fs;
t     = (0:N-1)'/fs;

% Lista de casos a comparar
steps_list = [5, 25, 100];

figure;
for idx = 1:length(steps_list)
    n_steps = steps_list(idx);
    dwell     = T / n_steps;
    samples_s = round(dwell * fs);
    
    % Construcción escalones
    B = f_fin - f_ini;
    df = B / n_steps;
    f_lvls = f_ini + (0:n_steps-1)*df;
    
    f_inst = repelem(f_lvls, samples_s).';
    if numel(f_inst) < N
        f_inst(end+1:N) = f_lvls(end);
    elseif numel(f_inst) > N
        f_inst = f_inst(1:N);
    end
    
    % Señal con fase continua
    phi = 2*pi*cumsum(f_inst)/fs;
    x   = cos(phi);
    
    % ----------- Gráficas -----------
    % f_inst
    subplot(length(steps_list),3,3*idx-2);
    stairs(t, f_inst, 'LineWidth', 1.3); grid on;
    xlabel('Tiempo [s]'); ylabel('f_{inst} [Hz]');
    title(sprintf('%d escalones: f_{inst}', n_steps));
    xlim([0 T]);
    
    % Señal temporal
    subplot(length(steps_list),3,3*idx-1);
    plot(t, x); grid on;
    xlabel('Tiempo [s]'); ylabel('Amplitud');
    title(sprintf('%d escalones: señal temporal', n_steps));
    xlim([0 T]);
    
    % Espectrograma
    subplot(length(steps_list),3,3*idx);
    window = hamming(128);          % ventana
    noverlap = 120;                 % solapamiento
    nfft = 256;                     % puntos FFT
    spectrogram(x, window, noverlap, nfft, fs, 'yaxis');
    ylim([0 f_fin]);    % mostrar hasta f_fin (100 Hz)
    % limitar a 0–150 Hz (normalizado en kHz)
    title(sprintf('%d escalones: espectrograma', n_steps));
end
