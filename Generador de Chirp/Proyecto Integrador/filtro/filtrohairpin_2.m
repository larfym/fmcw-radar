%% 1. Filtro elegido: Inverse Chebyshev
clc ; clear all ; close all ;
freqs = linspace(1e9, 2.5e9, 1000); 

filt = rffilter('FilterType', 'InverseChebyshev', ...
                'ResponseType', 'Bandpass', ...
                'Implementation', 'Transfer function', ...
                'FilterOrder', 5, ...
                'PassbandAttenuation', 0.1, ...
                'PassbandFrequency', [1.55e9, 1.85e9], ... 
                'StopbandFrequency', [1.4e9, 2e9], ...     
                'StopbandAttenuation', 27,...
                'Zin', 50, 'Zout', 50);

data = sparameters(filt, freqs);
IChs21 = 20*log10(abs(rfparam(data, 2, 1)));
IChs11 = 20*log10(abs(rfparam(data, 1, 1)));
data_export = sparameters(filt, freqs);

% Escribimos el archivo Touchstone
rfwrite(data_export, 'filtro_ideal_1p75GHz.s2p');

% 3. Gráfico comparativo 
figure;plot(freqs/1e9, IChs21, 'b.', 'LineWidth', 2);
hold on;
       plot(freqs/1e9, IChs11, 'g.', 'LineWidth', 2);
hold off;
% 4. Estética del gráfico
grid on;
xlabel('Frecuencia (GHz)');
ylabel('Magnitud de S_{21} y S_{11}(dB)');
title('Respuestas de Filtro Pasabanda Inverso de Chebyshev (N=6)');
legend('Inverse Chebyshev', 'Location', 'best');
ylim([-60, 5]); % Limita el eje Y para apreciar bien la banda de paso y el stopband

