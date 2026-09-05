% 1. Definición de frecuencias de análisis (Ej: de 1 GHz a 2.5 GHz con más puntos para mejor resolución)
freqs = linspace(1e9, 2.5e9, 1000); 

% Filtro 1: Chebyshev (Tipo I)
filt1 = rffilter('FilterType', 'Chebyshev', ...
                'ResponseType', 'Bandpass', ...
                'Implementation', 'Transfer function', ...
                'FilterOrder', 5, ...
                'PassbandAttenuation', 0.1, ...
                'PassbandFrequency', [1.55e9, 1.85e9], ... % Corregido a Hz
                'StopbandFrequency', [1.4e9, 2e9], ...     % Corregido a Hz
                'StopbandAttenuation', 27,...
                'Zin', 50, 'Zout', 50);

% Filtro 2: Butterworth
filt2 = rffilter('FilterType', 'Butterworth', ...
                'ResponseType', 'Bandpass', ...
                'Implementation', 'Transfer function', ...
                'FilterOrder', 5, ...
                'PassbandAttenuation', 0.1, ...
                'PassbandFrequency', [1.55e9, 1.85e9], ... % Corregido a Hz
                'StopbandFrequency', [1.4e9, 2e9], ...     % Corregido a Hz
                'StopbandAttenuation', 27,...
                'Zin', 50, 'Zout', 50);

% Filtro 3: Inverse Chebyshev (Tipo II)
filt3 = rffilter('FilterType', 'InverseChebyshev', ...
                'ResponseType', 'Bandpass', ...
                'Implementation', 'Transfer function', ...
                'FilterOrder', 5, ...
                'PassbandAttenuation', 0.1, ...
                'PassbandFrequency', [1.55e9, 1.85e9], ... % Corregido a Hz
                'StopbandFrequency', [1.4e9, 2e9], ...     % Corregido a Hz
                'StopbandAttenuation', 27,...
                'Zin', 50, 'Zout', 50);

% 2. Cálculo de Parámetros S
data1 = sparameters(filt1, freqs);
Chs21 = 20*log10(abs(rfparam(data1, 2, 1)));
Chs11  = 20*log10(abs(rfparam(data1, 1, 1)));

data2 = sparameters(filt2, freqs);
Bts21 = 20*log10(abs(rfparam(data2, 2, 1)));
Bts11  = 20*log10(abs(rfparam(data2, 1, 1)));

data3 = sparameters(filt3, freqs);
IChs21 = 20*log10(abs(rfparam(data3, 2, 1)));
IChs11 = 20*log10(abs(rfparam(data3, 1, 1)));


% 3. Gráfico comparativo (Frecuencias divididas por 1e9 para ver el eje X en GHz)
figure;
plot(freqs/1e9, Chs21, 'r-', 'LineWidth', 2); hold on;
plot(freqs/1e9, Bts21, 'b--', 'LineWidth', 2);
plot(freqs/1e9, IChs21, 'g-.', 'LineWidth', 2);
hold off;

% 4. Estética del gráfico
grid on;
xlabel('Frecuencia (GHz)');
ylabel('Magnitud de S_{21} (dB)');
title('Comparación de Respuestas de Filtros Pasabanda (N=6)');
legend('Chebyshev I', 'Butterworth', 'Inverse Chebyshev', 'Location', 'best');
ylim([-60, 5]); % Limita el eje Y para apreciar bien la banda de paso y el stopband

figure; % Abre la segunda ventana gráfica
plot(freqs/1e9, Chs11, 'r-', 'LineWidth', 2); hold on;
plot(freqs/1e9, Bts11, 'b--', 'LineWidth', 2);
plot(freqs/1e9, IChs11, 'g-.', 'LineWidth', 2);
hold off;

% Estética del gráfico S11
grid on;
xlabel('Frecuencia (GHz)');
ylabel('Magnitud de S_{11} (dB)');
title('Comparación de Adaptación de Entrada (S_{11})');
legend('Chebyshev I', 'Butterworth', 'Inverse Chebyshev', 'Location', 'best');
ylim([-50, 0]); % Rango típico en dB para evaluar el acoplamiento