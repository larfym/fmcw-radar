%% --- Comparación de frecuencia de batido entre rampa ideal y ADF4350 ---

clc;
clear;
close all;

% --- Parámetros del sistema ---
c = 3e8;                  % velocidad de la luz (m/s)
R_target = 10;            % distancia del objetivo (m)
freq_start_main_MHz = 100; % MHz
freq_end_main_MHz = 200;   % MHz
num_main_steps = 100;

% --- Patrón del ADF4350 (simulado del fabricante) ---
manufacturer_time_us = [0, 20, 40, 60, 75, 90, 110];
manufacturer_freq_rel_MHz = [0, 40, 20, 10, 5, 0];
pattern_duration_us = manufacturer_time_us(end);

% --- Tiempo total de la simulación ---
total_time_us = num_main_steps * pattern_duration_us;
total_time_s = total_time_us * 1e-6;

% --- Generar rampa ideal ---
dt = 1e-9;
t = 0:dt:total_time_s;
f_ideal_Hz = (freq_start_main_MHz*1e6) + ...
    ((freq_end_main_MHz - freq_start_main_MHz)*1e6) * (t / total_time_s);

% --- Generar rampa tipo ADF4350 ---
dt2 = 1e-10;
t2 = 0:dt2:total_time_s;
f_combined_Hz = zeros(size(t2));

main_freq_increment_MHz = (freq_end_main_MHz - freq_start_main_MHz) / num_main_steps;
current_t_us = 0;

for i = 1:num_main_steps
    base_freq_MHz = freq_start_main_MHz + (i-1)*main_freq_increment_MHz;
    for j = 1:length(manufacturer_freq_rel_MHz)-1
        t_start_us = current_t_us + manufacturer_time_us(j);
        t_end_us = current_t_us + manufacturer_time_us(j+1);
        f_actual_MHz = base_freq_MHz + manufacturer_freq_rel_MHz(j);
        idx = (t2*1e6 >= t_start_us) & (t2*1e6 < t_end_us);
        f_combined_Hz(idx) = f_actual_MHz*1e6;
    end
    current_t_us = current_t_us + pattern_duration_us;
end

% --- Calcular frecuencia de batido para un objetivo a 10 m ---
% f_beat = (2*R / c) * df/dt
dfdt_ideal = gradient(f_ideal_Hz, dt);
dfdt_adf = gradient(f_combined_Hz, dt2);

fbeat_ideal = (2*R_target/c) .* dfdt_ideal;
fbeat_adf = (2*R_target/c) .* dfdt_adf(1:length(t)); % igualar tamaño

% --- Diferencia entre frecuencias de batido ---
fbeat_diff = fbeat_adf - fbeat_ideal;
%% --- Graficar comparación de Frecuencias de Batido ---

% Figura 1: Comparación de la Frecuencia de Batido (f_beat)
figure('Position',[100 100 1200 500])

% Graficar la f_beat ideal (debe ser constante)
plot(t*1e6, fbeat_ideal/1e3, 'r--', 'LineWidth', 2, 'DisplayName', 'f_{beat} Ideal (Lineal)')
hold on;

% Graficar la f_beat del ADF (escalonada/variable)
% NOTA: Usamos 't' para ambas ya que la interpolación en el código original ya igualó el tamaño
plot(t*1e6, fbeat_adf/1e3, 'b', 'LineWidth', 1.5, 'DisplayName', 'f_{beat} ADF4350 (Escalonada)')

% Configuración del gráfico
xlabel('Tiempo (\mus)', 'FontSize', 14)
ylabel('Frecuencia de Batido (kHz)', 'FontSize', 14)
title('Frecuencia de Batido Resultante (\it{f}_{beat}) a R=10 m', 'FontSize', 16)
ylim_min = min(fbeat_ideal)/1e3 * 0.9;
ylim_max = max(fbeat_ideal)/1e3 * 1.1;
ylim([ylim_min ylim_max])
grid on
legend('show', 'Location', 'NorthEast')
hold off;

%% --- Figura 2: Graficar diferencia (Error de Linealidad) ---
% Esto es lo que estaba en tu código original, ahora como Figura 2 para el análisis de error.
figure('Position',[100 650 1200 500])
plot(t*1e6, fbeat_diff/1e3, 'k', 'LineWidth', 1.5)
xlabel('Tiempo (\mus)', 'FontSize', 14)
ylabel('\Delta f_{beat} (kHz)', 'FontSize', 14)
title('Error en la Frecuencia de Batido debido al ADF4350', 'FontSize', 16)
grid on
xlim([0 200]) % Muestra solo los primeros 200 µs para mejor detalle