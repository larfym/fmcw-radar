% Frecuencias en Hz (usando notación científica)
frec = [1e3, 5e3, 10e3, 50e3, 100e3, 500e3, 1e6, 1.369e6]; 

% Magnitudes en dB (¡Falta un dato! Añadí NaN al final para que corra el código)
magn = [43.8, 30.6, 23.4, 10.9, 7.8, 4.5, 2,0]; 

% Crear la gráfica con escala logarítmica en el eje X
figure;
semilogx(frec, magn, '-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'b');

% Configurar la cuadrícula para diagramas de Bode/Frecuencia
grid on;
set(gca, 'XMinorTick', 'on');

% Etiquetas y título
xlabel('Frecuencia (Hz)');
ylabel('Magnitud (dB)');
title('Respuesta en Frecuencia');