clc; clear; close all;

%% ============================================================
%              PARÁMETROS DEL RADAR FMCW
% =============================================================
c   = physconst('LightSpeed');      % m/s
fc  = 2e9;                          % Hz (frecuencia central)
T   = 1e-3;                         % s  (duración del chirp)
nChirps = 1;                        
Fs = 10e6;                          % Hz 
dt = 1/Fs;
t  = 0:dt:nChirps*T - dt;

% Blancos iniciales
R = [10, 11.4];                     % m
v = [0, 10];                        % m/s
tau = 2*R/c;                        % s
fd  = 2*v*fc/c;                     % Hz
nTargets = numel(R);

% Lista de anchos de banda a comparar
BW_list = [300e6,100e6,50e6];

% =============================================================
%              ANÁLISIS DE DIFERENTES BANDAS
% =============================================================
tiledlayout(numel(BW_list), 1, "Padding", "compact", "TileSpacing", "compact");

for bwi = 1:numel(BW_list)
    BW = BW_list(bwi);
    slope = BW/T;

    % ====== TX ======
    t_mod_tx = mod(t, T);
    s_tx = cos(2*pi*(fc*t + 0.5*slope*t_mod_tx.^2));

    % ====== RX ======
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

    % ====== FFT ======
    NchirpSamples = round(T/dt);
    mix_ch1 = s_mix(1:NchirpSamples);
    i0 = max(1, floor(max(tau)/dt) + 1);
    mix_valid = mix_ch1(i0:end);

    w    = hann(numel(mix_valid)).';
    Nfft = 2^nextpow2(numel(mix_valid));
    B    = fft(mix_valid.*w, Nfft);
    f    = (0:Nfft-1)*(Fs/Nfft);
    Bpos = B(1:Nfft/2+1);
    fpos = f(1:Nfft/2+1);

    bandMask = (fpos > 1e3) & (fpos < 2e6);
    pks_all  = abs(Bpos(bandMask));
    [pks, locs] = findpeaks(pks_all, 'NPeaks', nTargets, ...
        'SortStr','descend', 'MinPeakProminence', 0.05*max(pks_all));
    fb_est = fpos(bandMask);
    fb_est = sort(fb_est(locs));

    R_true  = sort(R(:)).';
    R_est   = c*fb_est/(2*slope);
    m = min(numel(R_est), numel(R_true));
    err_abs = abs(R_est(1:m) - R_true(1:m));

    fb_exp = sort(slope*tau + fd);

    nexttile;
    plot(fpos/1e3, abs(Bpos)/max(abs(Bpos)), 'LineWidth', 1.1); grid on; hold on;

    if ~isempty(fb_est)
        stem(fb_est/1e3, ones(size(fb_est))*0.9, 'filled');
    end

    for k = 1:numel(fb_exp)
        xline(fb_exp(k)/1e3, '--', 'Color', [0.2 0.2 0.2], 'LineWidth', 1);
    end

    f_max_plot = min(2.5e6, 1.5*max([fb_exp(:); fb_est(:); 1e5]));
    xlim([0, f_max_plot]/1e3);
    xlabel('Frecuencia [kHz]'); ylabel('|B| norm');

    dR = c/(2*BW);
    title(sprintf(['BW=%.0f MHz | dR=%.3f m | R real=[%g %g] m | ' ...
                   'R est=[%0.2f %0.2f] m | err=[%0.2f %0.2f] m'], ...
           BW/1e6, dR, R_true, ...
           padarray(R_est, [0 max(0,2-numel(R_est))], NaN, 'post'), ...
           padarray(err_abs, [0 max(0,2-numel(err_abs))], NaN, 'post')));

    legend({'Espectro','Picos estimados','f_b esperada'}, 'Location','northeast');
end

%% =============================================================
%              GRÁFICO DE FRECUENCIA INSTANTÁNEA TX vs RX
% =============================================================
BW = BW_list(1); % usar el primero para representar
slope = BW/T;

t_plot = linspace(0, T, 1000);
f_tx = fc + slope*t_plot;        % frecuencia instantánea TX
f_rx = fc + slope*(t_plot - tau(1));  % frecuencia instantánea RX (retardada)
f_rx(t_plot < tau(1)) = NaN;    % antes del eco, no hay señal

figure;
plot(t_plot*1e3, f_tx/1e9, 'k', 'LineWidth', 1.8); hold on;
plot(t_plot*1e3, f_rx/1e9, 'r', 'LineWidth', 1.8);
grid on;
xlabel('Tiempo [ms]');
ylabel('Frecuencia instantánea [GHz]');
title(sprintf('Frecuencia instantánea Tx (negro) vs Rx (rojo) — R = %.1f m', R(1)));
legend({'Transmitido','Recibido'}, 'Location','northwest');

%% =============================================================
%              ANIMACIÓN: CAMBIO DE DISTANCIA DEL OBJETIVO 2
% =============================================================
figure;
BW = 300e6;              % ancho de banda usado
slope = BW/T;
R1 = 1;                 % m (fijo)
R2_range = linspace(1, 30, 100);  % rango variable
v = [0 0];               % sin velocidad

for r2 = R2_range
    R = [R1, r2];
    tau = 2*R/c;
    fd  = 2*v*fc/c;
    nTargets = numel(R);

    % ====== TX ======
    t_mod_tx = mod(t, T);
    s_tx = cos(2*pi*(fc*t + 0.5*slope*t_mod_tx.^2));

    % ====== RX ======
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

    % ====== Mezcla y FFT ======
    s_mix = s_tx .* s_rx;
    NchirpSamples = round(T/dt);
    mix_ch1 = s_mix(1:NchirpSamples);
    i0 = max(1, floor(max(tau)/dt) + 1);
    mix_valid = mix_ch1(i0:end);

    w    = hann(numel(mix_valid)).';
    Nfft = 2^nextpow2(numel(mix_valid));
    B    = fft(mix_valid.*w, Nfft);
    f    = (0:Nfft-1)*(Fs/Nfft);
    Bpos = B(1:Nfft/2+1);
    fpos = f(1:Nfft/2+1);

    % ====== Gráfico ======
    plot(fpos/1e3, abs(Bpos)/max(abs(Bpos)), 'LineWidth', 1.3);
    grid on;
    ylim([0 1.1]); xlim([0 70]);
    xlabel('Frecuencia [kHz]'); ylabel('|B| normalizada');
    title(sprintf('Espectro del batido | R_1 = %.1f m (fijo) | R_2 = %.2f m (variable)', R1, r2));
    drawnow;
end
