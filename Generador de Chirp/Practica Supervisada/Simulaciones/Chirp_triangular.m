clc; clear; close all;

% Parámetros base
f_ini = 0;      % Hz
f_fin = 100;    % Hz
fs    = 1000;   % Hz
T     = 1;      % duración de medio ciclo [s]
N     = T*fs;
t     = (0:N-1)/fs;

% Eco simulado
delay_time = 0.2;                  
delay_samples = round(delay_time*fs);
atten = 0.7;                        

% Número de chirps triangulares
chirp_count = 2;   % p.ej. 2 triángulos seguidos

for idx = 1:chirp_count
    % === Frecuencia instantánea triangular ===
    f_up   = f_ini + (f_fin-f_ini)*(t/T);       % ascendente
    f_down = f_fin - (f_fin-f_ini)*(t/T);       % descendente
    f_inst = [f_up f_down];                     % concatenado
    
    % Tiempo extendido para el triángulo
    t_tri = (0:length(f_inst)-1)/fs;
    
    % === Señal Tx ===
    phi = 2*pi*cumsum(f_inst)/fs;
    tx = exp(1j*phi);
    
    % === Señal Rx (retardada y atenuada) ===
    rx = zeros(1, length(tx) + delay_samples);
    rx(delay_samples+1:delay_samples+length(tx)) = atten * tx; 
    t_rx = (0:length(rx)-1)/fs;
    
    % === Matched Filter ===
    h = conj(flip(tx));
    y = conv(rx, h, 'same');
    
    % === Graficar ===
    figure('Name',sprintf('Triángulo %d',idx));
    
    % (1) Frecuencia instantánea
    subplot(4,1,1);
    plot(t_tri, f_inst, 'LineWidth', 1.3); grid on;
    xlabel('Tiempo [s]'); ylabel('f_{inst} [Hz]');
    title('Chirp triangular: frecuencia instantánea');
    xlim([0 max(t_tri)]);
    
    % (2) Tx (parte real)
    subplot(4,1,2);
    plot(t_tri, real(tx)); grid on;
    xlabel('Tiempo [s]'); ylabel('Amplitud');
    title('Tx (real)');
    xlim([0 max(t_tri)]);
    
    % (3) Rx
    subplot(4,1,3);
    plot(t_rx, real(rx)); grid on;
    xlabel('Tiempo [s]'); ylabel('Amplitud');
    title('Rx (retardado)');
    xlim([0 max(t_tri)+delay_time]);
    
    % (4) Salida matched filter
    subplot(4,1,4);
    plot(t_rx, abs(y)); grid on;
    xlabel('Tiempo [s]'); ylabel('Amplitud');
    title('Salida del matched filter');
    xlim([0 max(t_tri)+delay_time]);
end
