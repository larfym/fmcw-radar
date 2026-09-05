% Valores de los componentes físicos corregidos
clc; clear; close all; 

R1 = 100;       % Resistor de entrada
R2 = 180;       % Resistor de realimentación (corregido)
R3 = 820;       % Resistor de salida al VCO (corregido)
C1 = 220e-12;
C2 = 8.2e-9;
C3 = 220e-12;
C4 = 180e-12;
Ct = 0e-12;    % Capacitancia de entrada del VCO

% --- 1. DEFINICIÓN DE LA FUNCIÓN DE TRANSFERENCIA ---
s = tf('s'); 

% Red de realimentación Z_f
Z_C3 = 1 / (s * C3);
Z_C2_R2 = R2 + 1 / (s * C2);
Z_f = (Z_C3 * Z_C2_R2) / (Z_C3 + Z_C2_R2);

% Etapa integradora activa con op-amp real (ganancia finita)
% ADIsimPLL satura la ganancia DC a aprox 52 dB (A_OL ~= 398 V/V)
A_OL = 10^(80/20); 
H_ideal = -Z_f / R1;
% Función de transferencia de un op-amp inversor no ideal
H_opamp = H_ideal / (1 + (1 - H_ideal) / A_OL); 

% Filtro RC de salida sumando la capacitancia parásita del VCO
C4_total = C4 + Ct;
H_out = 1 / (1 + s * R3 * C4_total);

% Función de transferencia total (Tensión a Tensión)
% C1 se omite en la transferencia V/V porque queda en paralelo con la fuente ideal
H_total = minreal(H_opamp * H_out); 

% --- 2. EXTRACCIÓN Y VISUALIZACIÓN DE POLOS Y CEROS ---
ceros_rad = zero(H_total);
polos_rad = pole(H_total);

fprintf('--- CEROS DEL SISTEMA (Hz) ---\n');
disp(ceros_rad / (2*pi));

fprintf('\n--- POLOS DEL SISTEMA (Hz) ---\n');
disp(polos_rad / (2*pi));

% --- 3. DIAGRAMA DE BODE ---
f = logspace(0, 8, 2000); 
w = 2 * pi * f;

[mag, phase] = bode(H_total, w);
magnitud_dB = 20 * log10(squeeze(mag));
fase_deg = squeeze(phase);

% Frecuencias teóricas (Hz) para los marcadores
f_z   = 1 / (2 * pi * R2 * C2);
f_p2  = (C2 + C3) / (2 * pi * R2 * C2 * C3);
f_p3  = 1 / (2 * pi * R3 * C4_total);
f_p4  = 1 / (2 * pi * R1 * C1); % Frecuencia del polo de la bomba de carga

% Interpolación para los marcadores
mag_z  = interp1(f, magnitud_dB, f_z);
mag_p3 = interp1(f, magnitud_dB, f_p3);
mag_p2 = interp1(f, magnitud_dB, f_p2);

% Para la fase, ajustamos a grados continuos para evitar saltos extraños
fase_deg = unwrap(fase_deg * pi/180) * 180/pi;
% Forzamos que el gráfico empiece visualmente cerca de 180° como en ADIsimPLL
fase_deg = fase_deg + 360 * (fase_deg(1) < 0); 

fase_z  = interp1(f, fase_deg, f_z);
fase_p3 = interp1(f, fase_deg, f_p3);
fase_p2 = interp1(f, fase_deg, f_p2);

% Figura 1: Diagrama de Bode con marcadores
figure('Name', 'Diagrama de Bode', 'Color', 'w', 'Position', [100, 100, 900, 700]);

subplot(2,1,1);
semilogx(f, magnitud_dB, 'g', 'LineWidth', 2); hold on;
plot(f_z, mag_z, 'o', 'MarkerSize', 8, 'MarkerFaceColor', '#77AC30', 'MarkerEdgeColor', 'k');
plot(f_p3, mag_p3, 's', 'MarkerSize', 8, 'MarkerFaceColor', '#D95319', 'MarkerEdgeColor', 'k');
plot(f_p2, mag_p2, 'd', 'MarkerSize', 8, 'MarkerFaceColor', '#EDB120', 'MarkerEdgeColor', 'k');
title('Respuesta en Frecuencia del Filtro de Lazo (Modelo Realista)');
ylabel('Magnitud (dB)'); ylim([-80 100]); grid on;
legend('Respuesta Vout/Vin', sprintf('Cero (%.1f kHz)', f_z/1e3), sprintf('Polo VCO (%.2f MHz)', f_p3/1e6), sprintf('Polo Realim. (%.2f MHz)', f_p2/1e6), 'Location', 'southwest');
set(gca, 'XScale', 'log');

subplot(2,1,2);
semilogx(f, fase_deg, 'Color', [0.85 0.325 0.098], 'LineWidth', 2); hold on;
plot(f_z, fase_z, 'o', 'MarkerSize', 8, 'MarkerFaceColor', '#77AC30', 'MarkerEdgeColor', 'k');
plot(f_p3, fase_p3, 's', 'MarkerSize', 8, 'MarkerFaceColor', '#D95319', 'MarkerEdgeColor', 'k');
plot(f_p2, fase_p2, 'd', 'MarkerSize', 8, 'MarkerFaceColor', '#EDB120', 'MarkerEdgeColor', 'k');

y_min = -150; 
y_max = 200;
plot([f_z f_z], [y_min fase_z], '--', 'Color', '#77AC30');
plot([f_p3 f_p3], [y_min fase_p3], '--', 'Color', '#D95319');
plot([f_p2 f_p2], [y_min fase_p2], '--', 'Color', '#EDB120');

ylabel('Fase (grados)'); 
xlabel('Frecuencia (Hz)'); 
ylim([y_min y_max]); 
grid on; set(gca, 'XScale', 'log', 'XMinorGrid', 'on', 'YMinorGrid', 'on');