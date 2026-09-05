%PS Andrés Agustín Cesana
clc;
close all;
clear;

% Parámetros del chirp
f1 = 0;       
f2 = 100;     
tiempo = 1;   

% Valores de frecuencia de muestreo a probar
fs_values = [80 150 300 600]; 

figure;

for i = 1:length(fs_values)
    fs = fs_values(i);
    t = 0:1/fs:tiempo;
    
    % Chirp lineal
    x = chirp(t,f1,tiempo,f2,'linear');
    
    % Calculo del oversampling factor
    K = f2/tiempo;     
    BW = K*tiempo;     
    alfa = fs/BW;      
    
    % --- Subplot señal en el tiempo ---
    subplot(length(fs_values),3,3*i-2);
    plot(t,x);
    title(sprintf('Señal en tiempo (fs = %d Hz, \\alpha = %.2f)',fs,alfa));
    xlabel('Tiempo [s]');
    ylabel('Amplitud');
    axis([0 tiempo -1 1]);
    grid on;
    
    % --- Subplot espectrograma ---
    subplot(length(fs_values),3,3*i-1);
    win = min(128,length(x));
    noverlap = max(0,floor(win*0.9));
    nfft = max(128,2^nextpow2(win));
    spectrogram(x,win,noverlap,nfft,fs,'yaxis');
    title(sprintf('Espectrograma (fs = %d Hz)',fs));
    
    % --- Subplot respuesta en frecuencia (FFT) ---
    N = length(x);
    X = fft(x, N);
    Xshift = fftshift(X);
    f = (-N/2:N/2-1)*(fs/N);  % eje de frecuencias en Hz
    
    subplot(length(fs_values),3,3*i);
    plot(f, abs(Xshift)/N);
    grid on;
    xlabel('Frecuencia [Hz]');
    ylabel('|X(f)|');
    title(sprintf('Respuesta en frecuencia (fs = %d Hz)',fs));
    xlim([0 f2*2]);  % mostrar hasta 2x ancho de banda del chirp
end
