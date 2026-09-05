% --- Generar Onda Coseno con Frecuencia Variable y Gráfica de Frecuencia ---

% 1. Limpiar el entorno
clc;
clear;
close all;

% 2. Definir los parámetros de la señal de frecuencia
time_intervals = [0, 20, 40, 60, 75, 90, 110]; % en us
frequency_values = [200, 240, 220, 210, 205, 200]; % en MHz

% 3. Crear el vector de tiempo
t_final = time_intervals(end) * 1e-6; % Tiempo final en segundos
dt = 1e-10; % Paso de tiempo pequeño para precisión de la fase
t = 0:dt:t_final;

% 4. Generar la señal de frecuencia (f(t))
f = zeros(size(t));
for i = 1:length(frequency_values)
    start_time = time_intervals(i) * 1e-6;
    end_time = time_intervals(i+1) * 1e-6;
    indices = (t >= start_time) & (t < end_time);
    f(indices) = frequency_values(i);
end
f(t == t_final) = frequency_values(end);

% 5. Calcular la fase instantánea (phi(t))
f_Hz = f * 1e6; % Convertir de MHz a Hz
phi = cumsum(2 * pi * f_Hz * dt); % Integración numérica para la fase

% 6. Generar la onda coseno modulada en frecuencia
y = cos(phi);

% 7. Visualizar los resultados

figure('Position', [100, 100, 900, 700]); % Crear una figura más grande

% Subplot 1: Gráfica de Frecuencia vs. Tiempo (la original)
subplot(2, 1, 1);
plot(t * 1e6, f, 'r', 'LineWidth', 2);
title('Perfil de Frecuencia (Frecuencia vs. Tiempo)');
xlabel('Tiempo (\mus)');
ylabel('Frecuencia (MHz)');
grid on;
axis([0 110 195 245]); % Ajustar límites de los ejes

% Subplot 2: Zoom de la Onda Coseno Modulada
subplot(2, 1, 2);
% Definimos una ventana de tiempo pequeña para visualizar una transición
% Por ejemplo, de 38 us a 42 us, donde la frecuencia cambia de 240 a 220 MHz
start_plot_t = 19.8e-6;
end_plot_t = 20.15e-6;
indices_plot = (t >= start_plot_t) & (t <= end_plot_t);
plot(t(indices_plot) * 1e6, y(indices_plot));
title('Zoom de la Onda Coseno Modulada (Transición 240 a 220 MHz)');
xlabel('Tiempo (\mus)');
ylabel('Amplitud');
grid on;