%% =========================================================================
%% 1. CÁLCULO MATEMÁTICO IDEAL (CHEBYSHEV TIPO II)
%% =========================================================================

% Definición de parámetros originales (Frecuencias en Hz)
Fp = [1550e6 1850e6];
Fs = [1400e6 2000e6];
Rp = 0.05;
Rs = 28;

% Frecuencia central de diseño
f0 = 1700e6; 

% Conversión a rad/s y cálculo del orden
Wp = 2 * pi * Fp;
Ws = 2 * pi * Fs;
[n, Wn] = cheb2ord(Wp, Ws, Rp, Rs, 's');

% Diseñar el filtro matemático Chebyshev Tipo II
[b, a] = cheby2(n, Rs, Wn, 's');

% Vector de frecuencias para evaluar el gráfico matemático
f_vector = linspace(1000e6, 2500e6, 2000); 
w_vector = 2 * pi * f_vector; 

% Evaluar la respuesta analógica ideal
H = freqs(b, a, w_vector);

% Cálculo de parámetros S ideales por conservación de energía
S21_ideal_lineal = abs(H);
S21_ideal_db = 20 * log10(max(S21_ideal_lineal, 1e-6)); 

S11_ideal_lineal = sqrt(1 - S21_ideal_lineal.^2);
S11_ideal_db = 20 * log10(max(S11_ideal_lineal, 1e-6)); 

%% =========================================================================
%% 2. GENERACIÓN Y CONFIGURACIÓN GEOMÉTRICA DEL FILTRO HAIRPIN (FR4)
%% =========================================================================

% Crear el objeto de la toolbox usando el orden calculado (n = 5)
hairpinfilter = filterHairpin;
hairpinfilter.FilterOrder = n;

% Configuración del Sustrato real (FR4)
sustrato = dielectric('FR4');
sustrato.EpsilonR = 4.3;
sustrato.LossTangent = 0.01;
sustrato.Thickness = 1.55e-3; % 1.55 mm en metros

hairpinfilter.Substrate = sustrato;
hairpinfilter.Height = 1.55e-3;

% Configuración del Conductor (Cobre)
conductor = metal('Copper');
conductor.Thickness = 0.033e-3; % 33 um en metros
hairpinfilter.Conductor = conductor;

% Dimensiones de los puertos de entrada/salida (Línea de 50 Ohms)
hairpinfilter.PortLineWidth = 5.0e-3;  % 3 mm de ancho
hairpinfilter.PortLineLength = 5.0e-3; % 8 mm de largo

% Dimensiones físicas de cada Resonador en "U" (Cálculo a 1.7 GHz)
hairpinfilter.Resonator.Width = 2.973e-3;                       % Ancho de pista: 3 mm
hairpinfilter.Resonator.Spacing = 3.5e-3;                     % Espacio interno de la U: 3.5 mm
hairpinfilter.Resonator.Length = [20.98e-3 6.5e-3 20.98e-3]; % [Brazo1 Base Brazo2] en metros

% Configuración del acoplamiento de entrada/salida (Feed)
hairpinfilter.FeedType = 'Coupled';
hairpinfilter.CoupledLineWidth = 2.973e-3;   
hairpinfilter.CoupledLineLength = 20.98e-3; 
hairpinfilter.CoupledLineSpacing = [0.8e-3 0.8e-3]; % Distancia S0 inicial (0.8 mm)

% Espaciados físicos iniciales entre las horquillas [S12 S23 S34 S45]
hairpinfilter.Spacing = [1.2e-3 1.8e-3 1.8e-3 1.2e-3]; 

% Mostrar la estructura geométrica en 3D
figure('Name', 'Geometría del Filtro Hairpin 3D');
show(hairpinfilter);

%% =========================================================================
%% 3. SIMULACIÓN ELECTROMAGNÉTICA (MoM) Y GRÁFICOS COMPARATIVOS
%% =========================================================================

% Vector de frecuencias para la simulación EM (menos puntos para agilizar el cálculo)
f_sim = linspace(1000e6, 2500e6, 60); 

disp('Corriendo simulación electromagnética del Layout... Esto puede demorar unos instantes.');
s_em = sparameters(hairpinfilter, f_sim);

% Extraer los datos simulados en dB
S11_em_db = rfparam(s_em, 1, 1);
S21_em_db = rfparam(s_em, 2, 1);

% Graficar la comparación de resultados
figure('Name', 'Comparación de Parámetros S: Ideal vs EM Real');

% --- Gráfico de S21 (Transmisión) ---
subplot(2,1,1);
plot(f_vector / 1e6, S21_ideal_db, 'LineStyle', '--', 'Color', [0 0.45 0.74], 'LineWidth', 1.5);
hold on;
plot(f_sim / 1e6, S21_em_db, 'LineStyle', '-', 'Color', [0 0.45 0.74], 'LineWidth', 2.5);
grid on;
yline(-Rs, '--r', 'Especificación Rs');
xline(Fp/1e6, ':k');
title('Parámetro S21 (Transmisión)');
xlabel('Frecuencia (MHz)');
ylabel('Magnitud (dB)');
legend('S21 Ideal (Matemático)', 'S21 Real (Simulación EM)', 'Location', 'southwest');
ylim([-60 5]);
xlim([1000 2500]);

% --- Gráfico de S11 (Reflexión) ---
subplot(2,1,2);
plot(f_vector / 1e6, S11_ideal_db, 'LineStyle', '--', 'Color', [0.85 0.33 0.1], 'LineWidth', 1.5);
hold on;
plot(f_sim / 1e6, S11_em_db, 'LineStyle', '-', 'Color', [0.85 0.33 0.1], 'LineWidth', 2.5);
grid on;
yline(-Rp, '--k', 'Especificación Rp');
xline(Fp/1e6, ':k');
title('Parámetro S11 (Reflexión / Acoplamiento)');
xlabel('Frecuencia (MHz)');
ylabel('Magnitud (dB)');
legend('S11 Ideal (Matemático)', 'S11 Real (Simulación EM)', 'Location', 'southwest');
ylim([-60 5]);
xlim([1000 2500]);

disp('Simulación y gráficos completados con éxito.');