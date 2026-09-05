clc; clear; close all; 

%% Parámetros fijos 
c = physconst('LightSpeed'); % m/s 
fc = 2e9; % Hz 
T = 1e-3; % s 
nChirps = 1; 
Fs = 10e6; % Hz 
dt = 1/Fs; 
t = 0:dt:nChirps*T - dt; 

% Blancos 
R = [10, 12   ]; % m (rangos reales) 
v = [ 0, 10]; % m/s 
tau = 2*R/c; % s .0

fd = 2*v*fc/c; % Hz 
nTargets = numel(R); 

% Lista de anchos de banda a comparar 
BW_list = [300e6,100e6,50e6]; 

% Layout para verlos juntos 
tiledlayout(numel(BW_list), 1, "Padding", "compact", "TileSpacing", "compact"); 

for bwi = 1:numel(BW_list) 
    BW = BW_list(bwi); 
    slope = BW/T; 

    % ====== TX ====== 
    t_mod_tx = mod(t, T); 
    s_tx = cos(2*pi*(fc*t + 0.5*slope*t_mod_tx.^2)); 

    % ====== RX: suma de ecos con retardo + Doppler ====== 
    s_rx = zeros(size(t)); 
    for n = 0:nChirps-1 
        for k = 1:nTargets 
            idx = (t >= (n*T + tau(k))) & (t < ((n+1)*T + tau(k))); 
            if any(idx) 
                t_rel = t(idx) - (n*T + tau(k)); 
                s_rx(idx) = s_rx(idx) + cos(2*pi*(fc*t(idx) + 0.5*slope*t_rel.^2 + fd(k)*t(idx))); 
            end 
        end 
    end 

    % ====== Mezcla ====== 
    s_mix = s_tx .* s_rx; 

    % ====== FFT del beat (1er chirp, desde max(tau)) ====== 
    NchirpSamples = round(T/dt); 
    mix_ch1 = s_mix(1:NchirpSamples); 
    i0 = max(1, floor(max(tau)/dt) + 1); 
    mix_valid = mix_ch1(i0:end); 

    w = hann(numel(mix_valid)).'; 
    Nfft = 2^nextpow2(numel(mix_valid)); 
    B = fft(mix_valid.*w, Nfft); 
    f = (0:Nfft-1)*(Fs/Nfft); 
    Bpos = B(1:Nfft/2+1); 
    fpos = f(1:Nfft/2+1); 

    % ====== Picos estimados ====== 
    bandMask = (fpos > 1e3) & (fpos < 2e6); 
    pks_all = abs(Bpos(bandMask)); 
    [pks, locs] = findpeaks(pks_all, ... 
        'NPeaks', nTargets, ... 
        'SortStr','descend', ... 
        'MinPeakProminence', 0.05*max(pks_all)); 
    fb_est = fpos(bandMask); 
    fb_est = sort(fb_est(locs)); % Hz 

    % ====== Rangos estimados y errores ====== 
    R_true = sort(R(:)).'; % m 
    R_est = c*fb_est/(2*slope); % m 
    % Asegurar longitudes (por si encuentra < nTargets picos) 
    m = min(numel(R_est), numel(R_true)); 
    err_abs = abs(R_est(1:m) - R_true(1:m)); 

    % ====== Frecuencias de batido esperadas (para graficar líneas) ====== 
    fb_exp = sort(slope*tau + fd); % Hz 

    % ====== Plot ====== 
    nexttile; 
    plot(fpos/1e3, abs(Bpos)/max(abs(Bpos)), 'LineWidth', 1.1); grid on; hold on; 

    % Marcar picos estimados 
    if ~isempty(fb_est) 
        stem(fb_est/1e3, ones(size(fb_est))*0.9, 'filled'); 
    end 

    % Marcar f_b esperadas (líneas punteadas) 
    for k = 1:numel(fb_exp) 
        xline(fb_exp(k)/1e3, '--', 'Color', [0.2 0.2 0.2], 'LineWidth', 1); 
    end 

    % Eje X 
    f_max_plot = min(2.5e6, 1.5*max([fb_exp(:); fb_est(:); 1e5])); 
    xlim([0, f_max_plot]/1e3); 
    xlabel('Frecuencia [kHz]'); ylabel('|B| norm'); 

    % Título con info real vs medida 
    dR = c/(2*BW); 
    title(sprintf(['BW=%.0f MHz | dR=%.3f m | R real=[%g %g] m | ' ... 
                   'R est=[%0.2f %0.2f] m | err=[%0.2f %0.2f] m'], ... 
           BW/1e6, dR, R_true, ... 
           padarray(R_est, [0 max(0,2-numel(R_est))], NaN, 'post'), ... 
           padarray(err_abs, [0 max(0,2-numel(err_abs))], NaN, 'post'))); 

    legend({'Espectro','Picos estimados','f_b esperada'}, 'Location','northeast'); 

    % ======consola ====== 
    fprintf('\n=== BW = %.0f MHz ===\n', BW/1e6); 
    fprintf('Resolución teórica dR = %.3f m\n', dR); 
    fprintf('R (real) : %s m\n', sprintf('%.2f ', R_true)); 
    if isempty(R_est) 
        fprintf('No se detectaron picos.\n'); 
    else 
        fprintf('R (estimado) : %s m\n', sprintf('%.2f ', R_est)); 
        fprintf('Error abs : %s m\n', sprintf('%.2f ', err_abs)); 
    end 
    fprintf('f_b (esp) : %s Hz\n', sprintf('%.1f ', fb_exp)); 
    if ~isempty(fb_est), fprintf('f_b (est) : %s Hz\n', sprintf('%.1f ', fb_est)); end 
end
