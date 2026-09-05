clc; clear; close all;

%% Parámetros fijos
c   = physconst('LightSpeed')*0.66;      % m/s
fc  = 2e9;                          % Hz
T   = 1e-3;                         % s
nChirps = 1;                        
Fs = 10e6;                           % Hz 
dt = 1/Fs;
t  = 0:dt:nChirps*T - dt;

% Blancos
R = [14, 15];                     % m
v = [  0, 10];                      % m/s
tau = 2*R/c;                        % s
fd  = 2*v*fc/c;                     % Hz
nTargets = numel(R);

% Lista de anchos de banda a comparar
BW_list = [300e6,100e6,25e6];

% ====== Figura para ver la no linealidad del chirp ======
figure('Name','No linealidad del chirp','NumberTitle','off');
hold on; grid on;
xlabel('Tiempo [ms]');
ylabel('Frecuencia instantánea [MHz]');
title('Chirp no lineal simulado (efecto VCO)');

% Layout para los espectros
figure;
tiledlayout(numel(BW_list), 1, "Padding", "compact", "TileSpacing", "compact");

for bwi = 1:numel(BW_list)
    BW = BW_list(bwi);
    slope = BW/T;

    % ====== TX con NO LINEALIDAD DE VCO ======
    t_mod_tx = mod(t, T);

    % Modelado no lineal: curva cuadrática + componente aleatoria suave
    alpha = 0.15;                         % nivel de no linealidad
    nonlinear_term = alpha * (t_mod_tx/T).^2 * BW;  
    slow_noise = 0.01*BW * sin(2*pi*50*t_mod_tx);  
    f_inst = fc + slope*t_mod_tx + nonlinear_term + slow_noise;
    phi = 2*pi*cumtrapz(t, f_inst);
    s_tx = cos(phi);

    % Graficar solo una vez el chirp para mostrar su forma
    if bwi == 1
        plot(t_mod_tx*1e3, f_inst/1e6, 'DisplayName', sprintf('BW=%.0f MHz', BW/1e6));
    end

    % ====== RX: suma de ecos con retardo + Doppler ======
    s_rx = zeros(size(t));
    for n = 0:nChirps-1
        for k = 1:nTargets
            idx = (t >= (n*T + tau(k))) & (t < ((n+1)*T + tau(k)));
            if any(idx)
                t_rel = t(idx) - (n*T + tau(k));
                f_inst_rx = fc + slope*t_rel + nonlinear_term(idx) + slow_noise(idx) + fd(k);
                phi_rx = 2*pi*cumtrapz(t(idx), f_inst_rx);
                s_rx(idx) = s_rx(idx) + cos(phi_rx);
            end
        end
    end

    % ====== Mezcla ======
    s_mix = s_tx .* s_rx;

    % ====== FFT del beat ======
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

    % ====== Picos estimados ======
    bandMask = (fpos > 1e3) & (fpos < 2e6);
    pks_all  = abs(Bpos(bandMask));
    [pks, locs] = findpeaks(pks_all, ...
                            'NPeaks', nTargets, ...
                            'SortStr','descend', ...
                            'MinPeakProminence', 0.05*max(pks_all));
    fb_est = fpos(bandMask);
    fb_est = sort(fb_est(locs));           % Hz

    % ====== Rangos estimados y errores ======
    R_true  = sort(R(:)).';                
    R_est   = c*fb_est/(2*slope);          
    m = min(numel(R_est), numel(R_true));
    err_abs = abs(R_est(1:m) - R_true(1:m));

    % ====== Frecuencias esperadas ======
    fb_exp = sort(slope*tau + fd);         

    % ====== Plot ======
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

    % ====== Consola ======
    fprintf('\n=== BW = %.0f MHz ===\n', BW/1e6);
    fprintf('Resolución teórica dR = %.3f m\n', dR);
    fprintf('R (real)     : %s m\n', sprintf('%.2f ', R_true));
    if isempty(R_est)
        fprintf('No se detectaron picos.\n');
    else
        fprintf('R (estimado) : %s m\n', sprintf('%.2f ', R_est));
        fprintf('Error abs    : %s m\n', sprintf('%.2f ', err_abs));
    end
    fprintf('f_b (esp)    : %s Hz\n', sprintf('%.1f ', fb_exp));
    if ~isempty(fb_est), fprintf('f_b (est)    : %s Hz\n', sprintf('%.1f ', fb_est)); end
end

% Mostrar leyenda del gráfico del chirp
figure(findobj('Name','No linealidad del chirp'));
legend('show','Location','best');
